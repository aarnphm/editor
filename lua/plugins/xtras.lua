local extras = { "plugins.lang.sql", "plugins.lang.clangd" }

return vim.tbl_map(function(extra) return { import = extra } end, extras)
