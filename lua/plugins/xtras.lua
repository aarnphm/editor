local extras = { "plugins.lang.sql", "plugins.lang.clangd", "plugins.lang.python", "plugins.lang.typescript" }

return vim.tbl_map(function(extra) return { import = extra } end, extras)
