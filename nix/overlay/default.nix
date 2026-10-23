final: _prev: {
  Meowby-R1 = final.lib.makeScope final.newScope (self: {
    HiByOS-v1-6 = self.callPackage ../package/hibyos-v1_6.nix { };
    stockFirmwareImage = self.HiByOS-v1-6;
    toolDeps = self.callPackage ../package/tool-deps.nix { };
    writeDashBin = self.callPackage ../package/write-dash-bin.nix { };
    unpack = self.callPackage ../package/unpack-wrapper.nix { };
    repack = self.callPackage ../package/repack-wrapper.nix { };
    apply-overlay = self.callPackage ../package/apply-overlay-wrapper.nix { };
    create-overlay = self.callPackage ../package/create-overlay-wrapper.nix { };
    default = final.symlinkJoin {
      name = "hiby-tools";
      paths = [
        self.unpack
        self.repack
        self.apply-overlay
        self.create-overlay
      ];
    };
  });
}
