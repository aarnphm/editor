---@class lazyvim.util.terminal
---@overload fun(cmd: string|string[], opts: LazyTermOpts): LazyFloat
local M = setmetatable({}, {
  __call = function(m, ...) return m.open(...) end,
})

---@type table<string,LazyFloat>
local terminals = {}

---@param shell? string
function M.setup(shell)
  vim.o.shell = shell or vim.o.shell

  -- Special handling for pwsh
  if shell == "pwsh" or shell == "powershell" then
    -- Check if 'pwsh' is executable and set the shell accordingly
    if vim.fn.executable "pwsh" == 1 then
      vim.o.shell = "pwsh"
    elseif vim.fn.executable "powershell" == 1 then
      vim.o.shell = "powershell"
    else
      return Util.error "No powershell executable found"
    end

    -- Setting shell command flags
    vim.o.shellcmdflag =
      "-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';"

    -- Setting shell redirection
    vim.o.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'

    -- Setting shell pipe
    vim.o.shellpipe = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'

    -- Setting shell quote options
    vim.o.shellquote = ""
    vim.o.shellxquote = ""
  end
end

---@class LazyTermOpts: LazyCmdOptions
---@field interactive? boolean
---@field esc_esc? boolean
---@field ctrl_hjkl? boolean

-- Opens a floating terminal (interactive by default)
---@param cmd? string[]|string
---@param opts? LazyTermOpts
function M.open(cmd, opts)
  opts = vim.tbl_deep_extend("force", {
    ft = "lazyterm",
    size = { width = 0.9, height = 0.9 },
    backdrop = not cmd and 100 or nil,
  }, opts or {}, { persistent = true }) --[[@as LazyTermOpts]]

  local termkey = vim.inspect { cmd = cmd or "shell", cwd = opts.cwd, env = opts.env, count = vim.v.count1 }

  if terminals[termkey] and terminals[termkey]:buf_valid() then
    terminals[termkey]:toggle()
  else
    terminals[termkey] = require("lazy.util").float_term(cmd, opts)
    local buf = terminals[termkey].buf
    -- Disable mini.indentscope in all lazyterm buffers
    vim.b[buf].miniindentscope_disable = true
    vim.b[buf].lazyterm_cmd = cmd
    if opts.esc_esc == false then vim.keymap.set("t", "<esc>", "<esc>", { buffer = buf, nowait = true }) end
    if opts.ctrl_hjkl == false then
      vim.keymap.set("t", "<c-h>", "<c-h>", { buffer = buf, nowait = true })
      vim.keymap.set("t", "<c-j>", "<c-j>", { buffer = buf, nowait = true })
      vim.keymap.set("t", "<c-k>", "<c-k>", { buffer = buf, nowait = true })
      vim.keymap.set("t", "<c-l>", "<c-l>", { buffer = buf, nowait = true })
    end

    vim.keymap.set("n", "gf", function()
      local f = vim.fn.findfile(vim.fn.expand "<cfile>")
      if f ~= "" then
        vim.cmd "close"
        vim.cmd("e " .. f)
      end
    end, { buffer = buf })

    vim.api.nvim_create_autocmd("BufEnter", {
      buffer = buf,
      callback = function() vim.cmd.startinsert() end,
    })

    vim.cmd "noh"
  end

  return terminals[termkey]
end

---@param cmd? string[]|string
---@param opts? {height?: number, persistent?: boolean, startinsert?: boolean, focus?: boolean}
function M.bottom(cmd, opts)
  opts =
    vim.tbl_deep_extend("force", { height = 15, persistent = true, startinsert = false, focus = true }, opts or {})
  cmd = cmd or { vim.o.shell }
  vim.cmd.new()
  if opts.focus then vim.cmd.wincmd "J" end

  -- winopts
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_height(0, opts.height)
  vim.wo.winfixheight = true

  local buf = vim.api.nvim_get_current_buf()

  local function enforce_height(winid)
    if not winid or not vim.api.nvim_win_is_valid(winid) then return end
    vim.api.nvim_win_set_height(winid, opts.height)
    vim.api.nvim_win_set_option(winid, "winfixheight", true)
  end

  enforce_height(win)

  local resize_group = vim.api.nvim_create_augroup(string.format("lazyterm_bottom_%d", buf), { clear = true })

  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = resize_group,
    buffer = buf,
    callback = function()
      local target = vim.fn.bufwinid(buf)
      if target ~= -1 then enforce_height(target) end
    end,
  })

  vim.api.nvim_create_autocmd("WinEnter", {
    group = resize_group,
    callback = function(event)
      if event.buf ~= buf then return end
      local target = vim.fn.bufwinid(buf)
      if target ~= -1 then enforce_height(target) end
    end,
  })

  vim.api.nvim_create_autocmd({ "WinResized", "VimResized", "TabEnter" }, {
    group = resize_group,
    callback = function()
      local target = vim.fn.bufwinid(buf)
      if target ~= -1 then enforce_height(target) end
    end,
  })
  -- bufopts
  vim.b[buf].lazyterm_cmd = cmd
  vim.b[buf].filetype = "lazyterm"
  vim.b[buf].buftype = "nofile"
  vim.bo[buf].modifiable = false
  -- Disable mini.indentscope in all lazyterm buffers
  vim.b[buf].miniindentscope_disable = true

  -- mappings
  vim.keymap.set("t", "<c-h>", "<c-h>", { buffer = buf, nowait = true })
  vim.keymap.set("t", "<c-j>", "<c-j>", { buffer = buf, nowait = true })
  vim.keymap.set("t", "<c-k>", "<c-k>", { buffer = buf, nowait = true })
  vim.keymap.set("t", "<c-l>", "<c-l>", { buffer = buf, nowait = true })
  vim.keymap.set("n", "gf", function()
    local f = vim.fn.findfile(vim.fn.expand "<cfile>")
    if f ~= "" then
      vim.cmd "close"
      vim.cmd("e " .. f)
    end
  end, { buffer = buf })

  -- autocmd
  vim.api.nvim_create_autocmd("TermClose", {
    once = true,
    buffer = buf,
    callback = function()
      pcall(vim.api.nvim_del_augroup_by_id, resize_group)
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
        if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
        vim.cmd.redraw()
      end)
      vim.cmd.checktime()
    end,
  })

  vim.fn.termopen(cmd, opts)
  if opts.startinsert then
    vim.cmd "noh"
    vim.cmd.startinsert()
  else
    vim.cmd "normal! G"
  end
end

---@param cmd? string[]|string
---@param opts? {width?: number, persistent?: boolean, startinsert?: boolean, side?: "left" | "right"}
function M.side(cmd, opts)
  opts =
    vim.tbl_deep_extend("force", { width = 80, persistent = true, startinsert = false, side = "right" }, opts or {})
  cmd = cmd or { vim.o.shell }

  if opts.side == "left" then
    vim.cmd "vnew"
    vim.cmd.wincmd "H"
  else
    vim.cmd "vnew"
    vim.cmd.wincmd "L"
  end

  -- winopts
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_width(0, opts.width)
  vim.wo.winfixwidth = true

  -- bufopts
  local buf = vim.api.nvim_get_current_buf()
  vim.b[buf].lazyterm_cmd = cmd
  vim.b[buf].filetype = "lazyterm"
  vim.b[buf].buftype = "nofile"
  vim.bo[buf].modifiable = false
  -- Disable mini.indentscope in all lazyterm buffers
  vim.b[buf].miniindentscope_disable = true

  -- mappings
  vim.keymap.set("t", "<c-h>", "<c-h>", { buffer = buf, nowait = true })
  vim.keymap.set("t", "<c-j>", "<c-j>", { buffer = buf, nowait = true })
  vim.keymap.set("t", "<c-k>", "<c-k>", { buffer = buf, nowait = true })
  vim.keymap.set("t", "<c-l>", "<c-l>", { buffer = buf, nowait = true })
  vim.keymap.set("n", "gf", function()
    local f = vim.fn.findfile(vim.fn.expand "<cfile>")
    if f ~= "" then
      vim.cmd "close"
      vim.cmd("e " .. f)
    end
  end, { buffer = buf })

  -- autocmd
  vim.api.nvim_create_autocmd("TermClose", {
    once = true,
    buffer = buf,
    callback = function()
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
        if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
        vim.cmd.redraw()
      end)
      vim.cmd.checktime()
    end,
  })

  vim.fn.termopen(cmd, opts)
  if opts.startinsert then
    vim.cmd "noh"
    vim.cmd.startinsert()
  else
    vim.cmd "normal! G"
  end
end

return M
