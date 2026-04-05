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
  # mcpのテストはNixサンドボックス内でネットワークサーバーを起動しようとして
  # TimeoutErrorになるため、doCheck = falseでテストをスキップする
  # denoのcompile_tests (trybuild) もNixサンドボックス内で失敗するため同様にスキップ
  # https://github.com/NixOS/nixpkgs/pull/445232 がマージされたら除去可能
  mcpFixOverlay = final: prev: {
    deno = prev.deno.overrideAttrs { doCheck = false; };
    python3Packages = prev.python3Packages.override {
      overrides = pyFinal: pyPrev: {
        mcp = pyPrev.mcp.overrideAttrs (old: {
          doCheck = false;
        });
      };
    };
    python311Packages = prev.python311Packages.override {
      overrides = pyFinal: pyPrev: {
        mcp = pyPrev.mcp.overrideAttrs (old: {
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
