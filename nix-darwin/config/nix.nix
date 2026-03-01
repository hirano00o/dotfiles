{
  nix = {
    optimise.automatic = true;
    settings = {
      sandbox = "relaxed";
      experimental-features = "nix-command flakes";
      download-buffer-size = 268435456;
    };
  };
}
