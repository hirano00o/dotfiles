{ config, pkgs, ... }:
let
  zsh-interactive-cd = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/mrjohannchang/zsh-interactive-cd/e7d4802aa526ec069dafec6709549f4344ce9d4a/zsh-interactive-cd.plugin.zsh";
    sha256 = "sha256-dbDYYcgwYzvl7UL8dRvwucPm64HhLJ7/pCbZ+SEkUzc=";
  };
in
{
  home.file = {
    ".config/zsh/completion.zsh".source = ./config/completion.zsh;
    ".config/zsh/function.zsh".source = ./config/function.zsh;
    ".config/zsh/zsh-interactive-cd.plugin.zsh".source = zsh-interactive-cd;
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
    };
    defaultKeymap = "viins";
    dotDir = "${config.xdg.configHome}/zsh";
    history = {
      extended = true;
      path = "${config.home.homeDirectory}/.zsh_history";
      save = 1000000;
      size = 1000000;
      expireDuplicatesFirst = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      saveNoDups = true;
      share = true;
    };
    shellAliases = {
      k = "kubectl";
    };
    shellGlobalAliases = {
      C = "| pbcopy";
    };
    initContent = ''
      export LANG=ja_JP.UTF-8
      bindkey -M viins '^j' vi-cmd-mode
      bindkey -M viins '^f' autosuggest-accept

      [ -f ${config.xdg.configHome}/zsh/path.zsh ] && source ${config.xdg.configHome}/zsh/path.zsh
      [ -f ${config.xdg.configHome}/zsh/completion.zsh ] && source ${config.xdg.configHome}/zsh/completion.zsh
      [ -f ${config.xdg.configHome}/zsh/function.zsh ] && source ${config.xdg.configHome}/zsh/function.zsh
      [ -f ${config.xdg.configHome}/zsh/zsh-interactive-cd.plugin.zsh ] && source ${config.xdg.configHome}/zsh/zsh-interactive-cd.plugin.zsh
      [ -f ${config.xdg.configHome}/zsh/work.zsh ] && source ${config.xdg.configHome}/zsh/work.zsh
    '';
  };
}
