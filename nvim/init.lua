-- Set <space> as the leader key
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install package manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
local plugins = {
  -- NOTE: First, some plugins that don't require any configuration

  -- the premier Vim plugin for Git
  'tpope/vim-fugitive',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- Useful plugin to show you pending keybinds.
  {
    'folke/which-key.nvim',
    dependencies = {
      'echasnovski/mini.icons'
    },
    config = function()
      require"which-key".setup({
        notify = false,
      })
      require('which-key').add {
        {'<leader>c', group = '[C]ode or [C]opilot' },
        {'<leader>d', group = '[D]ocument' },
        {'<leader>g', group = '[G]it or [G]o' },
        {'<leader>u', group = '[U]pdate' },
        {'<leader>s', group = '[S]earch' },
        {'<leader>t', group = '[T]oggle' },
        {'<leader>w', group = '[W]orkspace' },
      }
    end
  },

  -- DAP (Debug Adapter Protocol)
  -- 'mfussenegger/nvim-dap',
  -- 'rcarriga/nvim-dap-ui',
  -- 'theHamsta/nvim-dap-virtual-text',
  -- 'nvim-telescope/telescope-dap.nvim',

  -- NOTE: This is where your plugins related to LSP can be installed.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-buffer',
      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      numhl = true,
      word_diff = false,

      current_line_blame = false,

      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr) -- "git diff => gd"
        vim.keymap.set('n', '<leader>gd', require('gitsigns').preview_hunk, { buffer = bufnr, desc = 'Preview git hunk' })

        -- "git blame => gb"
        vim.keymap.set('n', '<leader>tb', require('gitsigns').toggle_current_line_blame, { buffer = bufnr, desc = 'Toggle current line git blame' })

        -- don't override the built-in and fugitive keymaps
        -- "[c" "]c" : jump to next/prev diff hunk
        local gs = package.loaded.gitsigns
        vim.keymap.set({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Jump to next hunk' })
        vim.keymap.set({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Jump to previous hunk' })
      end,
    },
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = true,
        --theme = 'onedark',
        --theme = 'papercolor_dark',
        theme = 'seoul256',
        --component_separators = '|',
        --section_separators = '',
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},

      },
      sections = {
        lualine_c = {
          {
            'filename',
            path = 1,
          },
        },
      },
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- See `:help ibl`
    main = 'ibl',
    opts = {
      scope = {
        enabled = false,
      },
      indent = {
        char = '▏',
        --char = '·',
      },
    },
    config = function(_, opts)
      require("ibl").setup(opts)
      vim.keymap.set('n', '<leader>ti', '<cmd>IBLToggle<CR>', { desc = 'Toggle IBL' })
    end,
  },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = 'master',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    config = function ()
      require('telescope').setup {
        defaults = {
          layout_strategy = 'vertical',
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
            },
          },
          path_display = {
            filename_first = {
              reverse_directories = true
            },
          }
        },
      }

      -- Enable telescope fzf native, if installed
      pcall(require('telescope').load_extension, 'fzf')

 
     -- See `:help telescope.builtin`
      -- vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
      vim.keymap.set('n', '<M-p>', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
      vim.keymap.set('n', '<D-p>', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })

      -- macOS Option+p outputs π character, map it directly
      vim.keymap.set('n', 'π', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files (Option+p)' })

      vim.keymap.set('n', '<leader>o', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>O', require('telescope.builtin').find_files, { desc = '[O]pen Files' })
      vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>sn', require('telescope').extensions.notify.notify, { desc = '[S]earch [N]otify' })
      vim.keymap.set('n', '<leader>p', require('telescope.builtin').registers, { desc = '[P]aste register' })
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

    end
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
    config = function()
      require'nvim-treesitter.configs'.setup {
        -- A list of parser names, or "all" (the five listed parsers should always be installed)
        ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash', "yaml", "json" },

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
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<CR>",
            node_incremental = "<CR>",
            scope_incremental = "<Tab>",
            node_decremental = "<S-Tab>",
          },
          is_supported = function()
            local ct = vim.fn.getcmdwintype()
            if ct ~= "" then return false end
            return true
          end,
        },
        matchup = {
          enable = true,              -- mandatory, false will disable the whole extension
        },
        prefer_git = true,
      }
    end,
  },

  {
    'mbbill/undotree',
    keys = {
      { '<leader>tu', function() vim.cmd.UndotreeToggle() end, desc = 'Toggle undotree' },
    },
  },

  {
    'nvim-tree/nvim-tree.lua',
    keys = {
      { '<leader>tt', function() vim.cmd.NvimTreeFindFileToggle() end, desc = 'Toggle nvimTree' },
    },
    config = function()
      require('nvim-tree').setup {}
    end,
  },

  {
    'pwntester/octo.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    -- see https://github.com/pwntester/octo.nvim/issues/685
    commit = 'f09ff9413652e3c06a6817ba6284591c00121fe0',
    pin = true,
    config = function()
      require"octo".setup({
        github_hostname = "oss.navercorp.com",
        suppress_missing_scope = {
          projects_v2 = true,
        },
        use_local_fs = true,
      })
    end
  },

  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup({
        icons = false,
        dap_debug_gui = {
          layouts = {
            {
              elements = {      -- Elements can be strings or table with id and size keys.        { id = "breakpoints", size = 0.2 },        
              "console",
              "repl",
              "watches",
              "stacks",
            },
            size = 80, -- 80 columns      
            position = "right",
          },
          {
            elements = {
              "scopes",
            },
            size = 0.25, -- 25% of total lines
            position = "bottom",
          },
        },
      },
      remap_commands = { GoDoc = false },
      })
    end,
    event = {"CmdlineEnter"},
    ft = {"go", 'gomod'},
    keys = {
      { '<leader>gt', function() vim.cmd.GoTestPkg() end, desc = 'GoTestPkg' },
    },
    --build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
  },

  {
    "miversen33/sunglasses.nvim",
    opts = {
      filter_type = "SHADE",
      filter_percent = .35,
      excluded_filetypes = { "qf", "dashboard", "lspsagafinder", "packer", "checkhealth", "mason", "NvimTree", "neo-tree", "plugin", "lazy", "TelescopePrompt", "alpha", "toggleterm", "sagafinder", "better_term", "fugitiveblame", "starter", "NeogitPopup", "NeogitStatus", "DiffviewFiles", "DiffviewFileHistory", "DressingInput", "spectre_panel", "zsh", "registers", "startuptime", "OverseerList", "Navbuddy", "noice", "notify", "saga_codeaction", "sagarename" },
    },
    keys = {
      { '<leader>ts', function() vim.cmd.SunglassesEnableToggle() end, desc = 'Toggle Sunglasses' },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {
      enable = true,
    },
  },

  {
    "andymass/vim-matchup",
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end
  },

  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true },

  {
    "github/copilot.vim",
    lazy = false,
    -- tag = 'v1.56.0',
  },


  {
    'nvim-telescope/telescope-ui-select.nvim',
    config = function()
      require("telescope").load_extension("ui-select")
    end
  },

  {
    "rcarriga/nvim-notify",
    config = function()
      vim.notify = require("notify")
      require("notify").setup({
        background_colour = "#000000",
      })
    end,
  },

  {
    "fredrikaverpil/godoc.nvim",
    version = "*",
    dependencies = {
      { "nvim-telescope/telescope.nvim" }, -- optional
      {
        "nvim-treesitter/nvim-treesitter",
        opts = {
          ensure_installed = { "go" },
        },
      },
    },
    build = "go install github.com/lotusirous/gostdsym/stdsym@latest", -- optional
    opts = {
      adapters = {
        {
          name = "go",
          opts = {
            command = "GoDoc", -- the vim command to invoke Go documentation
            get_syntax_info = function()
              return {
                filetype = "godoc", -- filetype for the buffer
                language = "go", -- tree-sitter parser, for syntax highlighting
              }
            end,
          },
        },
      },
      window = {
        type = "split", -- split | vsplit
      },

      picker = {
        type = "telescope",
      },
    }, -- see further down below for configuration
  },

  {
    "difro/nvim-lspimport",
    branch = "nvim11",
  },

  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = function(_, opts)
      require("claudecode").setup(opts)
      vim.api.nvim_create_autocmd("QuitPre", {
        callback = function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(buf) and vim.b[buf].claudecode_diff_tab_name then
              vim.bo[buf].modified = false
            end
          end
        end,
      })
    end,
    keys = {
      { "<leader>cc", nil, desc = "AI/Claude Code" },
      { "<leader>ccc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>ccf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      -- { "<C-,>", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude", mode = { "n", "x" } },
      { "<leader>ccr", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>ccC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>ccm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>ccb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>ccs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        "<leader>ccs",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
      },
      -- Diff management
      { "<leader>cca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ccd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
    opts = {
      focus_after_send = true,

      terminal = {
        provider = require("claude-tmux-provider"),
      },

      diff_opts = {
        layout = "vertical",
        open_in_new_tab = true,
        keep_terminal_focus = true,
      },
    },
  },
}

for _, p in ipairs(require('colors')) do
  table.insert(plugins, p)
end

require('lazy').setup(plugins, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = 'split'

-- Make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse mode
vim.o.mouse = ''

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.o.clipboard = 'unnamedplus'

-- Enable break indent
-- vim.o.breakindent = true

-- Save undo history
vim.o.swapfile = false
vim.o.backup = false
vim.o.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.o.undofile = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 100
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.laststatus = 2
vim.opt.wrap = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")

vim.keymap.set('n', '<leader>CD', ":cd %:p:h<CR>" , { desc = '[C]hange Dir' })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

vim.diagnostic.config{
  float={border="single"}
}

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
-- local on_attach = function(_, bufnr)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    -- NOTE: Remember that lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself
    -- many times.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local nmap = function(keys, func, desc)
      if desc then
        desc = 'LSP: ' .. desc
      end

      vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    --nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

    nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
    nmap('<leader>dd', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    -- Format on save configuration per filetype
    local format_config = {
      python = {
        pattern = "*.py",
        check_vscode_settings = true,
        actions = {
          { kind = "format" },
          { kind = "source.fixAll", wait = 100 },
          { kind = "source.organizeImports.ruff" },
          { kind = "lspimport" },
        },
      },
    }

    -- Check if formatting should be enabled based on .vscode/settings.json
    local function should_format_vscode(bufnr, filetype)
      local path = vim.api.nvim_buf_get_name(bufnr)
      if path == "" then return false end

      local settings = vim.fs.find(".vscode/settings.json", {
        path = vim.fs.dirname(path),
        upward = true,
        stop = vim.uv.os_homedir(),
      })[1]
      if not settings then return false end

      local ok, cfg = pcall(vim.fn.json_decode, table.concat(vim.fn.readfile(settings), "\n"))
      if not ok then return false end

      local lang_config = cfg["[" .. filetype .. "]"]
      return lang_config and lang_config["editor.formatOnSave"] == true
    end

    -- Execute format actions for a buffer
    local function execute_format_actions(bufnr, actions)
      for _, action in ipairs(actions) do
        if action.kind == "format" then
          vim.lsp.buf.format({ bufnr = bufnr, async = false })
        elseif action.kind == "lspimport" then
          require("lspimport").import()
        else
          vim.lsp.buf.code_action({
            bufnr = bufnr,
            context = { only = { action.kind } },
            apply = true,
          })
        end

        if action.wait then
          vim.wait(action.wait)
        end
      end
    end

    -- Create autocmds for each configured filetype
    local augroup = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })
    for _, config in pairs(format_config) do
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        pattern = config.pattern,
        callback = function(event)
          local filetype = vim.bo[event.buf].filetype

          -- Check vscode settings if required
          if config.check_vscode_settings and not should_format_vscode(event.buf, filetype) then
            return
          end

          execute_format_actions(event.buf, config.actions)
        end,
      })
    end

    -- Go specific format on save (requires different handling)
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      pattern = "*.go",
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local client = vim.lsp.get_active_clients({ bufnr = bufnr })[1]

        if not client then
          vim.lsp.buf.format({ async = false })
          return
        end

        -- Organize imports using buf_request_sync for synchronous execution
        local params = vim.lsp.util.make_range_params(nil, client.offset_encoding)
        params.context = { only = { "source.organizeImports" } }
        local result = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 1000)

        if result then
          for cid, res in pairs(result) do
            for _, r in pairs(res.result or {}) do
              if r.edit then
                local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                vim.lsp.util.apply_workspace_edit(r.edit, enc)
              end
            end
          end
        end

        -- Format after organizing imports
        vim.lsp.buf.format({ async = false })
      end,
    })

    -- See `:help K` for why this keymap
    -- nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    -- nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

    -- Lesser used LSP functionality
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    --nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    --nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    --nmap('<leader>wl', function()
    --  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    --end, '[W]orkspace [L]ist Folders')

    -- Create a command `:Format` local to the LSP buffer
    --vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    --  vim.lsp.buf.format()
    --end, { desc = 'Format current buffer with LSP' })
  end,
})

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },
  gopls = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      -- hints = {
      --   rangeVariableTypes = true,
      --   parameterNames = true,
      --   constantValues = true,
      --   assignVariableTypes = true,
      --   compositeLiteralFields = true,
      --   compositeLiteralTypes = true,
      --   functionTypeParameters = true,
      -- },
    },
  },
}

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)


-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'
--
mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
--
  handlers = {
    function(server_name)
      local opts = {
        capabilities = capabilities,
        -- settings = servers[server_name],
      }

      vim.lsp.config[server_name] = opts
      vim.lsp.enable(server_name)
    end,
  },
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  --[[ experimental = {
    ghost_text = true,
  }, ]]

  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    -- ['<C-n>'] = cmp.mapping.select_next_item( { behavior = cmp.SelectBehavior.Select } ),
    -- ['<C-p>'] = cmp.mapping.select_prev_item( { behavior = cmp.SelectBehavior.Select } ),
    -- ['<C-e>'] = cmp.mapping.abort(),
    -- ["<C-b>"] = cmp.mapping(cmp.mapping.complete({
    --   reason = cmp.ContextReason.Auto,
    -- }), {"i", "c"}),

    -- Navigate between snippet placeholder
    ['<C-n>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-p>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),

    -- Scroll up and down in the completion documentation
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<CR>'] = cmp.mapping.confirm {
     behavior = cmp.ConfirmBehavior.Replace,
     select = true,
    },
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  completion = {
    completeopt = 'menu,menuone,noselect',
  },
  preselect = cmp.PreselectMode.None,
}
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline({
    -- Use default nvim history scrolling
    ["<C-n>"] = {
      c = false,
    },
    ["<C-p>"] = {
      c = false,
    },
  }),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    {
      name = 'cmdline',
      option = {
        ignore_cmds = { 'Man', '!' }
      }
    }
  })
})

-- Always jump to the last known cursor position
local preserve_cursor_group = vim.api.nvim_create_augroup('PreserveCursorPosition', { clear = true })
vim.api.nvim_create_autocmd('BufReadPost', {
  group = preserve_cursor_group,
  pattern = '*',
  callback = function()
    local line = vim.fn.line
    if line("'\"") > 0 and line("'\"") <= line("$") then
      vim.cmd('normal! g`"')
    end
  end,
})

-- Add border to 'K' hover
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
})

-- Update Pkgs
vim.keymap.set('n', '<leader>ul', require("lazy").sync, { desc = '[Update] Lazy' })
vim.keymap.set('n', '<leader>um', vim.cmd.Mason, { desc = '[Update] Mason' })

-- -- Set conceallevel=2 for markdown
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "markdown",
--   callback = function()
--     vim.opt.conceallevel = 2
--   end,
-- })

-- initialize global var to false -> nvim-cmp turned off per default
vim.g.cmptoggle = true

cmp.setup {
  enabled = function()
    return vim.g.cmptoggle
  end
}
vim.keymap.set("n", "<leader>tc", "<cmd>lua vim.g.cmptoggle = not vim.g.cmptoggle<CR>", { desc = "toggle nvim-cmp" })

--
-- vim.keymap.set({ 'n' }, '<C-s>', function()       require('lsp_signature').toggle_float_win()
-- end, { silent = true, noremap = true, desc = 'toggle signature' })
-- require "lsp_signature".setup({
--   bind = true,
--   handler_opts = {
--     border = "rounded"
--   },
--   hint_enable = false,
--   always_trigger = true,
--   auto_close_after = nil,
-- })

-- remember marks/oldfiles for the last 1000 files
vim.opt.shada = "!,'1000,<50,s10,h"

-- Load $(hostname).lua
local hostname = io.popen("hostname -s"):read("*l")
local config_filename = hostname .. ".lua"
local config_path = vim.fn.stdpath('config') .. '/' .. config_filename

if vim.uv.fs_stat(config_path) then
    dofile(config_path)
end

-- Set default colorscheme
vim.api.nvim_create_autocmd('VimEnter', {
  pattern = '*',
  callback = function()
    vim.cmd.colorscheme 'catppuccin-mocha'
    pcall(vim.cmd.SunglassesDisable)
  end,
})

if vim.fn.has('nvim') == 1 then
  vim.keymap.set('t', '<M-[>', '<C-\\><C-n>')
  vim.keymap.set('t', '"', '<C-\\><C-n>')

  -- Terminal mode window navigation
  vim.keymap.set('t', '<C-w>h', '<C-\\><C-n><C-w>h')
  vim.keymap.set('t', '<C-w>j', '<C-\\><C-n><C-w>j')
  vim.keymap.set('t', '<C-w>k', '<C-\\><C-n><C-w>k')
  vim.keymap.set('t', '<C-w>l', '<C-\\><C-n><C-w>l')
end

-- vim.diagnostic.config({
--   -- Use the default configuration
--   virtual_lines = true
--
--   -- Alternatively, customize specific options
--   -- virtual_lines = {
--   --  -- Only show virtual line diagnostics for the current cursor line
--   --  current_line = true,
--   -- },
-- })
--
-- Load Claude Translate plugin
require('claude-translate').setup()

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
