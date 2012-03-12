include Makefile.in

.PHONY: compiler linker assembler simulator
MAKE_OPTION = 

# TODO
all: compiler linker assembler simulator dst/lib_asm.s dst/lib_ml.ml


compiler:
	cd compiler; make $(MAKE_OPTION)

linker:
	cd linker; make $(MAKE_OPTION)
	
assembler:
	cd assembler; make $(MAKE_OPTION)
	
simulator:
	cd simulator; make $(MAKE_OPTION)

# TODO
dst/lib_asm.s: lib_asm.s.tmpl ${notdir $(CONFIGFILE)} renderer.py
	python renderer.py ${notdir $(CONFIGFILE)} lib_asm.s.tmpl > dst/lib_asm.s

dst/lib_ml.ml: lib_ml.ml.tmpl ${notdir $(CONFIGFILE)} renderer.py
	python renderer.py ${notdir $(CONFIGFILE)} lib_ml.ml.tmpl > dst/lib_ml.ml

clean:
	cd compiler; make clean -k
	cd assembler; make clean -k
	cd simulator; make clean -k
	cd linker; make clean -k
	cd assembler; rm $(INCDIR)/*
	rm dst/lib_asm.s 
