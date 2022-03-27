local config = {}

function config.nvim_lsp()
  require("modules.completion.lspconfig")
end

function config.lightbulb()
  require("nvim-lightbulb").setup({
    -- LSP client names to ignore
    ignore = { "sumneko_lua", "null-ls" },
    sign = {
      enabled = true,
      -- Priority of the gutter sign
      priority = 10,
    },
    float = {
      enabled = false,
      -- Text to show in the popup float
      text = "💡",
      win_opts = {},
    },
    virtual_text = {
      enabled = false,
      -- Text to show at virtual text
      text = "💡",
      -- highlight mode to use for virtual text (replace, combine, blend), see :help nvim_buf_set_extmark() for reference
      hl_mode = "replace",
    },
    status_text = {
      enabled = false,
      -- Text to provide when code actions are available
      text = "💡",
      -- Text to provide when no actions are available
      text_unavailable = "",
    },
  })
  vim.cmd([[autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]])
  vim.cmd([[hi link LightBulbFloatWin YellowFloat]])
  vim.cmd([[hi link LightBulbVirtualText YellowFloat]])
end

function config.cmp()
  vim.cmd([[highlight CmpItemAbbrDeprecated guifg=#D8DEE9 guibg=NONE gui=strikethrough]])
  vim.cmd([[highlight CmpItemKindSnippet guifg=#BF616A guibg=NONE]])
  vim.cmd([[highlight CmpItemKindUnit guifg=#D08770 guibg=NONE]])
  vim.cmd([[highlight CmpItemKindProperty guifg=#A3BE8C guibg=NONE]])
  vim.cmd([[highlight CmpItemKindKeyword guifg=#EBCB8B guibg=NONE]])
  vim.cmd([[highlight CmpItemAbbrMatch guifg=#5E81AC guibg=NONE]])
  vim.cmd([[highlight CmpItemAbbrMatchFuzzy guifg=#5E81AC guibg=NONE]])
  vim.cmd([[highlight CmpItemKindVariable guifg=#8FBCBB guibg=NONE]])
  vim.cmd([[highlight CmpItemKindInterface guifg=#88C0D0 guibg=NONE]])
  vim.cmd([[highlight CmpItemKindText guifg=#81A1C1 guibg=NONE]])
  vim.cmd([[highlight CmpItemKindFunction guifg=#B48EAD guibg=NONE]])
  vim.cmd([[highlight CmpItemKindMethod guifg=#B48EAD guibg=NONE]])

  vim.cmd([[packadd cmp-under-comparator]])

  local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
  end
  local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  local cmp = require("cmp")
  cmp.setup({
    sorting = {
      comparators = {
        cmp.config.compare.offset,
        cmp.config.compare.exact,
        cmp.config.compare.score,
        require("cmp-under-comparator").under,
        cmp.config.compare.kind,
        cmp.config.compare.sort_text,
        cmp.config.compare.length,
        cmp.config.compare.order,
      },
    },
    formatting = {
      format = function(entry, vim_item)
        local lspkind_icons = {
          Text = "",
          Method = "",
          Function = "",
          Constructor = "",
          Field = "",
          Variable = "",
          Class = "ﴯ",
          Interface = "",
          Module = "",
          Property = "ﰠ",
          Unit = "",
          Value = "",
          Enum = "",
          Keyword = "",
          Snippet = "",
          Color = "",
          File = "",
          Reference = "",
          Folder = "",
          EnumMember = "",
          Constant = "",
          Struct = "",
          Event = "",
          Operator = "",
          TypeParameter = "",
        }
        -- load lspkind icons
        vim_item.kind = string.format("%s %s", lspkind_icons[vim_item.kind], vim_item.kind)

        vim_item.menu = ({
          buffer = "[﬘ Buf]",
          nvim_lsp = "[ LSP]",
          luasnip = "[ LSnip]",
          nvim_lua = "[ NvimLua]",
          path = "[~ Path]",
          tmux = "[ Tmux]",
          spell = "[ Spell]",
        })[entry.source.name]

        return vim_item
      end,
    },
    -- You can set mappings if you want
    mapping = {
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<C-p>"] = cmp.mapping.select_prev_item(),
      ["<C-n>"] = cmp.mapping.select_next_item(),
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-e>"] = cmp.mapping.close(),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<C-h>"] = function(fallback)
        if require("luasnip").jumpable(-1) then
          vim.fn.feedkeys(t("<Plug>luasnip-jump-prev"), "")
        else
          fallback()
        end
      end,
      ["<C-l>"] = function(fallback)
        if require("luasnip").expand_or_jumpable() then
          vim.fn.feedkeys(t("<Plug>luasnip-expand-or-jump"), "")
        else
          fallback()
        end
      end,
    },
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    -- You should specify your *installed* sources.
    sources = {
      { name = "nvim_lsp" },
      { name = "nvim_lua" },
      { name = "luasnip" },
      { name = "path" },
      { name = "spell" },
      { name = "tmux" },
      { name = "buffer" },
      { name = "latex_symbols" },
    },
  })
end

function config.luasnip()
  require("luasnip").config.set_config({
    history = true,
    updateevents = "TextChanged,TextChangedI",
  })
  require("luasnip/loaders/from_vscode").load()
end

function config.autopairs()
  require("nvim-autopairs").setup({})

  -- If you want insert `(` after select function or method item
  local cmp_autopairs = require("nvim-autopairs.completion.cmp")
  local cmp = require("cmp")
  cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))
  cmp_autopairs.lisp[#cmp_autopairs.lisp + 1] = "racket"
end

function config.nvim_lsputils()
  if vim.fn.has("nvim-0.5.1") == 1 then
    vim.lsp.handlers["textDocument/codeAction"] = require("lsputil.codeAction").code_action_handler
    vim.lsp.handlers["textDocument/references"] = require("lsputil.locations").references_handler
    vim.lsp.handlers["textDocument/definition"] = require("lsputil.locations").definition_handler
    vim.lsp.handlers["textDocument/declaration"] = require("lsputil.locations").declaration_handler
    vim.lsp.handlers["textDocument/typeDefinition"] = require("lsputil.locations").typeDefinition_handler
    vim.lsp.handlers["textDocument/implementation"] = require("lsputil.locations").implementation_handler
    vim.lsp.handlers["textDocument/documentSymbol"] = require("lsputil.symbols").document_handler
    vim.lsp.handlers["workspace/symbol"] = require("lsputil.symbols").workspace_handler
  else
    local bufnr = vim.api.nvim_buf_get_number(0)

    vim.lsp.handlers["textDocument/codeAction"] = function(_, _, actions)
      require("lsputil.codeAction").code_action_handler(nil, actions, nil, nil, nil)
    end

    vim.lsp.handlers["textDocument/references"] = function(_, _, result)
      require("lsputil.locations").references_handler(nil, result, {
        bufnr = bufnr,
      }, nil)
    end

    vim.lsp.handlers["textDocument/definition"] = function(_, method, result)
      require("lsputil.locations").definition_handler(nil, result, {
        bufnr = bufnr,
        method = method,
      }, nil)
    end

    vim.lsp.handlers["textDocument/declaration"] = function(_, method, result)
      require("lsputil.locations").declaration_handler(nil, result, {
        bufnr = bufnr,
        method = method,
      }, nil)
    end

    vim.lsp.handlers["textDocument/typeDefinition"] = function(_, method, result)
      require("lsputil.locations").typeDefinition_handler(nil, result, {
        bufnr = bufnr,
        method = method,
      }, nil)
    end

    vim.lsp.handlers["textDocument/implementation"] = function(_, method, result)
      require("lsputil.locations").implementation_handler(nil, result, {
        bufnr = bufnr,
        method = method,
      }, nil)
    end

    vim.lsp.handlers["textDocument/documentSymbol"] = function(_, _, result, _, bufn)
      require("lsputil.symbols").document_handler(nil, result, { bufnr = bufn }, nil)
    end

    vim.lsp.handlers["textDocument/symbol"] = function(_, _, result, _, bufn)
      require("lsputil.symbols").workspace_handler(nil, result, { bufnr = bufn }, nil)
    end
  end
end

return config
