local ls = require "luasnip"
local fmt = require("luasnip.extras.fmt").fmt
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node

---@class simple.util.nit
local M = {}

local date_format = "%Y-%m-%d"
local seconds_in_day = 60 * 60 * 24

M.current_date = function()
  return f(function() return os.date(date_format) end)
end

M.yesterday_date = function()
  return f(function() return os.date(date_format, os.time() - seconds_in_day) end)
end

M.tomorrow_date = function()
  return f(function() return os.date(date_format, os.time() + seconds_in_day) end)
end

---@param real bool
M.localhost = function(real) return real and t "http://127.0.0.1" or t "http://localhost" end

return M
