{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    casks = [
      "karabiner-elements"
      "logi-options+"
    ];
  };
}
