---@diagnostic disable: duplicate-set-field
--# selene: allow(global_usage)
local ok, plenary_reload = pcall(require, "plenary.reload")
local reloader = require
if ok then reloader = plenary_reload.reload_module end

_G.P = function(v)
	print(vim.inspect(v))
	return v
end

_G.RELOAD = function(...) return reloader(...) end

_G.R = function(name)
	_G.RELOAD(name)
	return require(name)
end
