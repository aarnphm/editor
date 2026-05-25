local util = require "conform.util"

local config_file_names = {
  ".oxfmtrc.json",
  ".oxfmtrc.jsonc",
  "oxfmt.config.ts",
}

local function stdin_filepath(ctx)
  local filename = ctx.filename
  if filename == "" then return "stdin.json" end
  if filename:lower():match "%.ipynb$" then return filename .. ".json" end
  return filename
end

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/oxc-project/oxc",
    description = "Oxfmt configured for JSON buffers and notebook JSON files.",
  },
  command = util.from_node_modules "oxfmt",
  args = function(_, ctx) return { "--stdin-filepath", stdin_filepath(ctx) } end,
  stdin = true,
  cwd = util.root_file(config_file_names),
}
