---@meta

---@class vim.api.keyset.create_autocmd.opts: vim.api.keyset.create_autocmd
---@field callback? fun(ev:vim.api.create_autocmd.callback.args):boolean?

---@module "utils"
_G.Util = require "utils"

---@param _event string | string[]
---@param _opts vim.api.keyset.create_autocmd.opts
---@return integer
function vim.api.nvim_create_autocmd(_event, _opts) end

---@class vim.diagnostic.config.Opts: vim.diagnostic.Opts
---@field float? vim.diagnostic.config.Opts.Float

---@alias FloatBorderStyle string
---@alias FloatBorderEdges string[]
---@alias FloatBorderEdgesWithHl string[][]
---@alias FloatBorder FloatBorderStyle | FloatBorderEdges | FloatBorderEdgesWithHl

---@class vim.diagnostic.config.Opts.Float: vim.diagnostic.Opts.Float
---@field border? FloatBorder
