{
  nix = {
    optimise.automatic = true;
    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 14d";
    };
    settings = {
      sandbox = "relaxed";
      experimental-features = "nix-command flakes";
      download-buffer-size = 268435456;
      min-free = 5368709120; # 5 GiB
      max-free = 10737418240; # 10 GiB
      auto-optimise-store = true;
    };
  };
}
