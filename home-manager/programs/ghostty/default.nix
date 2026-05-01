{
  pkgs,
  ...
}:
{
  programs.ghostty = {
    enable = true;

    package =
      if pkgs.stdenv.isLinux then
        pkgs.ghostty
      else if pkgs.stdenv.isDarwin then
        pkgs.ghostty-bin
      else
        throw "unsupported system ${pkgs.stdenv.hostPlatform.system}";

    enableZshIntegration = true;
    settings = {
      theme = "Monokai Pro Spectrum";
      font-feature = [
        "-calt"
        "-dlig"
        "-liga"
      ];
      font-size = 15;
      keybind = [
        "shift+enter=text:\n"
        "shift+cmd+w=close_window"
        "cmd+w=unbind"
        "cmd+n=unbind"

        # goto tab
        "cmd+1=unbind"
        "cmd+2=unbind"
        "cmd+3=unbind"
        "cmd+4=unbind"
        "cmd+5=unbind"
        "cmd+6=unbind"
        "cmd+7=unbind"
        "cmd+8=unbind"
        "cmd+9=unbind"
        "cmd+0=unbind"

        "cmd+digit_1=unbind"
        "cmd+digit_2=unbind"
        "cmd+digit_3=unbind"
        "cmd+digit_4=unbind"
        "cmd+digit_5=unbind"
        "cmd+digit_6=unbind"
        "cmd+digit_7=unbind"
        "cmd+digit_8=unbind"
        "cmd+digit_9=unbind"
        "cmd+digit_0=unbind"
      ];
      window-padding-balance = true;
      macos-titlebar-style = "transparent";
      window-padding-x = 0;
      window-padding-y = 0;
      window-theme = "ghostty";
      background-opacity = 0.8;
      shell-integration-features = "no-cursor, sudo, ssh-env";
    };
  };
}
