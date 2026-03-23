{
  config,
  pkgs,
  mcp-servers-nix,
  llm-agents,
  gatehook,
  ...
}:
let
  drawio-skill = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/jgraph/drawio-mcp/15ce87fe3fe9ea87f79f2e80f0efd0ff40367249/skill-cli/SKILL.md";
    sha256 = "sha256-mO102njzsU+FKaZuZQ1YcwNA6SwcBI+tXcPj81Y2PSk=";
  };

  gatehook-pkg = gatehook.packages.${pkgs.stdenv.hostPlatform.system}.default;

  gatehook-rules = {
    rules = [ ];
  };

  rulesJson = pkgs.writeText "pretooluse-rules.json" (builtins.toJSON gatehook-rules);
in
{
  home.file = {
    ".claude/scripts/statusline.sh" = {
      source = ./scripts/statusline.sh;
      executable = true;
    };
    ".claude/scripts/notify.sh" = {
      source = ./scripts/notify.sh;
      executable = true;
    };
    ".claude/scripts/posttooluse-lint.sh" = {
      source = ./scripts/posttooluse-lint.sh;
      executable = true;
    };
    ".claude/scripts/gatehook-rules.json".source = rulesJson;
  };
  programs.claude-code = {
    enable = true;
    package = llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
    memory.source = ./CLAUDE.md;
    settings = {
      model = "opusplan";
      theme = "dark";
      language = "japanese";
      autoUpdates = false;
      includeCoAuthoredBy = false;
      enableAllProjectMcpServers = true;
      alwaysThinkingEnabled = true;
      env = {
        CLAUDE_CODE_ENABLE_TELEMETRY = "0";
        DISABLE_COST_WARNINGS = "0";
        BASH_DEFAULT_TIMEOUT_MS = "300000";
        BASH_MAX_TIMEOUT_MS = "1200000";
        CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
        ENABLE_TOOL_SEARCH = "true";
        DISABLE_NON_ESSENTIAL_MODEL_CALLS = "1";
        CLAUDE_CODE_HIDE_ACCOUNT_INFO = "1";
      };
      permissions = {
        allow = [
          "List(*)"
          "WebSearch"
          "Bash(ls:*)"
          "Bash(rg:*)"
          "Bash(grep:*)"
          "Bash(make:*)"
          "Bash(mkdir:*)"
          "Bash(cp:*)"
          "Bash(find:*)"
          "Bash(cat:*)"
          "Bash(bat:*)"
          "Bash(head:*)"
          "Bash(tail:*)"
          "Bash(less:*)"
          "Bash(more:*)"
          "Bash(wc:*)"
          "Bash(sort:*)"
          "Bash(uniq:*)"
          "Bash(tar:*)"
          "Bash(gzip:*)"
          "Bash(zip:*)"
          "Bash(unzip:*)"
          "Bash(ps:*)"
          "Bash(top:*)"
          "Bash(which:*)"
          "Bash(whoami:*)"
          "Bash(pwd:*)"
          "Bash(df:*)"
          "Bash(date:*)"
          "Bash(echo:*)"
          "Bash(touch:*)"
          "Bash(lsof:*)"
          "Bash(diff:*)"
          "Bash(docker ps:*)"
          "Bash(docker build:*)"
          "Bash(docker run:*)"
          "Bash(docker logs:*)"
          "Bash(docker images:*)"
          "Bash(docker pull:*)"
          "Bash(docker stop:*)"
          "Bash(docker rm:*)"
          "Bash(docker rmi:*)"
          "Bash(docker inspect:*)"
          "Bash(docker compose:*)"
          "Bash(go test:*)"
          "Bash(go build:*)"
          "Bash(go fmt:*)"
          "Bash(gofmt:*)"
          "Bash(gh pr list:*)"
          "Bash(gh pr view:*)"
          "Bash(gh pr diff:*)"
          "Bash(git add:*)"
          "Bash(git pull:*)"
          "Bash(git checkout:*)"
          "Bash(git reset:*)"
          "Bash(nix search:*)"
          "Bash(nix hash:*)"
          "Bash(nix flake:*)"
          "Bash(nix derivation show:*)"
          "Bash(nix log:*)"
          "Bash(nix --version:*)"
          "Bash(nix-build:*)"
          "Bash(nix-prefetch-url:*)"
          "Bash(nix-collect-garbage:*)"
          "Bash(readlink:*)"
          "Bash(jq:*)"
          "Bash(yq:*)"
          "WebFetch(domain:api.github.com)"
          "WebFetch(domain:github.com)"
          "WebFetch(domain:gist.github.com)"
          "WebFetch(domain:docs.anthropic.com)"
          "Read(**/.env.example)"
          "Read(**/.env.sample)"
          "Write(**/.env.example)"
          "Write(**/.env.sample)"
          "Write(/private/tmp)"
          "mcp__serena"
          "mcp__filesystem"
          "mcp__fetch"
          "mcp__context7"
          "mcp__deepwiki"
          "mcp__playwright"
          "mcp__sequential-thinking"
          "mcp__terraform"
          "mcp__markitdown"
        ];
        deny = [
          "Bash(* .env*)"
          "Bash(* ~/.aws/*)"
          "Bash(* ~/.config/gh/*)"
          "Bash(* ~/.config/git/*)"
          "Bash(* ~/.netrc)"
          "Bash(* ~/.ssh/*)"
          "Bash(* ~/.pypirc)"
          "Bash(* ~/.cloudflared/*)"
          "Bash(* ~/.config/sops/*)"
          "Bash(* ~/.config/sops-nix/*)"
          "Bash(rm -rf *)"
          "Bash(rm -rf:*)"
          "Bash(rmdir *)"
          "Bash(for)"
          "Bash(do)"
          "Bash(gh repo delete:*)"
          "Bash(security *)"
          "Bash(ssh *)"
          "Bash(telnet *)"
          "Bash(su *)"
          "Bash(sudo *)"
          "Bash(sudo:*)"
          "Bash(chmod 777:*)"
          "Bash(chmod -R 777 /*)"
          "Bash(chown root:*)"
          "Bash(mysql:*)"
          "Bash(psql:*)"
          "Bash(mongosh:*)"
          "Bash(su *)"
          "Bash(dd:*)"
          "Bash(mkfs:*)"
          "Bash(fdisk:*)"
          "Bash(> /dev/*)"
          "Bash(>> /dev/*)"
          "Bash(npm publish:*)"
          "Bash(deno publish:*)"
          "Bash(sed -i:*)"
          "Bash(awk -i:*)"
          "Edit(/etc/**)"
          "Edit(/usr/**)"
          "Edit(/var/**)"
          "Edit(/opt/**)"
          "Edit(/bin/**)"
          "Edit(/sbin/**)"
          "Edit(/lib/**)"
          "Edit(/lib64/**)"
          "Edit(/boot/**)"
          "Edit(/proc/**)"
          "Edit(/sys/**)"
          "Edit(/dev/**)"
          "Edit(~/.ssh/*)"
          "Edit(./.env)"
          "Edit(./.env.*)"
          "Write(**/*.env*)"
          "Write(**/*aws*)"
          "Write(**/*key)"
          "Write(**/*secrets*)"
          "Write(**/*token*)"
          "Write(./.env)"
          "Write(./.env.*)"
          "Read(**/*.env*)"
          "Read(**/*aws*)"
          "Read(**/*key)"
          "Read(**/*secrets*)"
          "Read(**/*token*)"
          "Read(./.env)"
          "Read(./.env.*)"
          "Read(~/.aws/**)"
          "Read(~/.config/gh/**)"
          "Read(~/.config/git/**)"
          "Read(~/.netrc)"
          "Read(~/.npmrc)"
          "Read(~/.pypirc)"
          "Read(~/.ssh/**)"
          "Read(~/.cloudflared/**)"
          "Read(~/.config/sops/**)"
          "Read(~/.config/sops-nix/**)"
        ];
        ask = [
          "Bash(git push:*)"
          "Bash(git config:*)"
          "Bash(git rm:*)"
        ];
      };
      hooks = {
        PreToolUse = [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "${gatehook-pkg}/bin/gatehook --config ${config.home.homeDirectory}/.claude/scripts/gatehook-rules.json";
              }
            ];
          }
        ];
        PostToolUse = [
          {
            matcher = "Edit|Write";
            hooks = [
              {
                type = "command";
                command = "${config.home.homeDirectory}/.claude/scripts/posttooluse-lint.sh";
              }
            ];
          }
        ];
        Stop = [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "${config.home.homeDirectory}/.claude/scripts/notify.sh \"Finished\" 'Claude Code'";
              }
            ];
          }
        ];
        Notification = [
          {
            hooks = [
              {
                type = "command";
                command = "${config.home.homeDirectory}/.claude/scripts/notify.sh \"$(jq -r '.message')\" 'Claude Code'";
              }
            ];
          }
        ];
      };
      statusLine = {
        type = "command";
        command = "~/.claude/scripts/statusline.sh";
        padding = 0;
      };
      enabledPlugins = {
        # https://github.com/anthropics/claude-plugins-official
        "agent-sdk-dev@claude-code-plugins" = true;
        "feature-dev@claude-code-plugins" = true;
        "frontend-design@claude-code-plugins" = true;
        "pr-review-toolkit@claude-code-plugins" = true;
        "ralph-wiggum@claude-code-plugins" = true;
        "security-guidance@claude-code-plugins" = true;
      };
    };
    skills = {
      handover = ./skills/handover/SKILL.md;
    };
    mcpServers =
      (mcp-servers-nix.lib.evalModule pkgs {
        programs = {
          filesystem.enable = true;
          fetch.enable = true;
          context7.enable = true;
          playwright.enable = true;
          terraform.enable = true;
          sequential-thinking.enable = true;
          serena = {
            enable = true;
            context = "claude-code";
            enableWebDashboard = false;
          };
          github = {
            enable = true;
            envFile = "${config.home.homeDirectory}/.claude/.github.token";
          };
        };
      }).config.settings.servers
      // {
        deepwiki = {
          type = "http";
          url = "https://mcp.deepwiki.com/mcp";
        };
        markitdown = {
          type = "stdio";
          command = "markitdown-mcp";
        };
        drawio = {
          type = "http";
          url = "https://mcp.draw.io/mcp";
        };
      };
  };
  home.file = {
    "${config.home.homeDirectory}/.claude/skills/drawio/SKILL.md".source = drawio-skill;
  };
}
