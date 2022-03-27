USE_SH ?= false
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
local:
	@./fixtures/local
