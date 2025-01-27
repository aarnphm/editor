if vim.g.vscode then return { import = "plugins.vscode" } end
return vim.tbl_map(function(extra) return { import = extra } end, vim.g.extra_plugins)
