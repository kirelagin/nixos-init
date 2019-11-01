{ config, lib, pkgs, modulesPath, ... }@args:

let
  upstream = import "${modulesPath}/misc/version.nix" {
    config.system = config.initramfs;
    inherit lib pkgs;
  };
in

{
  options.initramfs.nixos = upstream.options.system.nixos;
  config = {
    initramfs.nixos = upstream.config.system.nixos;
    initramfs.environment.etc.os-release =
      upstream.config.environment.etc.os-release;
    initramfs.environment.etc.initrd-release.text = "";
  };
}
