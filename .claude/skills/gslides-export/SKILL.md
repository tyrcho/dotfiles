---
name: gslides-export
description: Export a Google Slides presentation (or a single slide) to a Markdown file. Uses get_presentation for text boxes, then downloads slide thumbnails via curl and reads them as images to extract table content. Use when the user wants to download, export, summarise, or save slide content as markdown.
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
| Single slide detail | `get_slide` | ✅ same as `get_presentation`, per slide |
| File title, owner, modified date | `get_file_metadata` | ✅ if file is in your Drive; ❌ 404 otherwise |
| Plain-text export of all content | `get_file_content` | ✅ if file is in your Drive; ❌ 404 otherwise |
| **Table cell content** | thumbnail → visual read | ✅ via `get_slide_thumbnail` + `curl` + `Read` |
| Hyperlinks in text boxes | — | ❌ text only, link metadata dropped |
| Smart chips | — | ❌ |
| Speaker notes | — | ❌ |

## Process

### Step 1 — extract IDs

From the URL `https://docs.google.com/presentation/d/<PRESENTATION_ID>/edit?slide=id.<SLIDE_OBJECT_ID>`:
- `PRESENTATION_ID` is between `/d/` and `/edit`
- `SLIDE_OBJECT_ID` is the value after `slide=id.` (optional — only for single-slide export)

### Step 2 — fetch structure and thumbnails in parallel

Run all of these simultaneously:

```
get_presentation(presentation_id)
get_file_metadata(file_id)          # may 404 if file not in your Drive
get_file_content(file_id)           # may 404 if file not in your Drive
get_slide_thumbnail(presentation_id, slide_id)  # one per slide that has a table
```

From `get_presentation`, identify which slides contain tables (element type `table`) vs. which have only text boxes. Request thumbnails for all table slides — text-only slides don't need thumbnails since `get_presentation` already has their text.

If exporting a single slide (`--slide`), only fetch that slide's thumbnail.

### Step 3 — download thumbnails

`get_slide_thumbnail` returns a temporary `contentUrl` (valid ~30 min). Download all thumbnails in parallel with `curl` before the URLs expire:

```bash
curl -s "<contentUrl_slide_A>" -o /tmp/slide_A.png &
curl -s "<contentUrl_slide_B>" -o /tmp/slide_B.png &
curl -s "<contentUrl_slide_C>" -o /tmp/slide_C.png &
wait
```

**Verify each download:** check file size with `ls -lh`. A valid 1600×900 PNG is typically 100KB–500KB. A file under 10KB means the URL was truncated or expired — call `get_slide_thumbnail` again for that slide and re-download.

### Step 4 — read table slides visually

Use the `Read` tool on each downloaded PNG. Claude reads the image and transcribes the table content as markdown. Thumbnails are 1600×900 and legible for typical slide font sizes.

For each table slide, transcribe:
- The slide title (top-left or top header cell)
- All cell content, preserving the two-column layout common in status-update decks (Updates / Challenges on the left, Highlighted Incidents / People Changes on the right)

### Step 5 — merge text and visual content

Combine `get_presentation` text-box content with the visually-transcribed table content:
- Text boxes: emit verbatim from `get_presentation`
- Tables: use the visual transcription from Step 4
- If `get_file_content` succeeded, cross-check it against the visual for any content missed

### Step 6 — write the file

Prepend a header block:

```markdown
# <Presentation Title>

**Source:** <full URL>
**Owner:** <displayName> (<email>) — or "not available" if get_file_metadata returned 404
**Last modified:** <modifiedTime> — or "not available"
**Slides:** <count>
```

Per slide:

```markdown
## Slide <N+1> — <title>

<content>
```

## Known limitations

- **Hyperlinks:** text is returned without link metadata by both `get_presentation` and the visual read. A cell reading "GCP-3415" loses its Jira URL. Construct Atlassian URLs manually from ticket IDs.
- **Files not in your Drive:** `get_file_metadata` and `get_file_content` return 404. Use `get_presentation` + thumbnails only.
- **Dense or small text:** very small font sizes in a thumbnail may be hard to read accurately. Flag uncertain transcriptions inline with `[?]`.
- **Thumbnail URL expiry:** URLs are valid ~30 min. If you need to re-read a slide later, call `get_slide_thumbnail` again — do not cache the URL.
- **Smart chips:** not returned by any tool; not visible in thumbnails at typical thumbnail resolution.
