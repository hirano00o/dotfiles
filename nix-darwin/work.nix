{ ... }:
{
  imports = [
    ./default.nix
  ];

  nix.settings.ssl-cert-file = "/etc/ssl/certs/ca-certificates.crt";

  homebrew = {
    casks = [
      "windows-app"
      "microsoft-teams"
    ];
  };
}
