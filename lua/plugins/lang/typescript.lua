---@alias ConformCtx {buf: number, filename: string, dirname: string}
local M = {}

local supported = {
  "css",
  "graphql",
  "handlebars",
  "html",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
  "less",
  "markdown.mdx",
  "markdown",
  "scss",
  "sass",
  "typescript",
  "typescriptreact",
  "vue",
  "yaml",
}

--- Checks if a Prettier config file exists for the given context
---@param ctx ConformCtx
function M.has_config(ctx)
  vim.fn.system { "prettier", "--find-config-path", ctx.filename }
  return vim.v.shell_error == 0
end

--- Checks if a parser can be inferred for the given context:
--- * If the filetype is in the supported list, return true
--- * Otherwise, check if a parser can be inferred
---@param ctx ConformCtx
function M.has_parser(ctx)
  local ft = vim.bo[ctx.buf].filetype --[[@as string]]
  -- default filetypes are always supported
  if vim.tbl_contains(supported, ft) then return true end
  -- otherwise, check if a parser can be inferred
  local ret = vim.fn.system { "prettier", "--file-info", ctx.filename }
  ---@type boolean, string?
  local ok, parser = pcall(function() return vim.fn.json_decode(ret).inferredParser end)
  return ok and parser and parser ~= vim.NIL
end

M.has_config = Util.memoize(M.has_config)
M.has_parser = Util.memoize(M.has_parser)

return {
  { "mason-org/mason.nvim", opts = { ensure_installed = { "oxlint", "prettier" } } },
  { "mfussenegger/nvim-lint", opts = { linters_by_ft = { typescript = { "oxlint" } } } },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tsserver = { enabled = false },
        ts_ls = { enabled = false },
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
                maxInlayHintLength = 30,
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
                local win = vim.api.nvim_get_current_win()
                local params = vim.lsp.util.make_position_params(win, "utf-16")
                Util.lsp.execute {
                  command = "typescript.goToSourceDefinition",
                  arguments = { params.textDocument.uri, params.position },
                  open = true,
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
                  open = true,
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
          Snacks.util.lsp.on({ name = "vtsls" }, function(_, client)
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
          end)

          -- copy typescript settings to javascript
          opts.settings.javascript =
            vim.tbl_deep_extend("force", {}, opts.settings.typescript, opts.settings.javascript or {})
        end,
      },
    },
  },
  {
    "stevearc/conform.nvim",
    ---@param opts conform.setupOpts
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs(supported) do
        if vim.tbl_contains({ "markdown", "markdown.mdx" }, ft) then
          opts.formatters_by_ft[ft] = { "prettier", "cbfmt" }
        else
          opts.formatters_by_ft[ft] = { "prettier" }
        end
      end

      opts.formatters = opts.formatters or {}
      opts.formatters.prettier = {
        -- configure whether prettier will requires configuration. If true, then prettier won't be run for compatible files if configuration is missing
        condition = function(_, ctx) return M.has_parser(ctx) and M.has_config(ctx) end,
      }
    end,
  },
}
