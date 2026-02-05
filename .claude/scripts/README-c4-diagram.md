# C4 Diagram Helper Script

## Overview
The `c4-diagram-helper.sh` script automates PlantUML C4 diagram verification and output management.

## Features
- Auto-downloads plantuml.jar to `~/.claude/bin/` if missing or older than 1 week
- Verifies diagrams by generating PNG files
- Supports two output modes: local PNG or PlantText URL

## Usage

### Default (Local PNG)
Opens the generated PNG file in default viewer:
```bash
~/.claude/scripts/c4-diagram-helper.sh /tmp/diagram.puml
```

### PlantText URL Mode
Encodes and opens diagram in PlantText.com:
```bash
~/.claude/scripts/c4-diagram-helper.sh --planttext /tmp/diagram.puml
```

## Output Location
- `.puml` files: Created in `/tmp/` by default
- `.png` files: Generated in same directory as `.puml` file
- `plantuml.jar`: Stored in `~/.claude/bin/`

## Integration with /c4-diagram Command
The `/c4-diagram` command automatically uses this script for verification.

See: `~/.claude/commands/c4-diagram.md`

## Compatibility
- Works with both BSD stat (macOS native) and GNU stat (coreutils)
- Python 3 required for PlantText encoding
- Java required for plantuml.jar execution
