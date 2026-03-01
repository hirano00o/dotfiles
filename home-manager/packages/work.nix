{ pkgs }:
with pkgs;
[
  zoom-us
  awscli
  granted
  kubectl
  docker
  docker-credential-helpers
  mongosh
  mongodb-tools
  xbar
]
++ lib.optionals stdenv.isDarwin [
  pkgs.brewCasks.docker-desktop
  pkgs.brewCasks.tunnelblick
]
