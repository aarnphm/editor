local config = {}

config.nvim_lsp = function()
  require("modules.completion.lsp")
end

config.lightbulb = function()
  vim.cmd([[autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]])
end

config.aerial = function()
  require("aerial").setup({
    backends = { "treesitter", "lsp", "markdown" },
    layout = {
      -- These control the width of the aerial window.
      -- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
      -- min_width and max_width can be a list of mixed types.
      -- max_width = {40, 0.2} means "the lesser of 40 columns or 20% of total"
      max_width = { 40, 0.2 },
      width = nil,
      min_width = 30,

      -- Enum: prefer_right, prefer_left, right, left, float
      -- Determines the default direction to open the aerial window. The 'prefer'
      -- options will open the window in the other direction *if* there is a
      -- different buffer in the way of the preferred direction
      default_direction = "prefer_right",

      -- Enum: edge, group, window
      --   edge   - open aerial at the far right/left of the editor
      --   group  - open aerial to the right/left of the group of windows containing the current buffer
      --   window - open aerial to the right/left of the current window
      placement = "window",
    },
    ignore = {
      -- Ignore unlisted buffers. See :help buflisted
      unlisted_buffers = true,

      -- List of filetypes to ignore.
      filetypes = { "alpha", "NvimTree" },

      -- Ignored buftypes.
      -- Can be one of the following:
      -- false or nil - No buftypes are ignored.
      -- "special"    - All buffers other than normal buffers are ignored.
      -- table        - A list of buftypes to ignore. See :help buftype for the
      --                possible values.
      -- function     - A function that returns true if the buffer should be
      --                ignored or false if it should not be ignored.
      --                Takes two arguments, `bufnr` and `buftype`.
      buftypes = "special",

      -- Ignored wintypes.
      -- Can be one of the following:
      -- false or nil - No wintypes are ignored.
      -- "special"    - All windows other than normal windows are ignored.
      -- table        - A list of wintypes to ignore. See :help win_gettype() for the
      --                possible values.
      -- function     - A function that returns true if the window should be
      --                ignored or false if it should not be ignored.
      --                Takes two arguments, `winid` and `wintype`.
      wintypes = "special",
    },
  })
end

config.cmp = function()
  vim.cmd([[packadd cmp-under-comparator]])

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

  local cmp = require("cmp")

  local tab_complete = function(fallback)
    local copilot_keys = vim.fn["copilot#Accept"]()
    if copilot_keys ~= "" then
      vim.api.nvim_feedkeys(copilot_keys, "i", true)
    elseif cmp.visible() then
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
    preselect = cmp.PreselectMode.None,
    window = {
      completion = {
        border = border("CmpBorder"),
      },
      documentation = {
        border = border("CmpDocBorder"),
      },
    },
    enabled = function()
      local ctx = require("cmp.config.context")
      if vim.api.nvim_get_mode() == "c" then
        return true
      else
        return not ctx.in_treesitter_capture("comment") and not ctx.in_treesitter_capture("Comment")
      end
    end,
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
          emoji = "[ Emoji]",
          path = "[~ Path]",
          spell = "[  Spell]",
        })[entry.source.name]

        return vim_item
      end,
    },
    -- You can set mappings if you want
    mapping = {
      ["<C-p>"] = cmp.mapping.select_prev_item(),
      ["<C-n>"] = cmp.mapping.select_next_item(),
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-c>"] = cmp.mapping.abort(),
      ["<C-g>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({ select = false }),
      ["<Tab>"] = tab_complete,
      ["<S-Tab>"] = s_tab_complete,
      ["<C-e>"] = cmp.mapping({
        i = function(fallback)
          local copilot_keys = vim.fn["copilot#Accept"]()
          if copilot_keys ~= "" then
            vim.api.nvim_feedkeys(copilot_keys, "i", true)
          else
            cmp.mapping.abort()(fallback)
          end
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
  local handlers = require("nvim-autopairs.completion.handlers")
  cmp.event:on(
    "confirm_done",
    cmp_autopairs.on_confirm_done({
      filetypes = {
        -- "*" is an alias to all filetypes
        ["*"] = {
          ["("] = {
            kind = {
              cmp.lsp.CompletionItemKind.Function,
              cmp.lsp.CompletionItemKind.Method,
            },
            handler = handlers["*"],
          },
        },
        -- Disable for tex
        tex = false,
      },
    })
  )
end

config.bqf = function()
  vim.cmd([[
    hi BqfPreviewBorder guifg=#F2CDCD ctermfg=71
    hi link BqfPreviewRange Search
]])

  require("bqf").setup({
    auto_enable = true,
    auto_resize_height = true, -- highly recommended enable
    preview = {
      win_height = 12,
      win_vheight = 12,
      delay_syntax = 80,
      border_chars = { "┃", "┃", "━", "━", "┏", "┓", "┗", "┛", "█" },
      should_preview_cb = function(bufnr, qwinid)
        local ret = true
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        local fsize = vim.fn.getfsize(bufname)
        if fsize > 100 * 1024 then
          -- skip file size greater than 100k
          ret = false
        elseif bufname:match("^fugitive://") then
          -- skip fugitive buffer
          ret = false
        end
        return ret
      end,
    },
    -- make `drop` and `tab drop` to become preferred
    func_map = {
      drop = "o",
      openc = "O",
      split = "<C-s>",
      tabdrop = "<C-t>",
      tabc = "",
      ptogglemode = "z,",
    },
    filter = {
      fzf = {
        action_for = { ["ctrl-s"] = "split", ["ctrl-t"] = "tab drop" },
        extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
      },
    },
  })
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
