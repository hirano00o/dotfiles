args@{ sops-nix, ... }:
import ./default.nix (
  args
  // {
    extraOverlays = [ (import ./overlays/datadog-pup.nix) ];
    extraPackages = { pkgs }: import ./packages/work.nix { inherit pkgs; };
    extraPrograms =
      { pkgs, mcp-servers-nix }:
      import ./programs/work.nix { inherit pkgs mcp-servers-nix; }
      ++ [
        sops-nix.homeManagerModules.sops
        ./sops/work.nix
        {
          home.sessionVariables = {
            NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";
          };
        }
      ];
  }
)
