# Stable Nix entry point
{
  pkgs ? null,
  system ? null,
  nixpkgs ?
    let
      lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
    in
    builtins.fetchTarball {
      inherit (lock) url;
      sha256 = lock.narHash;
    },
}:

let
  overlay = import ./nix/overlay;

  pkgs' =
    if builtins.isNull pkgs then
      import nixpkgs {
        system = if builtins.isString system then system else builtins.currentSystem;
        overlays = [ overlay ];
      }
    else
      pkgs.extend overlay;
in
pkgs'.Meowby-R1
