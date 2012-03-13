include ../Makefile.in

HEADER = $(INCDIR)/common.h $(ASMDIR)/assembler.h

all:$(INCDIR) $(ASMDIR) $(ASMDIR)/assembler $(ASMDIR)/Makefile

$(ASMDIR)/assembler:$(ASMDIR)/assembler.o $(ASMDIR)/encode.o
$(ASMDIR)/assembler.o:$(HEADER) $(ASMDIR)/encode.o
$(ASMDIR)/encode.o:$(HEADER)

$(ASMDIR)/assembler.cpp:assembler.cpp.tmpl $(CONFIGFILE) $(RENDERER)
$(ASMDIR)/assembler.h:assembler.h.tmpl  $(CONFIGFILE) $(RENDERER)
$(ASMDIR)/encode.cpp:encode.cpp.tmpl $(CONFIGFILE) $(RENDERER)
$(INCDIR)/common.h:common.h.tmpl $(CONFIGFILE) $(RENDERER)

$(INCDIR)/%.h:$(INCDIR) $(RENDERER) $(CONFIGFILE)
	python $(RENDERER) $(CONFIGFILE) ${notdir $@}.tmpl > $@

$(ASMDIR)/%.h:$(ASMDIR) $(RENDERER) $(CONFIGFILE)
	python $(RENDERER) $(CONFIGFILE) ${notdir $@}.tmpl > $@

$(ASMDIR)/%.cpp:$(ASMDIR) $(RENDERER) $(CONFIGFILE)
	python $(RENDERER) $(CONFIGFILE) ${notdir $@}.tmpl > $@

$(ASMDIR)/Makefile:$(ASMDIR) Makefile.tmpl $(CONFIGFILE) $(RENDERER)
	python $(RENDERER) $(CONFIGFILE) ${notdir $@}.tmpl > $@

$(ASMDIR):
	mkdir $(ASMDIR)

$(INCDIR):
	mkdir $(INCDIR)

clean:
	rm -rf $(ASMDIR)
	rm -rf $(INCDIR)
