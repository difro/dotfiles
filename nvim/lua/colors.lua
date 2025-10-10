return {
  { 'rose-pine/neovim', name = 'rose-pine' },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        transparent_background = true,
      })
    end
  },
  { "arzg/vim-colors-xcode" },
  {
    'datsfilipe/vesper.nvim',
    config = function()
      require('vesper').setup({
        transparent = true,
      })
    end
  },
  { "folke/tokyonight.nvim" },
  {
    'rebelot/kanagawa.nvim',
    config = function()
      require("kanagawa").setup({
        transparent = false,
        theme = "dragon",
      })
    end
  },
  {
    "zenbones-theme/zenbones.nvim",
    dependencies = "rktjmp/lush.nvim",
    config = function()
      vim.g.zenbones_darken_comments = 5
    end
  },
  { 'nordtheme/vim' },
  { "savq/melange-nvim" },
  {
    "AlexvZyl/nordic.nvim",
    config = function()
      require('nordic').setup({
        reduced_blue = true,
        bright_border = true,
        telescope = {
          style = 'classic',
        },
        cursorline = {
          bold = false,
          bold_number = true,
          theme = 'light',
          blend = 0.99,
        },
      })
    end
  },
  {
    "neanias/everforest-nvim",
    version = false,
    config = function()
      require('everforest').setup({
        background = 'hard',
        transparent_background_level = 2,
      })
    end
  },
  {
    "thesimonho/kanagawa-paper.nvim",
    config = function()
      require("kanagawa-paper").setup({
        transparent = false,
      })
    end
  },
  { "Mofiqul/dracula.nvim" },
  {
    "loctvl842/monokai-pro.nvim",
    config = function()
      require("monokai-pro").setup({
        transparent_background = true,
        filter = "pro",
      })
    end
  }
}
