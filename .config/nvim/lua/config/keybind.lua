vim.keymap.set("i", "jj", "<ESC>", { silent = true })
vim.keymap.set("i", "っj", "<ESC>", { silent = true })
vim.keymap.set("n", "<ESC><ESC>", "<Cmd>noh<CR>", { silent = true })

-- タブ(buffer)の操作
vim.keymap.set("n", "<C-l>", "<Cmd>BufferNext<CR>", { desc = "Next to right tab" })
vim.keymap.set("n", "<C-h>", "<Cmd>BufferPrevious<CR>", { desc = "Next to left tab" })
vim.keymap.set("n", "<leader>w", "<Cmd>BufferClose<CR>", { desc = "Close tab" })
-- aiboがタブとして残らないように、ターミナルはバッファから除外
local term_augroup = vim.api.nvim_create_augroup('TerminalSettings', { clear = true })
vim.api.nvim_create_autocmd({ 'TermOpen', 'BufEnter' }, {
  group = term_augroup,
  pattern = 'term://*',
  callback = function(args)
    vim.bo[args.buf].buflisted = false
    vim.bo[args.buf].bufhidden = 'hide'
  end,
})

-- aibo(Claude Code)
vim.keymap.set("n", "<leader>ai", function()
  vim.cmd(string.format('Aibo -toggle -opener="botright %dvsplit" claude', math.floor(vim.o.columns * 1 / 3)))
  vim.defer_fn(function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) then
        local buftype = vim.api.nvim_get_option_value('buftype', { buf = buf })
        if buftype == 'terminal' then
          vim.bo[buf].buflisted = false
          vim.bo[buf].bufhidden = 'hide'
        end
      end
    end
  end, 100)
end, { desc = "Claude Code" })


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
