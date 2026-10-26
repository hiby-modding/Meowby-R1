{
  lib,
  writeDashBin,
  bashNonInteractive,
  toolDeps,
}:

writeDashBin "hiby-repack" ''
  export PATH="${lib.makeBinPath [ toolDeps ]}:$PATH"

  # TEMP_SCRIPT=${../../unpack_pack/repack.sh}

  # Create a modified version of repack.sh that uses fakeroot instead of sudo
  TEMP_SCRIPT=$(mktemp)
  sed 's/sudo mksquashfs/fakeroot mksquashfs/g; s/sudo unsquashfs/fakeroot unsquashfs/g' \
    ${../../unpack_pack/repack.sh} >"$TEMP_SCRIPT"
  chmod +x "$TEMP_SCRIPT"

  # Execute the modified script
  exec ${lib.getExe bashNonInteractive} "$TEMP_SCRIPT" "./squashfs-root/"
''
