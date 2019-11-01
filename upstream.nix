/* <nixpkgs/nixos> emulation
 *
 * This module provides options and default arguments provided by the original
 * NixOS modules system. This allows us to build the initramfs separately from
 * the main system, just because we can.
 */
{ pkgs, nixos }:

{ config, lib, modulesPath, ...}:

with lib;

let
  inherit (builtins) concatStringsSep filter map;

  overlayType = lib.mkOptionType {
    name = "nixpkgs-overlay";
    description = "nixpkgs overlay";
    check = lib.isFunction;
    merge = lib.mergeOneOption;
  };

in

{
  options = {
    nixpkgs.overlays = lib.mkOption {
      default = [];
      type = lib.types.listOf overlayType;
    };

    system.build = mkOption {
      internal = true;
      default = {};
      type = types.attrs;
      description = ''
        Attribute set of derivations used to setup the system.
      '';
    };

    system.boot.loader.initrdFile = mkOption {
      internal = true;
      default = "initrd";
      type = types.str;
      description = ''
        Name of the initrd file to be passed to the bootloader.
      '';
    };

    fileSystems =
      let
        upstream = import "${modulesPath}/tasks/filesystems.nix" {
          inherit config lib pkgs;
          utils = import "${modulesPath}/../lib/utils.nix" pkgs;
        };
      in upstream.options.fileSystems;

    assertions =
      let
        upstream = import "${modulesPath}/misc/assertions.nix" {
          inherit lib;
        };
      in upstream.options.assertions;
  };

  config = {
    _module.args = {
      pkgs = pkgs.appendOverlays config.nixpkgs.overlays;
      modulesPath = "${nixos}/modules";
    };

    initramfs.build.assertions =
      let
        failedAssertions = map (x: x.message) (filter (x: !x.assertion) config.assertions);
      in
        if length failedAssertions > 0
        then throw "Failed assertions:\n${concatStringsSep "\n" (map (x: "- ${x}") failedAssertions)}"
        else null;

    fileSystems."/" = {
      device = "/dev/fakeroot";
      options = [ "loop" ];
    };
  };
}
