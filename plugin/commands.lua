vim.api.nvim_create_user_command("ClearBuffer", function()
  local removed, failures = 0, {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) == "" then
      local ok, err = pcall(vim.api.nvim_buf_delete, buf, { force = true })
      if ok then
        removed = removed + 1
      else
        table.insert(failures, string.format("buffer %d: %s", buf, err))
      end
    end
  end
  if removed == 0 then
    Util.info "ClearBuffer: no [No Name] buffers"
  else
    local suffix = removed == 1 and "" or "s"
    Util.info(string.format("ClearBuffer: removed %d buffer%s", removed, suffix))
  end
  if #failures > 0 then Util.warn("ClearBuffer: unable to remove\n" .. table.concat(failures, "\n")) end
end, { desc = "buffer: delete unnamed buffers" })

local latex_shortcut_cache = nil

local function latex_shortcut_pack_root()
  if not vim.pack then return nil end

  local ok, plugins = pcall(vim.pack.get, { "luasnip-latex-snippets.nvim" }, { info = false })
  local plugin = ok and plugins and plugins[1] or nil
  if type(plugin) ~= "table" or type(plugin.path) ~= "string" or plugin.path == "" then return nil end
  if vim.fn.isdirectory(plugin.path) == 1 then return plugin.path end
end

local function latex_shortcut_source_root()
  local roots = {
    vim.fs.joinpath(vim.fn.stdpath "data", "site/pack/core/opt/luasnip-latex-snippets.nvim"),
    vim.fn.expand "~/workspace/neovim-plugins/luasnip-latex-snippets.nvim",
  }
  local pack_root = latex_shortcut_pack_root()
  if pack_root then table.insert(roots, 1, pack_root) end

  for _, root in ipairs(roots) do
    if vim.fn.isdirectory(root) == 1 then return root end
  end
end

local function latex_shortcut_module_names(root)
  local dir = vim.fs.joinpath(root, "lua", "luasnip-latex-snippets")
  local names = {}
  for name, kind in vim.fs.dir(dir) do
    if kind == "file" and name ~= "init.lua" and name:match "%.lua$" then
      names[#names + 1] = name:gsub("%.lua$", "")
    end
  end
  table.sort(names)
  return names
end

local function latex_shortcut_package_path(root)
  return table.concat({
    vim.fs.joinpath(root, "lua", "?.lua"),
    vim.fs.joinpath(root, "lua", "?", "init.lua"),
    package.path,
  }, ";")
end

local function with_latex_shortcut_source(root, fn)
  local prefix = "luasnip-latex-snippets"
  local saved_loaded = {}
  for name, module in pairs(package.loaded) do
    if name == prefix or name:sub(1, #prefix + 1) == prefix .. "." then
      saved_loaded[name] = module
      package.loaded[name] = nil
    end
  end

  local old_path = package.path
  package.path = latex_shortcut_package_path(root)
  local ok, result = pcall(fn)
  package.path = old_path

  for name in pairs(package.loaded) do
    if name == prefix or name:sub(1, #prefix + 1) == prefix .. "." then package.loaded[name] = nil end
  end
  for name, module in pairs(saved_loaded) do
    package.loaded[name] = module
  end

  if not ok then error(result, 0) end
  return result
end

local function latex_shortcut_docstring(snippet)
  local doc = snippet.docstring
  if type(doc) ~= "table" and type(snippet.get_docstring) == "function" then
    local ok, generated = pcall(snippet.get_docstring, snippet)
    if ok then doc = generated end
  end
  if type(doc) == "string" then return { doc } end
  if type(doc) ~= "table" then return {} end

  local lines = {}
  for _, line in ipairs(doc) do
    if type(line) == "string" then lines[#lines + 1] = line end
  end
  return lines
end

local function latex_shortcut_name(snippet)
  if type(snippet.name) == "string" and snippet.name ~= "" then return snippet.name end
  if type(snippet.dscr) == "table" and type(snippet.dscr[1]) == "string" then return snippet.dscr[1] end
  if type(snippet.description) == "table" and type(snippet.description[1]) == "string" then
    return snippet.description[1]
  end
  return snippet.trigger
end

local function latex_shortcut_kind(snippet)
  local parts = {}
  if snippet.regTrig then parts[#parts + 1] = "regex" end
  if type(snippet.trigEngine) == "string" then parts[#parts + 1] = snippet.trigEngine end
  if snippet.wordTrig == false then parts[#parts + 1] = "in-word" end
  if #parts == 0 then return "plain" end
  return table.concat(parts, ",")
end

local function latex_shortcut_trim(value, limit)
  value = tostring(value or ""):gsub("%s+", " ")
  if #value <= limit then return value end
  return value:sub(1, limit - 1) .. "~"
end

local function latex_shortcut_item_from_fields(module_name, trigger, name, kind, doc)
  local doc_text = table.concat(doc, " ")
  local display = ("%-22s %-34s %-20s %s"):format(
    latex_shortcut_trim(trigger, 22),
    latex_shortcut_trim(name, 34),
    latex_shortcut_trim(module_name, 20),
    kind
  )

  return {
    text = table.concat({ trigger, name, module_name, kind, doc_text }, " "),
    display = display,
    trigger = trigger,
    name = name,
    module = module_name,
    kind = kind,
    doc = doc,
  }
end

local function latex_shortcut_item(module_name, snippet)
  if type(snippet) ~= "table" or type(snippet.trigger) ~= "string" or snippet.trigger == "" then return nil end

  return latex_shortcut_item_from_fields(
    module_name,
    snippet.trigger,
    latex_shortcut_name(snippet),
    latex_shortcut_kind(snippet),
    latex_shortcut_docstring(snippet)
  )
end

local function latex_shortcut_collect_init(root, items, seen)
  local path = vim.fs.joinpath(root, "lua", "luasnip-latex-snippets", "init.lua")
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then return end

  local uncommented = {}
  for _, line in ipairs(lines) do
    if not line:match "^%s*%-%-" then uncommented[#uncommented + 1] = line end
  end

  local source = table.concat(uncommented, "\n")
  for trig, name, body in
    source:gmatch 'parse_snippet%(%s*{%s*trig%s*=%s*"([^"]+)"%s*,%s*name%s*=%s*"([^"]+)".-}%s*,%s*"([^"]*)"%s*%)'
  do
    local item = latex_shortcut_item_from_fields("init", trig, name, "plain", { body })
    local key = table.concat({ item.trigger, item.name, item.module }, "\0")
    if not seen[key] then
      seen[key] = true
      items[#items + 1] = item
    end
  end
end

local function latex_shortcut_collect(root)
  Util.pack.load "LuaSnip"

  return with_latex_shortcut_source(root, function()
    local items, seen = {}, {}
    for _, module_name in ipairs(latex_shortcut_module_names(root)) do
      local ok, module = pcall(require, "luasnip-latex-snippets." .. module_name)
      if ok and type(module) == "table" and type(module.retrieve) == "function" then
        local retrieved_ok, snippets = pcall(module.retrieve, function() return true end)
        if retrieved_ok and type(snippets) == "table" then
          for _, snippet in ipairs(snippets) do
            local item = latex_shortcut_item(module_name, snippet)
            if item then
              local key = table.concat({ item.trigger, item.name, item.module }, "\0")
              if not seen[key] then
                seen[key] = true
                items[#items + 1] = item
              end
            end
          end
        end
      end
    end

    latex_shortcut_collect_init(root, items, seen)

    table.sort(items, function(a, b)
      if a.trigger == b.trigger then return a.name < b.name end
      return a.trigger < b.trigger
    end)
    return items
  end)
end

local function latex_shortcut_items(refresh)
  if refresh then latex_shortcut_cache = nil end
  if latex_shortcut_cache then return latex_shortcut_cache.items, latex_shortcut_cache.root end

  local root = latex_shortcut_source_root()
  if not root then return nil, nil end

  local items = latex_shortcut_collect(root)
  latex_shortcut_cache = { items = items, root = root }
  return items, root
end

local function latex_shortcut_show(buf, items)
  local lines = vim.tbl_map(function(item) return item.display end, items)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

local function latex_shortcut_preview(buf, item)
  local lines = {
    item.name,
    "",
    "trigger: " .. item.trigger,
    "kind: " .. item.kind,
    "source: " .. item.module,
    "",
    "docstring:",
  }
  if #item.doc == 0 then
    lines[#lines + 1] = "  " .. item.trigger
  else
    for _, line in ipairs(item.doc) do
      lines[#lines + 1] = "  " .. line
    end
  end

  vim.bo[buf].filetype = "tex"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

local function latex_shortcut_choose(item)
  vim.fn.setreg('"', item.trigger)
  pcall(vim.fn.setreg, "+", item.trigger)
  Util.info(("LatexShortcut: yanked %s"):format(item.trigger), { title = "latex" })
end

local function latex_shortcut_open(opts)
  local items, root = latex_shortcut_items(opts.bang)
  if not items then
    Util.warn("LatexShortcut: local luasnip-latex-snippets.nvim checkout not found", { title = "latex" })
    return
  end
  if #items == 0 then
    Util.warn("LatexShortcut: no snippets found in " .. root, { title = "latex" })
    return
  end
  if type(Util.ui.pick) ~= "function" then
    Util.warn("LatexShortcut: mini.pick is unavailable", { title = "latex" })
    return
  end

  if opts.args ~= "" then
    vim.schedule(function()
      local ok, pick = pcall(require, "mini.pick")
      if ok then pcall(pick.set_picker_query, { opts.args }) end
    end)
  end

  Util.ui.pick {
    source = {
      name = "LatexShortcut",
      items = items,
      show = latex_shortcut_show,
      preview = latex_shortcut_preview,
      choose = latex_shortcut_choose,
    },
  }
end

vim.api.nvim_create_user_command("LatexShortcut", latex_shortcut_open, {
  bang = true,
  nargs = "*",
  desc = "latex: fuzzy shortcut cheatsheet",
})

-- Create new obsidian notes
vim.api.nvim_create_user_command("ObsidianNew", function(opts)
  local raw = table.concat(opts.fargs, " ")
  if raw == "" then
    Util.error "ObsidianNew: provide a note name"
    return
  end

  -- Trim trailing slashes to avoid creating ".../.md" when user ends with "/".
  raw = raw:gsub("/+$", ""):gsub("/+", "/")

  -- Support subpaths like "posts/your note title"
  -- Split on the LAST "/" so nested paths also work.
  local subdir, stem = raw:match "^(.*)/([^/]+)$"
  if not stem then stem = raw end
  if not stem:match "%.md$" then stem = stem .. ".md" end

  local cur = vim.api.nvim_buf_get_name(0)
  local vault = nil
  for _, v in ipairs(VAULTS) do
    if cur:sub(1, #v.root) == v.root then
      vault = v
      break
    end
  end
  if not vault then vault = VAULTS[1] end

  local dir = vault.root
  if vault.new_note_dir and vault.new_note_dir ~= "" then dir = dir .. "/" .. vault.new_note_dir end
  if subdir and subdir ~= "" then dir = dir .. "/" .. subdir end

  local path = dir .. "/" .. stem
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end, { nargs = "+", complete = "file", desc = "obsidian: new note (supports subpaths)" })
