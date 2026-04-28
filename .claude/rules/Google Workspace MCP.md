# Google Workspace MCP — Docs

## Authoring content

**Always use `insert_markdown` as the first tool.** It handles headings (H1–H3), bold, italic, strikethrough, hyperlinks, inline code, bullet/numbered lists, and multi-line code blocks in a single call.

Only reach for `format_text` or `update_paragraph_style` when you need something Markdown cannot express:
- Text or background color
- Font family or size
- Alignment, line spacing, indentation
- Hyperlinking text that already exists in the document

Styles are additive: passing `text_color` leaves bold/italic/font intact. Always call `read_document` first to get the 1-based character indices you need.

## Inserting vs. appending

| Goal | Tool | Why |
|---|---|---|
| Add formatted content | `insert_markdown` (no `index`) | Appends with full Markdown support |
| Add plain text | `append_text` | Faster, but `**asterisks**` stay literal |
| Insert in the middle | `insert_markdown` with `index` | Re-read doc first — inserting shifts all indices after the insertion point |

**Never use `append_text` when you want formatting applied.**

## Known gaps — plan around these

**Nested lists** are flattened. The parser does not increase the nesting level. Nested items become top-level bullets with the literal text `  - child`.

Fix: keep lists flat, or follow up with `update_paragraph_style(indent_start=72, indent_first_line=54)` on the paragraphs that should be indented.

**Tables** render as plain pipe-delimited paragraphs, not real Docs tables. Docs MCP cannot build a real table.

Fix: for anything beyond a tiny reference grid, warn the user and ask them to paste a table manually, or embed a Google Sheet.

**Horizontal rules** (`---`) render as 40 Unicode `─` characters. Visual only, not a real HR.

## Reading documents

Use `get_doc_as_markdown` to read content. It is lossy: colors, font families, font sizes, alignment, line spacing, HR elements, and nested-list structure are all stripped. Use it for reading text, not for round-tripping formatting.

## Docs vs. Slides — do not mix these up

The tool names are deceptively similar. The following tools only work on **Slides** (`presentation_id` required):

- `insert_text`
- `update_text_style`
- `batch_update`
- `replace_all_text`

Their **Docs** equivalents are:

- `insert_markdown` / `append_text`
- `format_text`
- `update_paragraph_style`
- `replace_text`

Passing a `document_id` to a Slides tool, or vice versa, will fail.
