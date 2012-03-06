include ../Makefile.in

DEPEND = $(RENDERER) $(CONFIGFILE)

TEMPLATES = Makefile.tmpl OCamlMakefile.tmpl\
float.c.tmpl global.ml.tmpl type.ml.tmpl id.ml.tmpl m.ml.tmpl\
s.ml.tmpl time.ml.tmpl syntax.ml.tmpl parser.mly.tmpl lexer.mll.tmpl\
typing.ml.tmpl kNormal.ml.tmpl alpha.ml.tmpl beta.ml.tmpl betaTuple.ml.tmpl\
assoc.ml.tmpl inline.ml.tmpl elim.ml.tmpl constArray.ml.tmpl cse.ml.tmpl\
constFold.ml.tmpl globalEnv.ml.tmpl closure.ml.tmpl asm.ml.tmpl virtual.ml.tmpl\
sglobal.ml.tmpl simm.ml.tmpl block.ml.tmpl liveness.ml.tmpl coloring.ml.tmpl\
toAsm.ml.tmpl regAlloc.ml.tmpl regAllocWithColoring.ml.tmpl output.ml.tmpl emit.ml.tmpl\
main.ml.tmpl

SOURCES = $(TEMPLATES:%.tmpl=$(COMDIR)/%)

all: $(SOURCES)
	cd $(COMDIR); make

$(COMDIR)/%akefile:
	cp ${notdir $@}.tmpl $@

$(COMDIR)/%.ml:
	python $(RENDERER) $(CONFIGFILE) ${notdir $@}.tmpl > $@

$(COMDIR)/%.mll:
	python $(RENDERER) $(CONFIGFILE) ${notdir $@}.tmpl > $@

$(COMDIR)/%.mly:
	python $(RENDERER) $(CONFIGFILE) ${notdir $@}.tmpl > $@

$(COMDIR)/%.c:
	python $(RENDERER) $(CONFIGFILE) ${notdir $@}.tmpl > $@

$(COMDIR)/OCamlMakefile: OCamlMakefile.tmpl $(DEPEND)
$(COMDIR)/Makefile: Makefile.tmpl $(DEPEND)
$(COMDIR)/README.txt: README.txt.tmpl $(DEPEND)
$(COMDIR)/alpha.ml: alpha.ml.tmpl $(DEPEND)
$(COMDIR)/output.ml: output.ml.tmpl $(DEPEND)
$(COMDIR)/emit.ml: emit.ml.tmpl $(DEPEND)
$(COMDIR)/asm.ml: asm.ml.tmpl $(DEPEND)
$(COMDIR)/virtual.ml: virtual.ml.tmpl $(DEPEND)
$(COMDIR)/simm.ml: simm.ml.tmpl $(DEPEND)
$(COMDIR)/block.ml: block.ml.tmpl $(DEPEND)
$(COMDIR)/toAsm.ml: toAsm.ml.tmpl $(DEPEND)
$(COMDIR)/coloring.ml: coloring.ml.tmpl $(DEPEND)
$(COMDIR)/regAllocWithColoring.ml: regAllocWithColoring.ml.tmpl $(DEPEND)
$(COMDIR)/regAlloc.ml: regAlloc.ml.tmpl $(DEPEND)
$(COMDIR)/main.ml: main.ml.tmpl $(DEPEND)
$(COMDIR)/sglobal.ml: sglobal.ml.tmpl $(DEPEND)
$(COMDIR)/float.c: float.c.tmpl $(DEPEND)
$(COMDIR)/globalEnv.ml: globalEnv.ml.tmpl $(DEPEND)
$(COMDIR)/parser.mly: parser.mly.tmpl $(DEPEND)


clean:
	rm $(COMDIR)/*
