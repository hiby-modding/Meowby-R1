# HiBy R1 Overlay System

Store only your squashfs modifications in git while keeping the full filesystem ignored.

## Quick Start

1. **Extract firmware**:

   ```sh
   nix run .#unpack
   # or
   nix run -f default.nix unpack
   # or
   nix-run -A unpack
   # or
   $(nix-build -A unpack --no-out-link)/bin/hiby-unpack
   ```

2. **Apply existing modifications** (if any):

   ```sh
   nix run .#apply-overlay
   ```

3. **Modify files** in `squashfs-root/` as needed

4. **Capture your changes**:

   ```sh
   nix run .#create-overlay
   ```

5. **Commit overlay to git**:

   ```sh
   git add overlays/
   git commit -m "Add firmware modifications"
   ```

6. **Repack firmware**:

   ```sh
   nix run .#repack
   ```

## How It Works

- **`overlays/files/`**: New or replacement files (git-tracked)
- **`overlays/patches/`**: Patches for modified existing files (git-tracked)
- **`overlays/scripts/`**: Overlay management scripts (git-tracked)
- **`squashfs-root/`**: Full extracted filesystem (gitignored)
- **`squashfs-root-clean/`**: Clean reference for comparison (gitignored, read-only)

## Commands

- `nix run .#unpack` - Extract firmware to squashfs-root/
- `nix run .#apply-overlay` - Apply stored modifications to squashfs-root/
- `nix run .#create-overlay` - Capture current modifications to overlays/
- `nix run .#repack` - Repack squashfs-root/ into firmware file

*NOTE: [nix-run](https://tangled.org/weethet.eurosky.social/nix-run) can be used if you are not using flakes*

## Reference Root Protection

The overlay system automatically creates a clean reference copy (`squashfs-root-clean/`) for comparison. This reference is made **read-only** to prevent accidental modification.

To manually remove the reference root:

```sh
chmod -R +w squashfs-root-clean && rm -rf squashfs-root-clean
```
