local vim = vim

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

_G.enhance_align = function(key)
  if not packer_plugins["vim-easy-align"].loaded then
    vim.cmd([[packadd vim-easy-align]])
  end
  local map = { ["nga"] = "<Plug>(EasyAlign)", ["xga"] = "<Plug>(EasyAlign)" }
  return t(map[key])
end
