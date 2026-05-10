if vim.g.luasnip_latex_snippets_configured then return end
vim.g.luasnip_latex_snippets_configured = true

Util.pack.load "luasnip-latex-snippets.nvim"

local luasnip = require "luasnip"
local latex_snippets = require "luasnip-latex-snippets"

latex_snippets.setup { use_treesitter = true, allow_on_markdown = false }
latex_snippets.setup_markdown()

for _, filetype in ipairs { "norg", "org", "rmd", "quarto" } do
  luasnip.filetype_extend(filetype, { "markdown" })
end

luasnip.config.setup { enable_autosnippets = true }
