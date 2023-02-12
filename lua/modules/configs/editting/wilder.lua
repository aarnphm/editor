return function()
	local wilder = require "wilder"
	wilder.setup { modes = { ":", "/", "?" } }
	wilder.set_option("use_python_remote_plugin", 0)
	wilder.set_option("pipeline", {
		wilder.branch(
			wilder.cmdline_pipeline {
				use_python = 0,
				fuzzy = 1,
				fuzzy_filter = wilder.lua_fzy_filter(),
			},
			wilder.vim_search_pipeline(),
			{
				wilder.check(function(_, x) return x == "" end),
				wilder.history(),
				wilder.result {
					draw = {
						function(_, x) return " " .. x end,
					},
				},
			}
		),
	})

	local popupmenu_renderer = wilder.popupmenu_renderer(wilder.popupmenu_border_theme {
		border = "rounded",
		empty_message = wilder.popupmenu_empty_message_with_spinner(),
		highlighter = wilder.lua_fzy_highlighter(),
		left = {
			" ",
			wilder.popupmenu_devicons(),
			wilder.popupmenu_buffer_flags {
				flags = " a + ",
				icons = { ["+"] = "", a = "", h = "" },
			},
		},
		right = {
			" ",
			wilder.popupmenu_scrollbar(),
		},
	})
	local wildmenu_renderer = wilder.wildmenu_renderer {
		highlighter = wilder.lua_fzy_highlighter(),
		apply_incsearch_fix = true,
		separator = " | ",
		left = { " ", wilder.wildmenu_spinner(), " " },
		right = { " ", wilder.wildmenu_index() },
	}
	wilder.set_option(
		"renderer",
		wilder.renderer_mux {
			[":"] = popupmenu_renderer,
			["/"] = wildmenu_renderer,
			substitute = wildmenu_renderer,
		}
	)
end
