"""
Eigenbasis extraction and geometric validation.

The cell is a square with an elliptical pillar whose major axis is rotated by
45 degrees. That structure is mirror-symmetric about its diagonals, so the
principal axes of the reflection operator are the ellipse's major and minor
axes, at 45 and 135 degrees. The x/y basis that CST excites in is NOT the
eigenbasis, so an x-polarised wave couples into y.

Because the reflection operator is reciprocal it is symmetric, and it is
diagonalised by a congruence transform R(theta) S R(theta)^T. This module
searches for the theta that minimises the off-diagonal energy, which both
recovers the principal coefficients and validates the assumption: if the
recovered theta is far from 45 degrees, the cell has lost its diagonal
symmetry and its phases should not be trusted.
"""

from __future__ import annotations

from dataclasses import dataclass

import numpy as np


@dataclass
class PrincipalBasis:
    """Result of rotating one 2x2 reflection matrix into its eigenbasis."""

    theta_star_deg: float      # angle of minimum off-diagonal energy
    r_major: complex           # reflection along the major axis
    r_minor: complex           # reflection along the minor axis
    residual_linear: float     # |off-diagonal| sum after rotation
    residual_relative: float   # residual normalised by the diagonal magnitude

    @property
    def phi_major_deg(self) -> float:
        return float(np.angle(self.r_major, deg=True))

    @property
    def phi_minor_deg(self) -> float:
        return float(np.angle(self.r_minor, deg=True))

    @property
    def delta_phi_deg(self) -> float:
        """Minor-minus-major phase, wrapped to [0, 360)."""
        return float(np.mod(self.phi_minor_deg - self.phi_major_deg, 360.0))

    @property
    def mag_major(self) -> float:
        return float(abs(self.r_major))

    @property
    def mag_minor(self) -> float:
        return float(abs(self.r_minor))


def rotate_at_angle(
    sxx: np.ndarray,
    syy: np.ndarray,
    sxy: np.ndarray,
    syx: np.ndarray,
    theta_deg: float,
) -> tuple[np.ndarray, np.ndarray]:
    """
    Apply the congruence transform at a *fixed* angle to whole frequency axis.

    Used for band descriptors: the eigenbasis is a property of the cell
    geometry, not of frequency, so theta* found at f0 is reused across the
    band instead of being re-searched at every point.

    Returns the two principal coefficients as arrays over the input axis.
    """
    c, s_ = np.cos(np.deg2rad(theta_deg)), np.sin(np.deg2rad(theta_deg))

    r_major = c * c * sxx + c * s_ * (sxy + syx) + s_ * s_ * syy
    r_minor = s_ * s_ * sxx - c * s_ * (sxy + syx) + c * c * syy
    return r_major, r_minor


def rotate_to_principal(
    sxx: complex,
    syy: complex,
    sxy: complex,
    syx: complex,
    step_deg: float = 0.5,
) -> PrincipalBasis:
    """
    Rotate the x/y reflection matrix into its eigenbasis.

    The search is over [0, 90) degrees: for a diagonal-symmetric cell one
    quadrant suffices, and the major axis is then whichever diagonal entry
    carries the larger effective cross-section (identified by the caller via
    the recovered angle).

    Parameters are the four complex reflection terms at one frequency.
    """
    s = np.array([[sxx, sxy], [syx, syy]], dtype=complex)

    thetas = np.arange(0.0, 90.0, step_deg)
    best_resid = np.inf
    best_theta = 0.0
    best_rp = np.eye(2, dtype=complex)

    for theta in thetas:
        c, s_ = np.cos(np.deg2rad(theta)), np.sin(np.deg2rad(theta))
        r = np.array([[c, s_], [-s_, c]])
        rp = r @ s @ r.T

        resid = abs(rp[0, 1]) + abs(rp[1, 0])
        if resid < best_resid:
            best_resid = resid
            best_theta = theta
            best_rp = rp

    diag_mag = abs(best_rp[0, 0]) + abs(best_rp[1, 1])
    rel = best_resid / diag_mag if diag_mag > 0 else np.inf

    return PrincipalBasis(
        theta_star_deg=float(best_theta),
        r_major=complex(best_rp[0, 0]),
        r_minor=complex(best_rp[1, 1]),
        residual_linear=float(best_resid),
        residual_relative=float(rel),
    )


# --------------------------------------------------------------------------- #
# Geometric validation
# --------------------------------------------------------------------------- #

def ellipse_bounding_half_extent(a_mm: np.ndarray, ratio: np.ndarray) -> np.ndarray:
    """
    Half-extent of the axis-aligned bounding box of a 45-degree rotated ellipse.

    For semi-axes (a, b) rotated by theta the bounding box is
        X = sqrt((a cos t)^2 + (b sin t)^2)
    and at theta = 45 degrees with cos = sin = 1/sqrt(2) this reduces to
        sqrt((a^2 + b^2) / 2)
    which is symmetric in x and y, so one number checks both directions.

    Note that this is larger than b and approaches a as the ratio grows, which
    is why a more elongated ellipse permits a longer major axis before the
    cell is violated.
    """
    b_mm = a_mm / ratio
    return np.sqrt((a_mm ** 2 + b_mm ** 2) / 2.0)


def fits_in_cell(
    a_mm: np.ndarray,
    ratio: np.ndarray,
    p_ratio: np.ndarray,
    lam0_mm: float,
    clearance_mm: float,
) -> np.ndarray:
    """
    True where the rotated ellipse leaves at least `clearance_mm` to the cell
    edge on every side.
    """
    cell_mm = p_ratio * lam0_mm
    half_extent = ellipse_bounding_half_extent(a_mm, ratio)
    return half_extent <= (cell_mm / 2.0 - clearance_mm)


def angle_matches_rotation(
    theta_star_deg: np.ndarray,
    expected_deg: float,
    tol_deg: float,
) -> np.ndarray:
    """
    True where the recovered eigenbasis angle matches the geometric rotation.

    The comparison is modulo 90 degrees, because a rotation by theta and
    theta + 90 swap which principal axis is which but describe the same
    physical basis.
    """
    delta = np.mod(theta_star_deg - expected_deg + 45.0, 90.0) - 45.0
    return np.abs(delta) <= tol_deg
