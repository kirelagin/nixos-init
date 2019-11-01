# systemd-based initramfs for NixOS

![](doc/nixos-init.svg)

This is an experimental attempt to reimplement the stage-1 initramfs of NixOS
so that it is managed by systemd rather than boring shell scripts.


## Use

* Currently the primary way of building this initramfs is just `nix-build` in the
root of the repository.
* But it is also possible to import the modules from this repository into
  your regular NixOS config and build it normally:


  ```nix
  # /etc/nixos/configuration.nix
  {
    imports = [
      # ... other imports ...
    ]
    ++ import /path/to/nixos-init/modules/module-list.nix;

    # ...
  }
  ```
