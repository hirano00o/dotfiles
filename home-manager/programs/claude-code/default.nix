{
  config,
  pkgs,
  mcp-servers-nix,
  llm-agents,
  ...
}:
let
  drawio-skill = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/jgraph/drawio-mcp/15ce87fe3fe9ea87f79f2e80f0efd0ff40367249/skill-cli/SKILL.md";
    sha256 = "sha256-mO102njzsU+FKaZuZQ1YcwNA6SwcBI+tXcPj81Y2PSk=";
  };
in
{
  programs.claude-code = {
    enable = true;
    package = llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
    memory.source = ./CLAUDE.md;
    settings = {
      model = "opusplan";
      theme = "dark";
      autoUpdates = false;
      includeCoAuthoredBy = false;
      enableAllProjectMcpServers = true;
      alwaysThinkingEnabled = false;
      preferredNotifChannel = "terminal_bell";
      env = {
        CLAUDE_CODE_ENABLE_TELEMETRY = "0";
        DISABLE_COST_WARNINGS = "0";
        BASH_DEFAULT_TIMEOUT_MS = "300000";
        BASH_MAX_TIMEOUT_MS = "1200000";
        CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
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
          "Bash(rm -rf /*)"
          "Bash(rm -rf ~)"
          "Bash(rm -rf ~/)"
          "Bash(rm -rf /)"
          "Bash(sudo rm -:*)"
          "Bash(chmod 777 /*)"
          "Bash(chmod -R 777 /*)"
          "Bash(chown root:*)"
          "Bash(sudo chmod 777:*)"
          "Bash(sudo chown :*)"
          "Bash(sudo -i:*)"
          "Bash(sudo su:*)"
          "Bash(dd:*)"
          "Bash(mkfs:*)"
          "Bash(fdisk:*)"
          "Bash(> /dev/*)"
          "Bash(>> /dev/*)"
          "Bash(sudo dd:*)"
          "Bash(sudo mkfs:*)"
          "Bash(sudo fdisk:*)"
          "Bash(sudo mount:*)"
          "Bash(sudo umount:*)"
          "Bash(rm -rf .git)"
          "Bash(git push --force-with-lease origin main)"
          "Bash(git push --force-with-lease origin master)"
          "Bash(git push -f origin main)"
          "Bash(git push -f origin master)"
          "Bash(git push origin main)"
          "Bash(git push origin master)"
          "Bash(npm publish:*)"
          "Bash(deno publish:*)"
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
          "Bash(sed -i:*)"
          "Bash(awk -i:*)"
          "Write(/etc/**)"
          "Write(/usr/**)"
          "Write(/var/**)"
          "Write(/opt/**)"
          "Write(/bin/**)"
          "Write(/sbin/**)"
          "Write(/lib/**)"
          "Write(/lib64/**)"
          "Write(/boot/**)"
          "Write(/proc/**)"
          "Write(/sys/**)"
          "Write(/dev/**)"
          "Write(~/.ssh/*)"
        ];
      };
      hooks = {
        Notification = [
          {
            hooks = [
              {
                type = "command";
                command = "echo \"Claude Code: $(jq -r '.message')\" | terminal-notifier -title 'Claude Code'";
              }
            ];
          }
        ];
      };
      statusLine = {
        type = "command";
        command = "ccusage statusline --no-offline";
        padding = 0;
      };
      enabledPlugins = {
        # https://github.com/anthropics/claude-plugins-official
        "code-review@claude-code-plugins" = true;
        "agent-sdk-dev@claude-code-plugins" = true;
        "feature-dev@claude-code-plugins" = true;
        "frontend-design@claude-code-plugins" = true;
        "pr-review-toolkit@claude-code-plugins" = true;
        "ralph-wiggum@claude-code-plugins" = true;
        "security-guidance@claude-code-plugins" = true;
        # https://github.com/VoltAgent/awesome-claude-code-subagents
        "voltagent-core-dev@voltagent-subagents" = true;
        "voltagent-lang@voltagent-subagents" = true;
        "voltagent-infra@voltagent-subagents" = true;
        "voltagent-data-ai@voltagent-subagents" = true;
        "voltagent-dev-exp@voltagent-subagents" = true;
        "voltagent-meta@voltagent-subagents" = true;
        "voltagent-research@voltagent-subagents" = true;
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
