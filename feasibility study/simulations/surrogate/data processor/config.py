"""
Configuration for the data processor.

Everything tunable lives here: paths, the design frequency, the clearance
rule, the eigenbasis search, the feature transforms and the filters.

Nothing in this module imports the rest of the package, so it can be edited
freely without touching the processing logic.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Callable

import numpy as np

# --------------------------------------------------------------------------- #
# Speed of light
# --------------------------------------------------------------------------- #

C0_MM_GHZ = 299.792458  # mm * GHz, so lambda0[mm] = C0_MM_GHZ / f0[GHz]


# --------------------------------------------------------------------------- #
# Paths
# --------------------------------------------------------------------------- #

# Directory that contains one subdirectory per CST sweep; each subdirectory
# holds the .s2p files plus a result_navigator.csv.
DEFAULT_DATA_ROOT = Path(
    "feasibility study/simulations/data"
)

# Where the processed dataset is written.
DEFAULT_OUTPUT = Path(
    "feasibility study/simulations/surrogate/data processor/out/dataset.npz"
)


# --------------------------------------------------------------------------- #
# Design point
# --------------------------------------------------------------------------- #

F0_GHZ = 30.0
LAMBDA0_MM = C0_MM_GHZ / F0_GHZ


# --------------------------------------------------------------------------- #
# Geometry
# --------------------------------------------------------------------------- #

# Minimum gap between the rotated ellipse's bounding box and the cell edge, mm.
# The base clearance is a print-resolution constraint, so it stays absolute
# and does NOT scale with the cell.
CLEARANCE_MM = 0.2

# Ellipse major axis is rotated by this angle relative to the array axes.
ELLIPSE_ROTATION_DEG = 45.0


# --------------------------------------------------------------------------- #
# Eigenbasis search and validation
# --------------------------------------------------------------------------- #

# Angular scan step for the congruence transform, degrees.
THETA_SCAN_STEP_DEG = 0.5

# A cell is only in its eigenbasis if the recovered angle sits near the
# geometric rotation. Deviations mean the diagonal symmetry is broken.
THETA_STAR_TOL_DEG = 10.0

# Reject samples whose residual (linear, summed off-diagonal magnitude)
# exceeds this. Mainly completeness; the relative residual filter below is
# the one that actually discriminates.
RESIDUAL_MAX_LINEAR = 0.05


# --------------------------------------------------------------------------- #
# Feature transforms
# --------------------------------------------------------------------------- #
#
# Each transform takes the raw per-sample geometry (in mm where absolute) and
# returns one feature column. They are applied in the order listed, so adding
# or replacing a feature is a one-line change here.


@dataclass
class RawGeometry:
    """Raw per-sample geometry, before any transform. Length = n_samples."""

    a_mm: np.ndarray          # ellipse semi-major axis, mm
    ratio: np.ndarray         # a / b, always > 1
    p_ratio: np.ndarray       # cell size as a fraction of lambda0 (0.5 = lambda0/2)
    eps_r: np.ndarray         # relative permittivity
    h_pillar_mm: np.ndarray   # pillar height, absolute mm
    h_base_mm: np.ndarray     # base layer thickness, absolute mm

    def __len__(self) -> int:
        return int(self.a_mm.shape[0])


def _lambda_g_factor(eps_r: np.ndarray) -> np.ndarray:
    """sqrt(eps_r): converts physical length to electrical length in the medium."""
    return np.sqrt(eps_r)


def feat_fill_fraction(g: RawGeometry, lam0: float) -> np.ndarray:
    """
    Ellipse area divided by cell area.

    This is the dielectric fill fraction, the quantity that actually sets the
    effective permittivity of the cell. Much closer to physics than the raw
    semi-axis length.
    """
    b_mm = g.a_mm / g.ratio
    cell_mm = g.p_ratio * lam0
    return np.pi * g.a_mm * b_mm / (cell_mm ** 2)


def feat_electrical_height_pillar(g: RawGeometry, lam0: float) -> np.ndarray:
    """Pillar height in electrical wavelengths inside the dielectric."""
    return (g.h_pillar_mm / lam0) * _lambda_g_factor(g.eps_r)


def feat_electrical_height_base(g: RawGeometry, lam0: float) -> np.ndarray:
    """Base thickness in electrical wavelengths inside the dielectric."""
    return (g.h_base_mm / lam0) * _lambda_g_factor(g.eps_r)


def feat_log_ratio(g: RawGeometry, lam0: float) -> np.ndarray:
    """
    ln(a / b): the anisotropy strength, on a logarithmic scale.

    This is the parameter that controls the separation between the major- and
    minor-axis resonances, and hence the achievable phase difference. Log
    because the response is close to logarithmic in elongation.
    """
    return np.log(g.ratio)


def feat_eps_r(g: RawGeometry, lam0: float) -> np.ndarray:
    """Relative permittivity itself (low Q vs high Q)."""
    return g.eps_r


# The feature set. Order defines the column order of X.
FEATURE_TRANSFORMS: list[tuple[str, Callable[[RawGeometry, float], np.ndarray]]] = [
    ("fill_fraction",       feat_fill_fraction),
    ("h_pillar_electrical", feat_electrical_height_pillar),
    ("h_base_electrical",   feat_electrical_height_base),
    ("log_ratio",           feat_log_ratio),
    ("eps_r",               feat_eps_r),
]


# --------------------------------------------------------------------------- #
# Band descriptors
# --------------------------------------------------------------------------- #
#
# The .s2p export covers a narrow band around f0. Instead of collapsing it to
# a single number (which breaks when a resonance does/does not fall inside),
# every sample carries a fixed-length triple that is always well defined.

BAND_SLOPE_DF_GHZ = 0.1     # central-difference step for dphi/df, GHz
RESONANCE_DIP_DB = -3.0     # |S| below this counts as a resonance
BAND_FEATURE_NAMES = ["dphi_df", "band_spread", "resonance_in_band"]


# --------------------------------------------------------------------------- #
# Output
# --------------------------------------------------------------------------- #

OUTPUT_FORMAT = "npz"       # "npz" | "csv"
