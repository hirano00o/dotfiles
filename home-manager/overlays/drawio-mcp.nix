# drawio-mcpはnixpkgs未収録のため手動定義
# https://github.com/jgraph/drawio-mcp/tree/main/mcp-tool-server
# npmパッケージ: @drawio/mcp
final: prev: {
  drawio-mcp = prev.buildNpmPackage {
    pname = "drawio-mcp";
    version = "1.1.8";
    src = prev.fetchFromGitHub {
      owner = "jgraph";
      repo = "drawio-mcp";
      rev = "173ad981cf1f273e49e4c7db08f5485f7b10a2f5";
      hash = "sha256-Px0IgByowmHod5OwwxH+QPzASC3Pi70fak6nOUUpReY=";
    };
    sourceRoot = "source/mcp-tool-server";
    npmDepsHash = "sha256-ufgxe7zCTUU06IROtrTd5+lrqXHaNNqip8Oe/ZQsZ6Q=";
    dontNpmBuild = true;
    meta = {
      description = "Official draw.io MCP server for LLMs - Open diagrams in draw.io editor";
      homepage = "https://github.com/jgraph/drawio-mcp";
      license = prev.lib.licenses.asl20;
      mainProgram = "drawio-mcp";
    };
  };
}
