#!/usr/bin/env python3
"""
Snapshot File-Path Hook

PreToolUse hook for `mcp__chrome-devtools__take_snapshot`. Forces the
caller to pass `filePath` when `verbose: true` is set, so the full a11y
tree is saved to disk instead of inlined.

Rationale: a compact snapshot (default, `verbose: false`) is usually
small enough to inline — Claude reads element uids from it to drive
clicks/fills. A verbose snapshot of a complex page can be 20K+ tokens
of DOM/ARIA noise, which saturates observer context the same way
screenshots do (see ~/.claude/rules/process/Observer Memory.md).

Default (compact) snapshots are allowed inline. Only verbose snapshots
without `filePath` are blocked.

Exit codes:
- 0: Allow the tool use to proceed
- 2: Block with stderr feedback (Claude sees the message and retries)
"""

import json
import os
import sys
import time


SNAPSHOT_DIR_ENV = "CLAUDE_SCREENSHOT_DIR"
DEFAULT_SNAPSHOT_DIR = os.path.expanduser("~/.claude/screenshots")


def suggest_path() -> str:
    base = os.environ.get(SNAPSHOT_DIR_ENV, DEFAULT_SNAPSHOT_DIR)
    return os.path.join(base, f"snapshot-{int(time.time())}.txt")


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except json.JSONDecodeError:
        return 0

    tool_name = payload.get("tool_name", "")
    if tool_name != "mcp__chrome-devtools__take_snapshot":
        return 0

    tool_input = payload.get("tool_input", {}) or {}
    if not tool_input.get("verbose"):
        return 0  # compact snapshot → small enough to inline
    if tool_input.get("filePath"):
        return 0  # verbose but saving to disk → allow

    suggested = suggest_path()
    sys.stderr.write(
        "BLOCKED: take_snapshot was called with `verbose: true` and no `filePath`.\n\n"
        "A verbose a11y tree on a complex page can be 20K+ tokens of DOM noise,\n"
        "which has historically blown context in observer and memory sessions\n"
        "(see ~/.claude/rules/process/Observer Memory.md).\n\n"
        "Options:\n"
        "  (a) Re-call with `verbose: false` (the default) if you only need\n"
        "      element uids and structure. The compact tree is small enough\n"
        "      to inline and almost always sufficient.\n"
        f"  (b) Re-call with `filePath: \"{suggested}\"` to keep the full tree\n"
        "      on disk and Read only the part you need.\n\n"
        "Override this hook only when full-page verbose analysis is genuinely\n"
        "required in-context, and explain why in your response.\n"
    )
    return 2


if __name__ == "__main__":
    sys.exit(main())
