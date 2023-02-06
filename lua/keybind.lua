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

function RHS:new()
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
function RHS:map_cmd(cmd_string)
	self.cmd = cmd_string
	return self
end

---@param cmd_string string
---@return RhsContainer
function RHS:map_cr(cmd_string)
	self.cmd = (":%s<CR>"):format(cmd_string)
	return self
end

---@param cmd_string string
---@return RhsContainer
function RHS:map_args(cmd_string)
	self.cmd = (":%s<Space>"):format(cmd_string)
	return self
end

---@param cmd_string string
---@return RhsContainer
function RHS:map_cu(cmd_string)
	self.cmd = (":<C-u>%s<CR>"):format(cmd_string)
	return self
end

---@param callback fun():nil
--- Takes a callback that will be called when the key is pressed
---@return RhsContainer
function RHS:map_callback(callback)
	self.cmd = ""
	self.options.callback = callback
	return self
end

---@return RhsContainer
function RHS:with_defaults()
	-- this defaults include noremap and silent
	self.options.noremap = true
	self.options.silent = true
	return self
end

---@return RhsContainer
function RHS:with_silent()
	self.options.silent = true
	return self
end

---@return RhsContainer
function RHS:with_noremap()
	self.options.noremap = true
	return self
end

---@return RhsContainer
function RHS:with_expr()
	self.options.expr = true
	return self
end

---@return RhsContainer
function RHS:with_nowait()
	self.options.nowait = true
	return self
end

---@param bufnr number
---@return RhsContainer
function RHS:with_buffer(bufnr)
	self.buffer = bufnr
	return self
end

---@param desc_string string
---@return RhsContainer
function RHS:with_desc(desc_string)
	self.options.desc = desc_string
	return self
end

local pbind = {}
pbind.__index = pbind

---@param cmd_string string
---@return RhsContainer
pbind.map_cr = function(cmd_string)
	local ro = RHS:new()
	return ro:map_cr(cmd_string)
end

---@param cmd_string string
---@return RhsContainer
pbind.map_cmd = function(cmd_string)
	local ro = RHS:new()
	return ro:map_cmd(cmd_string)
end

---@param cmd_string string
---@return RhsContainer
pbind.map_cu = function(cmd_string)
	local ro = RHS:new()
	return ro:map_cu(cmd_string)
end

---@param cmd_string string
---@return RhsContainer
pbind.map_args = function(cmd_string)
	local ro = RHS:new()
	return ro:map_args(cmd_string)
end

---@param callback function
---@return RhsContainer
pbind.map_callback = function(callback)
	local ro = RHS:new()
	return ro:map_callback(callback)
end

---@param mapping table<string, RhsContainer>
pbind.nvim_load_mapping = function(mapping)
	for key, value in pairs(mapping) do
		local mode, keymap = key:match "([^|]*)|?(.*)"
		if type(value) == "table" then
			vim.api.nvim_set_keymap(mode, keymap, value.cmd, value.options)
		end
	end
end

return pbind
