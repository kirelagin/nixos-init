self: super:

let
  inherit (self) callPackage;
in

{
  makeInitramfs = callPackage ./mkInitramfs { };

  systemdMini = super.systemd.override {
    # TODO: create a really minimal build of systemd
    glibcLocales = null;
    iptables = null;
    libapparmor = null;
    libgcrypt = null;
    libmicrohttpd = null;
#    pam = null;
    pcre2 = null;
    perl = null;
    withKexectools = false;
    xz = null;
  };
}
