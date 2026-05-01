{ ... }:
{
  imports = [
    ./default.nix
  ];

  environment.etc."ssl/certs/ca-certificates.crt".enable = false;

  nix.settings.ssl-cert-file = "/etc/ssl/certs/ca-certificates.crt";

  homebrew = {
    casks = [
      "windows-app"
      "microsoft-teams"
    ];
  };
}
