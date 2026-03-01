{
  programs.neovim = {
    enable = true;
  };

  xdg.configFile."nvim" = {
    source = ../../../.config/nvim;
    recursive = true;
  };

  programs.zsh = {
    shellAliases = {
      v = "nvim";
    };
  };
}
