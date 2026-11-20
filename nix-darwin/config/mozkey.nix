{ pkgs }:
let
  version = "1.1.0";
  pkg = pkgs.fetchurl {
    url = "https://github.com/koyasi777/mozkey/releases/download/v${version}/Mozkey_v${version}_macos_universal.pkg";
    hash = "sha256-Zfx2P2sdIEmQMKGr70Nc6H05fO4hW1jk09B5YfPvk8s=";
  };
  infoPlist = "/Library/Input Methods/Mozc.app/Contents/Info.plist";
in
{
  # LaunchAgent が /Library/Input Methods/Mozc.app を絶対パスで参照するため、
  # Nix store に置いたり home-manager から入れたりはできず、pkg をそのまま installer に渡す。
  # pkg の receipt はアプリの更新を保証しないため、実体の Info.plist でバージョンを比較する。
  # 入力ソースの有効化は、インストール前から続くセッションでは TISEnableInputSource が
  # 成功を返しても反映されないため、ログインし直してから手動で行う。
  system.activationScripts.postActivation.text = ''
    if [ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' '${infoPlist}' 2>/dev/null)" != "${version}" ]; then
      echo "installing Mozkey ${version}..." >&2
      /usr/sbin/installer -pkg ${pkg} -target /
    fi
  '';
}
