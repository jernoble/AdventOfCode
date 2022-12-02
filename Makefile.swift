CWD = $(shell pwd)
DAY = $(notdir $(CWD))
YEAR = $(notdir $(patsubst %/,%, $(dir $(CWD))))
BUILDDIR = ../../build/$(YEAR)/$(DAY)/

SRC = $(wildcard *.swift)
BIN = $(patsubst %.swift,$(BUILDDIR)%,$(SRC))
ALL : $(BUILDDIR) $(BIN) output

$(BUILDDIR) :
	mkdir -p $(BUILDDIR)

$(BUILDDIR)% : %.swift
	swiftc -o $@ $^

output : $(BIN) input.txt
	for binary in $(BIN); do \
		echo Running "$$binary"; \
		./$$binary < input.txt; \
	done