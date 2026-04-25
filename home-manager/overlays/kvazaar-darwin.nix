# kvazaar 2.3.2 の test_rate_control が aarch64-darwin サンドボックス内で
# SIGKILL (Killed: 9) され、ffmpeg-full の依存解決時にビルドが失敗する。
# Darwin ではテストをスキップして回避する。
# 上流が修正されたら本オーバーレイは削除可能。
final: prev:
prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
  kvazaar = prev.kvazaar.overrideAttrs (old: {
    doCheck = false;
  });
}
