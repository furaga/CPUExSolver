include ../Makefile.in

all:$(LNKDIR) $(LNKDIR)/linker.class $(LNKDIR)/Makefile
	
$(LNKDIR)/linker.class:$(LNKDIR) $(RENDERER) $(CONFIGFILE) linker.java.tmpl
	python $(RENDERER) $(CONFIGFILE) linker.java.tmpl > $(LNKDIR)/linker.java
	javac $(LNKDIR)/linker.java

$(LNKDIR)/Makefile:$(LNKDIR) $(RENDERER) $(CONFIGFILE) Makefile.tmpl
	python $(RENDERER) $(CONFIGFILE) Makefile.tmpl > $@

$(LNKDIR):
	mkdir $(LNKDIR)
	
clean:
	rm -rf $(LNKDIR)
