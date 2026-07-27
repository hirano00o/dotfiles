{
  system,
  nixpkgs,
  nixpkgs-stable,
  mcp-servers-nix,
  brew-nix,
  rust-overlay,
  llm-agents,
  gatehook,
  hunk,
  arto,
  extraOverlays ? [ ],
  extraPackages ? { pkgs }: [ ],
  extraPrograms ? { pkgs, mcp-servers-nix }: [ ],
  ...
}:
let
  isDarwin = builtins.match ".*-darwin" system != null;
  brewNixOverlay = if isDarwin then [ brew-nix.overlays.default ] else [ ];
  # いくつかテストはNixサンドボックス内でネットワークサーバーを起動しようとして
  # TimeoutErrorになるため、doCheck = falseでテストをスキップする
  dontCheckOverlay = final: prev: {
    chromaprint = prev.chromaprint.overrideAttrs { doCheck = false; };
    kvazaar = prev.kvazaar.overrideAttrs { doCheck = false; };
  };

  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
    config.permittedInsecurePackages = [ "electron-39.8.10" ];
    overlays = [
      dontCheckOverlay
      (import ./overlays/drawio-mcp.nix)
      (import ./overlays/d2-darwin.nix)
      (import ./overlays/python-audio-darwin.nix)
      mcp-servers-nix.overlays.default
      rust-overlay.overlays.default
    ]
    ++ extraOverlays
    ++ brewNixOverlay;
  };
  pkgs-stable = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
  lib = pkgs.lib;

  basicPkgs = import ./packages/basic.nix {
    inherit
      pkgs
      pkgs-stable
      llm-agents
      hunk
      arto
      ;
  };

  misc = import ./misc { };

  basicPrograms = import ./programs/basic.nix {
    inherit mcp-servers-nix;
    inherit rust-overlay;
    inherit llm-agents;
  };
in
{
  imports = misc ++ basicPrograms ++ (extraPrograms { inherit pkgs mcp-servers-nix; });

  # すべてのモジュールがoverlayを含むpkgsを使用するように設定
  _module.args = {
    pkgs = lib.mkForce pkgs;
    inherit mcp-servers-nix llm-agents gatehook;
  };

  home.stateVersion = "26.05";
  home.packages = basicPkgs ++ (extraPackages { inherit pkgs; });
}
