return {
  {
    "romgrk/barbar.nvim",
    dependencies = {
      "lewis6991/gitsigns.nvim",
    },
    config = function()
      require("barbar").setup({
        -- aiboがタブに表示されるためターミナルを除外する
        auto_hide = false,
        exclude_ft = { "qf" },
        exclude_name = {},
        filter = function(buf)
          if not vim.api.nvim_buf_is_valid(buf) then
            return false
          end

          local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
          if buftype == "terminal" then
            return false
          end
          return true
        end,
      })
    end,
  },
  {
    'Bekaboo/dropbar.nvim',
    config = function()
      local dropbar_api = require('dropbar.api')
      vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
      vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
      vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
    end

  },
}
