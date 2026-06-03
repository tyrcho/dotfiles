---
name: gdoc-export
description: Export a Google Doc to a complete Markdown file. Combines three MCP tools to capture everything: headings/links (get_doc_as_markdown), smart chip values and dropdowns (get_file_content), and structural metadata (read_document). Use when the user wants to download, export, or save a Google Doc as markdown.
allowed-tools: Bash, Read, Write, Edit, mcp__datadog-google-workspace__get_doc_as_markdown, mcp__datadog-google-workspace__get_file_content, mcp__datadog-google-workspace__get_file_metadata, mcp__datadog-google-workspace__list_file_comments, mcp__datadog-google-workspace__read_document
---

# Google Doc → Markdown Export

Export a Google Doc to a complete Markdown file at `$ARGUMENTS` (output path).

If no output path is given, write to `/tmp/<slug-of-doc-title>.md`.

## Why three tools are required

No single Google Workspace MCP tool captures everything:

| What you need | Tool |
|---|---|
| Headings, bold/italic, hyperlinks, table structure | `get_doc_as_markdown` |
| Smart chip values: person names, dates, Jira/GitHub chips, dropdown cell values | `get_file_content` |
| File title, owner email, last-modified date | `get_file_metadata` |
| richLink URLs, exact character positions, `dateElement` timestamps | `read_document` + jq |
| Comments and replies | `list_file_comments` |

`get_doc_as_markdown` is the base. `get_file_content` patches the gaps. `read_document` is only needed for structural detail.

## Process

### Step 1 — extract the document ID

From any Google Doc URL, the document ID is the path segment between `/d/` and the next `/`:

```
https://docs.google.com/document/d/<DOCUMENT_ID>/edit?tab=t.0
```

### Step 2 — fetch all sources in parallel

Run these three calls simultaneously:

1. `mcp__datadog-google-workspace__get_doc_as_markdown(document_id)` → structured markdown
2. `mcp__datadog-google-workspace__get_file_content(file_id)` → plain-text export
3. `mcp__datadog-google-workspace__get_file_metadata(file_id)` → title, owner, timestamps

### Step 3 — merge

Use `get_doc_as_markdown` output as the base. Patch every field that is empty or missing with values from `get_file_content`:

**Fields that `get_doc_as_markdown` misses and `get_file_content` captures:**
- Person smart chips → rendered as display name (e.g. `Anoushka Singh`)
- Date smart chips → rendered as formatted date (e.g. `May 27, 2026`)
- Jira/GitHub/connected-app smart chips → rendered as chip label text (e.g. `GCP-3627: Evaluate current metric scraper...`)
- Table cell dropdown values → rendered as plain text (e.g. `In progress`, `Not started`)
- Inline comment markers → appended at end as `[a]`, `[b]`, … footnotes with full comment text

**Constructing Atlassian URLs from chip text:**
- Jira chip text follows the pattern `PROJ-NNNN: Title` → URL is `https://datadoghq.atlassian.net/browse/PROJ-NNNN`
- Confluence chip text → use `mcp__atlassian__search` to resolve if needed

### Step 4 — `read_document` (only when needed)

`read_document` is a large JSON blob (100k–400k chars). Save to disk and query with `jq`.

Use it only when you need:
- Exact character indices for `format_text` calls
- `richLink` URLs that appear as smart links in the doc
- `dateElement.dateElementProperties.timestamp` for machine-readable dates
- `inlineObjectElement` IDs to identify drawings or embedded objects

```bash
DOC_FILE="/path/to/read_document_output.txt"

# All person chips
jq -c '
  .tabs[0].documentTab.body.content[].paragraph?.elements[]?
  | select(.person != null)
  | {start: .startIndex, name: .person.personProperties.name}
' "$DOC_FILE"

# All date chips
jq -c '
  .tabs[0].documentTab.body.content[].paragraph?.elements[]?
  | select(.dateElement != null)
  | {start: .startIndex, display: .dateElement.dateElementProperties.displayText, ts: .dateElement.dateElementProperties.timestamp}
' "$DOC_FILE"

# All richLinks (smart links, not regular hyperlinks)
jq -c '
  .tabs[0].documentTab.body.content[].paragraph?.elements[]?
  | select(.richLink != null)
  | {start: .startIndex, title: .richLink.richLinkProperties.title, uri: .richLink.richLinkProperties.uri}
' "$DOC_FILE"

# All text content with headings (first 100 elements — header area)
jq -c '
  .tabs[0].documentTab.body.content[0:100][]
  | if .paragraph then
      {style: .paragraph.paragraphStyle.namedStyleType,
       text: ([.paragraph.elements[]? | .textRun?.content // .person?.personProperties?.name // ""] | add // "")}
    elif .table then
      {type: "table", cells: [.table.tableRows[].tableCells[].content[].paragraph?.elements[]?.textRun?.content // ""]}
    else . end
' "$DOC_FILE"
```

### Step 5 — write the file

Write the merged content to the output path. Use the document title (from `get_file_metadata`) as the H1 heading if the doc itself doesn't start with one.

## Output format notes

- Remove CDN image URLs from table header cells (the `get_doc_as_markdown` export renders column-type icons as raw `![image](https://lh7-rt.googleapis...)` noise). Replace with the plain column name from `get_file_content`.
- Section dividers (`________________` in plain text) become `---` in markdown.
- Comment footnotes from `get_file_content` can be appended as a `## Comments` section or dropped — ask the user if the doc has many.

## Known limitations

- Jira/GitHub connected-app smart chips: chip label text is available via `get_file_content`, but the chip's underlying URL is **not** exposed by any Docs API tool. Construct it from the ticket ID in the label text.
- Status/dropdown chip values in tables: available via `get_file_content` plain-text export only.
- Embedded drawings and charts: only available as CDN image URLs; actual drawing content is not accessible.
- Nested list indentation: `get_doc_as_markdown` flattens nested lists to top-level bullets.
- Tables with merged cells or complex formatting: may be partially garbled; verify against source.
