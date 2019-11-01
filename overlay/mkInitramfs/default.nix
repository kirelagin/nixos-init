{ stdenv, pkgsHostTarget
, writeTextFile, closureInfo
, systemd
}:

{ etc }:

let
  init = "${systemd}/lib/systemd/systemd";
  # Stupid way of properly capturing the entire closure
  buildCommand0 = writeTextFile {
    name = "buildCommand";
    text = ''
      ln -s "${etc}"/etc "$out"/etc
      ln -s "${init}" "$out"/init
    '';
  };
  _closureInfo = closureInfo { rootPaths = [ buildCommand0 ]; };
in

stdenv.mkDerivation {
  name = "initramfs";

  buildCommand = ''
    mkdir -p "$out"
    xargs -I{} cp -a --parents {} "$out"/ < "${_closureInfo}"/store-paths
    source ${buildCommand0}
  '';
}
