{
  lib,
  writeDashBin,
  bashNonInteractive,
  toolDeps,
}:

writeDashBin "hiby-create-overlay" ''
  export PATH="${lib.makeBinPath [ toolDeps ]}:$PATH"
  cd "$(pwd)"
  exec ${lib.getExe bashNonInteractive} ${../../overlays/scripts/create-overlay.sh} "$@"
''
