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
    mojo = "mojo",
    ["🔥"] = "mojo",
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
