# Overlay management wrappers
{
  lib,
  writeDashBin,
  bashNonInteractive,
  toolDeps,
}:

writeDashBin "hiby-apply-overlay" ''
  export PATH="${lib.makeBinPath [ toolDeps ]}:$PATH"
  cd "$(pwd)"
  exec ${lib.getExe bashNonInteractive} ${../../overlays/scripts/apply-overlay.sh} "$@"
''
