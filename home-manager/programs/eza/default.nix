{
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    colors = "auto";
    git = true;
  };

  programs.zsh.shellAliases = {
    ls = "eza";
    ll = "eza -l";
  };
}
