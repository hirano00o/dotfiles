{
  description = "hirano00o's nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    flake-parts.url = "github:hercules-ci/flake-parts";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    brew-nix = {
      url = "github:BatteredBunny/brew-nix";
      inputs.brew-api.follows = "brew-api";
    };
    brew-api = {
      url = "github:BatteredBunny/brew-api";
      flake = false;
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    workUsername = {
      url = "path:./users/work";
      flake = true;
    };
    hb = {
      url = "github:hirano00o/hb";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gatehook = {
      url = "github:hirano00o/gatehook";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    decisis = {
      url = "github:hirano00o/decisis";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hunk = {
      url = "github:modem-dev/hunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    arto.url = "github:arto-app/Arto";
    # 26.05-darwin の bitwarden-desktop 2026.5.0 は electron-39 経由で compiler-rt 18 を
    # 引き込み、SDK 26.4 の libcxx 21 (__builtin_ctzg) でビルド不能。修正版 (nixpkgs #530348)
    # を含む master の 2026.7.0 を pin して bitwarden-desktop だけ差し替える。
    nixpkgs-bitwarden.url = "github:NixOS/nixpkgs/3c293e782c514503f6c6b623c0ec80c9b1a605f8";
  };

  outputs =
    {
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
      ];

      flake = {
        darwinConfigurations = {
          privateDarwin = import ./hosts/privateDarwin { inherit inputs; };
          workDarwin = import ./hosts/workDarwin {
            inherit inputs;
            username = inputs.workUsername.value;
            brewUsername = inputs.workUsername.brewUser;
          };
        };
      };
    };
}
