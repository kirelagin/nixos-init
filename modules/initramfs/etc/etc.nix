/* Populate /etc in initramfs.
 *
 * This module reuses the one from NixOS, except that it does not do the
 * activation thing, because /etc in initramfs is immutable, so there is
 * no need to populate it with symlinks.
*/

{ config, lib, pkgs, modulesPath, ... }@args:

let
  upstream = import "${modulesPath}/system/etc/etc.nix" {
    config = config.initramfs;
    inherit lib pkgs;
  };
in

{
  options = {
    initramfs.environment.etc = upstream.options.environment.etc;
  };

  config = {
    initramfs.build.etc = upstream.config.system.build.etc;
  };
}
