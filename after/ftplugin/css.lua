Util.lsp.enable "cssls"
Util.lsp.ensure_mason_packages({ "css-lsp" }, { ["css-lsp"] = "cssls" })

vim.cmd.runtime "after/ftplugin/tailwindcss.lua"
