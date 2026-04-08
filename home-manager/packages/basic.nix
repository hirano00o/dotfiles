{ pkgs, llm-agents }:
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
  mysql80
  sqlite
  duckdb

  # Go
  go
  gofumpt
  golangci-lint
  gotests

  # Misc
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
  deno
  python312
  typescript
  google-cloud-sdk

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
  brewCasks.raycast
]
