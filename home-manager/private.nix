args@{ sops-nix, ... }:
import ./default.nix (
  args
  // {
    extraPackages = { pkgs }: import ./packages/private.nix { inherit pkgs; hb = args.hb; };
    extraPrograms =
      { pkgs, mcp-servers-nix }:
      import ./programs/private.nix { inherit pkgs mcp-servers-nix; }
      ++ [
        sops-nix.homeManagerModules.sops
        ./sops/private.nix
      ];
  }
)
