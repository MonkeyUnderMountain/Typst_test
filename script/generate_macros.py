#!/usr/bin/env python3
"""Generate macro bindings in my_macros.typ from a JSON table.

Usage:
    python script/generate_category_macros.py
    python script/generate_category_macros.py --table script/macro_table.json --macros my_macros.typ

Expected JSON format:
{
    "custom_macros": {
        "surjmap": {"xelatex": "\\twoheadrightarrow", "pdflatex": "\\twoheadrightarrow", "typst": "arrow.r.twohead"}
    },
    "categories": {"Set": "Set", "Var": "Var"},
    "up_operators": {"Spec": "Spec", "mSpec": "mSpec"},
    "frak_operators": {"Hilb": "Hilb"},
    "cal_operators": {"calHom": "calHom"},
    "text_macros": {"an": "an"}
}

Rendering rules:
- custom_macros: #let <name> = <typst>
- categories: #let <name> = math.bold("<label>")
- up_operators: #let <name> = math.op("<label>")
- frak_operators: #let <name> = math.frak("<label>")
- cal_operators: #let <name> = math.cal("<label>")
- text_macros: no Typst definitions are generated
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import NoReturn

# Project root is assumed to be one level above this script directory.
ROOT = Path(__file__).resolve().parents[1]
# Default input JSON table and output Typst macros file.
DEFAULT_TABLE = ROOT / "script" / "macro_table.json"
DEFAULT_MACROS = ROOT / "my_macros.typ"

# Markers used to locate the generated region in the Typst file.
BEGIN_MARKER = "// BEGIN AUTO-GENERATED CATEGORY MACROS"
END_MARKER = "// END AUTO-GENERATED CATEGORY MACROS"
# Valid Typst identifier pattern for generated macro names.
NAME_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")
GROUP_RENDERERS: dict[str, str] = {
    "custom_macros": "raw_typst",
    "categories": "math.bold",
    "up_operators": "math.op",
    "frak_operators": "math.frak",
    "cal_operators": "math.cal",
    "text_macros": "skip",
}


def _fail(message: str) -> NoReturn:
    # Exit immediately with a user-facing error message.
    raise SystemExit(message)


def _normalize_table(raw: object) -> dict[str, list[tuple[str, str]]]:
    """Normalize table into command_group -> [(name, label), ...].

    Only this JSON shape is accepted:
    - dict[str, dict[str, str]]
    """
    if not isinstance(raw, dict):
        _fail("Table must be an object mapping command groups to name/label maps")

    if not raw:
        _fail("No command groups found in table")

    normalized: dict[str, list[tuple[str, str]]] = {}
    for group_name, group_items in raw.items():
        if not isinstance(group_name, str):
            _fail(f"Invalid command group name: {group_name!r}")
        if not NAME_RE.match(group_name):
            _fail(
                f"Invalid command group '{group_name}'. "
                "Use letters/digits/underscore and do not start with a digit."
            )
        if group_name not in GROUP_RENDERERS:
            _fail(
                f"Unsupported command group '{group_name}'. "
                f"Supported groups: {', '.join(GROUP_RENDERERS.keys())}"
            )
        if not isinstance(group_items, dict):
            _fail(f"Command group '{group_name}' must be an object")

        pairs: list[tuple[str, str]] = []
        for name, payload in group_items.items():
            if not isinstance(name, str):
                _fail(f"Invalid macro name in group '{group_name}': {name!r}")

            if group_name == "custom_macros":
                if not isinstance(payload, dict):
                    _fail(
                        f"Invalid entry in group '{group_name}' for '{name}'. "
                        "Expected object with a string 'typst' field."
                    )
                typst_item = payload.get("typst")
                if not isinstance(typst_item, str) or not typst_item:
                    _fail(
                        f"Invalid entry in group '{group_name}' for '{name}'. "
                        "Expected non-empty string field 'typst'."
                    )
                pairs.append((name, typst_item))
                continue

            if not isinstance(payload, str):
                _fail(
                    f"Invalid entry in group '{group_name}': {name!r}: {payload!r}. "
                    "Expected string -> string."
                )
            pairs.append((name, payload))

        if not pairs:
            _fail(f"Command group '{group_name}' is empty")
        normalized[group_name] = pairs

    return normalized


def load_commands(table_path: Path) -> dict[str, list[tuple[str, str]]]:
    """Load, normalize, and validate command groups from a JSON file."""
    # Fail fast with a clear message if the input table does not exist.
    if not table_path.exists():
        _fail(f"Table file not found: {table_path}")

    # Parse JSON in the strict command-group table format.
    data = json.loads(table_path.read_text(encoding="utf-8"))
    groups = _normalize_table(data)

    # Ensure every generated macro name is valid and unique among emitted macros.
    seen_names: set[str] = set()
    for group_name, pairs in groups.items():
        if GROUP_RENDERERS[group_name] == "skip":
            continue
        for name, label in pairs:
            if not NAME_RE.match(name):
                _fail(
                    f"Invalid Typst identifier '{name}' in group '{group_name}'. "
                    "Use letters/digits/underscore and do not start with a digit."
                )
            if name in seen_names:
                _fail(f"Duplicate macro name across groups: {name}")
            seen_names.add(name)

    return groups


def build_generated_block(groups: dict[str, list[tuple[str, str]]]) -> str:
    """Build the full auto-generated Typst block as a single string."""
    lines: list[str] = [
        BEGIN_MARKER,
        "// This block is generated by script/generate_category_macros.py.",
        "// Do not edit manually; edit script/macro_table.json and regenerate.",
        "",
    ]

    # Emit grouped macro bindings with section comments per command group.
    for group_name, pairs in groups.items():
        renderer = GROUP_RENDERERS[group_name]
        if renderer == "skip":
            continue

        lines.append(f"// {group_name}")
        for name, value in pairs:
            if renderer == "raw_typst":
                lines.append(f"#let {name} = {value}")
                continue
            escaped = value.replace('\\', '\\\\').replace('"', '\\"')
            lines.append(f"#let {name} = {renderer}(\"{escaped}\")")
        lines.append("")

    lines.extend([
        END_MARKER,
    ])

    return "\n".join(lines)


def replace_generated_block(macros_text: str, new_block: str) -> str:
    """Replace content between generation markers with a newly built block."""
    # Locate insertion boundaries in the target Typst file.
    begin_idx = macros_text.find(BEGIN_MARKER)
    end_idx = macros_text.find(END_MARKER)

    # Reject malformed marker state to avoid corrupting unrelated content.
    if begin_idx == -1 or end_idx == -1 or end_idx < begin_idx:
        _fail(
            "Auto-generated markers not found in macros file. "
            "Add BEGIN/END markers first."
        )

    # Keep everything outside the marker range untouched.
    end_tail = end_idx + len(END_MARKER)
    return macros_text[:begin_idx] + new_block + macros_text[end_tail:]


def main() -> None:
    """Parse CLI arguments and regenerate the category macro region."""
    # Define command-line options with sensible project defaults.
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--table", type=Path, default=DEFAULT_TABLE)
    parser.add_argument("--macros", type=Path, default=DEFAULT_MACROS)
    args = parser.parse_args()

    # Resolve relative paths against project root for consistent behavior.
    table_path = (ROOT / args.table).resolve() if not args.table.is_absolute() else args.table
    macros_path = (ROOT / args.macros).resolve() if not args.macros.is_absolute() else args.macros

    # Load input data, build replacement content, and apply it to the file.
    groups = load_commands(table_path)
    new_block = build_generated_block(groups)

    macros_text = macros_path.read_text(encoding="utf-8")
    updated = replace_generated_block(macros_text, new_block)
    macros_path.write_text(updated, encoding="utf-8")

    # Print concise status so this script is easy to use in CI or hooks.
    print(f"Updated {macros_path}")
    group_count = len(groups)
    command_count = sum(len(v) for v in groups.values())
    print(f"Loaded {group_count} command groups ({command_count} entries) from {table_path}")


if __name__ == "__main__":
    # Standard entry point guard for direct script execution.
    main()
