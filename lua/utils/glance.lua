---@class lazyvim.util.glance
local M = {}

---@param method {label:string, lsp_method:string, non_standard?:boolean}
---@return fun(bufnr: number, params: table|nil, callback: lsp.Handler)
M.create_handler = function(method)
  return function(bufnr, params, cb)
    local _client_request_ids, cancel_all_requests, client_request_ids

    _client_request_ids, cancel_all_requests = vim.lsp.buf_request(
      bufnr,
      method.lsp_method,
      params,
      function(err, result, ctx)
        if not client_request_ids then
          -- do a copy of the table we don't want
          -- to mutate the original table
          client_request_ids = vim.tbl_deep_extend("keep", _client_request_ids, {})
        end

        -- Don't log a error when LSP method is non-standard
        if err and not method.non_standard then
          Util.error(("An error happened requesting %s: %s"):format(method.label, err.message), { title = "Glance" })
        end

        if result == nil or vim.islist(result) then
          client_request_ids[ctx.client_id] = nil
        else
          cancel_all_requests()
          result = vim.islist(result) and result or { result }

          return cb(err, result, ctx)
        end

        if vim.tbl_isempty(client_request_ids) then cb {} end
      end
    )
  end
end

---@param opts GlanceOpts
function M.setup(opts)
  local glsp = require "glance.lsp"

  ---HACK: we need to mk the LSP setup here to fix deprecated
  ---since glance are pretty old.
  glsp.setup = function()
    for key, method in pairs(glsp.methods) do
      glsp.methods[key].handler = M.create_handler(method)
    end
  end

  require("glance").setup(opts)
end
return M
