# Writing & Communication Style

## General formating

Do NOT use line breaks (---) in addition to headings.

Prefer short sentences and paragraphs.

Limit the use of emojis, **bold** and *italic* to put emphasis or structure.

Write for colleagues using simple words you'd use with a respected family member. Favor clarity and **being concise** over complexity. Write as a human, for a human reader (not as an agent writing for an agent).


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
- [GitHub permalink with line numbers]
- [Web link with title](url)
- [Confluence/Jira full URL]
```

### GitHub Permalinks

**Always use commit-based permalinks, not branch-based links.**

Branch-based links change as the branch is updated. Commit-based permalinks are permanent and always point to the exact version of the code.

**How to get a commit-based permalink:**
1. Navigate to the file on GitHub
2. Press `y` key to convert the URL to use the commit hash
3. Or manually replace branch name with commit hash in URL

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
