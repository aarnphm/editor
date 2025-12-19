-- Clear empty buffers
vim.api.nvim_create_user_command("ClearBuffer", function()
  local removed, failures = 0, {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
      if vim.api.nvim_buf_get_name(buf) == "" then
        local ok, err = pcall(vim.api.nvim_buf_delete, buf, { force = true })
        if ok then
          removed = removed + 1
        else
          table.insert(failures, string.format("buffer %d: %s", buf, err))
        end
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
-- add bigfile filetype and disable some defaults on bigfile
-- add http, dotenv, tsconfig
vim.filetype.add {
  extension = {
    ["http"] = "http",
    env = "dotenv",
    h = "c",
    ["j2"] = "jinja",
  },
  filename = {
    [".env"] = "dotenv",
    ["env"] = "dotenv",
  },
  pattern = {
    ["[jt]sconfig.*.json"] = "jsonc",
    ["%.env%.[%w_.-]+"] = "dotenv",
  },
}
-- starting up quartz scripts
vim.api.nvim_create_user_command("Quartz", function(opts)
  local state = {
    cwd = nil,
    height = 7, -- Reduced from 15 to 8 lines for unfocused terminal
    background = false,
    cmd = { "pnpm", "exec", "tsx", "quartz/scripts/dev.ts" },
  }
  for _, arg in ipairs(opts.fargs) do
    if arg == "bg" then
      state.background = true
    else
      local value = arg:match "cwd=([^%s]+)"
      if value then
        state.cwd = value
      else
        table.insert(state.cmd, arg)
      end
    end
  end
  if state.cwd == nil then state.cwd = Util.root() end
  if state.background then
    local job_id = vim.fn.jobstart(state.cmd, {
      cwd = state.cwd,
      env = { NODE_ENV = "development" },
      on_exit = function(_, code)
        if code == 0 then
          Util.info "Quartz can be accessed at http://localhost:8080"
        else
          Util.error("Quartz process exited with code " .. code)
        end
      end,
      on_stderr = function(_, data)
        if data and #data > 0 then vim.schedule(function() Util.error(table.concat(data, "\n")) end) end
      end,
    })

    if job_id <= 0 then
      Util.error "Failed to start Quartz process"
    else
      Util.info "Quartz process started in background"
    end
  else
    -- Create terminal with unfocused settings
    Util.terminal.bottom(state.cmd, {
      height = state.height,
      cwd = state.cwd,
      startinsert = false, -- Don't auto-focus the terminal
      focus = false, -- Don't move focus to the terminal
    })
  end
end, {
  desc = "quartz: start server",
  nargs = "*",
  complete = function(_, _, _)
    local candidates = {} ---@type string[]
    vim.list_extend(candidates, { "bg" })
    vim.list_extend(
      candidates,
      ---@param x string
      vim.tbl_map(function(x) return "cwd=" .. x end, { Util.root() })
    )
    return candidates
  end,
})

local omni_providers = {
  claude = "https://claude.ai/chat/%s",
  chatgpt = "https://chatgpt.com/c/%s",
  gemini = "https://gemini.google.com/app/%s",
}
local omni_provider_order = { "claude", "chatgpt", "gemini" }
local function omni_open(provider, session_id)
  provider = (provider or ""):lower()
  local fmt = omni_providers[provider]
  if not fmt then
    Util.error(("omni: invalid provider %q (expected: claude|chatgpt|gemini)"):format(provider))
    return
  end
  if not session_id or session_id == "" then
    Util.error(("omni: missing session id for %s"):format(provider))
    return
  end

  Util.open_url(fmt:format(session_id))
end
-- Omni providers
vim.api.nvim_create_user_command("Omni", function(opts)
  if #opts.fargs ~= 2 then
    Util.error "omni: expected 2 args: Omni <claude|chatgpt|gemini> <session_id>"
    return
  end
  omni_open(opts.fargs[1], opts.fargs[2])
end, {
  nargs = "+",
  desc = "omni: open chat session in browser",
  complete = function(arg_lead, cmd_line, _)
    local parts = vim.split(cmd_line, "%s+", { trimempty = true })
    local trailing_space = cmd_line:match "%s$" ~= nil
    if #parts == 1 or (#parts == 2 and not trailing_space) then
      local needle = vim.pesc(arg_lead)
      return vim.tbl_filter(function(x) return x:find("^" .. needle) end, omni_provider_order)
    end
    return {}
  end,
})
vim.api.nvim_create_user_command("OmniClaude", function(opts) omni_open("claude", opts.fargs[1]) end, {
  nargs = 1,
  desc = "omni: open claude session in browser",
})
vim.api.nvim_create_user_command("OmniChat", function(opts) omni_open("chatgpt", opts.fargs[1]) end, {
  nargs = 1,
  desc = "omni: open chatgpt session in browser",
})
vim.api.nvim_create_user_command("OmniGem", function(opts) omni_open("gemini", opts.fargs[1]) end, {
  nargs = 1,
  desc = "omni: open gemini session in browser",
})
