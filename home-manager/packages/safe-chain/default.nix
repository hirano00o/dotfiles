{ pkgs, ... }:
let
  pname = "safe-chain";
  version = "1.4.2";

  arch = if pkgs.stdenv.isAarch64 then "arm64" else "x64";

  src = pkgs.fetchurl {
    url = "https://github.com/AikidoSec/safe-chain/releases/download/${version}/safe-chain-macos-${arch}";
    hash = "sha256-Q2AMev3+0QVuC3l4fPo8/K59nuxXGFUEujW9zyc+paY=";
  };
in
pkgs.stdenv.mkDerivation {
  inherit pname version src;

  dontUnpack = true;
  dontStrip = true;

  meta = with pkgs.lib; {
    description = "Aikido Safe Chain - Protects against malicious code in package installations";
    homepage = "https://github.com/AikidoSec/safe-chain";
    license = licenses.agpl3Only;
    platforms = platforms.darwin;
    maintainers = [ ];
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp $src $out/bin/safe-chain
    chmod +x $out/bin/safe-chain

    runHook postInstall
  '';
}
