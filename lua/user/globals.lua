---@diagnostic disable: duplicate-set-field
--# selene: allow(global_usage,incorrect_standard_library_use)
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

local getlocals = function(l)
	local i = 0
	local direction = 1
	return function()
		i = i + direction
		local k, v = debug.getlocal(l, i)
		if direction == 1 and (k == nil or k.sub(k, 1, 1) == "(") then
			i = -1
			direction = -1
			k, v = debug.getlocal(l, i)
		end
		return k, v
	end
end

_G.dumpsig = function(f)
	assert(type(f) == "function", "bad argument #1 to 'dumpsig' (function expected)")
	local p = {}
	pcall(function()
		local oldhook
		local hook = function(_, _)
			for k, _ in getlocals(3) do
				if k == "(*vararg)" then
					table.insert(p, "...")
					break
				end
				table.insert(p, k)
			end
			debug.sethook(oldhook)
			error "aborting the call"
		end
		oldhook = debug.sethook(hook, "c")
		-- To test for vararg must pass a least one vararg parameter
		f(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20)
	end)
	return "function(" .. table.concat(p, ",") .. ")"
end
