---
description: Generate a Mermaid diagram from text or file, verify with mermaid-cli, and open result
allowed-tools: Bash, atlassian-mcp, datadog-mcp, Write, Edit, Read
---

# Mermaid Diagram Generator

1. Get the content from a file, URL, MCP or pasted text.

2. Create the diagram:
   - Analyze the content and create a Mermaid diagram that visualizes the system/process/flow described
   - Use appropriate Mermaid diagram types:
     - `flowchart` / `graph`: For flowcharts and process flows
     - `sequenceDiagram`: For sequence/interaction diagrams
     - `classDiagram`: For class relationships
     - `stateDiagram-v2`: For state machines
     - `erDiagram`: For entity-relationship diagrams
     - `gantt`: For timelines and schedules
     - `gitGraph`: For git workflows
     - `mindmap`: For hierarchical concepts
   - Keep the diagram clear and well-organized
   - Use descriptive labels and proper syntax
   - Write the `.mmd` file to `/tmp/` by default (e.g., `/tmp/diagram_name.mmd`)

3. **MANDATORY VERIFICATION** - Use the helper script:
   - Run: `~/.claude/scripts/mermaid-diagram-helper.sh [--local|--mermaid-live] [--png|--svg] /tmp/diagram_name.mmd`
   - The script automatically:
     - Installs mermaid-cli to `~/.claude/bin/node_modules/` if not present or older than 1 week
     - Verifies the diagram by generating a PNG or SVG
     - Generates output file at `/tmp/diagram_name.png` (or `.svg`)
   - Default mode is `--local --png` (opens PNG file)
   - Use `--svg` for vector output
   - Use `--mermaid-live` flag to encode and open Mermaid Live URL instead

4. Output:
   - **Default**: Opens the local PNG file in default viewer
   - **--svg flag**: Opens local SVG file in default viewer
   - **--mermaid-live flag**: Encodes diagram and opens Mermaid Live URL in browser
   - Provide the file path or URL to the user

Important:
- ALWAYS use the helper script for verification - never skip this step
- Files are created in `/tmp/` by default
- Default behavior is to open local PNG file
- Use `--svg` for scalable vector output
- Use `--mermaid-live` only when user explicitly requests the web URL or wants to edit online
- Focus on clarity and choose the right diagram type for the content
- Follow Mermaid syntax guidelines for the chosen diagram type
