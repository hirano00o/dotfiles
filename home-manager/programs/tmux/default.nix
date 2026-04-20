{ pkgs, config, ... }:
{
  programs.tmux = {
    enable = true;
    terminal = "xterm-ghostty";

    prefix = "C-a";

    # キーストロークのディレイを減らす
    escapeTime = 1;
    mouse = true;
    # viのキーバインドをコピーモードで使用する
    keyMode = "vi";
    # Plugins
    plugins = with pkgs.tmuxPlugins; [
      sensible
      logging
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-save-interval '5'
          set -g @continuum-restore 'on'
        '';
      }
    ];

    extraConfig = ''
      unbind C-b

      # C-a*2でtmux内のプログラムにC-aを送る
      bind C-a send-prefix

      # | でペインを縦に分割する
      bind | split-window -h -c "#{pane_current_path}"
      # - でペインを横に分割する
      bind - split-window -v -c "#{pane_current_path}"

      # Vimのキーバインドでペインを移動する
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind -r C-h select-window -t :-
      bind -r C-l select-window -t :+

      # Vimのキーバインドでペインをリサイズする
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # マウスホイールの詳細設定
      bind-key -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'select-pane -t=; copy-mode -e; send-keys -M'"
      bind -n WheelDownPane select-pane -t= \; send-keys -M
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"

      # デフォルトシェルを設定する
      set-option -g default-shell "''${SHELL}"
      set -g default-command "''${SHELL}"

      # ステータスバーの色を設定する
      set -g status-fg white
      set -g status-bg black

      # ウィンドウリストの色を設定する
      setw -g window-status-style bg=default,dim,fg=cyan
      # アクティブなウィンドウを目立たせる
      setw -g window-status-current-style bg=red,bright,fg=white

      # ペインボーダーの色を設定する
      set -g pane-border-style fg=green
      set -g pane-border-style bg=black
      # アクティブなペインを目立たせる
      set -g pane-active-border-style fg=white
      set -g pane-active-border-style bg=yellow

      # コマンドラインの色を設定する
      set -g message-style bg=black,bright,fg=white

      # ステータスバーをトップに配置する
      set-option -g status-position top

      # 左パネルを設定する
      set -g status-left-length 40
      set -g status-left "#[fg=green]Session: #S #[fg=yellow]#I #[fg=cyan]#P"
      # 右パネルを設定する (Claude Code 待機ペイン数を左端に差し込む)
      set-option -g status-right '#(${config.home.homeDirectory}/.claude/scripts/waiting-panes.sh count)[%Y-%m-%d(%a) %H:%M]'
      set-option -g status-right-length 60
      set-option -g status-interval 5

      # ウィンドウリストの位置を中心寄せにする
      set -g status-justify centre
      # ヴィジュアルノーティフィケーションを有効にする
      setw -g monitor-activity on
      set -g visual-activity on

      # <prefix>c で新規ウィンドウをカレントディレクトリで開く
      bind c new-window -c "#{pane_current_path}"

      # <prefix>e でclaude codeを縦分割で起動する
      bind e command-prompt -p "worktree name (empty to skip):" "run-shell 'if [ -n \"%%\" ]; then tmux split-window -h -l $((#{window_width}/3)) -c \"#{pane_current_path}\" \"claude -w %%\"; else tmux split-window -h -l $((#{window_width}/3)) -c \"#{pane_current_path}\" claude; fi'"

      # <prefix>u でlazydockerをポップアップウィンドウで起動する
      bind u display-popup -E -w 90% -h 90% -d "#{pane_current_path}" "lazydocker"

      # <prefix>g でlazygitをポップアップウィンドウで起動する
      bind g display-popup -E -w 90% -h 90% -d "#{pane_current_path}" "lazygit"

      # <prefix>C-n で Claude Code 待機中ペインの一覧をメニュー表示する
      bind C-n run-shell "${config.home.homeDirectory}/.claude/scripts/waiting-panes.sh menu"

      # ペインにフォーカスが移ったら Claude Code 待機状態を解除する
      set-hook -g pane-focus-in 'run-shell "${config.home.homeDirectory}/.claude/scripts/waiting-panes.sh clear"'

      # コピーモードのキーバインドを設定する
      bind-key -T copy-mode-vi v     send-keys -X begin-selection
      bind-key -T copy-mode-vi V     send-keys -X select-line
      bind-key -T copy-mode-vi C-v   send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y     send-keys -X copy-pipe-and-cancel "pbcopy"
      bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "pbcopy"

      set -g extended-keys on
      set -as terminal-features 'xterm*:extkeys'

      # 画像レンダリング（Kitty image protocol）をターミナルに通過させる
      set -g allow-passthrough on
    '';
  };

  programs.zsh = {
    shellAliases = {
      t = "tmux";
    };
  };
}
