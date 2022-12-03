CWD = $(shell pwd)
DAY = $(notdir $(CWD))
YEAR = $(notdir $(patsubst %/,%, $(dir $(CWD))))
BUILDDIR = ../../build/$(YEAR)/$(DAY)/

SRC = $(wildcard *.swift)
BIN = $(patsubst %.swift,$(BUILDDIR)%,$(SRC))
OUTPUTS = $(patsubst %.swift,output.%,$(SRC))
ALL : $(BUILDDIR) $(BIN) $(OUTPUTS)

$(BUILDDIR) :
	mkdir -p $(BUILDDIR)

$(BUILDDIR)% : %.swift
	swiftc -o $@ $^

output.% : $(BUILDDIR)%
	$^ < input.txt
