{ lib, ... }:
{
  programs.claude-code = {
    settings = {
      env = {
        NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";
      };
      effortLevel = lib.mkForce "medium";
      model = lib.mkForce "opusplan";
    };
    mcpServers = {
      datadog-dev = {
        type = "http";
        url = "https://mcp.datadoghq.com/v1/mcp?toolsets=core,dashboards,apm,error-tracking&account=dev";
      };
      datadog-prd = {
        type = "http";
        url = "https://mcp.datadoghq.com/v1/mcp?toolsets=core,dashboards,apm,error-tracking&account=prd";
      };
      cloudwatch-logs = {
        command = "uvx";
        args = [ "awslabs.cloudwatch-mcp-server@2026.09.20260922000649" ];
        env = {
          FASTMCP_LOG_LEVEL = "ERROR";
        };
        transportType = "stdio";
      };
    };
  };
}
