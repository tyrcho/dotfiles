Google Slides MCP tools return text box content but skip table cell content. Tables are the dominant content format in status-update decks, so a text-only approach produces empty exports for most slides.

The workaround: `get_slide_thumbnail` returns a temporary PNG URL per slide. Download it with `curl`, then read it as an image — Claude can transcribe the table content visually. This covers cases the text API can't reach.

What this means in practice:
- Text boxes, titles, subtitles → captured as plain text via `get_presentation`
- Tables → captured visually via thumbnail download + image read
- Hyperlinks in text → lost (text only, no URL metadata)
- Files not in your Drive → `get_file_content` returns 404; use `get_presentation` + thumbnails

## Usage

```
/gslides-export <presentation-url> [output-path]
```

If no output path is given, writes to `/tmp/<slug-of-title>.md`.
To export a single slide, append `--slide <objectId>` (objectId from the URL's `slide=id.` parameter).
