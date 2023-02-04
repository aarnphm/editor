return function()
  require("nvim-tree").setup({
    disable_netrw = true,
    hijack_cursor = true,
    sort_by = "extensions",
    reload_on_bufenter = true,
    prefer_startup_root = true,
    respect_buf_cwd = true,
    view = {
      adaptive_size = false,
      width = 16,
      side = "right",
    },
    renderer = {
      root_folder_modifier = ":e",
      icons = {
        padding = " ",
        symlink_arrow = "  ",
        glyphs = {
          ["default"] = "", --
          ["symlink"] = "",
          ["git"] = {
            ["unstaged"] = "",
            ["staged"] = "", --
            ["unmerged"] = "שׂ",
            ["renamed"] = "", --
            ["untracked"] = "ﲉ",
            ["deleted"] = "",
            ["ignored"] = "", --◌
          },
          ["folder"] = {
            ["arrow_open"] = "",
            ["arrow_closed"] = "",
            ["default"] = "",
            ["open"] = "",
            ["empty"] = "",
            ["empty_open"] = "",
            ["symlink"] = "",
            ["symlink_open"] = "",
          },
        },
      },
      indent_markers = {
        enable = true,
        icons = {
          corner = "└ ",
          edge = "│ ",
          none = "  ",
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
    filters = { dotfiles = false, custom = { "^.git$", ".DS_Store", "__pycache__", "*/packer_compiled.lua" } },
    git = { timeout = 500, ignore = false },
    trash = { cmd = "rip", require_confirm = true },
    filesystem_watchers = {
      enable = true,
      debounce_delay = 50,
    },
    actions = {
      open_file = {
        resize_window = false,
        window_picker = {
          enable = true,
          chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
          exclude = {
            filetype = { "notify", "qf", "diff", "fugitive", "fugitiveblame" },
            buftype = { "nofile", "terminal", "help" },
          },
        },
      },
    },
  })
end
