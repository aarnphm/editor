if not vim.pack then return end

local function pack_get()
  local ok, plugins = pcall(vim.pack.get, nil, { info = false })
  if not ok then
    vim.notify("vim.pack.get failed: " .. plugins, vim.log.levels.ERROR, { title = "vim.pack" })
    return {}
  end
  return plugins
end

local function complete_pack_names(arg_lead)
  local matches = {}
  for _, plugin in ipairs(pack_get()) do
    local name = plugin.spec and plugin.spec.name
    if name and name:sub(1, #arg_lead) == arg_lead then table.insert(matches, name) end
  end
  table.sort(matches)
  return matches
end

local function update_pack(opts)
  local names = #opts.fargs > 0 and opts.fargs or nil
  vim.pack.update(names, {
    force = opts.bang,
    target = opts.target,
  })
end

vim.api.nvim_create_user_command("PackStatus", function()
  local lines = {}
  for _, plugin in ipairs(pack_get()) do
    local marker = plugin.active and "*" or " "
    local spec = plugin.spec or {}
    local rev = plugin.rev and plugin.rev:sub(1, 8) or "unlocked"
    table.insert(lines, ("%s %-24s %-10s %s"):format(marker, spec.name or "?", rev, spec.src or ""))
  end

  if #lines == 0 then
    vim.notify("No vim.pack plugins are registered", vim.log.levels.INFO, { title = "vim.pack" })
    return
  end

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "vim.pack" })
end, { desc = "vim.pack: show managed plugins" })

vim.api.nvim_create_user_command("PackUpdate", function(opts) update_pack(opts) end, {
  bang = true,
  nargs = "*",
  complete = complete_pack_names,
  desc = "vim.pack: update plugins",
})

vim.api.nvim_create_user_command("PackLock", function(opts)
  opts.target = "lockfile"
  update_pack(opts)
end, {
  bang = true,
  nargs = "*",
  complete = complete_pack_names,
  desc = "vim.pack: update lockfile metadata",
})
