{ pkgs }:
with pkgs;
[
  _1password-gui
  _1password-cli
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
  datadog-pup
]
++ lib.optionals stdenv.isDarwin [
  pkgs.brewCasks.docker-desktop
  pkgs.brewCasks.tunnelblick
]
