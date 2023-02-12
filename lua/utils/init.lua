local M = {}

---@class palette
---@field rosewater string
---@field flamingo string
---@field mauve string
---@field pink string
---@field red string
---@field maroon string
---@field peach string
---@field yellow string
---@field green string
---@field sapphire string
---@field blue string
---@field sky string
---@field teal string
---@field lavender string
---@field text string
---@field subtext1 string
---@field subtext0 string
---@field overlay2 string
---@field overlay1 string
---@field overlay0 string
---@field surface2 string
---@field surface1 string
---@field surface0 string
---@field base string
---@field mantle string
---@field crust string
---@field none "NONE"

---@type palette
local palette = nil

---Initialize the palette
---@return palette
local init_palette = function()
	if not palette then
		if vim.g.colors_name == "catppuccin" then
			palette = require("catppuccin.palettes").get_palette()
		elseif vim.g.colors_name == "rose-pine" then
			local rp = require "rose-pine.palette"
			-- mapping 1-1 to catppuccin variables
			palette = {
				rosewater = rp.love,
				flamingo = rp.rose,
				mauve = rp.iris,
				pink = rp.rose,
				red = rp.love,
				maroon = rp.love,
				peach = "#ea9a97",
				yellow = "#f6c177",
				green = rp.foam,
				sapphire = rp.pine,
				blue = rp.pine,
				sky = rp.foam,
				teal = rp.pine,
				lavender = rp.iris,

				text = rp.text,
				subtext1 = rp.base,
				subtext0 = rp.base,
				overlay2 = rp.overlay,
				overlay1 = rp.overlay,
				overlay0 = rp.overlay,
				surface2 = rp.surface,
				surface1 = rp.surface,
				surface0 = rp.surface,

				base = rp.base,
				mantle = rp.highlight_high,
				crust = rp.highlight_low,
			}
		else
			palette = {
				rosewater = "#DC8A78",
				flamingo = "#DD7878",
				mauve = "#CBA6F7",
				pink = "#F5C2E7",
				red = "#E95678",
				maroon = "#B33076",
				peach = "#FF8700",
				yellow = "#F7BB3B",
				green = "#AFD700",
				sapphire = "#36D0E0",
				blue = "#61AFEF",
				sky = "#04A5E5",
				teal = "#B5E8E0",
				lavender = "#7287FD",

				text = "#F2F2BF",
				subtext1 = "#BAC2DE",
				subtext0 = "#A6ADC8",
				overlay2 = "#C3BAC6",
				overlay1 = "#988BA2",
				overlay0 = "#6E6B6B",
				surface2 = "#6E6C7E",
				surface1 = "#575268",
				surface0 = "#302D41",

				base = "#1D1536",
				mantle = "#1C1C19",
				crust = "#161320",
			}
		end

		palette = vim.tbl_extend("force", { none = "NONE" }, palette, require("editor").config.palette_overwrite)
	end

	return palette
end

---Generate universal highlight groups
---@param overwrite palette? @The color to be overwritten | highest priority
---@return palette
M.get_palette = function(overwrite)
	if not overwrite then
		return init_palette()
	else
		return vim.tbl_extend("force", init_palette(), overwrite)
	end
end

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
---@param def table @Attributes to be extended
M.extend_hl = function(name, def)
	local hlexists = pcall(vim.api.nvim_get_hl_by_name, name, true)
	if not hlexists then
		-- Do nothing if highlight group not found
		return
	end
	local current_def = get_highlight(name)
	local combined_def = vim.tbl_deep_extend("force", current_def, def)

	vim.api.nvim_set_hl(0, name, combined_def)
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

	opts = vim.tbl_extend("keep", opts or {}, {
		previewer = false,
		shorten_path = true,
		layout_strategy = "horizontal",
	})

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

return M
