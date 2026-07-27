# 26.05-darwin の bitwarden-desktop 2026.5.0 は electron-39 経由で compiler-rt 18 を引き込み、
# SDK 26.4 の libcxx 21 (__builtin_ctzg) でビルド不能。修正版を含む pin した nixpkgs の
# 2026.7.0 (electron 新版・compiler-rt 18 非依存) に差し替える。legacyPackages を直接使う
# (import ... {config} で作り直すと drv が変わりバイナリキャッシュを外すため)。
{ nixpkgs-bitwarden }:
final: prev: {
  bitwarden-desktop =
    nixpkgs-bitwarden.legacyPackages.${prev.stdenv.hostPlatform.system}.bitwarden-desktop;
}
