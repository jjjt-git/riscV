GHDL := ghdl
RM := rm -rf

GHDLOPTS := --std=08

MODULES := $(wildcard *.vhdl)
OBJECTS := $(MODULES:.vhdl=.o)
DEPS := $(MODULES:.vhdl=.d)

TESTBENCHES := $(patsubst %.vhdl,%,$(wildcard tb_*.vhdl))
TB_RUN_TRGS := $(addprefix run_,$(TESTBENCHES))

MODULES_IMPORT_TRGS := $(addprefix import_,$(MODULES))

.PHONY: all run clear $(TB_RUN_TRGS) $(MODULES_IMPORT_TRGS)
all: $(OBJECTS)

run: $(TB_RUN_TRGS)
$(TB_RUN_TRGS): run_%: %
	./$* --wave=$*.ghw

clear:
	$(RM) $(subst .o,,$(OBJECTS)) *.o *.cf *.d *.ghw

$(OBJECTS): %.o: %.vhdl $(MODULES_IMPORT_TRGS)
	$(GHDL) -a $(GHDLOPTS) $<

$(TESTBENCHES): %: %.o
	$(GHDL) -m $(GHDLOPTS) $@

$(MODULES_IMPORT_TRGS): import_%: %
	$(GHDL) -i $(GHDLOPTS) $*