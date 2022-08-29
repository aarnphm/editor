local config = {}

config.nvim_lsp = function()
  require("modules.completion.lsp")
end

config.lspsaga = function()
  -- Set icons for sidebar.
  local diagnostic_icons = {
    Error = " ",
    Warn = " ",
    Info = " ",
    Hint = " ",
  }
  for type, icon in pairs(diagnostic_icons) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl })
  end

  local kind = require("lspsaga.lspkind")
  kind[2][2] = " "
  kind[4][2] = " "
  kind[5][2] = "ﴯ "
  kind[6][2] = " "
  kind[7][2] = "ﰠ "
  kind[8][2] = " "
  kind[9][2] = " "
  kind[10][2] = " "
  kind[11][2] = " "
  kind[12][2] = " "
  kind[13][2] = " "
  kind[15][2] = " "
  kind[16][2] = " "
  kind[23][2] = " "
  kind[26][2] = " "

  require("lspsaga").init_lsp_saga()
end

config.cmp = function()
  local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
  end
  local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  local replace_termcodes = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
  end

  local check_backspace = function()
    local col = vim.fn.col(".") - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
  end

  local border = function(hl)
    return {
      { "╭", hl },
      { "─", hl },
      { "╮", hl },
      { "│", hl },
      { "╯", hl },
      { "─", hl },
      { "╰", hl },
      { "│", hl },
    }
  end

  local cmp_window = require("cmp.utils.window")

  function cmp_window:has_scrollbar()
    return false
  end

  local compare = require("cmp.config.compare")

  local cmp = require("cmp")

  local tab_complete = function(fallback)
    if cmp.visible() then
      cmp.select_next_item()
    elseif require("luasnip").expand_or_jumpable() then
      vim.fn.feedkeys(replace_termcodes("<Plug>luasnip-expand-or-jump"), "")
    elseif check_backspace() then
      vim.fn.feedkeys(replace_termcodes("<Tab>"), "n")
    else
      fallback()
    end
  end

  local s_tab_complete = function(fallback)
    if cmp.visible() then
      cmp.select_prev_item()
    elseif require("luasnip").jumpable(-1) then
      vim.fn.feedkeys(replace_termcodes("<Plug>luasnip-jump-prev"), "")
    elseif has_words_before() then
      cmp.complete()
    else
      fallback()
    end
  end

  cmp.setup({
    window = {
      completion = {
        border = border("CmpBorder"),
      },
      documentation = {
        border = border("CmpDocBorder"),
      },
    },
    sorting = {
      comparators = {
        compare.offset,
        compare.exact,
        compare.score,
        require("cmp-under-comparator").under,
        compare.kind,
        compare.sort_text,
        compare.length,
        compare.order,
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
          -- cmp_tabnine = "[TN]",
          buffer = "[BUF]",
          orgmode = "[ORG]",
          nvim_lsp = "[LSP]",
          nvim_lua = "[LUA]",
          path = "[PATH]",
          tmux = "[TMUX]",
          luasnip = "[SNIP]",
          spell = "[SPELL]",
        })[entry.source.name]

        return vim_item
      end,
    },
    -- You can set mappings if you want
    mapping = cmp.mapping.preset.insert({
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<C-p>"] = cmp.mapping.select_prev_item(),
      ["<C-n>"] = cmp.mapping.select_next_item(),
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<Tab>"] = tab_complete,
      ["<S-Tab>"] = s_tab_complete,
      ["<C-e>"] = cmp.mapping({
        i = function(fallback)
          cmp.mapping.abort()(fallback)
        end,
        c = cmp.mapping.close(),
      }),
      ["<C-j>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<C-k>"] = cmp.mapping(function(fallback)
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
    }),
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
      { name = "tmux" },
      { name = "buffer" },
      { name = "latex_symbols" },
      { name = "spell" },
      { name = "emoji" },
    },
  })
end

config.luasnip = function()
  require("luasnip").config.set_config({
    history = true,
    updateevents = "TextChanged,TextChangedI",
  })
  require("luasnip.loaders.from_lua").lazy_load()
  require("luasnip.loaders.from_vscode").lazy_load()
  require("luasnip.loaders.from_snipmate").lazy_load()
end

config.autopairs = function()
  require("nvim-autopairs").setup({
    disable_filetype = { "TelescopePrompt", "vim" },
  })

  -- If you want insert `(` after select function or method item
  local cmp = require("cmp")
  local cmp_autopairs = require("nvim-autopairs.completion.cmp")
  cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

  local handlers = require("nvim-autopairs.completion.handlers")

  cmp.event:on(
    "confirm_done",
    cmp_autopairs.on_confirm_done({
      filetypes = {
        -- "*" is a alias to all filetypes
        ["*"] = {
          ["("] = {
            kind = {
              cmp.lsp.CompletionItemKind.Function,
              cmp.lsp.CompletionItemKind.Method,
            },
            handler = handlers["*"],
          },
        },
      },
    })
  )
end

config.mason_install = function()
  require("mason-tool-installer").setup({

    -- a list of all tools you want to ensure are installed upon
    -- start; they should be the names Mason uses for each tool
    ensure_installed = {
      -- you can turn off/on auto_update per tool
      "efm",
      "rust-analyzer",
      "clangd",
      "deno",
      "typescript-language-server",
      "dockerfile-language-server",
      "gopls",
      "rnix-lsp",
      "pyright",
      "bash-language-server",
      "editorconfig-checker",
      "lua-language-server",
      "stylua",
      "selene",
      "black",
      "pylint",
      "prettier",
      "shellcheck",
      "shfmt",
      "vint",
      "taplo",
    },

    -- if set to true this will check each tool for updates. If updates
    -- are available the tool will be updated.
    -- Default: false
    auto_update = true,

    -- automatically install / update on startup. If set to false nothing
    -- will happen on startup. You can use `:MasonToolsUpdate` to install
    -- tools and check for updates.
    -- Default: true
    run_on_start = true,
  })
end

config.golang = function()
  vim.g.go_doc_keywordprg_enabled = 0
  vim.g.go_def_mapping_enabled = 0
  vim.g.go_code_completion_enabled = 0
end

config.rust_tools = function()
  vim.cmd([[packadd nvim-lspconfig]])
  local opts = {
    tools = {
      -- rust-tools options
      -- Automatically set inlay hints (type hints)
      autoSetHints = true,
      -- Whether to show hover actions inside the hover window
      -- This overrides the default hover handler
      hover_with_actions = true,
      runnables = {
        -- whether to use telescope for selection menu or not
        use_telescope = true,

        -- rest of the opts are forwarded to telescope
      },
      debuggables = {
        -- whether to use telescope for selection menu or not
        use_telescope = true,

        -- rest of the opts are forwarded to telescope
      },
      -- These apply to the default RustSetInlayHints command
      inlay_hints = {
        -- Only show inlay hints for the current line
        only_current_line = false,
        -- Event which triggers a refersh of the inlay hints.
        -- You can make this "CursorMoved" or "CursorMoved,CursorMovedI" but
        -- not that this may cause  higher CPU usage.
        -- This option is only respected when only_current_line and
        -- autoSetHints both are true.
        only_current_line_autocmd = "CursorHold",
        -- wheter to show parameter hints with the inlay hints or not
        show_parameter_hints = true,
        -- prefix for parameter hints
        parameter_hints_prefix = "<- ",
        -- prefix for all the other hints (type, chaining)
        other_hints_prefix = " » ",
        -- whether to align to the length of the longest line in the file
        max_len_align = false,
        -- padding from the left if max_len_align is true
        max_len_align_padding = 1,
        -- whether to align to the extreme right or not
        right_align = false,
        -- padding from the right if right_align is true
        right_align_padding = 7,
      },
      hover_actions = {
        -- the border that is used for the hover window
        -- see vim.api.nvim_open_win()
        border = {
          { "╭", "FloatBorder" },
          { "─", "FloatBorder" },
          { "╮", "FloatBorder" },
          { "│", "FloatBorder" },
          { "╯", "FloatBorder" },
          { "─", "FloatBorder" },
          { "╰", "FloatBorder" },
          { "│", "FloatBorder" },
        },
        -- whether the hover action window gets automatically focused
        auto_focus = false,
      },
    },
    -- all the opts to send to nvim-lspconfig
    -- these override the defaults set by rust-tools.nvim
    -- see https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#rust_analyzer
    server = {}, -- rust-analyzer options
  }

  require("rust-tools").setup(opts)
end

config.vimtex = function()
  vim.g.vimtex_view_method = "skim"
  vim.g.vimtex_view_general_viewer = "/Applications/Skim.app/Contents/SharedSupport/displayline"
  vim.g.vimtex_view_general_options = "-r @line @pdf @tex"

  vim.cmd([[
augroup vimtex_mac
    autocmd!
    autocmd User VimtexEventCompileSuccess call UpdateSkim()
augroup END

function! UpdateSkim() abort
    let l:out = b:vimtex.out()
    let l:src_file_path = expand('%:p')
    let l:cmd = [g:vimtex_view_general_viewer, '-r']

    if !empty(system('pgrep Skim'))
    call extend(l:cmd, ['-g'])
    endif

    call jobstart(l:cmd + [line('.'), l:out, l:src_file_path])
endfunction
  ]])
end

return config
