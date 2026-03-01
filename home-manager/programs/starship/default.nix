{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";
      character.format = "[\\$](green bold) ";
      directory.truncation_length = 3;
      git_branch = {
        symbol = "";
        format = "[$symbol$branch(:$remote_branch) ]($style)";
      };
      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        conflicted = "💥";
        ahead = "";
        behind = "";
        diverged = "";
        up_to_date = "✓";
        untracked = "";
        stashed = "";
        modified = "🔥";
        staged = "";
        renamed = "";
        deleted = "";
      };
      aws.disabled = true;
      buf.disabled = true;
      bun.disabled = true;
      gcloud.disabled = true;
      golang.disabled = true;
      nodejs.disabled = true;
      package.disabled = true;
      python.disabled = true;
      rust.disabled = true;
    };
  };
}
