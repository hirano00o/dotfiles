vim.keymap.set("i", "jj", "<ESC>", { silent = true })
vim.keymap.set("i", "っj", "<ESC>", { silent = true })
vim.keymap.set("n", "<ESC><ESC>", "<Cmd>noh<CR>", { silent = true })

-- タブ(buffer)の操作
vim.keymap.set("n", "<C-l>", "<Cmd>BufferNext<CR>", { desc = "Next to right tab" })
vim.keymap.set("n", "<C-h>", "<Cmd>BufferPrevious<CR>", { desc = "Next to left tab" })
vim.keymap.set("n", "<leader>w", "<Cmd>BufferClose<CR>", { desc = "Close tab" })
-- termがタブとして残らないように、ターミナルはバッファから除外
local term_augroup = vim.api.nvim_create_augroup('TerminalSettings', { clear = true })
vim.api.nvim_create_autocmd({ 'TermOpen', 'BufEnter' }, {
  group = term_augroup,
  pattern = 'term://*',
  callback = function(args)
    vim.bo[args.buf].buflisted = false
    vim.bo[args.buf].bufhidden = 'hide'
  end,
})

-- jsonをjqでフォーマット
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json" },
  callback = function()
    vim.api.nvim_set_option_value("formatprg", "jq", { scope = 'local' })
  end,
})

-- tests
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function(ev)
    local go_test = require("config.gotest")

    go_test.setup({
      gotests_bin = "gotests",
      template_dir = vim.fn.stdpath("config") .. "/templates/gotests",
    })

    go_test.setup_keymaps(ev.buf)
  end,
  desc = "Setup Go test functionality"
})
