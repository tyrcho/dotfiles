---
name: gsheet-export
description: Export a Google Sheets tab to a Markdown table file. Use when the user wants to download, export, or save a Google Sheet tab as markdown.
allowed-tools: Bash, Read, Write, mcp__datadog-google-workspace__get_spreadsheet_metadata, mcp__datadog-google-workspace__read_sheet, mcp__datadog-google-workspace__get_file_content, mcp__datadog-google-workspace__get_file_metadata
---

# Google Sheet Tab → Markdown Export

Export a specific tab of a Google Sheet to a Markdown file at `$ARGUMENTS` (output path).

If no output path is given, write to `/tmp/<slug-of-title>-<tab-name>.md`.

## Tool capabilities for Sheets

| What you need | Tool | Captured? |
|---|---|---|
| Cell text values | `read_sheet` | ✅ structured JSON rows |
| Cell text values | `get_file_content` (CSV) | ✅ flat text, all tabs merged |
| File title, owner, modified date | `get_file_metadata` | ✅ |
| Sheet names and tab structure | `get_spreadsheet_metadata` | ✅ |
| Cell hyperlinks | — | ❌ not exposed by any MCP tool |
| Smart chip values (person, Jira, date) | — | ❌ plain text label only via `get_file_content` |
| Cell formatting (bold, color, merged cells) | — | ❌ |

## Process

### Step 1 — extract IDs

From the URL `https://docs.google.com/spreadsheets/d/<SPREADSHEET_ID>/edit?gid=<GID>`:
- `SPREADSHEET_ID` is between `/d/` and `/edit`
- `GID` is the `gid=` query parameter

### Step 2 — resolve the tab name

Run in parallel:
- `get_spreadsheet_metadata(spreadsheet_id)` → find the sheet with `sheetId == GID`, read its `title`
- `get_file_metadata(file_id)` → spreadsheet title, owner, modified date

### Step 3 — read the sheet content

`read_sheet` requires A1 notation with the tab name. Start with a broad range to discover content extent:

```
read_sheet(spreadsheet_id, range="<TabName>!A1:Z200")
```

If the sheet has more rows, extend the range. The response is a `values` array of arrays (rows × columns). Empty trailing cells in a row are omitted — rows may have different lengths.

### Step 4 — convert to Markdown

Use the first non-empty row as the header. Section headers (rows with a single non-empty cell spanning intent) become `##` headings. Empty rows become section breaks.

```python
def sheet_to_markdown(values):
    # Find max column count
    ncols = max(len(row) for row in values if row)

    lines = []
    header_written = False

    for row in values:
        if not any(row):          # empty row — section break
            lines.append("")
            continue
        if len(row) == 1:         # single-cell row — treat as section heading
            lines.append(f"## {row[0]}\n")
            header_written = False
            continue
        padded = row + [""] * (ncols - len(row))
        if not header_written:
            lines.append("| " + " | ".join(padded) + " |")
            lines.append("| " + " | ".join("---" for _ in padded) + " |")
            header_written = True
        else:
            lines.append("| " + " | ".join(padded) + " |")

    return "\n".join(lines)
```

### Step 5 — write the file

Prepend a header block:

```markdown
# <Spreadsheet Title> — <Tab Name>

**Source:** <full URL with gid>
**Owner:** <displayName> (<email>)
**Last modified:** <modifiedTime YYYY-MM-DD>

> **Note:** Cell hyperlinks and smart chips are not accessible via the Sheets MCP API. Cell values only.
```

## Known limitations

- **Cell hyperlinks:** never exposed. If a cell contains `GCP-3415: Dashboard Migration` as a Jira chip, only the label text is captured, not the URL. Construct Jira URLs manually from ticket IDs: `https://datadoghq.atlassian.net/browse/<PROJ-NNN>`.
- **Merged cells:** appear as empty cells in `read_sheet`. The merged-cell value is only in the top-left cell of the merge.
- **Smart chips (person, date, Jira, GitHub):** label text only via `get_file_content` CSV; completely absent from `read_sheet` when the chip has no display text.
- **Cell formatting:** bold, color, borders — not accessible.
- **Multiple tabs:** `get_file_content` exports all tabs as concatenated CSV with tab name separators. `read_sheet` requires an explicit range per tab. For a multi-tab export, call `read_sheet` once per tab using names from `get_spreadsheet_metadata`.
