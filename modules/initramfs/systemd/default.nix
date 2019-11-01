{ config, lib, modulesPath, pkgs, utils, ... }:

with lib;

let
  upstream = import "${modulesPath}/system/boot/systemd.nix" {
    config = config.initramfs;
    inherit lib pkgs utils;
  };

  sdlib =
    import "${modulesPath}/system/boot/systemd-lib.nix" {
      config = config.initramfs;
      inherit lib pkgs;
    };
  unitOptions =
    import "${modulesPath}/system/boot/systemd-unit-options.nix" {
      config = config.initramfs;
      inherit lib;
    };

  # See https://www.freedesktop.org/software/systemd/man/bootup.html
  defaultUpstreamUnits = [
    "systemd-hibernate-resume@.service"

    "local-fs-pre.target"
    "local-fs.target"

    "swap.target"

    # "cryptsetup.target"  # TODO: needs libcryptsetup

    "sysinit.target"

    "timers.target"
    "paths.target"
    "sockets.target"
    "rescue.service"
    "rescue.target"

    "basic.target"

    "emergency.service"
    "emergency.target"

    "initrd-root-device.target"
    "initrd-root-fs.target"
    "initrd-parse-etc.service"
    "initrd-fs.target"
    "initrd.target"

    "initrd-cleanup.service"

    "initrd-udevadm-cleanup-db.service"

    "initrd-switch-root.target"
    "initrd-switch-root.service"
  ];

  # TODO: Not sure why it is done this way instead of copying all of them
  defaultUpstreamWants = [
    "local-fs.target.wants"
    "sysinit.target.wants"
    "timers.target.wants"
    "sockets.target.wants"

    "multi-user.target.wants"  # TODO: stupid `generateUnits`
  ];

  cfg = config.initramfs.systemd;

in

{
  options.initramfs = {
    systemd = {
      package = upstream.options.systemd.package // {
        default = pkgs.systemdMini;
        defaultText = "pkgs.systemdMini";
      };

      inherit (upstream.options.systemd)
        units targets services sockets timers paths mounts automounts slices
        packages globalEnvironment;

      # TODO: These probably do not make a lot of sense for initramfs
      # but omitting them is not an option as stupid `generateUnits` wants them.
      defaultUnit = upstream.options.systemd.defaultUnit // {
        default = "initrd.target";
        readOnly = true;  # Don’t, just don’t mess with initramfs
      };
      ctrlAltDelUnit = upstream.options.systemd.ctrlAltDelUnit;

      upstreamUnits = lib.mkOption {
        default = [];
        type = types.listOf types.str;
      };
      upstreamWants = lib.mkOption {
        default = [];
        type = types.listOf types.str;
      };
    };
  };

  config.initramfs = {
    systemd.units = upstream.config.systemd.units;

    systemd.upstreamUnits = defaultUpstreamUnits;
    systemd.upstreamWants = defaultUpstreamWants;

    environment.etc = {
      "systemd/system".source = sdlib.generateUnits "system" cfg.units cfg.upstreamUnits cfg.upstreamWants;
      "machine-id".text = "";
    };
  };
}
