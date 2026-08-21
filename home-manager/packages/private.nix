{ pkgs, hb }:
with pkgs;
[
  hb.packages.${pkgs.system}.default
  go-mockery
  discord
  orbstack
  bitwarden-desktop
  cloudflared
  kubernetes-helm
  fluxcd
  scrcpy
  ffmpeg-full
  slack
  zoom-us
]
++ lib.optionals stdenv.isDarwin [
]
