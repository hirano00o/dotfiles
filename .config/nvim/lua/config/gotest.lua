local M = {}

M.config = {
  gotests_bin = "gotests",
  template_dir = vim.fn.stdpath("config") .. "/templates/gotests",
}

function M.generate_test()
  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)

  if not filepath:match("%.go$") or filepath:match("_test%.go$") then
    vim.notify("❌ Goファイルではありません", vim.log.levels.ERROR)
    return
  end

  local test_file = filepath:gsub("%.go$", "_test.go")

  -- treesitterでカーソル位置の関数名を取得
  local node = vim.treesitter.get_node()

  local function_name = nil
  while node do
    local node_type = node:type()
    if node_type == "function_declaration" or node_type == "method_declaration" then
      -- 関数名のノードを探す
      for child in node:iter_children() do
        if child:type() == "identifier" or child:type() == "field_identifier" then
          function_name = vim.treesitter.get_node_text(child, bufnr)
          break
        end
      end
      break
    end
    node = node:parent()
  end

  if not function_name then
    vim.notify("❌ カーソル位置に関数が見つかりません", vim.log.levels.ERROR)
    return
  end

  local cmd = string.format(
    "%s -w -template_dir %s -only '^%s$' %s 2>&1",
    M.config.gotests_bin,
    vim.fn.shellescape(M.config.template_dir),
    function_name,
    vim.fn.shellescape(filepath)
  )

  -- 実行
  local output = {}
  vim.fn.jobstart(cmd, {
    on_stdout = function(_, data)
      if data then
        vim.list_extend(output, data)
      end
    end,
    on_stderr = function(_, data)
      if data then
        vim.list_extend(output, data)
        vim.notify(string.format("📤 STDERR: %s", table.concat(data, "\n")), vim.log.levels.WARN)
      end
    end,
    on_exit = function(_, exit_code)
      vim.schedule(function()
        local test_exists = vim.fn.filereadable(test_file) == 1
        local output_str = table.concat(output, "\n")
        local has_error = output_str:match("[Ee]rror") or
            output_str:match("unexpected") or
            output_str:match("failed")

        if exit_code == 0 and test_exists and not has_error then
          vim.cmd("edit " .. test_file)
        else
          local error_msg = output_str ~= "" and output_str or "テストファイルの生成に失敗しました"
          vim.notify(
            string.format("❌ テスト生成に失敗しました\n理由: exit_code=%d, test_exists=%s, has_error=%s\n出力: %s",
              exit_code, test_exists, has_error, error_msg),
            vim.log.levels.ERROR
          )
        end
      end)
    end,
  })
end

function M.generate_all_tests()
  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)

  if not filepath:match("%.go$") or filepath:match("_test%.go$") then
    return
  end

  local test_file = filepath:gsub("%.go$", "_test.go")

  local cmd = string.format(
    "%s -w -all -template_dir %s %s 2>&1",
    M.config.gotests_bin,
    vim.fn.shellescape(M.config.template_dir),
    vim.fn.shellescape(filepath)
  )

  local output = {}
  vim.fn.jobstart(cmd, {
    on_stdout = function(_, data)
      if data then
        vim.list_extend(output, data)
      end
    end,
    on_stderr = function(_, data)
      if data then
        vim.list_extend(output, data)
      end
    end,
    on_exit = function(_, exit_code)
      vim.schedule(function()
        local test_exists = vim.fn.filereadable(test_file) == 1
        local output_str = table.concat(output, "\n")
        local has_error = output_str:match("[Ee]rror") or
            output_str:match("unexpected") or
            output_str:match("failed")

        if exit_code == 0 and test_exists and not has_error then
          vim.cmd("edit " .. test_file)
        else
          local error_msg = output_str ~= "" and output_str or "テストファイルの生成に失敗しました"
          vim.notify(
            string.format("❌ テスト生成に失敗しました\n%s", error_msg),
            vim.log.levels.ERROR
          )
        end
      end)
    end,
  })
end

function M.generate_exported_tests()
  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)

  if not filepath:match("%.go$") or filepath:match("_test%.go$") then
    return
  end

  local test_file = filepath:gsub("%.go$", "_test.go")

  local cmd = string.format(
    "%s -w -exported -template_dir %s %s 2>&1",
    M.config.gotests_bin,
    vim.fn.shellescape(M.config.template_dir),
    vim.fn.shellescape(filepath)
  )

  local output = {}
  vim.fn.jobstart(cmd, {
    on_stdout = function(_, data)
      if data then
        vim.list_extend(output, data)
      end
    end,
    on_stderr = function(_, data)
      if data then
        vim.list_extend(output, data)
      end
    end,
    on_exit = function(_, exit_code)
      vim.schedule(function()
        local test_exists = vim.fn.filereadable(test_file) == 1
        local output_str = table.concat(output, "\n")
        local has_error = output_str:match("[Ee]rror") or
            output_str:match("unexpected") or
            output_str:match("failed")

        if exit_code == 0 and test_exists and not has_error then
          vim.cmd("edit " .. test_file)
        else
          local error_msg = output_str ~= "" and output_str or "テストファイルの生成に失敗しました"
          vim.notify(
            string.format("❌ テスト生成に失敗しました\n%s", error_msg),
            vim.log.levels.ERROR
          )
        end
      end)
    end,
  })
end

function M.setup_keymaps(bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }

  vim.keymap.set('n', '<leader>n', M.generate_test,
    vim.tbl_extend('force', opts, { desc = "Generate test for function" }))

  vim.keymap.set('n', '<leader>tg', M.generate_test,
    vim.tbl_extend('force', opts, { desc = "Generate test" }))

  vim.keymap.set('n', '<leader>tga', M.generate_all_tests,
    vim.tbl_extend('force', opts, { desc = "Generate all tests" }))

  vim.keymap.set('n', '<leader>tge', M.generate_exported_tests,
    vim.tbl_extend('force', opts, { desc = "Generate exported tests" }))
end

function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", M.config, opts)
end

return M
