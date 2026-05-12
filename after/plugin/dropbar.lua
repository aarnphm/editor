local setup_done = false

local function file_buffer_exists()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
      return true
    end
  end
  return false
end

local function setup_dropbar()
  if setup_done then return end
  setup_done = true

  Util.pack.load "dropbar.nvim"

  require("dropbar").setup {
    bar = {
      update_events = {
        buf = {
          "FileChangedShellPost",
          "TextChanged",
          "ModeChanged",
          "BufWritePost",
        },
      },
      enable = function(buf, win, _)
        if
          not vim.api.nvim_buf_is_valid(buf)
          or not vim.api.nvim_win_is_valid(win)
          or vim.fn.win_gettype(win) ~= ""
          or vim.wo[win].winbar ~= ""
          or vim.tbl_contains({ "help", "terminal" }, vim.bo[buf].ft)
        then
          return false
        end

        local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
        if stat and stat.size > 1.5 * 1024 * 1024 then return false end

        return vim.bo[buf].ft == "markdown"
          or pcall(vim.treesitter.get_parser, buf)
          or #vim.lsp.get_clients { bufnr = buf, method = "textDocument/documentSymbol" } > 0
      end,
      hover = false,
      sources = function(buf, _)
        local sources = require "dropbar.sources"
        local utils = require "dropbar.utils"
        if vim.bo[buf].ft == "markdown" then return { sources.markdown } end
        return { utils.source.fallback { sources.lsp, sources.treesitter } }
      end,
    },
  }
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = augroup "dropbar_lazy",
  once = true,
  callback = function()
    if vim.v.vim_did_enter == 1 then vim.defer_fn(setup_dropbar, 20) end
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup "dropbar_startup_buffer",
  once = true,
  callback = function()
    if file_buffer_exists() then vim.defer_fn(setup_dropbar, 20) end
  end,
})

vim.keymap.set("n", "<leader>;", function()
  setup_dropbar()
  require("dropbar.api").pick()
end, { desc = "breadcrumbs: pick" })
