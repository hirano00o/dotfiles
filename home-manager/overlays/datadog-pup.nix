# datadog-labs/pup はnixpkgs未収録のため手動定義
# https://github.com/datadog-labs/pup
final: prev:
let
  version = "0.52.0";
  selectAsset =
    if prev.stdenv.isDarwin && prev.stdenv.isAarch64 then
      {
        suffix = "Darwin_arm64";
        hash = "sha256-bgL8eE6+Jaz1h6H7QbJqxRUnUQmrApIjHA+dfYnNpYA=";
      }
    else if prev.stdenv.isDarwin && prev.stdenv.isx86_64 then
      {
        suffix = "Darwin_x86_64";
        hash = "sha256-c5jabz5FwuINvTr751nGkXoRwHlxlPRgCMkKb8Gzyp8=";
      }
    else
      throw "datadog-pup: unsupported system ${prev.stdenv.hostPlatform.system}";
in
{
  datadog-pup = prev.stdenvNoCC.mkDerivation {
    pname = "datadog-pup";
    inherit version;

    src = prev.fetchurl {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_${selectAsset.suffix}.tar.gz";
      hash = selectAsset.hash;
    };

    sourceRoot = ".";
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 pup $out/bin/pup
      runHook postInstall
    '';

    meta = {
      description = "Datadog AI-agent-ready CLI with 325+ commands across 57 Datadog product domains";
      homepage = "https://github.com/datadog-labs/pup";
      license = prev.lib.licenses.asl20;
      mainProgram = "pup";
      platforms = prev.lib.platforms.darwin;
    };
  };
}
