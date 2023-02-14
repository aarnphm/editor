local get_rust_adapters = function()
	if require("editor").global.is_windows then
		return {
			type = "executable",
			command = "lldb-vscode",
			name = "rt_lldb",
		}
	end
	local codelldb_extension_path = require("editor").global.mason_dir .. "/packages/codelldb/extension"
	local codelldb_path = codelldb_extension_path .. "/adapter/codelldb"
	local extension = ".so"
	if require("editor").global.is_mac then extension = ".dylib" end
	local liblldb_path = codelldb_extension_path .. "/lldb/lib/liblldb" .. extension
	return require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path)
end

return function(options)
	require("rust-tools").setup {
		tools = {
			inlay_hints = {
				other_hints_prefix = ":: ",
				only_current_line = true,
				show_parameter_hints = false,
			},
		},
		dap = { adapter = get_rust_adapters() },
		server = {
			standalone = true,
			on_attach = options.on_attach,
			capabilities = options.capabilities,
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
end
