local config = {}
local sessions_dir = vim.fn.stdpath("data") .. "/sessions/"

function config.vim_cursorword()
  vim.api.nvim_command("augroup user_plugin_cursorword")
  vim.api.nvim_command("autocmd!")
  vim.api.nvim_command("autocmd FileType NvimTree,lspsagafinder,dashboard let b:cursorword = 0")
  vim.api.nvim_command("autocmd WinEnter * if &diff || &pvw | let b:cursorword = 0 | endif")
  vim.api.nvim_command("autocmd InsertEnter * let b:cursorword = 0")
  vim.api.nvim_command("autocmd InsertLeave * let b:cursorword = 1")
  vim.api.nvim_command("augroup END")
end

function config.auto_session()
  local opts = {
    log_level = "info",
    auto_session_enable_last_session = true,
    auto_session_root_dir = sessions_dir,
    auto_session_enabled = true,
    auto_save_enabled = true,
    auto_restore_enabled = true,
    auto_session_suppress_dirs = nil,
  }

  require("auto-session").setup(opts)
end
function config.tabout()
  require("tabout").setup({
    tabkey = "<A-l>",
    backwards_tabkey = "<A-h>",
    ignore_beginning = false,
    act_as_tab = true,
    enable_backward = true,
    completion = true,
    tabouts = {
      { open = "'", close = "'" },
      { open = '"', close = '"' },
      { open = "`", close = "`" },
      { open = "(", close = ")" },
      { open = "[", close = "]" },
      { open = "{", close = "}" },
    },
    exclude = {},
  })
end

function config.symbols_outline()
  require("symbols-outline").setup({
    highlight_hovered_item = true,
    width = 60,
    show_guides = true,
    auto_preview = true,
    position = "right",
    show_numbers = true,
    show_relative_numbers = true,
    show_symbol_details = true,
    preview_bg_highlight = "Pmenu",
    keymaps = {
      close = "<Esc>",
      goto_location = "<Cr>",
      focus_location = "o",
      hover_symbol = "<C-space>",
      rename_symbol = "r",
      code_actions = "a",
    },
    lsp_blacklist = {},
    symbols = {
      File = { icon = "", hl = "TSURI" },
      Module = { icon = "", hl = "TSNamespace" },
      Namespace = { icon = "", hl = "TSNamespace" },
      Package = { icon = "", hl = "TSNamespace" },
      Class = { icon = "𝓒", hl = "TSType" },
      Method = { icon = "ƒ", hl = "TSMethod" },
      Property = { icon = "", hl = "TSMethod" },
      Field = { icon = "", hl = "TSField" },
      Constructor = { icon = "", hl = "TSConstructor" },
      Enum = { icon = "ℰ", hl = "TSType" },
      Interface = { icon = "ﰮ", hl = "TSType" },
      Function = { icon = "", hl = "TSFunction" },
      Variable = { icon = "", hl = "TSConstant" },
      Constant = { icon = "", hl = "TSConstant" },
      String = { icon = "𝓐", hl = "TSString" },
      Number = { icon = "#", hl = "TSNumber" },
      Boolean = { icon = "⊨", hl = "TSBoolean" },
      Array = { icon = "", hl = "TSConstant" },
      Object = { icon = "⦿", hl = "TSType" },
      Key = { icon = "🔐", hl = "TSType" },
      Null = { icon = "NULL", hl = "TSType" },
      EnumMember = { icon = "", hl = "TSField" },
      Struct = { icon = "𝓢", hl = "TSType" },
      Event = { icon = "🗲", hl = "TSType" },
      Operator = { icon = "+", hl = "TSOperator" },
      TypeParameter = { icon = "𝙏", hl = "TSParameter" },
    },
  })
end

function config.nvim_treesitter()
  vim.cmd([[set foldmethod=expr]])
  vim.cmd([[set foldexpr=nvim_treesitter#foldexpr()]])

  require("nvim-treesitter.configs").setup({
    ensure_installed = "maintained",
    sync_install = false,
    incremental_selection = {
      enable = true,
      keymaps = {
        -- mappings for incremental selection (visual mappings)
        init_selection = "gnn", -- maps in normal mode to init the node/scope selection
        node_incremental = "grn", -- increment to the upper named parent
        scope_incremental = "grc", -- increment to the upper scope (as defined in locals.scm)
        node_decremental = "grm", -- decrement to the previous node
      },
    },
    highlight = { enable = true },
    rainbow = {
      enable = true,
      extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
      max_file_lines = 1000, -- Do not enable for files with more than 1000 lines, int
    },
    context_commentstring = { enable = false, enable_autocmd = false },
    matchup = { enable = true },
    context = { enable = true, throttle = true },
    textobjects = {
      enable = true,
      lsp_interop = {
        enable = true,
        peek_definition_code = {
          ["Df"] = "@function.outer",
          ["Dc"] = "@class.outer",
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ["<leader>a"] = "@parameter.inner",
        },
        swap_previous = {
          ["<leader>A"] = "@parameter.inner",
        },
      },
      select = {
        enable = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          ["iF"] = {
            python = "(function_definition) @function",
            cpp = "(function_definition) @function",
            c = "(function_definition) @function",
            java = "(method_declaration) @function",
            go = "(method_declaration) @function",
          },
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = "@class.outer",
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["]["] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.outer",
        },
      },
    },
  })
end

function config.autotag()
  require("nvim-ts-autotag").setup({
    filetypes = {
      "html",
      "xml",
      "javascript",
      "typescriptreact",
      "javascriptreact",
      "vue",
    },
  })
end

function config.matchup()
  vim.cmd([[let g:matchup_matchparen_offscreen = {'method': 'popup'}]])
end

function config.toggleterm()
  require("toggleterm").setup({
    -- size can be a number or function which is passed the current terminal
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.40
      end
    end,
    open_mapping = [[<c-\>]],
    hide_numbers = true, -- hide the number column in toggleterm buffers
    shade_filetypes = {},
    shade_terminals = false,
    shading_factor = "1", -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
    start_in_insert = true,
    insert_mappings = true, -- whether or not the open mapping applies in insert mode
    persist_size = true,
    direction = "horizontal",
    close_on_exit = true, -- close the terminal window when the process exits
    shell = vim.o.shell, -- change the default shell
  })
end

function config.nvim_colorizer()
  require("colorizer").setup()
end

return config
