# Writing & Communication Style

## General formating

### DO
Prefer short sentences and paragraphs.

Limit the use of emojis.

Use **bold** and *italic* to put emphasis or structure.

Write for colleagues using simple words. Favor clarity and **being concise**. Write as a human, for a human reader.

Avoid duplicating information. Each paragraph or concept should appear only in one place. Reorganise and move text as needed.

### DONT
Do NOT use line breaks (---). Use headings like ## heading 2.

Do NOT use this symbol —. Prefer other ponctuation like parenthesis, columns, dots.

Do NOT write as an agent writing for an agent. Don't be verbose. Don't repeat yourself (DRY).


## Datadog Style Guide

### Words to Avoid - Quick Reference

**Corporate Jargon → Simple Words:**
- align → agree
- leverage → use
- resource (verb) → people
- strategy → plan
- streamline → simplify, reduce steps, speed up
- utilize → use

**Marketing Speak → Direct:**
- single pane of glass → unified view, single place
- slice and dice → filter and group
- drill down → examine, investigate
- seamless → (remove)
- turn-key → ready to use
- unlock → gain, access, discover
- baked in → included

**Vague Intensifiers → Remove:**
- highly, very, easily, simply, just, obviously → (delete these words)

**Idioms → Clear Alternatives:**
- figure out → determine
- bear/keep in mind → consider, note
- let's say → assuming, for example
- under the hood → (remove)
- on the fly → real-time

**Wordy Phrases → Concise:**
- in order to → to
- a number of → few, several, many
- create a new → create a
- e.g./i.e./etc. → for example / that is / such as
- note that → **Note:**

**AI Markers to Avoid:**
- delve → (common in AI text, avoid)

**Inclusive Language:**
- whitelist/blacklist → allowlist/blocklist
- master/slave → (use only when referencing unchangeable technical terms)


## Slack Links

Link to the specific thread or message, not the channel, whenever possible.

- Thread link: `https://dd.slack.com/archives/CXXXXXXX/pNNNNNNNNNNNNNN` (preferred)
- Channel link: `https://dd.slack.com/archives/CXXXXXXX` (only when no specific thread is relevant)

## Datadog Incident References

Always link incidents using the format: `SEV-X [Incident name](https://app.datadoghq.com/incidents/NNNNN)`

Example: SEV-2 [AWS me-south-1 and me-central-1 outages](https://app.datadoghq.com/incidents/50263)

- `IR-NNNNN` references are always Datadog incidents, never Jira tickets
- Apply this to any mention by incident number, name, or IR prefix

## Documentation Workflow

Before writing documentation:
1. Create todo list breaking down all sections
2. Work through each section systematically

## Source Citations

**CRITICAL**: Always include source links when providing information.

**Format:**
```markdown
[Your answer]

**Sources:**
- [description of the code](GitHub permalink with line numbers)
- [Web link with title](url)
- [Confluence/Jira full URL]
```

### GitHub Permalinks

**Always use commit-based permalinks, not branch-based links.**

Branch-based links change as the branch is updated. Commit-based permalinks are permanent and always point to the exact version of the code.

**How to get a commit-based permalink:**
1. Navigate to the file on GitHub
2. Manually replace branch name with commit hash in URL

**Examples:**
- ❌ Branch-based (changes over time): `https://github.com/org/repo/blob/main/path/file.ext`
- ✅ Commit-based (permanent): `https://github.com/org/repo/blob/abc123def456/path/file.ext`

**With line numbers:**
`https://github.com/org/repo/blob/abc123def456/path/file.ext#L14-L20`

**Quick method:**
```bash
# Get current commit hash
git rev-parse HEAD

# Or for a specific file's last commit
git log -1 --format=%H path/to/file
```
