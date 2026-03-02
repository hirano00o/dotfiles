return {
  {
    "akinsho/toggleterm.nvim",
    config = function()
      local toggleterm = require("toggleterm")
      local Terminal = require("toggleterm.terminal").Terminal

      toggleterm.setup({
        size = function(term)
          if term.direction == "horizontal" then
            return vim.o.lines * 0.3
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = nil,
        direction = 'horizontal',
        winbar = {
          enabled = true,
          name_formatter = function(term)
            return string.format("%d: %s", term.id, term.name or "Terminal")
          end
        },
        -- ターミナルを開いた時に自動的にTERMINALモードに入る
        on_open = function(term)
          vim.schedule(function()
            vim.cmd("startinsert!")
          end)
        end,
        -- ターミナル終了時に別のターミナルがあれば切り替える
        on_exit = function(term, job, exit_code, name)
          local terms = require("toggleterm.terminal").get_all()
          if #terms == 0 then return end

          local smaller_ids = {}
          local larger_ids = {}

          for _, t in ipairs(terms) do
            if t.id < term.id then
              table.insert(smaller_ids, t.id)
            elseif t.id > term.id then
              table.insert(larger_ids, t.id)
            end
          end

          -- 1つ前（なければ1つ後）のターミナルを開く
          local target_id = nil
          if #smaller_ids > 0 then
            table.sort(smaller_ids)
            target_id = smaller_ids[#smaller_ids]
          elseif #larger_ids > 0 then
            table.sort(larger_ids)
            target_id = larger_ids[1]
          end

          if target_id then
            vim.schedule(function()
              vim.cmd(target_id .. "ToggleTerm")
              vim.defer_fn(function()
                vim.cmd("startinsert!")
              end, 50)
            end)
          end
        end,
      })

      -- ESCでターミナルモードを抜ける
      vim.keymap.set("t", "<ESC>", [[<C-\><C-n>]], { silent = true })

      -- F12: ターミナル開閉
      vim.keymap.set('n', '<F12>', '<cmd>ToggleTerm<cr>', { noremap = true, silent = true })
      vim.keymap.set('t', '<F12>', '<C-\\><C-n><cmd>ToggleTerm<cr>', { noremap = true, silent = true })

      -- ターミナルIDのソート
      local function get_sorted_term_ids()
        local terms = require("toggleterm.terminal").get_all()
        local ids = {}
        for _, term in ipairs(terms) do
          table.insert(ids, term.id)
        end
        table.sort(ids)
        return ids
      end

      local function switch_terminal(target_id)
        local current_id = require("toggleterm.terminal").get_focused_id()
        if current_id and current_id ~= target_id then
          -- 現在のターミナルを閉じる
          vim.cmd(current_id .. "ToggleTerm")
        end
        -- 目的のターミナルを開く
        vim.cmd(target_id .. "ToggleTerm")
      end

      -- Ctrl+n: 新規ターミナル作成
      vim.keymap.set('t', '<C-n>', function()
        local ids = get_sorted_term_ids()
        local next_id = (#ids > 0) and (ids[#ids] + 1) or 1
        switch_terminal(next_id)
      end, { noremap = true, silent = true, desc = "Create new terminal" })

      -- Ctrl+]: 次のターミナルに移動
      vim.keymap.set('t', '<C-]>', function()
        local ids = get_sorted_term_ids()
        if #ids <= 1 then return end

        local current = require("toggleterm.terminal").get_focused_id()
        local next_id = ids[1]
        for i, id in ipairs(ids) do
          if id == current then
            next_id = ids[i + 1] or ids[1]
            break
          end
        end

        switch_terminal(next_id)
      end, { noremap = true, silent = true, desc = "Next terminal" })

      -- Ctrl+[: 前のターミナルに移動
      vim.keymap.set('t', '<C-[>', function()
        local ids = get_sorted_term_ids()
        if #ids <= 1 then return end

        local current = require("toggleterm.terminal").get_focused_id()
        local prev_id = ids[#ids]
        for i, id in ipairs(ids) do
          if id == current then
            prev_id = ids[i - 1] or ids[#ids]
            break
          end
        end

        switch_terminal(prev_id)
      end, { noremap = true, silent = true, desc = "Previous terminal" })

      -- :TermN コマンドを作成（N=1-9）
      for i = 1, 9 do
        vim.api.nvim_create_user_command("Term" .. i, function()
          vim.cmd(i .. "ToggleTerm")
        end, { desc = "Toggle terminal " .. i })
      end
    end,
  },
}
