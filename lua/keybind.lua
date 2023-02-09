---@class RhsContainer
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
---@return RhsContainer
RHS.map_cmd = function(self, cmd_string)
	self.cmd = cmd_string
	return self
end

---@param cmd_string string
---@return RhsContainer
RHS.map_cr = function(self, cmd_string)
	self.cmd = (":%s<CR>"):format(cmd_string)
	return self
end

---@param cmd_string string
---@return RhsContainer
RHS.map_args = function(self, cmd_string)
	self.cmd = (":%s<Space>"):format(cmd_string)
	return self
end

---@param cmd_string string
---@return RhsContainer
RHS.map_cu = function(self, cmd_string)
	self.cmd = (":<C-u>%s<CR>"):format(cmd_string)
	return self
end

---@param callback fun():nil
--- Takes a callback that will be called when the key is pressed
---@return RhsContainer
RHS.map_callback = function(self, callback)
	self.cmd = ""
	self.options.callback = callback
	return self
end

---@return RhsContainer
RHS.with_defaults = function(self)
	-- this defaults include noremap and silent
	self.options.noremap = true
	self.options.silent = true
	return self
end

---@return RhsContainer
RHS.with_silent = function(self)
	self.options.silent = true
	return self
end

---@return RhsContainer
RHS.with_noremap = function(self)
	self.options.noremap = true
	return self
end

---@return RhsContainer
RHS.with_expr = function(self)
	self.options.expr = true
	return self
end

---@return RhsContainer
RHS.with_nowait = function(self)
	self.options.nowait = true
	return self
end

---@param bufnr number
---@return RhsContainer
RHS.with_buffer = function(self, bufnr)
	self.buffer = bufnr
	return self
end

---@param desc_string string
---@return RhsContainer
RHS.with_desc = function(self, desc_string)
	self.options.desc = desc_string
	return self
end

local pbind = {}
pbind.__index = pbind

---@param cmd_string string
---@return RhsContainer
pbind.map_cr = function(cmd_string) return RHS:new():map_cr(cmd_string) end

---@param cmd_string string
---@return RhsContainer
pbind.map_cmd = function(cmd_string) return RHS:new():map_cmd(cmd_string) end

---@param cmd_string string
---@return RhsContainer
pbind.map_cu = function(cmd_string) return RHS:new():map_cu(cmd_string) end

---@param cmd_string string
---@return RhsContainer
pbind.map_args = function(cmd_string) return RHS:new():map_args(cmd_string) end

---@param callback function
---@return RhsContainer
pbind.map_callback = function(callback) return RHS:new():map_callback(callback) end

---@param mapping table<string, RhsContainer>
pbind.nvim_load_mapping = function(mapping)
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

return pbind
