include ../Makefile.in
HEADER = $(INCDIR)/common.h

all: $(SIMDIR)/simulator $(SIMDIR)/Makefile

$(SIMDIR)/simulator:$(SIMDIR)/simulator.o
$(SIMDIR)/simulator.o:$(HEADER)
$(SIMDIR)/simulator.cpp:simulator.cpp.tmpl $(CONFIGFILE) $(RENDERER)
$(SIMDIR)/Makefile:Makefile.tmpl $(CONFIGFILE) $(RENDERER)

$(SIMDIR)/%.cpp:$(SIMDIR) $(RENDERER) $(CONFIGFILE)
	python $(RENDERER) $(CONFIGFILE) ${notdir $@}.tmpl > $@

$(SIMDIR)/Makefile:$(SIMDIR) $(RENDERER) $(CONFIGFILE)
	python $(RENDERER) $(CONFIGFILE) ${notdir $@}.tmpl > $@

$(SIMDIR):
	mkdir $(SIMDIR)

clean:
	rm -rf $(SIMDIR)
