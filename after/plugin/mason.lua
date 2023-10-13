local opts = {
  ensure_installed = { "lua-language-server", "pyright", "mypy", "mdx-analyzer" },
  ui = { border = "none" },
}

require('mason').setup(opts)

local mr = require "mason-registry"
for _, tool in ipairs(opts.ensure_installed) do
  local p = mr.get_package(tool)
  if not p:is_installed() then p:install() end
end

vim.keymap.set('n', '<leader>m', "<cmd>Mason<cr>", {desc = "Mason"})
