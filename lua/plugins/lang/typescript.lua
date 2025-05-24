return {
  { "mason-org/mason.nvim", opts = { ensure_installed = { "oxlint" } } },
  { "mfussenegger/nvim-lint", opts = { linters_by_ft = { typescript = { "eslint", "oxlint" } } } },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          -- explicitly add default filetypes, so that we can extend
          -- them in related extras
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
          },
          settings = {
            complete_function_calls = true,
            vtsls = {
              enableMoveToFileCodeAction = true,
              autoUseWorkspaceTsdk = true,
              experimental = {
                completion = {
                  enableServerSideFuzzyMatch = true,
                },
              },
            },
            typescript = {
              updateImportsOnFileMove = { enabled = "always" },
              suggest = {
                completeFunctionCalls = true,
              },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = false },
              },
            },
          },
          keys = {
            {
              "gD",
              function()
                local params = vim.lsp.util.make_position_params(vim.api.nvim_get_current_win(), "utf-8")
                Util.lsp.execute {
                  command = "typescript.goToSourceDefinition",
                  arguments = { params.textDocument.uri, params.position },
                }
              end,
              desc = "lsp: goto source definition",
            },
            {
              "gR",
              function()
                Util.lsp.execute {
                  command = "typescript.findAllFileReferences",
                  arguments = { vim.uri_from_bufnr(0) },
                }
              end,
              desc = "lsp: file references",
            },
            {
              "<leader>co",
              Util.lsp.action["source.organizeImports"],
              desc = "lsp: organize imports",
            },
            {
              "<leader>cM",
              Util.lsp.action["source.addMissingImports.ts"],
              desc = "lsp: add missing imports",
            },
            {
              "<leader>cu",
              Util.lsp.action["source.removeUnused.ts"],
              desc = "lsp: remove unused imports",
            },
            {
              "<leader>cD",
              Util.lsp.action["source.fixAll.ts"],
              desc = "lsp: fix all diagnostics",
            },
            {
              "<leader>cV",
              function() Util.lsp.execute { command = "typescript.selectTypeScriptVersion" } end,
              desc = "lsp: select TS workspace version",
            },
          },
        },
      },
      setup = {
        --- @deprecated -- tsserver renamed to ts_ls but not yet released, so keep this for now
        --- the proper approach is to check the nvim-lspconfig release version when it's released to determine the server name dynamically
        tsserver = function() return true end,
        ts_ls = function() return true end,
        vtsls = function(_, opts)
          Util.lsp.on_attach(function(client, bufnr)
            client.commands["_typescript.moveToFileRefactoring"] = function(command, _)
              ---@type lsp.LSPAny, lsp.LSPAny, lsp.LSPAny
              local action, uri, range = unpack(command.arguments)

              local function move(newf)
                client.request("workspace/executeCommand", {
                  command = command.command,
                  arguments = { action, uri, range, newf },
                })
              end

              ---@cast uri string
              local fname = vim.uri_to_fname(uri)
              ---@cast range lsp.Range
              client.request("workspace/executeCommand", {
                command = "typescript.tsserverRequest",
                arguments = {
                  "getMoveToRefactoringFileSuggestions",
                  {
                    file = fname,
                    startLine = range.start.line + 1,
                    startOffset = range.start.character + 1,
                    endLine = range["end"].line + 1,
                    endOffset = range["end"].character + 1,
                  },
                },
              }, function(_, result)
                ---@type string[]
                local files = result.body.files
                table.insert(files, 1, "Enter new path...")
                vim.ui.select(files, {
                  prompt = "Select move destination:",
                  format_item = function(f) return vim.fn.fnamemodify(f, ":~:.") end,
                }, function(f)
                  if f and f:find "^Enter new path" then
                    vim.ui.input({
                      prompt = "Enter move destination:",
                      default = vim.fn.fnamemodify(fname, ":h") .. "/",
                      completion = "file",
                    }, function(newf) return newf and move(newf) end)
                  elseif f then
                    move(f)
                  end
                end)
              end, bufnr)
            end
          end, "vtsls")
          -- copy typescript settings to javascript
          opts.settings.javascript =
            vim.tbl_deep_extend("force", {}, opts.settings.typescript, opts.settings.javascript or {})
        end,
      },
    },
  },
  {
    "windwp/nvim-ts-autotag",
    ft = { "ts", "tsx", "js", "jsx" },
    opts = { opts = { enable_close = true } },
  },
}
