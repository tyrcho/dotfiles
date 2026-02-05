---
description: Generate a PlantUML C4 diagram from text or file, verify with plantuml.jar, and open result
allowed-tools: Bash, atlassian-mcp, datadog-mcp, Write, Edit, Read
---

# C4 Diagram Generator

1. Get the content from a file, URL, MCP or pasted text.

2. Create the diagram:
   - Analyze the content and create a PlantUML C4 diagram that visualizes the architecture/system described
   - Use the C4-PlantUML library: `!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Container.puml` or `C4_Context.puml`
   - Keep the diagram high-level and hide irrelevant details unless the user asks for more detail
   - Use appropriate C4 elements: Person, System, Container, ContainerDb, System_Boundary, System_Ext
   - Add relevant notes to explain key concepts
   - Write the `.puml` file to `/tmp/` by default (e.g., `/tmp/diagram_name.puml`)

3. **MANDATORY VERIFICATION** - Use the helper script:
   - Run: `~/.claude/scripts/c4-diagram-helper.sh [--local|--planttext] /tmp/diagram_name.puml`
   - The script automatically:
     - Downloads plantuml.jar to `~/.claude/bin/` if not present or older than 1 week
     - Verifies the diagram by generating a PNG
     - Generates PNG file at `/tmp/diagram_name.png`
   - Default mode is `--local` (opens PNG file)
   - Use `--planttext` flag to encode and open PlantText URL instead

4. Output:
   - **Default**: Opens the local PNG file in default viewer
   - **--planttext flag**: Encodes diagram and opens PlantText URL in browser
   - Provide the file path or URL to the user

Important:
- ALWAYS use the helper script for verification - never skip this step
- Files are created in `/tmp/` by default
- Default behavior is to open local PNG file
- Use `--planttext` only when user explicitly requests the web URL
- Focus on clarity and simplicity in the diagram
- Use the C4 model level Context or Container appropriately
