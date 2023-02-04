return function()
  local cmp = {
    name = "nvim-cmp",
    opts = { defer = false },
    disable = function()
      require("cmp").setup.buffer({ enabled = false })
    end,
  }

  require("bigfile").config({
    filesize = 1, -- size of the file in MiB
    pattern = { "*" }, -- autocmd pattern
    features = { -- features to disable
      "indent_blankline",
      "lsp",
      "illuminate",
      "treesitter",
      "syntax",
      "vimopts",
      cmp,
    },
  })
end
