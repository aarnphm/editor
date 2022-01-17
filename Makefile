USE_SH ?= false

install:
	@go install github.com/rhysd/vim-startuptime@latest
fmt:
	@stylua lua
lint:
	@selene lua
reset:
	@\rm -rf ${HOME}/.local/share/nvim/lazy ${HOME}/.cache/nvim ${HOME}/.local/state/nvim
	nvim --headless "+Lazy! sync" +qa
	nvim --headless -c 'lua require("nvim-treesitter.install").update({ with_sync = true }); vim.cmd("quitall")'
