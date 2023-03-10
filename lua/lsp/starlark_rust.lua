local u = require "lspconfig.util"

local root_files = { "WORKSPACE", "WORKSPACE.bzlmod", "WORKSPACE.bazel", "MODULE.bazel", "MODULE" }

return function(options)
	require("lspconfig").starlark_rust.setup {
		on_attach = options.on_attach,
		capabilities = options.capabilities,
		cmd = { "starlark", "--lsp" },
		filetypes = { "bzl", "WORKSPACE", "star", "BUILD.bazel", "bazel", "bzlmod" },
		root_dir = function(fname)
			return u.root_pattern(unpack(root_files))(fname)
				or u.find_git_ancestor(fname)
				or u.path.dirname(fname)
		end,
	}
end
