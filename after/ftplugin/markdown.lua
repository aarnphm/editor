Util.lsp.formatters({ "markdown", "markdown.mdx" }, Util.lsp.use_markdown_formatters)
Util.lint.linters({ "markdown", "markdown.mdx" }, { "markdownlint" })

local markdownlint_config_names = { ".markdownlint.jsonc", ".markdownlint.yaml", ".markdownlint.yml" }

local function markdownlint_config(path)
  path = path ~= "" and path or vim.api.nvim_buf_get_name(0)
  if path == "" then return nil end
  return vim.fs.find(markdownlint_config_names, { path = path, upward = true, type = "file" })[1]
end

Util.lint.linter("markdownlint", {
  args = {
    "--stdin",
    "--config",
    function() return markdownlint_config(vim.api.nvim_buf_get_name(0)) end,
  },
  condition = function(ctx) return markdownlint_config(ctx.filename) end,
})
local markdown_oxide_root_markers = { ".obsidian", ".moxide.toml" }

local function markdown_oxide_vault_root(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" then return nil end

  path = vim.uv.fs_realpath(path) or Util.norm(path)
  for _, vault in ipairs(_G.VAULTS or {}) do
    if type(vault) == "table" and type(vault.root) == "string" then
      local root = Util.norm(vim.fn.fnamemodify(vim.fn.expand(vault.root), ":p"))
      root = vim.uv.fs_realpath(root) or root
      if Util.lsp.path_is_under(path, root) then return root end
    end
  end
end

local function markdown_oxide_root(bufnr)
  return markdown_oxide_vault_root(bufnr) or vim.fs.root(bufnr, markdown_oxide_root_markers)
end

local markdown_oxide_config = {
  root_markers = markdown_oxide_root_markers,
  root_dir = function(bufnr, on_dir)
    local root = markdown_oxide_root(bufnr)
    if root then on_dir(root) end
  end,
  capabilities = {
    workspace = { didChangeWatchedFiles = { dynamicRegistration = true } },
  },
}
Util.lsp.on_attach("markdown_oxide", "disable_formatting", function(client)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
  client.server_capabilities.documentOnTypeFormattingProvider = nil
end)

local function start_markdown_oxide(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "markdown" then return end
  if Util.is_bigfile(bufnr) then return end
  if #vim.lsp.get_clients { bufnr = bufnr, name = "markdown_oxide" } > 0 then return end

  local root = markdown_oxide_root(bufnr)
  if not root then return end

  if not Util.lsp.server_is_available("markdown_oxide", markdown_oxide_config) then return end

  Util.lsp.prepend_mason_bin()
  if Util.pack and Util.pack.get "nvim-lspconfig" then pcall(Util.pack.load, "nvim-lspconfig") end
  Util.lsp.configure_defaults()
  vim.lsp.config("markdown_oxide", markdown_oxide_config)

  local config = vim.tbl_deep_extend("force", vim.deepcopy(vim.lsp.config.markdown_oxide), { root_dir = root })
  vim.lsp.start(config, { bufnr = bufnr, silent = true })
end

local markdown_buf = vim.api.nvim_get_current_buf()
if vim.v.vim_did_enter == 0 then
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      vim.schedule(function() start_markdown_oxide(markdown_buf) end)
    end,
  })
else
  start_markdown_oxide(markdown_buf)
end
vim.cmd.runtime "after/ftplugin/latex.lua"

local function luasnip_jump(direction)
  local ok, luasnip = pcall(require, "luasnip")
  if ok and luasnip.jumpable(direction) then
    luasnip.jump(direction)
    return true
  end
end

---@return table<string,string>
local function load_latex_snippets()
  local path = vim.fn.stdpath "config" .. "/snippets/latex.json"
  local fd = io.open(path, "r")
  if not fd then return {} end
  local content = fd:read "*a"
  fd:close()
  local ok, data = pcall(vim.fn.json_decode, content)
  if not ok or type(data) ~= "table" then return {} end
  local tbl = {}
  for _, item in pairs(data) do
    local prefixes = {}
    if type(item.prefix) == "table" then
      prefixes = item.prefix
    elseif type(item.prefix) == "string" then
      prefixes = { item.prefix }
    end
    local body
    if type(item.body) == "table" then
      body = table.concat(item.body, "\n")
    elseif type(item.body) == "string" then
      body = item.body
    end
    if body then
      for _, p in ipairs(prefixes) do
        tbl[p] = body
      end
    end
  end
  return tbl
end

local M = {}

---@type table<string, any>
M._snippets = nil
M._list_continuation_tab = nil

local _md_list_parts

local _md_list_continuation_tab_timeout_ns = 1000000000

---@return integer
local function _md_indent_width()
  local width = vim.bo.shiftwidth
  if width <= 0 then width = vim.bo.tabstop end
  if width <= 0 then return 2 end
  return width
end

---@param parts table
---@return string
local function _md_nested_list_indent(parts)
  if parts.kind == "ordered" then return string.rep(" ", #parts.marker) end
  return string.rep(" ", _md_indent_width())
end

---@param parts table
---@return string
local function _md_nested_list_marker(parts)
  if parts.kind == "ordered" then return "1" .. parts.sep .. " " end
  return parts.marker
end

---@return string?
local function _md_nested_list_from_double_tab()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  if col ~= #line or not _md_list_parts then
    M._list_continuation_tab = nil
    return nil
  end

  local parts = _md_list_parts(line)
  if not parts or parts.prefix ~= "" or not parts.rest:match "^%s*$" then
    M._list_continuation_tab = nil
    return nil
  end

  local now = vim.uv.hrtime()
  local state = M._list_continuation_tab
  M._list_continuation_tab = {
    bufnr = vim.api.nvim_get_current_buf(),
    row = row,
    marker = parts.marker,
    at = now,
  }

  if
    not state
    or state.bufnr ~= vim.api.nvim_get_current_buf()
    or state.row ~= row
    or state.marker ~= parts.marker
    or now - state.at > _md_list_continuation_tab_timeout_ns
  then
    return nil
  end

  local text = _md_nested_list_indent(parts) .. _md_nested_list_marker(parts)
  M._list_continuation_tab = nil
  return vim.api.nvim_replace_termcodes("<C-u>" .. text, true, false, true)
end

---@param trigger string
---@param body string
local function expand(trigger, body)
  -- Delete the trigger text before expanding.
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local bufnr = 0
  vim.api.nvim_buf_set_text(bufnr, row - 1, col - #trigger, row - 1, col, { "" })
  -- Move cursor to start of removed trigger
  vim.api.nvim_win_set_cursor(0, { row, col - #trigger })
  Util.cmp.expand(body)
end

vim.keymap.set("i", "<Tab>", function()
  if M._snippets == nil then M._snippets = load_latex_snippets() end

  if luasnip_jump(1) then return end

  -- inside snippets
  if vim.snippet.active { direction = 1 } then
    vim.schedule(function() vim.snippet.jump(1) end)
    return
  end

  local nested_list = _md_nested_list_from_double_tab()
  if nested_list then return nested_list end

  -- not math, then returns per usual
  if Util.treesitter.not_math() then return "\t" end

  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col "." - 1
  local prefix = line:sub(1, col):match "(%w+)$"
  if prefix and M._snippets[prefix] then
    expand(prefix, M._snippets[prefix])
    return
  end
  return "\t"
end, { expr = true, silent = true, buffer = true, desc = "snippet: expand or indent" })

vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
  if luasnip_jump(-1) then return end

  if vim.snippet.active { direction = -1 } then
    vim.schedule(function() vim.snippet.jump(-1) end)
    return
  end
  return "<S-Tab>"
end, { expr = true, silent = true, buffer = true, desc = "snippet: jump backwards" })

vim.keymap.set("i", "<D-k>", function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { "[[]]" })
  vim.api.nvim_win_set_cursor(0, { row, col + 2 })
end, { buffer = true, desc = "wikilink: insert" })

local function _md_insert_sidenote() Util.cmp.expand "{{sidenotes[$1]: $2}}" end

vim.keymap.set("i", "gasdn", _md_insert_sidenote, { buffer = true, desc = "sidenote: insert" })
vim.keymap.set("x", "gasdn", [[c{{sidenotes[<C-r>"]: }}<Left><Left>]], {
  buffer = true,
  desc = "sidenote: wrap selection",
})

local _md_heading_ns = vim.api.nvim_create_namespace "md_headings_popup"

---@class simple.markdown.heading
---@field line integer
---@field level integer
---@field text string

---@param line string
---@return string?
---@return integer?
local function _md_atx_heading(line)
  local hashes, text = line:match "^%s*(#+)%s*(.-)%s*$"
  if not hashes or #hashes > 6 then return nil end
  text = vim.trim(text:gsub("%s*#+%s*$", ""))
  if text == "" then return nil end
  return text, #hashes
end

---@param line string
---@return integer?
local function _md_setext_level(line)
  if line:match "^%s*=+%s*$" then return 1 end
  if line:match "^%s*-+%s*$" then return 2 end
end

---@param line string
---@return string?
local function _md_setext_text(line)
  if _md_atx_heading(line) then return nil end
  local text = vim.trim(line)
  if text == "" or text:match "^[%-%*_]+$" then return nil end
  return text
end

---@param buf integer
---@return simple.markdown.heading[]?
local function _md_collect_headings_with_treesitter(buf)
  local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown", {})
  if not ok or not parser then return nil end
  local trees = parser:parse()
  if not trees or not trees[1] then return nil end
  local root = trees[1]:root()
  if not root then return nil end
  local query = vim.treesitter.query.parse(
    "markdown",
    [[
    (atx_heading) @h
    (setext_heading) @h
  ]]
  )
  ---@type simple.markdown.heading[]
  local items = {}
  for _, node in query:iter_captures(root, buf, 0, -1) do
    local start_row, _, end_row, _ = node:range()
    local text = ""
    local level = 1
    if node:type() == "atx_heading" then
      local line = (vim.api.nvim_buf_get_lines(buf, start_row, start_row + 1, false)[1] or "")
      text, level = _md_atx_heading(line)
    else
      local first = (vim.api.nvim_buf_get_lines(buf, start_row, start_row + 1, false)[1] or "")
      local underline = (vim.api.nvim_buf_get_lines(buf, end_row - 1, end_row, false)[1] or "")
      level = _md_setext_level(underline) or level
      text = _md_setext_text(first)
    end
    if text and text ~= "" then table.insert(items, { line = start_row, level = level, text = text }) end
  end
  table.sort(items, function(a, b) return a.line < b.line end)
  return items
end

---@param buf integer
---@return simple.markdown.heading[]
local function _md_collect_headings_with_lines(buf)
  local items = {}
  local prev_line
  local prev_row
  local in_frontmatter = false
  local line_count = vim.api.nvim_buf_line_count(buf)

  for start_row = 0, line_count - 1, 512 do
    local lines = vim.api.nvim_buf_get_lines(buf, start_row, math.min(start_row + 512, line_count), false)
    for offset, line in ipairs(lines) do
      local row = start_row + offset - 1

      if row == 0 and line:match "^%s*%-%-%-%s*$" then
        in_frontmatter = true
        prev_line = nil
        prev_row = nil
      elseif in_frontmatter then
        if row > 0 and line:match "^%s*%-%-%-%s*$" then in_frontmatter = false end
        prev_line = nil
        prev_row = nil
      else
        local text, level = _md_atx_heading(line)
        if text then table.insert(items, { line = row, level = level, text = text }) end

        level = _md_setext_level(line)
        text = prev_line and _md_setext_text(prev_line) or nil
        if level and text and prev_row then table.insert(items, { line = prev_row, level = level, text = text }) end

        prev_line = line
        prev_row = row
      end
    end
  end

  return items
end

---@return simple.markdown.heading[]
local function _md_collect_headings()
  local buf = 0
  if Util.is_bigfile(buf) then return _md_collect_headings_with_lines(buf) end

  local items = _md_collect_headings_with_treesitter(buf)
  if items then return items end

  return _md_collect_headings_with_lines(buf)
end

local function _md_open_headings_popup()
  local src_win = vim.api.nvim_get_current_win()
  local items = _md_collect_headings()
  if #items == 0 then return end
  ---@type string[]
  local lines = {}
  local max_length = 0
  for i, it in ipairs(items) do
    local indent = string.rep("  ", math.max(it.level - 1, 0))
    local line = indent .. it.text
    lines[i] = line
    if #line > max_length then max_length = #line end
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  local width = math.min(max_length + 2, math.max(20, math.floor(vim.o.columns * 0.8)))
  local height = math.min(#lines, math.max(5, math.floor(vim.o.lines * 0.6)))
  local row = math.floor((vim.o.lines - height) / 2)
  local col = 2
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
  })
  vim.api.nvim_set_option_value("wrap", false, { win = win })
  vim.api.nvim_set_option_value("cursorline", true, { win = win })
  ---@type table<string, table<any>>
  local groups = {}
  for i, it in ipairs(items) do
    ---@type string[]
    local initials = {}
    local seen = {}
    local function add_initial(str)
      if not str then return end
      local ch = str:match "%a"
      if not ch then return end
      ch = ch:lower()
      if seen[ch] then return end
      seen[ch] = true
      table.insert(initials, ch)
    end
    local trimmed = vim.trim(it.text)
    local link_inside = trimmed:match "^%[%[([^%]]+)%]%]"
    if link_inside then
      ---@type string
      local before_alias = link_inside:match "^[^|]+"
      add_initial(before_alias)
      if before_alias then
        for segment in before_alias:gmatch "[^/]+" do
          add_initial(segment)
        end
      end
      local alias = link_inside:match "|(.+)$"
      if alias then add_initial(alias) end
    else
      add_initial(trimmed)
    end
    for _, init in ipairs(initials) do
      groups[init] = groups[init] or {}
      local exists = false
      for _, idx in ipairs(groups[init]) do
        if idx == i then
          exists = true
          break
        end
      end
      if not exists then table.insert(groups[init], i) end
    end
  end
  local jump_to_index = function(idx)
    if not idx or not items[idx] then return end
    local target = items[idx]
    pcall(vim.api.nvim_win_close, win, true)
    if vim.api.nvim_win_is_valid(src_win) then vim.api.nvim_set_current_win(src_win) end
    pcall(vim.api.nvim_win_set_cursor, src_win, { target.line + 1, 0 })
    vim.cmd "normal! zvzz"
  end
  local second_active = false
  local second_keys_set = {}
  local second_extmarks = {}
  local function clear_second()
    if #second_extmarks > 0 then
      for _, id in ipairs(second_extmarks) do
        pcall(vim.api.nvim_buf_del_extmark, buf, _md_heading_ns, id)
      end
    end
    second_extmarks = {}
    if #second_keys_set > 0 then
      for _, k in ipairs(second_keys_set) do
        pcall(vim.keymap.del, "n", k, { buffer = buf })
      end
    end
    second_keys_set = {}
    second_active = false
  end
  local second_choice_keys = {
    "a",
    "s",
    "d",
    "f",
    "l",
    "h",
    "g",
    "u",
    "i",
    "o",
    "p",
    "w",
    "e",
    "r",
    "t",
    "y",
    "c",
    "v",
    "b",
    "n",
    "m",
    "x",
    "z",
  }
  local function enter_second(init)
    local list = groups[init]
    if not list or #list <= 1 then return end
    clear_second()
    second_active = true
    local mid = math.ceil(#lines / 2)
    table.sort(list, function(a, b)
      local da = math.abs(a - mid)
      local db = math.abs(b - mid)
      if da ~= db then return da < db end
      return a > b
    end)
    local assigned = {}
    for i, idx in ipairs(list) do
      local key = second_choice_keys[i]
      if not key then break end
      table.insert(second_keys_set, key)
      assigned[idx] = key
      vim.keymap.set("n", key, function()
        clear_second()
        jump_to_index(idx)
      end, { buffer = buf, nowait = true, silent = true })
    end
    for idx, key in pairs(assigned) do
      local id = vim.api.nvim_buf_set_extmark(buf, _md_heading_ns, idx - 1, 0, {
        virt_text = { { key .. " ", "IncSearch" } },
        virt_text_pos = "overlay",
        virt_text_win_col = 0,
      })
      table.insert(second_extmarks, id)
    end
  end
  local function on_first(char)
    local list = groups[char]
    if not list or #list == 0 then return end
    if #list == 1 then
      jump_to_index(list[1])
    else
      enter_second(char)
    end
  end

  local function move_cursor(delta)
    local cur = vim.api.nvim_win_get_cursor(win)
    local new_row = math.max(1, math.min(#lines, cur[1] + delta))
    if new_row ~= cur[1] then vim.api.nvim_win_set_cursor(win, { new_row, 0 }) end
  end

  vim.keymap.set("n", "j", function() move_cursor(1) end, { buffer = buf, nowait = true, silent = true })
  vim.keymap.set("n", "k", function() move_cursor(-1) end, { buffer = buf, nowait = true, silent = true })
  for byte = string.byte "a", string.byte "z" do
    local ch = string.char(byte)
    if ch ~= "j" and ch ~= "k" then
      vim.keymap.set("n", ch, function()
        if second_active then return end
        on_first(ch)
      end, { buffer = buf, nowait = true, silent = true })
    end
  end
  vim.keymap.set("n", "<CR>", function()
    local cur = vim.api.nvim_win_get_cursor(win)[1]
    jump_to_index(cur)
  end, { buffer = buf, nowait = true, silent = true })
  vim.keymap.set(
    "n",
    "q",
    function() pcall(vim.api.nvim_win_close, win, true) end,
    { buffer = buf, nowait = true, silent = true }
  )
  vim.keymap.set("n", "<Esc>", function()
    if second_active then
      clear_second()
    else
      pcall(vim.api.nvim_win_close, win, true)
    end
  end, { buffer = buf, nowait = true, silent = true })
end

vim.keymap.set(
  "n",
  "gh",
  _md_open_headings_popup,
  { buffer = true, silent = true, desc = "markdown: headings quick jump" }
)

---@param line string
---@return string indent
---@return string quote
---@return string body
local function _md_split_quote_prefix(line)
  local indent = line:match "^(%s*)" or ""
  local idx = #indent + 1
  local quote = ""

  while line:sub(idx, idx) == ">" do
    quote = quote .. ">"
    idx = idx + 1
    local spaces = line:match("^(%s*)", idx) or ""
    quote = quote .. spaces
    idx = idx + #spaces
  end

  return indent, quote, line:sub(idx)
end

---@param line string
---@return { prefix: string, insert_prefix: string, marker: string, next: string, rest: string, kind: string, sep?: string }?
function _md_list_parts(line)
  local function result(base_indent, quote, indent, marker, next_marker, rest, kind, sep)
    return {
      prefix = base_indent .. quote .. indent,
      insert_prefix = quote .. indent,
      marker = marker,
      next = next_marker,
      rest = rest,
      kind = kind,
      sep = sep,
    }
  end

  local base_indent, quote, body = _md_split_quote_prefix(line)
  local indent, marker = body:match "^(%s*)([%-%+%*]%s+%[[ xX%-]%]%s+)"
  if indent then
    local rest = body:sub(#indent + #marker + 1)
    local bullet, checked = marker:match "^([%-%+%*])%s+%[([ xX%-])%]"
    return result(base_indent, quote, indent, string.format("%s [%s] ", bullet, checked), marker, rest, "task")
  end

  indent, marker = body:match "^(%s*)([%-%+%*]%s+)"
  if indent then
    local rest = body:sub(#indent + #marker + 1)
    return result(base_indent, quote, indent, marker:sub(1, 1) .. " ", marker, rest, "unordered")
  end

  local num, sep
  indent, num, sep = body:match "^(%s*)(%d+)([.)])%s+"
  if indent then
    local current = string.format("%s%s ", num, sep)
    local next_marker = string.format("%d%s ", tonumber(num) + 1, sep)
    local rest = body:sub(#indent + #current + 1)
    return result(base_indent, quote, indent, current, next_marker, rest, "ordered", sep)
  end
end

---@param line string
---@return string?
local function _md_blockquote_prefix(line)
  local base_indent, quote = _md_split_quote_prefix(line)
  if quote == "" then return nil end
  return base_indent .. quote, quote
end

---@param line string
---@return string
local function _md_next_line_prefix(line)
  local parts = _md_list_parts(line)
  if parts then
    if parts.rest:match "^%s*$" then return parts.prefix end
    return parts.prefix .. parts.next
  end

  local bq_prefix = _md_blockquote_prefix(line)
  if bq_prefix then return bq_prefix end

  return line:match "^(%s*)" or ""
end

---@param opts? { blockquote_only?: boolean }
local function _md_smart_cr(opts)
  opts = opts or {}
  local _, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()

  if not opts.blockquote_only then
    local parts = _md_list_parts(line)
    if parts then
      if parts.rest:match "^%s*$" and col >= #line then
        return vim.api.nvim_replace_termcodes(
          "<Esc>0C" .. parts.prefix .. "<CR>" .. parts.insert_prefix,
          true,
          false,
          true
        )
      end

      return vim.api.nvim_replace_termcodes("<CR>" .. parts.insert_prefix .. parts.next, true, false, true)
    end
  end

  local _, bq_insert_prefix = _md_blockquote_prefix(line)
  if bq_insert_prefix then return vim.api.nvim_replace_termcodes("<CR>" .. bq_insert_prefix, true, false, true) end

  return vim.api.nvim_replace_termcodes("<CR>", true, false, true)
end

---@param command "o"|"O"
local function _md_smart_open(command)
  if vim.v.count > 0 then
    local keys = vim.api.nvim_replace_termcodes(("%d%s"):format(vim.v.count, command), true, false, true)
    vim.api.nvim_feedkeys(keys, "n", false)
    return
  end

  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_get_current_line()
  local prefix = _md_next_line_prefix(line)
  local insert_row = command == "o" and row or (row - 1)

  vim.api.nvim_buf_set_lines(0, insert_row, insert_row, false, { prefix })
  vim.api.nvim_win_set_cursor(0, { insert_row + 1, math.max(#prefix - 1, 0) })
  vim.cmd "startinsert!"
end

vim.keymap.set("i", "<CR>", _md_smart_cr, { buffer = true, expr = true, desc = "markdown: continue list" })
vim.keymap.set(
  "i",
  "<S-CR>",
  function() return _md_smart_cr { blockquote_only = true } end,
  { buffer = true, expr = true, desc = "markdown: continue blockquote" }
)
vim.keymap.set("n", "o", function() _md_smart_open "o" end, {
  buffer = true,
  desc = "markdown: open continuation below",
})
vim.keymap.set("n", "O", function() _md_smart_open "O" end, {
  buffer = true,
  desc = "markdown: open continuation above",
})

local function _md_insert_emdash() return "—" end

vim.keymap.set(
  "i",
  "<S-M-->",
  _md_insert_emdash,
  { buffer = true, expr = true, desc = "markdown: insert em dash (Option+Shift+-)" }
)
vim.keymap.set(
  "i",
  "<M-->",
  _md_insert_emdash,
  { buffer = true, expr = true, desc = "markdown: insert em dash (Option+-)" }
)

---@param url string
---@return string
local function _md_clean_url(url)
  local base, fragment = url:match "^(.-)(#.*)$"
  if not base then
    base = url
    fragment = ""
  end

  local before_query, query = base:match "^(.-)%?(.*)$"
  if not before_query then return base .. fragment end

  local kept = {}
  for part in query:gmatch "[^&]+" do
    local name = part:match "^([^=]+)"
    if name ~= "curius" then table.insert(kept, part) end
  end
  if #kept == 0 then return before_query .. fragment end
  return before_query .. "?" .. table.concat(kept, "&") .. fragment
end

---@param text string
---@return string
local function _md_clean_url_token(text)
  local url, suffix = text:match "^(.+)([.,;:!?])$"
  if not url then return _md_clean_url(text) end
  return _md_clean_url(url) .. suffix
end

---@param text string
---@return string
local function _md_clean_pasted_urls(text)
  text = text:gsub("https?://[^%s<>()%[%]{}\"']+", _md_clean_url_token)
  text = text:gsub("www%.[^%s<>()%[%]{}\"']+", _md_clean_url_token)
  return text
end

---@param lines string[]
---@return string[]
local function _md_transform_paste(lines)
  local raw = table.concat(lines or {}, "\n")
  local cleaned = _md_clean_pasted_urls(raw)
  if cleaned == raw then return lines end
  return vim.split(cleaned, "\n", { plain = true, trimempty = false })
end

local _md_paste_hook_version = 2

if vim.g._md_paste_hook_version ~= _md_paste_hook_version then
  vim.g._md_paste_hook_version = _md_paste_hook_version

  vim.paste = (function(overridden)
    local chunked = ""

    return function(lines, phase)
      phase = phase or -1

      -- don't mess with cmdline pastes, it gets weird fast.
      if vim.fn.getcmdtype() ~= "" then return overridden(lines, phase) end

      local buf = vim.api.nvim_get_current_buf()
      if vim.bo[buf].filetype ~= "markdown" then return overridden(lines, phase) end

      local is_first_chunk = phase < 2
      local is_last_chunk = phase == -1 or phase == 3

      if is_first_chunk then chunked = "" end
      chunked = chunked .. table.concat(lines, "\n")

      if not is_last_chunk then return true end

      local transformed = _md_transform_paste(vim.split(chunked, "\n", { plain = true, trimempty = false }))
      chunked = ""
      return overridden(transformed, -1)
    end
  end)(vim.paste)
end

return M
