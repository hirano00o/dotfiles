{ pkgs }:
{
  fonts.packages = with pkgs; [
    moralerspace
    moralerspace-hw
    moralerspace-jpdoc
    moralerspace-hwjpdoc
    hackgen-font
    hackgen-nf-font
    nerd-fonts.symbols-only
  ];
}
