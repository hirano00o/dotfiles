{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;

    defaultCommand = "fd --type f --hidden --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --exclude .git";

    fileWidgetOptions = [ "--preview 'bat --color=always --style=plain {}'" ];
    changeDirWidgetOptions = [ "--preview 'eza --tree --level=2 --color=always {}'" ];

    defaultOptions = [ "--highlight-line" ];
  };
}
