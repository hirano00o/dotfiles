set term=xterm-256color             " 256色で表示する
" set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[38;2;%lu;%lu;%lum"
set encoding=utf-8                  " エンコーディングをUTF-8にする
set fileencodings=utf-8,sjis,cp932  " 設定の順番の文字コードでファイルを開く
set fileformats=unix,dos,mac        " 設定の順番で改行コードを開く
set nofixendofline                  " EOFを元のファイルと同じ状態にする

set ambiwidth=double                " ○文字や□文字でもカーソル位置を保持する
set nobackup                        " バックアップファイルは作成しない
set noswapfile                      " スワップファイルは作成しない
set autoread                        " 編集中のファイルが変更された場合、自動で読み直し
" set hidden                          " 未保存のファイルがあっても、別ファイルを開く
set showcmd                         " 入力コマンドをステータスに表示する
" set cursorline                      " 現行を強調表示する
set cursorcolumn                    " 現列を強調表示する

if !has('gui_running')              " CUI使用時
  set mouse=                        " マウス操作をOFFにする
  set ttimeoutlen=0                 " insertからnormalに戻るときの遅延を解消する
  set t_Co=256
endif

set autoindent                      " 改行時に前行のインデントを保持する
set smartindent                     " 改行時に前行末尾に合わせて、インデントを増減する
set tabstop=4                       " タブは設定文字数分で表示する
set shiftwidth=4                    " 自動インデントは4文字
set expandtab                       " タブを空白文字にする
set showmatch                       " 対応する括弧を強調表示する

set wildmenu                        " TABでファイル名を補完する
set wildmode=full                   " TABを押すごとに次のファイル名を補完する
set ignorecase                      " 検索に大文字小文字を区別しない
set smartcase                       " 検索に大文字を使うと、大文字小文字を区別する
set incsearch                       " リアルタイム検索する
set wrapscan                        " 最後まで検索すると、最初に戻る
set hlsearch                        " 検索結果をハイライト表示する
hi Search ctermbg=cyan              " ハイライトの背景をシアン
hi Search ctermfg=white             " ハイライト文字を白

set scrolloff=3                     " 3行前から画面をスクロールする
set nowrap                          " テキストの折返しをしない
set ruler                           " ルーラーを表示する
set number                          " 行番号を表示する
set relativenumber                  " 行番号を相対表示する
" カラムラインを120列目に引く
if (exists('+colorcolumn'))
    set colorcolumn=120
    hi ColorColumn ctermbg=grey
endif
" Esc2回でハイライトを消す
nmap <Esc><Esc> :nohlsearch<CR><Esc>
nmap <C-j><C-j> :nohlsearch<CR><Esc>

" Hで行頭へ移動する
map H ^
" Lで行末へ移動する
map L $
" Ctrl+jでEsc
noremap <C-j> <Esc>
noremap! <C-j> <Esc>

" WSL clipboardへコピー
nnoremap <silent> <Space>y :.w !win32yank.exe -i<CR><CR>
vnoremap <silent> <Space>y :w !win32yank.exe -i<CR><CR>
nnoremap <silent> <Space>p :r !win32yank.exe -o<CR>
vnoremap <silent> <Space>p :r !win32yank.exe -o<CR>

augroup fileTypeIndent
    autocmd!
    autocmd BufNewFile,BufRead *.yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufNewFile,BufRead *.yml setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufNewFile,BufRead *.js setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufNewFile,BufRead *.vue setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END

" undoを保存する
if has('persistent_undo')
    set undodir=~/.vim/undo
    set undofile
endif

" grepした結果をquickfixに表示する
augroup grepwindow
    autocmd!
    au QuickFixCmdPost *grep* cwindow
augroup END

if filereadable($HOME.'/.vim/autoload/plug.vim')  " vim-plugを利用する
  " curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  " :PlugInstallでインストール
  call plug#begin()
    Plug 'fatih/vim-go'                         " goの機能拡張
    Plug 'SirVer/ultisnips'                     " スニペット
    " goのスニペット -> https://github.com/fatih/vim-go/blob/master/gosnippets/UltiSnips/go.snippets
    Plug 'bronson/vim-trailing-whitespace'      " 行末のスペースをハイライト
    Plug 'Yggdroot/indentLine'                  " インデントを見やすくする
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }   " あいまい検索
    Plug 'junegunn/fzf.vim'
    Plug 'cohama/lexima.vim'                    " 括弧の補完
    Plug 'itchyny/lightline.vim'                " ステータスライン拡張
    " Plug 'morhetz/gruvbox'                      " カラースキーム
    Plug 'scrooloose/syntastic'                 " syntastic
    Plug 'othree/yajs.vim', { 'for': ['javascript', 'javascript.jsx'] }
    Plug 'pangloss/vim-javascript', { 'for': ['javascript', 'javascript.jsx'] }
    Plug 'othree/es.next.syntax.vim', { 'for': ['javascript', 'javascript.jsx'] }
    Plug 'othree/javascript-libraries-syntax.vim', { 'for': ['javascript', 'javascript.jsx'] }
    Plug 'othree/html5.vim'
    Plug 'maxmellon/vim-jsx-pretty', { 'for': ['javascript', 'javascript.jsx'] }
    " jsbeautifyの設定 -> https://github.com/maksimr/vim-jsbeautify#examples
    Plug 'maksimr/vim-jsbeautify'
    Plug 'Valloric/YouCompleteMe', { 'do': './install.py'  }            " Python補完
    Plug 'nvie/vim-flake8'                                              " Python Flake8
    Plug 'tpope/vim-markdown'                   " markdown編集
    Plug 'previm/previm'                        " markdown preview
    Plug 'alvan/vim-closetag'                   " html, xml tag auto closed
    Plug 'simeji/winresizer'                    " resize window
    Plug 'prabirshrestha/async.vim'
    Plug 'prabirshrestha/asyncomplete.vim'
    Plug 'prabirshrestha/asyncomplete-lsp.vim'
    Plug 'prabirshrestha/vim-lsp'
    Plug 'mattn/vim-lsp-settings'
    Plug 'xavierchow/vim-swagger-preview'       " swagger preview in browser
  call plug#end()
endif

syntax enable                       " シンタックスをONにする
" set background=dark                 " 背景をダークモードにする
" if filereadable($HOME.'/.vim/plugged/gruvbox/autoload/gruvbox.vim')
"     colorscheme gruvbox
" endif

let g:lightline = {
      \ 'colorscheme': 'landscape',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste'  ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified'  ] ]
      \ },
      \ 'component_function': {
      \   'linetotal': 'LightLineTotal',
      \   'gitbranch': 'fugitive#head'
      \ },
      \ }
let g:lightline.component = {
    \ 'lineinfo': '[%3l/%3L]:%-2v'
    \ }
set laststatus=2                    " ステータスラインを常に表示する
set cmdheight=1                     " ステータスライン下のメッセージ表示行数

" ペースト時に自動インデントを無効化する
if &term =~ "xterm"
    let &t_SI .= "\e[?2004h"
    let &t_EI .= "\e[?2004l"
    let &pastetoggle = "\e[201~"
    function XTermPasteBegin(ret)
        set paste
        return a:ret
    endfunction

    inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
endif

" vim-go設定
let mapleader = "\<Space>"            " <leader>を<Space>にする
" au FileType go nmap <leader>r <Plug>(go-run)
" au FileType go nmap <leader>b <Plug>(go-build)
" au FileType go nmap <leader>t <Plug>(go-test)
" au FileType go nmap <leader>c <Plug>(go-coverage)
" au FileType go nmap <Leader>i <Plug>(go-info)
" au FileType go nmap <leader>s <Plug>(go-def-split)
" au FileType go nmap <leader>v <Plug>(go-def-vertical)

" au FileType go :highlight goErr cterm=bold ctermfg=214
" au FileType go :match goErr /\<err\>/

let g:go_def_mapping_enabled = 0
let g:go_doc_keywordprg_enabled = 0

" ハイライト表示
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_fields = 1
let g:go_highlight_types = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1

let g:go_metalinter_autosave = 0
" let g:go_metalinter_autosave = ['vet', 'golint', 'gopls']    " 保存時にvet, lint を実行する
" let g:go_fmt_autosave = 1           " 保存時にfmtを実行する
" let g:go_fmt_fail_silently = 1
let g:go_fmt_command = "goimports"  " 不要なimportを削除する

if executable('gopls')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'gopls',
        \ 'cmd': {server_info->['gopls']},
        \ 'whitelist': ['go'],
        \ })
    au FileType go setlocal omnifunc=lsp#complete
    au FileType go let g:lsp_diagnostics_echo_cursor = 1
    au FileType go let g:lsp_signs_error = {'text': '✗'}
    au FileType go let g:lsp_signs_warning = {'text': '‼'}
    au FileType go let g:lsp_signs_hint = {'text': '!'}
    au BufWritePre *.go LspDocumentFormatSync
endif
nmap <silent> <C-]> :LspDefinition<CR>
nmap <silent> K :LspHover<CR>
nmap <silent> <f2> :LspRename<CR>
nmap <silent> td :LspTypeDefinition<CR>
nmap <silent> <Leader>r :LspReferences<CR>
nmap <silent> <Leader>i :LspImplementation<CR>
nmap <silent> <Leader>d :LspDocumentDiagnostics<CR>
nmap <silent> <Leader>n :LspNextDiagnostic<CR>
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:asyncomplete_popup_delay = 200
let g:lsp_text_edit_enabled = 0

" syntastic設定
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_javascript_checkers = ['eslint']

" javascript-libraries-syntax設定
augroup EnableJS
    autocmd!
augroup END

function! EnableJavascript()
    let g:used_javascript_libs = 'jquery,underscore,react,vue,jasmine,chai,d3'
    let b:javascript_lib_use_jquery = 1
    let b:javascript_lib_use_underscore = 1
    let b:javascript_lib_use_react = 1
    let b:javascript_lib_use_vue = 1
    let b:javascript_lib_use_jasmine = 1
    let b:javascript_lib_use_chai = 1
    let b:javascript_lib_use_d3 = 1
endfunction
autocmd EnableJS FileType javascript,javascript.jsx call EnableJavascript()

" jsbeautify
map <leader>j :call JsBeautify()<cr>

" youcompleteme
au FileType py let g:ycm_global_ycm_extra_conf = "$HOME/.vim/plugged/YouCompleteMe/.ycm_extra_conf.py"
au FileType py let g:ycm_auto_trigger = 1
au FileType py let g:ycm_min_num_of_chars_for_completion = 1
au FileType py let g:ycm_server_python_interpreter = "/usr/bin/python3.8"
au FileType py let g:ycm_autoclose_preview_window_after_insertion = 1

" autopep8
function! Preserve(command)
    " Save the last search.
    let search = @/
    " Save the current cursor position.
    let cursor_position = getpos('.')
    " Save the current window position.
    normal! H
    let window_position = getpos('.')
    call setpos('.', cursor_position)
    " Execute the command.
    execute a:command
    " Restore the last search.
    let @/ = search
    " Restore the previous window position.
    call setpos('.', window_position)
    normal! zt
    " Restore the previous cursor position.
    call setpos('.', cursor_position)
endfunction

function! Autopep8()
    call Preserve(':silent %!autopep8 --ignore=E501 -')
endfunction

augroup python_pep
	autocmd!
	autocmd BufWrite *.py :call Autopep8()
	autocmd BufWrite *.py :call Flake8()
augroup END

" vim-markdown
let g:markdown_fenced_languages = ['html', 'python', 'bash=sh']
let g:markdown_minlines = 100

" previm
let g:previm_open_cmd = '/mnt/c/Program\ Files\ \(x86\)/Google/Chrome/Application/chrome.exe'
let g:previm_enable_realtime = 1
let g:previm_wsl_mode = 1

" vim-closetag
let g:closetag_filenames = '*.html,*.vue'

" winresizer
let g:winresizer_vert_resize = 1
let g:winresizer_horiz_resize = 1

