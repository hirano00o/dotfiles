# aarch64-darwin サンドボックスで pythonImportsCheckPhase / pytestCheckPhase が
# SIGKILL (Killed: 9) される音声系 Python パッケージのテストフェーズを一括スキップする。
#
# 対象:
# - av (PyAV): pythonImportsCheck で巨大な ffmpeg-full ライブラリのロードに失敗
# - openai-whisper: installCheckPhase の test_audio が ffmpeg サブプロセス起動失敗
# - faster-whisper / speechrecognition / pydub / markitdown: 同種の SIGKILL を予防
# - pywebview: pyside6 → qtpositioning-6.11.x で cctools リンカが SIGTRAP クラッシュ
#   (macOS では Cocoa/WebKit バックエンドを使うため pyside6 / qtpy は不要)
#
# 注: 個別の overlay に分けると `python3Packages.override` の overrides が
# 後の overlay で上書きされて衝突するため、本ファイルに集約する。
# 上流が修正されたら本オーバーレイは削除可能。
final: prev:
prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
  python3Packages = prev.python3Packages.override {
    overrides = pyFinal: pyPrev: {
      av = pyPrev.av.overrideAttrs (old: {
        pythonImportsCheck = [ ];
        doInstallCheck = false;
      });
      openai-whisper = pyPrev.openai-whisper.overrideAttrs (old: {
        disabledTests = (old.disabledTests or [ ]) ++ [ "test_audio" ];
      });
      faster-whisper = pyPrev.faster-whisper.overrideAttrs (old: {
        pythonImportsCheck = [ ];
        doInstallCheck = false;
      });
      speechrecognition = pyPrev.speechrecognition.overrideAttrs (old: {
        pythonImportsCheck = [ ];
        doInstallCheck = false;
      });
      pydub = pyPrev.pydub.overrideAttrs (old: {
        pythonImportsCheck = [ ];
        doInstallCheck = false;
      });
      markitdown = pyPrev.markitdown.overrideAttrs (old: {
        pythonImportsCheck = [ ];
        doInstallCheck = false;
      });
      # qtpositioning-6.11.x のビルドで cctools リンカが SIGTRAP でクラッシュするため
      # pyside6 と qtpy を依存から除外する。macOS では pywebview は Cocoa/WebKit
      # バックエンドを使用するためこれらは実行時にも不要。
      pywebview = pyPrev.pywebview.overridePythonAttrs (old: {
        dependencies = prev.lib.filter (
          dep:
          !(prev.lib.elem (dep.pname or "") [
            "pyside6"
            "qtpy"
          ])
        ) (old.dependencies or [ ]);
      });
    };
  };
}
