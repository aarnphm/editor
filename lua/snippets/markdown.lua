-- lua/snippets/markdown.lua
-- Minimal LuaSnip snippets for LaTeX-in-Markdown workflows.
--
--  * `mk` – inline math: $$ · $$
--  * `dm` – display math block
--  * `ali` – \begin{align}···\end{align}
--  * `fr`  – \frac{·}{·}
--  * `sm`  – \sum_{·}^{·} ·
--
-- All math snippets expand only when the cursor is inside a markdown
-- Math node (inline_math or display_math) detected via Tree-sitter.
-- Place this file in `lua/snippets/markdown.lua` and make sure you load
-- LuaSnip from Lua (lazy-load or require). No further setup required.

local ls   = require('luasnip')
local s, i, t = ls.snippet, ls.insert_node, ls.text_node
local fmt  = require('luasnip.extras.fmt').fmt

--------------------------------------------------------------------------------
-- Simple math-zone detector ----------------------------------------------------
--------------------------------------------------------------------------------

---Return true when cursor sits inside an inline or display math node.
local function in_math()
  local pos  = { vim.fn.line('.') - 1, math.max(vim.fn.col('.') - 1, 0) }
  local node = vim.treesitter.get_node({ pos = pos })
  while node do
    local tp = node:type()
    if tp == 'inline_math' or tp == 'display_math' then
      return true
    end
    node = node:parent()
  end
  return false
end

local math_cond = function() return in_math() end

--------------------------------------------------------------------------------
-- Base $$ helpers --------------------------------------------------------------
--------------------------------------------------------------------------------

ls.add_snippets('markdown', {
  s('mk', { t('$$'), i(1), t('$$') }),
  s('dm', { t({'$$', ''}), i(1), t({'', '$$'}) }),
})

--------------------------------------------------------------------------------
-- Core LaTeX math snippets -----------------------------------------------------
--------------------------------------------------------------------------------

ls.add_snippets('markdown', {
  -- Align environment
  s('ali', {
    t({'\\begin{align}', '\t'}), i(1), t({'', '\\end{align}'})
  }, { condition = math_cond }),

  -- Fraction
  s('fr', fmt('\\frac{{{}}}{{{}}}', { i(1), i(2) }), { condition = math_cond }),

  -- Summation
  s('sm', fmt('\\sum_{{{}}}^{{{}}} {}', { i(1, 'i=1'), i(2,'n'), i(3) }), { condition = math_cond }),
}, { type = 'autosnippets' })