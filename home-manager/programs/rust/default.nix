{ pkgs, ... }:
{
  imports = [
    ./rust-analyzer.nix
  ];

  home.packages = with pkgs; [
    (rust-bin.stable.latest.default.override {
      extensions = [
        "rust-src" # rust-analyzer Diagnostics 用のソースコード
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
