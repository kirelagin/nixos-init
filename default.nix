{ localSystem ? { system = builtins.currentSystem; }
, crossSystem ? null

, pkgs ? import <nixpkgs> { inherit localSystem crossSystem; }
, nixos ? <nixpkgs/nixos>

, compress ? true
}:

let
  # Fake NixOS module system environment
  _upstream = import ./upstream.nix { inherit pkgs nixos; };

  inherit (pkgs.lib.evalModules {
    modules = (import ./modules/module-list.nix) ++ [ _upstream ];
  }) options config;
in

{
  _assertions = config.initramfs.build.assertions;

  #unpacked = config.initramfs.build.toplevel;  # Unpacked initramfs directory
  image = config.initramfs.build.image.override { inherit compress; };
}
