local get_rust_adapters = function()
	local zox = require "zox"
	if zox.is_windows then return {
		type = "executable",
		command = "lldb-vscode",
		name = "rt_lldb",
	} end
	local codelldb_extension_path = vim.fn.stdpath "data" .. "/mason/packages/codelldb/extension"
	local codelldb_path = codelldb_extension_path .. "/adapter/codelldb"
	local extension = ".so"
	if zox.is_mac then extension = ".dylib" end
	local liblldb_path = codelldb_extension_path .. "/lldb/lib/liblldb" .. extension
	return require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path)
end

require("rust-tools").setup {
	tools = {
		inlay_hints = {
			auto = true,
			other_hints_prefix = ":: ",
			only_current_line = true,
			show_parameter_hints = false,
		},
	},
	dap = { adapter = get_rust_adapters() },
	server = {
		standalone = true,
		settings = {
			["rust-analyzer"] = {
				cargo = {
					loadOutDirsFromCheck = true,
					buildScripts = { enable = true },
				},
				checkOnSave = { command = "clippy" },
				procMacro = { enable = true },
			},
		},
	},
}
