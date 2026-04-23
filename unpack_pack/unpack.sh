#!/bin/bash
set -euo pipefail

# Script to unpack HiBy R1 firmware (.upt) based on rockbox r1_patcher.sh logic

# Parse arguments
if [[ $# -ge 1 ]]; then
    UPT_FILE="$1"
else
    UPT_FILE="r1.upt"
fi

if [[ $# -ge 2 ]]; then
    OUTPUT_DIR="$2"
else
    OUTPUT_DIR="squashfs-root"
fi

if [[ ! -f "$UPT_FILE" ]]; then
    echo "Error: Cannot find $UPT_FILE in current directory."
    echo "Usage: ./unpack.sh [path_to_r1.upt] [output_directory]"
    exit 1
fi

echo "======================================"
echo "Unpacking $UPT_FILE..."
echo "======================================"

rm -rf __unpack_tmp 2>/dev/null
mkdir -p __unpack_tmp
7z x -o"__unpack_tmp" "$UPT_FILE" >/dev/null

echo "Reconstructing xImage..."
cat __unpack_tmp/ota_v0/xImage.* > xImage
echo "Reconstructing rootfs.squashfs..."
cat __unpack_tmp/ota_v0/rootfs.squashfs.* > rootfs.squashfs

echo "Extracting rootfs.squashfs to $OUTPUT_DIR (Requires sudo)..."
rm -rf "$OUTPUT_DIR" 2>/dev/null
sudo unsquashfs -f -d "$OUTPUT_DIR" rootfs.squashfs

rm -rf __unpack_tmp rootfs.squashfs
echo "✅ Unpack complete!"
echo "Original filesystem extracted to: $OUTPUT_DIR/"
echo "Kernel saved as: xImage"
echo "You can now modify files in $OUTPUT_DIR/"
