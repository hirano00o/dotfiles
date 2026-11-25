vim.keymap.set("i", "jj", "<ESC>", { silent = true })
vim.keymap.set("i", "っj", "<ESC>", { silent = true })
vim.keymap.set("n", "<ESC><ESC>", "<Cmd>noh<CR>", { silent = true })

-- タブ(buffer)の操作
vim.keymap.set("n", "<C-l>", "<Cmd>BufferNext<CR>", { desc = "Next to right tab" })
vim.keymap.set("n", "<C-h>", "<Cmd>BufferPrevious<CR>", { desc = "Next to left tab" })
vim.keymap.set("n", "<leader>w", "<Cmd>BufferClose<CR>", { desc = "Close tab" })

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

-- yank
vim.keymap.set("v", "Y", '"+y', { desc = "Copy to OS clipboard" })

-- アンダースコア区切りをサブワードとして移動 (例: I_AM_A_BOY の各単語)
local function subword_motion(motion)
  return function()
    local iskw = vim.opt_local.iskeyword:get()
    vim.opt_local.iskeyword:remove("_")
    vim.cmd("normal! " .. vim.v.count1 .. motion)
    vim.opt_local.iskeyword = iskw
  end
end

vim.keymap.set({ "n", "x" }, "]w", subword_motion("w"), { desc = "Move to next sub-word" })
vim.keymap.set({ "n", "x" }, "[w", subword_motion("b"), { desc = "Move to previous sub-word" })
