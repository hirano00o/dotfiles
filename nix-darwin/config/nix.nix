{ pkgs, ... }:
{
  nix = {
    # Nix 2.34.9 makes the darwin sandbox profile exceed its 64 KiB limit for large closures
    # such as home-manager-generation (https://github.com/NixOS/nix/issues/16613).
    # Pinning 2.34.8 would reintroduce GHSA-m4vq-qf6v-82pj, so backport the unmerged fix
    # https://github.com/NixOS/nix/pull/16617 until a release contains it.
    # The now-enforced sandbox denies stat on /nix/var, which breaks the flake unit tests
    # when building Nix locally; backport https://github.com/NixOS/nix/pull/16660 for that.
    package =
      (pkgs.nixVersions.nixComponents_2_34.appendPatches [
        ./patches/nix-darwin-sandbox-regex.patch
        ./patches/nix-default-nix-path-eperm.patch
      ]).nix-everything;
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
      substituters = [ "https://cache.numtide.com" ];
      trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
    };
  };
}
