{ pkgs, ... }:
{
  imports = [
    ./rust-analyzer.nix
  ];

  home.packages = with pkgs; [
    (rust-bin.stable.latest.minimal.override {
      extensions = [
        # "rust-src" (rust-analyzer の std ソース診断用) は nix 2.30+ の build-dir 参照スキャンで
        # ビルドが失敗するため一時的に無効化。上流修正後に戻す (NixOS/nix#13701 系)
        "rust-analyzer"
        "clippy"
        "rustfmt"
      ];
      targets = [
        "aarch64-apple-darwin"
        "x86_64-unknown-linux-gnu"
        "aarch64-unknown-linux-gnu"
        "wasm32-unknown-unknown"
      ];
    })
  ];
}
