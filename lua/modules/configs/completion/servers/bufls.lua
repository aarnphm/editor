-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/bufls.lua
return {
	cmd = { "bufls", "serve", "--debug" },
	filetypes = { "proto" },
}
