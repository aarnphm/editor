if vim.g.luasnip_latex_snippets_configured then return end
vim.g.luasnip_latex_snippets_configured = true

local function setup_luasnip_latex()
  if vim.g.luasnip_latex_snippets_loaded then return end
  vim.g.luasnip_latex_snippets_loaded = true

  Util.pack.load "luasnip-latex-snippets.nvim"

  local luasnip = require "luasnip"
  local latex_snippets = require "luasnip-latex-snippets"
  local utils = require "luasnip-latex-snippets.util.utils"

  local function add_emptyset_snippet(filetype)
    local is_math = utils.with_opts(utils.is_math, true)
    local no_backslash = utils.no_backslash
    local parse_snippet = luasnip.extend_decorator.apply(luasnip.parser.parse_snippet, {
      condition = utils.pipe { is_math, no_backslash },
    }) --[[@as function]]

    luasnip.add_snippets(filetype, {
      parse_snippet({ trig = "OO", name = "emptyset" }, "\\emptyset"),
    }, {
      type = "autosnippets",
      override_priority = 1000,
      key = "simple-emptyset-override",
    })
  end

  latex_snippets.setup { use_treesitter = true, allow_on_markdown = false }
  latex_snippets.setup_markdown()
  add_emptyset_snippet "markdown"
  add_emptyset_snippet "tex"

  for _, filetype in ipairs { "norg", "org", "rmd", "quarto" } do
    luasnip.filetype_extend(filetype, { "markdown" })
  end

  luasnip.config.setup { enable_autosnippets = true }
end

vim.api.nvim_create_autocmd("InsertEnter", {
  group = augroup "luasnip_latex",
  once = true,
  callback = setup_luasnip_latex,
})
