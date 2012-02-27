include ../Makefile.in
HEADER = $(ASMDIR)/common.h simulator.h

simulator: simulator.o
simulator.o: $(HEADER)

simulator.cpp: simulator.cpp.tmpl $(CONFIGFILE) $(RENDERER)
simulator.h: simulator.h.tmpl $(CONFIGFILE) $(RENDERER)

%.h:
	python $(RENDERER) $(CONFIGFILE) $@.tmpl > $@

%.cpp:
	python $(RENDERER) $(CONFIGFILE) $@.tmpl > $@

clean:
	rm *.cpp
	rm *.h
	rm *.o
	rm simulator
