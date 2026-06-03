---
name: gslides-export
description: Export a Google Slides presentation (or a single slide) to a Markdown file. Captures text boxes only — table cell content is not accessible via the MCP. Use when the user wants to download, export, or save slide content as markdown.
allowed-tools: Bash, Read, Write, mcp__datadog-google-workspace__get_presentation, mcp__datadog-google-workspace__get_slide, mcp__datadog-google-workspace__get_file_content, mcp__datadog-google-workspace__get_file_metadata, mcp__datadog-google-workspace__get_slide_thumbnail
---

# Google Slides → Markdown Export

Export a Google Slides presentation (or a single slide) to a Markdown file at `$ARGUMENTS` (output path).

If no output path is given, write to `/tmp/<slug-of-title>.md`.
If `--slide <objectId>` is given, export only that slide.

## Tool capabilities for Slides

| What you need | Tool | Captured? |
|---|---|---|
| Slide structure + text box content | `get_presentation` | ✅ all slides, text boxes only |
| Single slide detail | `get_slide` | ✅ same as get_presentation, per slide |
| File title, owner, modified date | `get_file_metadata` | ✅ if file is in your Drive; ❌ 404 otherwise |
| Plain-text export of all content | `get_file_content` | ✅ if file is in your Drive; ❌ 404 otherwise |
| Slide thumbnail (PNG) | `get_slide_thumbnail` | ✅ URL valid for ~30 min; image only, not text |
| **Table cell content** | — | ❌ never returned; rows/cols count only |
| Hyperlinks in text boxes | — | ❌ text only, link metadata dropped |
| Smart chips | — | ❌ |
| Images on slides | — | ❌ |

## Process

### Step 1 — extract IDs

From the URL `https://docs.google.com/presentation/d/<PRESENTATION_ID>/edit?slide=id.<SLIDE_OBJECT_ID>`:
- `PRESENTATION_ID` is between `/d/` and `/edit`
- `SLIDE_OBJECT_ID` is the value after `slide=id.` (optional — only for single-slide export)

### Step 2 — fetch presentation structure

```
get_presentation(presentation_id)
```

Returns: title, slide count, and for each slide: objectId, index, element list with type and text content for text boxes (tables have rows/columns count only).

Run in parallel if the file is accessible:
```
get_file_metadata(file_id)   # title, owner, modified date — may 404
get_file_content(file_id)    # plain-text export — may 404
```

If `get_file_content` succeeds it provides a more complete text dump (sometimes captures content that `get_presentation` misses). Use it to cross-check; prefer `get_presentation` structure for the markdown output.

### Step 3 — build per-slide sections

For each slide (or just the target slide if `--slide` was given):

```markdown
## Slide <N> — <title text if present>

<objectId: ...>

<text box content as bullet list or paragraphs>

[Table: <R> rows × <C> cols — content not accessible]
```

For text boxes: emit the text content directly. If there are multiple text boxes, use a bullet list. Preserve placeholder type in a comment when it disambiguates meaning (e.g., `TITLE`, `BODY`, `SUBTITLE`).

### Step 4 — write the file

Prepend a header block:

```markdown
# <Presentation Title>

**Source:** <full URL>
**Owner:** <displayName> (<email>) — or "not available" if get_file_metadata returned 404
**Last modified:** <modifiedTime> — or "not available"
**Slides:** <count>

> **Note:** Table cell content is not accessible via the Slides MCP API. Text boxes are captured; tables show row/column count only.
```

### Step 5 — single-slide export

If `--slide <objectId>` was given:
1. Find the matching slide in the `get_presentation` response by `objectId`
2. If deeper detail is needed, call `get_slide(presentation_id, slide_id)` — but it returns the same summary as `get_presentation`
3. If a visual is needed, call `get_slide_thumbnail` and include the PNG URL with a note that it expires

## Known limitations

- **Table cell content:** the single largest gap. Status-update decks that use tables for team updates are effectively blank exports. No workaround within the MCP; manual copy-paste or `get_slide_thumbnail` (image only) are the only alternatives.
- **Hyperlinks:** text is returned without link metadata. A cell reading "GCP-3415" loses its Jira URL.
- **Files not in your Drive:** `get_file_metadata` and `get_file_content` return 404. Use `get_presentation` only.
- **Smart chips:** not returned by any tool.
- **Images:** not accessible as text or alt text. `get_slide_thumbnail` gives the whole slide as a PNG.
- **Speaker notes:** not returned by `get_presentation` or `get_slide`.
