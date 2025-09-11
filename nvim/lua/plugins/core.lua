return {
  {
    "LazyVim/LazyVim",
    vscode = true,
    opts = {
      -- colorscheme = "catppuccin",
      ui = {
        transparency = true,
      },
    },
  },
  {
    "tribela/transparent.nvim",
    event = "VimEnter",
    config = true,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "html" },
      highlight = { enable = true },
    },
  },
  -- {
  --   "jose-elias-alvarez/null-ls.nvim",
  --   opts = function(_, opts)
  --     local nls = require("null-ls")
  --     opts.sources = vim.list_extend(opts.sources, {
  --       nls.builtins.formatting.prettier,
  --     })
  --   end,
  -- },
  {
    "neovim/nvim-lspconfig",
    vscode = true,
    opts = {
      setup = {
        rust_analyzer = function()
          return true
        end,
      },
      servers = {
        rust_analyzer = {
          mason = false,
        },
      },
    },
  },
  { "tpope/vim-repeat", event = "VeryLazy", vscode = true },
  {
    "smoka7/hop.nvim",
    version = "*",
    opts = {
      keys = "etovxqpdygfblzhckisuran",
    },
  },
  { "ron-rs/ron.vim", vscode = true },
  {
    "nvim-lualine/lualine.nvim",
    vscode = true,
    optional = true, -- ���Ϊ��ѡ���
  },
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    opts = {
      term_colors = true,
      transparent_background = true,
      dim_inactive = {
        enabled = false, -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.15, -- percentage of the shade to apply to the inactive window
      },
    },
  },
  -- {
  --   "catppuccin/nvim",
  --   name = "catppuccin",
  --   priority = 1000,
  --   opts = {
  --     term_colors = true,
  --     transparent_background = true,
  --     dim_inactive = {
  --       enabled = false, -- dims the background color of inactive window
  --       shade = "dark",
  --       percentage = 0.15, -- percentage of the shade to apply to the inactive window
  --     },
  --     no_italic = false, -- Force no italic
  --     no_bold = false, -- Force no bold
  --     no_underline = false, -- Force no underline
  --     styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
  --       comments = { "italic" }, -- Change the style of comments
  --       conditionals = { "italic" },
  --       loops = {},
  --       functions = {},
  --       keywords = {},
  --       strings = {},
  --       variables = {},
  --       numbers = {},
  --       booleans = {},
  --       properties = {},
  --       types = {},
  --       operators = {},
  --       -- miscs = {}, -- Uncomment to turn off hard-coded styles
  --     },
  --     integrations = {
  --       cmp = true,
  --       gitsigns = true,
  --       treesitter = true,
  --       harpoon = true,
  --       telescope = true,
  --       mason = true,
  --       noice = true,
  --       notify = true,
  --       which_key = true,
  --       fidget = true,
  --       native_lsp = {
  --         enabled = true,
  --         virtual_text = {
  --           errors = { "italic" },
  --           hints = { "italic" },
  --           warnings = { "italic" },
  --           information = { "italic" },
  --         },
  --         underlines = {
  --           errors = { "underline" },
  --           hints = { "underline" },
  --           warnings = { "underline" },
  --           information = { "underline" },
  --         },
  --         inlay_hints = {
  --           background = true,
  --         },
  --       },
  --       mini = {
  --         enabled = true,
  --         indentscope_color = "",
  --       },
  --     },
  --   },
  --   config = function(_, opts)
  --     require("catppuccin").setup(opts)
  --     vim.cmd.colorscheme("catppuccin-macchiato")
  --   end,
  -- },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
  -- { "uga-rosa/ccc.nvim" },
  -- {
  --   "mfussenegger/nvim-dap",
  -- },
  -- {
  --   "rcarriga/nvim-dap-ui",
  -- },
  -- {
  --   "rustaceanvim/rustaceanvim",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "MunifTanjim/nui.nvim",
  --     "mfussenegger/nvim-dap",
  --     "rcarriga/nvim-dap-ui",
  --   },
  --   ft = "rust",
  --   config = true,
  -- },
}
