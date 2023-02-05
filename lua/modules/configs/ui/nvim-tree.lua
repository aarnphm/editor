return function()
  local icons = {
    diagnostics = require("utils.icons").get("diagnostics"),
    documents = require("utils.icons").get("documents"),
    git = require("utils.icons").get("git"),
    ui = require("utils.icons").get("ui"),
  }
  require("nvim-tree").setup({
    create_in_closed_folder = false,
    respect_buf_cwd = false, -- set to true if you want to open the tree relative to the current buffer's directory
    auto_reload_on_write = true,
    disable_netrw = false, -- set to true if you don't want to hijack netrw
    hijack_cursor = true,
    hijack_netrw = true,
    hijack_unnamed_buffer_when_opening = true,
    ignore_buffer_on_setup = false,
    open_on_setup = false,
    open_on_setup_file = false,
    open_on_tab = false,
    sort_by = "name", -- "name" | "extension" | "size" | "relative_path" | "modified" | "created" | "accessed"
    sync_root_with_cwd = true,
    view = {
      adaptive_size = false,
      centralize_selection = false,
      width = 30,
      side = "left",
      preserve_window_proportions = false,
      number = false,
      relativenumber = false,
      signcolumn = "yes",
      hide_root_folder = false,
      float = {
        enable = false,
        open_win_config = {
          relative = "editor",
          border = "rounded",
          width = 30,
          height = 30,
          row = 1,
          col = 1,
        },
      },
    },
    reload_on_bufenter = true,
    prefer_startup_root = true,
    renderer = {
      add_trailing = false,
      group_empty = true,
      highlight_git = false,
      full_name = false,
      highlight_opened_files = "none",
      special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md", "CMakeLists.txt" },
      symlink_destination = true,
      indent_markers = {
        enable = true,
        icons = {
          corner = "└ ",
          edge = "│ ",
          item = "│ ",
          none = "  ",
        },
      },
      root_folder_label = ":.:s?.*?/..?",
      root_folder_modifier = ":e",
      icons = {
        webdev_colors = true,
        git_placement = "before",
        show = {
          file = true,
          folder = true,
          folder_arrow = false,
          git = true,
        },
        padding = " ",
        symlink_arrow = "  ",
        glyphs = {
          default = icons.documents.Default, --
          symlink = icons.documents.Symlink, --
          bookmark = icons.ui.Bookmark,
          git = {
            unstaged = icons.git.Mod_alt,
            staged = icons.git.Add, --
            unmerged = icons.git.Unmerged,
            renamed = icons.git.Rename, --
            untracked = icons.git.Untracked, -- "ﲉ"
            deleted = icons.git.Remove, --
            ignored = icons.git.Ignore, --◌
          },
          folder = {
            -- arrow_open = "",
            -- arrow_closed = "",
            arrow_open = "",
            arrow_closed = "",
            default = icons.ui.Folder,
            open = icons.ui.FolderOpen,
            empty = icons.ui.EmptyFolder,
            empty_open = icons.ui.EmptyFolderOpen,
            symlink = icons.ui.SymlinkFolder,
            symlink_open = icons.ui.FolderOpen,
          },
        },
      },
    },
    hijack_directories = { enable = true, auto_open = true },
    update_focused_file = {
      enable = true,
      update_root = true,
      ignore_list = {},
    },
    system_open = { cmd = "open", args = {} },
    filters = { dotfiles = false, custom = { "^.git$", ".DS_Store", "__pycache__", "*/lazy-lock.json" } },
    git = { timeout = 500, ignore = false },
    diagnostics = {
      enable = false,
      show_on_dirs = false,
      debounce_delay = 50,
      icons = {
        hint = icons.diagnostics.Hint_alt,
        info = icons.diagnostics.Information_alt,
        warning = icons.diagnostics.Warning_alt,
        error = icons.diagnostics.Error_alt,
      },
    },
    trash = { cmd = require("utils").get_binary_path("rip"), require_confirm = true },
    filesystem_watchers = { enable = true, debounce_delay = 50 },
    actions = {
      open_file = {
        resize_window = false,
        window_picker = {
          enable = true,
          chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
          exclude = {
            filetype = { "notify", "qf", "diff", "fugitive", "fugitiveblame", "alpha", "Trouble" },
            buftype = { "nofile", "terminal", "help" },
          },
        },
      },
    },
  })
end