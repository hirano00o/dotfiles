{
  pkgs,
  pkgs-stable,
  llm-agents,
  hunk,
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
  pyright
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
  slack
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

  presenterm
  mermaid-cli
  typst
  pandoc
  d2
  python313Packages.weasyprint

  marp-cli

  markitdown-mcp
  drawio
  vhs
  shottr

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
