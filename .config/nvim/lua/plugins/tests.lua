return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      {
        "fredrikaverpil/neotest-golang",
        version = "*",
      },
      "nvim-neotest/neotest-jest",
      "andythigpen/nvim-coverage",
    },
    ft = { "go", "typescript", "typescriptreact" },
    config = function()
      local neotest_ns = vim.api.nvim_create_namespace("neotest")
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            local message =
                diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
            return message
          end,
        },
      }, neotest_ns)

      require("neotest").setup({
        adapters = {
          require("neotest-golang")({
            go_test_args = { "-count=1", "-timeout=60s" },
          }),
          require("neotest-jest")({
            jestCommand = "npm test --",
            jestArguments = function(defaultArguments, context)
              return defaultArguments
            end,
            jestConfigFile = "jest.config.ts",
            env = { CI = true },
            cwd = function(path)
              return vim.fn.getcwd()
            end,
            isTestFile = require("neotest-jest.jest-util").defaultIsTestFile,
          }),
        },
        discovery = {
          enabled = true,
          concurrent = 1,
        },
        status = {
          enabled = true,
          virtual_text = true,
          signs = true,
        },
        floating = {
          border = "rounded",
          max_height = 0.8,
          max_width = 0.8,
        },
        output = {
          enabled = true,
          open_on_run = "short", -- "short" | false | "auto"
        },
        summary = {
          enabled = true,
          animated = true,
          follow = true,
          expand_errors = true,
          mappings = {
            attach = "a",
            clear_marked = "M",
            clear_target = "T",
            debug = "d",
            debug_marked = "D",
            expand = { "<CR>", "<2-LeftMouse>" },
            expand_all = "e",
            jumpto = "i",
            mark = "m",
            next_failed = "J",
            output = "o",
            prev_failed = "K",
            run = "r",
            run_marked = "R",
            short = "O",
            stop = "u",
            target = "t",
            watch = "w",
          },
        },
      })

      local function setup_neotest_keymaps(bufnr)
        local opts = { buffer = bufnr, noremap = true, silent = true }
        local neotest = require("neotest")

        vim.keymap.set('n', '<SC-r>', function() neotest.run.run() end,
          vim.tbl_extend('force', opts, { desc = "Run nearest test" }))

        vim.keymap.set('n', '<leader>tr', function() neotest.run.run() end,
          vim.tbl_extend('force', opts, { desc = "Run nearest test" }))

        vim.keymap.set('n', '<leader>tf', function() neotest.run.run(vim.fn.expand("%")) end,
          vim.tbl_extend('force', opts, { desc = "Run file tests" }))

        vim.keymap.set('n', '<leader>tl', function() neotest.run.run_last() end,
          vim.tbl_extend('force', opts, { desc = "Run last test" }))

        vim.keymap.set('n', '<leader>td', function() neotest.run.run({ strategy = "dap" }) end,
          vim.tbl_extend('force', opts, { desc = "Debug nearest test" }))

        vim.keymap.set('n', '<leader>ts', function() neotest.summary.toggle() end,
          vim.tbl_extend('force', opts, { desc = "Toggle test summary" }))

        vim.keymap.set('n', '<leader>to', function() neotest.output.open({ enter = true }) end,
          vim.tbl_extend('force', opts, { desc = "Show test output" }))

        vim.keymap.set('n', '<leader>tp', function() neotest.output_panel.toggle() end,
          vim.tbl_extend('force', opts, { desc = "Toggle output panel" }))
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "go", "typescript", "typescriptreact" },
        callback = function(ev)
          setup_neotest_keymaps(ev.buf)
        end,
        desc = "Setup neotest keymaps"
      })
    end,
  },
}
