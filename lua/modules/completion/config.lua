local config = {}

config.lspconfig = function()
  require("modules.completion.lsp")
end

config.lspsaga = function()
  local set_sidebar_icons = function()
    -- Set icons for sidebar.
    local diagnostic_icons = {
      Error = " ",
      Warn = " ",
      Info = " ",
      Hint = " ",
    }
    for type, icon in pairs(diagnostic_icons) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl })
    end
  end

  local get_palette = function()
    if vim.g.colors_name == "catppuccin" then
      -- If the colorscheme is catppuccin then use the palette.
      return require("catppuccin.palettes").get_palette()
    else
      -- Default behavior: return lspsaga's default palette.
      local palette = require("lspsaga.lspkind").colors
      palette.peach = palette.orange
      palette.flamingo = palette.orange
      palette.rosewater = palette.yellow
      palette.mauve = palette.violet
      palette.sapphire = palette.blue
      palette.maroon = palette.orange

      return palette
    end
  end

  set_sidebar_icons()

  local colors = get_palette()

  require("lspsaga").init_lsp_saga({
    diagnostic_header = { " ", " ", "  ", " " },
    custom_kind = {
      File = { " ", colors.rosewater },
      Module = { " ", colors.blue },
      Namespace = { " ", colors.blue },
      Package = { " ", colors.blue },
      Class = { "ﴯ ", colors.yellow },
      Method = { " ", colors.blue },
      Property = { "ﰠ ", colors.teal },
      Field = { " ", colors.teal },
      Constructor = { " ", colors.sapphire },
      Enum = { " ", colors.yellow },
      Interface = { " ", colors.yellow },
      Function = { " ", colors.blue },
      Variable = { " ", colors.peach },
      Constant = { " ", colors.peach },
      String = { " ", colors.green },
      Number = { " ", colors.peach },
      Boolean = { " ", colors.peach },
      Array = { " ", colors.peach },
      Object = { " ", colors.yellow },
      Key = { " ", colors.red },
      Null = { "ﳠ ", colors.yellow },
      EnumMember = { " ", colors.teal },
      Struct = { " ", colors.yellow },
      Event = { " ", colors.yellow },
      Operator = { " ", colors.sky },
      TypeParameter = { " ", colors.maroon },
      -- ccls-specific icons.
      TypeAlias = { " ", colors.green },
      Parameter = { " ", colors.blue },
      StaticMethod = { "ﴂ ", colors.peach },
      Macro = { " ", colors.red },
    },
  })
end

config.cmp = function()
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
    else
      fallback()
    end
  end

  cmp.setup({
    window = {
      completion = {
        border = border("CmpBorder"),
        winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
      },
      documentation = {
        border = border("CmpDocBorder"),
      },
    },
    sorting = {
      comparators = {
        -- require("copilot_cmp.comparators").prioritize,
        -- require("copilot_cmp.comparators").score,
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
      format = lspkind.cmp_format({
        mode = "symbol_text",
        maxwidth = 50,
        ellipsis_char = "...",
        symbol_map = { Copilot = "" },
      }),
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
      -- { name = "copilot" },
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
      "deno",
      "eslint-lsp",
      "efm",
      "typescript-language-server",
      "dockerfile-language-server",
      "gopls",
      "rnix-lsp",
      "pyright",
      "jdtls",
      "bash-language-server",
      "lua-language-server",
      "stylua",
      "selene",
      "black",
      "isort",
      "yamllint",
      "clang-format",
      "buf",
      "pylint",
      "prettier",
      "shellcheck",
      "shfmt",
      "vint",
      "taplo",
      "vim-language-server",
      "tflint",
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
  vim.api.nvim_command([[packadd nvim-lspconfig]])
  vim.api.nvim_command([[packadd lsp_signature.nvim]])

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
      on_attach = function(client, bufnr)
        require("nvim-navic").attach(client, bufnr)
      end,
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
