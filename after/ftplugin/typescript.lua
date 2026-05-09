Util.lsp.formatters({ "javascript", "javascriptreact", "typescript", "typescriptreact" }, { "prettier" })
vim.cmd.runtime "after/ftplugin/tailwindcss.lua"

local vtsls = {
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
        completion = { enableServerSideFuzzyMatch = true },
      },
    },
    typescript = {
      updateImportsOnFileMove = { enabled = "always" },
      suggest = { completeFunctionCalls = true },
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
}
vtsls.settings.javascript = vim.tbl_deep_extend("force", {}, vtsls.settings.typescript)

Util.lsp.enable("vtsls", vtsls)

vim.bo.commentstring = "// %s"

local function source_action(kind)
  return function()
    vim.lsp.buf.code_action {
      apply = true,
      context = {
        only = { kind },
        diagnostics = {},
      },
    }
  end
end

vim.keymap.set(
  "n",
  "<leader>co",
  source_action "source.organizeImports",
  { buffer = true, desc = "lsp: organize imports" }
)
vim.keymap.set(
  "n",
  "<leader>cM",
  source_action "source.addMissingImports.ts",
  { buffer = true, desc = "lsp: add missing imports" }
)
vim.keymap.set(
  "n",
  "<leader>cu",
  source_action "source.removeUnused.ts",
  { buffer = true, desc = "lsp: remove unused imports" }
)
vim.keymap.set(
  "n",
  "<leader>cD",
  source_action "source.fixAll.ts",
  { buffer = true, desc = "lsp: fix all diagnostics" }
)
vim.keymap.set(
  "n",
  "<leader>cV",
  function() vim.lsp.buf.execute_command { command = "typescript.selectTypeScriptVersion", arguments = {} } end,
  { buffer = true, desc = "lsp: select TS workspace version" }
)
