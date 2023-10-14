-- vim: ts=2 sw=2 et:
-- init packer
vim.cmd [[packadd packer.nvim]]
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.3',
    requires = { {'nvim-lua/plenary.nvim'} },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
      vim.keymap.set('n', '<C-p>', builtin.git_files, {})
      vim.keymap.set('n', '<leader>o', builtin.buffers, {})
    end
  }

  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function()
      require'nvim-treesitter.configs'.setup {
        -- A list of parser names, or "all" (the five listed parsers should always be installed)
        ensure_installed = { "go", "rust", "javascript", "typescript", "c", "lua", "vim", "vimdoc", "query", "yaml", "json" },

        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- Automatically install missing parsers when entering buffer
        -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
        auto_install = true,

        highlight = {
          enable = true,
          --enable = false,

          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          additional_vim_regex_highlighting = false,
        },
      }
    end
  }

  -- colorschemes
  use 'romainl/Apprentice'
  use { 'rose-pine/neovim', as = 'rose-pine' }
  use { "catppuccin/nvim", as = "catppuccin" }
  use { 'rebelot/kanagawa.nvim' }

  vim.cmd([[colorscheme kanagawa-dragon]])

  use {
	  'mbbill/undotree',
	  config = function()
		  vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
	  end,
  }

  use {
    'tpope/vim-fugitive',
    config = 'vim.keymap.set("n", "<leader>gs", vim.cmd.Git)',
  }

  use 'airblade/vim-gitgutter'

  use "sindrets/diffview.nvim"

  use {
	  'fatih/vim-go',
	  config = function()
		  -- turn off vim-go 'K'. use lsp's 'K'
		  vim.g.go_doc_keywordprg_enabled = 0
	  end
  }

  use {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    requires = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},
      {'williamboman/mason.nvim'},
      {'williamboman/mason-lspconfig.nvim'},

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-path'},
      {'saadparwaiz1/cmp_luasnip'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'hrsh7th/cmp-nvim-lua'},

      -- Snippets
      {'L3MON4D3/LuaSnip'},
    },
    config = function()
      local lsp_zero = require('lsp-zero')

      lsp_zero.on_attach(function(client, bufnr)
        -- see :help lsp-zero-keybindings
        -- to learn the available actions
        lsp_zero.default_keymaps({buffer = bufnr})

	--vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, {})
	vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, {})
      end)

      require('lspconfig').lua_ls.setup(lsp_zero.nvim_lua_ls())

      require('mason').setup({})
      require('mason-lspconfig').setup({
        ensure_installed = {},
        handlers = {
          lsp_zero.default_setup,
          gopls = function()
            require('lspconfig').gopls.setup({
              settings = {
                gopls = {
                  completeUnimported = true,
                  usePlaceholders = true,
                },
              },
            })
          end
        },
      })

      local cmp = require('cmp')
      local cmp_action = require('lsp-zero').cmp_action()

      cmp.setup({
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'luasnip'},
        },
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          -- `Enter` key to confirm completion
          -- ['<CR>'] = cmp.mapping.confirm({select = false}),

          -- Ctrl+Space to trigger completion menu
          -- ['<C-Space>'] = cmp.mapping.complete(),

          -- Navigate between snippet placeholder
          ['<C-f>'] = cmp_action.luasnip_jump_forward(),
          ['<C-b>'] = cmp_action.luasnip_jump_backward(),

          -- Scroll up and down in the completion documentation
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
        }),
      })

      vim.api.nvim_create_autocmd(
      "BufWritePre", {
        pattern = "*.go",
        callback = function()
          local params = vim.lsp.util.make_range_params()
          params.context = {only = {"source.organizeImports"}}
          -- buf_request_sync defaults to a 1000ms timeout. Depending on your
          -- machine and codebase, you may want longer. Add an additional
          -- argument after params if you find that you have to write the file
          -- twice for changes to be saved.
          -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
          local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
          for cid, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
              if r.edit then
                local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                vim.lsp.util.apply_workspace_edit(r.edit, enc)
              end
            end
          end
          vim.lsp.buf.format({async = false})
        end
      })
    end
  }

end)

---------
-- remaps
---------
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")

vim.keymap.set("x", "<leader>p", "\"_dP")

-- lsp keymaps
vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, {})


---------
-- set
---------
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
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.scrolloff = 8

--vim.opt.colorcolumn = "80"
vim.opt.colorcolumn = "0"

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
