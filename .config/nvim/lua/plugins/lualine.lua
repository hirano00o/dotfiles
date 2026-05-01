return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    sections = {
      lualine_c = {
        {
          function()
            return '%{%v:lua._G.dropbar_lualine()%}'
          end,
        },
      },
    },
  },
}
