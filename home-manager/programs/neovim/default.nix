{ config, lib, ... }:
{
  programs.neovim = {
    enable = true;
    withRuby = true;
    withPython3 = true;
  };

  xdg.configFile."nvim" = {
    source = ../../../.config/nvim;
    recursive = true;
  };

  # vim.loaderのバイトコードキャッシュはmtimeとサイズだけで鮮度を判定する。
  home.activation.clearNeovimLuaCache = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run rm -rf $VERBOSE_ARG "${config.xdg.cacheHome}/nvim/luac"
  '';

  programs.zsh = {
    shellAliases = {
      v = "nvim";
    };
  };
}
