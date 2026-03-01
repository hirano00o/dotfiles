return {
  "rainbowhxch/accelerated-jk.nvim",
  keys = {
    { "j", "<Plug>(accelerated_jk_gj)", mode = "n", desc = "Accelerated j" },
    { "k", "<Plug>(accelerated_jk_gk)", mode = "n", desc = "Accelerated k" },
  },
  config = function()
    require("accelerated-jk").setup({
      enable_deceleration = true,
      acceleration_limit = 100,
      acceleration_table = { 7, 12, 17, 21, 24, 26, 28, 30 },
      deceleration_table = { { 150, 9999 } },
      acceleration_motions = { "w", "b" },
    })
  end,
}
