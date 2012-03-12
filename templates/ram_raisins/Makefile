#all-sld: min-rt.bin
#	for name in ls sld/*.sld; do\
		echo $$name;\
		simulator/simulator min-rt.bin < $$name > $$name.ppm;\
	done

#allrun:
#	for name in ls ../../../compiler/test/*.s; do\
		echo $$name;\
		assembler/assembler $$name $$name.bin;\
		simulator/simulator $$name.bin;\
	done

min-rt.run: min-rt.bin
	simulator/simulator min-rt.bin < ../../../simulator/cache/sldbin/contest.sldbin > contest.ppm
	diff contest.ppm contest_t.ppm | wc -l
#	simulator/simulator min-rt.bin < sld/base.sld > base.ppm
#

min-rt.bin: min-rt.s
	assembler/assembler min-rt.s min-rt.bin

min-rt.s: lib_ml.ml lib_asm.s globals.ml min-rt.ml compiler/min-caml
	cat lib_ml.ml globals.ml min-rt.ml > tmp.ml
#	compiler/min-caml tmp
	compiler/min-caml -b --inline 250 tmp
	cd linker; java linker ../lib_asm.s ../tmp.s ../min-rt.s
	rm tmp.ml tmp.s


matmul.s: lib_ml.ml lib_asm.s globals.ml min-rt.ml compiler/min-caml
	cat lib_ml.ml matmul.ml > tmp.ml
	compiler/min-caml tmp
	cd linker; java linker ../lib_asm.s ../tmp.s ../matmul.s
	rm tmp.ml tmp.s

clean:
	rm min-rt.s min-rt.bin
