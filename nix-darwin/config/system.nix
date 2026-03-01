{ username }:
{
  system = {
    primaryUser = username;
    stateVersion = 6;
    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
      };
      finder = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = true;
      };
      dock = {
        autohide = true;
        show-recents = false;
        launchanim = false;
        orientation = "bottom";
      };
    };
    startup = {
      chime = false;
    };
  };
}
