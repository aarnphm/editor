USE_SH ?= false

install:
	@go install github.com/rhysd/vim-startuptime@latest
fmt:
	@stylua lua
lint:
	@selene lua
ifeq ($(USE_SH),true)
benchmark:
	@./fixtures/benchmark.sh && cat ./fixtures/benchmark.txt
else
benchmark:
	@./fixtures/benchmark.pl
endif
benchmark-local:
	@vim-startuptime --vimpath nvim | sort -k 2
reset:
	@mv ${HOME}/.local/share/nvim/lazy/nvim-treesitter ${HOME}/.local/share/nvim/
	@\rm -rf ${HOME}/.local/share/nvim/lazy ${HOME}/.cache/nvim ${HOME}/.local/state/nvim
	@mkdir -p ${HOME}/.local/share/nvim/lazy && mv ${HOME}/.local/share/nvim/nvim-treesitter ${HOME}/.local/share/nvim/lazy
	@nvim --headless "+Lazy! update" +qa
