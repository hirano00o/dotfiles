{
  pkgs,
  pkgs-stable,
  llm-agents,
  hunk,
  arto,
}:
with pkgs;
[
  # Related vim
  tree-sitter
  lazydocker
  pinentry_mac
  lua54Packages.lua

  # LSP/dev
  bash-language-server
  biome
  buf
  docker-language-server
  golangci-lint-langserver
  gopls
  graphql-language-service-cli
  jinja-lsp
  lua-language-server
  nixd
  protobuf-language-server
  pyrefly
  terraform-ls
  tflint
  textlsp
  typescript-language-server
  yaml-language-server
  vscode-langservers-extracted # HTML/CSS/JSON/ESLint
  typescript-go

  # DB
  mysql84
  sqlite
  duckdb

  # Go
  go
  gofumpt
  golangci-lint
  gotests

  # Misc
  git-filter-repo
  openssl
  zstd
  imagemagick
  ghostscript
  protobuf
  jq
  yq
  tree
  ripgrep
  wget
  ghq
  jujutsu
  evans
  xcodes
  terraform
  trivy
  pkgs-stable.deno
  python312
  google-cloud-sdk
  hunk.packages.${pkgs.system}.default
  envsubst

  presenterm
  mermaid-cli
  typst
  pandoc
  d2
  python313Packages.weasyprint

  marp-cli
  arto.packages.${pkgs.system}.default # markdown viewer

  markitdown-mcp
  drawio
  vhs
  shottr
  # Upstream test suite segfaults during the build check phase, so skip it.
  (md2pdf.overridePythonAttrs (_: {
    doCheck = false;
  }))

  llm-agents.packages.${stdenv.hostPlatform.system}.ccusage

  # Nix
  nix-output-monitor
  nixfmt

  sops
  age
]
++ lib.optionals stdenv.isDarwin [
  terminal-notifier
  raycast
]
