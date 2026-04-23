#!/bin/bash
set -euo pipefail

# Capture current modifications in squashfs-root/ to overlay system

# Work in the directory where the command was called from
PROJECT_DIR="$(pwd)"
OVERLAY_DIR="$PROJECT_DIR/overlays"
SQUASHFS_ROOT="$PROJECT_DIR/squashfs-root"
REFERENCE_ROOT="$OVERLAY_DIR/patch-reference"

if [[ ! -d "$SQUASHFS_ROOT" ]]; then
    echo "Error: squashfs-root/ directory not found in current directory."
    echo "Run 'nix run .#unpack' first to extract the firmware."
    exit 1
fi

echo "======================================"
echo "Creating overlay from current modifications..."
echo "======================================"

# Create clean reference if it doesn't exist
if [[ ! -d "$REFERENCE_ROOT" ]]; then
    echo "No clean reference found. Creating one..."
    echo "This will extract a fresh copy for comparison."
    
    # Use nix run .#unpack to create the reference root
    echo "Using nix run .#unpack to create reference..."
    
    # The unpack command will use the original UPT from the flake
    # and extract to our specified reference directory
    nix run .#unpack -- "$REFERENCE_ROOT"
    
    echo "Making reference root read-only..."
    # Make entire reference root read-only to prevent accidental modification
    chmod -R a-w "$REFERENCE_ROOT"
    echo "  Reference root protected from accidental changes"
    echo "  To remove: chmod -R +w squashfs-root-clean && rm -rf squashfs-root-clean"
fi

echo "Comparing against clean reference..."

# Clear previous overlay files and patches
rm -rf "$OVERLAY_DIR/files"/* "$OVERLAY_DIR/patches"/* 2>/dev/null || true
mkdir -p "$OVERLAY_DIR/files" "$OVERLAY_DIR/patches"

# Track what we're capturing
CAPTURED_FILES=0
CAPTURED_PATCHES=0

# Compare each file against reference
cd "$SQUASHFS_ROOT"
find . -type f | while read -r file; do
    rel_path="${file#./}"
    reference_file="$REFERENCE_ROOT/$rel_path"
    
    if [[ ! -f "$reference_file" ]]; then
        # New file - copy to overlay
        echo "  New file: $rel_path"
        mkdir -p "$OVERLAY_DIR/files/$(dirname "$rel_path")"
        cp "$file" "$OVERLAY_DIR/files/$rel_path"
        CAPTURED_FILES=$((CAPTURED_FILES + 1))
    elif ! diff -q "$file" "$reference_file" >/dev/null 2>&1; then
        # Modified file - create patch
        echo "  Modified: $rel_path"
        
        # Create patch filename (replace / with -)
        patch_name=$(echo "$rel_path" | tr '/' '-').patch
        
        # Generate patch (from reference to modified)
        diff -u "$reference_file" "$file" > "$OVERLAY_DIR/patches/$patch_name" || true
        CAPTURED_PATCHES=$((CAPTURED_PATCHES + 1))
    fi
done

cd "$PROJECT_DIR"

echo "✅ Overlay created!"
echo "  $CAPTURED_FILES new/replacement files captured"  
echo "  $CAPTURED_PATCHES patches created"
echo ""
echo "Files stored in overlays/files/"
echo "Patches stored in overlays/patches/"
echo ""
echo "Commit these changes to git to preserve your modifications."
