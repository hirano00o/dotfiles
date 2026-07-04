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

    defaultSopsFile = ../../secrets/private.enc.yaml;

    # macOS LaunchAgent needs PATH to find getconf and newfs_hfs
    environment = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      PATH = lib.mkForce "/usr/bin:/usr/sbin:/bin:/sbin";
    };

    secrets = {
      "obsidian/plugin/remotely_save/secret" = { };

      "git/config" = {
        path = "${config.home.homeDirectory}/.gitconfig";
        mode = "0644";
      };
      "ssh/config" = {
        path = "${config.home.homeDirectory}/.ssh/config";
        mode = "0600";
      };
      "ssh/id_ed25519" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        mode = "0600";
      };
      "ssh/id_ed25519_pub" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        mode = "0644";
      };
      "ssh/id_ed25519_kubernetes" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519_kubernetes";
        mode = "0600";
      };
      "ssh/id_ed25519_pub_kubernetes" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519_kubernetes.pub";
        mode = "0644";
      };
      "kubernetes/config" = {
        path = "${config.home.homeDirectory}/.kube/config";
        mode = "0600";
      };
      "python" = {
        path = "${config.home.homeDirectory}/.pypirc";
        mode = "0600";
      };

      # github MCP サーバの envFile (claude-code/default.nix の mcpServers.github が参照)。
      # 有効化する前に README の手順で secrets/private.enc.yaml に
      # claude/github_env を sops set しておくこと (未投入だと activation が失敗する)。
      # "claude/github_env" = {
      #   path = "${config.home.homeDirectory}/.claude/.github.token";
      #   mode = "0600";
      # };
    };
  };
}
