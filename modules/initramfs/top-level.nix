{ config, lib, pkgs, ... }:

with lib;

let
  makeImage = { drv, compress ? true }:
    pkgs.stdenv.mkDerivation {
      name = "${drv.name}-img" + lib.optionalString compress ".xz";
      nativeBuildInputs = with pkgs; [ cpio xz ];
      buildCommand = ''
        cd "${drv}"
        find . -print0 \
        | cpio --create --null --format=newc -R +0:+0 --reproducible --quiet \
      '' + lib.optionalString compress ''
        | xz \
      '' + ''
        > "$out"
      '';
    };
in

{
  options = {
    initramfs.build = mkOption {
      internal = true;
      default = {};
      type = types.attrs;
      description = ''
        Attribute set of derivations used to build the initramfs.
      '';
    };
  };

  config = {
    initramfs.build.toplevel = pkgs.makeInitramfs.override {
      systemd = config.initramfs.systemd.package;
    } {
      inherit (config.initramfs.build) etc;
    };

    initramfs.build.image = pkgs.callPackage makeImage {
      drv = config.initramfs.build.toplevel;
    };

    # NixOS compatibility
    # TODO: For some reason this line does nothing.
    system.build.initialRamdisk = config.initramfs.build.image;
    system.boot.loader.initrdFile = "init";
  };
}
