include ../Makefile.in

all: $(LNKDIR)/linker.class $(LNKDIR)/Makefile
	
$(LNKDIR)/linker.class: $(RENDERER) $(CONFIGFILE) linker.java.tmpl
	python $(RENDERER) $(CONFIGFILE) linker.java.tmpl > $(LNKDIR)/linker.java
	javac $(LNKDIR)/linker.java

$(LNKDIR)/Makefile: $(RENDERER) $(CONFIGFILE) Makefile.tmpl
	python $(RENDERER) $(CONFIGFILE) Makefile.tmpl > $@

clean:
	$(RM) $(LNKDIR)/*.class
	$(RM) $(LNKDIR)/*.java
	$(RM) $(LNKDIR)/Makefile
