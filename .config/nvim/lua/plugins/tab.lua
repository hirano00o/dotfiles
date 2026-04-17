return {
  {
    "romgrk/barbar.nvim",
    dependencies = {
      "lewis6991/gitsigns.nvim",
    },
    config = function()
      require("barbar").setup({
        -- aiboがタブに表示されるためターミナルを除外する
        auto_hide = false,
        exclude_ft = { "qf" },
        exclude_name = {},
        filter = function(buf)
          if not vim.api.nvim_buf_is_valid(buf) then
            return false
          end

          local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
          if buftype == "terminal" then
            return false
          end
          return true
        end,
      })
    end,
  },
  {
    'Bekaboo/dropbar.nvim',
    config = function()
      local _dropbar_cache = { buf = nil, win = nil }
      function _G.dropbar_lualine()
        local bars = _G.dropbar and _G.dropbar.bars
        if not bars then return '' end
        local win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_win_get_buf(win)
        local bar
        if bars[buf] and bars[buf][win] then
          _dropbar_cache.buf = buf
          _dropbar_cache.win = win
          bar = bars[buf][win]
        else
          -- フォールバック: メニュー等の floating window がフォーカスされた場合
          local lb, lw = _dropbar_cache.buf, _dropbar_cache.win
          if lb and lw and vim.api.nvim_win_is_valid(lw) and bars[lb] and bars[lb][lw] then
            bar = bars[lb][lw]
          end
        end
        if not bar then return '' end
        bar:update()
        return bar:cat()
      end

      local configs = require('dropbar.configs')
      require('dropbar').setup({
        bar = {
          enable = false, -- lualine の statusline で代替するため winbar 表示を無効化
        },
        symbol = {
          on_click = function(symbol)
            -- デフォルト実装をベースに pick モード時のメニュー位置をウィンドウ下部に変更
            if symbol.entry and symbol.entry.menu then
              symbol.entry.menu:update_current_context_hl(symbol.entry.idx)
            elseif symbol.bar then
              symbol.bar:update_current_context_hl(symbol.bar_idx)
            end

            local prev_win = nil
            local prev_buf = nil
            local entries_source = nil
            local init_cursor = nil
            local win_configs = {}
            if symbol.bar then
              prev_win = symbol.bar.win
              prev_buf = symbol.bar.buf
              entries_source = symbol.opts.siblings
              init_cursor = symbol.opts.sibling_idx
                and { symbol.opts.sibling_idx, 0 }
              if symbol.bar.in_pick_mode then
                local function tbl_sum(tbl)
                  local sum = 0
                  for _, v in ipairs(tbl) do
                    sum = sum + v
                  end
                  return sum
                end
                win_configs.relative = 'win'
                win_configs.win = vim.api.nvim_get_current_win()
                -- pick モード: row=0 の代わりにウィンドウ下部に配置し上方向に展開
                win_configs.row = vim.api.nvim_win_get_height(win_configs.win)
                win_configs.anchor = 'SW'
                win_configs.col = symbol.bar.padding.left
                  + tbl_sum(vim.tbl_map(
                    function(component)
                      return component:displaywidth()
                        + symbol.bar.separator:displaywidth()
                    end,
                    vim.tbl_filter(function(component)
                      return component.bar_idx < symbol.bar_idx
                    end, symbol.bar.components)
                  ))
              end
            elseif symbol.entry and symbol.entry.menu then
              prev_win = symbol.entry.menu.win
              prev_buf = symbol.entry.menu.buf
              entries_source = symbol.opts.children
            end

            if symbol.menu then
              symbol.menu:toggle({
                prev_win = prev_win,
                prev_buf = prev_buf,
                win_configs = win_configs,
              })
              return
            end

            if not entries_source or vim.tbl_isempty(entries_source) then
              return
            end

            local menu = require('dropbar.menu')
            symbol.menu = menu.dropbar_menu_t:new({
              prev_win = prev_win,
              prev_buf = prev_buf,
              cursor = init_cursor,
              win_configs = win_configs,
              entries = vim.tbl_map(function(sym)
                local menu_indicator_icon = configs.opts.icons.ui.menu.indicator
                local menu_indicator_on_click = nil
                if not sym.children or vim.tbl_isempty(sym.children) then
                  menu_indicator_icon =
                    string.rep(' ', vim.fn.strdisplaywidth(menu_indicator_icon))
                  menu_indicator_on_click = false
                end
                return menu.dropbar_menu_entry_t:new({
                  components = {
                    sym:merge({
                      name = '',
                      icon = menu_indicator_icon,
                      icon_hl = 'dropbarIconUIIndicator',
                      on_click = menu_indicator_on_click,
                    }),
                    sym:merge({
                      on_click = function()
                        local root_menu = symbol.menu and symbol.menu:root()
                        if root_menu then
                          root_menu:close(false)
                        end
                        sym:jump()
                      end,
                    }),
                  },
                })
              end, entries_source),
            })
            symbol.menu:toggle()
          end,
        },
        menu = {
          win_configs = {
            row = function(menu)
              if menu.prev_menu then
                return menu.prev_menu.clicked_at
                  and menu.prev_menu.clicked_at[1] - vim.fn.line('w0')
                  or 0
              end
              -- 第一階層メニュー: ウィンドウ下部に配置
              return vim.api.nvim_win_get_height(menu.prev_win or 0)
            end,
            anchor = function(menu)
              if menu.prev_menu then
                return 'NW'
              end
              return 'SW'
            end,
          },
        },
      })
      -- _update() はコンポーネントを component:del() で全破棄→再作成するため、
      -- メニューが開いている間に実行されるとメニューが閉じてしまう。
      -- vim.defer_fn による遅延実行でも発生するため、_update() 自体を保護する。
      local dropbar_bar = require('dropbar.bar')
      local original__update = dropbar_bar.dropbar_t._update
      function dropbar_bar.dropbar_t:_update()
        for _, component in ipairs(self.components) do
          if component.menu and component.menu.is_opened then
            return
          end
        end
        original__update(self)
      end


      local dropbar_api = require('dropbar.api')
      vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
      vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
      vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
    end

  },
}
