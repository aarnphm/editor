-- treesitter
Util.pack.load "nvim-treesitter"

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

local ts = require "nvim-treesitter"
ts.setup()
register_mojo_parser()
Util.treesitter.get_installed(true)

vim.api.nvim_create_user_command("TSInstallDefault", function()
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
  ts.install(missing, { summary = true })
end, { desc = "treesitter: install configured missing parsers" })

vim.api.nvim_create_autocmd("FileType", {
  group = augroup "treesitter",
  callback = function(ev)
    local ft = ev.match
    if not Util.treesitter.have(ft) then return end

    if Util.treesitter.have(ft, "highlights") then pcall(vim.treesitter.start, ev.buf) end
    if Util.treesitter.have(ft, "indents") then
      Util.set_default("indentexpr", "v:lua.Util.treesitter.indentexpr()")
    end
    if Util.treesitter.have(ft, "folds") and Util.set_default("foldmethod", "expr") then
      Util.set_default("foldexpr", "v:lua.Util.treesitter.foldexpr()")
    end
  end,
})
