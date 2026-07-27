return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {},
    ft = { "markdown", "quarto", "Avante" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      -- 編集中は自動レンダーしない。<leader>P のポップアップ内バッファのみ
      -- buf_enable() で個別にレンダーする。
      enabled = false,
      render_modes = { "n", "c", "t" },
      -- ポップアップでカーソル行も含め全行レンダーするため無効化。
      anti_conceal = { enabled = false },
      -- カーソル行でも ** やリンク URL の conceal を維持する。
      win_options = { concealcursor = { rendered = 'n' } },
      heading = {
        enabled        = true,
        sign           = false,
        icons          = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
        position       = 'overlay',
        width          = 'full',

        -- h1/h2 の下線(border)
        border         = true,
        border_virtual = true,
        border_prefix  = false,

        -- ヘッダ前後の余白
        above          = ' ',
        below          = ' ',

        left_pad       = { 0, 1, 2, 3, 4, 5 },
        right_pad      = 0,

        -- 背景なし
        backgrounds    = {
          'RenderMarkdownH1Bg', 'RenderMarkdownH2Bg', 'RenderMarkdownH3Bg',
          'RenderMarkdownH4Bg', 'RenderMarkdownH5Bg', 'RenderMarkdownH6Bg',
        },
        foregrounds    = {
          'RenderMarkdownH1', 'RenderMarkdownH2', 'RenderMarkdownH3',
          'RenderMarkdownH4', 'RenderMarkdownH5', 'RenderMarkdownH6',
        },
      },
      code = {
        enabled            = true,
        sign               = false,
        style              = 'full',
        position           = 'left',
        language_pad       = 0,
        disable_background = { 'mermaid' },
        width              = 'block',
        left_pad           = 0,
        right_pad          = 2,
        border             = 'thin',
        highlight          = 'RenderMarkdownCode',
        highlight_inline   = 'RenderMarkdownCodeInline',
      },

      bullet = {
        enabled   = true,
        icons     = { '•', '◦', '▪', '▫' },
        left_pad  = 0,
        right_pad = 0,
      },

      checkbox = {
        enabled   = true,
        unchecked = { icon = '☐ ', highlight = 'RenderMarkdownUnchecked' },
        checked   = { icon = '☑ ', highlight = 'RenderMarkdownChecked' },
      },

      quote = {
        enabled          = true,
        icon             = '▍',
        repeat_linebreak = true,
        highlight        = 'RenderMarkdownQuote',
      },

      pipe_table = {
        enabled             = true,
        style               = 'full',
        cell                = 'padded',
        border              = {
          '┌', '┬', '┐',
          '├', '┼', '┤',
          '└', '┴', '┘',
          '│', '─',
        },
        alignment_indicator = '━',
        head                = 'RenderMarkdownTableHead',
        row                 = 'RenderMarkdownTableRow',
        filler              = 'RenderMarkdownTableFill',
      },

      link = {
        enabled   = true,
        image     = '🖼 ',
        email     = '✉ ',
        hyperlink = '󰌹 ',
        highlight = 'RenderMarkdownLink',
      },

      dash = {
        enabled   = true,
        icon      = '─',
        width     = 'full',
        highlight = 'RenderMarkdownDash',
      },
    },

    config = function(_, opts)
      require('render-markdown').setup(opts)

      -- 現在バッファの内容をスナップショットし、フロートにレンダー表示する
      local function markdown_popup()
        local src = vim.api.nvim_get_current_buf()
        local ft = vim.bo[src].filetype
        if not vim.tbl_contains({ 'markdown', 'quarto', 'Avante' }, ft) then
          return
        end

        local lines = vim.api.nvim_buf_get_lines(src, 0, -1, false)
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

        -- 相対パスの画像を元ファイルと同じディレクトリ基準で解決させる。
        -- snacks.image は nvim_buf_get_name の dirname を基準に解決するため、
        -- 無名スクラッチバッファに元ファイルと同ディレクトリの名前を付与する。
        local src_name = vim.api.nvim_buf_get_name(src)
        if src_name ~= '' then
          pcall(vim.api.nvim_buf_set_name, buf, src_name .. '.render-popup')
        end

        -- snacks.image のホバー用フロート自動アタッチを抑止する。ネストした
        -- フロート内ではホバーフロートが開けないため、後段でインライン描画する。
        vim.b[buf].snacks_image_attached = true

        vim.bo[buf].filetype             = ft -- FileType 発火 → attach(enabled=false のため未描画)
        vim.bo[buf].modifiable           = false
        vim.bo[buf].bufhidden            = 'wipe' -- 閉じたらバッファ破棄。再表示時の名前衝突を防ぐ

        local width                      = math.floor(vim.o.columns * 0.8)
        local height                     = math.floor(vim.o.lines * 0.8)
        vim.api.nvim_open_win(buf, true, { -- enter=true でフロートを current 化
          relative = 'editor',
          width    = width,
          height   = height,
          row      = math.floor((vim.o.lines - height) / 2),
          col      = math.floor((vim.o.columns - width) / 2),
          border   = 'rounded',
        })

        require('render-markdown').buf_enable() -- このフロートバッファのみレンダー有効化

        -- フロート内ではホバーフロートが開けないため、画像をインライン描画する。
        pcall(function() Snacks.image.inline.new(buf) end)

        for _, key in ipairs({ 'q', '<Esc>' }) do
          vim.keymap.set('n', key, '<cmd>close<cr>', { buffer = buf, nowait = true })
        end
      end

      vim.keymap.set('n', '<leader>P', markdown_popup, { desc = 'Markdown render popup' })

      -- GitHub Dark風
      local gh_dark = {
        fg        = '#e6edf3',
        muted     = '#8b949e',
        border    = '#30363d',
        code_bg   = '#161b22',
        inline_bg = '#343942',
        link      = '#2f81f7',
        quote_fg  = '#8b949e',
      }
      local c = gh_dark

      local set = function(name, o) vim.api.nvim_set_hl(0, name, o) end

      -- カラースキーム適用後にも上書きされるよう ColorScheme で再適用
      local apply = function()
        local h_colors = {
          '#f0883e', -- H1: orange
          '#2f81f7', -- H2: blue
          '#a371f7', -- H3: purple
          '#3fb950', -- H4: green
          '#e6edf3', -- H5: white
          '#8b949e', -- H6: muted gray
        }
        for i = 1, 6 do
          set('RenderMarkdownH' .. i, { fg = h_colors[i], bold = true })
          set('RenderMarkdownH' .. i .. 'Bg', {}) -- 背景なし
        end
        set('RenderMarkdownH1Border', { fg = c.border })
        set('RenderMarkdownH2Border', { fg = c.border })

        -- RenderMarkdownCode: disable_background=trueのため不要（設定してもextmarkが非適用）
        set('RenderMarkdownCodeInline', { bg = c.inline_bg, fg = c.fg })

        set('RenderMarkdownQuote', { fg = c.quote_fg })
        set('RenderMarkdownLink', { fg = c.link, underline = true })

        set('RenderMarkdownTableHead', { fg = c.border, bold = true })
        set('RenderMarkdownTableRow', { fg = c.border })
        set('RenderMarkdownTableFill', { fg = c.border })

        set('RenderMarkdownDash', { fg = c.border })
      end

      apply()
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('RenderMarkdownGithubColors', { clear = true }),
        callback = apply,
      })
    end,
  },
  {
    'arto-app/arto.vim',
    init = function()
      vim.g.arto_path = vim.fn.expand('$HOME/Applications/Home Manager Apps/Arto.app')
    end,
  },
}
