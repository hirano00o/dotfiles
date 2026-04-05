{
  nix = {
    optimise.automatic = true;
    settings = {
      sandbox = "relaxed";
      experimental-features = "nix-command flakes";
      download-buffer-size = 268435456;
      min-free = 1073741824; # 1 GiB
    };
  };
}
