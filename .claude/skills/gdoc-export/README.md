Each Google Workspace MCP tool has a blind spot:

- `get_doc_as_markdown` loses all smart chip values — person names, dates, Jira/GitHub chips, and table dropdown values come back empty.
- `get_file_content` fills those gaps but loses all formatting — headings, bold, and hyperlinks are stripped.
- `read_document` exposes the raw JSON structure but requires disk + jq to query and is too large to use inline.

A single-tool export always produces an incomplete file. This skill runs all three in parallel and merges the results.

## Usage

```
/gdoc-export <google-doc-url> [output-path]
```

If no output path is given, writes to `/tmp/<slug-of-doc-title>.md`.
