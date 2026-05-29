#!/usr/bin/env python3
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent.parent / "lib" / "features"

for path in ROOT.rglob("*.dart"):
    text = path.read_text(encoding="utf-8")
    updated = re.sub(
        r"\s*backgroundColor:\s*const Color\(0xFFF7F6F3\),\n",
        "\n",
        text,
    )
    updated = re.sub(
        r"\s*backgroundColor:\s*const Color\(0xFFF7F6F3\)\s*,?",
        "",
        updated,
    )
    if updated != text:
        path.write_text(updated, encoding="utf-8")
        print(path.relative_to(ROOT.parent.parent))
