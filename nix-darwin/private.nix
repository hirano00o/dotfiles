{ ... }:
let
  network = import ./config/network.nix;
in
{
  imports = [
    ./default.nix
    network
  ];
}
