return function()
  require("legendary").setup({
    which_key = {
      auto_register = true,
      do_binding = false,
    },
    scratchpad = {
      view = "float",
      results_view = "float",
      keep_contents = true,
    },
    sort = {
      -- sort most recently used item to the top
      most_recent_first = true,
      -- sort user-defined items before built-in items
      user_items_first = true,
      frecency = {
        -- the directory to store the database in
        db_root = string.format("%s/legendary/", vim.fn.stdpath("data")),
        -- the maximum number of timestamps for a single item
        -- to store in the database
        max_timestamps = 10,
      },
    },
    -- Directory used for caches
    cache_path = string.format("%s/legendary/", vim.fn.stdpath("cache")),
    -- Log level, one of 'trace', 'debug', 'info', 'warn', 'error', 'fatal'
    log_level = "info",
  })

  require("which-key").register({
    ["<Space>"] = {
      -- bufferline.nvim
      x = "buffer: Close current buffer",
      b = {
        name = "Bufferline commands",
        d = "buffer: Sort by directory",
        e = "buffer: Sort by extension",
        c = "buffer: Pick buffer to close",
        p = "buffer: Switch to pick buffer",
      },
      -- lazy.nvim
      p = {
        name = "Lazy commands",
        s = "Lazy: sync plugins",
        c = "Lazy: clean plugins",
        u = "Lazy: update plugins",
        cc = "Lazy: check for updates plugins",
        h = "Lazy: open home panel",
      },
      -- gitsigns.nvim
      h = { name = "Gitsigns commands" },
    },
    -- Lspsaga and nvim-lsp
    ["g"] = {
      a = "lsp: Code action",
      d = "lsp: Preview definition",
      D = "lsp: Goto definition",
      h = "lsp: Show reference",
      o = "lsp: Toggle outline",
      r = "lsp: Rename in file range",
      R = "lsp: Rename in project range",
      t = "lsp: Toggle trouble list",
      ["["] = "lsp: Goto prev diagnostic",
      ["]"] = "lsp: Goto next diagnostic",
      b = "buffer: Buffer pick",
    },
    K = "lsp: Show documentation",
    ["<LocalLeader>"] = {
      l = {
        name = "LSP commands",
        i = "lsp: LSP Info",
        r = "lsp: LSP Restart",
      },
      sc = "lsp: Show cursor disgnostics",
      sl = "lsp: Show line disgnostics",
      ci = "lsp: Incoming calls",
      co = "lsp: Outgoing calls",
      -- vim-fugitive
      G = "git: Show fugitive",
      g = {
        name = "git commands",
        aa = "git: Add .",
        cm = "git: Commit",
        p = {
          s = "git: Push",
          l = "git: Pull",
        },
      },
      -- copilot.lua
      cp = "copilot: Open panel",
      -- nvim-dap
      d = {
        name = "Dap commands",
        b = "debug: Set breakpoint with condition",
        c = "debug: Run to cursor",
        l = "debug: Run last",
        o = "debug: Open repl",
      },
      -- legendary.nvim
      ["<C-p>"] = "utils: Show keymap legends",
      -- octo.nvim
      oc = {
        name = "Octo commands",
        pr = "octo: Pull request",
      },
      -- trouble.nvim
      t = {
        name = "Trouble commands",
        d = "lsp: Show document diagnostics",
        w = "lsp: Show workspace diagnostics",
        q = "lsp: Show quickfix list",
        l = "lsp: Show loclist",
        r = "lsp: Show lsp references",
      },
      -- telescope.nvim
      f = {
        name = "Telescope commands",
        e = "find: File by history",
        c = "ui: Change color scheme",
        f = "find: File under current git directory",
        w = "find: Word with regex",
        u = "edit: Show undo history",
        z = "edit: Change current directory by zoxide",
        n = "edit: New file",
      },
      -- refactoring.nvim
      r = {
        name = "Refactoring commands",
        e = "refactor: Extract function",
        f = "refactor: Extract function to file",
        v = "refactor: Extract variable",
        i = "refactor: Inline variable",
        b = "refactor: Extract block",
        bf = "refactor: Extract block to file",
      },
      -- cheatsheet.nvim
      km = "cheatsheet: Show panel",
      -- hop.nvim
      w = "jump: Goto word",
      j = "jump: Goto line",
      k = "jump: Goto line",
      c = "jump: Goto one char",
      cc = "jump: Goto two char",
      -- general vim motion
      ["]"] = "windows: resize right 10px",
      ["["] = "windows: resize left 10px",
      ["-"] = "windows: resize up 5px",
      ["="] = "windows: resize down 5px",
      lcd = "edit: Change to current directory",
    },
    ["<Leader>"] = {
      o = "editor: set local for spell checker",
      I = "editor: set list",
      vs = "windows: Split vertical",
      hs = "windows: Split horizontal",
      p = "edit: remove last search words",
      i = "edit: indent current buffer",
      l = "editor: toggle list",
      t = "editor: remove trailing whitespaces",
      r = "tool: Code snip run",
      -- nvim-tree.lua
      n = {
        name = "NvimTree commands",
        f = "filetree: NvimTree find file",
        r = "filetree: NvimTree refresh",
      },
      -- nvim-spectre and nvim-treesitter
      s = {
        o = "replace: Open panel",
        w = "replace: Replace word under cursor",
        p = "replace: Replace word under file search",
        d = "jump: Goto outer function definition",
        D = "jump: Goto outer class definition",
      },
      -- crates.nvim
      c = {
        name = "Crates commands",
        t = "crates: toggle",
        r = "crates: reload",
        v = "crates: show versions popup",
        f = "crates: show features popup",
        d = "crates: show dependencies popup",
        u = "crates: update crates",
        a = "crates: update all crates",
        U = "crates: upgrade crates",
        A = "crates: upgrade all crates",
        H = "crates: show homepage",
        R = "crates: show repository",
        D = "crates: show documentation",
        C = "crates: open crates.io",
      },
    },
    ["<C-n>"] = "filetree: NvimTree open",
    f = {
      o = "find: Old files",
      r = "find: File by frecency",
      b = "find: Buffer opened",
      p = "find: Project",
      w = "find: Word",
      f = "find: File under current work directory",
      t = "buffer: Format toggle",
    },
    [";"] = "mode: enter command mode",
    ["<C-h>"] = "navigation: Move to left buffer",
    ["<C-l>"] = "navigation: Move to right buffer",
    ["<C-j>"] = "navigation: Move to down buffer",
    ["<C-k>"] = "navigation: Move to up buffer",
    ["<"] = "edit: outdent 1 step",
    [">"] = "edit: indent 1 step",
    ["\\"] = "edit: clean hightlight",
    Y = "edit: Yank to eol",
    D = "edit: Delete to eol",
    ["<C-s>"] = "edit: Save file",
    -- toggleterm.nvim
    ["<C-t>"] = "term: Create vertical terminal",
    ["<C-\\>"] = "term: Create horizontal terminal",
    -- zen-mode.nvim
    zm = "zenmode: Toggle",
    -- markdown-preview.nvim
    mpt = "markdown: preview",
    -- vim-easy-align
    gea = "easy-align: Align by char",
    slg = "git: Show lazygit",
    ["<F6>"] = "debug: Run/Continue",
    ["<F7>"] = "debug: Terminate debug session",
    ["<F8>"] = "debug: Toggle breakpoint",
    ["<F9>"] = "debug: Step into",
    ["<F10>"] = "debug: Step out",
    ["<F11>"] = "debug: Step over",
  })
end
