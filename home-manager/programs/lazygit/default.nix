{
  programs.lazygit = {
    enable = true;
    settings = {
      keybinding.files.commitChanges = "C";
      customCommands = [
        {
          key = "c";
          context = "files";
          description = "Commit (Claude message if staged)";
          command = "git commit -m {{ .Form.Message | quote }}";
          prompts = [
            {
              type = "input";
              title = "Commit message";
              key = "Message";
              initialValue = "{{ runCommand \"bash -c 'if git diff --cached --quiet; then :; else git diff --cached | claude -p \\\"Generate a concise, conventional-commits style commit message in English for this staged diff. Output only the message, single line, no quotes, no code fences.\\\" 2>/dev/null | head -1; fi'\" }}";
            }
          ];
        }
      ];
    };
  };
}
