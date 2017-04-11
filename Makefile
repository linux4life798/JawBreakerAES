.PHONY: all clean

SOURCES=$(wildcard *.sv)

all: simv

simv: $(SOURCES)
	vcs -sverilog -debug -v2k_generate $^

clean:
	$(RM) simv