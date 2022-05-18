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
	@\rm -rf ${HOME}/.local/share/nvim ${HOME}/.cache/nvim
	@\rm -rf ./plugin
	nvim -c "autocmd User PackerComplete quitall" -c "PackerSync"
	nvim
