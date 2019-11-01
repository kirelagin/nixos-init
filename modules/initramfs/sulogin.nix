{ config, pkgs, ... }:

{
  config = {
    initramfs.environment.etc = {
      # TODO: Empty password for root. Bad idea?
      "passwd".text = ''
        root::0:0::/:${pkgs.busybox}/bin/ash
      '';
    };

    # TODO: Do not list explicitly but rather generate somehow?
    initramfs.systemd.services.emergency.path = with pkgs; [
      busybox
      utillinux  # TODO: try to get rid of it?
    ] ++ [ config.initramfs.systemd.package ];
  };
}
