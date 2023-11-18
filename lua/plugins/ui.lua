local dropbar_enable = {
  "PlenaryTestPopup",
  "help",
  "lspinfo",
  "man",
  "notify",
  "gitcommit",
  "qf",
  "query",
  "man",
  "nowrite",
  "fugitive",
  "prompt",
  "spectre_panel",
  "startuptime",
  "tsplayground",
  "neorepl",
  "neo-tree",
  "alpha",
  "toggleterm",
  "health",
  "nofile",
  "scratch",
  "starter",
  "",
}

return {
  {
    "Bekaboo/dropbar.nvim",
    enabled = vim.fn.has "nvim-0.10" == 1,
    event = { "BufReadPre", "BufNewFile" },
    ---@type dropbar_configs_t
    opts = {
      general = {
        ---@type boolean|fun(buf:integer, win: integer): boolean
        enable = function(buf, win)
          return not vim.api.nvim_win_get_config(win).zindex
            and not vim.wo[win].diff
            and not vim.tbl_contains(dropbar_enable, vim.bo[buf].filetype)
        end,
      },
      icons = {
        enable = true,
        ui = {
          bar = { separator = "  ", extends = "…" },
          menu = { separator = " ", indicator = "  " },
        },
      },
    },
  },
  {
    "stevearc/dressing.nvim",
    lazy = true,
    opts = {
      input = {
        enabled = true,
        override = function(config) return vim.tbl_deep_extend("force", config, { col = -1, row = 0 }) end,
      },
      select = { enabled = true, backend = "telescope", trim_prompt = true },
    },
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load { plugins = { "dressing.nvim" } }
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load { plugins = { "dressing.nvim" } }
        return vim.ui.input(...)
      end
    end,
  },
  {
    "folke/which-key.nvim",
    event = "BufReadPost",
    opts = { plugins = { presets = { operators = false } } },
    config = function(_, opts) require("which-key").setup(opts) end,
  },
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = { plugins = { gitsigns = { enabled = true }, alacritty = { enabled = true } } },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = Util.lazy_file_events,
    main = "ibl",
    opts = {
      indent = { char = "│", tab_char = "│" },
      scope = { enabled = false },
      exclude = {
        filetypes = {
          "", -- for all buffers without a file type
          "alpha",
          "fugitive",
          "aerial",
          "git",
          "gitcommit",
          "help",
          "json",
          "log",
          "markdown",
          "neo-tree",
          "Outline",
          "startify",
          "TelescopePrompt",
          "txt",
          "undotree",
          "vimwiki",
          "vista",
          "lazyterm",
        },
        buftypes = { "terminal", "nofile", "quickfix", "prompt" },
      },
    },
    config = function(_, opts) require("ibl").setup(opts) end,
  },
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = { providers = { "lsp" } },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)

      local imap = function(key, dir, buffer)
        vim.keymap.set(
          "n",
          key,
          function() require("illuminate")["goto_" .. dir .. "_reference"](false) end,
          { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer }
        )
      end

      imap("]]", "next")
      imap("[[", "prev")

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          imap("]]", "next", buffer)
          imap("[[", "prev", buffer)
        end,
      })
    end,
  },
}
