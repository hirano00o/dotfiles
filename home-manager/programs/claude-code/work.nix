{ lib, ... }:
{
  programs.claude-code = {
    settings = {
      env = {
        NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";
        CLAUDE_CODE_EFFORT_LEVEL = lib.mkForce "medium";
      };
      model = lib.mkForce "opusplan";
    };
    mcpServers = {
      datadog-dev = {
        type = "http";
        url = "https://mcp.datadoghq.com/api/unstable/mcp-server/mcp?toolsets=core,dashboards,apm,error-tracking&account=dev";
      };
      datadog-prd = {
        type = "http";
        url = "https://mcp.datadoghq.com/api/unstable/mcp-server/mcp?toolsets=core,dashboards,apm,error-tracking&account=prd";
      };
    };
  };
}
