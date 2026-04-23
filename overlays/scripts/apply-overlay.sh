#!/bin/bash
set -euo pipefail

# Apply stored overlay modifications to squashfs-root/

# Work in the directory where the command was called from
PROJECT_DIR="$(pwd)"
OVERLAY_DIR="$PROJECT_DIR/overlays"
SQUASHFS_ROOT="$PROJECT_DIR/squashfs-root"

if [[ ! -d "$SQUASHFS_ROOT" ]]; then
    echo "Error: squashfs-root/ directory not found in current directory."
    echo "Run 'nix run .#unpack' first to extract the firmware."
    exit 1
fi

echo "======================================"
echo "Applying overlay modifications..."
echo "======================================"

# Apply file overlays (new/replacement files)
if [[ -d "$OVERLAY_DIR/files" ]] && [[ -n "$(find "$OVERLAY_DIR/files" -type f ! -name ".gitkeep" 2>/dev/null)" ]]; then
    echo "Copying overlay files..."
    # Use rsync to preserve permissions and handle directory creation, excluding .gitkeep files
    rsync -av --exclude='.gitkeep' "$OVERLAY_DIR/files/" "$SQUASHFS_ROOT/"
fi

# Apply patches
if [[ -d "$OVERLAY_DIR/patches" ]] && [[ -n "$(find "$OVERLAY_DIR/patches" -name "*.patch" 2>/dev/null)" ]]; then
    echo "Applying patches..."
    cd "$SQUASHFS_ROOT"
    for patch in "$OVERLAY_DIR/patches"/*.patch; do
        if [[ -f "$patch" ]]; then
            echo "  Applying $(basename "$patch")..."
            # Try to apply patch, but don't fail if already applied
            if ! patch -p1 --dry-run < "$patch" >/dev/null 2>&1; then
                echo "    Patch $(basename "$patch") already applied or conflicts - skipping"
            else
                patch -p1 < "$patch"
            fi
        fi
    done
    cd "$PROJECT_DIR"
fi

echo "✅ Overlay applied successfully!"
echo "Modified squashfs-root/ with your customizations."
