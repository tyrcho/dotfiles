# Create Jira Epic - Reference

## Description Template

Write the description in **ADF** (Atlassian Document Format) with 4 sections. Derive content from the user's description — do not leave placeholder text.

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

Pass the full description as ADF JSON in `fields.description` with `contentFormat: adf`.

## Fields

| Field             | Value                                                               |
|-------------------|---------------------------------------------------------------------|
| summary           | Epic title (derive from description if not explicit)                |
| issueTypeName     | Epic                                                                |
| description       | 4-section ADF (`contentFormat: adf`)                               |
| priority.id       | See priority mapping below                                          |
| customfield_10163 | `[{"id": "<option_id>"}]` — Quarter Completion                      |
| timetracking      | `{"originalEstimate": "Xw"}` — only if estimate param provided      |

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

If the target quarter is not in this table, verify against field metadata from `getJiraIssueTypeMetaWithFields`.

## Output

Return:
- Epic key as a link (e.g. [AZINTS-XXXX](https://datadoghq.atlassian.net/browse/AZINTS-XXXX))
- Priority and quarter confirmed
