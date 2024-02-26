return {
  {
    "akinsho/toggleterm.nvim",
    enabled = false,
    keys = {
      { "<C-t>", "<Esc><Cmd>ToggleTerm direction=vertical<CR>" },
      { "<C-\\>", "<Esc><Cmd>ToggleTerm direction=horizontal<CR>" },
    },
    ---@return ToggleTermConfig
    opts = function()
      if vim.g.simple_colorscheme == "rose-pine" then
        highlights = require "rose-pine.plugins.toggleterm"
      else
        highlights = {
          Normal = { link = "Normal" },
          NormalFloat = { link = "NormalFloat" },
          FloatBorder = { link = "FloatBorder" },
        }
      end
      return {
        ---@param term Terminal
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.33
          end
        end,
        highlights = highlights,
        open_mapping = false, -- [[<c-\>]],
        persist_mode = false,
      }
    end,
    config = function(_, opts)
      require("toggleterm").setup(opts)
      vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { silent = true, remap = false })
      vim.keymap.set("t", "jk", "<C-\\><C-n>", { silent = true, remap = false })
    end,
  },
  {
    "nvim-pack/nvim-spectre",
    event = "BufReadPost",
    cmd = "Spectre",
    build = false,
    opts = { open_cmd = "noswapfile vnew", live_update = true },
    keys = {
      { "<Leader>so", function() require("spectre").open() end, desc = "replace: Open panel" },
      { "<Leader>so", function() require("spectre").open_visual() end, desc = "replace: Open panel", mode = "v" },
      {
        "<Leader>sw",
        function() require("spectre").open_visual { select_word = true } end,
        desc = "replace: Open panel",
      },
    },
  },
  {
    "ggandor/flit.nvim",
    opts = { labeled_modes = "nx" },
    ---@diagnostic disable-next-line: assign-type-mismatch
    keys = function()
      ---@type table<string, LazyKeys[]>
      local ret = {}
      for _, key in ipairs { "f", "F", "t", "T" } do
        ret[#ret + 1] = { key, mode = { "n", "x", "o" }, desc = key }
      end
      return ret
    end,
  },
  {
    "ggandor/leap.nvim",
    keys = { { "gs", mode = { "n", "x", "o" }, desc = "motion: Leap from windows" } },
    config = function(_, opts)
      local leap = require "leap"
      for key, val in pairs(opts) do
        leap.opts[key] = val
      end
      leap.add_default_mappings(true)
      vim.keymap.del({ "x", "o" }, "x")
      vim.keymap.del({ "x", "o" }, "X")
    end,
  },
  { "tpope/vim-repeat", event = "VeryLazy" },
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile" },
    config = true,
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
      { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
      { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
    },
  },
  {
    "kevinhwang91/nvim-ufo",
    name = "ufo",
    event = "BufReadPost",
    dependencies = { "kevinhwang91/promise-async" },
    opts = {
      preview = { win_config = { border = BORDER } },
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (" 󰇘 %d "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end,
      provider_selector = function(bufnr, filetype, buftype)
        --- cascade from lsp -> treesitter -> indent
        ---@param buf number
        ---@return Promise
        local cascadeSelector = function(buf)
          local handleFallbackException = function(err, providerName)
            if type(err) == "string" and err:match "UfoFallbackException" then
              return require("ufo").getFolds(buf, providerName)
            else
              return require("promise").reject(err)
            end
          end

          return require("ufo")
            .getFolds(buf, "lsp")
            :catch(function(err) return handleFallbackException(err, "treesitter") end)
            :catch(function(err) return handleFallbackException(err, "indent") end)
        end
        return cascadeSelector
      end,
    },
    config = function(_, opts)
      local ufo = require "ufo"
      ufo.setup(opts)

      vim.keymap.set("n", "zR", ufo.openAllFolds, { desc = "fold: open all" })
      vim.keymap.set("n", "zM", ufo.closeAllFolds, { desc = "fold: close all" })
      vim.keymap.set("n", "zr", ufo.openFoldsExceptKinds, { desc = "fold: open all except" })
      vim.keymap.set("n", "zm", ufo.closeFoldsWith, { desc = "fold: close all with" })
    end,
  },
}
