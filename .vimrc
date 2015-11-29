" init vundle
set rtp+=~/.vim/bundle/Vundle/
call vundle#rc()

" vundle packages
Bundle 'gmarik/vundle'
Bundle 'scrooloose/nerdtree'
Plugin 'chriskempson/base16-vim'

" init vundle
set rtp+=~/.vim/bundle/Vundle/
call vundle#rc()

" vundle packages
Bundle 'gmarik/vundle'
Bundle 'scrooloose/nerdtree'
Plugin 'chriskempson/base16-vim'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" => general settings
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" enable plugins by filetype
filetype plugin on
filetype indent on

" unix line endings
set ffs=unix,dos

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

" disable continued comments for all files
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Show matching brackets
set showmatch
set matchtime=2


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

" configure backspace
set backspace=eol,start,indent

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
let base16colorspace=256
set background=dark
colorscheme base16-default

" show trailing whitespaces
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" remove trailing whitespaces
nnoremap <Leader>rtw :%s/\s\+$//e<CR>

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
map <leader>he :split <c-r>=SwapExtension()<cr><ENTER>
map <leader>ve :vsplit <c-r>=SwapExtension()<cr><ENTER>



" shortcuts for ctags
map <leader>ts :ts <ENTER>
map <leader>tn :tn <ENTER>
map <leader>tp :tp <ENTER>
map <leader>tf :tf <ENTER>
map <leader>tl :tl <ENTER>

" remove arrow keys
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

" shortcut for removing colon and adding brackets
map <leader>rc :Rc <ENTER>

" shortcut for generating cpp templates
map <leader>gcc :Gcc <ENTER>

" shortcut for resizing vertical split
map <leader>s :vertical resize -5 <ENTER>
map <leader>b :vertical resize +5 <ENTER>

" shortcut for buffer access
map <leader>ls :ls <ENTER>
map <leader>n :bnext <ENTER>
map <leader>p :blast <ENTER>
map <leader>sn :sbnext <ENTER>
map <leader>sp :sblast <ENTER>

" shortcut for beautify document
map <leader>bd :Bd <ENTER>

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif
" Remember info about open buffers on close
set viminfo^=%

" NerdTree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
map <leader>n :NERDTreeToggle<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" => command definitions
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command Gct execute "!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q ."
command Gcc call Load_ClassTemplate(expand("%"))
command Rc call ReplaceColon()
command Bd call BeautifyDocument()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" => function definitions
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! BeautifyDocument()
    exe "normal mz"
      %s/\r//ge
      %s/\s\+$//ge
    exe "normal `z"
    silent exe "retab"
endfunction
function! ReplaceColon()
    exe "s#;#\<CR>{\<CR>}"
    exe "normal! O"
    :startinsert
endfunction

function! SwapExtension()
    let [path, ext] = [expand('%:r'), expand('%:e')]
    if ext == 'h'
        let ext = 'cpp'
    elseif ext == 'cpp'
        let ext = 'h'
    endif
    return path . '.' . ext
endfunction

function! Load_ClassTemplate(filetype)
    if a:filetype =~ "\.h$"
        0r ~/.vim/templates/cpp/ClassHeader.h
    elseif a:filetype =~ "\.cpp$"
        0r ~/.vim/templates/cpp/ClassFile.cpp
    endif
    try
        silent exe "%s#\\\$tpl:name\\\$#".expand("%:t:r")."#g"
    catch
    endtry
    try
        silent exe "%s#\\\$tpl:preproc\\\$#".toupper(expand("%:t:r"))."#g"
    catch
    endtry
    1
endfunction

function! ClangCheckImpl(cmd)
  if &autowrite | wall | endif
  echo "Running " . a:cmd . " ..."
  let l:output = system(a:cmd)
  cexpr l:output
  cwindow
  let w:quickfix_title = a:cmd
  if v:shell_error != 0
    cc
  endif
  let g:clang_check_last_cmd = a:cmd
endfunction

function! ClangCheck()
  let l:filename = expand('%')
  if l:filename =~ '\.\(cpp\|cxx\|cc\|c\)$'
    call ClangCheckImpl("clang-check " . l:filename)
  elseif exists("g:clang_check_last_cmd")
    call ClangCheckImpl(g:clang_check_last_cmd)
  else
    echo "Can't detect file's compilation arguments and no previous clang-check invocation!"
  endif
endfunction

nmap <silent> <F5> :call ClangCheck()<CR><CR>

map <C-K> :pyf /usr/share/clang/clang-format.py<CR><CR>
imap <C-K> <c-o>:pyf /usr/share/clang/clang-format.py<CR><CR>
