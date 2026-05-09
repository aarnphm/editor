Util.lsp.formatters({ "c", "cpp", "cuda", "objc", "objcpp" }, { "clang_format" })
Util.lsp.enable("clangd", {
  capabilities = { offsetEncoding = { "utf-16" } },
  root_markers = {
    ".git",
    "Makefile",
    "configure.ac",
    "configure.in",
    "config.h.in",
    "meson.build",
    "meson_options.txt",
    "build.ninja",
    "compile_commands.json",
    "compile_flags.txt",
  },
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
  },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
})

vim.bo.commentstring = "// %s"

vim.keymap.set("n", "<leader>ch", function()
  if vim.fn.exists ":ClangdSwitchSourceHeader" == 2 then
    vim.cmd.ClangdSwitchSourceHeader()
  else
    Util.warn "clangd: switch source/header command is unavailable"
  end
end, { buffer = true, desc = "clangd: switch source/header" })
