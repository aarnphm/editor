---@class RHS
---@field cmd string
---@field options table
---@field options.noremap boolean
---@field options.silent boolean
---@field options.expr boolean
---@field options.nowait boolean
---@field options.callback function
---@field options.desc string
---@field buffer boolean|number
local RHS = {}

RHS.new = function(self)
	local instance = {
		cmd = "",
		options = {
			noremap = false,
			silent = false,
			expr = false,
			nowait = false,
			callback = nil,
			desc = "",
		},
		buffer = false,
	}
	setmetatable(instance, self)
	self.__index = self
	return instance
end

---@param cmd_string string
---@return RHS
RHS.map_cmd = function(self, cmd_string)
	self.cmd = cmd_string
	return self
end

---@param cmd_string string
---@return RHS
RHS.map_cr = function(self, cmd_string)
	self.cmd = (":%s<CR>"):format(cmd_string)
	return self
end

---@param cmd_string string
---@return RHS
RHS.map_args = function(self, cmd_string)
	self.cmd = (":%s<Space>"):format(cmd_string)
	return self
end

---@param cmd_string string
---@return RHS
RHS.map_cu = function(self, cmd_string)
	self.cmd = (":<C-u>%s<CR>"):format(cmd_string)
	return self
end

---@param callback fun():nil
---@return RHS
--- Takes a callback that will be called when the key is pressed
RHS.map_callback = function(self, callback)
	self.cmd = ""
	self.options.callback = callback
	return self
end

---@return RHS
--- Set silent to true
RHS.with_silent = function(self)
	self.options.silent = true
	return self
end

---@return RHS
--- Set noremap to true
RHS.with_noremap = function(self)
	self.options.noremap = true
	return self
end

---@return RHS
--- Whether the keymap is an expression
RHS.with_expr = function(self)
	self.options.expr = true
	return self
end

---@return RHS
--- Set nowait to true
RHS.with_nowait = function(self)
	self.options.nowait = true
	return self
end

---@param bufnr number
---@return RHS
--- Assigning a buffer to a keymap.
RHS.with_buffer = function(self, bufnr)
	self.buffer = bufnr
	return self
end

---@param desc_string string
---@return RHS
--- Assigning a description to a keymap.
RHS.with_desc = function(self, desc_string)
	self.options.desc = desc_string
	return self
end

---@param desc_string string
---@return RHS
--- Sets noremap and silent to true and assigns a description to a keymap.
RHS.with_defaults = function(self, desc_string)
	self.options.noremap = true
	self.options.silent = true
	self:with_desc(desc_string)
	return self
end

local bind = {}
bind.__index = bind

---@param cmd_string string
---@return RHS
bind.map_cr = function(cmd_string) return RHS:new():map_cr(cmd_string) end

---@param cmd_string string
---@return RHS
bind.map_cmd = function(cmd_string) return RHS:new():map_cmd(cmd_string) end

---@param cmd_string string
---@return RHS
bind.map_cu = function(cmd_string) return RHS:new():map_cu(cmd_string) end

---@param cmd_string string
---@return RHS
bind.map_args = function(cmd_string) return RHS:new():map_args(cmd_string) end

---@param callback function
---@return RHS
bind.map_callback = function(callback) return RHS:new():map_callback(callback) end

---@param mapping table<string, RHS>
--- This functions takes the mapping tables and loads them into the neovim
--- keymap. The mapping table should be in the following format: [mode|keymap] = RHS
--- For example:
--- ["n|<Space>ph"] = k.map_cr("Lazy"):with_defaults():with_nowait():with_desc "package: Show",
bind.nvim_load_mapping = function(mapping)
	for key, value in pairs(mapping) do
		local mode, keymap = key:match "([^|]*)|?(.*)"
		if type(value) == "table" then
			local buffer = value.buffer
			if buffer and type(buffer) == "number" then
				vim.api.nvim_buf_set_keymap(buffer, mode, keymap, value.cmd, value.options)
			else
				vim.api.nvim_set_keymap(mode, keymap, value.cmd, value.options)
			end
		end
	end
end

--- Replaces terminal codes and |keycodes| (<CR>, <Esc>, ...) in a string with
--- the internal representation.
---@param str string
---@return string
bind.t = function(str) return vim.api.nvim_replace_termcodes(str, true, true, true) end

return bind
