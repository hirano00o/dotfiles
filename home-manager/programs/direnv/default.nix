{
  programs.direnv = {
    enable = true;
    stdlib = ''
      use_github_token() {
        export GITHUB_TOKEN=$(gh auth token)
      }
    '';
  };
}
