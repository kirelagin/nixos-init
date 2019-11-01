{ ... }:

{
  config = {
    nixpkgs.overlays = [ (import ../overlay) ];
  };
}
