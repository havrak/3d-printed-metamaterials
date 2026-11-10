# Data statistics

Reports what sweep configurations exist under a directory tree, so you can see
at a glance whether the dataset covers the space the surrogate needs.

Reads **only** `result_navigator.csv` files — the `.s2p` data is never opened,
so it is fast even over tens of thousands of runs.

## Run

```bash
cd "feasibility study/simulations/surrogate/data statistics"

python stats.py "../../data"                    # console + PNG next to it
python stats.py "../../data" --csv coverage.csv
python stats.py "../../data" --png overview.png --top 100
python stats.py "../../data" --no-png           # console only
```

`--top N` limits rows on the console and image (`0` = all).

Requires only the standard library. The image additionally needs matplotlib; if
it is absent the script still prints the table and skips the PNG.

## What it shows

The hierarchy, outermost first:

```
P_ratio -> epsilon_r -> H_pillar -> ratio -> a
```

One row per `ratio`-level group, with the `a` coverage of that group:

| column | meaning |
|---|---|
| `P_ratio` … `ratio` | the group's values; a value is printed only on the first row of its block, so nesting reads as indentation-by-blankness |
| `n` | how many samples exist for that group |
| `a_min`, `a_max` | the sampled range of the tuning variable |
| `span` | `a_max - a_min` |
| `dir` | the subdirectory the data came from (console only) |

Alternating shading separates `P_ratio` blocks in the image.

The summary panel gives totals, the overall `a` range, the distinct values at
each level, and the `a`-sample distribution (min / median / max per leaf) — the
last is what tells you whether the surrogate will have enough resolution near
resonance.

## Design notes

**Values are compared with a tolerance.** `2.2` and `2.2000001` arrive from
different export paths; grouping them on exact equality would split a group
into two rows and overstate the leaf count.

**Column lookup is by name, not position.** CST's navigator column order varies
between export scripts.

**Nothing is filtered.** Unlike the data processor, this reports the raw state
of the tree, including incomplete groups. If a `ratio` value was swept at only
three `a` points, that is exactly what you want to see here.

## Outputs

- console: the tree table and the summary block
- `--csv`: one row per leaf, TAB separated, all rows regardless of `--top`
- `--png`: one page, table on the left and summary on the right
