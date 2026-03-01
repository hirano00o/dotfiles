-- Need Lua 5.1 and LuaRocks
--
-- Install guide
-- curl -fsSLO https://www.lua.org/ftp/lua-5.1.5.tar.gz && tar zxf lua-5.1.5.tar.gz && cd lua-5.1.5
-- make macosx
-- sudo make install
-- cd ../ && rm -rf lua-5.1.5 lua-5.1.5.tar.gz
-- curl -fsSLO https://luarocks.org/releases/luarocks-3.12.2.tar.gz
-- tar zxpf luarocks-3.12.2.tar.gz
-- cd luarocks-3.12.2
-- ./configure && make && sudo make install
-- sudo luarocks install luasocket

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = {
    enabled = true,
    notify = false,
    frequency = 86400, -- 24時間に1回のみチェック
  },
  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
