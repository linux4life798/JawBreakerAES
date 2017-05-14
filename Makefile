.PHONY: all clean

#SOURCES=$(wildcard *.sv)
SOURCES=top2.sv AES.sv

all: simv

simv: $(SOURCES)
	vcs -sverilog -debug -top testbench2 -v2k_generate $^

clean:
	$(RM) simv
