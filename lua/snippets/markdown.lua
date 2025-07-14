-- lua/snippets/markdown.lua
-- Markdown-specific snippets powered by **LuaSnip**.
--
-- • `mk` → `$$…$$` (inline)
-- • `dm` → display-math block
-- • LaTeX helpers (`ali`, `fr`, `sm`, `pm`, `inf`, `hat`, greek letters, …)
--   These are only active *inside* a math zone detected via Tree-sitter.
--
-- The file is discovered automatically by
-- `require("luasnip.loaders.from_lua").lazy_load()` when editing markdown.

local ls = require('luasnip')
local s  = ls.snippet
local t  = ls.text_node
local i  = ls.insert_node
local fmt = require('luasnip.extras.fmt').fmt

--------------------------------------------------------------------------------
-- Math-zone detector -----------------------------------------------------------
--------------------------------------------------------------------------------

local function in_math() --→ boolean
  -- Try node under cursor or the previous column (edge-case at EOL).
  local pos = { vim.fn.line('.') - 1, math.max(vim.fn.col('.') - 1, 0) }
  local node = vim.treesitter.get_node({ pos = pos })
  while node do
    local tp = node:type()
    if tp == 'inline_math' or tp == 'display_math' or tp == 'math_block' then
      return true
    end
    node = node:parent()
  end
  return false
end

local math_cond = function() return in_math() end

--------------------------------------------------------------------------------
-- Basic $$ triggers ------------------------------------------------------------
--------------------------------------------------------------------------------

ls.add_snippets('markdown', {
  -- Inline $$ … $$
  s('mk', { t('$$'), i(1), t('$$') }),

  -- Display math block
  s('dm', { t({'$$', ''}), i(1), t({'', '$$'}) }),
})

--------------------------------------------------------------------------------
-- LaTeX helpers (active only in math) -----------------------------------------
--------------------------------------------------------------------------------

local math_snips = {
  -- \begin{align} … \end{align}
  s({ trig = 'ali', name = 'align env' }, {
    t({'\\begin{align}', '\t'}), i(1), t({'', '\\end{align}'})
  }, { condition = math_cond }),

  -- \frac{…}{…}
  s('fr', fmt('\\frac{{{}}}{{{}}}', { i(1), i(2) }), { condition = math_cond }),

  -- Summation shortcut
  s('sm', fmt('\\sum_{{{}}}^{{{}}} {}', { i(1, 'i=1'), i(2,'n'), i(3) }), { condition = math_cond }),

  -- Quick symbols
  s('pm',  t('\\pm'),     { condition = math_cond }),
  s('inf', t('\\infty'),  { condition = math_cond }),
  s('hat', fmt('\\hat{{{}}}', { i(1) }), { condition = math_cond }),

  -- \left( … \right)
  s('lr', fmt('\\left( {} \\right)', { i(1) }), { condition = math_cond }),
  s('fl', fmt('\\lfloor {} \\rfloor', { i(1) }), { condition = math_cond }),
  s('ceil', fmt('\\lceil {} \\rceil', { i(1) }), { condition = math_cond }),
}

-- Greek letters autosnippets ;a → \alpha (in math)
local greek = {
  a='alpha', b='beta', g='gamma', d='delta', e='epsilon', z='zeta',
  h='eta', t='theta', i_='iota', k='kappa', l='lambda', m='mu', n='nu',
  x='xi', p='pi', r='rho', s='sigma', u='upsilon', f='phi', c='chi',
  q='psi', o='omega',
  A='Alpha', B='Beta', G='Gamma', D='Delta', E='Epsilon', Z='Zeta',
  H='Eta', T='Theta', I='Iota', K='Kappa', L='Lambda', M='Mu', N='Nu',
  X='Xi', P='Pi', R='Rho', S='Sigma', U='Upsilon', F='Phi', C='Chi',
  Q='Psi', O='Omega',
}
for key, name in pairs(greek) do
  table.insert(math_snips, s({ trig = ';'..key, wordTrig = false, snippetType='autosnippet' }, {
    t('\\'..name)
  }, { condition = math_cond }))
end

ls.add_snippets('markdown', math_snips, { type = 'autosnippets' })

--------------------------------------------------------------------------------
-- cmp integration (optional) ---------------------------------------------------
--------------------------------------------------------------------------------
-- If you use nvim-cmp with `cmp_luasnip` this section is not strictly required;
-- snippets will be filtered by ls.expandable() anyway.  The filter makes sure
-- we do NOT offer math-only snippets outside a math zone.
--------------------------------------------------------------------------------

if pcall(require, 'cmp') then
  local cmp = require('cmp')
  cmp.setup.filetype('markdown', {
    -- Keep existing sources and add/patch luasnip
    sorting = cmp.config.sorting.default_sorting(),
    sources = cmp.config.sources({
      { name = 'luasnip', option = { show_autosnippets = true, use_show_condition = true, get_bufnrs = function()
        if in_math() then return {vim.api.nvim_get_current_buf()} end -- only in math
        return {}
      end } },
    }, {})
  })
end