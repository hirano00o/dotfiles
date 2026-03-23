{ pkgs }:
with pkgs;
[
  zoom-us
  awscli2
  saml2aws
  granted
  kubectl
  docker
  docker-credential-helpers
  mongosh
  mongodb-tools
  xbar
  jira-cli-go
]
++ lib.optionals stdenv.isDarwin [
  pkgs.brewCasks.docker-desktop
  pkgs.brewCasks.tunnelblick
]
