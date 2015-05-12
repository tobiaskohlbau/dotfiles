"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" => general settings
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" enable plugins by filetype
filetype plugin on
filetype indent on

" autoread file if modified outside of vim
set autoread

let mapleader=","
let g:mapleader=","

" fast saving
nmap <leader>w :w!<cr>


" indent settings

" expand tabs to spaces
set expandtab

" replace 1 tab by 4 whitespaces
set tabstop=4
set shiftwidth=4

" use smart tabs
set smarttab

" linbreak
set lbr
set tw=120

set ai
set si
set wrap

" misc settings
nmap 0 ^

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" => user interface 
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" set 7 lines to cursor
set so=7

" turn wild menu on
set wildmenu

" ignore compiled files
set wildignore=*.o

" enable ruler
set ruler

" height of the command bar
set cmdheight=2

" ignore case for searching
set ignorecase
map <space> /
map <c-space> / 
set smartcase
set hlsearch
set incsearch

" show matching brackets
set showmatch

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" => Themes 
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" enable syntax highlightin
syntax enable

" utf8 as default
set encoding=utf8

" use linux line endings
set ffs=unix

function! Tabline()
    let s = ''
    for i in range(tabpagenr('$'))
        let tab = i + 1
        let winnr = tabpagewinnr(tab)
        let buflist = tabpagebuflist(tab)
        let bufnr = buflist[winnr - 1]
        let bufname = bufname(bufnr)
        let bufmodified = getbufvar(bufnr, "&mod")

        let s .= '%' . tab . 'T'
        let s .= (tab == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#')
        let s .= ' ' . tab . ':'
        let s .= (bufname != '' ? '[' . fnamemodify(bufname, ':t') . ']' : '[No Name]')

        if bufmodified
            let s .= '[+]'
        endif
    endfor

    let s .= '%#TabeLineFill#'
    return s
endfunction
set tabline=%!Tabline()

" highlight colum 120
set colorcolumn=120
highlight ColorColumn ctermbg=darkgrey

" fold settings
set fdm=indent
set fdc=4
set fdl=1

" show line numbers
set number


" use color scheme
colorscheme flattened_dark


" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" => backup 
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" turn off vim backup functions
set nobackup
set nowb
set noswapfile

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" => shortcuts 
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" opens a new tab with current buffers path
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/
map <leader>tec :tabedit <c-r>=expand("%:p:r")<cr>.h<ENTER>
map <leader>tec :tabedit <c-r>=expand("%:p:r")<cr>.cpp<ENTER>
map <leader>sec :split <c-r>=expand("%:p:r")<cr>.h<ENTER>
map <leader>sec :split <c-r>=expand("%:p:r")<cr>.cpp<ENTER><c-w>r
map <leader>vsec :vsplit <c-r>=expand("%:p:r")<cr>.h<ENTER>
map <leader>vsec :vsplit <c-r>=expand("%:p:r")<cr>.cpp<ENTER><c-w>r



" shortcuts for ctags
map <leader>ts :ts <ENTER>
map <leader>tn :tn <ENTER>
map <leader>tp :tp <ENTER>
map <leader>tf :tf <ENTER>
map <leader>tl :tl <ENTER>


" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif
" Remember info about open buffers on close
set viminfo^=%

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" => command definitons
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command Gct execute "!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q ."
