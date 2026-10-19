import cadquery as cq
import numpy as np
import os

# ---------------- Config ----------------
OUT_DIR = "print_test_stl"

GRID_N   = 12          # array size
H_BASE   = 1.4         # mm, support/adhesion layer (fixed)
LAMBDA_MULT = 1.5      # pillar height = 1.5 * lambda_0
ROT_DEG  = 45.0        # ellipse major axis on the square diagonal

FREQS = {
    #  f0 [GHz]: period P [mm]
    30.0: 5.0,
    15.0: 10.0,
}

# Global selector: Choose which frequency array to generate, export, and display
SELECTED_FREQ = 30.0

# Global feature size constraints (in mm)
# These values are taken from Massaccesi2023, where minimal diameter 
# of cutout was 0.8 mm and maximal was set at 2.55 with UC width of 3 mm
MIN_FEATURE_MM = 0.8
MAX_FEATURE_OFFSET = 0.4  # Max size = cell_width - 0.4 mm


# "elliptical_pillar", "elliptical_void", "rhombus_pillar", "rhombus_void"
PILLAR_TYPE = "rhombus_pillar"


def lambda0_mm(f_ghz: float) -> float:
    c = 299.792458           # mm * GHz
    return c / f_ghz


def make_cell(P, H_pillar, major_dia, minor_dia, pillar_type):
    """
    One unit cell centred at origin:
      - base  : P x P x H_BASE, z in [0, H_BASE]
      - pillar: Either a rectangular block with an elliptical void,
                or a solid elliptical pillar.
    """
    base = cq.Workplane("XY").rect(P, P).extrude(H_BASE)
    a, b = major_dia / 2.0, minor_dia / 2.0

    if pillar_type == "elliptical_void":
        pillar = (
            cq.Workplane("XY")
            .workplane(offset=H_BASE)
            .rect(P, P)
            .extrude(H_pillar)
        )
        void = (
            cq.Workplane("XY")
            .workplane(offset=H_BASE)
            .ellipse(a, b)
            .extrude(H_pillar + 1.0)        # overshoot, then cut
            .rotate((0, 0, H_BASE), (0, 0, H_BASE + 1), ROT_DEG)
        )
        pillar = pillar.cut(void)
    elif pillar_type == "elliptical_pillar":
        pillar = (
            cq.Workplane("XY")
            .workplane(offset=H_BASE)
            .ellipse(a, b)
            .extrude(H_pillar)
            .rotate((0, 0, H_BASE), (0, 0, H_BASE + 1), ROT_DEG)
        )
    elif pillar_type in ("rhombus_pillar", "rhombus_void"):
        rhombus_profile = (
            cq.Workplane("XY")
            .workplane(offset=H_BASE)
            .polyline([(a, 0), (0, b), (-a, 0), (0, -b)])
            .close()
        )
        if pillar_type == "rhombus_void":
            pillar = (
                cq.Workplane("XY")
                .workplane(offset=H_BASE)
                .rect(P, P)
                .extrude(H_pillar)
            )
            void = (
                rhombus_profile
                .extrude(H_pillar + 1.0)
                .rotate((0, 0, H_BASE), (0, 0, H_BASE + 1), ROT_DEG)
            )
            pillar = pillar.cut(void)
        else:
            pillar = (
                rhombus_profile
                .extrude(H_pillar)
                .rotate((0, 0, H_BASE), (0, 0, H_BASE + 1), ROT_DEG)
            )
    else:
        raise ValueError(f"Unknown PILLAR_TYPE: {pillar_type}")

    return base.union(pillar)


def make_gradient_array(f_ghz, fracs):
    """
    Build the full 10x10 2D parameter sweep panel using the provided fracs list:
      - columns (ix) sweep major axis fractions
      - rows (iy) sweep minor axis fractions
    """
    P = FREQS[f_ghz]
    H_pillar = LAMBDA_MULT * lambda0_mm(f_ghz)

    x0 = -(GRID_N - 1) / 2.0 * P
    y0 = -(GRID_N - 1) / 2.0 * P

    solid = None
    for ix, major_frac in enumerate(fracs):
        major_dia = major_frac * P
        for iy, minor_frac in enumerate(fracs):
            minor_dia = minor_frac * P
            
            cell = make_cell(P, H_pillar, major_dia, minor_dia, PILLAR_TYPE)
            placed = cell.translate((x0 + ix * P, y0 + iy * P, 0))
            solid = placed if solid is None else solid.union(placed)
            
    return solid, dict(P=P, H_pillar=H_pillar, H_total=H_BASE + H_pillar)


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    f_ghz = SELECTED_FREQ
    P = FREQS[f_ghz]
    
    # Compute fractions dynamically based on fixed mm limits for this cell width (P)
    min_frac = MIN_FEATURE_MM / P
    max_frac = (P - MAX_FEATURE_OFFSET) / P
    
    fracs = list(np.linspace(min_frac, max_frac, GRID_N))
    
    print(f"\n=== {f_ghz} GHz  (P = {P} mm) ===")
    print(f"  Pillar Type: {PILLAR_TYPE}")
    print(f"  Feature limits: {MIN_FEATURE_MM} mm to {P - MAX_FEATURE_OFFSET} mm")
    print(f"  Computed fractions: {[f'{x:.3f}' for x in fracs]}")
    
    solid, meta = make_gradient_array(f_ghz, fracs)
    filename = f"{PILLAR_TYPE}_{int(f_ghz)}GHz.stl"
    stl = os.path.join(OUT_DIR, filename)
    cq.exporters.export(solid, stl)
    print(f"  H_pillar={meta['H_pillar']:.1f}  H_total={meta['H_total']:.1f}  -> {stl}")
    return fracs


out = main()

result, _ = make_gradient_array(SELECTED_FREQ, out)