include Makefile.in

.PHONY: compiler linker assembler simulator
MAKE_OPTION = 

# TODO
all: compiler linker assembler simulator dst/lib_asm.s

compiler:
	cd compiler; make $(MAKE_OPTION)

linker:
	cd linker; make $(MAKE_OPTION)
	
assembler:
	cd assembler; make $(MAKE_OPTION)
	
simulator:
	cd simulator; make $(MAKE_OPTION)

# TODO
dst/lib_asm.s: lib_asm.s.tmpl architecture.xml renderer.py
	python renderer.py architecture.xml lib_asm.s.tmpl > dst/lib_asm.s

clean:
	cd compiler; make clean
	cd assembler; make clean
	cd assembler; rm $(INCDIR)/*
