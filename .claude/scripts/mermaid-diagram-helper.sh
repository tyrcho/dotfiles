#!/bin/bash
# Mermaid Diagram Helper Script
# Manages mermaid-cli, verifies diagrams, and handles output options

set -e

MERMAID_DIR="$HOME/.claude/bin"
MERMAID_BIN="$MERMAID_DIR/node_modules/.bin/mmdc"
MERMAID_MARKER="$MERMAID_DIR/.mermaid-installed"

# Function to check if mermaid-cli needs update (older than 1 week)
needs_update() {
    if [ ! -f "$MERMAID_BIN" ] || [ ! -f "$MERMAID_MARKER" ]; then
        return 0  # needs install
    fi

    # Get modification time (works with both BSD and GNU stat)
    local mod_time=$(stat -c %Y "$MERMAID_MARKER" 2>/dev/null || /usr/bin/stat -f %m "$MERMAID_MARKER" 2>/dev/null)

    local marker_age_days=$(( ( $(date +%s) - $mod_time ) / 86400 ))
    [ $marker_age_days -gt 7 ]
}

# Function to install/update mermaid-cli
install_mermaid() {
    echo "Installing/updating mermaid-cli..." >&2
    mkdir -p "$MERMAID_DIR"

    # Install mermaid-cli locally in .claude/bin
    cd "$MERMAID_DIR"
    if [ ! -f "package.json" ]; then
        npm init -y >/dev/null 2>&1
    fi

    npm install @mermaid-js/mermaid-cli >&2
    touch "$MERMAID_MARKER"
    echo "Installed mermaid-cli to $MERMAID_DIR" >&2
}

# Function to verify diagram
verify_diagram() {
    local mmd_file="$1"
    local output_format="${2:-png}"  # png or svg
    local output_file="${mmd_file%.mmd}.$output_format"

    echo "Verifying diagram with mermaid-cli..." >&2
    "$MERMAID_BIN" -i "$mmd_file" -o "$output_file" >&2

    if [ ! -f "$output_file" ]; then
        echo "ERROR: Failed to generate $output_format file" >&2
        return 1
    fi

    echo "$output_file"
}

# Function to encode for Mermaid Live
encode_mermaid_live() {
    local mmd_file="$1"

    python3 - "$mmd_file" << 'PYTHON_EOF'
import sys
import base64

mmd_file = sys.argv[1]
with open(mmd_file, 'r') as f:
    mermaid_code = f.read()

# Base64 encode for Mermaid Live
encoded = base64.b64encode(mermaid_code.encode('utf-8')).decode('utf-8')
print(f"https://mermaid.live/edit#base64:{encoded}")
PYTHON_EOF
}

# Main script logic
main() {
    local mmd_file=""
    local output_mode="local"  # local or mermaid-live
    local output_format="png"  # png or svg

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --mermaid-live)
                output_mode="mermaid-live"
                shift
                ;;
            --local)
                output_mode="local"
                shift
                ;;
            --svg)
                output_format="svg"
                shift
                ;;
            --png)
                output_format="png"
                shift
                ;;
            *)
                mmd_file="$1"
                shift
                ;;
        esac
    done

    if [ -z "$mmd_file" ]; then
        echo "Usage: $0 [--local|--mermaid-live] [--png|--svg] <diagram.mmd>" >&2
        exit 1
    fi

    if [ ! -f "$mmd_file" ]; then
        echo "ERROR: File not found: $mmd_file" >&2
        exit 1
    fi

    # Install/update mermaid-cli if needed
    if needs_update; then
        install_mermaid
    fi

    # Verify diagram (always generates output file)
    output_file=$(verify_diagram "$mmd_file" "$output_format")

    # Handle output mode
    if [ "$output_mode" = "mermaid-live" ]; then
        url=$(encode_mermaid_live "$mmd_file")
        echo "$url"
        open "$url"
    else
        # Local mode - open generated file
        echo "$output_file"
        open "$output_file"
    fi
}

main "$@"
