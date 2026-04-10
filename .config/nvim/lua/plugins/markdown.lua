return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    {
      "tree-sitter-grammars/tree-sitter-markdown",
    },
  },
  ft = {"markdown", "quarto", "Avante"},
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    render_modes = { "n", "c", "t" },
    code = {
      disable_background = { "mermaid" },
    },
    anti_conceal = { enabled = true },
    heading = {
      enabled  = true,
      sign     = false,
      icons    = {},
      position = 'overlay',
      width    = 'full',

      -- h1/h2 の下線(border)
      border         = true,
      border_virtual = true,
      border_prefix  = false,

      -- ヘッダ前後の余白
      above = ' ',
      below = ' ',

      left_pad  = 0,
      right_pad = 0,

      -- 背景なし
      backgrounds = {
        'RenderMarkdownH1Bg', 'RenderMarkdownH2Bg', 'RenderMarkdownH3Bg',
        'RenderMarkdownH4Bg', 'RenderMarkdownH5Bg', 'RenderMarkdownH6Bg',
      },
      foregrounds = {
        'RenderMarkdownH1', 'RenderMarkdownH2', 'RenderMarkdownH3',
        'RenderMarkdownH4', 'RenderMarkdownH5', 'RenderMarkdownH6',
      },
    },

    code = {
      enabled            = true,
      sign               = false,
      style              = 'normal',
      position           = 'left',
      language_pad       = 0,
      disable_background = false,
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
      checked   = { icon = '☑ ', highlight = 'RenderMarkdownChecked'   },
    },

    quote = {
      enabled          = true,
      icon             = '▍',
      repeat_linebreak = true,
      highlight        = 'RenderMarkdownQuote',
    },

    pipe_table = {
      enabled = true,
      style   = 'full',
      cell    = 'padded',
      border  = {
        '┌', '┬', '┐',
        '├', '┼', '┤',
        '└', '┴', '┘',
        '│', '─',
      },
      alignment_indicator = '━',
      head   = 'RenderMarkdownTableHead',
      row    = 'RenderMarkdownTableRow',
      filler = 'RenderMarkdownTableFill',
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
      for i = 1, 6 do
        set('RenderMarkdownH' .. i,        { fg = c.fg, bold = true })
        set('RenderMarkdownH' .. i .. 'Bg', {})  -- 背景なし
      end
      set('RenderMarkdownH1Border',  { fg = c.border })
      set('RenderMarkdownH2Border',  { fg = c.border })

      set('RenderMarkdownCode',       { bg = c.code_bg })
      set('RenderMarkdownCodeInline', { bg = c.inline_bg, fg = c.fg })

      set('RenderMarkdownQuote', { fg = c.quote_fg })
      set('RenderMarkdownLink',  { fg = c.link, underline = true })

      set('RenderMarkdownTableHead', { fg = c.border, bold = true })
      set('RenderMarkdownTableRow',  { fg = c.border })
      set('RenderMarkdownTableFill', { fg = c.border })

      set('RenderMarkdownDash', { fg = c.border })
    end

    apply()
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('RenderMarkdownGithubColors', { clear = true }),
      callback = apply,
    })
  end,
}
