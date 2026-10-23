{
  description = "HiBy R1 firmware modification tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "i686-linux"
        "aarch64-darwin"
        "riscv64-linux"
      ];

      eachSystem =
        systems: f:
        builtins.foldl' (
          a: s: a // builtins.mapAttrs (k: v: (a.${k} or { }) // { ${s} = v; }) (f s)
        ) { } systems;
    in
    {
      overlays.default = import ./nix/overlay;
    }
    // eachSystem supportedSystems (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };

        inherit (pkgs) lib;
      in
      {
        packages = lib.filterAttrs (_: lib.isDerivation) pkgs.Meowby-R1 // {
          original = self.packages.${system}.stockFirmwareImage;
        };

        checks = {
          defaultPkg = self.packages.${system}.default;
        };
      }
    );
}
