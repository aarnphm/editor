return {
  {
    "mfussenegger/nvim-lint",
    event = Util.lazy_file_events,
    ---@alias LintOptions table<string,table>
    opts = {
      -- Event to trigger linters
      events = { "BufWritePost", "BufReadPost", "InsertLeave" },
      linters_by_ft = { lua = { "selene" }, python = { "ruff", "mypy" } },
      ---@type table<string,table>
      linters = {
        -- -- Example of using selene only when a selene.toml file is present
        selene = {
          -- `condition` is another LazyVim extension that allows you to
          -- dynamically enable/disable linters based on the context.
          condition = function(ctx) return vim.fs.find({ "selene.toml" }, { path = ctx.filename, upward = true })[1] end,
        },
        ruff = {
          condition = function(ctx)
            return vim.fs.find({ "ruff.toml", "pyproject.toml", ".ruff.toml" }, { path = ctx.filename, upward = true })[1]
          end,
        },
        mypy = {
          condition = function(ctx)
            return vim.fs.find({ "mypy.ini", "pyproject.toml" }, { path = ctx.filename, upward = true })[1]
          end,
        },
      },
    },
    config = function(_, opts)
      local lint = require "lint"
      for name, linter in pairs(opts.linters) do
        if type(linter) == "table" and type(lint.linters[name]) == "table" then
          lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
        else
          lint.linters[name] = linter
        end
      end
      lint.linters_by_ft = opts.linters_by_ft

      local M = {}
      M.debounce = function(ms, fn)
        local timer = vim.loop.new_timer()
        return function(...)
          local argv = { ... }
          timer:start(ms, 0, function()
            timer:stop()
            vim.schedule_wrap(fn)(unpack(argv))
          end)
        end
      end

      M.lint = function()
        -- Use nvim-lint's logic first:
        -- * checks if linters exist for the full filetype first
        -- * otherwise will split filetype by "." and add all those linters
        -- * this differs from conform.nvim which only uses the first filetype that has a formatter
        local names = lint._resolve_linter_by_ft(vim.bo.filetype)

        -- Add fallback linters.
        if #names == 0 then vim.list_extend(names, lint.linters_by_ft["_"] or {}) end

        -- Add global linters.
        vim.list_extend(names, lint.linters_by_ft["*"] or {})

        -- Filter out linters that don't exist or don't match the condition.
        local ctx = { filename = vim.api.nvim_buf_get_name(0) }
        ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
        names = vim.tbl_filter(function(name)
          local linter = lint.linters[name]
          if not linter then Util.warn("Linter not found: " .. name, { title = "nvim-lint" }) end
          return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
        end, names)

        -- Run linters.
        if #names > 0 then lint.try_lint(names) end
      end

      vim.api.nvim_create_autocmd(opts.events, {
        group = augroup "nvim-lint",
        callback = M.debounce(100, M.lint),
      })
    end,
  },
}
