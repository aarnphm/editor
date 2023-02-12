return function()
	local alpha = require "alpha"
	local dashboard = require "alpha.themes.dashboard"

	local icons = {
		misc = require("utils.icons").get("misc", true),
		ui = require("utils.icons").get("ui", true),
	}

	---@param postfix string postfix to use with leader
	---@param description string name of the button
	---@param lhs string prefix to use with sc
	---@param rhs string | nil Actual binding to be called when button is pressed. Can be nil.
	---@param opts? table<string, any> Options to be passed to the keybind. See |vim.api.nvim_set_keymap|
	local button = function(postfix, description, lhs, opts)
		local binding = postfix:gsub("%s", ""):gsub(lhs, "<leader>")
		local defaults = { noremap = true, silent = true, nowait = true }
		opts = opts or {}
		if vim.NIL == vim.tbl_get(opts, "callback") then
			vim.notify("No callback provided for " .. description, vim.log.levels.ERROR, { title = "Alpha" })
		end

		return {
			val = description,
			type = "button",
			on_press = function()
				vim.api.nvim_feedkeys(
					vim.api.nvim_replace_termcodes(binding .. "<Ignore>", true, false, true),
					"t",
					false
				)
			end,
			opts = {
				position = "center",
				cursor = 5,
				width = 50,
				shortcut = postfix,
				align_shortcut = "right",
				hl_shortcut = "Keyword",
				keymap = {
					"n",
					binding,
					"",
					vim.tbl_extend("keep", opts, defaults),
				},
			},
		}
	end

	local leader = "SPC"

	dashboard.section.buttons.opts.hl = "String"
	dashboard.section.buttons.val = {
		button(
			"SPC r",
			icons.misc.Rocket .. "File frecency",
			leader,
			{ callback = function() require("telescope").extensions.frecency.frecency() end }
		),
		button(
			"SPC \\",
			icons.ui.List .. "Project find",
			leader,
			{ callback = function() require("telescope").extensions.projects.projects {} end }
		),
		button(
			"SPC w",
			icons.misc.WordFind .. "Word find",
			leader,
			{ callback = function() require("telescope").extensions.live_grep_args.live_grep_args {} end }
		),
		button(
			"SPC f",
			icons.misc.FindFile .. "File find",
			leader,
			{ callback = function() require("utils").find_files(false) end }
		),
		button(
			"SPC n",
			icons.ui.NewFile .. "File new",
			leader,
			{ callback = function() vim.api.nvim_command "enew" end }
		),
	}

	local footer = icons.misc.BentoBox
		.. "github.com/aarnphm"
		.. "   v"
		.. vim.version().major
		.. "."
		.. vim.version().minor
		.. "."
		.. vim.version().patch
		.. "   "
		.. require("lazy").stats().count
		.. " plugins total"

	dashboard.section.footer.opts.hl = "Function"
	dashboard.section.footer.val = footer

	local top_button_pad = 2
	local footer_button_pad = 1
	local heights = #dashboard.section.header.val + 2 * #dashboard.section.buttons.val + top_button_pad

	dashboard.config.layout = {
		{
			type = "padding",
			val = math.max(0, math.ceil((vim.fn.winheight(0) - heights) * 0.25)),
		},
		dashboard.section.header,
		{ type = "padding", val = top_button_pad },
		dashboard.section.buttons,
		{ type = "padding", val = footer_button_pad },
		dashboard.section.footer,
	}

	alpha.setup(dashboard.opts)

	vim.api.nvim_create_autocmd("User", {
		pattern = "LazyVimStarted",
		callback = function()
			dashboard.section.footer.val = footer
			pcall(vim.cmd.AlphaRedraw)
		end,
	})
end
