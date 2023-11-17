-- This is the same as in lspconfig.server_configurations.jdtls, but avoids
-- needing to require that when this module loads.
local java_filetypes = { "java" }

return {
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "hpp", "h" },
    lazy = true,
    opts = function()
      local lspconfig = require "lspconfig"

      local switch_source_header_splitcmd = function(bufnr, splitcmd)
        bufnr = lspconfig.util.validate_bufnr(bufnr)
        local params = { uri = vim.uri_from_bufnr(bufnr) }

        local clangd_client = lspconfig.util.get_active_client_by_name(bufnr, "clangd")

        if clangd_client then
          clangd_client.request("textDocument/switchSourceHeader", params, function(err, result)
            if err then error(tostring(err)) end
            if not result then
              error("Corresponding file can’t be determined", vim.log.levels.ERROR)
              return
            end
            vim.api.nvim_command(splitcmd .. " " .. vim.uri_to_fname(result))
          end)
        else
          error(
            "Method textDocument/switchSourceHeader is not supported by any active server on this buffer",
            vim.log.levels.ERROR
          )
        end
      end

      local get_binary_path_list = function(binaries)
        local get_binary_path = function(binary)
          local path = nil
          if vim.loop.os_uname().sysname == "Windows_NT" then
            path = vim.fn.trim(vim.fn.system("where " .. binary))
          else
            path = vim.fn.trim(vim.fn.system("which " .. binary))
          end
          if vim.v.shell_error ~= 0 then path = nil end
          return path
        end

        local path_list = {}
        for _, binary in ipairs(binaries) do
          local path = get_binary_path(binary)
          if path then table.insert(path_list, path) end
        end
        return table.concat(path_list, ",")
      end

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
            "build.ninja"
          )(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(
            fname
          ) or require("lspconfig.util").find_git_ancestor(fname)
        end,
        server = {
          single_file_support = true,
          filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
          capabilities = { offsetEncoding = { "utf-16" } },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
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
        inlay_hints = { inline = false },
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
}
