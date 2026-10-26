# Common dependencies needed by scripts
{
  symlinkJoin,
  p7zip,
  squashfsTools,
  cdrkit,
  coreutils,
  fakeroot,
  bashNonInteractive,
  rsync,
  patch,
  diffutils,
  gnused,
}:

symlinkJoin {
  name = "hiby-common-tools-deps";
  paths = [
    p7zip # 7z command for .upt extraction
    squashfsTools # unsquashfs/mksquashfs
    cdrkit # genisoimage for ISO creation
    coreutils # md5sum, split, stat, cat
    fakeroot # replace sudo requirement
    bashNonInteractive # shell interpreter
    rsync # for overlay file copying
    patch # for applying patches
    diffutils # for generating patches
    gnused # for tweaking text
  ];
}
