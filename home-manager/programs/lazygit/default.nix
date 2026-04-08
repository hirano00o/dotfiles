{
  programs.lazygit = {
    enable = true;
    settings = {
      customCommands = [
        {
          key = "<c-a>";
          context = "files";
          description = "Draft commit message with Claude";
          command = ''
            msg=$(mktemp) && git diff --cached | claude -p "英語のコミットメッセージを1行で出力" > "$msg" && git commit -e -F "$msg"; rm -f "$msg"
          '';
          output = "terminal";
        }
      ];
    };
  };
}
