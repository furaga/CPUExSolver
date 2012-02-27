include ../Makefile.in
HEADER = $(ASMDIR)/common.h $(ASMDIR)/assembler.h

$(ASMDIR)/assembler: $(ASMDIR)/assembler.o $(ASMDIR)/encode.o
$(ASMDIR)/assembler.o: $(HEADER) $(ASMDIR)/encode.o
$(ASMDIR)/encode.o: $(HEADER)

$(ASMDIR)/assembler.cpp: assembler.cpp.tmpl $(CONFIGFILE) $(RENDERER)
$(ASMDIR)/assembler.h: assembler.h.tmpl  $(CONFIGFILE) $(RENDERER)
$(ASMDIR)/encode.cpp: encode.cpp.tmpl $(CONFIGFILE) $(RENDERER)
$(ASMDIR)/common.h: common.h.tmpl $(CONFIGFILE) $(RENDERER)

%.h:
	python $(RENDERER) $(CONFIGFILE) ${notdir $@}.tmpl > $@

%.cpp:
	python $(RENDERER) $(CONFIGFILE) ${notdir $@}.tmpl > $@

clean:
	rm $(ASMDIR)/*.cpp
	rm $(ASMDIR)/*.h
	rm $(ASMDIR)/*.o
	rm $(ASMDIR)/assembler
