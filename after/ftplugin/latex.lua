if vim.g.luasnip_latex_snippets_configured then return end
vim.g.luasnip_latex_snippets_configured = true

Util.pack.load "luasnip-latex-snippets.nvim"
require("luasnip-latex-snippets").setup { use_treesitter = true }
require("luasnip").config.setup { enable_autosnippets = true }
