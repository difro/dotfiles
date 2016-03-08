set nocompatible

"==============================
" Bundle
let $GIT_SSL_NO_VERIFY = 'true'
filetype off
filetype plugin indent off
set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#begin()

if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

call vundle#end()
filetype plugin indent on
"==============================

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
set hlsearch
set ignorecase	" search case insensitive...
set smartcase	" ... but not when pattern contains upper case letters

set showmatch	" highlight matching [{()}]
set nobackup

set cursorline	" highlight current line
set wildmenu	" visual autocomplete for command menu

colorscheme jellybeans
set background=dark

" Always jump to the last known cursor position.
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif

function! DiffToggle()
    if &diff
        diffoff!
    else
        VCSVimDiff
    endif
:endfunction


"""""""""""""""
let mapleader = ','

"=== Ctrl-P settingsj===
nmap <Leader>o		:CtrlPBuffer<CR>
nmap <Leader>O		:CtrlP<CR>

let g:ctrlp_cmd               = 'CtrlPMRU'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_match_window      = 'bottom,order:ttb,max:10'
let g:ctrlp_custom_ignore     = '\v\~$|\.(o|swp|pyc|wav|mp3|ogg|blend)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])|__init__\.py'
let g:ctrlp_switch_buffer     = 'et'


"=== vim-go ===
au FileType go nmap <Leader>gi <Plug>(go-info)
au FileType go nmap <Leader>gd <Plug>(go-doc-split)
au FileType go nmap <Leader>gr <Plug>(go-run)
au FileType go nmap <Leader>gb <Plug>(go-build)
au FileType go nmap <Leader>gt <Plug>(go-test)
"au FileType go nmap gd <Plug>(go-def-tab)
au FileType go nmap <Leader>gD <Plug>(go-def-split)
let g:go_fmt_command = "goimports" " automatically manager imports

"=== vim-beeter-whitespace ===
highlight ExtraWhitespace ctermbg=9

"=== 'junegunn/vim-easy-align' ===
" Easy align interactive
vnoremap <silent> <Enter> :EasyAlign<cr>

" 'bling/vim-airline'
let g:airline_detect_paste=1

" NERDTree
"nmap <silent> <leader>t		:NERDTreeTabsToggle<CR>
let g:nerdtree_tabs_open_on_console_startup = 0
nmap <silent><Leader>e	:NERDTreeToggle<CR>

" ----- xolox/vim-easytags settings -----
" Where to look for tags files
set tags=./tags;,~/.vimtags
" Sensible defaults
let g:easytags_events = ['BufReadPost', 'BufWritePost']
let g:easytags_async = 1
let g:easytags_dynamic_files = 1
let g:easytags_resolve_links = 1
let g:easytags_suppress_ctags_warning = 1

" ----- majutsushi/tagbar settings -----
" Open/close tagbar with ,b
nmap <silent> <leader>b :TagbarToggle<CR>
" Uncomment to open tagbar automatically whenever possible
"autocmd BufEnter * nested :call tagbar#autoopen(0)

" === neocomplete ===
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#sources#syntax#min_keyword_length = 3
if !exists('g:neocomplete#sources')
	let g:neocomplete#sources = {}
endif
let g:neocomplete#sources._ = ['buffer', 'member', 'tag', 'file', 'dictionary']
let g:neocomplete#sources.go = ['omni']
" disable sorting
call neocomplete#custom#source('_', 'sorters', [])
set completeopt-=preview
" === neocomplete ===

noremap <Tab> :call Next_buffer_or_next_tab()<cr>

fun! Next_buffer_or_next_tab()
	let num_buffers = len(tabpagebuflist())
	echo num_buffers
	if (num_buffers <= 1)
		:tabnext
	else
		:exe "normal \<C-w>\<C-w>"
	endif
endf

"=== key mappings ===
nmap <F12> :cs kill -1<CR>:!cscope -Rb<CR>:cs add cscope.out<CR>

nmap <F2> 		:call DiffToggle()<CR>
nmap <Leader>n		:setlocal number!<CR>
nmap <Leader>p		:set paste!<CR>
nmap <Leader><space>	:nohlsearch<CR>
nmap <C-e>		:b#<CR>
nmap <Leader>g		:GitGutterToggle<CR>
nmap <silent> <leader>V :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>
nmap <Leader>h          :e %:p:s,.h$,.X123X,:s,.c$,.h,:s,.X123X$,.c,<CR>

" =============================================
let s:host_vimrc = $HOME . '/.vimrc.' . hostname()
if filereadable(s:host_vimrc)
	execute 'source ' . s:host_vimrc
endif
