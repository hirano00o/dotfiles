{ ... }:
{
  environment.variables = {
    EDITOR = "nvim";
  };

  # `darwin manual html` のエラーが出るためfalseに設定
  # nix-darwin側が修正されたら戻す
  documentation.doc.enable = false;
  system.tools.darwin-uninstaller.enable = false;
}
