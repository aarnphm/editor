local slow_format_filetypes = {}
local ignore_folders = { "/node_modules/", "/tinygrad/", "/tinyllm/" }

return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    cmd = { "ConformInfo" },
    init = function() vim.o.formatexpr = "v:lua.require'conform'.formatexpr()" end,
    opts = {
      log_level = vim.log.levels.DEBUG,
      formatters_by_ft = {
        lua = { "stylua" },
        toml = { "taplo" },
        python = { "ruff_fix", "ruff_format" },
        proto = { { "buf", "protolint" } },
        zsh = { "beautysh" },
        ["javascript"] = { "prettier" },
        ["javascriptreact"] = { "prettier" },
        ["typescript"] = { "prettier" },
        ["typescriptreact"] = { "prettier" },
        ["vue"] = { "prettier" },
        ["css"] = { "prettier" },
        ["scss"] = { "prettier" },
        ["less"] = { "prettier" },
        ["html"] = { "prettier" },
        ["json"] = { "prettier" },
        ["jsonc"] = { "prettier" },
        ["yaml"] = { "prettier" },
        ["graphql"] = { "prettier" },
        ["handlebars"] = { "prettier" },
        ["markdown"] = { { "prettierd", "prettier", "cbfmt" } },
        ["markdown.mdx"] = { { "prettierd", "prettier" } },
      },
      format_on_save = function(bufnr)
        if slow_format_filetypes[vim.bo[bufnr].filetype] then return end
        local on_format = function(err)
          if err and err:match "timeout$" then slow_format_filetypes[vim.bo[bufnr].filetype] = true end
        end

        -- Disable autoformat on certain filetypes
        local ignore_filetypes = { "gitcommit" }
        if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then return end
        -- Disable with a global or buffer-local variable
        if vim.g.autoformat or vim.b[bufnr].autoformat then return end
        -- Disable autoformat for files in a certain path
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        for _, folder in ipairs(ignore_folders) do
          if bufname:match(folder) then return end
        end

        return { timeout_ms = 200, lsp_fallback = true }, on_format
      end,
      format_after_save = function(bufnr)
        if not slow_format_filetypes[vim.bo[bufnr].filetype] then return end
        return { lsp_fallback = true }
      end,
    },
    keys = {
      {
        "<Leader><Leader>f",
        function() require("conform").format { async = true, lsp_fallback = true } end,
        desc = "style: format buffer",
      },
    },
    config = function(_, opts)
      local conform = require "conform"
      conform.setup(opts)

      vim.api.nvim_create_user_command("FormatDisable", function(args)
        -- FormatDisable! will disable formatting just for this buffer
        if args.bang then
          vim.b.autoformat = true
        else
          vim.g.autoformat = true
        end
      end, {
        desc = "Disable autoformat-on-save",
        bang = true,
      })
      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.autoformat = false
        vim.g.autoformat = false
      end, {
        desc = "Re-enable autoformat-on-save",
      })

      vim.api.nvim_create_user_command("Format", function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
          }
        end
        conform.format { async = true, lsp_fallback = true, range = range }
      end, { range = true })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = { "CmdlineEnter", "InsertEnter" },
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "onsails/lspkind.nvim",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-emoji",
      "hrsh7th/cmp-cmdline",
      "kdheepak/cmp-latex-symbols",
      {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        keys = {
          {
            "<tab>",
            function() return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>" end,
            expr = true,
            silent = true,
            mode = "i",
          },
          { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
          { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
        },
        build = (not jit.os:find "Windows")
            and "echo -e 'NOTE: jsregexp is optional, so not a big deal if it fails to build\n'; make install_jsregexp"
          or nil,
        config = function(_, opts)
          require("luasnip").setup(opts)
          require("luasnip.loaders.from_vscode").lazy_load()
          require("luasnip.loaders.from_lua").lazy_load { paths = vim.fn.stdpath "config" .. "/snippets/" }
          vim.api.nvim_create_user_command(
            "LuaSnipEdit",
            function() require("luasnip.loaders.from_lua").edit_snippet_files() end,
            {}
          )
        end,
        opts = {
          history = true,
          -- Event on which to check for exiting a snippet's region
          region_check_events = "InsertEnter",
          delete_check_events = "InsertLeave",
          ft_func = function() return vim.split(vim.bo.filetype, ".", { plain = true }) end,
        },
      },
      {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        build = ":Copilot auth",
        opts = {
          cmp = { enabled = true, method = "getCompletionsCycling" },
          panel = { enabled = false },
          suggestion = { enabled = true, auto_trigger = true },
          filetypes = {
            markdown = true,
            help = false,
            terraform = false,
            hgcommit = false,
            gitcommit = false,
            svn = false,
            cvs = false,
            ["dap-repl"] = false,
            octo = false,
            TelescopePrompt = false,
            big_file_disabled_ft = false,
            neogitCommitMessage = false,
          },
        },
        config = function(_, opts)
          vim.defer_fn(function() require("copilot").setup(opts) end, 100)
        end,
      },
    },
    opts = function()
      local check_backspace = function()
        local col = vim.fn.col "." - 1
        ---@diagnostic disable-next-line: param-type-mismatch
        local current_line = vim.fn.getline "."
        ---@diagnostic disable-next-line: undefined-field
        return col == 0 or current_line:sub(col, col):match "%s"
      end

      ---@param str string
      ---@return string
      local replace_termcodes = function(str) return vim.api.nvim_replace_termcodes(str, true, true, true) end

      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

      local cmp = require "cmp"
      local defaults = require "cmp.config.default"()

      ---@type cmp.ConfigSchema
      return {
        preselect = cmp.PreselectMode.Item,
        completion = { completeopt = "menu,menuone,noinsert" },
        snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
        formatting = {
          fields = { "menu", "abbr", "kind" },
          format = require("lspkind").cmp_format { mode = "symbol", maxwidth = 50 },
        },
        sorting = defaults.sorting,
        experimental = { ghost_text = { hl_group = "CmpGhostText" } },
        mapping = cmp.mapping.preset.insert {
          ["<CR>"] = cmp.mapping.confirm { select = true },
          ["<S-CR>"] = cmp.mapping.confirm { select = true, behavior = cmp.ConfirmBehavior.Replace },
          ["<C-k>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
          ["<C-j>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
          ["<Tab>"] = function(fallback)
            if require("copilot.suggestion").is_visible() then
              require("copilot.suggestion").accept()
            elseif cmp.visible() then
              cmp.select_next_item()
            elseif require("luasnip").expand_or_jumpable() then
              vim.fn.feedkeys(replace_termcodes "<Plug>luasnip-expand-or-jump", "")
            elseif check_backspace() then
              vim.fn.feedkeys(replace_termcodes "<Tab>", "n")
            else
              fallback()
            end
          end,
          ["<S-Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif require("luasnip").jumpable(-1) then
              vim.fn.feedkeys(replace_termcodes "<Plug>luasnip-jump-prev", "")
            else
              fallback()
            end
          end,
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
          { name = "emoji" },
          { name = "buffer" },
          { name = "latex_symbols" },
        },
      }
    end,
    ---@param opts cmp.ConfigSchema
    config = function(_, opts)
      local cmp = require "cmp"
      for _, source in ipairs(opts.sources) do
        source.group_index = source.group_index or 1
      end
      if Util.has "clangd_extensions.nvim" then
        table.insert(opts.sorting.comparators, 1, require "clangd_extensions.cmp_scores")
      end

      cmp.setup(opts)
      if Util.has "cmp-cmdline" then
        cmp.setup.cmdline("/", {
          mapping = cmp.mapping.preset.cmdline(),
          sources = {
            { name = "buffer" },
          },
        })
        cmp.setup.cmdline(":", {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources(
            { { name = "path" } },
            { { name = "cmdline", option = { ignore_cmds = { "Man", "!" } } } }
          ),
        })
      end
      -- special cases with crates.nvim
      vim.api.nvim_create_autocmd({ "BufRead" }, {
        group = augroup "cmp_source_cargo",
        pattern = "Cargo.toml",
        callback = function() cmp.setup.buffer { sources = { { name = "crates" } } } end,
      })
    end,
  },
}
