include Makefile.in

.PHONY: compiler linker assembler simulator
MAKE_OPTION = 

all: $(DSTDIR_TOP)
#	make $(MAKE_OPTION) assembler
#	make $(MAKE_OPTION) simulator
#	make $(MAKE_OPTION) linker
	make $(MAKE_OPTION) compiler
#	make $(MAKE_OPTION) $(DSTDIR_TOP)/lib_asm.s_f
#	make $(MAKE_OPTION) $(DSTDIR_TOP)/lib_ml.ml_f
#	make $(MAKE_OPTION) $(DSTDIR_TOP)/Makefile_f
#	make $(MAKE_OPTION) $(DSTDIR_TOP)/Makefile.in_f

compiler: $(DSTDIR_TOP)
	cd compiler; make $(MAKE_OPTION)

linker: $(DSTDIR_TOP)
	cd linker; make $(MAKE_OPTION)
	
assembler: $(DSTDIR_TOP)
	cd assembler; make $(MAKE_OPTION)
	
simulator: $(DSTDIR_TOP)
	cd simulator; make $(MAKE_OPTION)

$(DSTDIR_TOP)/lib_asm.s_f: $(DSTDIR_TOP) lib_asm.s.tmpl ${notdir $(CONFIGFILE)} renderer.py
	python renderer.py ${notdir $(CONFIGFILE)} lib_asm.s.tmpl > $(DSTDIR_TOP)/lib_asm.s

$(DSTDIR_TOP)/lib_ml.ml_f: $(DSTDIR_TOP) lib_ml.ml.tmpl ${notdir $(CONFIGFILE)} renderer.py
	python renderer.py ${notdir $(CONFIGFILE)} lib_ml.ml.tmpl > $(DSTDIR_TOP)/lib_ml.ml

$(DSTDIR_TOP)/Makefile_f: $(DSTDIR_TOP) Makefile.tmpl
	cp Makefile.tmpl $(DSTDIR_TOP)/Makefile

$(DSTDIR_TOP)/Makefile.in_f: $(DSTDIR_TOP) Makefile.in.tmpl
	cp Makefile.in.tmpl $(DSTDIR_TOP)/Makefile.in

$(DSTDIR_TOP):
	mkdir $(DSTDIR_TOP)

clean:
	rm -rf $(DSTDIR_TOP)
