local M = {}

---@param c string @The color in hexadecimal.
local hexToRgb = function(c)
	c = string.lower(c)
	return { tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16), tonumber(c:sub(6, 7), 16) }
end

---Parse the `style` string into nvim_set_hl options
---@param style string @The style config
---@return table
local parse_style = function(style)
	if not style or style == "NONE" then return {} end

	local result = {}
	for field in string.gmatch(style, "([^,]+)") do
		result[field] = true
	end

	return result
end

---Wrapper function for nvim_get_hl_by_name
---@param hl_group string @Highlight group name
---@return table
local get_highlight = function(hl_group)
	local hl = vim.api.nvim_get_hl_by_name(hl_group, true)
	if hl.link then return get_highlight(hl.link) end

	local result = parse_style(hl.style)
	result.fg = hl.foreground and string.format("#%06x", hl.foreground)
	result.bg = hl.background and string.format("#%06x", hl.background)
	result.sp = hl.special and string.format("#%06x", hl.special)
	for attr, val in pairs(hl) do
		if type(attr) == "string" and attr ~= "foreground" and attr ~= "background" and attr ~= "special" then
			result[attr] = val
		end
	end

	return result
end

---Blend foreground with background
---@param foreground string @The foreground color
---@param background string @The background color to blend with
---@param alpha number|string @Number between 0 and 1 for blending amount.
M.blend = function(foreground, background, alpha)
	alpha = type(alpha) == "string" and (tonumber(alpha, 16) / 0xff) or alpha
	local bg = hexToRgb(background)
	local fg = hexToRgb(foreground)

	local blendChannel = function(i)
		local ret = (alpha * fg[i] + ((1 - alpha) * bg[i]))
		return math.floor(math.min(math.max(0, ret), 255) + 0.5)
	end

	return string.format("#%02x%02x%02x", blendChannel(1), blendChannel(2), blendChannel(3))
end

---Get RGB highlight by highlight group
---@param hl_group string @Highlight group name
---@param use_bg boolean @Returns background or not
---@param fallback_hl? string @Fallback value if the hl group is not defined
---@return string
M.hl_to_rgb = function(hl_group, use_bg, fallback_hl)
	local hex = fallback_hl or "#000000"
	local hlexists = pcall(vim.api.nvim_get_hl_by_name, hl_group, true)

	if hlexists then
		local result = get_highlight(hl_group)
		if use_bg then
			hex = result.bg and result.bg or "NONE"
		else
			hex = result.fg and result.fg or "NONE"
		end
	end

	return hex
end

---Extend a highlight group
---@param name string @Target highlight group name
---@param def? table @Attributes to be extended
M.extend_hl = function(name, def)
	def = def or {}
	local hlexists = pcall(vim.api.nvim_get_hl_by_name, name, true)
	if not hlexists then
		-- Do nothing if highlight group not found
		return
	end
	vim.api.nvim_set_hl(0, name, vim.tbl_deep_extend("force", get_highlight(name), def))
end

M.get_binary_path = function(binary)
	local path = nil
	if require("editor").global.is_mac or require("editor").global.is_linux then
		path = vim.fn.trim(vim.fn.system("which " .. binary))
	elseif require("editor").global.is_windows then
		path = vim.fn.trim(vim.fn.system("where " .. binary))
	end
	if vim.v.shell_error ~= 0 then path = nil end
	return path
end

---@param opts? table<string, any> telescope options. Default to {}.
--- See |telescope.builtin.find_files| and |telescope.builtin.git_files| for opts
---@param safe_git? boolean whether to use git_files or not. Default to true
---@overload fun(opts: table<string, any>): nil
---@overload fun(safe_git: boolean): nil
M.find_files = function(opts, safe_git)
	safe_git = safe_git or true
	opts = opts or {}

	opts = vim.tbl_extend("force", {
		previewer = false,
		shorten_path = true,
		layout_strategy = "horizontal",
	}, opts)

	local find_files = function()
		opts.find_command = 1 == vim.fn.executable "fd"
				and { "fd", "-t", "f", "-H", "-E", ".git", "--strip-cwd-prefix" }
			or nil
		require("telescope.builtin").find_files(
			vim.tbl_deep_extend("keep", opts, require("editor").config.plugins.telescope)
		)
	end

	if safe_git then
		vim.fn.system "git rev-parse --is-inside-work-tree"
		if vim.v.shell_error == 0 then
			require("telescope.builtin").git_files(
				vim.tbl_deep_extend("keep", opts, require("editor").config.plugins.telescope)
			)
		else
			find_files()
		end
	else
		find_files()
	end
end

M.has_words_before = function()
	if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match "^%s*$" == nil
end

M.check_backspace = function()
	local col = vim.fn.col "." - 1
	return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
end

--- Map a function over a table
---@param tbl table<string, any>
---@param func fun(v: any): any
---@return table<string, any> a new table
M.map = function(tbl, func)
	local newtbl = {}
	for i, v in pairs(tbl) do
		newtbl[i] = func(v)
	end
	return newtbl
end

return M
