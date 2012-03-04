#all-sld: min-rt.bin
#	for name in ls sld/*.sld; do\
		echo $$name;\
		simulator/simulator min-rt.bin < $$name > $$name.ppm;\
	done

min-rt.run: min-rt.bin
	simulator/simulator min-rt.bin < sld/base.sld > base.ppm

min-rt.bin: min-rt.s
	assembler/assembler min-rt.s min-rt.bin

min-rt.s: globals.ml min-rt.ml compiler/min-caml
	cat lib_ml.ml globals.ml min-rt.ml > tmp.ml
	compiler/min-caml tmp
#	compiler/min-caml -b --inline 250 tmp
	cd linker; java linker ../lib_asm.s ../tmp.s ../min-rt.s
	rm tmp.ml tmp.s

clean:
	rm min-rt.s min-rt.bin
