{ username }:
{
  system = {
    primaryUser = username;
    stateVersion = 6;
    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        "com.apple.keyboard.fnState" = true;
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
        wvous-br-corner = 2;
        # AeroSpace 推奨
        expose-group-apps = true;
      };
      # AeroSpace 推奨
      spaces.spans-displays = true;
      controlcenter = {
        Bluetooth = true;
        Sound = true;
        BatteryShowPercentage = true;
      };
    };
    startup = {
      chime = false;
    };
  };
}
