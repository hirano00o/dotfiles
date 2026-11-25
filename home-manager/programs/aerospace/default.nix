{ ... }:
{
  programs.aerospace = {
    enable = true;

    launchd.enable = true;

    settings = {
      gaps = {
        inner.horizontal = 8;
        inner.vertical = 8;
        outer.left = 8;
        outer.right = 8;
        outer.top = 8;
        outer.bottom = 8;
      };

      mode.main.binding = {
        # レイアウト
        alt-slash = "layout tiles horizontal vertical";
        alt-comma = "layout accordion horizontal vertical";
        alt-f = "fullscreen";
        alt-shift-f = "layout floating tiling";

        # フォーカス移動
        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";

        # ウィンドウ移動
        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";

        # リサイズ
        alt-minus = "resize smart -50";
        alt-equal = "resize smart +50";

        # ワークスペース切替
        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-8 = "workspace 8";
        alt-9 = "workspace 9";
        alt-a = "workspace A";
        alt-b = "workspace B";
        alt-c = "workspace C";
        alt-d = "workspace D";
        alt-e = "workspace E";

        alt-shift-1 = [
          "move-node-to-workspace 1"
          "workspace 1"
        ];
        alt-shift-2 = [
          "move-node-to-workspace 2"
          "workspace 2"
        ];
        alt-shift-3 = [
          "move-node-to-workspace 3"
          "workspace 3"
        ];
        alt-shift-4 = [
          "move-node-to-workspace 4"
          "workspace 4"
        ];
        alt-shift-5 = [
          "move-node-to-workspace 5"
          "workspace 5"
        ];
        alt-shift-6 = [
          "move-node-to-workspace 6"
          "workspace 6"
        ];
        alt-shift-7 = [
          "move-node-to-workspace 7"
          "workspace 7"
        ];
        alt-shift-8 = [
          "move-node-to-workspace 8"
          "workspace 8"
        ];
        alt-shift-9 = [
          "move-node-to-workspace 9"
          "workspace 9"
        ];
        alt-shift-a = [
          "move-node-to-workspace A"
          "workspace A"
        ];
        alt-shift-b = [
          "move-node-to-workspace B"
          "workspace B"
        ];
        alt-shift-c = [
          "move-node-to-workspace C"
          "workspace C"
        ];
        alt-shift-d = [
          "move-node-to-workspace D"
          "workspace D"
        ];
        alt-shift-e = [
          "move-node-to-workspace E"
          "workspace E"
        ];

        alt-tab = "workspace-back-and-forth";
        alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

        alt-shift-semicolon = "mode service";
      };

      mode.service.binding = {
        esc = [
          "reload-config"
          "mode main"
        ];
        r = [
          "flatten-workspace-tree"
          "mode main"
        ];
        f = [
          "layout floating tiling"
          "mode main"
        ];
        backspace = [
          "close-all-windows-but-current"
          "mode main"
        ];

        alt-shift-h = [
          "join-with left"
          "mode main"
        ];
        alt-shift-j = [
          "join-with down"
          "mode main"
        ];
        alt-shift-k = [
          "join-with up"
          "mode main"
        ];
        alt-shift-l = [
          "join-with right"
          "mode main"
        ];
      };

      on-window-detected = [
        {
          "if".app-id = "com.apple.systempreferences";
          run = "layout floating";
        }
        {
          "if".app-id = "com.apple.finder";
          run = "layout floating";
        }
        {
          "if".app-id = "com.apple.calculator";
          run = "layout floating";
        }
        {
          "if".app-id = "org.pqrs.Karabiner-Elements.Settings";
          run = "layout floating";
        }
        {
          "if".app-id = "cc.ffitch.shottr";
          run = "layout floating";
        }
        {
          "if".app-id = "com.bitwarden.desktop";
          run = "layout floating";
        }
        {
          "if".app-id = "com.1password.1password";
          run = "layout floating";
        }

        # 1: コミュニケーション
        {
          "if".app-id = "com.tinyspeck.slackmacgap";
          run = "move-node-to-workspace 1";
        }
        {
          "if".app-id = "com.hnc.Discord";
          run = "move-node-to-workspace 1";
        }
        {
          "if".app-id = "jp.naver.line.mac";
          run = "move-node-to-workspace 1";
        }
        {
          "if".app-id = "us.zoom.xos";
          run = "move-node-to-workspace 1";
        }

        # 2: ブラウザ
        {
          "if".app-id = "com.google.Chrome";
          run = "move-node-to-workspace 2";
        }
        {
          "if".app-id = "org.mozilla.firefox";
          run = "move-node-to-workspace 2";
        }
        {
          "if".app-id = "com.apple.Safari";
          run = "move-node-to-workspace 2";
        }

        # 3: AI
        {
          "if".app-id = "com.anthropic.claudefordesktop";
          run = "move-node-to-workspace 3";
        }

        # 4: ドキュメント
        {
          "if".app-id = "md.obsidian";
          run = "move-node-to-workspace 4";
        }
        {
          "if".app-id = "com.jgraph.drawio.desktop";
          run = "move-node-to-workspace 4";
        }

        # 7: インフラ/リモート
        {
          "if".app-id = "dev.kdrag0n.MacVirt";
          run = "move-node-to-workspace 7";
        }
        {
          "if".app-id = "com.docker.docker";
          run = "move-node-to-workspace 7";
        }
        {
          "if".app-id = "com.realvnc.vncviewer";
          run = "move-node-to-workspace 7";
        }

        # A: ターミナル, markdown viewer
        {
          "if".app-id = "com.mitchellh.ghostty";
          run = "move-node-to-workspace A";
        }
        {
          "if".app-id = "com.lambdalisue.Arto";
          run = "move-node-to-workspace A";
        }
      ];

      workspace-to-monitor-force-assignment = {
        "1" = "main";
        "2" = "main";
        "3" = "main";
        "4" = "main";
        "5" = "main";
        "6" = "main";
        "7" = "main";
        "8" = "main";
        "9" = "main";
        "A" = [
          "secondary"
          "2"
        ];
        "B" = "secondary";
        "C" = "secondary";
        "D" = "secondary";
        "E" = "secondary";
      };
    };
  };
}
