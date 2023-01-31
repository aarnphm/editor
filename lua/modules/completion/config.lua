local config = {}

config.lspconfig = function()
  require("modules.completion.lsp")
end

config.copilot = function()
  vim.defer_fn(function()
    require("copilot").setup({
      cmp = {
        enabled = true,
        method = "getCompletionsCycling",
      },
      panel = {
        -- if true, it can interfere with completions in copilot-cmp
        enabled = true,
        auto_refresh = true,
      },
      suggestion = {
        -- if true, it can interfere with completions in copilot-cmp
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<Tab>",
          accept_word = "<Tab>",
          accept_line = "<Tab>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      filetypes = {
        ["TelescopePrompt"] = false,
        ["dap-repl"] = false,
        ["big_file_disabled_ft"] = false,
      },
    })
  end, 100)
end

config.lspsaga = function()
  local icons = {
    diagnostics = require("modules.ui.icons").get("diagnostics", true),
    kind = require("modules.ui.icons").get("kind", true),
    type = require("modules.ui.icons").get("type", true),
    ui = require("modules.ui.icons").get("ui", true),
  }

  local set_sidebar_icons = function()
    -- Set icons for sidebar.
    local diagnostic_icons = {
      Error = icons.diagnostics.Error_alt,
      Warn = icons.diagnostics.Warning_alt,
      Info = icons.diagnostics.Information_alt,
      Hint = icons.diagnostics.Hint_alt,
    }
    for type, icon in pairs(diagnostic_icons) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl })
    end
  end

  set_sidebar_icons()

  local colors = require("modules.utils").get_palette()

  require("lspsaga").setup({
    preview = {
      lines_above = 1,
      lines_below = 12,
    },
    scroll_preview = {
      scroll_down = "<C-j>",
      scroll_up = "<C-k>",
    },
    request_timeout = 3000,
    finder = {
      edit = { "o", "<CR>" },
      vsplit = "s",
      split = "i",
      tabe = "t",
      quit = { "q", "<ESC>" },
    },
    definition = {
      edit = "<C-c>o",
      vsplit = "<C-c>v",
      split = "<C-c>s",
      tabe = "<C-c>t",
      quit = "q",
      close = "<Esc>",
    },
    code_action = {
      num_shortcut = true,
      keys = {
        quit = "q",
        exec = "<CR>",
      },
    },
    lightbulb = {
      enable = false,
      sign = true,
      enable_in_insert = true,
      sign_priority = 20,
      virtual_text = true,
    },
    diagnostic = {
      twice_into = false,
      show_code_action = false,
      show_source = true,
      keys = {
        exec_action = "<CR>",
        quit = "q",
        go_action = "g",
      },
    },
    rename = {
      quit = "<C-c>",
      exec = "<CR>",
      mark = "x",
      confirm = "<CR>",
      whole_project = true,
      in_select = true,
    },
    outline = {
      win_position = "right",
      win_with = "_sagaoutline",
      win_width = 30,
      show_detail = true,
      auto_preview = false,
      auto_refresh = true,
      auto_close = true,
      keys = {
        jump = "<CR>",
        expand_collapse = "u",
        quit = "q",
      },
    },
    symbol_in_winbar = {
      in_custom = true,
      enable = false,
      separator = " " .. icons.ui.Separator,
      hide_keyword = true,
      show_file = false,
      color_mode = true,
    },
    ui = {
      theme = "round",
      border = "single", -- Can be single, double, rounded, solid, shadow.
      winblend = 0,
      expand = icons.ui.ArrowClosed,
      collapse = icons.ui.ArrowOpen,
      preview = icons.ui.Newspaper,
      code_action = icons.ui.CodeAction,
      diagnostic = icons.ui.Bug,
      incoming = icons.ui.Incoming,
      outgoing = icons.ui.Outgoing,
      colors = {
        normal_bg = colors.base,
        title_bg = colors.base,
        red = colors.red,
        megenta = colors.maroon,
        orange = colors.peach,
        yellow = colors.yellow,
        green = colors.green,
        cyan = colors.sapphire,
        blue = colors.blue,
        purple = colors.mauve,
        white = colors.text,
        black = colors.mantle,
        fg = colors.text,
      },
      kind = {
        -- Kind
        Class = { icons.kind.Class, colors.yellow },
        Constant = { icons.kind.Constant, colors.peach },
        Constructor = { icons.kind.Constructor, colors.sapphire },
        Enum = { icons.kind.Enum, colors.yellow },
        EnumMember = { icons.kind.EnumMember, colors.rosewater },
        Event = { icons.kind.Event, colors.yellow },
        Field = { icons.kind.Field, colors.teal },
        File = { icons.kind.File, colors.rosewater },
        Function = { icons.kind.Function, colors.blue },
        Interface = { icons.kind.Interface, colors.yellow },
        Key = { icons.kind.Keyword, colors.red },
        Method = { icons.kind.Method, colors.blue },
        Module = { icons.kind.Module, colors.blue },
        Namespace = { icons.kind.Namespace, colors.blue },
        Number = { icons.kind.Number, colors.peach },
        Operator = { icons.kind.Operator, colors.sky },
        Package = { icons.kind.Package, colors.blue },
        Property = { icons.kind.Property, colors.teal },
        Struct = { icons.kind.Struct, colors.yellow },
        TypeParameter = { icons.kind.TypeParameter, colors.maroon },
        Variable = { icons.kind.Variable, colors.peach },
        -- Type
        Array = { icons.type.Array, colors.peach },
        Boolean = { icons.type.Boolean, colors.peach },
        Null = { icons.type.Null, colors.yellow },
        Object = { icons.type.Object, colors.yellow },
        String = { icons.type.String, colors.green },
        -- ccls-specific icons.
        TypeAlias = { icons.kind.TypeAlias, colors.green },
        Parameter = { icons.kind.Parameter, colors.blue },
        StaticMethod = { icons.kind.StaticMethod, colors.peach },
        -- Microsoft-specific icons.
        Text = { icons.kind.Text, colors.green },
        Snippet = { icons.kind.Snippet, colors.mauve },
        Folder = { icons.kind.Folder, colors.blue },
        Unit = { icons.kind.Unit, colors.green },
        Value = { icons.kind.Value, colors.peach },
      },
    },
  })
end

config.cmp = function()
  local icons = {
    kind = require("modules.ui.icons").get("kind", false),
    type = require("modules.ui.icons").get("type", false),
    cmp = require("modules.ui.icons").get("cmp", false),
  }
  local replace_termcodes = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
  end

  local has_words_before = function()
    if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
      return false
    end
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    -- return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  local border = function(hl)
    return {
      { "┌", hl },
      { "─", hl },
      { "┐", hl },
      { "│", hl },
      { "┘", hl },
      { "─", hl },
      { "└", hl },
      { "│", hl },
    }
  end

  local cmp_window = require("cmp.utils.window")

  cmp_window.info_ = cmp_window.info
  cmp_window.info = function(self)
    local info = self:info_()
    info.scrollable = false
    return info
  end

  local compare = require("cmp.config.compare")
  local lspkind = require("lspkind")
  local cmp = require("cmp")

  local tab_complete = function(fallback)
    if require("copilot.suggestion").is_visible() then
      require("copilot.suggestion").accept()
    elseif cmp.visible() and has_words_before() then
      cmp.select_next_item()
    elseif require("luasnip").expand_or_jumpable() then
      vim.fn.feedkeys(replace_termcodes("<Plug>luasnip-expand-or-jump"), "")
    else
      fallback()
    end
  end

  local s_tab_complete = function(fallback)
    if cmp.visible() then
      cmp.select_prev_item()
    elseif require("luasnip").jumpable(-1) then
      vim.fn.feedkeys(replace_termcodes("<Plug>luasnip-jump-prev"), "")
    else
      fallback()
    end
  end

  cmp.setup({
    window = {
      completion = {
        border = border("Normal"),
        max_width = 80,
        max_height = 20,
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
      fields = { "kind", "abbr", "menu" },
      format = function(entry, vim_item)
        local kind = lspkind.cmp_format({
          mode = "symbol_text",
          maxwidth = 50,
          symbol_map = vim.tbl_deep_extend("force", icons.kind, icons.type, icons.cmp),
        })(entry, vim_item)
        local strings = vim.split(kind.kind, "%s", { trimempty = true })
        kind.kind = " " .. strings[1] .. " "
        kind.menu = "    (" .. strings[2] .. ")"
        return kind
      end,
    },
    -- You can set mappings if you want
    mapping = cmp.mapping.preset.insert({
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<C-k>"] = cmp.mapping.select_prev_item(),
      ["<C-j>"] = cmp.mapping.select_next_item(),
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-e>"] = cmp.mapping.close(),
      ["<Tab>"] = cmp.mapping(tab_complete, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(s_tab_complete, { "i", "s" }),
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
      -- { name = "buffer" },
      { name = "latex_symbols" },
      { name = "spell" },
      { name = "emoji" },
    },
  })
end

config.luasnip = function()
  local snippet_path = os.getenv("HOME") .. "/.config/nvim/custom-snippets/"
  if not vim.tbl_contains(vim.opt.rtp:get(), snippet_path) then
    vim.opt.rtp:append(snippet_path)
  end
  require("luasnip").config.set_config({
    history = true,
    updateevents = "TextChanged,TextChangedI",
    delete_check_events = "TextChanged,InsertLeave",
  })
  require("luasnip.loaders.from_lua").lazy_load()
  require("luasnip.loaders.from_vscode").lazy_load()
  require("luasnip.loaders.from_snipmate").lazy_load()
end

config.autopairs = function()
  require("nvim-autopairs").setup({})

  -- If you want insert `(` after select function or method item
  local cmp_autopairs = require("nvim-autopairs.completion.cmp")
  local cmp = require("cmp")
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

config.mason_install = function()
  require("mason-tool-installer").setup({

    -- a list of all tools you want to ensure are installed upon
    -- start; they should be the names Mason uses for each tool
    ensure_installed = {
      -- you can turn off/on auto_update per tool
      "rust-analyzer",
      "clangd",
      "typescript-language-server",
      "eslint-lsp",
      "efm",
      "dockerfile-language-server",
      "gopls",
      "rnix-lsp",
      "pyright",
      "jdtls",
      "bash-language-server",
      "grammarly-languageserver",
      "lua-language-server",
      "stylua",
      "selene",
      "black",
      "taplo",
      "isort",
      "yamllint",
      "clang-format",
      "buf",
      "pylint",
      "prettier",
      "shellcheck",
      "shfmt",
      "vint",
      "buildifier",
      "taplo",
      "vim-language-server",
      "tflint",
      "jq",
      "yamlfmt",
    },
    auto_update = false,
    run_on_start = true,
  })
end

config.golang = function()
  vim.g.go_doc_keywordprg_enabled = 0
  vim.g.go_def_mapping_enabled = 0
  vim.g.go_code_completion_enabled = 0
end

config.rust_tools = function()
  local opts = {
    tools = { -- rust-tools options

      -- how to execute terminal commands
      -- options right now: termopen / quickfix
      executor = require("rust-tools/executors").termopen,

      -- callback to execute once rust-analyzer is done initializing the workspace
      -- The callback receives one parameter indicating the `health` of the server: "ok" | "warning" | "error"
      on_initialized = function(_)
        require("lsp_signature").on_attach({
          bind = true,
          use_lspsaga = false,
          floating_window = true,
          fix_pos = true,
          hint_enable = true,
          hi_parameter = "Search",
          handler_opts = { "double" },
        })
      end,

      -- automatically call RustReloadWorkspace when writing to a Cargo.toml file.
      reload_workspace_from_cargo_toml = true,

      -- These apply to the default RustSetInlayHints command
      inlay_hints = {
        -- automatically set inlay hints (type hints)
        -- default: true
        auto = true,

        -- Only show inlay hints for the current line
        only_current_line = false,

        -- whether to show parameter hints with the inlay hints or not
        -- default: true
        show_parameter_hints = true,

        -- prefix for parameter hints
        -- default: "<-"
        parameter_hints_prefix = "<- ",

        -- prefix for all the other hints (type, chaining)
        -- default: "=>"
        other_hints_prefix = "=> ",

        -- whether to align to the lenght of the longest line in the file
        max_len_align = false,

        -- padding from the left if max_len_align is true
        max_len_align_padding = 1,

        -- whether to align to the extreme right or not
        right_align = false,

        -- padding from the right if right_align is true
        right_align_padding = 7,

        -- The color of the hints
        highlight = "Comment",
      },

      -- options same as lsp hover / vim.lsp.util.open_floating_preview()
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
        -- default: false
        auto_focus = false,
      },

      -- settings for showing the crate graph based on graphviz and the dot
      -- command
      crate_graph = {
        -- Backend used for displaying the graph
        -- see: https://graphviz.org/docs/outputs/
        -- default: x11
        backend = "x11",
        -- where to store the output, nil for no output stored (relative
        -- path from pwd)
        -- default: nil
        output = nil,
        -- true for all crates.io and external crates, false only the local
        -- crates
        -- default: true
        full = true,

        -- List of backends found on: https://graphviz.org/docs/outputs/
        -- Is used for input validation and autocompletion
        -- Last updated: 2021-08-26
        enabled_graphviz_backends = {
          "bmp",
          "cgimage",
          "canon",
          "dot",
          "gv",
          "xdot",
          "xdot1.2",
          "xdot1.4",
          "eps",
          "exr",
          "fig",
          "gd",
          "gd2",
          "gif",
          "gtk",
          "ico",
          "cmap",
          "ismap",
          "imap",
          "cmapx",
          "imap_np",
          "cmapx_np",
          "jpg",
          "jpeg",
          "jpe",
          "jp2",
          "json",
          "json0",
          "dot_json",
          "xdot_json",
          "pdf",
          "pic",
          "pct",
          "pict",
          "plain",
          "plain-ext",
          "png",
          "pov",
          "ps",
          "ps2",
          "psd",
          "sgi",
          "svg",
          "svgz",
          "tga",
          "tiff",
          "tif",
          "tk",
          "vml",
          "vmlz",
          "wbmp",
          "webp",
          "xlib",
          "x11",
        },
      },
    },

    -- all the opts to send to nvim-lspconfig
    -- these override the defaults set by rust-tools.nvim
    -- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
    server = {
      -- standalone file support
      -- setting it to false may improve startup time
      standalone = true,
    }, -- rust-analyer options

    -- debugging stuff
    dap = {
      adapter = {
        type = "executable",
        command = "lldb-vscode",
        name = "rt_lldb",
      },
    },
  }

  require("rust-tools").setup(opts)
end

config.vimtex = function()
  if __editor_global.is_mac then
    vim.g.vimtex_view_method = "skim"
    vim.g.vimtex_view_general_viewer = "/Applications/Skim.app/Contents/SharedSupport/displayline"
    vim.g.vimtex_view_general_options = "-r @line @pdf @tex"
  end

  vim.api.nvim_command([[
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
