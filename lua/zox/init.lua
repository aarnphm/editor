local e = require "editor"
local exported = {
	adapters = {},
	servers = {},
}

if not vim.tbl_contains(vim.opt.rtp:get(), e.global.zox) then vim.opt.rtp:append(e.global.zox) end

for package, table in pairs(exported) do
	setmetatable(table, {
		__index = function(t, k)
			local ok, builtin = pcall(require, string.format("zox.%s.%s", package, k))
			if not ok then
				vim.notify(
					string.format("Failed to load '%s' for '%s'; make sure '%s' is available.", k, package, k),
					vim.log.levels.DEBUG,
					{ title = "zox: configuration" }
				)
				return
			end
			rawset(t, k, builtin)
			return builtin
		end,
	})
end

return setmetatable(exported, {
	__index = function(t, k)
		if not rawget(t, k) then
			vim.notify(
				string.format(
					"Failed to load builtin table for package '%s'; make sure '%s' is available in zox.",
					k,
					k
				),
				vim.log.levels.WARN,
				{ title = "zox: configuration" }
			)
		end
		return rawget(t, k)
	end,
})
