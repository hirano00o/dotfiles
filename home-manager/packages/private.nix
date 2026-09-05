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

  # kubernetes tools
  kubernetes-helm
  kustomize
  kubeseal
  fluxcd
]
++ lib.optionals stdenv.isDarwin [
]
