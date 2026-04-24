---@meta

---@class vim.api.keyset.create_autocmd.opts: vim.api.keyset.create_autocmd
---@field callback? fun(ev:vim.api.create_autocmd.callback.args):boolean?

---@module "utils"
_G.Util = require "utils"

---@param event string | string[] (string|array) Event(s) that will trigger the handler
---@param opts vim.api.keyset.create_autocmd.opts
---@return integer
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

---@class ScratchPadConfig
---@field width integer
---@field output_height integer
---@field side "left"|"right"
---@field focus_on_open boolean

---@class ScratchPadState
---@field code_buf? integer
---@field output_buf? integer
---@field code_win? integer
---@field output_win? integer
---@field side? "left"|"right"
---@field output_lines? string[]
---@field last_selection? { line1?: integer, line2?: integer }

---@class ScratchPadCapture
---@field kind string
---@field lines string[]
---@field side? "left"|"right"
---@field view? table

---@class ScratchPad
---@field config ScratchPadConfig
---@field state ScratchPadState
---@field augroup integer
---@field _win_closed_autocmd? boolean
---@field open fun(opts?: {side?:"left"|"right", width?:integer, output_height?:integer, focus?:boolean}): (integer?, integer?)
---@field close fun()
---@field run fun(line1?: integer, line2?: integer, buf?: integer): string[]|nil
---@field write_output fun(lines: string[])
---@field clear_output fun()
---@field capture fun(win?: integer, buf?: integer): ScratchPadCapture?
---@field rehydrate fun(win?: integer, buf?: integer, state?: ScratchPadCapture)
---@field is_scratch_buffer fun(buf: integer): boolean

---we need to add hints for leap.nvim
---@alias LeapKey string|string[]
---
---@class LeapKeys
---@field next_target LeapKey
---@field prev_target LeapKey
---@field next_group LeapKey
---@field prev_group LeapKey
---
---@class LeapOpts: table<string, any>
---@field preview_filter nil | fun(...): any
---@field max_highlighted_traversal_targets number
---@field equivalence_classes string[]
---@field substitute_chars table<string, string>
---@field safe_labels string|string[]|nil
---@field labels string|string[]
---@field keys LeapKeys
---@field vim_opts table<string, boolean|integer|string|fun(...): any>
---
---@class Leap
---@field opts LeapOpts
---@field add_default_mappings fun(force?: boolean): nil
