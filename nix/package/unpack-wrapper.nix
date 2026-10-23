{
  lib,
  writeDashBin,
  bashNonInteractive,
  toolDeps,
  stockFirmwareImage,
}:

writeDashBin "hiby-unpack" ''
  export PATH="${lib.makeBinPath [ toolDeps ]}:$PATH"

  # TEMP_SCRIPT=${../../unpack_pack/unpack.sh}

  # Create a modified version of unpack.sh that uses fakeroot instead of sudo
  TEMP_SCRIPT=$(mktemp)
  sed 's/sudo unsquashfs/fakeroot unsquashfs/g' \
    ${../../unpack_pack/unpack.sh} >"$TEMP_SCRIPT"
  chmod +x "$TEMP_SCRIPT"

  # Execute the modified script
  exec ${lib.getExe bashNonInteractive} "$TEMP_SCRIPT" "${stockFirmwareImage}" "$@"
''
