{
  description = "HiBy R1 firmware modification tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
        
        # Common dependencies needed by both scripts
        toolDeps = with pkgs; [
          p7zip              # 7z command for .upt extraction
          squashfsTools      # unsquashfs/mksquashfs 
          cdrkit             # genisoimage for ISO creation
          coreutils          # md5sum, split, stat, cat
          fakeroot           # replace sudo requirement
          bash               # shell interpreter
        ];

        hiByOS-v1-6 = pkgs.fetchurl {
          # https://drive.google.com/drive/folders/1A2RIMdvuZRzGCNMY9F81vtGAAs2FJ46W?usp=sharing
          url = "https://drive.usercontent.google.com/download?export=download&id=1cvZdQeJsb2qYu2qv6sZaYJaP8vqW1LqG&confirm=t";
          sha256 = "sha256-mq2oGZXY0rLtgNbPKSxivF8PcF5R5PacfnZu5nU2umA=";
          name = "HiBy-OS-v1.6.upt";
        };

        # Create wrapper that replaces sudo with fakeroot in the original unpack script
        unpack-wrapper = pkgs.writeScriptBin "hiby-unpack" ''
          #!${lib.getExe pkgs.bash}
          export PATH=${pkgs.lib.makeBinPath toolDeps}:$PATH
          
          # TEMP_SCRIPT=${./unpack_pack/unpack.sh}

          # Create a modified version of unpack.sh that uses fakeroot instead of sudo
          TEMP_SCRIPT=$(mktemp)
          sed 's/sudo unsquashfs/fakeroot unsquashfs/g' \
            ${./unpack_pack/unpack.sh} > "$TEMP_SCRIPT"
          chmod +x "$TEMP_SCRIPT"
          
          # Execute the modified script
          exec ${lib.getExe pkgs.bash} "$TEMP_SCRIPT" "${self.packages.${system}.original}"
        '';

        # Create wrapper that replaces sudo with fakeroot in the original repack script  
        repack-wrapper = pkgs.writeScriptBin "hiby-repack" ''
          #!${lib.getExe pkgs.bash}
          export PATH=${pkgs.lib.makeBinPath toolDeps}:$PATH
          
          # TEMP_SCRIPT=${./unpack_pack/repack.sh}

          # Create a modified version of repack.sh that uses fakeroot instead of sudo
          TEMP_SCRIPT=$(mktemp)
          sed 's/sudo mksquashfs/fakeroot mksquashfs/g; s/sudo unsquashfs/fakeroot unsquashfs/g' \
            ${./unpack_pack/repack.sh} > "$TEMP_SCRIPT"
          chmod +x "$TEMP_SCRIPT"
          
          # Execute the modified script
          exec ${lib.getExe pkgs.bash} "$TEMP_SCRIPT" "$@"
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
          original = hiByOS-v1-6;
        };
      }
    );
}
