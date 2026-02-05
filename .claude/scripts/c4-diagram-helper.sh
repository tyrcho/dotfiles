#!/bin/bash
# C4 Diagram Helper Script
# Manages plantuml.jar, verifies diagrams, and handles output options

set -e

PLANTUML_DIR="$HOME/.claude/bin"
PLANTUML_JAR="$PLANTUML_DIR/plantuml.jar"
PLANTUML_URL="https://github.com/plantuml/plantuml/releases/latest/download/plantuml.jar"

# Function to check if jar needs update (older than 1 week)
needs_update() {
    if [ ! -f "$PLANTUML_JAR" ]; then
        return 0  # needs download
    fi

    # Get modification time (works with both BSD and GNU stat)
    local mod_time=$(stat -c %Y "$PLANTUML_JAR" 2>/dev/null || /usr/bin/stat -f %m "$PLANTUML_JAR" 2>/dev/null)

    local jar_age_days=$(( ( $(date +%s) - $mod_time ) / 86400 ))
    [ $jar_age_days -gt 7 ]
}

# Function to download plantuml.jar
download_plantuml() {
    echo "Downloading latest plantuml.jar..." >&2
    mkdir -p "$PLANTUML_DIR"
    curl -L -o "$PLANTUML_JAR" "$PLANTUML_URL"
    echo "Downloaded plantuml.jar to $PLANTUML_JAR" >&2
}

# Function to verify diagram
verify_diagram() {
    local puml_file="$1"
    local png_file="${puml_file%.puml}.png"

    echo "Verifying diagram with plantuml.jar..." >&2
    java -jar "$PLANTUML_JAR" -tpng "$puml_file" 2>&1

    if [ ! -f "$png_file" ]; then
        echo "ERROR: Failed to generate PNG file" >&2
        return 1
    fi

    echo "$png_file"
}

# Function to encode for PlantText
encode_planttext() {
    local puml_file="$1"

    python3 - "$puml_file" << 'PYTHON_EOF'
import sys
import zlib

# PlantUML's custom base64 alphabet
plantuml_alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_'

def encode_plantuml(plantuml_text):
    compressed = zlib.compress(plantuml_text.encode('utf-8'))[2:-4]
    encoded = ''
    i = 0
    while i < len(compressed):
        if i + 2 < len(compressed):
            b1, b2, b3 = compressed[i], compressed[i+1], compressed[i+2]
            encoded += plantuml_alphabet[(b1 >> 2) & 0x3F]
            encoded += plantuml_alphabet[((b1 & 0x3) << 4) | ((b2 >> 4) & 0xF)]
            encoded += plantuml_alphabet[((b2 & 0xF) << 2) | ((b3 >> 6) & 0x3)]
            encoded += plantuml_alphabet[b3 & 0x3F]
            i += 3
        elif i + 1 < len(compressed):
            b1, b2 = compressed[i], compressed[i+1]
            encoded += plantuml_alphabet[(b1 >> 2) & 0x3F]
            encoded += plantuml_alphabet[((b1 & 0x3) << 4) | ((b2 >> 4) & 0xF)]
            encoded += plantuml_alphabet[(b2 & 0xF) << 2]
            i += 2
        else:
            b1 = compressed[i]
            encoded += plantuml_alphabet[(b1 >> 2) & 0x3F]
            encoded += plantuml_alphabet[(b1 & 0x3) << 4]
            i += 1
    return encoded

puml_file = sys.argv[1]
with open(puml_file, 'r') as f:
    plantuml_code = f.read()

encoded = encode_plantuml(plantuml_code)
print(f"https://www.planttext.com/?text={encoded}")
PYTHON_EOF
}

# Main script logic
main() {
    local puml_file=""
    local output_mode="local"  # local or planttext

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --planttext)
                output_mode="planttext"
                shift
                ;;
            --local)
                output_mode="local"
                shift
                ;;
            *)
                puml_file="$1"
                shift
                ;;
        esac
    done

    if [ -z "$puml_file" ]; then
        echo "Usage: $0 [--local|--planttext] <diagram.puml>" >&2
        exit 1
    fi

    if [ ! -f "$puml_file" ]; then
        echo "ERROR: File not found: $puml_file" >&2
        exit 1
    fi

    # Download/update plantuml.jar if needed
    if needs_update; then
        download_plantuml
    fi

    # Verify diagram (always generates PNG)
    png_file=$(verify_diagram "$puml_file")

    # Handle output mode
    if [ "$output_mode" = "planttext" ]; then
        url=$(encode_planttext "$puml_file")
        echo "$url"
        open "$url"
    else
        # Local mode - open PNG
        echo "$png_file"
        open "$png_file"
    fi
}

main "$@"
