{
  system,
  nixpkgs,
  nixpkgs-stable,
  mcp-servers-nix,
  brew-nix,
  rust-overlay,
  llm-agents,
  gatehook,
  decisis,
  hunk,
  arto,
  gprt,
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
    # weasyprint の assert_pixels_equal テストが darwin で失敗する。md2pdf 等の
    # 依存経由でも使われるため、python3Packages.override ではなく拡張で全体に効かせる。
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (pyFinal: pyPrev: {
        weasyprint = pyPrev.weasyprint.overridePythonAttrs { doCheck = false; };
      })
    ];
  };

  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
    config.permittedInsecurePackages = [ "electron-39.8.10" ];
    overlays = [
      dontCheckOverlay
      (import ./overlays/drawio-mcp.nix)
      (import ./overlays/python-audio-darwin.nix)
      rust-overlay.overlays.default
    ]
    ++ extraOverlays
    ++ brewNixOverlay;
  };
  pkgs-stable = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
  pkgs-mcp = import mcp-servers-nix.inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [ mcp-servers-nix.overlays.default ];
  };
  lib = pkgs.lib;

  basicPkgs = import ./packages/basic.nix {
    inherit
      pkgs
      pkgs-stable
      llm-agents
      decisis
      hunk
      arto
      gprt
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
    inherit
      mcp-servers-nix
      pkgs-mcp
      llm-agents
      gatehook
      ;
  };

  # nix-darwin 26.05 の制約でmodule評価のlibはstableのままpkgsだけunstableにしているため、
  # unstableのmake-options-docがstableのlibで評価されて失敗する。マニュアルは使わないので無効化する
  manual.manpages.enable = false;
  # libとpkgsのリリース差を意図して許容しているので警告を抑止する
  home.enableNixpkgsReleaseCheck = false;

  home.stateVersion = "26.05";
  home.packages = basicPkgs ++ (extraPackages { inherit pkgs; });
}
