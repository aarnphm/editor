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

function RHS:map_cmd(cmd_string)
  self.cmd = cmd_string
  return self
end

function RHS:map_cr(cmd_string)
  self.cmd = (":%s<CR>"):format(cmd_string)
  return self
end

function RHS:map_args(cmd_string)
  self.cmd = (":%s<Space>"):format(cmd_string)
  return self
end

function RHS:map_cu(cmd_string)
  self.cmd = (":<C-u>%s<CR>"):format(cmd_string)
  return self
end

function RHS:map_callback(callback)
  self.cmd = ""
  self.options.callback = callback
  return self
end

function RHS:with_defaults()
  -- this defaults include noremap and silent
  self.options.noremap = true
  self.options.silent = true
  return self
end

function RHS:with_silent()
  self.options.silent = true
  return self
end

function RHS:with_noremap()
  self.options.noremap = true
  return self
end

function RHS:with_expr()
  self.options.expr = true
  return self
end

function RHS:with_nowait()
  self.options.nowait = true
  return self
end

function RHS:with_buffer(bufnr)
  self.buffer = bufnr
  return self
end

function RHS:with_desc(desc_string)
  self.options.desc = desc_string
  return self
end

local pbind = {}
pbind.__index = pbind

pbind.map_cr = function(cmd_string)
  local ro = RHS:new()
  return ro:map_cr(cmd_string)
end

pbind.map_cmd = function(cmd_string)
  local ro = RHS:new()
  return ro:map_cmd(cmd_string)
end

pbind.map_cu = function(cmd_string)
  local ro = RHS:new()
  return ro:map_cu(cmd_string)
end

pbind.map_args = function(cmd_string)
  local ro = RHS:new()
  return ro:map_args(cmd_string)
end
pbind.map_callback = function(callback)
  local ro = RHS:new()
  return ro:map_callback(callback)
end

pbind.nvim_load_mapping = function(mapping)
  for key, value in pairs(mapping) do
    local mode, keymap = key:match("([^|]*)|?(.*)")
    if type(value) == "table" then
      vim.api.nvim_set_keymap(mode, keymap, value.cmd, value.options)
    end
  end
end

return pbind
