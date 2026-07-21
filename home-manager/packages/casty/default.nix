# casty は nixpkgs 未収録で、上流に package-lock.json が無く buildNpmPackage も
# 使えないため、npm tarball と唯一の依存 ws を直接取得して node_modules を組み立てる。
# Chrome Headless Shell は casty 自身が初回実行時に ~/.casty/browsers/ へ取得する。
{ pkgs, ... }:
let
  pname = "casty";
  version = "1.2.2";
  wsVersion = "8.21.1";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@sanohiro/casty/-/casty-${version}.tgz";
    sha256 = "0zy4axvz5s2q7fmf7k5zahcvh92dhgddygva0xpmnr4yplmq672m";
  };

  ws = pkgs.fetchurl {
    url = "https://registry.npmjs.org/ws/-/ws-${wsVersion}.tgz";
    sha256 = "1h9f8zsaiqj30yy6lcqy94kg51g1bwbkckbkf9k78r0zp9c7w3xv";
  };
in
pkgs.stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = with pkgs; [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/casty/node_modules/ws $out/bin
    cp -R . $out/lib/casty
    tar xzf ${ws} --strip-components=1 -C $out/lib/casty/node_modules/ws

    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/casty \
      --add-flags "$out/lib/casty/bin/casty.js"

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "TTY web browser using raw CDP and Kitty graphics protocol";
    homepage = "https://github.com/sanohiro/casty";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "casty";
  };
}
