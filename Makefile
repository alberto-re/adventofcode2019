LUACHECKBIN=/usr/bin/luacheck
LUACHECKOPTS=--std lua53

all: lint

lint:
	$(LUACHECKBIN) $(LUACHECKOPTS) day* common.lua
