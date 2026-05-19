local setup_done = false

local function add_bundled_query_runtime()
  local init = vim.api.nvim_get_runtime_file("lua/nvim-treesitter/init.lua", false)[1]
  if not init then return end

  local root = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(init)))
  local runtime = vim.fs.joinpath(root, "runtime")
  if vim.fn.isdirectory(runtime) == 0 then return end
  if vim.tbl_contains(vim.opt.runtimepath:get(), runtime) then return end

  vim.opt.runtimepath:prepend(runtime)
end

local function register_mojo_parser()
  local ok_parsers, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok_parsers then return end
  parsers.mojo = {
    install_info = {
      url = "https://github.com/lsh/tree-sitter-mojo",
      revision = "03966fb3f209bea86844aab3bd0f2158a5a8bb8d",
      queries = "queries",
    },
  }
end

local function setup_treesitter()
  if setup_done then return true end
  setup_done = true

  Util.pack.load "nvim-treesitter"
  add_bundled_query_runtime()
  local ok, ts = pcall(require, "nvim-treesitter")
  if not ok then return false end

  require("treesitter_predicates").setup()
  ts.setup()
  register_mojo_parser()
  Util.treesitter.get_installed(true)
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
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(ev.buf) then
        vim.api.nvim_buf_call(ev.buf, function() start_treesitter(ev.buf, ft) end)
      end
    end)
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup "treesitter_startup_buffers",
  once = true,
  callback = function()
    vim.defer_fn(function()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          vim.api.nvim_buf_call(buf, function() start_treesitter(buf, vim.bo[buf].filetype) end)
        end
      end
    end, 20)
  end,
})
