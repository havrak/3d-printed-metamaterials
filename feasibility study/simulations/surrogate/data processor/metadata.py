"""
Parsing of the CST result-navigator CSV.

The file is TAB separated with every value wrapped in double quotes, e.g.

    " 3D Run ID" \t "H_pillar" \t "a" \t "epsilon_r"
    "1"          \t "2.2"      \t "0.4" \t "5"

The parser is deliberately manual: it splits on TAB, strips quotes and
whitespace, and converts numerically. No CSV dialect guessing, because CST's
quoting is not standard CSV.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

# Column names that may carry the run identifier, in priority order.
_ID_CANDIDATES = ("3D Run ID", "Run ID", "RunID", "ID")

# Column names the processor needs. Missing ones become NaN, which the
# validation stage then rejects.
_EXPECTED = ("H_pillar", "a", "epsilon_r", "ratio", "P_ratio", "H_base")


@dataclass
class RunRecord:
    """One row of the navigator: the swept parameters of a single CST run."""

    run_id: int
    params: dict[str, float]

    def get(self, key: str, default: float = float("nan")) -> float:
        return self.params.get(key, default)


def _split_strip(line: str) -> list[str]:
    """Split a TAB-separated line into trimmed, quote-stripped fields."""
    return [part.strip().strip('"').strip() for part in line.split("\t")]


def parse_navigator_csv(path: Path) -> dict[int, RunRecord]:
    """
    Parse the result-navigator CSV into a mapping run_id -> RunRecord.

    Raises ValueError when the header lacks a run identifier column.
    """
    text = path.read_text(encoding="utf-8-sig", errors="replace")
    lines = [ln for ln in text.splitlines() if ln.strip()]
    if len(lines) < 2:
        raise ValueError(f"{path}: no data rows")

    header = _split_strip(lines[0])
    id_col = None
    for candidate in _ID_CANDIDATES:
        for idx, name in enumerate(header):
            if name.lower() == candidate.lower():
                id_col = idx
                break
        if id_col is not None:
            break

    if id_col is None:
        raise ValueError(
            f"{path}: no run-id column (looked for {_ID_CANDIDATES}), "
            f"header was {header}"
        )

    records: dict[int, RunRecord] = {}
    for lineno, line in enumerate(lines[1:], start=2):
        fields = _split_strip(line)
        if len(fields) < len(header):
            fields += [""] * (len(header) - len(fields))

        try:
            run_id = int(float(fields[id_col]))
        except ValueError:
            raise ValueError(f"{path}:{lineno}: unparsable run id {fields[id_col]!r}")

        params: dict[str, float] = {}
        for idx, name in enumerate(header):
            if idx == id_col:
                continue
            field = fields[idx]
            if not field:
                continue
            try:
                params[name] = float(field)
            except ValueError:
                # non-numeric annotation columns are ignored on purpose
                continue

        records[run_id] = RunRecord(run_id=run_id, params=params)

    missing = [c for c in _EXPECTED if not any(c in r.params for r in records.values())]
    if missing:
        # Not fatal: the validation stage reports per-sample NaN instead.
        print(f"  note: {path.name}: columns absent from every row: {missing}")

    return records


def find_navigator_csv(directory: Path) -> Path | None:
    """
    Locate the navigator CSV in a sweep directory.

    Tries the exact name first, then any CSV, because CST's naming has varied
    between versions and export scripts.
    """
    exact = directory / "result_navigator.csv"
    if exact.is_file():
        return exact
    candidates = sorted(directory.glob("*.csv"))
    return candidates[0] if candidates else None
