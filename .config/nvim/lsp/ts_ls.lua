return {
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json" },
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
