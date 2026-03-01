return {
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
}
