# Arto (Markdown ビューア) を導入し、Markdown ファイルの既定アプリにする
{
  pkgs,
  lib,
  arto,
  ...
}:
{
  home.packages = [ arto.packages.${pkgs.stdenv.hostPlatform.system}.default ];

  # LaunchServices の関連付けを宣言するオプションが nix-darwin / home-manager に無いため duti で設定する
  home.activation.setArtoAsMarkdownHandler = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
    lib.hm.dag.entryAfter [ "writeBoundary" "copyApps" ] ''
      run ${pkgs.duti}/bin/duti -s com.lambdalisue.Arto net.daringfireball.markdown all
    ''
  );
}
