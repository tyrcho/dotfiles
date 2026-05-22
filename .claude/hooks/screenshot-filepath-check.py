#!/usr/bin/env python3
"""
Screenshot File-Path Hook

PreToolUse hook for `mcp__chrome-devtools__take_screenshot`. Forces the
caller to pass a `filePath` argument so the screenshot is saved to disk
instead of inlined as ~25K tokens of base64 in the tool result.

Rationale: observer/memory sessions repeatedly hit "Prompt is too long"
because raw screenshots saturate context. When `filePath` is set, the
tool returns a short "saved to <path>" string instead of the image bytes.
If Claude needs to look at the image, it can Read it back from disk.

Exit codes:
- 0: Allow the tool use to proceed
- 2: Block with stderr feedback (Claude sees the message and retries)
"""

import json
import os
import sys
import time


SCREENSHOT_DIR_ENV = "CLAUDE_SCREENSHOT_DIR"
DEFAULT_SCREENSHOT_DIR = os.path.expanduser("~/.claude/screenshots")


def suggest_path() -> str:
    base = os.environ.get(SCREENSHOT_DIR_ENV, DEFAULT_SCREENSHOT_DIR)
    return os.path.join(base, f"screenshot-{int(time.time())}.png")


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except json.JSONDecodeError:
        return 0  # malformed input → don't break the tool call

    tool_name = payload.get("tool_name", "")
    if tool_name != "mcp__chrome-devtools__take_screenshot":
        return 0

    tool_input = payload.get("tool_input", {}) or {}
    if tool_input.get("filePath"):
        return 0  # caller already saving to disk → allow

    suggested = suggest_path()
    sys.stderr.write(
        "BLOCKED: take_screenshot was called without `filePath`.\n\n"
        "An inline screenshot returns ~25K tokens of base64 image data,\n"
        "which has historically blown the context budget of observer\n"
        "and memory sessions (see ~/.claude/rules/process/Observer Memory.md).\n\n"
        "Re-call with `filePath` to save the image to disk instead:\n\n"
        f"  filePath: \"{suggested}\"\n\n"
        "If you need to see the image afterwards, Read it from that path —\n"
        "the Read tool handles images natively. Override this hook only when\n"
        "an inline screenshot is genuinely required for same-turn analysis,\n"
        "and explain why in your response.\n"
    )
    return 2


if __name__ == "__main__":
    sys.exit(main())
