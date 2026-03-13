---
allowed-tools: mcp__atlassian__getJiraIssueTypeMetaWithFields, mcp__atlassian__createJiraIssue
---

# Create Jira Epic

Create a Jira Epic with the standard 4-section template.

## Parameters

Parse from $ARGUMENTS in any order:
- **project**: Jira project key (e.g. AZINTS, AWSMETRICS) — required
- **description**: Free-text description of the epic — required
- **prio**: Priority level — default `1`
- **quarter**: Target quarter — default `next`
- **estimate**: Original estimate in weeks — optional, omit if not provided.

If params are ambiguous or missing, ask the user.

## Steps

1. Parse params from $ARGUMENTS
2. Compute target quarter (see Quarter logic below)
3. Call `getJiraIssueTypeMetaWithFields` (cloudId: `datadoghq.atlassian.net`, project, issueTypeId: `10000`) to get the Quarter Completion option ID for the target quarter
4. Build the epic title and description from the user's description (see template below)
5. Call `createJiraIssue` with all fields set

## Description Template

Write the description in **ADF** (Atlassian Document Format) with these 4 sections. Derive content from the user's description — do not leave placeholder text.

```
## Summary
[What the initiative delivers — executive summary or bullet points]

## Rationale
[Why: problems it solves, value it delivers — bullet points]

## Next Steps
[What's required to advance the initiative — bullet points]

## Links
[Any Google Docs, RFCs, related Jira tickets, or URLs from the user's input]
```

### Links format

Always use `inlineCard` ADF nodes for URLs — never plain text or markdown links. This renders as Jira Smart Links with auto-fetched titles.

```json
{
  "type": "bulletList",
  "content": [
    {
      "type": "listItem",
      "content": [
        {
          "type": "paragraph",
          "content": [
            {
              "type": "inlineCard",
              "attrs": { "url": "https://example.com" }
            }
          ]
        }
      ]
    }
  ]
}
```

Pass the full description as ADF JSON in the `fields.description` field, and set `contentFormat: adf`.

## Fields

| Field                | Value                                                                                  |
|----------------------|----------------------------------------------------------------------------------------|
| summary              | Epic title (derive from description if not explicit)                                   |
| issueTypeName        | Epic                                                                                   |
| description          | 4-section ADF (use `contentFormat: adf`)                                               |
| priority.id          | See priority mapping                                                                   |
| customfield_10163    | `[{"id": "<option_id>"}]` — Quarter Completion                                         |
| timetracking         | `{"originalEstimate": "Xw"}` — only if estimate param provided (e.g. `"2w"`)           |

## Priority Mapping

| Input          | Name    | ID    |
|----------------|---------|-------|
| 1, P0, top     | Top     | 10001 |
| 2, P1, highest | Highest | 1     |
| 3, P2, high    | High    | 2     |

## Quarter Logic

- `next` = next calendar quarter from today's date
- Known option IDs for `datadoghq.atlassian.net`:

| Quarter | ID    |
|---------|-------|
| 2026 Q1 | 29412 |
| 2026 Q2 | 29413 |
| 2026 Q3 | 29414 |
| 2026 Q4 | 29415 |

Verify against field metadata if the target quarter is not in this table.

## Output

Return:
- Epic key as a link (e.g. [AZINTS-XXXX](https://datadoghq.atlassian.net/browse/AZINTS-XXXX))
- Priority and quarter confirmed

