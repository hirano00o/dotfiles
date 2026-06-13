return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    keys = {
      {
        "<leader>dv",
        function()
          -- 追跡ブランチを取得
          local handle = io.popen("git rev-parse --abbrev-ref @{upstream} 2>/dev/null")
          local base = nil
          if handle then
            base = handle:read("*a"):gsub("%s+", "")
            handle:close()
          end

          -- 追跡ブランチがなければデフォルトブランチを取得
          if not base or base == "" then
            handle = io.popen("git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null")
            if handle then
              base = handle:read("*a"):gsub("refs/remotes/", ""):gsub("%s+", "")
              handle:close()
            end
          end

          -- フォールバック
          if not base or base == "" then
            base = "main"
          end

          vim.cmd("DiffviewOpen " .. base)
        end,
        desc = "Open Diffview against base branch",
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPost",
    opts = {
      current_line_blame = true,
      word_diff = true,
      -- 追加/変更は細い縦バー、削除は三角
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "▸" },
        topdelete = { text = "▸" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      -- base がブランチ分岐点になるため、staged との区別表示は冗長になり無効化
      signs_staged_enable = false,
      on_attach = function(bufnr)
        -- ブランチ分岐点の差分表示
        -- (デフォルトブランチとの merge-base) を差分の基準にする。
        -- デフォルトブランチ上では merge-base = HEAD となり従来挙動と一致する。
        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(bufnr) then
            return
          end
          local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
          for _, ref in ipairs { "origin/HEAD", "origin/main", "origin/master", "main", "master" } do
            local out = vim.fn.systemlist { "git", "-C", dir, "merge-base", ref, "HEAD" }
            if vim.v.shell_error == 0 and out[1] then
              vim.api.nvim_buf_call(bufnr, function()
                require("gitsigns").change_base(out[1], false)
              end)
              return
            end
          end
        end)
      end,
    },
    keys = {
      {
        "<leader>hu",
        function()
          require("gitsigns").preview_hunk_inline()
        end,
        desc = "Preview hunk",
      },
    },
  },
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = "Octo",
    opts = {
      picker = "telescope",
      enable_builtin = true,
      github_hostname = "github.com",
    },
    keys = {
      {
        "<leader>oi",
        "<CMD>Octo issue list<CR>",
        desc = "List GitHub Issues",
      },
      {
        "<leader>op",
        "<CMD>Octo pr list<CR>",
        desc = "List GitHub PullRequests",
      },
      {
        "<leader>od",
        "<CMD>Octo discussion list<CR>",
        desc = "List GitHub Discussions",
      },
      {
        "<leader>on",
        "<CMD>Octo notification list<CR>",
        desc = "List GitHub Notifications",
      },
      {
        "<leader>os",
        function()
          require("octo.utils").create_base_search_command { include_current_repo = true }
        end,
        desc = "Search GitHub",
      },
    },
  },
}
