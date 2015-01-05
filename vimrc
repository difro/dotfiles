set nocompatible

syntax	on
set autoindent
set smartindent
set smarttab

set noexpandtab
set tabstop=8
set shiftwidth=8

set laststatus=2
set encoding=utf-8

set t_Co=256	" number of terminal colors
            
set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:~:.:h\")})%)%(\ %a%)
set title   

set showcmd
set incsearch
set ignorecase
set smartcase
set hlsearch

set showmatch
set nobackup


" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
autocmd BufReadPost *
\ if line("'\"") > 0 && line("'\"") <= line("$") |
\   exe "normal g`\"" |
\ endif

function! DiffToggle()
    if &diff
        diffoff
    else
        VCSVimDiff
    endif
:endfunction


au BufEnter *.html set omnifunc=htmlcomplete#CompleteTags

"""""""""""""""
" Bundle
let $GIT_SSL_NO_VERIFY = 'true'
filetype off
filetype plugin indent off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Install Vundle bundles
if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

set runtimepath+=/naver/opt/go/misc/vim
filetype plugin indent on

"""""""""""""""
let mapleader = ','


" Go related mappings
au FileType go nmap <Leader>i <Plug>(go-info)
au FileType go nmap <Leader>gd <Plug>(go-doc)
au FileType go nmap <Leader>r <Plug>(go-run)
au FileType go nmap <Leader>b <Plug>(go-build)
au FileType go nmap <Leader>t <Plug>(go-test)
au FileType go nmap gd <Plug>(go-def-tab)

" Ctrl-P settings
let g:ctrlp_map = '<Leader>t'
let g:ctrlp_match_window_bottom = 0
let g:ctrlp_match_window_reversed = 0
let g:ctrlp_custom_ignore = '\v\~$|\.(o|swp|pyc|wav|mp3|ogg|blend)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])|__init__\.py'
let g:ctrlp_working_path_mode = 0
let g:ctrlp_dotfiles = 0
let g:ctrlp_switch_buffer = 0

""" key mappings
nmap <F12> :cs kill -1<CR>:!cscope -Rb<CR>:cs add cscope.out<CR>

nmap ; 			:CtrlPBuffer<CR>
nmap <F2> 		:call DiffToggle()<CR>
nmap <Leader>n		:setlocal number!<CR>
nmap <Leader>p		:set paste!<CR>
nmap <Leader>q		:nohlsearch<CR>
nmap <C-e>		:b#<CR>
nmap <Leader>e		:NERDTreeToggle<CR>
"nmap <Leader>g		:GitGutterToggle<CR>
map <leader>l 		:Align
map <silent> <leader>V 	:source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>

nmap <Leader>h         :e %:p:s,.h$,.X123X,:s,.c$,.h,:s,.X123X$,.c,<CR>

set background=dark
color tir_black

" Go related mappings
au FileType go nmap <Leader>i <Plug>(go-info)
au FileType go nmap <Leader>gd <Plug>(go-doc)
au FileType go nmap <Leader>r <Plug>(go-run)
au FileType go nmap <Leader>b <Plug>(go-build)
au FileType go nmap <Leader>t <Plug>(go-test)
au FileType go nmap gd <Plug>(go-def-tab)

let s:host_vimrc = $HOME . '/.vimrc.' . hostname()
if filereadable(s:host_vimrc)
	execute 'source ' . s:host_vimrc
endif