# Approval / Snapshot Testing

**Default to approval (a.k.a. snapshot, golden-file) tests whenever a test verifies a chunk of text** — JSON payloads, Markdown output, rendered code, CLI stdout/stderr, HTML, YAML, generated config, ADF, diff hunks, etc.

Inline `assert == "long string literal"` for these cases is hard to read, hard to update, and silently rots. Approval tests store the expected text in a sibling file, diff against it, and let you re-approve in one command when the output legitimately changes.

## When to use

Use an approval test when **any** of these is true:
- Expected output is more than ~3 lines of text.
- Output is structured text a human can review (JSON, MD, YAML, source code, ADF, HTML).
- The shape of the output matters as much as individual values (ordering, indentation, escaping).
- A future reader of the diff should see the rendered output change, not a regex tweak.

Stick with plain `assert ==` only for short scalar values (numbers, single fields, booleans, one-line strings).

## How to apply

- **Python**: prefer [`syrupy`](https://github.com/syrupy-project/syrupy) with a file-extension serializer (e.g. `SingleFileSnapshotExtension` configured per content type), or [`approvaltests`](https://github.com/approvals/ApprovalTests.Python) which already writes `*.approved.<ext>`. Avoid the default `.ambr` blob — it loses editor support.
- **JS/TS**: prefer `toMatchFileSnapshot('path/to/file.<ext>')` (vitest) or `jest-file-snapshot` over the default `.snap` blob, so each snapshot lives in its own file with the right extension.
- **Go**: prefer [`goldie`](https://github.com/sebdah/goldie) — pass `goldie.WithNameSuffix(".json")` (or `.md`, `.html`, etc.) so files are `testdata/<case>.json` not `.golden`.
- **Shell / CLI smoke tests**: write the expected output to `testdata/<case>.approved.<ext>` and `diff` against it; provide a `make approve` target or `UPDATE_SNAPSHOTS=1` env var.

### File extensions must match the content

The approval file's extension **must** match what the file actually contains:
- JSON output → `.json` (not `.snap`, `.ambr`, `.txt`, `.golden`)
- Markdown → `.md`
- HTML → `.html`
- Source code → the real source extension (`.py`, `.ts`, `.go`, `.sql`, …)
- YAML / TOML / XML / ADF → their canonical extension
- Plain text with no syntax → `.txt`

Reason: a reviewer should be able to open the approval file directly in their editor, GitHub's diff viewer, or a browser and get correct syntax highlighting, JSON folding, Markdown preview, etc. A `.snap` or `.ambr` blob hides all of that behind a tool-specific wrapper and discourages careful review.

Always normalize the output before snapshotting: strip timestamps, absolute paths, random IDs, ANSI colors. The test is worthless if it has to be re-approved on every run.

## Reviewing changes

Treat approval-file diffs as **first-class review artifacts**:
- Read the approval-file diff in PR review, not just the code.
- Never bulk-re-approve without inspecting each hunk.
- If the only way to make a test pass is to re-approve a file you do not understand, stop and read the rendering code.

## Don't

- Don't put long expected strings as inline literals (`expected = """..."""`) when an approval file would do.
- Don't accept a tool's default opaque extension (`.snap`, `.ambr`, `.golden`) when the content has a real one. Configure the tool to write `<name>.<real-ext>`.
- Don't hide the snapshot inside a custom assertion that obscures the diff.
- Don't normalize so aggressively that the test passes for outputs a human would reject.
