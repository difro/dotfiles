vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.updatetime = 100

vim.opt.expandtab = false
vim.opt.tabstop = 8
vim.opt.shiftwidth = 8

vim.opt.smartindent = true

vim.opt.wrap = true

vim.opt.laststatus = 2

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. ".vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.scrolloff = 8

vim.opt.colorcolumn = "80"

vim.opt.wildmenu = true
--vim.opt.cursorline = true

vim.g.mapleader = " "

-- Always jump to the last known cursor position
vim.api.nvim_exec([[
	augroup PreserveCursorPosition
	autocmd!
	autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif
	augroup END
]], false)
