{ pkgs, hb }:
with pkgs;
[
  hb.packages.${pkgs.system}.default
  go-mockery
  discord
  orbstack
  brewCasks.bitwarden
  cloudflared
  kubernetes-helm
  scrcpy
  ffmpeg-full
  slack
]
++ lib.optionals stdenv.isDarwin [
]
