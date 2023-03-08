local M = {}

---@param c string @The color in hexadecimal.
local hex_to_rgb = function(c)
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
		if
			type(attr) == "string"
			and attr ~= "foreground"
			and attr ~= "background"
			and attr ~= "special"
		then
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
	local bg = hex_to_rgb(background)
	local fg = hex_to_rgb(foreground)

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
	if vim.loop.os_uname().sysname == "Windows_NT" then
		path = vim.fn.trim(vim.fn.system("where " .. binary))
	else
		path = vim.fn.trim(vim.fn.system("which " .. binary))
	end
	if vim.v.shell_error ~= 0 then path = nil end
	return path
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

M.path = {
	join = function(...)
		return table.concat(
			vim.tbl_flatten { ... },
			vim.loop.os_uname().sysname == "Windows_NT" and "\\" or "/"
		)
	end,
}

M.has = function(plugin) return require("lazy.core.config").plugins[plugin] ~= nil end

---@param name string
M.opts = function(name)
	local plugin = require("lazy.core.config").plugins[name]
	if not plugin then return {} end
	return require("lazy.core.plugin").values(plugin, "opts", false)
end

M.on_attach = function(on_attach)
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local buffer = args.buf
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			on_attach(client, buffer)
		end,
	})
end

return M
