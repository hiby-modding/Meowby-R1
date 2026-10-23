# writers.writeDashBin with extra checks
{
  lib,
  checkbashisms,
  dash,
  shellcheck-minimal,
  writers,
}:
name: text:

let
  check =
    /* sh */ ''
      target="$out"
      runHook preCheck
      ${lib.getExe dash} -n "$target"
      ${lib.getExe checkbashisms} "$target"
      # Dropping shellcheck rules that collide with common Nix patterns
      ${lib.getExe shellcheck-minimal} --norc \
         --shell="dash" --severity="info" \
         --exclude="SC1090,SC1091,SC2016,SC2034,SC2154,SC2164" \
         "$target"
      runHook postCheck
    ''
    + ":";
in
writers.writeDashBin name { inherit check; } text
