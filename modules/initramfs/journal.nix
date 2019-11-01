{ config, ... }:

{
  config.initramfs = {
    environment.etc = {
      "systemd.journald.conf".text = ''
        [Journal]
        Storage=volatile
        RateLimitInterval=0
        RateLimitBurst=0
      '';
    };

    systemd.upstreamUnits = [
      "systemd-journald.service"
      "systemd-journald.socket"
      "systemd-journald-dev-log.socket"
    ];
  };
}
