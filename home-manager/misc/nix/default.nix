{ config, ... }:
{
  nix = {
    enable = true;
    extraOptions = ''
      experimental-features = nix-command flakes
      !include ${config.xdg.configHome}/nix/local.conf
    '';
  };
}
