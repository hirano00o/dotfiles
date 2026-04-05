return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  cmd = "Telescope",
  keys = {
    { "<leader>/",  function() require("telescope.builtin").live_grep() end,                    desc = "Telescope live grep" },
    { "<leader>b",  "<cmd>Telescope buffers<cr>",                                               desc = "List buffers" },
    { "<S-S><S-S>", "<cmd>Telescope find_files<cr>",                                            desc = "Telescope find files" },
    { "<leader>ff", function() require("telescope").extensions.file_browser.file_browser() end, desc = "Telescope file browser" },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<C-c>"] = actions.close,
          },
          n = {
            ["<C-c>"] = actions.close,
          }
        }
      },
      pickers = {
        diagnostics = {
          theme = "ivy",
        },
        find_files = {
          hidden = true,
        }
      },
    })
  end
}
