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
