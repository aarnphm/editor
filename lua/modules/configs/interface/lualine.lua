return function()
	local icons = {
		diagnostics = require("icons").get("diagnostics", true),
		misc = require("icons").get("misc", true),
		git = require("icons").get "git",
		ui = require("icons").get("ui", true),
	}

	local escape_status = function()
		local ok, m = pcall(require, "better_escape")
		return ok and m.waiting and icons.misc.EscapeST or ""
	end

	local _cache = { context = "", bufnr = -1 }
	local lspsaga_symbols = function()
		if
			vim.api.nvim_win_get_config(0).zindex
			or vim.tbl_contains(require("editor").global.exclude_ft, vim.bo.filetype)
		then
			return "" -- Excluded filetypes
		else
			local currbuf = vim.api.nvim_get_current_buf()
			local ok, lspsaga = pcall(require, "lspsaga.symbolwinbar")
			if ok and lspsaga:get_winbar() ~= nil then
				_cache.context = lspsaga:get_winbar()
				_cache.bufnr = currbuf
			elseif _cache.bufnr ~= currbuf then
				_cache.context = "" -- NOTE: Reset [invalid] cache (usually from another buffer)
			end

			return _cache.context
		end
	end

	local diff_source = function()
		local gitsigns = vim.b.gitsigns_status_dict
		if gitsigns then
			return {
				added = gitsigns.added,
				modified = gitsigns.changed,
				removed = gitsigns.removed,
			}
		end
	end

	local get_cwd = function()
		local cwd = vim.fn.getcwd()
		if not require("editor").global.is_windows then
			local home = os.getenv "HOME"
			if home and cwd:find(home, 1, true) == 1 then cwd = "~" .. cwd:sub(#home + 1) end
		end
		return icons.ui.RootFolderOpened .. cwd
	end

	local mini_sections = {
		lualine_a = { "filetype" },
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	}
	local outline = {
		sections = mini_sections,
		filetypes = { "lspsagaoutline" },
	}
	local diffview = {
		sections = mini_sections,
		filetypes = { "DiffviewFiles" },
	}

	local python_venv = function()
		local function env_cleanup(venv)
			if string.find(venv, "/") then
				local final_venv = venv
				for w in venv:gmatch "([^/]+)" do
					final_venv = w
				end
				venv = final_venv
			end
			return venv
		end

		if vim.bo.filetype == "python" then
			local venv = os.getenv "CONDA_DEFAULT_ENV"
			if venv then return string.format(icons.misc.PyEnv .. ":(%s)", env_cleanup(venv)) end
			venv = os.getenv "VIRTUAL_ENV"
			if venv then return string.format(icons.misc.PyEnv .. ":(%s)", env_cleanup(venv)) end
		end
		return ""
	end

	require("lualine").setup {
		options = {
			theme = "auto",
			disabled_filetypes = {
				statusline = {
					"alpha",
					"dashboard",
					"NvimTree",
					"prompt",
					"toggleterm",
					"terminal",
					"help",
					"lspsagaoutine",
					"_sagaoutline",
					"DiffviewFiles",
					"quickfix",
					"Trouble",
				},
			},
			component_separators = "|",
			section_separators = { left = "", right = "" },
			globalstatus = require("editor").config.plugins.lualine.globalstatus,
		},
		sections = {
			lualine_a = { { "mode" } },
			lualine_b = {
				{ "branch", icons_enabled = true, icon = icons.git.Branch },
				{ "diff", source = diff_source },
			},
			lualine_c = { lspsaga_symbols },
			lualine_x = {
				{ escape_status },
				{
					"diagnostics",
					sources = { "nvim_diagnostic" },
					symbols = {
						error = icons.diagnostics.Error,
						warn = icons.diagnostics.Warning,
						info = icons.diagnostics.Information,
					},
				},
				{ get_cwd },
			},
			lualine_y = {
				{ "filetype", colored = true, icon_only = true },
				{ python_venv },
				{ "encoding" },
				{
					"fileformat",
					icons_enabled = true,
					symbols = {
						unix = "LF",
						dos = "CRLF",
						mac = "CR",
					},
				},
			},
			lualine_z = { "progress", "location" },
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = { "filename" },
			lualine_x = { "location" },
			lualine_y = {},
			lualine_z = {},
		},
		tabline = {},
		extensions = {
			"quickfix",
			"nvim-tree",
			"nvim-dap-ui",
			"toggleterm",
			"fugitive",
			outline,
			diffview,
		},
	}

	-- Properly set background color for lspsaga
	for _, hlGroup in pairs(require("lspsaga.lspkind").get_kind()) do
		require("utils").extend_hl("LspSagaWinbar" .. hlGroup[1])
	end
	require("utils").extend_hl "LspSagaWinbarSep"
end
