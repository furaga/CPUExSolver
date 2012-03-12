
#----------------------------------------------------------------------
#
# lib_asm.s
#
#----------------------------------------------------------------------

# * create_array
min_caml_create_array:
	add $r5, $r3, $r29
	mov $r3, $r29
CREATE_ARRAY_LOOP:
	blt  $r29, $r5, CREATE_ARRAY_CONTINUE
	jr $r31
CREATE_ARRAY_CONTINUE:
	store $r4, $r29, 0	
	addi $r29, $r29, 1	
	j CREATE_ARRAY_LOOP

# * create_float_array
min_caml_create_float_array:
	add $r4, $r3, $r29
	mov $r3, $r29
CREATE_FLOAT_ARRAY_LOOP:
	blt $r29, $r4, CREATE_FLOAT_ARRAY_CONTINUE
	jr $r31
CREATE_FLOAT_ARRAY_CONTINUE:
	fmovi $r27, $f0
	store $r27, $r29, 0
	addi $r29, $r29, 1
	j CREATE_FLOAT_ARRAY_LOOP

# * floor		$f0 + MAGICF - MAGICF
min_caml_floor:
	fmov $f1, $f0
	# $f4 <- 0.0
	# fset $f4, 0.0
	flui $f4, 0
	flli $f4, 0
	fblt $f0, $f4, FLOOR_NEGATIVE	# if ($f4 <= $f0) goto FLOOR_PISITIVE
FLOOR_POSITIVE:
	# $f2 <- 8388608.0(0x4b000000)
	flui $f2, 19200
	flli $f2, 0
	fblt $f2, $f0, FLOOR_POSITIVE_RET
FLOOR_POSITIVE_MAIN:
	fmov $f1, $f0
	fadd $f0, $f0, $f2
	fmovi $r27, $f0
	store $r27, $r30, 0
	load $r4, $r30, 0
	fsub $f0, $f0, $f2
	fmovi $r27, $f0
	store $r27, $r30, 0
	load $r4, $r30, 0
	fblt $f1, $f0, FLOOR_POSITIVE_RET
	jr $r31
FLOOR_POSITIVE_RET:
	# $f3 <- 1.0
	# fset $f3, 1.0
	flui $f3, 16256
	flli $f3, 0
	fsub $f0, $f0, $f3
	jr $r31
FLOOR_NEGATIVE:
	fneg $f0, $f0
	# $f2 <- 8388608.0(0x4b000000)
	flui $f2, 19200
	flli $f2, 0
	fblt $f2, $f0, FLOOR_NEGATIVE_RET
FLOOR_NEGATIVE_MAIN:
	fadd $f0, $f0, $f2
	fsub $f0, $f0, $f2
	fneg $f1, $f1
	fblt $f0, $f1, FLOOR_NEGATIVE_PRE_RET
	j FLOOR_NEGATIVE_RET
FLOOR_NEGATIVE_PRE_RET:
	fadd $f0, $f0, $f2
	# $f3 <- 1.0
	# fset $f3, 1.0
	flui $f3, 16256
	flli $f3, 0
	fadd $f0, $f0, $f3
	fsub $f0, $f0, $f2
FLOOR_NEGATIVE_RET:
	fneg $f0, $f0
	jr $r31
	
min_caml_ceil:
	fneg $f0, $f0
	store $r31, $r30, 0
	addi $r30, $r30, -1
	jal min_caml_floor
	addi $r30, $r30, 1
	load $r31, $r30, 0
	fneg $f0, $f0
	jr $r31

# * float_of_int
min_caml_float_of_int:
	blt $r3, $r0, ITOF_NEGATIVE_MAIN		# if ($r0 <= $r3) goto ITOF_MAIN
ITOF_MAIN:
	# $f1 <- 8388608.0(0x4b000000)
	flui $f1, 19200
	flli $f1, 0
	# $r4 <- 0x4b000000
	lui $r4, 19200
	lli $r4, 0
	# $r5 <- 0x00800000
	lui $r5, 128
	lli $r5, 0
	blt $r3, $r5, ITOF_SMALL
ITOF_BIG:
	# $f2 <- 0.0
	# fset $f2, 0.0
	flui $f2, 0
	flli $f2, 0
ITOF_LOOP:
	sub $r3, $r3, $r5
	fadd $f2, $f2, $f1
	blt $r3, $r5, ITOF_RET
	j ITOF_LOOP
ITOF_RET:
	add $r3, $r3, $r4
	store $r3, $r30, 0
	load $r27, $r30, 0
	imovf $f0, $r27
	fsub $f0, $f0, $f1
	fadd $f0, $f0, $f2
	jr $r31
ITOF_SMALL:
	add $r3, $r3, $r4
	store $r3, $r30, 0
	load $r27, $r30, 0
	imovf $f0, $r27
	fsub $f0, $f0, $f1
	jr $r31
ITOF_NEGATIVE_MAIN:
	sub $r3, $r0, $r3
	store $r31, $r30, 0
	addi $r30, $r30, -1
	jal ITOF_MAIN
	addi $r30, $r30, 1
	load $r31, $r30, 0
	fneg $f0, $f0
	jr $r31

# * int_of_float
min_caml_int_of_float:
	# $f1 <- 0.0
	# fset $f1, 0.0
	flui $f1, 0
	flli $f1, 0
	fblt $f0, $f1, FTOI_NEGATIVE_MAIN			# if (0.0 <= $f0) goto FTOI_MAIN
FTOI_POSITIVE_MAIN:
	store $r31, $r30, 0
	addi $r30, $r30, -1
	jal min_caml_floor
	addi $r30, $r30, 1
	load $r31, $r30, 0
	# $f2 <- 8388608.0(0x4b000000)
	flui $f2, 19200
	flli $f2, 0
	# $r4 <- 0x4b000000
	lui $r4, 19200
	lli $r4, 0
	fblt $f0, $f2, FTOI_SMALL		# if (MAGICF <= $f0) goto FTOI_BIG
	# $r5 <- 0x00800000
	lui $r5, 128
	lli $r5, 0
	mov $r3, $r0
FTOI_LOOP:
	fsub $f0, $f0, $f2
	add $r3, $r3, $r5
	fblt $f0, $f2, FTOI_RET
	j FTOI_LOOP
FTOI_RET:
	fadd $f0, $f0, $f2
	fmovi $r27, $f0
	store $r27, $r30, 0
	load $r5, $r30, 0
	sub $r5, $r5, $r4
	add $r3, $r5, $r3
	jr $r31
FTOI_SMALL:
	fadd $f0, $f0, $f2
	fmovi $r27, $f0
	store $r27, $r30, 0
	load $r3, $r30, 0
	sub $r3, $r3, $r4
	jr $r31
FTOI_NEGATIVE_MAIN:
	fneg $f0, $f0
	store $r31, $r30, 0
	addi $r30, $r30, -1
	jal FTOI_POSITIVE_MAIN
	addi $r30, $r30, 1
	load $r31, $r30, 0
	sub $r3, $r0, $r3
	jr $r31
	
# * truncate
min_caml_truncate:
	j min_caml_int_of_float
	
# ビッグエンディアン
min_caml_read_int:
	add $r3, $r0, $r0
	# 24 - 31
	iold $r4
	add $r3, $r3, $r4
	slli $r3, $r3, 8
	# 16 - 23
	iold $r4
	add $r3, $r3, $r4
	slli $r3, $r3, 8
	# 8 - 15
	iold $r4
	add $r3, $r3, $r4
	slli $r3, $r3, 8
	# 0 - 7
	iold $r4
	add $r3, $r3, $r4
	jr $r31

min_caml_read_float:
	store $r31, $r30, 0
	addi $r30, $r30, -1
	jal min_caml_read_int
	addi $r30, $r30, 1
	load $r31, $r30, 0
	store $r3, $r30, 0
	load $r27, $r30, 0
	imovf $f0, $r27
	jr $r31

#----------------------------------------------------------------------
#
# lib_asm.s
#
#----------------------------------------------------------------------


