{ pkgs, hb }:
with pkgs;
[
  hb.packages.${pkgs.system}.default
  go-mockery
  discord
  orbstack
  bitwarden-desktop
  cloudflared
  scrcpy
  ffmpeg-full
  slack
  zoom-us
  antigravity-cli

  # kubernetes tools
  kubernetes-helm
  kustomize
  kubeseal
  fluxcd
]
++ lib.optionals stdenv.hostPlatform.isDarwin [
  (pkgs.brewCasks.google-gemini.overrideAttrs (old: {
    src = fetchurl {
      url = builtins.head old.src.urls;
      hash = "sha256-mzWr/7iqWZHXUJTRN2LL44q0GgGvVidhf2itT9VduxY=";
    };
  }))
]
