vim.api.nvim_create_user_command("LspHealth", "checkhealth vim.lsp", { desc = "LSP health check" })

vim.api.nvim_create_user_command("PyreflySourceRoot", function(opts)
  require("config.pyrefly").add(opts.fargs)
end, {
  nargs = "*",
  complete = "dir",
  desc = "Add source root directories for pyrefly (persisted to .nvim.lua, applied live)",
})

vim.api.nvim_create_user_command("PyreflySourceRootClear", function()
  require("config.pyrefly").clear()
end, { desc = "Clear pyrefly source roots" })

vim.api.nvim_create_user_command("PyreflySourceRootPick", function()
  require("config.pyrefly").pick()
end, { desc = "Pick source root directories for pyrefly via Telescope" })

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
      vim.keymap.set("n", "<leader>i", "<cmd>Trouble lsp_implementations<cr>", { buffer = args.buf, desc = "References buffer" })
    end

    if client:supports_method("textDocument/definition") then
      vim.keymap.set("n", "gd", "<cmd>Trouble lsp_definitions<cr>", { buffer = args.buf, desc = "Definitions buffer" })
    end

    if client:supports_method("textDocument/references") then
      vim.keymap.set("n", "gr", "<cmd>Trouble lsp_references<cr>", { buffer = args.buf, desc = "References buffer" })
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

-- lsp/oxfmt.lua (this config dir) merges with nvim-lspconfig's own lsp/oxfmt.lua by
-- runtime-path scan order, and the plugin's file is applied last, so it always wins
-- for keys both define (root_dir included) -- a file-based override cannot win here.
-- We therefore override root_dir imperatively, after everything else has loaded.
-- Upstream's root_dir calls on_dir(vim.fs.dirname(nil)) when no oxfmt config is found,
-- which resolves to on_dir(nil) and falls back to the "*" root_markers (".git") above,
-- causing oxfmt to attach to any git project and steal the <leader>f keymap from biome.
do
  local util = require("lspconfig.util")
  vim.lsp.config("oxfmt", {
    root_dir = function(bufnr, on_dir)
      local fname = vim.api.nvim_buf_get_name(bufnr)
      local root_markers = util.insert_package_json(
        { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" },
        { "oxfmt", "vite%-plus" },
        fname
      )
      root_markers =
        util.root_markers_with_field(root_markers, { "vite.config.ts" }, { "vite%-plus", "fmt:" }, fname, "all")

      local found = vim.fs.find(root_markers, { path = fname, upward = true })[1]
      if not found then
        return
      end
      on_dir(vim.fs.dirname(found))
    end,
  })
end

vim.lsp.enable({
  "gopls",
  "ts_ls",
  "biome",
  "oxfmt",
  "pyrefly",
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
