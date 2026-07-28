#!/usr/bin/env python3
"""Regenerate config/exercises.json from the app's exercises.csv.

The curator's `workout` field is repurposed as the muscle group (ranking
context + `--workout "<group>"` batching); equipment lands in `searchHints`.
Names are kept byte-for-byte — they are the app's identity keys.

Usage: python3 tool/video_curator/gen_config.py  (from the repo root, or
anywhere — paths are resolved relative to this script)
"""

import csv
import json
from pathlib import Path

TOOL_DIR = Path(__file__).resolve().parent
CSV_PATH = TOOL_DIR.parent.parent / "exercises.csv"
OUT_PATH = TOOL_DIR / "config" / "exercises.json"


def main() -> None:
    entries = []
    seen = set()
    with CSV_PATH.open(newline="", encoding="utf-8") as f:
        reader = csv.reader(f)
        next(reader)  # header
        for row in reader:
            if len(row) < 3 or not row[0].strip():
                continue
            name = row[0].strip()
            if name in seen:
                continue
            seen.add(name)
            entries.append(
                {
                    "workout": row[1].strip(),
                    "exercise": name,
                    "searchHints": row[2].strip(),
                }
            )

    OUT_PATH.write_text(json.dumps(entries, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Wrote {len(entries)} exercises to {OUT_PATH}")


if __name__ == "__main__":
    main()
