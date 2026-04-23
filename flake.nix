{
  description = "HiBy R1 firmware modification tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Common dependencies needed by both scripts
        toolDeps = with pkgs; [
          p7zip              # 7z command for .upt extraction
          squashfsTools      # unsquashfs/mksquashfs 
          cdrtools          # genisoimage for ISO creation
          coreutils         # md5sum, split, stat, cat
          fakeroot          # replace sudo requirement
          bash              # shell interpreter
        ];

        # Create wrapper that replaces sudo with fakeroot in the original unpack script
        unpack-wrapper = pkgs.writeScriptBin "hiby-unpack" ''
          #!${pkgs.bash}/bin/bash
          export PATH=${pkgs.lib.makeBinPath toolDeps}:$PATH
          
          # Create a modified version of unpack.sh that uses fakeroot instead of sudo
          TEMP_SCRIPT=$(mktemp)
          sed 's/sudo unsquashfs/fakeroot unsquashfs/g' \
            ${./unpack_pack/unpack.sh} > "$TEMP_SCRIPT"
          chmod +x "$TEMP_SCRIPT"
          
          # Execute the modified script
          exec ${pkgs.bash}/bin/bash "$TEMP_SCRIPT" "$@"
        '';

        # Create wrapper that replaces sudo with fakeroot in the original repack script  
        repack-wrapper = pkgs.writeScriptBin "hiby-repack" ''
          #!${pkgs.bash}/bin/bash
          export PATH=${pkgs.lib.makeBinPath toolDeps}:$PATH
          
          # Create a modified version of repack.sh that uses fakeroot instead of sudo
          TEMP_SCRIPT=$(mktemp)
          sed 's/sudo mksquashfs/fakeroot mksquashfs/g; s/sudo unsquashfs/fakeroot unsquashfs/g' \
            ${./unpack_pack/repack.sh} > "$TEMP_SCRIPT"
          chmod +x "$TEMP_SCRIPT"
          
          # Execute the modified script
          exec ${pkgs.bash}/bin/bash "$TEMP_SCRIPT" "$@"
        '';

      in {
        apps = {
          unpack = {
            type = "app";
            program = "${unpack-wrapper}/bin/hiby-unpack";
          };
          
          repack = {
            type = "app";
            program = "${repack-wrapper}/bin/hiby-repack";
          };
        };

        packages = {
          inherit unpack-wrapper repack-wrapper;
          default = pkgs.symlinkJoin {
            name = "hiby-tools";
            paths = [ unpack-wrapper repack-wrapper ];
          };
        };
      }
    );
}