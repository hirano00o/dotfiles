{ pkgs, username, ... }:
let
  environment = import ./config/environment.nix;
  fonts = import ./config/fonts.nix { inherit pkgs; };
  homebrew = import ./config/homebrew.nix;
  mozkey = import ./config/mozkey.nix { inherit pkgs; };
  nix = import ./config/nix.nix;
  security = import ./config/security.nix;
  system = import ./config/system.nix { inherit username; };
  time = import ./config/time.nix;
in
{
  imports = [
    environment
    fonts
    homebrew
    mozkey
    nix
    security
    system
    time
  ];

  brew-nix.enable = true;
  environment.systemPackages = with pkgs; [
    brewCasks.claude
  ];
}
