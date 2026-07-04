{
  config,
  pkgs,
  lib,
  ...
}:
{
  # 週次で dotfiles の flake.lock を更新する (土曜 09:00)。
  # コミットはしない — 差分は Renovate / 手動レビューで確認してから取り込む。
  launchd.agents.dotfiles-flake-update = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    enable = true;
    config = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        ''
          cd ${config.home.homeDirectory}/ws/repo/github.com/hirano00o/dotfiles \
            && /run/current-system/sw/bin/nix flake update \
            && /usr/bin/osascript -e 'display notification "flake.lock updated. Review and commit." with title "dotfiles"'
        ''
      ];
      StartCalendarInterval = [
        {
          Weekday = 6;
          Hour = 9;
          Minute = 0;
        }
      ];
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/dotfiles-flake-update.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/dotfiles-flake-update.err.log";
    };
  };
}
