{
  config,
  pkgs,
  lib,
  ...
}:
{
  sops = {
    age = {
      generateKey = true;
      keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
      sshKeyPaths = [ ];
    };
    gnupg.sshKeyPaths = [ ];

    defaultSopsFile = ../../secrets/work.enc.yaml;

    # macOS LaunchAgent needs PATH to find getconf and newfs_hfs
    environment = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      PATH = lib.mkForce "/usr/bin:/usr/sbin:/bin:/sbin";
    };

    secrets = {
      "git/config" = {
        path = "${config.home.homeDirectory}/.gitconfig";
        mode = "0644";
      };
      "git/private_config" = {
        path = "${config.home.homeDirectory}/.gitconfig_private";
        mode = "0644";
      };
      "ssh/config" = {
        path = "${config.home.homeDirectory}/.ssh/config";
        mode = "0600";
      };
      "ssh/id_ed25519_github" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519_github";
        mode = "0600";
      };
      "ssh/id_ed25519_github_pub" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519_github.pub";
        mode = "0644";
      };
      "ssh/id_ed25519_github_private" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519_github_private";
        mode = "0600";
      };
      "ssh/id_ed25519_github_pub_private" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519_github_private.pub";
        mode = "0644";
      };
    };
  };
}
