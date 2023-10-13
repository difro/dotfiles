set nocompatible

" begin vim-plug
call plug#begin('~/.vim/plugged')
if filereadable(expand("~/.vimrc.plugins"))
  source ~/.vimrc.plugins
endif
call plug#end()
filetype plugin indent on
"==============================

syntax	on
set autoindent
set smartindent
set smarttab

set noexpandtab
set tabstop=8
set shiftwidth=8

set laststatus=2	" last window will have statusline always.
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

"colorscheme jellybeans
colorscheme apprentice
set background=dark

set number relativenumber
set updatetime=2000 " interval between swap file writes

set scrolloff=8

" Always jump to the last known cursor position.
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif

function! DiffToggle()
    if &diff
        diffoff!
    else
        VCSVimDiff
    endif
:endfunction

let mapleader = ' '

let g:markdown_fenced_languages = ['html', 'python', 'ruby', 'vim', 'go', 'c', 'javascript']

"=== Ctrl-P settings ===
nmap <Leader>o		      :CtrlPBuffer<CR>
nmap <Leader>O		      :CtrlP<CR>
let g:ctrlp_map               = '<c-p>'
let g:ctrlp_cmd               = 'CtrlPMRU'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_match_window      = 'bottom,order:btt,max:15'
let g:ctrlp_custom_ignore     = '\v\~$|\.(o|swp|pyc|wav|mp3|ogg|blend)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])|__init__\.py'
let g:ctrlp_switch_buffer     = 'et'

"=== vim-better-whitespace ===
highlight ExtraWhitespace ctermbg=9

"=== bling/vim-airline ===
let g:airline_detect_paste=1
"let g:airline_theme='jellybeans'

"=== NERDTree ===
let g:nerdtree_tabs_open_on_console_startup = 0
nmap <silent><Leader>e	:NERDTreeToggle<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""

"=== vim-go ===
au FileType go nmap <Leader>gi <Plug>(go-info)
au FileType go nmap <Leader>gd <Plug>(go-doc-split)
au FileType go nmap <Leader>gr <Plug>(go-run)
au FileType go nmap <Leader>gb <Plug>(go-build)
au FileType go nmap <Leader>gt <Plug>(go-test)
au FileType go nmap <Leader>gs :GoFillStruct<CR>
"au FileType go nmap gd <Plug>(go-def-tab)
"au FileType go nmap <Leader>gD <Plug>(go-def-split)
let g:go_fmt_command = "goimports" " automatically manager imports
"let g:go_def_mode = "gopls"
"let g:go_metalinter_enabled = 0
au FileType go nmap <C-\>s <Plug>(go-referrers)


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

"set completeopt=menu,noinsert,noselect
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
nmap <Leader>t		:cs kill -1<CR>:!cscope -Rb<CR>:cs add cscope.out<CR>

nmap <F2> 		:call DiffToggle()<CR>
nmap <Leader>n		:setlocal number!<CR>
nmap <Leader>p		:set paste!<CR>
nmap <Leader><space>	:nohlsearch<CR>
nmap <C-e>		:b#<CR>
"nmap <Leader>g		:GitGutterToggle<CR>
nmap <silent> <leader>V :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>
nmap <Leader>h          :e %:p:s,.h$,.X123X,:s,.c$,.h,:s,.X123X$,.c,<CR>

" =============================================
let s:host_vimrc = $HOME . '/.vimrc.' . system('hostname -s')
if filereadable(s:host_vimrc)
	execute 'source ' . s:host_vimrc
endif


" rust
let g:rustfmt_autosave = 1

" fancy space/tab
"set list listchars+=space:·
"set listchars+=tab:>-
"
"au filetype go inoremap <buffer> . .<C-x><C-o>
au filetype c inoremap <buffer> . .<C-x><C-o>

au filetype xml nmap <Leader>P :%!xmllint --format -<CR>
au filetype json nmap <Leader>P :%!jq .<CR>

""
" dense-analysis/ale
""

" As-you-type autocomplete
"set completeopt=menu,menuone,preview,noselect,noinsert
set completeopt=menu,menuone,popup,noselect,noinsert
"let g:ale_completion_enabled = 1

" Required, explicitly enable Elixir LS
" let g:ale_linters = {
" \  'rust': ['analyzer'],
" \  'c': ['gcc', 'cppcheck'],
" \}

 " navigate between erros
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

nnoremap <C-u> <C-u>zz
nnoremap <C-d> <C-d>zz

" navigate between erros
"nmap <silent> <C-k> <Plug>(ale_previous_wrap)
"nmap <silent> <C-j> <Plug>(ale_next_wrap)

let g:context_extend_regex = '^\s*\([]{})]\|end\|else\|case\>\|default\>\)'
let g:context_filetype_blacklist = ["json"]

" coc settings
function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

set cmdheight=2
" gh - get hint on whatever's under the cursor
nnoremap <silent> gh :call <SID>show_documentation()<CR>
" gi - go to implementation
nmap <silent> gi <Plug>(coc-implementation)
" gr - find references
"nmap <silent> gr <Plug>(coc-references)
"autocmd CursorHold * silent call <SID>show_documentation()

"inoremap <silent><expr> <TAB>
"      \ coc#pum#visible() ? coc#pum#next(1) :
"      \ CheckBackspace() ? "\<Tab>" :
"      \ coc#refresh()
"inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
"inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
"                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
function! CheckBackspace() abort
	let col = col('.') - 1
	return !col || getline('.')[col - 1]  =~# '\s'
endfunction


" Show all diagnostics.
"nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
nnoremap <silent> <space>a  :CocDiagnostics<cr>

let g:go_metalinter_enabled = []
let g:go_metalinter_command = 'golangci-lint'
"let g:go_metalinter_autosave = 1
"let g:go_metalinter_autosave_enabled = ['vet','revive','errcheck','staticcheck','unused','varcheck']
