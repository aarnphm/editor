local k = require "keybind"

return function()
	local icons = {
		kind = require("utils.icons").get "kind",
		type = require("utils.icons").get "type",
		cmp = require("utils.icons").get "cmp",
	}

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

	local has_words_before = function()
		if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
			return false
		end
		local line, col = unpack(vim.api.nvim_win_get_cursor(0))
		return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match "^%s*$" == nil
	end

	local check_backspace = function()
		local col = vim.fn.col "." - 1
		return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
	end

	local cmp_window = require "cmp.utils.window"

	cmp_window.info_ = cmp_window.info
	cmp_window.info = function(self)
		local info = self:info_()
		info.scrollable = false
		return info
	end
	vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#57fa85" })

	local compare = require "cmp.config.compare"
	compare.lsp_scores = function(entry1, entry2)
		local diff
		if entry1.completion_item.score and entry2.completion_item.score then
			diff = (entry2.completion_item.score * entry2.score) - (entry1.completion_item.score * entry1.score)
		else
			diff = entry2.score - entry1.score
		end
		return (diff < 0)
	end

	local lspkind = require "lspkind"
	local cmp = require "cmp"

	local tab_complete = function(fallback)
		if require("copilot.suggestion").is_visible() then
			require("copilot.suggestion").accept()
		elseif cmp.visible() and has_words_before() then
			cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
		elseif require("luasnip").expand_or_jumpable() then
			vim.fn.feedkeys(k.t "<Plug>luasnip-expand-or-jump", "")
		elseif check_backspace() then
			vim.fn.feedkeys(k.t "<Tab>", "n")
		else
			fallback()
		end
	end

	local s_tab_complete = function(fallback)
		if cmp.visible() then
			cmp.select_prev_item()
		elseif require("luasnip").jumpable(-1) then
			vim.fn.feedkeys(k.t "<Plug>luasnip-jump-prev", "")
		elseif has_words_before() then
			cmp.complete()
		else
			fallback()
		end
	end

	cmp.setup {
		preselect = cmp.PreselectMode.None,
		window = {
			completion = {
				border = border "Normal",
				max_width = 80,
				max_height = 20,
			},
			documentation = {
				border = border "CmpDocBorder",
			},
		},
		sorting = {
			priority_weight = 2,
			comparators = {
				compare.offset,
				compare.exact,
				compare.lsp_scores,
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
				local kind = lspkind.cmp_format {
					mode = "symbol_text",
					maxwidth = 50,
					symbol_map = vim.tbl_deep_extend("force", icons.kind, icons.type, icons.cmp),
				}(entry, vim_item)
				local strings = vim.split(kind.kind, "%s", { trimempty = true })
				kind.kind = " " .. strings[1] .. " "
				kind.menu = "    (" .. strings[2] .. ")"
				return kind
			end,
		},
		experimental = {
			ghost_text = {
				hl_group = "LspCodeLens",
			},
		},
		-- You can set mappings if you want
		mapping = cmp.mapping.preset.insert {
			["<CR>"] = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true },
			["<C-k>"] = cmp.mapping.select_prev_item(),
			["<C-j>"] = cmp.mapping.select_next_item(),
			["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
			["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
			["<C-e>"] = cmp.mapping.close(),
			["<Tab>"] = tab_complete,
			["<S-Tab>"] = s_tab_complete,
		},
		snippet = {
			expand = function(args) require("luasnip").lsp_expand(args.body) end,
		},
		-- You should specify your *installed* sources.
		sources = {
			{ name = "nvim_lsp" },
			{ name = "nvim_lua" },
			{ name = "luasnip" },
			{ name = "path" },
			{ name = "buffer" },
			{ name = "latex_symbols" },
			{ name = "emoji" },
		},
	}
end
