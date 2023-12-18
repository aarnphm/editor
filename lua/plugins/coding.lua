---@param binary string
---@return string|nil
local get_binary_path = function(binary)
  local path = vim.fn.trim(vim.fn.system("which " .. binary))
  if vim.v.shell_error ~= 0 then path = nil end
  return path
end

---@param binaries string[]
local get_binary_path_list = function(binaries)
  local path_list = {}
  for _, binary in ipairs(binaries) do
    local path = get_binary_path(binary)
    if path then table.insert(path_list, path) end
  end
  return table.concat(path_list, ",")
end

return {
  { "fatih/vim-go", ft = { "go", "gomod" } },
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "hpp", "h", "cu" },
    lazy = true,
    opts = function()
      return {
        -- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/clangd.lua
        root_dir = function(fname)
          return require("lspconfig.util").root_pattern(
            "Makefile",
            "configure.ac",
            "configure.in",
            "config.h.in",
            "meson.build",
            "meson_options.txt",
            "WORKSPACE",
            "BUILD.bazel",
            "build.ninja",
            "compile_commands.json",
            "compile_flags.txt"
          )(fname) or require("lspconfig.util").find_git_ancestor(fname)
        end,
        server = {
          single_file_support = true,
          filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
          capabilities = { offsetEncoding = { "utf-16" } },
          init_options = { usePlaceholders = true, completeUnimported = true, clangdFileStatus = true },
          cmd = {
            "clangd",
            "-j=12",
            "--enable-config",
            "--background-index",
            "--pch-storage=memory",
            -- You MUST set this arg ↓ to your c/cpp compiler location (if not included)!
            "--query-driver="
              .. get_binary_path_list {
                "clang++",
                "clang",
                "gcc",
                "g++",
              },
            "--clang-tidy",
            "--all-scopes-completion",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            "--header-insertion-decorators",
            "--header-insertion=iwyu",
            "--limit-references=3000",
            "--limit-results=350",
          },
        },
        inlay_hints = { inline = true },
        ast = {
          --These require codicons (https://github.com/microsoft/vscode-codicons)
          role_icons = {
            type = "",
            declaration = "",
            expression = "",
            specifier = "",
            statement = "",
            ["template argument"] = "",
          },
          kind_icons = {
            Compound = "",
            Recovery = "",
            TranslationUnit = "",
            PackExpansion = "",
            TemplateTypeParm = "",
            TemplateTemplateParm = "",
            TemplateParamObject = "",
          },
        },
      }
    end,
  },
  {
    "simrat39/rust-tools.nvim",
    ft = "rust",
    dependencies = { "nvim-lua/plenary.nvim" },
    lazy = true,
    opts = {
      tools = {
        on_initialized = function()
          vim.cmd [[
                  augroup RustLSP
                    autocmd CursorHold                      *.rs silent! lua vim.lsp.buf.document_highlight()
                    autocmd CursorMoved,InsertEnter         *.rs silent! lua vim.lsp.buf.clear_references()
                    autocmd BufEnter,CursorHold,InsertLeave *.rs silent! lua vim.lsp.codelens.refresh()
                  augroup END
                ]]
        end,
        -- automatically call RustReloadWorkspace when writing to a Cargo.toml file.
        reload_workspace_from_cargo_toml = true,
        inlay_hints = {
          auto = true,
          other_hints_prefix = ":: ",
          only_current_line = true,
          show_parameter_hints = false,
        },
      },
      server = {
        standalone = true,
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              loadOutDirsFromCheck = true,
              buildScripts = { enable = true },
            },
            diagnostics = {
              disabled = { "unresolved-proc-macro" },
              enableExperimental = true,
            },
            checkOnSave = { command = "clippy" },
            procMacro = { enable = true },
          },
        },
      },
    },
    config = function() end,
  },
}
