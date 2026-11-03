return {
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json" },
  -- Formatting is delegated to biome/oxfmt when their config is detected
  -- (see lsp/biome.lua, lsp/oxfmt.lua); ts_ls should not compete for it.
  on_init = function(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
  settings = {
    typescript = {
      preferences = { preferTypeOnlyAutoImports = true },
      preferGoToSourceDefinition = true,
    },
    javascript = {
      preferGoToSourceDefinition = true,
    },
  },
}
