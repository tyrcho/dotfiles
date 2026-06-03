Google Sheets has no equivalent of `get_doc_as_markdown` or `read_document`. The only tools that return cell content are `read_sheet` (structured JSON values) and `get_file_content` (CSV export). Neither captures hyperlinks or smart chips in cells — only plain cell values are accessible.

What this means in practice:
- A Jira chip in a cell appears as plain text (e.g. `GCP-3415: Dashboard Migration`) with no URL
- A person chip appears as the display name string
- Cell hyperlinks are silently dropped
- Cell formatting (color, bold) is not accessible

## Usage

```
/gsheet-export <spreadsheet-url> [output-path]
```

If no output path is given, writes to `/tmp/<slug-of-title>-<tab-name>.md`.
