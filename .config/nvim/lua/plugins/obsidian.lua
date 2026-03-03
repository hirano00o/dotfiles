return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "saghen/blink.cmp",
      "nvim-telescope/telescope.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = function()
      vim.opt.conceallevel = 1
      return {
        ui = {
          enable = false,
        },
        workspaces = {
          {
            name = "work",
            path = "~/vaults/work",
          },
          {
            name = "private",
            path = "~/vaults/private",
          },
        },
        daily_notes = {
          folder = "daily_report",
          date_format = "%Y-%m-%d",
          template = "daily_report.md",
        },
        disable_frontmatter = true,
        templates = {
          folder = "templates",
          date_format = "%Y-%m-%d",
          time_format = "%H:%M:%S",
        },
        follow_url_func = function(url)
          vim.ui.open(url)
        end
      }
    end,
  },
  {
    "hirano00o/obsidian-thino.nvim",
    dependencies = {
      "epwalsh/obsidian.nvim",
    },
    opts = {
      time_format = "%H:%M:%S",
    },
  },
}
