{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    casks = [
      "karabiner-elements"
      "google-chrome"
      "logi-options+"
    ];
  };
}
