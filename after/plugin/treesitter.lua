local setup_done = false

local function setup_treesitter()
  if setup_done then return true end

  Util.pack.load "nvim-treesitter"
  local parser = require "nvim-treesitter.parsers"
  Util.treesitter.setup()

  parser.mojo = {
    install_info = {
      url = "https://github.com/lsh/tree-sitter-mojo",
      revision = "03966fb3f209bea86844aab3bd0f2158a5a8bb8d",
      queries = "queries",
    },
  }

  Util.treesitter.get_installed(true)
  setup_done = true
  return true
end

local function start_treesitter(buf, ft)
  if ft == "" or Util.is_bigfile(buf) or not setup_treesitter() then return end
  if not Util.treesitter.have(ft) then return end

  if Util.treesitter.have(ft, "highlights") then pcall(vim.treesitter.start, buf) end
  if Util.treesitter.have(ft, "indents") then
    Util.set_default("indentexpr", 'v:lua.require("utils").treesitter.indentexpr()')
  end
  if Util.treesitter.have(ft, "folds") and Util.set_default("foldmethod", "expr") then
    Util.set_default("foldexpr", 'v:lua.require("utils").treesitter.foldexpr()')
  end
end

local function start_treesitter_buffer(buf, ft)
  if not (vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf)) then return end
  vim.api.nvim_buf_call(buf, function() start_treesitter(buf, ft or vim.bo[buf].filetype) end)
end

local function start_loaded_buffers()
  local targets = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local ft = vim.bo[buf].filetype
      if ft ~= "" and not Util.is_bigfile(buf) then targets[#targets + 1] = { buf = buf, ft = ft } end
    end
  end

  if #targets == 0 or not setup_treesitter() then return end
  for _, target in ipairs(targets) do
    start_treesitter_buffer(target.buf, target.ft)
  end
end

vim.api.nvim_create_user_command("TSInstallDefault", function()
  if not setup_treesitter() then return end

  local missing = vim.tbl_filter(function(lang) return not Util.treesitter.have(lang) end, {
    "bash",
    "c",
    "cpp",
    "diff",
    "go",
    "gomod",
    "gosum",
    "gowork",
    "html",
    "javascript",
    "jsdoc",
    "json",
    "jsonc",
    "latex",
    "lua",
    "markdown",
    "markdown_inline",
    "mojo",
    "nix",
    "ocaml",
    "python",
    "query",
    "regex",
    "ron",
    "rust",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "yaml",
  })
  if #missing == 0 then
    Util.info "treesitter: all configured parsers are installed"
    return
  end
  require("nvim-treesitter").install(missing, { summary = true })
end, { desc = "treesitter: install configured missing parsers" })

vim.api.nvim_create_autocmd("FileType", {
  group = augroup "treesitter",
  callback = function(ev)
    local ft = ev.match
    if vim.v.vim_did_enter == 0 then return end
    vim.schedule(function() start_treesitter_buffer(ev.buf, ft) end)
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup "treesitter_startup_buffers",
  once = true,
  callback = function() vim.schedule(start_loaded_buffers) end,
})
