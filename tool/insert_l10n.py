"""Insert missing translation keys into lib/core/l10n/app_localizations.dart.

Idempotent: keys already present in a locale block are skipped, so this can be
re-run after editing tool/l10n_additions.json.

Usage (from the project root):
    python tool/insert_l10n.py
"""

import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
TARGET = ROOT / "lib" / "core" / "l10n" / "app_localizations.dart"
ADDITIONS = ROOT / "tool" / "l10n_additions.json"

INDENT = " " * 6


def dart_literal(value: str) -> str:
    """Render a Python string as a Dart single-quoted literal."""
    escaped = value.replace("\\", "\\\\").replace("'", "\\'").replace("$", "\\$")
    return f"'{escaped}'"


def locale_block_span(source: str, lang: str) -> tuple[int, int]:
    """Return (body_start, body_end) offsets for a locale's map body."""
    opener = re.search(rf"^    '{lang}': \{{$", source, re.M)
    if opener is None:
        raise SystemExit(f"locale block '{lang}' not found in {TARGET.name}")
    body_start = opener.end() + 1
    closer = re.compile(r"^    \},$", re.M).search(source, body_start)
    if closer is None:
        raise SystemExit(f"unterminated locale block '{lang}'")
    return body_start, closer.start()


def existing_keys(body: str) -> set[str]:
    return set(re.findall(r"^\s*'([^']+)'\s*:", body, re.M))


def main() -> int:
    source = TARGET.read_text(encoding="utf-8")
    additions = json.loads(ADDITIONS.read_text(encoding="utf-8"))

    total_added = 0
    for lang, entries in additions.items():
        body_start, body_end = locale_block_span(source, lang)
        body = source[body_start:body_end]
        present = existing_keys(body)

        new_lines = [
            f"{INDENT}{dart_literal(key)}: {dart_literal(value)},"
            for key, value in entries.items()
            if key not in present
        ]
        if not new_lines:
            print(f"{lang}: nothing to add")
            continue

        insertion = "\n".join(new_lines) + "\n"
        source = source[:body_end] + insertion + source[body_end:]
        total_added += len(new_lines)
        print(f"{lang}: added {len(new_lines)} key(s)")

    TARGET.write_text(source, encoding="utf-8")
    print(f"\ntotal keys added: {total_added}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
