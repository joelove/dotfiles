return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- File explorer: nvim-tree.lua (the most popular Neovim filetree and the one
  -- bundled with NvChad). The opts below are deep-merged on top of NvChad's
  -- defaults in ~/.local/share/nvim/lazy/NvChad/lua/nvchad/configs/nvimtree.lua
  {
    "nvim-tree/nvim-tree.lua",
    -- NvChad only lazy-loads this on NvimTreeToggle/NvimTreeFocus, so also load
    -- it at startup in order to show the sidebar by default.
    event = "VeryLazy",
    opts = {
      git = { enable = true, ignore = false },
      diagnostics = { enable = true, show_on_dirs = true },
      filesystem_watchers = { enable = true },
      view = { width = 35 },
      renderer = {
        group_empty = true,
        highlight_git = true,
        highlight_diagnostics = "name",
      },
    },
    config = function(_, opts)
      require("nvim-tree").setup(opts)

      -- Show the sidebar by default for a real file, a [No Name] buffer or a
      -- directory. Skip special buffers (terminals, quickfix, help, ...) and
      -- git-invoked editors such as COMMIT_EDITMSG. `focus = false` keeps the
      -- cursor in the buffer; `find_file` highlights it in the tree.
      local api = require("nvim-tree.api")
      local buf = vim.api.nvim_get_current_buf()
      local name = vim.api.nvim_buf_get_name(buf)
      local openable = name == "" or vim.fn.filereadable(name) == 1 or vim.fn.isdirectory(name) == 1
      local special = vim.bo[buf].buftype ~= "" or name:find("/%.git/") ~= nil
      if openable and not special and not api.tree.is_visible() then
        api.tree.toggle({ focus = false, find_file = true })
      end
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },

  -- GitHub PR review in this nvim pane. gh-dash stays the triage/approve
  -- dashboard; octo does inline review comments, suggestions, request-changes
  -- and thread resolution.
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      picker = "telescope",
      enable_builtin = true,
      -- The gh token has repo scope but not read:project; silence the warning.
      suppress_missing_scope = { projects_v2 = true },
    },
    config = function(_, opts)
      require("octo").setup(opts)
      vim.treesitter.language.register("markdown", "octo")
    end,
  },
}
