-- lua/snippets/markdown.lua
-- Tree-sitter aware math snippets for Markdown
-- These snippets work with Neovim’s built-in snippet API via mini.snippets.
-- They are only offered/expand inside an inline or display math zone (detected
-- with Tree-sitter).  Outside math they stay silent and do not pollute the
-- completion menu.

local ts = vim.treesitter
local MiniSnips = require('mini.snippets')
local s, t, i = MiniSnips.snippet, MiniSnips.text, MiniSnips.insert

--------------------------------------------------------------------------------
-- Helper: are we currently inside a markdown math node? -----------------------
--------------------------------------------------------------------------------

---Return the treesitter node at `pos` (current cursor when omitted).
---@param pos? integer[] 0-indexed {row,col}
local function get_node(pos)
  if pos then
    return ts.get_node({ pos = pos })
  end
  -- try normal cursor and one char to the left to catch edge cases at eol
  local row, col = vim.api.nvim_win_get_cursor(0)
  local node = ts.get_node({ pos = { row - 1, col } })
  if not node and col > 0 then
    node = ts.get_node({ pos = { row - 1, col - 1 } })
  end
  return node
end

---Detect whether the cursor is inside an inline or display math treesitter node.
---@return boolean
local function in_math()
  local node = get_node()
  while node do
    local type = node:type()
    -- NOTE: the exact node names come from the markdown parser (nvim-tree-sitter)
    if type == 'inline_math' or type == 'display_math' or type == 'math_block' then
      return true
    end
    node = node:parent()
  end
  return false
end

--------------------------------------------------------------------------------
-- Snippet definitions ----------------------------------------------------------
--------------------------------------------------------------------------------

local snippets = {
  -- align environment
  s('ali', {
    t({ '\\begin{align}', '\t' }),
    i(1),
    t({ '', '\\end{align}' }),
  }, { condition = in_math }),

  -- fraction \frac{•}{•}
  s({ trig = 'fr', name = 'frac' }, {
    t('\\frac{'), i(1), t('}{'), i(2), t('}'),
  }, { condition = in_math }),

  -- summation \sum_{i=1}^{n} •
  s('sm', {
    t('\\sum_{'), i(1, 'i=1'), t('}^{'), i(2, 'n'), t('} '), i(3),
  }, { condition = in_math }),

  -- plus/minus
  s('pm', { t('\\pm') }, { condition = in_math }),

  -- infinity
  s('inf', { t('\\infty') }, { condition = in_math }),

  -- hat{•}
  s('hat', { t('\\hat{'), i(1), t('}') }, { condition = in_math }),
}

-- Register snippets for the markdown filetype
MiniSnips.add('markdown', snippets)

--------------------------------------------------------------------------------
-- Optional: filter completion items from mini.snippets so they appear only ----
--           inside math zones when using nvim-cmp. ----------------------------
--------------------------------------------------------------------------------

if pcall(require, 'cmp') then
  local cmp = require('cmp')
  local cfg = require('cmp.config')
  -- Append a dedicated entry for mini_snippets with a filter that reuses `in_math`.
  cmp.setup.filetype('markdown', {
    sources = cmp.config.sources({
      { name = 'mini_snippets', option = { filter = in_math } },
    }, {}) -- keep existing sources untouched
  })
end

return {}