{ config, lib, ... }:
{
  home.activation.createZshDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $VERBOSE_ARG "${config.xdg.configHome}/zsh"
  '';

  home.activation.createObsidianDir = lib.hm.dag.entryBefore [ "obsidian" ] ''
    run mkdir -p $VERBOSE_ARG "${config.xdg.configHome}/obsidian"
  '';
}
