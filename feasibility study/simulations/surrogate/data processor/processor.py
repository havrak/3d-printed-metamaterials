"""
Walk a CST sweep tree, load and validate the data, and write one dataset file.

Usage
-----
    python processor.py                       # use config defaults
    python processor.py --root <dir> --out <file>
    python processor.py --no-band             # skip band descriptors entirely
    python processor.py --dry-run             # report counts, write nothing

Pipeline
--------
1. Walk `root` recursively; every directory holding .s2p files is a sweep.
2. Load the navigator CSV as metadata and join it to the Touchstone records by
   run id taken from the filename.
3. Rotate each sample into its eigenbasis and record theta* and the residual.
4. Reject samples that fail any filter (see FILTERS below).
5. Apply the feature transforms from config.py.
6. Write X, X_raw, Y, band, names and per-sample metadata to an .npz.

Filters, all recorded so the rejection reasons are auditable:
    missing_metadata   a required parameter is NaN
    clearance          the rotated ellipse comes too close to the cell edge
    eigenbasis         theta* is far from the geometric rotation, or the
                       residual is too large
    nonfinite          a target or feature came out NaN or inf
"""

from __future__ import annotations

import argparse
import sys
from collections import Counter
from dataclasses import dataclass, field
from pathlib import Path

import numpy as np

# Allow `python processor.py` from inside this directory as well as `-m`.
sys.path.insert(0, str(Path(__file__).resolve().parent))

import config
import features as feat
import metadata
import rotation
import touchstone


# --------------------------------------------------------------------------- #
# Records
# --------------------------------------------------------------------------- #

@dataclass
class Sample:
    """Everything known about one configuration, pre-filter."""

    source_dir: str
    run_id: int | None
    # raw geometry, mm where absolute
    a_mm: float
    ratio: float
    p_ratio: float
    eps_r: float
    h_pillar_mm: float
    h_base_mm: float
    # targets at f0
    r_major: complex
    r_minor: complex
    # diagnostics
    theta_star_deg: float
    residual_linear: float
    residual_relative: float
    # band descriptors; empty when --no-band
    band: dict[str, float] = field(default_factory=dict)
    # rejection bookkeeping
    reject: str | None = None


REQUIRED_PARAMS = ("a", "H_pillar", "ratio", "epsilon_r", "P_ratio")


# --------------------------------------------------------------------------- #
# Loading
# --------------------------------------------------------------------------- #

def find_sweep_dirs(root: Path) -> list[Path]:
    """Every directory under root that directly contains .s2p files."""
    dirs = sorted({p.parent for p in root.rglob("*.s2p")})
    return dirs


def load_sweep_dir(
    directory: Path,
    f0_ghz: float,
    with_band: bool,
    log: Counter,
) -> list[Sample]:
    """Load every .s2p in one sweep directory, joining metadata from the CSV."""
    s2p_files = sorted(directory.glob("*.s2p"))
    if not s2p_files:
        return []

    csv_path = metadata.find_navigator_csv(directory)
    if csv_path is None:
        print(f"  {directory.name}: no navigator CSV, skipping {len(s2p_files)} files")
        log["dir_missing_csv"] += len(s2p_files)
        return []

    records = metadata.parse_navigator_csv(csv_path)

    samples: list[Sample] = []
    for path in s2p_files:
        run_id = touchstone.parse_run_id(path.name)
        record = records.get(run_id) if run_id is not None else None

        if record is None:
            log["missing_metadata"] += 1
            continue

        try:
            ts = touchstone.parse_touchstone(path)
        except ValueError as exc:
            print(f"  {path.name}: {exc}")
            log["parse_error"] += 1
            continue

        # Only the rotation angle is needed across the band, so find theta*
        # once at f0 and reuse it: the eigenbasis is a property of the cell
        # geometry and does not move with frequency.
        idx = ts.at(f0_ghz)
        basis = rotation.rotate_to_principal(
            ts.s11[idx], ts.s22[idx], ts.s12[idx], ts.s21[idx],
            step_deg=config.THETA_SCAN_STEP_DEG,
        )

        band: dict[str, float] = {}
        if with_band and ts.is_multifrequency:
            fixed = rotation.rotate_at_angle(
                ts.s11, ts.s22, ts.s12, ts.s21, basis.theta_star_deg,
            )
            phi_major_band = np.rad2deg(np.angle(fixed[0]))
            mag_major_band = np.abs(fixed[0])
            band = feat.band_descriptors(
                ts.freq_ghz, phi_major_band, mag_major_band,
                f0_ghz,
                slope_step_ghz=config.BAND_SLOPE_DF_GHZ,
                resonance_dip_db=config.RESONANCE_DIP_DB,
            )

        samples.append(Sample(
            source_dir=str(directory),
            run_id=run_id,
            a_mm=record.get("a"),
            ratio=record.get("ratio"),
            p_ratio=record.get("P_ratio"),
            eps_r=record.get("epsilon_r"),
            h_pillar_mm=record.get("H_pillar"),
            h_base_mm=record.get("H_base", 0.0),
            r_major=basis.r_major,
            r_minor=basis.r_minor,
            theta_star_deg=basis.theta_star_deg,
            residual_linear=basis.residual_linear,
            residual_relative=basis.residual_relative,
            band=band,
        ))

    return samples


# --------------------------------------------------------------------------- #
# Validation
# --------------------------------------------------------------------------- #

def validate(samples: list[Sample], lam0_mm: float) -> list[Sample]:
    """
    Mark samples that fail a filter, in the order the filters are applied.

    Marking rather than dropping keeps the rejection statistics honest; the
    caller drops them afterwards.
    """
    if not samples:
        return samples

    n = len(samples)

    a = np.array([s.a_mm for s in samples])
    ratio = np.array([s.ratio for s in samples])
    p_ratio = np.array([s.p_ratio for s in samples])
    eps_r = np.array([s.eps_r for s in samples])
    h_pillar = np.array([s.h_pillar_mm for s in samples])
    theta = np.array([s.theta_star_deg for s in samples])
    resid_lin = np.array([s.residual_linear for s in samples])

    has_meta = np.isfinite(a) & np.isfinite(ratio) & np.isfinite(p_ratio) \
        & np.isfinite(eps_r) & np.isfinite(h_pillar)

    fits = np.zeros(n, dtype=bool)
    fits[has_meta] = rotation.fits_in_cell(
        a[has_meta], ratio[has_meta], p_ratio[has_meta],
        lam0_mm, config.CLEARANCE_MM,
    )

    angle_ok = rotation.angle_matches_rotation(
        theta, config.ELLIPSE_ROTATION_DEG, config.THETA_STAR_TOL_DEG,
    )
    resid_ok = np.isfinite(resid_lin) & (resid_lin <= config.RESIDUAL_MAX_LINEAR)

    finite_targets = np.array([
        np.isfinite(s.r_major.real) and np.isfinite(s.r_minor.real)
        and np.isfinite(s.r_major.imag) and np.isfinite(s.r_minor.imag)
        for s in samples
    ])

    for i, s in enumerate(samples):
        if not has_meta[i]:
            s.reject = "missing_metadata"
        elif not fits[i]:
            s.reject = "clearance"
        elif not angle_ok[i]:
            s.reject = "eigenbasis_angle"
        elif not resid_ok[i]:
            s.reject = "eigenbasis_residual"
        elif not finite_targets[i]:
            s.reject = "nonfinite"

    return samples


# --------------------------------------------------------------------------- #
# Assembly
# --------------------------------------------------------------------------- #

def build_arrays(samples: list[Sample]) -> dict[str, np.ndarray]:
    """Turn the surviving samples into the arrays the surrogate consumes."""
    geom = feat.RawGeometry(
        a_mm=np.array([s.a_mm for s in samples]),
        ratio=np.array([s.ratio for s in samples]),
        p_ratio=np.array([s.p_ratio for s in samples]),
        eps_r=np.array([s.eps_r for s in samples]),
        h_pillar_mm=np.array([s.h_pillar_mm for s in samples]),
        h_base_mm=np.array([s.h_base_mm for s in samples]),
    )

    names: list[str] = []
    columns: list[np.ndarray] = []
    for name, fn in config.FEATURE_TRANSFORMS:
        names.append(name)
        columns.append(np.asarray(fn(geom, config.LAMBDA0_MM), dtype=float))
    X = np.column_stack(columns) if columns else np.zeros((len(geom), 0))

    X_raw = np.column_stack([
        geom.a_mm, geom.ratio, geom.p_ratio, geom.eps_r,
        geom.h_pillar_mm, geom.h_base_mm,
    ])

    # Targets: real and imaginary parts of both principal coefficients.
    # Predicting the complex coefficient rather than the phase avoids the
    # 0/360 degree wrap discontinuity, which no regressor can learn across.
    Y = np.column_stack([
        [s.r_major.real for s in samples],
        [s.r_major.imag for s in samples],
        [s.r_minor.real for s in samples],
        [s.r_minor.imag for s in samples],
    ])

    band_names = list(samples[0].band.keys()) if samples and samples[0].band else []
    band = (np.column_stack([[s.band[k] for s in samples] for k in band_names])
            if band_names else np.zeros((len(samples), 0)))

    meta = {
        "source_dir": np.array([s.source_dir for s in samples]),
        "run_id": np.array([s.run_id if s.run_id is not None else -1 for s in samples]),
        "theta_star_deg": np.array([s.theta_star_deg for s in samples]),
        "residual_linear": np.array([s.residual_linear for s in samples]),
        "residual_relative": np.array([s.residual_relative for s in samples]),
    }

    return {
        "X": X,
        "X_raw": X_raw,
        "Y": Y,
        "band": band,
        "feature_names": np.array(names),
        "raw_names": np.array([
            "a_mm", "ratio", "p_ratio", "eps_r", "h_pillar_mm", "h_base_mm",
        ]),
        "band_names": np.array(band_names),
        "target_names": np.array([
            "re_major", "im_major", "re_minor", "im_minor",
        ]),
        **meta,
    }


# --------------------------------------------------------------------------- #
# Entry point
# --------------------------------------------------------------------------- #

def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=config.DEFAULT_DATA_ROOT)
    parser.add_argument("--out", type=Path, default=config.DEFAULT_OUTPUT)
    parser.add_argument("--no-band", action="store_true",
                        help="skip band descriptors")
    parser.add_argument("--dry-run", action="store_true",
                        help="report counts only, write nothing")
    args = parser.parse_args(argv)

    root: Path = args.root
    if not root.is_absolute():
        # resolve relative to the repository root, i.e. four levels up from here
        root = (Path(__file__).resolve().parents[4] / root)
    if not root.is_dir():
        print(f"error: data root not found: {root}")
        return 1

    with_band = not args.no_band
    log: Counter = Counter()
    all_samples: list[Sample] = []

    dirs = find_sweep_dirs(root)
    print(f"found {len(dirs)} sweep directories under {root}")
    for d in dirs:
        before = len(all_samples)
        all_samples.extend(load_sweep_dir(d, config.F0_GHZ, with_band, log))
        print(f"  {d.name}: {len(all_samples) - before} samples")

    if not all_samples:
        print("error: no samples loaded")
        return 1

    all_samples = validate(all_samples, config.LAMBDA0_MM)

    rejected = Counter(s.reject for s in all_samples if s.reject)
    kept = [s for s in all_samples if s.reject is None]

    print(f"\nloaded {len(all_samples)} samples, kept {len(kept)}")
    for reason, count in rejected.most_common():
        print(f"  rejected {reason:22s} {count}")
    for reason, count in log.most_common():
        print(f"  skipped  {reason:22s} {count}")

    if not kept:
        print("error: every sample was rejected")
        return 1

    arrays = build_arrays(kept)
    print(f"\nX  {arrays['X'].shape}  features: {list(arrays['feature_names'])}")
    print(f"Y  {arrays['Y'].shape}")
    if arrays["band"].size:
        print(f"band {arrays['band'].shape}  {list(arrays['band_names'])}")

    if args.dry_run:
        print("\ndry run: nothing written")
        return 0

    out: Path = args.out
    if not out.is_absolute():
        out = Path(__file__).resolve().parent / out
    out.parent.mkdir(parents=True, exist_ok=True)
    np.savez_compressed(out, **arrays)
    print(f"\nwrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
