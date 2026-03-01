# markitdown-mcpはnixpkgs-unstable (aarch64-darwin) 未収録のため手動定義
# https://pypi.org/project/markitdown-mcp/
# TODO: nixpkgsに収録された際はこのファイルを削除してbasic.nixのpkgs.markitdown-mcpをそのまま利用する
final: prev: {
  markitdown-mcp = prev.python3Packages.buildPythonApplication {
    pname = "markitdown-mcp";
    version = "0.0.1a4";
    pyproject = true;
    src = prev.fetchPypi {
      pname = "markitdown_mcp";
      version = "0.0.1a4";
      hash = "sha256-MJyU3IgzEeaQnYSTgqbHvEAt+yaS2rRIwTbGhkxr9J4=";
    };
    build-system = [ prev.python3Packages.hatchling ];
    dependencies = with prev.python3Packages; [
      markitdown
      mcp
    ];
    # mcp ~= 1.8.0 の制約に対して nixpkgs の mcp 1.26.0 が非準拠と判定されるため
    # pythonRelaxDepsHook で mcp のバージョン制約を緩和する
    nativeBuildInputs = [ prev.python3Packages.pythonRelaxDepsHook ];
    pythonRelaxDeps = [ "mcp" ];
    meta = {
      description = "A lightweight STDIO, Streamable HTTP, and SSE MCP server for calling MarkItDown";
      homepage = "https://github.com/microsoft/markitdown";
      mainProgram = "markitdown-mcp";
    };
  };
}
