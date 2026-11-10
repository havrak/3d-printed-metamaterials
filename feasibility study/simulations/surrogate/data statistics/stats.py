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
    headers = LEVELS + ["n", "a_min", "a_max", "span", "dir"]
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
        cells += [
            str(leaf.n_samples),
            _fmt(leaf.a_min),
            _fmt(leaf.a_max),
            _fmt(leaf.a_span),
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
    headers = LEVELS + ["n", "a_min", "a_max", "span"]
    col_x = [0.00, 0.11, 0.22, 0.34, 0.45, 0.53, 0.61, 0.69]
    bar_x0 = 0.78                # left edge of the sample-count bar column
    bar_max_w = 0.20

    for x, name in zip(col_x, headers):
        ax_table.text(x, 0, name, fontsize=head_pt, fontweight="bold",
                      family="monospace", va="center")
    ax_table.text(bar_x0, 0, "samples", fontsize=head_pt, fontweight="bold",
                  family="monospace", va="center")

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
        for x, cell in zip(col_x[4:], [
            str(leaf.n_samples),
            _fmt(leaf.a_min),
            _fmt(leaf.a_max),
            _fmt(leaf.a_span),
        ]):
            ax_table.text(x, y, cell, fontsize=font_pt,
                          family="monospace", va="center", zorder=3)

        # ---- sample-count bar ----
        w = bar_max_w * (leaf.n_samples / n_max) if n_max else 0.0
        ax_table.add_patch(Rectangle(
            (bar_x0, y - 0.30), max(w, 0.001), 0.60,
            facecolor=bar_color, edgecolor="none", zorder=3,
        ))

        prev = leaf.levels

    # ---- summary panel ----------------------------------------------
    ax_summary.set_ylim(n_rows + 2, 0)
    ax_summary.text(0.0, 0, summary, fontsize=font_pt, family="monospace",
                    va="top", linespacing=1.45)

    fig.savefig(out_path, facecolor="white")
    plt.close(fig)
    return True


def write_csv(leaves: list[Leaf], out_csv: Path) -> None:
    """One row per leaf, same columns as the console table."""
    header = LEVELS + ["n_samples", "a_min", "a_max", "a_span", "source_dir"]
    lines = ["\t".join(header)]
    for leaf in leaves:
        cells = [_fmt(v) for v in leaf.levels] + [
            str(leaf.n_samples),
            _fmt(leaf.a_min),
            _fmt(leaf.a_max),
            _fmt(leaf.a_span),
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
