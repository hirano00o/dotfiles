{ config, lib, ... }:
let
  # Codex は未知のキー (type / headers / transportType) を拒否するため、
  # claude-code の mcpServers から Codex が解釈できるキーだけを取り出す。
  toCodexServer =
    server:
    if server ? url then
      { inherit (server) url; }
    else
      {
        inherit (server) command;
      }
      // lib.getAttrs (builtins.filter (k: server ? ${k}) [
        "args"
        "env"
      ]) server;

  # serena は Codex 用の context を持つ。
  serenaForCodex =
    server: server // { args = map (a: if a == "claude-code" then "codex" else a) server.args; };

  mcpServers = lib.mapAttrs (
    name: server: toCodexServer (if name == "serena" then serenaForCodex server else server)
  ) config.programs.claude-code.mcpServers;

  skillsDir = ../claude-code/skills;
in
{
  programs.codex = {
    enable = true;
    context = ../agents/AGENTS.md;
    settings.mcp_servers = mcpServers;
    # develop は impl サブエージェントと TodoWrite に依存するため除外
    # aws-diagram は ~/.claude 配下の plugin を参照するため除外
    skills = {
      ship = skillsDir + "/ship/SKILL.md";
      tdd-cycle = skillsDir + "/tdd-cycle/SKILL.md";
      review-checklist = skillsDir + "/review-checklist/SKILL.md";
      lang-go = skillsDir + "/lang-go/SKILL.md";
      lang-typescript = skillsDir + "/lang-typescript/SKILL.md";
      lang-python = skillsDir + "/lang-python/SKILL.md";
      lang-rust = skillsDir + "/lang-rust/SKILL.md";
    };
  };
}
