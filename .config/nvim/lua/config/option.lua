local opt = vim.opt

opt.number = true
opt.wrap = false

-- インデント
opt.autoindent = true
opt.smartindent = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true

-- ステータスライン
opt.laststatus = 3
opt.cmdheight = 2

-- ウィンドウ分割
opt.splitright = true
opt.splitbelow = true
opt.equalalways = false -- ウィンドウ開閉時の自動リサイズを無効化
