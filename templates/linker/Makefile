LINKER = linker
RENDERER = ../renderer.py
CONFIGFILE = ../architecture.xml

# デフォルトではテスト用のファイルが使われる 
SOURCES = ../tmp/inputs/lib_asm.s ../tmp/inputs/__temp__.s
#SOURCES = ../tmp/inputs/lib_asm_noheap.s ../tmp/inputs/lib_asm_noheap.s
DEST = ../tmp/outputs/result.s

all: linker.class
	java $(LINKER) $(SOURCES) $(DEST)
	
$(LINKER).class: $(CONFIGFILE) $(LINKER).java.tmpl
	python $(RENDERER) $(CONFIGFILE) $(LINKER).java.tmpl > $(LINKER).java
	javac $(LINKER).java

clean:
	rm *.class
	rm *.java
