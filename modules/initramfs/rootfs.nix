{ config, lib, ... }:

with lib;

let
  inherit (builtins) concatStringsSep filter length map;
  inherit (lib) attrValues;
  mkFsLine = fs:
    ''${fs.device}  /sysroot ${fs.fsType}  ${concatStringsSep "," fs.options}  0 1'';
  roots = filter (fs: fs.mountPoint == "/") (attrValues config.fileSystems);
in

{
  options = {
    initramfs.rootfsTimeout = mkOption {
      type = types.nullOr types.int;
      default = 10;
      description = ''Timeout waiting for the rootfs to be mounted.'';
    };
  };

  config = {
    assertions = [
      { assertion = length roots > 0;
        message = "The ‘fileSystems’ option does not specify your root file system.";
      }
      { assertion = length roots <= 1;
        message = "The ‘fileSystems’ option specifies your root file system multiple times.";
      }
    ];

    initramfs = {
      environment.etc = {
        "fstab".text = concatStringsSep "\n" (map mkFsLine roots) + "\n";
      };

      systemd.targets.initrd-root-fs.unitConfig = mkIf (config.initramfs.rootfsTimeout != null) {
        JobTimeoutSec = toString config.initramfs.rootfsTimeout;
      };
    };
  };
}
