"""
Overview of the CST sweep coverage in a directory tree.

Scans for `result_navigator.csv` files only, reads the swept parameters from
each, and renders one page showing what configurations exist and how densely
the tuning variable was sampled.

Hierarchy, outermost first:

    P_ratio -> epsilon_r -> H_pillar -> ratio -> a

Usage
-----
    python stats.py <directory>
    python stats.py <directory> --csv out.csv --png out.png --top 60
    python stats.py <directory> --no-png          # table only

Outputs
-------
    console   the tree table and the summary block
    CSV       one row per leaf, for grepping
    PNG       the same table plus a summary panel, one page

Only the navigator CSV is read; the .s2p files are not touched, so this is
fast even on a large tree.
"""

from __future__ import annotations

import argparse
import sys
from dataclasses import dataclass
from pathlib import Path

# --------------------------------------------------------------------------- #
# Configuration
# --------------------------------------------------------------------------- #

NAVIGATOR_NAME = "result_navigator.csv"

# Nesting order, outermost first. `a` is the tuning variable shown per leaf.
LEVELS = ["P_ratio", "epsilon_r", "H_pillar", "ratio"]
TUNING = "a"

# Values closer than this are treated as equal, so that 2.2 and 2.2000001
# produced by different export paths do not split a group.
VALUE_TOL = 1e-6

# ---- geometry limit -------------------------------------------------------
#
# The ellipse major axis is rotated 45 degrees, so its axis-aligned bounding
# box half-extent is sqrt((a^2 + b^2)/2) with b = a/ratio. Requiring that to
# stay inside the cell gives the largest usable semi-major axis:
#
#     sqrt((a^2 + (a/ratio)^2)/2) <= P/2
#     a <= (P/2) * sqrt(2) / sqrt(1 + 1/ratio^2)
#
# A larger ratio therefore permits a longer major axis, which is why a sweep
# that shares one upper limit across several ratios never reaches the edge for
# the more elongated ones.
#
# GEOMETRIC_CLEARANCE_MM is the allowed gap between the ellipse bounding box
# and the cell wall. It is NOT the manufacturability clearance used elsewhere:
# 0.2 mm in dataExplorer reflects what an FDM nozzle can print, whereas for
# coverage of the surrogate's input domain the ellipse may legitimately touch
# the wall, since such a cell is still geometrically valid. Keep this at zero
# unless a specific study needs headroom.
C0_MM_GHZ = 299.792458      # mm * GHz
F0_GHZ = 30.0
LAMBDA0_MM = C0_MM_GHZ / F0_GHZ
GEOMETRIC_CLEARANCE_MM = 0.0    # purely geometric; not a print constraint
EDGE_MARGIN_MM = 0.01           # stay just inside the limit, for rounding
TARGET_STEP_MM = 0.02           # largest acceptable spacing of new samples


def max_major_axis(
    p_ratio: float,
    ratio: float,
    clearance_mm: float = GEOMETRIC_CLEARANCE_MM,
) -> float:
    """Largest semi-major axis whose bounding box still fits inside the cell."""
    cell_mm = p_ratio * LAMBDA0_MM
    half = cell_mm / 2.0 - clearance_mm
    if half <= 0 or ratio <= 0:
        return float("nan")
    return half * (2.0 ** 0.5) / (1.0 + 1.0 / ratio ** 2) ** 0.5


def extend_sweep(
    a_max: float,
    p_ratio: float,
    ratio: float,
    step_mm: float = TARGET_STEP_MM,
    margin_mm: float = EDGE_MARGIN_MM,
) -> tuple[float, float, int] | None:
    """
    Work out the extra samples needed to reach the geometric edge.

    Returns (start, end, n) or None when the sweep already reaches the edge.
    The new interval begins one step after the last sampled point and ends as
    close to the limit as a step of at most `step_mm` allows.
    """
    limit = max_major_axis(p_ratio, ratio) - margin_mm
    if not (limit == limit) or a_max >= limit:      # NaN or already long enough
        return None

    start = a_max + step_mm
    if start > limit:
        return None                                  # gap already below one step

    n_new = int((limit - a_max) / step_mm)           # whole steps only
    if n_new < 1:
        return None

    end = a_max + n_new * step_mm
    # the final point should land at the limit rather than short of it, as long
    # as doing so does not exceed the step
    if limit - end <= step_mm:
        end = limit
    return start, end, n_new


# --------------------------------------------------------------------------- #
# Parsing
# --------------------------------------------------------------------------- #

@dataclass
class Leaf:
    """One row of the tree: a fully resolved geometry plus its `a` coverage."""

    levels: tuple[float, ...]   # one value per entry of LEVELS
    n_samples: int
    a_min: float
    a_max: float
    source: str

    @property
    def a_span(self) -> float:
        return self.a_max - self.a_min

    # ---- geometry -----------------------------------------------------
    @property
    def p_ratio(self) -> float:
        return self.levels[LEVELS.index("P_ratio")]

    @property
    def ratio(self) -> float:
        return self.levels[LEVELS.index("ratio")]

    @property
    def a_limit(self) -> float:
        """Largest usable semi-major axis for this cell and elongation."""
        return max_major_axis(self.p_ratio, self.ratio)

    @property
    def extension(self) -> tuple[float, float, int] | None:
        """Extra sweep needed to reach the edge, or None if already there."""
        return extend_sweep(self.a_max, self.p_ratio, self.ratio)

    @property
    def needs_extension(self) -> bool:
        return self.extension is not None

    @property
    def a_coverage(self) -> float:
        """Fraction of the usable interval that was actually sampled."""
        limit = self.a_limit - EDGE_MARGIN_MM
        if not (limit == limit) or limit <= 0:
            return float("nan")
        return self.a_max / limit


def _split_strip(line: str) -> list[str]:
    """TAB-split, then strip quotes and whitespace from each field."""
    return [part.strip().strip('"').strip() for part in line.split("\t")]


def _to_float(text: str) -> float | None:
    try:
        return float(text)
    except ValueError:
        return None


def read_navigator(path: Path) -> list[dict[str, float]]:
    """
    Read one navigator CSV into a list of parameter dicts.

    CST writes TAB-separated fields, each wrapped in double quotes, with a
    leading space inside the quotes on the header. Column names vary between
    export scripts, so lookup is by name rather than position.
    """
    try:
        text = path.read_text(encoding="utf-8-sig", errors="replace")
    except OSError as exc:
        print(f"  cannot read {path}: {exc}")
        return []

    lines = [ln for ln in text.splitlines() if ln.strip()]
    if len(lines) < 2:
        return []

    header = _split_strip(lines[0])
    rows: list[dict[str, float]] = []

    for line in lines[1:]:
        fields = _split_strip(line)
        if len(fields) < len(header):
            fields += [""] * (len(header) - len(fields))

        record: dict[str, float] = {}
        for name, field in zip(header, fields):
            value = _to_float(field)
            if value is not None:
                record[name] = value
        if record:
            rows.append(record)

    return rows


def collect_leaves(root: Path, verbose: bool = False) -> tuple[list[Leaf], list[str]]:
    """
    Walk the tree and collapse each navigator CSV into per-group `a` coverage.

    Every file visited is named when `verbose` is set, together with its header
    and whether it was usable, which is the quickest way to find a dataset with
    unexpected column names.

    Returns the leaves and a list of warnings for files that could not be used.
    """
    groups: dict[tuple[float, ...], dict] = {}
    warnings: list[str] = []

    nav_files = sorted(root.rglob(NAVIGATOR_NAME))
    if not nav_files:
        return [], [f"no {NAVIGATOR_NAME} found under {root}"]

    required = LEVELS + [TUNING]

    for nav in nav_files:
        rel = nav.parent.relative_to(root)
        rows = read_navigator(nav)
        if not rows:
            warnings.append(f"{nav}: no usable rows")
            continue

        if verbose:
            print(f"  {rel}: {len(rows)} rows, header {list(rows[0])}")

        # Column names vary between CST export scripts, so resolve each
        # required column to the header spelling actually present.
        # Matching is case-insensitive and tolerant of surrounding space.
        available = {name.strip().lower(): name for name in rows[0]}
        resolved: dict[str, str] = {}
        for want in required:
            hit = available.get(want.strip().lower())
            if hit is None:
                resolved = {}
                break
            resolved[want] = hit

        if not resolved:
            missing_cols = [w for w in required if w.lower() not in available]
            warnings.append(
                f"{nav}: missing columns {missing_cols}, skipped"
                f"  (header was {list(rows[0])})"
            )
            if verbose:
                print(f"      MISSING {missing_cols}")
            continue

        # Per-row check: a column being present in row 0 does not guarantee it
        # is present in every row, because blank fields are dropped when the
        # record is built.
        skipped_rows = 0
        for row in rows:
            if any(resolved[lvl] not in row for lvl in required):
                skipped_rows += 1
                continue

            key = tuple(
                round(row[resolved[lvl]] / VALUE_TOL) * VALUE_TOL
                for lvl in LEVELS
            )
            entry = groups.setdefault(key, {
                "a_values": [],
                "source": str(nav.parent.relative_to(root)),
            })
            entry["a_values"].append(row[resolved[TUNING]])

        if skipped_rows:
            warnings.append(
                f"{nav}: {skipped_rows} of {len(rows)} rows lacked a required "
                f"value, skipped"
            )

    leaves: list[Leaf] = []
    for key, entry in groups.items():
        a_values = entry["a_values"]
        leaves.append(Leaf(
            levels=key,
            n_samples=len(a_values),
            a_min=min(a_values),
            a_max=max(a_values),
            source=entry["source"],
        ))

    leaves.sort(key=lambda lf: lf.levels)
    return leaves, warnings


# --------------------------------------------------------------------------- #
# Console rendering
# --------------------------------------------------------------------------- #

def _fmt(value: float) -> str:
    """Compact number formatting: integers lose the decimal point."""
    if abs(value - round(value)) < 1e-9:
        return f"{int(round(value))}"
    return f"{value:g}"


def render_tree(leaves: list[Leaf], top: int | None) -> str:
    """
    Indented tree table.

    A parent value is printed only on the first row of its block, so the
    grouping is visible as blank space and the eye can follow one branch.
    """
    headers = LEVELS + ["n", "a_min", "a_max", "a_lim",
                        "new_from", "new_to", "n_new", "dir"]
    widths = [max(len(h), 7) for h in headers]

    out: list[str] = []
    header_line = "  ".join(h.ljust(w) for h, w in zip(headers, widths))
    out.append(header_line)
    out.append("-" * len(header_line))

    shown = leaves if top is None else leaves[:top]
    prev: tuple[float, ...] | None = None

    for leaf in shown:
        cells: list[str] = []
        for idx, value in enumerate(leaf.levels):
            if prev is not None and all(
                abs(leaf.levels[k] - prev[k]) < VALUE_TOL for k in range(idx + 1)
            ):
                cells.append("")          # unchanged prefix: leave blank
            else:
                cells.append(_fmt(value))

        limit = leaf.a_limit
        ext = leaf.extension
        if ext is None:
            ext_from = ext_to = ext_n = "-"
        else:
            start, end, n_new = ext
            ext_from = f"{start:.2f}"
            ext_to = f"{end:.2f}"
            ext_n = str(n_new)

        cells += [
            str(leaf.n_samples),
            _fmt(leaf.a_min),
            _fmt(leaf.a_max),
            f"{limit:.2f}" if limit == limit else "nan",
            ext_from,
            ext_to,
            ext_n,
            leaf.source,
        ]
        out.append("  ".join(c.ljust(w) for c, w in zip(cells, widths)))
        prev = leaf.levels

    if top is not None and len(leaves) > top:
        out.append(f"... {len(leaves) - top} more rows (use --csv for all)")

    return "\n".join(out)


def render_summary(leaves: list[Leaf]) -> str:
    """Totals and per-level coverage."""
    if not leaves:
        return "no data"

    out: list[str] = []
    total = sum(lf.n_samples for lf in leaves)

    out.append(f"leaves (ratio-level groups) : {len(leaves)}")
    out.append(f"total samples              : {total}")
    out.append(f"a range overall            : "
               f"{_fmt(min(lf.a_min for lf in leaves))} .. "
               f"{_fmt(max(lf.a_max for lf in leaves))}")
    out.append("")
    out.append("distinct values per level:")

    for idx, level in enumerate(LEVELS):
        values = sorted({lf.levels[idx] for lf in leaves})
        shown = ", ".join(_fmt(v) for v in values[:12])
        if len(values) > 12:
            shown += f", ... (+{len(values) - 12})"
        out.append(f"  {level:<10} {len(values):>3} : {shown}")

    # a-sampling density, which is what matters for surrogate quality
    counts = [lf.n_samples for lf in leaves]
    out.append("")
    out.append("a samples per leaf:")
    out.append(f"  min {min(counts)}   median {sorted(counts)[len(counts)//2]}"
               f"   max {max(counts)}")

    # ---- geometric edge coverage --------------------------------------
    # A sweep that stops short of the cell boundary leaves the most extreme
    # geometry unsampled, which is exactly the region the surrogate must
    # interpolate at the edge of its domain.
    needs = [lf for lf in leaves if lf.needs_extension]
    extra = sum(lf.extension[2] for lf in needs)

    out.append("")
    out.append("geometric edge coverage:")
    out.append(f"  sweep ends short of the edge : {len(needs)} of {len(leaves)}")
    out.append(f"  additional runs required     : {extra}")
    if needs:
        # the widest gaps first, since those distort the surrogate most
        worst = sorted(
            needs,
            key=lambda lf: (lf.a_limit - lf.a_max) / max(lf.a_limit, 1e-9),
            reverse=True,
        )[:5]
        out.append("  largest relative gaps:")
        for lf in worst:
            gap = lf.a_limit - lf.a_max
            pct = 100.0 * gap / lf.a_limit if lf.a_limit else float("nan")
            level_txt = " ".join(f"{n}={_fmt(v)}" for n, v in zip(LEVELS, lf.levels))
            out.append(f"    {level_txt}  a_max {lf.a_max:.2f} of "
                       f"{lf.a_limit:.2f}  ({pct:.0f}% short)")

    return "\n".join(out)


# --------------------------------------------------------------------------- #
# PNG rendering
# --------------------------------------------------------------------------- #

def render_image(leaves: list[Leaf], summary: str, out_path: Path) -> bool:
    """
    Draw the tree table and the summary on one page, all rows, at a fixed
    physical row height.

    The row height is constant in inches rather than a fraction of the figure,
    so the text stays the same size no matter how many rows there are; the page
    simply grows. Combined with a vector format this stays readable and
    zoomable at any size.

    Returns False when matplotlib is unavailable, rather than failing the run:
    the console output is the primary product.
    """
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
        from matplotlib.patches import Rectangle
    except ImportError:
        return False

    # ---- layout, in inches -------------------------------------------
    row_in = 0.155           # physical height of one table row
    font_pt = 6.5            # row font size, constant per row
    head_pt = 7.0
    left_margin = 0.35
    top_margin = 0.45
    bottom_margin = 0.25
    summary_width = 2.5      # inches reserved for the summary panel
    table_width = 6.2        # inches for the table columns

    n_rows = len(leaves)
    fig_w = left_margin + table_width + 0.25 + summary_width + 0.25
    # one row for the header, one per data row
    fig_h = top_margin + bottom_margin + row_in * (n_rows + 2)

    fig = plt.figure(figsize=(fig_w, fig_h))

    # Axes sized in inches, converted to figure fractions
    ax_table = fig.add_axes([
        left_margin / fig_w,
        bottom_margin / fig_h,
        table_width / fig_w,
        (fig_h - top_margin - bottom_margin) / fig_h,
    ])
    ax_summary = fig.add_axes([
        (left_margin + table_width + 0.25) / fig_w,
        bottom_margin / fig_h,
        summary_width / fig_w,
        (fig_h - top_margin - bottom_margin) / fig_h,
    ])
    for ax in (ax_table, ax_summary):
        ax.set_axis_off()
        ax.set_xlim(0, 1)
        # y is measured in rows, counting down from the top. The header
        # occupies its own row at y = 0 and data starts at y = 1, so the
        # first row cannot collide with the header text.
        ax.set_ylim(n_rows + 2, 0)

    # ---- colours -----------------------------------------------------
    # One colour per branch level. Deeper levels get progressively more
    # saturated colours, so the eye can follow a branch by colour alone
    # without reading the numbers.
    level_colors = ["#1f4e79", "#2e7d32", "#b8860b", "#8b2c8b"]
    bar_color = "#4a90b8"
    group_heading = "#d6e4f0"     # header strip above each P_ratio block

    # Very pale tints for the top-level group backgrounds. Each P_ratio block
    # gets its own hue rather than alternating grey/white, so the background
    # identifies *which* block you are in, not merely that a block changed.
    # Saturation is kept low so the coloured foreground text stays legible.
    group_fills = [
        "#eef3f9",   # pale blue
        "#fdf6e3",   # pale amber
        "#eef7ee",   # pale green
        "#f7eef7",   # pale violet
        "#fdf0f0",   # pale rose
        "#f0f7f7",   # pale teal
    ]

    # ---- header ------------------------------------------------------
    # column x positions as fractions of the table width
    headers = LEVELS + ["n", "a_max", "a_lim", "new to", "n_new"]
    col_x = [0.00, 0.10, 0.20, 0.31, 0.41, 0.475, 0.545, 0.615]
    bar_x0 = 0.66                # left edge of the coverage bar column
    bar_max_w = 0.13
    gap_x = 0.86                 # red marker column

    for x, name in zip(col_x, headers):
        ax_table.text(x, 0, name, fontsize=head_pt, fontweight="bold",
                      family="monospace", va="center")
    ax_table.text(bar_x0, 0, "edge cover", fontsize=head_pt,
                  fontweight="bold", family="monospace", va="center")
    ax_table.text(gap_x, 0, "gap", fontsize=head_pt,
                  fontweight="bold", family="monospace", va="center")

    ax_table.plot([0, 1], [0.5, 0.5], color="0.3", linewidth=0.8)

    n_max = max((lf.n_samples for lf in leaves), default=1)

    # Precompute which rows start a new top-level group, and assign each
    # block an index so it can be given its own background tint.
    block_index: list[int] = []
    block = -1
    for r, leaf in enumerate(leaves):
        if r == 0 or abs(leaf.levels[0] - leaves[r - 1].levels[0]) >= VALUE_TOL:
            block += 1
        block_index.append(block)

    # ---- rows --------------------------------------------------------
    prev: tuple[float, ...] | None = None

    for r, leaf in enumerate(leaves):
        y = r + 1                      # data starts one row below the header
        blk = block_index[r]
        starts_block = r == 0 or blk != block_index[r - 1]

        # background tint for the whole top-level block
        ax_table.add_patch(Rectangle(
            (0, y - 0.5), 1.0, 1.0,
            facecolor=group_fills[blk % len(group_fills)],
            edgecolor="none", zorder=0,
        ))

        if starts_block:
            # a saturated strip across the first row of the block makes the
            # boundary unmistakable even in a long scroll
            ax_table.add_patch(Rectangle(
                (0, y - 0.5), 1.0, 1.0, facecolor=group_heading,
                edgecolor="none", zorder=0.5, alpha=0.55,
            ))
            if r > 0:
                ax_table.plot([0, 1], [y - 0.5, y - 0.5],
                              color="0.35", linewidth=0.9, zorder=1)

        # ---- cells ----
        for idx, value in enumerate(leaf.levels):
            # a value is printed only when it differs from the row above,
            # which is what makes the nesting readable
            unchanged = prev is not None and all(
                abs(leaf.levels[k] - prev[k]) < VALUE_TOL for k in range(idx + 1)
            )
            if unchanged:
                continue
            ax_table.text(
                col_x[idx], y, _fmt(value),
                fontsize=font_pt, family="monospace", va="center", zorder=3,
                color=level_colors[idx % len(level_colors)],
                fontweight="bold" if idx == 0 else "normal",
            )
            # a short tick marking a new branch at this level
            ax_table.plot(
                [col_x[idx] - 0.008, col_x[idx] - 0.003],
                [y, y], color=level_colors[idx % len(level_colors)],
                linewidth=1.2, zorder=3,
            )

        # ---- numeric columns ----
        limit = leaf.a_limit
        coverage = leaf.a_coverage
        ext = leaf.extension
        ext_to = f"{ext[1]:.2f}" if ext else "-"
        ext_n = str(ext[2]) if ext else "-"

        for x, cell in zip(col_x[4:], [
            str(leaf.n_samples),
            f"{leaf.a_max:.2f}",
            f"{limit:.2f}" if limit == limit else "nan",
            ext_to,
            ext_n,
        ]):
            ax_table.text(x, y, cell, fontsize=font_pt,
                          family="monospace", va="center", zorder=3)

        # ---- edge-coverage bar ----
        # filled to the fraction of the usable interval that was sampled;
        # the unfilled remainder is the region the surrogate must extrapolate
        bar_w = bar_max_w * (coverage if coverage == coverage else 0.0)
        bar_w = max(0.0, min(bar_w, bar_max_w))
        ax_table.add_patch(Rectangle(
            (bar_x0, y - 0.28), bar_max_w, 0.56,
            facecolor="0.90", edgecolor="none", zorder=3,
        ))
        if bar_w > 0:
            ax_table.add_patch(Rectangle(
                (bar_x0, y - 0.28), bar_w, 0.56,
                facecolor=bar_color, edgecolor="none", zorder=4,
            ))

        # ---- red cross marking a sweep that stops short of the edge ----
        if leaf.needs_extension:
            ax_table.plot(gap_x, y, marker="X", markersize=5.0,
                          color="#c62828", markeredgewidth=0.0, zorder=5)

        prev = leaf.levels

    # legend line for the marker, placed under the header rule on the right
    n_gap = sum(1 for lf in leaves if lf.needs_extension)
    ax_table.plot(gap_x, 0, marker="X", markersize=5.0, color="#c62828",
                  markeredgewidth=0.0, zorder=5)
    ax_table.text(gap_x + 0.02, 0, f"{n_gap} need more",
                  fontsize=font_pt - 0.5, family="monospace",
                  va="center", color="#c62828")
    ax_table.text(bar_x0, 0.72, "bar = fraction of usable a sampled",
                  fontsize=font_pt - 1.0, family="monospace",
                  va="center", color="0.45")

    # ---- summary panel ----------------------------------------------
    ax_summary.set_ylim(n_rows + 2, 0)
    ax_summary.text(0.0, 0, summary, fontsize=font_pt, family="monospace",
                    va="top", linespacing=1.45)

    fig.savefig(out_path, facecolor="white")
    plt.close(fig)
    return True


def write_csv(leaves: list[Leaf], out_csv: Path) -> None:
    """
    One row per leaf, including the geometry limit and the extra sweep needed.

    `extend_from` / `extend_to` / `extend_n` are empty when the sweep already
    reaches the cell edge.
    """
    header = LEVELS + [
        "n_samples", "a_min", "a_max", "a_span",
        "a_limit", "coverage", "extend_from", "extend_to", "extend_n",
        "source_dir",
    ]
    lines = ["\t".join(header)]

    for leaf in leaves:
        limit = leaf.a_limit
        coverage = leaf.a_coverage
        ext = leaf.extension

        cells = [_fmt(v) for v in leaf.levels] + [
            str(leaf.n_samples),
            _fmt(leaf.a_min),
            _fmt(leaf.a_max),
            f"{leaf.a_span:.3f}",
            f"{limit:.4f}" if limit == limit else "",
            f"{coverage:.4f}" if coverage == coverage else "",
            f"{ext[0]:.3f}" if ext else "",
            f"{ext[1]:.3f}" if ext else "",
            str(ext[2]) if ext else "",
            leaf.source,
        ]
        lines.append("\t".join(cells))

    out_csv.write_text("\n".join(lines) + "\n", encoding="utf-8")


# --------------------------------------------------------------------------- #
# Entry point
# --------------------------------------------------------------------------- #

def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("directory", type=Path, help="root to scan recursively")
    parser.add_argument("--csv", type=Path, default=None,
                        help="write the full table here")
    parser.add_argument("--png", type=Path, default=None,
                        help="write the overview image here")
    parser.add_argument("--no-png", action="store_true",
                        help="skip the image even if --png is not given")
    parser.add_argument("--top", type=int, default=0,
                        help="rows to show on the console (default 0 = all); "
                             "the image always contains every row")
    parser.add_argument("-v", "--verbose", action="store_true",
                        help="name every navigator CSV visited, with its "
                             "header and whether it was usable")
    parser.add_argument("--format", default="svg",
                        choices=["svg", "pdf", "png"],
                        help="image format (default svg, vector and zoomable)")
    args = parser.parse_args(argv)

    root: Path = args.directory
    if not root.is_dir():
        print(f"error: not a directory: {root}")
        return 1

    leaves, warnings = collect_leaves(root, verbose=args.verbose)
    for message in warnings:
        print(f"warning: {message}")
    if not leaves:
        print("error: nothing to report")
        return 1

    top = None if args.top == 0 else args.top

    print()
    print(render_tree(leaves, top))
    print()
    print("=" * 60)
    print(render_summary(leaves))
    print("=" * 60)

    # Outputs default to the directory the script was run from, not the data
    # directory, which is where the source data lives and should stay clean.
    here = Path.cwd()

    if not args.csv:
        args.csv = here / "coverage.csv"
    args.csv.parent.mkdir(parents=True, exist_ok=True)
    write_csv(leaves, args.csv)
    print(f"\nwrote {args.csv.resolve()}  ({len(leaves)} rows)")

    if not args.no_png:
        out_img = args.png or (here / f"data_statistics.{args.format}")
        out_img.parent.mkdir(parents=True, exist_ok=True)
        if render_image(leaves, render_summary(leaves), out_img):
            print(f"wrote {out_img.resolve()}  (all {len(leaves)} rows)")
        else:
            print("note: matplotlib not available, no image written")

    return 0


if __name__ == "__main__":
    sys.exit(main())
