args@{ sops-nix, ... }:
import ./default.nix (
  args
  // {
    extraPackages = { pkgs }: import ./packages/work.nix { inherit pkgs; };
    extraPrograms =
      { pkgs, mcp-servers-nix }:
      import ./programs/work.nix { inherit pkgs mcp-servers-nix; }
      ++ [
        sops-nix.homeManagerModules.sops
        ./sops/work.nix
      ];
  }
)
