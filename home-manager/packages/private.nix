{ pkgs }:
with pkgs;
[
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
