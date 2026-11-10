"""
Band descriptors derived from a multi-frequency Touchstone export.

The .s2p covers a narrow band around the design frequency (1 GHz at 30 GHz in
the current sweeps). Collapsing that band to a single scalar is fragile: a
resonance may or may not fall inside it, so the scalar is not comparable
across samples.

Instead every sample carries three descriptors that are always well defined:

    dphi_df           local phase slope at f0, deg/GHz  (central difference)
    band_spread       max - min of the major-axis phase over the band, deg
    resonance_in_band 1 if |S| dips below a threshold inside the band, else 0

`band_spread` is the honest wideband measure: it is the phase variation the
element would show if used over the band, and the absence of a resonance gives
a small value, which is correct rather than missing. `resonance_in_band` is a
flag for filtering, not a feature, precisely so that "no resonance" does not
turn into a ragged array.
"""

from __future__ import annotations

import numpy as np


def phase_slope_at(
    freq_ghz: np.ndarray,
    phase_deg: np.ndarray,
    f0_ghz: float,
    step_ghz: float = 0.1,
) -> float:
    """
    Local phase slope at f0 in deg/GHz, by central difference.

    The phase is unwrapped first: a wrapped phase would turn a small slope into
    a ±360 deg jump. Returns NaN when the band does not contain f0 ± step.
    """
    if freq_ghz.size < 2:
        return float("nan")

    unwrapped = np.rad2deg(np.unwrap(np.deg2rad(phase_deg)))

    lo, hi = f0_ghz - step_ghz, f0_ghz + step_ghz
    inside = (freq_ghz >= lo) & (freq_ghz <= hi)
    if np.count_nonzero(inside) < 2:
        return float("nan")

    slope, _ = np.polyfit(freq_ghz[inside], unwrapped[inside], 1)
    return float(slope)


def band_spread(phase_deg: np.ndarray) -> float:
    """
    Peak-to-peak phase variation across the whole band, deg.

    Unwrapped so that a genuine 300 degree excursion is reported as 300, not
    as the 60 degrees left after wrapping.
    """
    if phase_deg.size == 0:
        return float("nan")
    unwrapped = np.rad2deg(np.unwrap(np.deg2rad(phase_deg)))
    return float(np.ptp(unwrapped))


def has_resonance(mag_major: np.ndarray, dip_db: float = -3.0) -> int:
    """
    1 when the major-axis reflection dips below `dip_db` inside the band.

    A resonance shows up as a notch in |S|; this is the robust indicator. It is
    returned as an integer flag rather than a float, and as an ordinal 0/1 so
    that it can be used for filtering without introducing NaN.
    """
    if mag_major.size == 0:
        return 0
    with np.errstate(divide="ignore"):
        mag_db = 20.0 * np.log10(np.maximum(mag_major, 1e-12))
    return int(np.any(mag_db < dip_db))


def band_descriptors(
    freq_ghz: np.ndarray,
    phi_major_deg: np.ndarray,
    mag_major: np.ndarray,
    f0_ghz: float,
    slope_step_ghz: float = 0.1,
    resonance_dip_db: float = -3.0,
) -> dict[str, float]:
    """All three descriptors for one sample, keyed by their feature names."""
    return {
        "dphi_df": phase_slope_at(freq_ghz, phi_major_deg, f0_ghz, slope_step_ghz),
        "band_spread": band_spread(phi_major_deg),
        "resonance_in_band": float(has_resonance(mag_major, resonance_dip_db)),
    }
