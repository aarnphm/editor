Util.lsp.formatters({ "json", "jsonc" }, { "oxfmt_json" })
Util.lint.linters({ "json", "jsonc" }, { "jsonlint" })
Util.lsp.on_attach("jsonls", "disable_formatting", function(client)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
  client.server_capabilities.documentOnTypeFormattingProvider = nil
end)
Util.lsp.enable("jsonls", {
  settings = {
    json = {
      format = { enable = false },
      validate = { enable = true },
    },
  },
})

vim.bo.commentstring = "// %s"
local function oxfmt_json_path(path)
  if path == "" then return "stdin.json" end
  if path:lower():match "%.ipynb$" then return path .. ".json" end
  return path
end

local formatprg_path = oxfmt_json_path(vim.api.nvim_buf_get_name(0))
vim.bo.formatprg = "oxfmt --stdin-filepath " .. vim.fn.shellescape(formatprg_path)
