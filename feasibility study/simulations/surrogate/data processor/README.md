# Data processor

Turns a tree of CST sweep exports into one training-ready dataset for the
surrogate model.

## Run

```bash
cd "feasibility study/simulations/surrogate/data processor"
python processor.py --dry-run        # counts only, writes nothing
python processor.py                  # writes out/dataset.npz
```

`--root` and `--out` override the defaults in `config.py`. `--no-band` skips
the wideband descriptors.

Requires only numpy.

## Input layout

```
data/
├── sweep_A/
│   ├── result_navigator.csv
│   ├── ..._3D_Run_RunID_1.s2p
│   └── ..._3D_Run_RunID_2.s2p
└── sweep_B/
    └── ...
```

Every subdirectory holding `.s2p` files is treated as one sweep and must have a
navigator CSV. The join key is the run id in the filename
(`..._RunID_<id>.s2p`) against the CSV's run-id column.

## Output

`out/dataset.npz`, load with `np.load(path)`:

| key | shape | meaning |
|---|---|---|
| `X` | `(n, f)` | transformed input features |
| `X_raw` | `(n, 6)` | raw geometry: `a_mm, ratio, p_ratio, eps_r, h_pillar_mm, h_base_mm` |
| `Y` | `(n, 4)` | `Re/Im` of `R_major` then `R_minor` at f0 |
| `band` | `(n, 3)` | `dphi_df`, `band_spread`, `resonance_in_band` |
| `feature_names`, `raw_names`, `target_names`, `band_names` | | column labels |
| `source_dir`, `run_id` | `(n,)` | provenance |
| `theta_star_deg`, `residual_linear`, `residual_relative` | `(n,)` | eigenbasis diagnostics |

## Why complex targets, not phases

`Y` holds the complex principal reflection coefficients, not `phi_major` /
`phi_minor`. Phase wraps at 360 degrees, so identical geometries would map to
both 0 and 360 and a regressor would average them toward 180. `Re/Im` are
continuous through resonance. Derive whatever you need afterwards:

```python
r_major = Y[:, 0] + 1j * Y[:, 1]
r_minor = Y[:, 2] + 1j * Y[:, 3]
phi_major = np.rad2deg(np.angle(r_major))
delta_phi = np.rad2deg(np.angle(r_minor * np.conj(r_major)))   # wrap-safe
```

## Feature transforms

Defined in `config.FEATURE_TRANSFORMS`, applied in order, one column each:

| feature | expression | rationale |
|---|---|---|
| `fill_fraction` | `pi*a*b / P^2` | dielectric loading of the cell |
| `h_pillar_electrical` | `(H_pillar/l0)*sqrt(eps_r)` | electrical height, scale-free |
| `h_base_electrical` | `(H_base/l0)*sqrt(eps_r)` | same, for the base layer |
| `log_ratio` | `ln(a/b)` | anisotropy strength, near-log response |
| `eps_r` | `eps_r` | resonator Q |

Add or replace a feature by editing that list; nothing else changes.

`H_pillar` and `H_base` are stored in absolute mm in the CSVs while `a` and
`P_ratio` are normalised. The transforms above divide by `lambda0` so every
feature is invariant under the 30 GHz -> 15 GHz frequency scaling.

## Filters

Applied in `validate()`, in this order. A sample is dropped at the first
failure and the reason is counted.

| reason | test |
|---|---|
| `missing_metadata` | a required parameter is NaN |
| `clearance` | rotated-ellipse bounding box exceeds `P/2 - 0.2 mm` |
| `eigenbasis_angle` | `theta_star` deviates from 45 deg by more than 10 deg |
| `eigenbasis_residual` | linear residual above `RESIDUAL_MAX_LINEAR` |
| `nonfinite` | a target came out NaN or inf |

The clearance test uses the axis-aligned bounding box of a 45-degree rotated
ellipse, `sqrt((a^2 + b^2)/2)`, which is correct for both directions because
the box is square. A more elongated ellipse permits a larger `a` before
violating, since its bounding box is smaller for the same major axis.

## Multi-frequency data

The Touchstone export spans ~1 GHz around f0. Rather than reduce that to one
scalar — which is inconsistent, because a resonance may or may not fall inside
the band — each sample carries three always-defined descriptors:

- `dphi_df` — local major-axis phase slope at f0, deg/GHz
- `band_spread` — max minus min major-axis phase over the band, deg
- `resonance_in_band` — `1` if `|S|` dips below `RESONANCE_DIP_DB` inside the band

`band_spread` is the honest wideband measure and is small when there is no
resonance, which is a correct answer rather than a missing one.
`resonance_in_band` is a flag for filtering wideband studies, not a feature, so
that "no resonance" never produces a ragged array.

## Adding a second processor

The surrogate trainer is a separate program. It consumes `dataset.npz` and does
not re-read the Touchstone files.
