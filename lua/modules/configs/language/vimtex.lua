return function()
	if require("editor").global.is_mac then
		vim.g.vimtex_view_method = "skim"
		vim.g.vimtex_view_general_viewer = "/Applications/Skim.app/Contents/SharedSupport/displayline"
		vim.g.vimtex_view_general_options = "-r @line @pdf @tex"
	end

	vim.api.nvim_create_autocmd("User", {
		group = vim.api.nvim_create_augroup("vimtext_mac", { clear = true }),
		pattern = "VimtexEventCompileSuccess",
		callback = function(_)
			local out = vim.b.vimtex.out()
			local src_file_path = vim.fn.expand "%:p"
			local cmd = { vim.g.vimtex_view_general_viewer, "-r" }

			if vim.fn.empty(vim.fn.system "pgrep Skim") == 0 then table.insert(cmd, "-g") end

			vim.fn.jobstart(vim.list_extend(cmd, { vim.fn.line ".", out, src_file_path }))
		end,
	})
end
