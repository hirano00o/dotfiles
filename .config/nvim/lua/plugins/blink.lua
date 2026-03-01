return {
  "saghen/blink.cmp",
  version = "*",
  opts = {
    keymap = {
      preset = "super-tab",
    },
    completion = {
      list = {
        selection = {
          preselect = false,
          auto_insert = true,
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
      },
      ghost_text = {
        enabled = true,
      },
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
    },
  },
  opts_extend = { "sources.default" },
}
