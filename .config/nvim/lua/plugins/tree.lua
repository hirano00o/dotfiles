return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    priority = 1000,
    keys = {
      {
        "<leader>1",
        function()
          require("nvim-tree.api").tree.toggle()
        end,
        desc = "Toggle NvimTree",
      },
    },
    opts = function()
      --- カスタムキーマッピング設定
      ---
      --- - O: システムアプリケーションで開く
      --- - P: ファイルプレビュー
      --- - /: telescope.nvimでファジーファイル検索
      local function on_attach(bufnr)
        local api = require("nvim-tree.api")

        local function opts(desc)
          return {
            desc = "nvim-tree: " .. desc,
            buffer = bufnr,
            noremap = true,
            silent = true,
            nowait = true,
          }
        end

        local image_extensions = {
          png = true,
          jpg = true,
          jpeg = true,
          gif = true,
          webp = true,
          avif = true,
          bmp = true,
          tiff = true,
          heic = true,
          ico = true,
          icns = true,
          svg = true,
          mp4 = true,
          mov = true,
          webm = true,
          pdf = true,
        }

        -- フローティングウィンドウでファイルをプレビュー表示
        local function float_preview()
          local node = api.tree.get_node_under_cursor()
          if not node or node.type == "directory" then
            return
          end

          local filepath = node.absolute_path
          local filename = node.name
          local ext = filename:match("%.([^%.]+)$")

          -- ウィンドウサイズを計算(画面の80%)
          local width = math.floor(vim.o.columns * 0.8)
          local height = math.floor(vim.o.lines * 0.8)
          local row = math.floor((vim.o.lines - height) / 2)
          local col = math.floor((vim.o.columns - width) / 2)

          if ext and image_extensions[ext:lower()] then
            local tree_win = vim.api.nvim_get_current_win()

            local buf = vim.api.nvim_create_buf(false, true)

            local win = vim.api.nvim_open_win(buf, true, {
              relative = "editor",
              width = width,
              height = height,
              row = row,
              col = col,
              style = "minimal",
              border = "rounded",
              title = " " .. filename .. " ",
              title_pos = "center",
            })

            local ok, snacks_image = pcall(require, "snacks.image.buf")
            if ok then
              snacks_image.attach(buf, { src = filepath })
            end

            -- プレビュークローズ用キーマッピング
            local close_keys = { "q", "<Esc>", "P" }
            for _, key in ipairs(close_keys) do
              vim.keymap.set("n", key, function()
                local ok_clean, snacks_placement = pcall(require, "snacks.image.placement")
                if ok_clean then
                  snacks_placement.clean(buf)
                end
                if vim.api.nvim_win_is_valid(win) then
                  vim.api.nvim_win_close(win, true)
                end
                if vim.api.nvim_buf_is_valid(buf) then
                  vim.api.nvim_buf_delete(buf, { force = true })
                end
                if vim.api.nvim_win_is_valid(tree_win) then
                  vim.api.nvim_set_current_win(tree_win)
                end
              end, { buffer = buf, noremap = true, silent = true })
            end
            return
          end

          local preview_buf = vim.api.nvim_create_buf(false, true)

          local lines = vim.fn.readfile(filepath)
          if #lines == 0 then
            lines = { "(empty file)" }
          end
          vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)

          local ft = vim.filetype.match({ filename = filename, buf = preview_buf })
          if ft then
            vim.bo[preview_buf].filetype = ft
          end

          vim.bo[preview_buf].modifiable = false
          vim.bo[preview_buf].bufhidden = "wipe"

          local win = vim.api.nvim_open_win(preview_buf, true, {
            relative = "editor",
            width = width,
            height = height,
            row = row,
            col = col,
            style = "minimal",
            border = "rounded",
            title = " " .. filename .. " ",
            title_pos = "center",
          })

          vim.wo[win].cursorline = true
          vim.wo[win].number = true

          local close_keys = { "q", "<Esc>", "P" }
          for _, key in ipairs(close_keys) do
            vim.keymap.set("n", key, function()
              if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
              end
            end, { buffer = preview_buf, noremap = true, silent = true })
          end
        end

        api.config.mappings.default_on_attach(bufnr)

        vim.keymap.set("n", "O", api.node.run.system, opts("Open with system application"))
        vim.keymap.set("n", "P", float_preview, opts("Float preview"))
        vim.keymap.set("n", "/", function()
          local node = api.tree.get_node_under_cursor()
          local path = node and node.type == "directory" and node.absolute_path or vim.fn.getcwd()
          require("telescope.builtin").find_files({
            cwd = path,
            find_command = {
              "fd",
              "--type",
              "f",
              "--hidden",
              "--exclude",
              "node_modules",
              "--exclude",
              "venv",
              "--exclude",
              ".venv",
              "--exclude",
              ".git",
            },
          })
        end, opts("Fuzzy find files"))
      end

      return {
        on_attach = on_attach,
        view = {
          side = "left",
          width = 35,
          preserve_window_proportions = true,
        },
        filters = {
          custom = { "^node_modules$", "^venv$", "^\\.venv$" },
          git_ignored = false,
        },
        renderer = {
          icons = {
            show = {
              git = true,
              file = true,
              folder = true,
              folder_arrow = true,
            },
          },
        },
        git = {
          enable = true,
        },
        diagnostics = {
          enable = true,
        },
        update_focused_file = {
          enable = true,
        },
        filesystem_watchers = {
          enable = true,
        },
      }
    end,
  },
}
