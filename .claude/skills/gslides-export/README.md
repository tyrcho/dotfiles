Google Slides MCP tools return text box content but silently skip table cell content. A slide that is purely a table (common in status decks) produces an empty export.

What this means in practice:
- Text boxes, titles, subtitles → captured as plain text (no hyperlinks)
- Tables → only row/column count returned; cell content is inaccessible
- Images → inaccessible; `get_slide_thumbnail` gives a PNG of the full slide only
- Files not in your Drive → `get_file_content` returns 404; only `get_presentation` works

## Usage

```
/gslides-export <presentation-url> [output-path]
```

If no output path is given, writes to `/tmp/<slug-of-title>.md`.
To export a single slide, append `--slide <objectId>` (objectId from the URL's `slide=id.` parameter).
