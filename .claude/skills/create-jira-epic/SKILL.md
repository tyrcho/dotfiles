---
name: create-jira-epic
description: Create a Jira epic with duplicate check and standard 4-section template
allowed-tools: mcp__atlassian__searchJiraIssuesUsingJql, mcp__atlassian__getJiraIssueTypeMetaWithFields, mcp__atlassian__createJiraIssue
---

# Create Jira Epic

## Arguments

Parse from `$ARGUMENTS` in any order:

| Param | Description | Default |
|-------|-------------|---------|
| **project** | Jira project key (e.g. AZINTS, AWSMETRICS) | required |
| **description** | Free-text description of the epic | required |
| **prio** | Priority level | `1` |
| **quarter** | Target quarter | `next` |
| **estimate** | Original estimate in weeks | omit if not provided |

If params are ambiguous or missing, ask the user.

## Steps

1. **Parse arguments** from `$ARGUMENTS`
2. **Check for duplicates** — search existing epics in the project with a similar title using `searchJiraIssuesUsingJql`:
   ```
   project = <PROJECT> AND issuetype = Epic AND summary ~ "<title keywords>" ORDER BY created DESC
   ```
   If a close match exists, show it and ask the user to confirm before proceeding.
3. **Compute target quarter** (see Quarter Logic in reference.md)
4. **Get quarter option ID** — call `getJiraIssueTypeMetaWithFields` (cloudId: `datadoghq.atlassian.net`, project, issueTypeId: `10000`)
5. **Build epic title and description** using the 4-section ADF template (see reference.md)
6. **Create the epic** via `createJiraIssue` with all fields set (see reference.md for field mapping)
7. **Confirm** — return the epic key as a link with priority and quarter confirmed

For detailed template, field mapping, ADF format, priority and quarter tables: @~/.claude/skills/create-jira-epic/reference.md
