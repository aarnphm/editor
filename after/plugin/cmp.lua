local cmp = require "cmp"

local cmp_format = function(opts)
  opts = opts or {}
  return function(entry, vim_item)
    if opts.before then vim_item = opts.before(entry, vim_item) end

    local item = icons.kind[vim_item.kind]
      or icons.type[vim_item.kind]
      or icons.cmp[vim_item.kind]
      or icons.kind.Undefined

    vim_item.kind = string.format("  %s  %s", item, vim_item.kind)

    if opts.maxwidth ~= nil then
      if opts.ellipsis_char == nil then
        vim_item.abbr = string.sub(vim_item.abbr, 1, opts.maxwidth)
      else
        local label = vim_item.abbr
        local truncated_label = vim.fn.strcharpart(label, 0, opts.maxwidth)
        if truncated_label ~= label then vim_item.abbr = truncated_label .. opts.ellipsis_char end
      end
    end
    return vim_item
  end
end

local check_backspace = function()
  local col = vim.fn.col "." - 1
  ---@diagnostic disable-next-line: param-type-mismatch
  local current_line = vim.fn.getline "."
  ---@diagnostic disable-next-line: undefined-field
  return col == 0 or current_line:sub(col, col):match "%s"
end

local compare = require "cmp.config.compare"

compare.lsp_scores = function(entry1, entry2)
  local diff
  if entry1.completion_item.score and entry2.completion_item.score then
    diff = (entry2.completion_item.score * entry2.score) - (entry1.completion_item.score * entry1.score)
  else
    diff = entry2.score - entry1.score
  end
  return (diff < 0)
end

---@param str string
---@return string
local replace_termcodes = function(str) return vim.api.nvim_replace_termcodes(str, true, true, true) end

vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

local opts = {
  preselect = cmp.PreselectMode.Item,
  completion = { completeopt = "menu,menuone,noinsert" },
  snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
  formatting = {
    fields = { "menu", "abbr", "kind" },
    format = function(entry, vim_item) return cmp_format { maxwidth = 80 }(entry, vim_item) end,
  },
  sorting = {
    priority_weight = 2,
    comparators = {
      compare.offset, -- Items closer to cursor will have lower priority
      compare.exact,
      -- compare.scopes,
      compare.lsp_scores,
      compare.sort_text,
      compare.score,
      compare.recently_used,
      -- compare.locality, -- Items closer to cursor will have higher priority, conflicts with `offset`
      compare.kind,
      compare.length,
      compare.order,
    },
  },
  experimental = { ghost_text = { hl_group = "CmpGhostText" } },
  matching = { disallow_partial_fuzzy_matching = false },
  performance = { async_budget = 1, max_view_entries = 120 },
  mapping = cmp.mapping.preset.insert {
    ["<CR>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ["<C-k>"] = cmp.mapping.select_prev_item(),
    ["<C-j>"] = cmp.mapping.select_next_item(),
    ["<Tab>"] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif require("luasnip").expand_or_jumpable() then
        vim.fn.feedkeys(replace_termcodes "<Plug>luasnip-expand-or-jump", "")
      elseif check_backspace() then
        vim.fn.feedkeys(replace_termcodes "<Tab>", "n")
      else
        fallback()
      end
    end,
    ["<S-Tab>"] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif require("luasnip").jumpable(-1) then
        vim.fn.feedkeys(replace_termcodes "<Plug>luasnip-jump-prev", "")
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = "nvim_lsp", max_item_count = 350 },
    { name = "buffer" },
    { name = "luasnip" },
    { name = "path" },
    { name = "emoji" },
  },
}

cmp.setup(opts)
