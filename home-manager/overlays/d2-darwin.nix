# d2 の buildInputs にある libgbm (mesa-libgbm) は libdrm に伝搬依存するが、
# libdrm は aarch64-darwin 非対応のため pkgs.d2 を参照するだけで評価が失敗する。
# d2 自体は meta.platforms に aarch64-darwin を含むため、Darwin では libgbm を
# emptyDirectory で差し替えて評価・ビルドできるようにする。
# 上流修正 (https://github.com/NixOS/nixpkgs/blob/HEAD/pkgs/by-name/d2/d2/package.nix)
# で libgbm を Linux 限定にする変更が取り込まれたら本オーバーレイは削除可能。
final: prev:
prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
  d2 = prev.d2.override {
    libgbm = prev.emptyDirectory;
  };
}
