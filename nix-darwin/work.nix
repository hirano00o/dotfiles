{ brewUsername, ... }:
{
  imports = [
    ./default.nix
    ./config/zsh.nix
  ];

  environment.etc."ssl/certs/ca-certificates.crt".enable = false;

  nix.settings.ssl-cert-file = "/etc/ssl/certs/ca-certificates.crt";

  # darwin-rebuild 実行ユーザーと適用させたいユーザーが異なるときに
  # /opt/homebrew の所有者と一致させて実行させる。
  homebrew.user = brewUsername;
  homebrew.casks = [
    "1password"
  ];
}
