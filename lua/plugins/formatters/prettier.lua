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
  { "mason-org/mason.nvim", opts = { ensure_installed = { "prettier" } } },
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
