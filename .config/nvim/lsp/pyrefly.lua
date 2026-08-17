return {
  -- import root は :PyreflySourceRoot {dir} で追加し、.nvim.luaに保存される。
  settings = {
    python = { pyrefly = { extraPaths = {} } },
  },
  before_init = function(_, config)
    config.settings.python.pyrefly.extraPaths = vim.g.pyrefly_extra_paths or {}
  end,
}
