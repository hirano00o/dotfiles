{ inputs }:
let
  inherit (inputs)
    nix-darwin
    home-manager
    brew-nix
    ;
  inherit (inputs) nixpkgs;

  username = "hirano00o";
  system = "aarch64-darwin";

  pkgs = import nixpkgs {
    inherit system;
    overlays = [
      brew-nix.overlays.default
    ];
  };
  configuration =
    { ... }:
    {
      users.users.${username}.home = "/Users/${username}";
    };
in
nix-darwin.lib.darwinSystem {
  inherit pkgs;
  inherit (inputs.nixpkgs) lib;
  specialArgs = {
    inherit username pkgs;
  };
  modules = [
    configuration
    ../../nix-darwin/private.nix
    brew-nix.darwinModules.default
    home-manager.darwinModules.home-manager
    {
      home-manager = {
        backupFileExtension = "backup";
        useUserPackages = true;
        users."${username}" = import ../../home-manager/private.nix;
        extraSpecialArgs = {
          inherit system username;
          inherit (inputs) nixpkgs;
          inherit (inputs) mcp-servers-nix;
          inherit (inputs) brew-nix;
          inherit (inputs) rust-overlay;
          inherit (inputs) llm-agents;
          inherit (inputs) sops-nix;
        };
      };
    }
  ];
}
