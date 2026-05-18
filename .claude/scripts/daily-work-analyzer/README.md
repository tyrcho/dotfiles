# daily-work-analyzer

A launchd-scheduled job that runs Claude Code headlessly each weekday morning to generate fresh `work-analyzer` reports for every 1:1 you have scheduled between now and the end of tomorrow. Reports land directly under each direct-report's folder in the Management/People vault, as Obsidian folder notes ready to read before the meeting.

## What it does

Every weekday at 10:03 AM local time, launchd runs `daily-work-analyzer.sh`, which:

1. Sources `~/.zprofile` and `~/.zshrc` so the Claude binary inherits `$PATH` and API tokens (`JIRA_API_TOKEN`, `CONFLUENCE_API_TOKEN`, etc.).
2. Invokes `~/.local/bin/claude --print` (the real Anthropic CLI, bypassing the cmux wrapper which has no socket in a launchd context) with the contents of `prompt.md`.
3. The prompt tells Claude to:
   - List calendar events between now and end-of-tomorrow via `mcp__datadog-google-calendar__list_events`.
   - Filter to 1:1s (events with exactly 2 attendees).
   - Match each attendee email to a direct-report note under `~/.../Management/People/{AWS,GCP,Azure}/<Name>/<Name>.md` (via grep on the frontmatter `email:` field).
   - Compute a report period from the gap since the previous 1:1 with that person (capped at 8 weeks).
   - Run `/work-analyzer:global-report` in parallel for each matched 1:1.
   - Flatten the produced folder so it lives directly under the person's folder as an Obsidian folder note.

Logs land at `/tmp/work-analyzer-daily.log` (stdout) and `/tmp/work-analyzer-daily.err` (stderr).

## Files

```
~/.claude/scripts/daily-work-analyzer/
├── README.md                 — this file
├── daily-work-analyzer.sh    — entry point invoked by launchd
└── prompt.md                — the Claude prompt; edit to change behavior
~/Library/LaunchAgents/
└── com.michel.daviot.work-analyzer-daily.plist  — launchd schedule (Mon-Fri 10:03 AM)
```

## Setup on a new machine

### Prerequisites

- macOS (uses launchd; on Linux you'd swap for a systemd `.timer` + `.service` unit).
- Claude Code installed at `~/.local/bin/claude` (the real Anthropic CLI, not a cmux/FleetView wrapper). Verify with `~/.local/bin/claude --version`.
- The `work-analyzer` plugin enabled in `~/.claude/settings.json` (under `enabledPlugins`).
- MCP servers connected and authenticated in your interactive Claude session:
  - `mcp__datadog-google-calendar` — for calendar lookup
  - `mcp__slack` — for `--slack` data collection
  - `mcp__datadog-mcp`, `mcp__datadog-google-workspace`, `mcp__atlassian`, `mcp__snowflake` — used by the various work-analyzer skills
- API tokens exported in `~/.zprofile` or `~/.zshrc`: `JIRA_API_TOKEN`, `CONFLUENCE_API_TOKEN`, `DD_API_KEY`, `DD_APP_KEY`, `ATLASSIAN_USER_EMAIL`.
- A `Management/People/{AWS,GCP,Azure}/<Person Name>/<Person Name>.md` vault layout with frontmatter `email:` and `github_id:` per direct report (see `~/.claude/rules/datadog/direct-reports.md`).

### Permission allowlist

For the headless run to invoke tools without TTY-bound permission prompts, the user's `~/.claude/settings.json` `permissions.allow` list must include at minimum:

```jsonc
[
  "Bash(grep:*)", "Bash(mv:*)", "Bash(rmdir:*)", "Bash(rm:*)",
  "Bash(python3:*)", "Bash(gh:*)", "Bash(jira:*)", "Bash(dd-auth:*)",
  "Bash(touch:*)", "Bash(chmod:*)", "Bash(builtin cd:*)",
  "Read", "Write", "Edit", "Glob", "Grep", "Agent",
  "mcp__datadog-google-calendar__*",
  "mcp__datadog-google-workspace__*",
  "mcp__google-workspace__*",
  "mcp__datadog-mcp__*",
  "mcp__slack__*",
  "mcp__atlassian__*",
  "mcp__snowflake__*"
]
```

(See `~/.claude/settings.json` on this machine for the full current set.)

### Install steps

1. **Copy this folder** (`~/.claude/scripts/daily-work-analyzer/`) to the new machine at the same path.

2. **Make the script executable**:
   ```bash
   chmod +x ~/.claude/scripts/daily-work-analyzer/daily-work-analyzer.sh
   ```

3. **Adjust paths in `prompt.md`** if the Management/People vault lives at a different absolute path on the new machine.

4. **Copy the launchd plist**:
   ```bash
   cp <existing>/com.michel.daviot.work-analyzer-daily.plist ~/Library/LaunchAgents/
   ```
   Then edit the plist if your username differs (look for `/Users/michel.daviot/` references) and adjust the firing time / weekdays in the `StartCalendarInterval` block if desired.

5. **Smoke-test once interactively** before scheduling:
   ```bash
   ~/.claude/scripts/daily-work-analyzer/daily-work-analyzer.sh 2>&1 | tee /tmp/smoke.log
   ```
   You should see Claude's streaming output, ending in either a per-meeting summary or `No 1:1s scheduled between now and end of tomorrow`.

6. **Bootstrap into launchd**:
   ```bash
   launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.michel.daviot.work-analyzer-daily.plist
   ```

7. **Verify it's loaded**:
   ```bash
   launchctl print "gui/$(id -u)/com.michel.daviot.work-analyzer-daily"
   ```

## Operating

| Action | Command |
|---|---|
| Tail logs | `tail -f /tmp/work-analyzer-daily.log /tmp/work-analyzer-daily.err` |
| Force-fire now | `launchctl kickstart -k gui/$(id -u)/com.michel.daviot.work-analyzer-daily` |
| Unload | `launchctl bootout gui/$(id -u)/com.michel.daviot.work-analyzer-daily` |
| Reload after editing the plist | `launchctl bootout … ; launchctl bootstrap …` (in sequence) |
| Edit the prompt | edit `prompt.md` — picked up on next run (no reload needed) |

## Why `~/.local/bin/claude` and not the cmux wrapper

The wrapper at `/Applications/cmux.app/Contents/Resources/bin/claude` injects `--session-id` and `--settings` flags when running inside a cmux terminal (`CMUX_SURFACE_ID` set). In a launchd context that variable is unset, so the wrapper passes through to the real binary — but if you smoke-test the script from a cmux terminal, the wrapper goes into cmux-injection mode and silently no-ops against the stale socket. The script explicitly `unset`s the cmux env vars and invokes `~/.local/bin/claude` directly so it behaves identically whether triggered from launchd or from any interactive shell.

## Why no `set -e`

The script sources `~/.zshrc`, which contains oh-my-zsh setup, iTerm2 shell integration, and similar interactive-mode helpers. Many of these exit non-zero when sourced from a non-interactive shell (e.g. `[[ -o interactive ]]` guards that aren't reached). With `set -e`, the first such failure would kill the script before reaching the `claude` call. The sources are wrapped with `2>/dev/null || true` to keep the failures invisible without aborting.
