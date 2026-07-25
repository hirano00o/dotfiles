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
  nixpkgs-bitwarden,
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
  # 26.05-darwin の bitwarden-desktop 2026.5.0 は electron-39 経由で compiler-rt 18 を引き込み、
  # SDK 26.4 の libcxx 21 (__builtin_ctzg) でビルド不能。修正版を含む pin した nixpkgs の
  # 2026.7.0 (electron 新版・compiler-rt 18 非依存) に差し替える。legacyPackages を直接使う
  # (import ... {config} で作り直すと drv が変わりバイナリキャッシュを外すため)。
  bitwardenOverlay = final: prev: {
    bitwarden-desktop = nixpkgs-bitwarden.legacyPackages.${system}.bitwarden-desktop;
  };

  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [
      dontCheckOverlay
      bitwardenOverlay
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

  home.stateVersion = "25.11";
  home.packages = basicPkgs ++ (extraPackages { inherit pkgs; });
}
