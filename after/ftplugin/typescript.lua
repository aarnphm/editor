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
