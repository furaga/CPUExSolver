
#----------------------------------------------------------------------
#
# lib_asm.s
#
#----------------------------------------------------------------------

# * create_array
min_caml_create_array:
	add ＄r5, ＄r3, ＄r2
	mov ＄r3, ＄r2
CREATE_ARRAY_LOOP:
	blt  ＄r2, ＄r5, CREATE_ARRAY_CONTINUE
	return
CREATE_ARRAY_CONTINUE:
	sti ＄r4, ＄r2, 0	
	mvhi ＄r28, 0
	mvlo ＄r28, 1
	add ＄r2, ＄r2, ＄r28	
	j CREATE_ARRAY_LOOP

# * create_float_array
min_caml_create_float_array:
	add ＄r4, ＄r3, ＄r2
	mov ＄r3, ＄r2
CREATE_FLOAT_ARRAY_LOOP:
	blt ＄r2, ＄r4, CREATE_FLOAT_ARRAY_CONTINUE
	return
CREATE_FLOAT_ARRAY_CONTINUE:
	fsti ＄f0, ＄r2, 0
	mvhi ＄r28, 0
	mvlo ＄r28, 1
	add ＄r2, ＄r2, ＄r28
	j CREATE_FLOAT_ARRAY_LOOP

# * floor		＄f0 + MAGICF - MAGICF
min_caml_floor:
	fmov ＄f1, ＄f0
	# ＄f4 <- 0.0
	# fset ＄f4, 0.0
	fmvhi ＄f4, 0
	fmvlo ＄f4, 0
	fblt ＄f0, ＄f4, FLOOR_NEGATIVE	# if (＄f4 <= ＄f0) goto FLOOR_PISITIVE
FLOOR_POSITIVE:
	# ＄f2 <- 8388608.0(0x4b000000)
	fmvhi ＄f2, 19200
	fmvlo ＄f2, 0
	fblt ＄f2, ＄f0, FLOOR_POSITIVE_RET
FLOOR_POSITIVE_MAIN:
	fmov ＄f1, ＄f0
	fadd ＄f0, ＄f0, ＄f2
	fsti ＄f0, ＄r1, 0
	ldi ＄r4, ＄r1, 0
	fsub ＄f0, ＄f0, ＄f2
	fsti ＄f0, ＄r1, 0
	ldi ＄r4, ＄r1, 0
	fblt ＄f1, ＄f0, FLOOR_POSITIVE_RET
	return
FLOOR_POSITIVE_RET:
	# ＄f3 <- 1.0
	# fset ＄f3, 1.0
	fmvhi ＄f3, 16256
	fmvlo ＄f3, 0
	fsub ＄f0, ＄f0, ＄f3
	return
FLOOR_NEGATIVE:
	fneg ＄f0, ＄f0
	# ＄f2 <- 8388608.0(0x4b000000)
	fmvhi ＄f2, 19200
	fmvlo ＄f2, 0
	fblt ＄f2, ＄f0, FLOOR_NEGATIVE_RET
FLOOR_NEGATIVE_MAIN:
	fadd ＄f0, ＄f0, ＄f2
	fsub ＄f0, ＄f0, ＄f2
	fneg ＄f1, ＄f1
	fblt ＄f0, ＄f1, FLOOR_NEGATIVE_PRE_RET
	j FLOOR_NEGATIVE_RET
FLOOR_NEGATIVE_PRE_RET:
	fadd ＄f0, ＄f0, ＄f2
	# ＄f3 <- 1.0
	# fset ＄f3, 1.0
	fmvhi ＄f3, 16256
	fmvlo ＄f3, 0
	fadd ＄f0, ＄f0, ＄f3
	fsub ＄f0, ＄f0, ＄f2
FLOOR_NEGATIVE_RET:
	fneg ＄f0, ＄f0
	return
	
min_caml_ceil:
	fneg ＄f0, ＄f0
	call min_caml_floor
	fneg ＄f0, ＄f0
	return

# * float_of_int
min_caml_float_of_int:
	blt ＄r3, ＄r0, ITOF_NEGATIVE_MAIN		# if (＄r0 <= ＄r3) goto ITOF_MAIN
ITOF_MAIN:
	# ＄f1 <- 8388608.0(0x4b000000)
	fmvhi ＄f1, 19200
	fmvlo ＄f1, 0
	# ＄r4 <- 0x4b000000
	mvhi ＄r4, 19200
	mvlo ＄r4, 0
	# ＄r5 <- 0x00800000
	mvhi ＄r5, 128
	mvlo ＄r5, 0
	blt ＄r3, ＄r5, ITOF_SMALL
ITOF_BIG:
	# ＄f2 <- 0.0
	# fset ＄f2, 0.0
	fmvhi ＄f2, 0
	fmvlo ＄f2, 0
ITOF_LOOP:
	sub ＄r3, ＄r3, ＄r5
	fadd ＄f2, ＄f2, ＄f1
	blt ＄r3, ＄r5, ITOF_RET
	j ITOF_LOOP
ITOF_RET:
	add ＄r3, ＄r3, ＄r4
	sti ＄r3, ＄r1, 0
	fldi ＄f0, ＄r1, 0
	fsub ＄f0, ＄f0, ＄f1
	fadd ＄f0, ＄f0, ＄f2
	return
ITOF_SMALL:
	add ＄r3, ＄r3, ＄r4
	sti ＄r3, ＄r1, 0
	fldi ＄f0, ＄r1, 0
	fsub ＄f0, ＄f0, ＄f1
	return
ITOF_NEGATIVE_MAIN:
	sub ＄r3, ＄r0, ＄r3
	call ITOF_MAIN
	fneg ＄f0, ＄f0
	return

# * int_of_float
min_caml_int_of_float:
	# ＄f1 <- 0.0
	# fset ＄f1, 0.0
	fmvhi ＄f1, 0
	fmvlo ＄f1, 0
	fblt ＄f0, ＄f1, FTOI_NEGATIVE_MAIN			# if (0.0 <= ＄f0) goto FTOI_MAIN
FTOI_POSITIVE_MAIN:
	call min_caml_floor
	# ＄f2 <- 8388608.0(0x4b000000)
	fmvhi ＄f2, 19200
	fmvlo ＄f2, 0
	# ＄r4 <- 0x4b000000
	mvhi ＄r4, 19200
	mvlo ＄r4, 0
	fblt ＄f0, ＄f2, FTOI_SMALL		# if (MAGICF <= ＄f0) goto FTOI_BIG
	# ＄r5 <- 0x00800000
	mvhi ＄r5, 128
	mvlo ＄r5, 0
	mov ＄r3, ＄r0
FTOI_LOOP:
	fsub ＄f0, ＄f0, ＄f2
	add ＄r3, ＄r3, ＄r5
	fblt ＄f0, ＄f2, FTOI_RET
	j FTOI_LOOP
FTOI_RET:
	fadd ＄f0, ＄f0, ＄f2
	fsti ＄f0, ＄r1, 0
	ldi ＄r5, ＄r1, 0
	sub ＄r5, ＄r5, ＄r4
	add ＄r3, ＄r5, ＄r3
	return
FTOI_SMALL:
	fadd ＄f0, ＄f0, ＄f2
	fsti ＄f0, ＄r1, 0
	ldi ＄r3, ＄r1, 0
	sub ＄r3, ＄r3, ＄r4
	return
FTOI_NEGATIVE_MAIN:
	fneg ＄f0, ＄f0
	call FTOI_POSITIVE_MAIN
	sub ＄r3, ＄r0, ＄r3
	return
	
# * truncate
min_caml_truncate:
	j min_caml_int_of_float
	
# ビッグエンディアン
min_caml_read_int:
	add ＄r3, ＄r0, ＄r0
	# 24 - 31
	input ＄r4
	add ＄r3, ＄r3, ＄r4
	slli ＄r3, ＄r3, 8
	# 16 - 23
	input ＄r4
	add ＄r3, ＄r3, ＄r4
	slli ＄r3, ＄r3, 8
	# 8 - 15
	input ＄r4
	add ＄r3, ＄r3, ＄r4
	slli ＄r3, ＄r3, 8
	# 0 - 7
	input ＄r4
	add ＄r3, ＄r3, ＄r4
	return

min_caml_read_float:
	call min_caml_read_int
	sti ＄r3, ＄r1, 0
	fldi ＄f0, ＄r1, 0
	return

#----------------------------------------------------------------------
#
# lib_asm.s
#
#----------------------------------------------------------------------


