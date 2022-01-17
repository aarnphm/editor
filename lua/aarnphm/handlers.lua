local M = {}

M.implementation = function()
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, "textDocument/implementation", params, function(err, result, ctx, config)
    local bufnr = ctx.bufnr
    local ft = vim.bo[bufnr].filetype
    -- eh i don't like seeing mocks for implementation in go
    if ft == "go" then
      local new_result = vim.tbl_filter(function(v) return not string.find(v.uri, "mock_") end, result)
      if #new_result > 0 then result = new_result end
    end

    vim.lsp.handlers["textDocument/implementation"](err, result, ctx, config)
    vim.cmd [[normal! zz]]
  end)
end

M.definition = function()
  local params = vim.lsp.util.make_position_params()

  vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result, ctx, config)
    if not result or vim.tbl_isempty(result) then
      print "[LSP] Could not find definition"
      return
    end
    if vim.tbl_islist(result) then
      vim.lsp.util.jump_to_location(result[1], "utf-8")
    else
      local ok, glance = pcall(require, "glance")
      if ok then glance.open "definitions" end
      vim.lsp.handlers["textDocument/definition"](err, result, ctx, config)
    end
  end)
end

return M
