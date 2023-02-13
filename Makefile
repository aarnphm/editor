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
	@mv ${HOME}/.local/share/nvim/site/lazy/nvim-treesitter ${HOME}/.local/share/nvim/site
	@\rm -rf ${HOME}/.local/share/nvim/site/lazy ${HOME}/.cache/nvim ${HOME}/.local/state/nvim
	@mkdir -p ${HOME}/.local/share/nvim/site/lazy && mv ${HOME}/.local/share/nvim/site/nvim-treesitter ${HOME}/.local/share/nvim/site/lazy
	@nvim --headless "+Lazy! update" +qa
