"""
Touchstone (.s2p) parsing.

Deliberately strict about only what this project produces: a CST export in
magnitude-angle format ("# Hz S MA R 50") for a two-mode Floquet port.

The port mapping assumed throughout is:

    Touchstone port 1 = CST port Zmax mode 1 = global x (TE00)
    Touchstone port 2 = CST port Zmax mode 2 = global y (TM00)

so, for the 2x2 reflection matrix in the x/y basis:

    S11 = Sxx    S22 = Syy    S12 = Sxy    S21 = Syx
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path

import numpy as np


@dataclass
class TouchstoneData:
    """One .s2p file: a frequency axis plus the complex 2x2 reflection matrix."""

    freq_ghz: np.ndarray      # (n_freq,)
    s11: np.ndarray           # (n_freq,) complex, x -> x
    s21: np.ndarray           # (n_freq,) complex, x -> y
    s12: np.ndarray           # (n_freq,) complex, y -> x
    s22: np.ndarray           # (n_freq,) complex, y -> y

    def __len__(self) -> int:
        return int(self.freq_ghz.shape[0])

    @property
    def n_freq(self) -> int:
        return int(self.freq_ghz.shape[0])

    @property
    def is_multifrequency(self) -> bool:
        return self.n_freq > 1

    def at(self, f_ghz: float) -> int:
        """Index of the frequency sample nearest f_ghz."""
        return int(np.argmin(np.abs(self.freq_ghz - f_ghz)))


_UNIT_SCALE = {
    # multiplier that converts the file's unit into GHz
    "hz": 1e-9,
    "khz": 1e-6,
    "mhz": 1e-3,
    "ghz": 1.0,
}


def parse_touchstone(path: Path) -> TouchstoneData:
    """
    Parse a two-port Touchstone file in magnitude-angle format.

    The stored S-parameters are values as written, never renormalised. CST
    writes `R 50.0` on the option line regardless of the Floquet port's actual
    reference (the free-space wave impedance), and these are unit-cell Floquet
    reflection coefficients referred to that impedance, so any renormalisation
    would replace the physical quantity with a different one.

    Raises ValueError with the offending line if the file does not match the
    expected layout, rather than silently producing misaligned arrays.
    """
    freq_scale = 1e-9          # Touchstone default unit is Hz
    fmt = "ma"                 # magnitude-angle
    rows: list[tuple[float, complex, complex, complex, complex]] = []

    with open(path, "r", encoding="utf-8", errors="replace") as fh:
        for lineno, raw in enumerate(fh, start=1):
            line = raw.strip()
            if not line:
                continue

            if line.startswith("!"):
                # CST annotates the swept parameters here; not needed, since
                # metadata comes from the navigator CSV
                continue

            if line.startswith("#"):
                tokens = line[1:].lower().split()
                for tok in tokens:
                    if tok in _UNIT_SCALE:
                        freq_scale = _UNIT_SCALE[tok]
                    elif tok in ("ma", "db"):
                        fmt = tok
                if fmt == "db":
                    raise ValueError(
                        f"{path}:{lineno}: DB format not supported, expected MA"
                    )
                continue

            values = [float(v) for v in line.split()]
            if len(values) < 9:
                # a two-port record on one line carries 9 numbers;
                # continuation lines for more ports are not expected here
                raise ValueError(
                    f"{path}:{lineno}: expected 9 values for a 2-port record, "
                    f"got {len(values)}"
                )

            f = values[0] * freq_scale
            s11 = values[1] * np.exp(1j * np.deg2rad(values[2]))
            s21 = values[3] * np.exp(1j * np.deg2rad(values[4]))
            s12 = values[5] * np.exp(1j * np.deg2rad(values[6]))
            s22 = values[7] * np.exp(1j * np.deg2rad(values[8]))
            rows.append((f, s11, s21, s12, s22))

    if not rows:
        raise ValueError(f"{path}: no data records found")

    arr = np.asarray(rows, dtype=complex)
    freq = arr[:, 0].real
    order = np.argsort(freq)

    return TouchstoneData(
        freq_ghz=freq[order],
        s11=arr[order, 1],
        s21=arr[order, 2],
        s12=arr[order, 3],
        s22=arr[order, 4],
    )


def parse_run_id(filename: str) -> int | None:
    """
    Extract <id> from a CST sweep export named like

        ..._3D_Run_RunID_<id>.s2p

    Returns None when the pattern is absent, so the caller can fall back to
    the file header.
    """
    match = re.search(r"RunID_(\d+)", filename)
    return int(match.group(1)) if match else None
