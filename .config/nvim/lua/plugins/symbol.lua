return {
  {
    "bassamsdata/namu.nvim",
    opts = {
      global = {},
      namu_symbols = {
        options = {},
      },
    },
    vim.keymap.set("n", "<leader>ss", ":Namu symbols<cr>", {
      desc = "Jump to LSP symbol",
      silent = true,
    }),
    vim.keymap.set("n", "<leader>sw", ":Namu workspace<cr>", {
      desc = "LSP Symbols - Workspace",
      silent = true,
    })
  },
  {
    "kkoomen/vim-doge",
    opts = {},
    event = { "BufReadPost", "BufNewFile" },
    run = ":call doge#install()",
    config = function()
      vim.g.doge_doc_standard_python = "google"
    end,
  },
}
