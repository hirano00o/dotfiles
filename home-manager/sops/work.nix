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
      "jira/api_token" = { };

      "obsidian/plugin/remotely_save/secret" = { };

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

  home.activation.registerJiraToken = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ "$(uname)" == "Darwin" ]]; then
      if token=$(SOPS_AGE_KEY_FILE="${config.xdg.configHome}/sops/age/keys.txt" ${pkgs.sops}/bin/sops --extract '["jira"]["api_token"]' -d ${toString ../../secrets/work.enc.yaml} 2>/dev/null); then
        run /usr/bin/security add-generic-password \
          -a "$USER" -s "jira_api_token" -w "$token" -U
      fi
    fi
  '';
}
