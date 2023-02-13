return function()
	local icons = {
		diagnostics = require("icons").get "diagnostics",
		documents = require("icons").get "documents",
		git = require("icons").get "git",
		ui = require("icons").get "ui",
	}

	require("nvim-tree").setup {
		hijack_cursor = true,
		hijack_unnamed_buffer_when_opening = true,
		reload_on_bufenter = true,
		sync_root_with_cwd = true,
		view = { adaptive_size = false, side = "right" },
		renderer = {
			group_empty = true,
			highlight_opened_files = "none",
			special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md", "CMakeLists.txt" },
			indent_markers = { enable = true },
			root_folder_label = ":.:s?.*?/..?",
			root_folder_modifier = ":e",
			icons = {
				symlink_arrow = "  ",
				glyphs = {
					default = icons.documents.Default, --
					symlink = icons.documents.Symlink, --
					bookmark = icons.ui.Bookmark,
					git = {
						unstaged = icons.git.ModHolo,
						staged = icons.git.Add, --
						unmerged = icons.git.Unmerged,
						renamed = icons.git.Rename, --
						untracked = icons.git.Untracked, -- "ﲉ"
						deleted = icons.git.Remove, --
						ignored = icons.git.Ignore, --◌
					},
					folder = {
						arrow_open = icons.ui.ArrowOpen,
						arrow_closed = icons.ui.ArrowClosed,
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
		update_focused_file = { enable = true, update_root = true },
		system_open = { cmd = require("editor").global.is_mac and "open" or "xdg-open" },
		filters = { custom = { "^.git$", ".DS_Store", "__pycache__", "lazy-lock.json" } },
		actions = {
			open_file = {
				resize_window = false,
				window_picker = {
					exclude = {
						filetype = { "notify", "qf", "diff", "fugitive", "fugitiveblame", "alpha", "Trouble" },
						buftype = { "nofile", "terminal", "help" },
					},
				},
			},
		},
		git = {
			enable = true,
			show_on_dirs = true,
			timeout = 500,
			ignore = require("editor").config.plugins.nvim_tree.git.ignore,
		},
		trash = {
			cmd = require("utils").get_binary_path "rip",
			require_confirm = true,
		},
	}
end
