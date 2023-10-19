---@class simple.util.palette
local M = {}

---@class palette
---@field rosewater string
---@field flamingo string
---@field mauve string
---@field pink string
---@field red string
---@field maroon string
---@field peach string
---@field yellow string
---@field green string
---@field sapphire string
---@field blue string
---@field sky string
---@field teal string
---@field lavender string
---@field text string
---@field subtext1 string
---@field subtext0 string
---@field overlay2 string
---@field overlay1 string
---@field overlay0 string
---@field surface2 string
---@field surface1 string
---@field surface0 string
---@field base string
---@field mantle string
---@field crust string
---@field none "NONE"
---
---@field nc string
---@field surface string
---@field overlay string
---@field muted string
---@field subtle string
---@field love string
---@field gold string
---@field rose string
---@field pine string
---@field foam string
---@field iris string
---@field highlight_low string
---@field highlight_med string
---@field highlight_high string

---@type nil|palette
local palette = nil

-- Indicates if autocmd for refreshing the builtin palette has already been registered
---@type boolean
local _has_palette_autocmd = false

---Initialize the palette
---@return palette
local create = function()
  -- Reinitialize the palette on event `ColorScheme`
  if not _has_palette_autocmd then
    _has_palette_autocmd = true
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("__builtin_palette", { clear = true }),
      pattern = "*",
      callback = function()
        palette = nil
        create()
      end,
    })
  end

  if not palette then
    if vim.g.colors_name:find "catppuccin" then
      palette = require("catppuccin.palettes").get_palette()
    elseif vim.g.colors_name:find "rose-pine" then
      palette = require "rose-pine.palette"
    else
      -- NOTE: Set the default palette here, based on catppuccin
      palette = {
        rosewater = "#DC8A78",
        flamingo = "#DD7878",
        mauve = "#CBA6F7",
        pink = "#F5C2E7",
        red = "#E95678",
        maroon = "#B33076",
        peach = "#FF8700",
        yellow = "#F7BB3B",
        green = "#AFD700",
        sapphire = "#36D0E0",
        blue = "#61AFEF",
        sky = "#04A5E5",
        teal = "#B5E8E0",
        lavender = "#7287FD",

        text = "#F2F2BF",
        subtext1 = "#BAC2DE",
        subtext0 = "#A6ADC8",
        overlay2 = "#C3BAC6",
        overlay1 = "#988BA2",
        overlay0 = "#6E6B6B",
        surface2 = "#6E6C7E",
        surface1 = "#575268",
        surface0 = "#302D41",

        base = "#1D1536",
        mantle = "#1C1C19",
        crust = "#161320",

        none = "NONE",
        nc = "#1f1d30",
        surface = "#2a273f",
        overlay = "#393552",
        muted = "#6e6a86",
        subtle = "#908caa",
        love = "#eb6f92",
        gold = "#f6c177",
        rose = "#ea9a97",
        pine = "#3e8fb0",
        foam = "#9ccfd8",
        iris = "#c4a7e7",
        highlight_low = "#2a283e",
        highlight_med = "#44415a",
        highlight_high = "#56526e",
      }
    end

    palette = vim.tbl_extend("force", { none = "NONE" }, palette)
  end

  return palette
end

---Generate universal highlight groups
---@param overwrite palette? @The color to be overwritten | highest priority
---@return palette
M.get = function(overwrite)
  if not overwrite then
    return create()
  else
    return vim.tbl_extend("force", create(), overwrite)
  end
end

return M
