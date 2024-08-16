---@meta

---@class LazyVimGlobals
---@field border string control the general border behaviour of floating win
vim.g = {}

_G.Util = require "utils"
_G.MiniIcons = require "mini.icons"

---@alias MiniIconItem [string, string, boolean]
---@alias MiniIconCategory "default" | "directory" | "extension" | "file" | "filetype" | "lsp" | "os"
---
---@overload fun(category: MiniIconCategory, name: string|nil): MiniIconItem
function _G.MiniIcons.get(category, name) end
---@overload fun(category: "lsp", name: string): string
function _G.MiniIcons.get(category, name) end

---@class vim.api.create_autocmd.callback.args
---@field id number
---@field event string
---@field group number?
---@field match string
---@field buf number
---@field file string
---@field data any

---@class vim.api.keyset.create_autocmd.opts: vim.api.keyset.create_autocmd
---@field callback? fun(ev:vim.api.create_autocmd.callback.args):boolean?

--- @param event string | string[] (string|array) Event(s) that will trigger the handler
--- @param opts vim.api.keyset.create_autocmd.opts
--- @return integer
function vim.api.nvim_create_autocmd(event, opts) end

---@class vim.diagnostic.config.Opts: vim.diagnostic.Opts
---@field float? vim.diagnostic.config.Opts.Float
---
---@alias FloatBorderStyle string
---@alias FloatBorderEdges string[]
---@alias FloatBorderEdgesWithHl string[][]
---@alias FloatBorder FloatBorderStyle | FloatBorderEdges | FloatBorderEdgesWithHl
---@class vim.diagnostic.config.Opts.Float: vim.diagnostic.Opts.Float
---@field border? FloatBorder

---@class vim.keymap.set.LazyOpts: vim.keymap.set.Opts, LazyKeysBase
---@field cond nil
---@field has nil

---@overload fun(mode: string|string[], lhs: string, rhs: string|(fun(...): any), opts: vim.keymap.set.LazyOpts)
function vim.keymap.set(mode, lhs, rhs, opts) end

--- we need to add hints for leap.nvim
---@class LeapSpecialKeys
---@field next_target string
---@field prev_target string[]
---@field next_group string
---@field prev_group string[]
---
---@class LeapOpts: table<string, any>
---@field preview_filter nil | fun(...): any
---@field max_highlighted_traversal_targets number
---@field cas_sensitive boolean
---@field equivalence_classes string[]
---@field substitute_chars table<string, string>
---@field safe_labels string[]
---@field labels string[]
---@field special_keys LeapSpecialKeys
---
---@class Leap
---@field opts LeapOpts
---@field add_default_mappings fun(force?: boolean): nil
