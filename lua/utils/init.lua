---@diagnostic disable: undefined-field
--# selene: allow(global_usage)
local M = {}

---@param on_attach fun(client?:lsp.Client, buffer?:integer): nil
M.on_attach = function(on_attach)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(client, args.buf)
    end,
  })
end

---@param plugin string
---@return boolean
M.has = function(plugin) return require("lazy.core.config").plugins[plugin] ~= nil end

M.get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients

---@param from string
---@param to string
M.on_rename = function(from, to)
  local clients = M.get_clients()
  for _, client in ipairs(clients) do
    if client.supports_method "workspace/willRenameFiles" then
      ---@diagnostic disable-next-line: invisible
      local resp = client.request_sync("workspace/willRenameFiles", {
        files = {
          {
            oldUri = vim.uri_from_fname(from),
            newUri = vim.uri_from_fname(to),
          },
        },
      }, 1000, 0)
      if resp and resp.result ~= nil then vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding) end
    end
  end
end

---@param name string
M.opts = function(name)
  local plugin = require("lazy.core.config").plugins[name]
  if not plugin then return {} end
  return require("lazy.core.plugin").values(plugin, "opts", false)
end

---@param name string
---@param fn fun(name: string): nil
M.on_load = function(name, fn)
  local Config = require "lazy.core.config"
  if Config.plugins[name] and Config.plugins[name]._.loaded then
    vim.schedule(function() fn(name) end)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == name then
          fn(name)
          return true
        end
      end,
    })
  end
end

M.root_patterns = { ".git", "lua" }

-- returns the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
---@return string
M.root = function()
  ---@type string?
  local path = vim.api.nvim_buf_get_name(0)
  path = path ~= "" and vim.loop.fs_realpath(path) or nil
  ---@type string[]
  local roots = {}
  if path then
    for _, client in pairs(M.get_clients { bufnr = 0 }) do
      local workspace = client.config.workspace_folders
      local paths = workspace and vim.tbl_map(function(ws) return vim.uri_to_fname(ws.uri) end, workspace)
        or client.config.root_dir and { client.config.root_dir }
        or {}
      for _, p in ipairs(paths) do
        local r = vim.loop.fs_realpath(p)
        ---@diagnostic disable-next-line: param-type-mismatch
        if path:find(r, 1, true) then roots[#roots + 1] = r end
      end
    end
  end
  table.sort(roots, function(a, b) return #a > #b end)
  ---@type string?
  local root = roots[1]
  if not root then
    path = path and vim.fs.dirname(path) or vim.loop.cwd()
    ---@type string?
    root = vim.fs.find(M.root_patterns, { path = path, upward = true })[1]
    root = root and vim.fs.dirname(root) or vim.loop.cwd()
  end
  ---@cast root string
  return root
end

-- this will return a function that calls telescope.
-- cwd will default to lazyvim.util.get_root
-- for `files`, git_files or find_files will be chosen depending on .git
M.telescope = function(builtin, opts)
  local params = { builtin = builtin, opts = opts }
  return function()
    builtin = params.builtin
    opts = params.opts
    opts = vim.tbl_deep_extend("force", { cwd = M.root() }, opts or {})
    if builtin == "files" then
      if vim.loop.fs_stat((opts.cwd or vim.loop.cwd()) .. "/.git") then
        opts.show_untracked = true
        builtin = "git_files"
      else
        builtin = "find_files"
      end
    end
    if opts.cwd and opts.cwd ~= vim.loop.cwd() then
      opts.attach_mappings = function(_, map)
        map("i", "<a-c>", function()
          local action_state = require "telescope.actions.state"
          local line = action_state.get_current_line()
          M.telescope(
            params.builtin,
            vim.tbl_deep_extend("force", {}, params.opts or {}, { cwd = false, default_text = line })
          )()
        end)
        return true
      end
    end

    require("telescope.builtin")[builtin](opts)
  end
end

M.use_lazy_file = true
M.lazy_file_events = { "BufReadPost", "BufNewFile", "BufWritePre" }
-- Properly load file based plugins without blocking the UI
M.lazy_file = function()
  M.use_lazy_file = M.use_lazy_file and vim.fn.argc(-1) > 0

  -- Add support for the LazyFile event
  local Event = require "lazy.core.handler.event"

  if M.use_lazy_file then
    -- We'll handle delayed execution of events ourselves
    Event.mappings.LazyFile = { id = "LazyFile", event = "User", pattern = "LazyFile" }
    Event.mappings["User LazyFile"] = Event.mappings.LazyFile
  else
    -- Don't delay execution of LazyFile events, but let lazy know about the mapping
    Event.mappings.LazyFile = { id = "LazyFile", event = { "BufReadPost", "BufNewFile", "BufWritePre" } }
    Event.mappings["User LazyFile"] = Event.mappings.LazyFile
    return
  end

  local events = {} ---@type {event: string, buf: number, data?: any}[]

  local function load()
    if #events == 0 then return end
    vim.api.nvim_del_augroup_by_name "lazy_file"

    ---@type table<string,string[]>
    local skips = {}
    for _, event in ipairs(events) do
      skips[event.event] = skips[event.event] or Event.get_augroups(event.event)
    end

    vim.api.nvim_exec_autocmds("User", { pattern = "LazyFile", modeline = false })
    for _, event in ipairs(events) do
      Event.trigger {
        event = event.event,
        exclude = skips[event.event],
        data = event.data,
        buf = event.buf,
      }
      if vim.bo[event.buf].filetype then
        Event.trigger {
          event = "FileType",
          buf = event.buf,
        }
      end
    end
    vim.api.nvim_exec_autocmds("CursorMoved", { modeline = false })
    events = {}
  end

  -- schedule wrap so that nested autocmds are executed
  -- and the UI can continue rendering without blocking
  load = vim.schedule_wrap(load)

  vim.api.nvim_create_autocmd(M.lazy_file_events, {
    group = vim.api.nvim_create_augroup("lazy_file", { clear = true }),
    callback = function(event)
      table.insert(events, event)
      load()
    end,
  })
end

---@class palette
---@field rosewater string
---@field flamingo string
---@field mauve string
---@field pink string
---@field red string
---@field maroon string
---@field peach string
---@field yellow string
---@field green string
---@field sapphire string
---@field blue string
---@field sky string
---@field teal string
---@field lavender string
---@field text string
---@field subtext1 string
---@field subtext0 string
---@field overlay2 string
---@field overlay1 string
---@field overlay0 string
---@field surface2 string
---@field surface1 string
---@field surface0 string
---@field base string
---@field mantle string
---@field crust string
---@field none "NONE"

---@type nil|palette
local palette = nil

-- Indicates if autocmd for refreshing the builtin palette has already been registered
---@type boolean
local _has_palette_autocmd = false

---Initialize the palette
---@return palette
local init_palette = function()
  -- Reinitialize the palette on event `ColorScheme`
  if not _has_palette_autocmd then
    _has_palette_autocmd = true
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("__builtin_palette", { clear = true }),
      pattern = "*",
      callback = function()
        palette = nil
        init_palette()
      end,
    })
  end

  if not palette then
    palette = vim.g.colors_name:find "catppuccin" and require("catppuccin.palettes").get_palette()
      or {
        rosewater = "#DC8A78",
        flamingo = "#DD7878",
        mauve = "#CBA6F7",
        pink = "#F5C2E7",
        red = "#E95678",
        maroon = "#B33076",
        peach = "#FF8700",
        yellow = "#F7BB3B",
        green = "#AFD700",
        sapphire = "#36D0E0",
        blue = "#61AFEF",
        sky = "#04A5E5",
        teal = "#B5E8E0",
        lavender = "#7287FD",

        text = "#F2F2BF",
        subtext1 = "#BAC2DE",
        subtext0 = "#A6ADC8",
        overlay2 = "#C3BAC6",
        overlay1 = "#988BA2",
        overlay0 = "#6E6B6B",
        surface2 = "#6E6C7E",
        surface1 = "#575268",
        surface0 = "#302D41",

        base = "#1D1536",
        mantle = "#1C1C19",
        crust = "#161320",
      }

    palette = vim.tbl_extend("force", { none = "NONE" }, palette)
  end

  return palette
end

---Generate universal highlight groups
---@param overwrite palette? @The color to be overwritten | highest priority
---@return palette
M.palette = function(overwrite)
  if not overwrite then
    return init_palette()
  else
    return vim.tbl_extend("force", init_palette(), overwrite)
  end
end

return M
