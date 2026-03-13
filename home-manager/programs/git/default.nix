{
  programs.git = {
    enable = true;
    ignores = [
      "*.swp"
      "*~"
      ".DS_Store"
      ".direnv"
      ".serena/"
      "**/.claude/**/*.local.*"
      "**/.claude/handovers/**"
    ];
  };

  programs.zsh = {
    shellAliases = {
      g = "git";
      gst = "git status";
      gn = "git checkout -b";
      gd = "git diff --color";
      gs = "git switch";
      gpl = "git pull";
      glgg = "git log --color --graph --decorate --oneline";
    };
  };
}
