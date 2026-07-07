{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;

    defaultCommand = "fd --type f --hidden --exclude .git";
    defaultOptions = [ "--highlight-line" ];
    fileWidget = {
      command = "fd --type f --hidden --exclude .git";
      options = [ "--preview 'bat --color=always --style=plain {}'" ];
    };
    changeDirWidget = {
      command = "fd --type d --hidden --exclude .git";
      options = [ "--preview 'eza --tree --level=2 --color=always {}'" ];
    };
  };
}
