{
  system,
  nixpkgs,
  mcp-servers-nix,
  brew-nix,
  rust-overlay,
  llm-agents,
  gatehook,
  extraPackages ? { pkgs }: [ ],
  extraPrograms ? { pkgs, mcp-servers-nix }: [ ],
  ...
}:
let
  isDarwin = builtins.match ".*-darwin" system != null;
  brewNixOverlay = if isDarwin then [ brew-nix.overlays.default ] else [ ];
  # mcpパッケージの壊れたpostPatchを修正するoverlay
  # nixpkgsのmcp 1.25.0にはmacOS向けのpostPatchがあるが、
  # upstream(mcp PR#1529)で該当コードが削除されたため、パッチが失敗する
  # mcp 1.26.0のテストはNixサンドボックス内でネットワークサーバーを起動しようとして
  # TimeoutErrorになるため、doCheck = falseでテストをスキップする
  mcpFixOverlay = final: prev: {
    python3Packages = prev.python3Packages.override {
      overrides = pyFinal: pyPrev: {
        mcp = pyPrev.mcp.overrideAttrs (old: {
          postPatch = "";
          doCheck = false;
        });
      };
    };
    python311Packages = prev.python311Packages.override {
      overrides = pyFinal: pyPrev: {
        mcp = pyPrev.mcp.overrideAttrs (old: {
          postPatch = "";
          doCheck = false;
        });
      };
    };
  };

  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [
      mcpFixOverlay
      (import ./overlays/markitdown-mcp.nix)
      (import ./overlays/drawio-mcp.nix)
      mcp-servers-nix.overlays.default
      rust-overlay.overlays.default
    ]
    ++ brewNixOverlay;
  };
  lib = pkgs.lib;

  basicPkgs = import ./packages/basic.nix { inherit pkgs llm-agents; };

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
