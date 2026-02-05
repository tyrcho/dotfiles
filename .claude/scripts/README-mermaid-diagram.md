# Mermaid Diagram Helper Script

## Overview
The `mermaid-diagram-helper.sh` script automates Mermaid diagram verification and output management.

## Features
- Auto-installs mermaid-cli (@mermaid-js/mermaid-cli) to `~/.claude/bin/node_modules/` if missing or older than 1 week
- Verifies diagrams by generating PNG or SVG files
- Supports two output modes: local file or Mermaid Live URL

## Usage

### Default (Local PNG)
Opens the generated PNG file in default viewer:
```bash
~/.claude/scripts/mermaid-diagram-helper.sh /tmp/diagram.mmd
```

### SVG Output
Opens the generated SVG file:
```bash
~/.claude/scripts/mermaid-diagram-helper.sh --svg /tmp/diagram.mmd
```

### Mermaid Live URL Mode
Encodes and opens diagram in Mermaid Live editor:
```bash
~/.claude/scripts/mermaid-diagram-helper.sh --mermaid-live /tmp/diagram.mmd
```

### Combined Options
```bash
# Local SVG file
~/.claude/scripts/mermaid-diagram-helper.sh --local --svg /tmp/diagram.mmd

# Mermaid Live (format flag ignored)
~/.claude/scripts/mermaid-diagram-helper.sh --mermaid-live /tmp/diagram.mmd
```

## Output Location
- `.mmd` files: Created in `/tmp/` by default
- `.png` / `.svg` files: Generated in same directory as `.mmd` file
- `mermaid-cli`: Installed in `~/.claude/bin/node_modules/`

## Requirements
- Node.js and npm (for mermaid-cli installation)
- Python 3 (for Mermaid Live encoding)

## Mermaid Live URL Format
The script encodes diagrams as base64 for Mermaid Live:
```
https://mermaid.live/edit#base64:<base64-encoded-diagram>
```

## Integration with /mermaid-diagram Command
The `/mermaid-diagram` command automatically uses this script for verification.

See: `~/.claude/commands/mermaid-diagram.md`

## Compatibility
- Works with both BSD stat (macOS native) and GNU stat (coreutils)
- Requires Node.js for mermaid-cli
- Requires Python 3 for base64 encoding
