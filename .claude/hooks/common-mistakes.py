#!/usr/bin/env python3
"""
Common Mistakes Hook

This PreToolUse hook catches common antipatterns in tool usage and provides
corrective feedback to the agent.

Exit codes:
- 0: Allow the tool use to proceed
- 2: Block the tool use with feedback (stderr is fed back to Claude)
"""

import json
import shlex
import sys


def check_builtin_misuse(tokens: list[str]) -> str | None:
    """
    Check if the command is using builtin with anything other than 'cd'.

    Wrong: builtin git status, builtin npm test, builtin make lint, etc.
    Right: builtin cd /path/to/directory
    Right: git status, npm test, make lint (without builtin)

    Returns feedback message if the pattern matches, None otherwise.
    """
    # Check for: builtin <command> where <command> is not 'cd'
    if len(tokens) >= 2 and tokens[0] == "builtin":
        command = tokens[1]
        if command != "cd":
            return (
                f"BLOCKED: `builtin {command}` is incorrect. The `builtin` command should ONLY be used with `cd`.\n\n"
                f"Correct usage:\n"
                f"✅ `builtin cd /path/to/directory` - Correct\n"
                f"❌ `builtin {command} ...` - WRONG\n\n"
                f"Use this command instead:\n"
                f"```\n"
                f"{' '.join(tokens[1:])}\n"
                f"```\n\n"
                f"The `builtin` prefix is ONLY for the `cd` command. All other commands should be used directly."
            )

    return None


def check_cd_without_builtin(tokens: list[str]) -> str | None:
    """
    Check if the command is using 'cd' without the 'builtin' prefix.

    Wrong: cd /path/to/directory
    Right: builtin cd /path/to/directory

    Returns feedback message if the pattern matches, None otherwise.
    """
    # Check for: cd <path> (without builtin prefix)
    if len(tokens) >= 1 and tokens[0] == "cd":
        path = tokens[1] if len(tokens) >= 2 else ""
        return (
            f"BLOCKED: `cd` must be used with the `builtin` prefix.\n\n"
            f"Correct usage:\n"
            f"✅ `builtin cd {path}` - Correct\n"
            f"❌ `cd {path}` - WRONG\n\n"
            f"Use this command instead:\n"
            f"```\n"
            f"builtin {' '.join(tokens)}\n"
            f"```\n\n"
            f"ALWAYS use `builtin cd` for changing directories."
        )

    return None


# Registry of mistake checkers
# Each checker takes a list of tokens and returns feedback or None
BASH_COMMAND_CHECKERS = [
    check_builtin_misuse,
    check_cd_without_builtin,
]


def check_bash_command(tokens: list[str]) -> str | None:
    """Run all bash command checkers and return the first match."""
    for checker in BASH_COMMAND_CHECKERS:
        feedback = checker(tokens)
        if feedback:
            return feedback
    return None


def main():
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        # If we can't parse input, allow the tool use to proceed
        sys.exit(0)

    tool_name = input_data.get("tool_name", "")
    tool_input = input_data.get("tool_input", {})

    # Only check Bash tool calls
    if tool_name != "Bash":
        sys.exit(0)

    command = tool_input.get("command", "")

    # Parse the command into tokens using shlex
    try:
        tokens = shlex.split(command)
    except ValueError:
        # If shlex can't parse the command (e.g., unclosed quotes),
        # allow the tool use to proceed and let bash handle the error
        sys.exit(0)

    feedback = check_bash_command(tokens)
    if feedback:
        # Exit code 2 with stderr = block and feed back to Claude
        print(feedback, file=sys.stderr)
        sys.exit(2)

    # Allow the tool use to proceed
    sys.exit(0)


if __name__ == "__main__":
    main()
