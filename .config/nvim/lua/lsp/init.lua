vim.api.nvim_create_user_command("LspHealth", "checkhealth vim.lsp", { desc = "LSP health check" })

vim.diagnostic.config({
  virtual_text = true,
})

local augroup = vim.api.nvim_create_augroup("lsp/init", {})

vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup,
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    if client:supports_method("textDocument/formatting") then
      vim.keymap.set("n", "<leader>f", function()
        vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
      end, { buffer = args.buf, desc = "Format buffer" })
    end

    if client:supports_method('textDocument/implementation') then
      vim.keymap.set("n", "<leader>i", vim.lsp.buf.implementation, { buffer = args.buf, desc = "References buffer" })
    end

    if client:supports_method("textDocument/references") then
      vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = args.buf, desc = "References buffer" })
    end

    if client:supports_method("textDocument/rename") then
      vim.keymap.set("n", "<C-q>", vim.lsp.buf.rename, { buffer = args.buf, desc = "Rename buffer" })
    end

    if client:supports_method("textDocument/codeAction") then
      vim.keymap.set("n", "<leader>k", function()
        vim.lsp.buf.code_action()
      end, { buffer = args.buf, desc = "CodeAction buffer" })
    end

    if client:supports_method("textDocument/signatureHelp") then
      vim.api.nvim_create_autocmd("CursorHoldI", {
        pattern = "*",
        callback = function()
          vim.lsp.buf.signature_help({ focus = false, silent = true })
        end
      })
    end
  end,
})

vim.lsp.config("*", {
  root_markers = { ".git" },
})

vim.lsp.enable({
  "gopls",
  "ts_ls",
  "pyright",
  "ruff",
  "lua_ls",
  "cssls",
  "jsonls",
  "yamlls",
  "terraformls",
  "textlsp",
  "tflint",
  "docker_language_server",
  "bashls",
  "nixd",
  "rnix",
})
