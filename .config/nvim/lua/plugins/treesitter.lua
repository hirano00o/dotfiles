return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      {
        "folke/ts-comments.nvim",
        event = "VeryLazy",
        enabled = vim.fn.has("nvim-0.10.0") == 1,
      },
    },
    event = "BufReadPost",
    build = ":TSUpdate",
    config = function()
      -- nvim-treesitter v2: bundled queriesをNeovimが検出できるようruntimepathに追加
      vim.opt.rtp:prepend(vim.fs.joinpath(
        vim.fn.stdpath('data') --[[@as string]], 'lazy', 'nvim-treesitter', 'runtime'
      ))
      require('nvim-treesitter').install({
        "lua", "vim", "vimdoc", "query", "sql",
        "markdown", "markdown_inline", "yaml", "json", "toml",
        "go", "typescript", "tsx", "javascript", "python", "bash",
        "html", "css", "csv", "tsv", "diff",
        "dockerfile", "editorconfig", "graphql", "hcl", "helm",
        "http", "jq", "mermaid", "nginx", "nix", "proto", "tmux",
      })
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          pcall(vim.treesitter.start, ev.buf)
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {},
  },
}
