{ config }:
{
  sops = {
    age = {
      generateKey = true;
      keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
      sshKeyPaths = [ ];
    };
    gnupg.sshKeyPaths = [ ];
    defaultSopsFile = ../../secrets/work.enc.yaml;
    secrets = { };
  };
}
