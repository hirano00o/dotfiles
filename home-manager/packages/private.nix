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
  scrcpy
  ffmpeg-full
]
++ lib.optionals stdenv.isDarwin [
]
