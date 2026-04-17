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

  programs.zsh = {
    shellAliases = {
      v = "nvim";
    };
  };
}
