return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    {
      "tree-sitter-grammars/tree-sitter-markdown",
    },
  },
  ft = "markdown",
  opts = {
    completions = {
      lsp = {
        enabled = true,
      },
    },
    render_modes = { "n", "c", "i" },
    inline_highlight = {
      enable = true,
    },
    code = {
      disable_background = { "mermaid" },
    },
  },
}
