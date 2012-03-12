	j	min_caml_start

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


min_caml_start:
	mvhi	＄r2, 0
	mvlo	＄r2, 591
	mvhi	＄r29, 0
	mvlo	＄r29, 1
	sub	＄r30, ＄r0, ＄r29
	# 0.000000
	fmvhi	＄f16, 0
	fmvlo	＄f16, 0
	# 1.000000
	fmvhi	＄f17, 16256
	fmvlo	＄f17, 0
	# -150.000000
	fmvhi	＄f18, 49942
	fmvlo	＄f18, 0
	# 150.000000
	fmvhi	＄f19, 17174
	fmvlo	＄f19, 0
	# -1.000000
	fmvhi	＄f20, 49024
	fmvlo	＄f20, 0
	# 0.500000
	fmvhi	＄f21, 16128
	fmvlo	＄f21, 0
	# 1.570796
	fmvhi	＄f22, 16329
	fmvlo	＄f22, 4058
	# 3.000000
	fmvhi	＄f23, 16448
	fmvlo	＄f23, 0
	# 5.000000
	fmvhi	＄f24, 16544
	fmvlo	＄f24, 0
	# 9.000000
	fmvhi	＄f25, 16656
	fmvlo	＄f25, 0
	# 7.000000
	fmvhi	＄f26, 16608
	fmvlo	＄f26, 0
	# 255.000000
	fmvhi	＄f27, 17279
	fmvlo	＄f27, 0
	# 15.000000
	fmvhi	＄f28, 16752
	fmvlo	＄f28, 0
	# 6.283185
	fmvhi	＄f29, 16585
	fmvlo	＄f29, 4058
	# 2.000000
	fmvhi	＄f30, 16384
	fmvlo	＄f30, 0
	# 3.141593
	fmvhi	＄f31, 16457
	fmvlo	＄f31, 4058
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 589
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 588
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 587
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 586
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	mvhi	＄r4, 0
	mvlo	＄r4, 1
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 585
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 584
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 583
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 582
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r6, 0
	mvlo	＄r6, 60
	mvhi	＄r10, 0
	mvlo	＄r10, 0
	mvhi	＄r9, 0
	mvlo	＄r9, 0
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	mvhi	＄r7, 0
	mvlo	＄r7, 0
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 11
	add	＄r2, ＄r2, ＄r28
	sti	＄r4, ＄r3, 10
	sti	＄r4, ＄r3, 9
	sti	＄r4, ＄r3, 8
	sti	＄r4, ＄r3, 7
	sti	＄r5, ＄r3, 6
	sti	＄r4, ＄r3, 5
	sti	＄r4, ＄r3, 4
	sti	＄r7, ＄r3, 3
	sti	＄r8, ＄r3, 2
	sti	＄r9, ＄r3, 1
	sti	＄r10, ＄r3, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 522
	add	＄r2, ＄r0, ＄r28
	mov	＄r4, ＄r3
	mov	＄r3, ＄r6
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 519
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 516
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 513
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 512
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f27
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r6, 0
	mvlo	＄r6, 50
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	mvhi	＄r4, 65535
	mvlo	＄r4, -1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 462
	add	＄r2, ＄r0, ＄r28
	mov	＄r3, ＄r6
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r6, 0
	mvlo	＄r6, 1
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	ldi	＄r4, ＄r0, 462
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 461
	add	＄r2, ＄r0, ＄r28
	mov	＄r3, ＄r6
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 460
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 459
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	# 1000000000.000000
	fmvhi	＄f0, 20078
	fmvlo	＄f0, 27432
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 458
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 455
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 454
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 451
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 448
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 445
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 442
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 2
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 440
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 2
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 438
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 437
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 434
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 431
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 428
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 425
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 422
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 419
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 418
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r7, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 417
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 65535
	mvlo	＄r28, -418
	sub	＄r4, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r6, 0
	mvlo	＄r6, 0
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r4, ＄r3, 1
	sti	＄r7, ＄r3, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 416
	add	＄r2, ＄r0, ＄r28
	mov	＄r4, ＄r3
	mov	＄r3, ＄r6
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 411
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 65535
	mvlo	＄r28, -416
	sub	＄r4, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 410
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 407
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r6, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 60
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 347
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 65535
	mvlo	＄r28, -410
	sub	＄r4, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	ldi	＄r2, ＄r0, 591
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 345
	add	＄r2, ＄r0, ＄r28
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r4, ＄r3, 1
	sti	＄r6, ＄r3, 0
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 344
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r6, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 343
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 65535
	mvlo	＄r28, -344
	sub	＄r4, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 341
	add	＄r2, ＄r0, ＄r28
	mov	＄r4, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r3, ＄r4, 1
	sti	＄r6, ＄r4, 0
	ldi	＄r2, ＄r0, 591
	mvhi	＄r6, 0
	mvlo	＄r6, 180
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r2, ＄r2, ＄r28
	fsti	＄f16, ＄r3, 2
	sti	＄r4, ＄r3, 1
	sti	＄r5, ＄r3, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 161
	add	＄r2, ＄r0, ＄r28
	mov	＄r4, ＄r3
	mov	＄r3, ＄r6
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 160
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 128
	mvhi	＄r4, 0
	mvlo	＄r4, 128
	sti	＄r3, ＄r0, 440
	sti	＄r4, ＄r0, 441
	mvhi	＄r4, 0
	mvlo	＄r4, 64
	sti	＄r4, ＄r0, 438
	mvhi	＄r4, 0
	mvlo	＄r4, 64
	sti	＄r4, ＄r0, 439
	# 128.000000
	fmvhi	＄f3, 17152
	fmvlo	＄f3, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_float_of_int
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fdiv	＄f0, ＄f3, ＄f0
	fsti	＄f0, ＄r0, 437
	ldi	＄r12, ＄r0, 440
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 157
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r11, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 154
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 149
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 65535
	mvlo	＄r28, -154
	sub	＄r4, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r10, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 150
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 151
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 152
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 153
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 144
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r9, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 139
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r8, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 136
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 131
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 65535
	mvlo	＄r28, -136
	sub	＄r4, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r7, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 132
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 133
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 134
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 135
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 128
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 123
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 65535
	mvlo	＄r28, -128
	sub	＄r4, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r6, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 124
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 125
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 126
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 127
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 122
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r13, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 119
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 114
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 65535
	mvlo	＄r28, -119
	sub	＄r4, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r5, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 115
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 116
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 117
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 118
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	add	＄r2, ＄r2, ＄r28
	sti	＄r5, ＄r3, 7
	sti	＄r13, ＄r3, 6
	sti	＄r6, ＄r3, 5
	sti	＄r7, ＄r3, 4
	sti	＄r8, ＄r3, 3
	sti	＄r9, ＄r3, 2
	sti	＄r10, ＄r3, 1
	sti	＄r11, ＄r3, 0
	mov	＄r4, ＄r3
	mov	＄r3, ＄r12
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r10, ＄r3
	sti	＄r10, ＄r0, 113
	ldi	＄r3, ＄r0, 440
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r9, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	init_line_elements.3044
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r23, ＄r3
	sti	＄r23, ＄r0, 112
	ldi	＄r12, ＄r0, 440
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 109
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r11, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 106
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 101
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 65535
	mvlo	＄r28, -106
	sub	＄r4, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r10, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 102
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 103
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 104
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 105
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 96
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r9, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 91
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r8, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 88
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 83
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 65535
	mvlo	＄r28, -88
	sub	＄r4, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r7, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 84
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 85
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 86
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 87
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 80
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 75
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 65535
	mvlo	＄r28, -80
	sub	＄r4, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r6, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 76
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 77
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 78
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 79
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 74
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r13, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 71
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 66
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 65535
	mvlo	＄r28, -71
	sub	＄r4, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r5, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 67
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 68
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 69
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 70
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	add	＄r2, ＄r2, ＄r28
	sti	＄r5, ＄r3, 7
	sti	＄r13, ＄r3, 6
	sti	＄r6, ＄r3, 5
	sti	＄r7, ＄r3, 4
	sti	＄r8, ＄r3, 3
	sti	＄r9, ＄r3, 2
	sti	＄r10, ＄r3, 1
	sti	＄r11, ＄r3, 0
	mov	＄r4, ＄r3
	mov	＄r3, ＄r12
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r10, ＄r3
	sti	＄r10, ＄r0, 65
	ldi	＄r3, ＄r0, 440
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r9, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	init_line_elements.3044
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r31, ＄r3
	sti	＄r31, ＄r0, 64
	ldi	＄r12, ＄r0, 440
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 61
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r11, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 58
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 53
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 65535
	mvlo	＄r28, -58
	sub	＄r4, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r10, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 54
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 55
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 56
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 57
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 48
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r9, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 43
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r8, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 40
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 35
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 65535
	mvlo	＄r28, -40
	sub	＄r4, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r7, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 36
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 37
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 38
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 39
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 32
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 27
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 65535
	mvlo	＄r28, -32
	sub	＄r4, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r6, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 28
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 29
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 30
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 31
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 26
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r13, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 23
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 18
	add	＄r2, ＄r0, ＄r28
	mvhi	＄r28, 65535
	mvlo	＄r28, -23
	sub	＄r4, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r5, ＄r3
	ldi	＄r2, ＄r0, 591
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 19
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 20
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 21
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 22
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	add	＄r2, ＄r2, ＄r28
	sti	＄r5, ＄r3, 7
	sti	＄r13, ＄r3, 6
	sti	＄r6, ＄r3, 5
	sti	＄r7, ＄r3, 4
	sti	＄r8, ＄r3, 3
	sti	＄r9, ＄r3, 2
	sti	＄r10, ＄r3, 1
	sti	＄r11, ＄r3, 0
	mov	＄r4, ＄r3
	mov	＄r3, ＄r12
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r10, ＄r3
	sti	＄r10, ＄r0, 17
	ldi	＄r3, ＄r0, 440
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r9, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	init_line_elements.3044
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r22, ＄r3
	sti	＄r22, ＄r0, 16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_float
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fsti	＄f0, ＄r0, 519
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_float
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fsti	＄f0, ＄r0, 520
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_float
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fsti	＄f0, ＄r0, 521
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_float
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	# 0.017453
	fmvhi	＄f6, 15502
	fmvlo	＄f6, 64045
	fmul	＄f3, ＄f0, ＄f6
	fsub	＄f2, ＄f22, ＄f3
	fblt	＄f2, ＄f16, fbge_else.43075
	fmov	＄f1, ＄f2
	j	fbge_cont.43076
fbge_else.43075:
	fneg	＄f1, ＄f2
fbge_cont.43076:
	fblt	＄f29, ＄f1, fbge_else.43077
	fblt	＄f1, ＄f16, fbge_else.43079
	fmov	＄f0, ＄f1
	j	fbge_cont.43080
fbge_else.43079:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43081
	fblt	＄f1, ＄f16, fbge_else.43083
	fmov	＄f0, ＄f1
	j	fbge_cont.43084
fbge_else.43083:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43085
	fblt	＄f1, ＄f16, fbge_else.43087
	fmov	＄f0, ＄f1
	j	fbge_cont.43088
fbge_else.43087:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43088:
	j	fbge_cont.43086
fbge_else.43085:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43086:
fbge_cont.43084:
	j	fbge_cont.43082
fbge_else.43081:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43089
	fblt	＄f1, ＄f16, fbge_else.43091
	fmov	＄f0, ＄f1
	j	fbge_cont.43092
fbge_else.43091:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43092:
	j	fbge_cont.43090
fbge_else.43089:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43090:
fbge_cont.43082:
fbge_cont.43080:
	j	fbge_cont.43078
fbge_else.43077:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43093
	fblt	＄f1, ＄f16, fbge_else.43095
	fmov	＄f0, ＄f1
	j	fbge_cont.43096
fbge_else.43095:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43097
	fblt	＄f1, ＄f16, fbge_else.43099
	fmov	＄f0, ＄f1
	j	fbge_cont.43100
fbge_else.43099:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43100:
	j	fbge_cont.43098
fbge_else.43097:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43098:
fbge_cont.43096:
	j	fbge_cont.43094
fbge_else.43093:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43101
	fblt	＄f1, ＄f16, fbge_else.43103
	fmov	＄f0, ＄f1
	j	fbge_cont.43104
fbge_else.43103:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43104:
	j	fbge_cont.43102
fbge_else.43101:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43102:
fbge_cont.43094:
fbge_cont.43078:
	fblt	＄f31, ＄f0, fbge_else.43105
	fblt	＄f16, ＄f2, fbge_else.43107
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.43108
fbge_else.43107:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.43108:
	j	fbge_cont.43106
fbge_else.43105:
	fblt	＄f16, ＄f2, fbge_else.43109
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	fbge_cont.43110
fbge_else.43109:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
fbge_cont.43110:
fbge_cont.43106:
	fblt	＄f31, ＄f0, fbge_else.43111
	fmov	＄f1, ＄f0
	j	fbge_cont.43112
fbge_else.43111:
	fsub	＄f1, ＄f29, ＄f0
fbge_cont.43112:
	fblt	＄f22, ＄f1, fbge_else.43113
	fmov	＄f0, ＄f1
	j	fbge_cont.43114
fbge_else.43113:
	fsub	＄f0, ＄f31, ＄f1
fbge_cont.43114:
	fmul	＄f1, ＄f0, ＄f21
	fmul	＄f0, ＄f1, ＄f1
	fdiv	＄f2, ＄f0, ＄f25
	fsub	＄f2, ＄f26, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f24, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f23, ＄f2
	fdiv	＄f0, ＄f0, ＄f2
	fsub	＄f0, ＄f17, ＄f0
	fdiv	＄f1, ＄f1, ＄f0
	fmul	＄f0, ＄f30, ＄f1
	fmul	＄f1, ＄f1, ＄f1
	fadd	＄f1, ＄f17, ＄f1
	fdiv	＄f0, ＄f0, ＄f1
	beq	＄r3, ＄r0, bne_else.43115
	fmov	＄f5, ＄f0
	j	bne_cont.43116
bne_else.43115:
	fneg	＄f5, ＄f0
bne_cont.43116:
	fblt	＄f3, ＄f16, fbge_else.43117
	fmov	＄f1, ＄f3
	j	fbge_cont.43118
fbge_else.43117:
	fneg	＄f1, ＄f3
fbge_cont.43118:
	fblt	＄f29, ＄f1, fbge_else.43119
	fblt	＄f1, ＄f16, fbge_else.43121
	fmov	＄f0, ＄f1
	j	fbge_cont.43122
fbge_else.43121:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43123
	fblt	＄f1, ＄f16, fbge_else.43125
	fmov	＄f0, ＄f1
	j	fbge_cont.43126
fbge_else.43125:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43127
	fblt	＄f1, ＄f16, fbge_else.43129
	fmov	＄f0, ＄f1
	j	fbge_cont.43130
fbge_else.43129:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43130:
	j	fbge_cont.43128
fbge_else.43127:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43128:
fbge_cont.43126:
	j	fbge_cont.43124
fbge_else.43123:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43131
	fblt	＄f1, ＄f16, fbge_else.43133
	fmov	＄f0, ＄f1
	j	fbge_cont.43134
fbge_else.43133:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43134:
	j	fbge_cont.43132
fbge_else.43131:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43132:
fbge_cont.43124:
fbge_cont.43122:
	j	fbge_cont.43120
fbge_else.43119:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43135
	fblt	＄f1, ＄f16, fbge_else.43137
	fmov	＄f0, ＄f1
	j	fbge_cont.43138
fbge_else.43137:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43139
	fblt	＄f1, ＄f16, fbge_else.43141
	fmov	＄f0, ＄f1
	j	fbge_cont.43142
fbge_else.43141:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43142:
	j	fbge_cont.43140
fbge_else.43139:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43140:
fbge_cont.43138:
	j	fbge_cont.43136
fbge_else.43135:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43143
	fblt	＄f1, ＄f16, fbge_else.43145
	fmov	＄f0, ＄f1
	j	fbge_cont.43146
fbge_else.43145:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43146:
	j	fbge_cont.43144
fbge_else.43143:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43144:
fbge_cont.43136:
fbge_cont.43120:
	fblt	＄f31, ＄f0, fbge_else.43147
	fblt	＄f16, ＄f3, fbge_else.43149
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.43150
fbge_else.43149:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.43150:
	j	fbge_cont.43148
fbge_else.43147:
	fblt	＄f16, ＄f3, fbge_else.43151
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	fbge_cont.43152
fbge_else.43151:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
fbge_cont.43152:
fbge_cont.43148:
	fblt	＄f31, ＄f0, fbge_else.43153
	fmov	＄f1, ＄f0
	j	fbge_cont.43154
fbge_else.43153:
	fsub	＄f1, ＄f29, ＄f0
fbge_cont.43154:
	fblt	＄f22, ＄f1, fbge_else.43155
	fmov	＄f0, ＄f1
	j	fbge_cont.43156
fbge_else.43155:
	fsub	＄f0, ＄f31, ＄f1
fbge_cont.43156:
	fmul	＄f1, ＄f0, ＄f21
	fmul	＄f0, ＄f1, ＄f1
	fdiv	＄f2, ＄f0, ＄f25
	fsub	＄f2, ＄f26, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f24, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f23, ＄f2
	fdiv	＄f0, ＄f0, ＄f2
	fsub	＄f0, ＄f17, ＄f0
	fdiv	＄f1, ＄f1, ＄f0
	fmul	＄f0, ＄f30, ＄f1
	fmul	＄f1, ＄f1, ＄f1
	fadd	＄f1, ＄f17, ＄f1
	fdiv	＄f0, ＄f0, ＄f1
	beq	＄r3, ＄r0, bne_else.43157
	fmov	＄f4, ＄f0
	j	bne_cont.43158
bne_else.43157:
	fneg	＄f4, ＄f0
bne_cont.43158:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_float
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fmul	＄f3, ＄f0, ＄f6
	fsub	＄f2, ＄f22, ＄f3
	fblt	＄f2, ＄f16, fbge_else.43159
	fmov	＄f1, ＄f2
	j	fbge_cont.43160
fbge_else.43159:
	fneg	＄f1, ＄f2
fbge_cont.43160:
	fblt	＄f29, ＄f1, fbge_else.43161
	fblt	＄f1, ＄f16, fbge_else.43163
	fmov	＄f0, ＄f1
	j	fbge_cont.43164
fbge_else.43163:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43165
	fblt	＄f1, ＄f16, fbge_else.43167
	fmov	＄f0, ＄f1
	j	fbge_cont.43168
fbge_else.43167:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43169
	fblt	＄f1, ＄f16, fbge_else.43171
	fmov	＄f0, ＄f1
	j	fbge_cont.43172
fbge_else.43171:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43172:
	j	fbge_cont.43170
fbge_else.43169:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43170:
fbge_cont.43168:
	j	fbge_cont.43166
fbge_else.43165:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43173
	fblt	＄f1, ＄f16, fbge_else.43175
	fmov	＄f0, ＄f1
	j	fbge_cont.43176
fbge_else.43175:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43176:
	j	fbge_cont.43174
fbge_else.43173:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43174:
fbge_cont.43166:
fbge_cont.43164:
	j	fbge_cont.43162
fbge_else.43161:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43177
	fblt	＄f1, ＄f16, fbge_else.43179
	fmov	＄f0, ＄f1
	j	fbge_cont.43180
fbge_else.43179:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43181
	fblt	＄f1, ＄f16, fbge_else.43183
	fmov	＄f0, ＄f1
	j	fbge_cont.43184
fbge_else.43183:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43184:
	j	fbge_cont.43182
fbge_else.43181:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43182:
fbge_cont.43180:
	j	fbge_cont.43178
fbge_else.43177:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43185
	fblt	＄f1, ＄f16, fbge_else.43187
	fmov	＄f0, ＄f1
	j	fbge_cont.43188
fbge_else.43187:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43188:
	j	fbge_cont.43186
fbge_else.43185:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43186:
fbge_cont.43178:
fbge_cont.43162:
	fblt	＄f31, ＄f0, fbge_else.43189
	fblt	＄f16, ＄f2, fbge_else.43191
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.43192
fbge_else.43191:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.43192:
	j	fbge_cont.43190
fbge_else.43189:
	fblt	＄f16, ＄f2, fbge_else.43193
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	fbge_cont.43194
fbge_else.43193:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
fbge_cont.43194:
fbge_cont.43190:
	fblt	＄f31, ＄f0, fbge_else.43195
	fmov	＄f1, ＄f0
	j	fbge_cont.43196
fbge_else.43195:
	fsub	＄f1, ＄f29, ＄f0
fbge_cont.43196:
	fblt	＄f22, ＄f1, fbge_else.43197
	fmov	＄f0, ＄f1
	j	fbge_cont.43198
fbge_else.43197:
	fsub	＄f0, ＄f31, ＄f1
fbge_cont.43198:
	fmul	＄f1, ＄f0, ＄f21
	fmul	＄f0, ＄f1, ＄f1
	fdiv	＄f2, ＄f0, ＄f25
	fsub	＄f2, ＄f26, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f24, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f23, ＄f2
	fdiv	＄f0, ＄f0, ＄f2
	fsub	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	fmul	＄f1, ＄f30, ＄f0
	fmul	＄f0, ＄f0, ＄f0
	fadd	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	beq	＄r3, ＄r0, bne_else.43199
	fmov	＄f2, ＄f0
	j	bne_cont.43200
bne_else.43199:
	fneg	＄f2, ＄f0
bne_cont.43200:
	fblt	＄f3, ＄f16, fbge_else.43201
	fmov	＄f1, ＄f3
	j	fbge_cont.43202
fbge_else.43201:
	fneg	＄f1, ＄f3
fbge_cont.43202:
	fblt	＄f29, ＄f1, fbge_else.43203
	fblt	＄f1, ＄f16, fbge_else.43205
	fmov	＄f0, ＄f1
	j	fbge_cont.43206
fbge_else.43205:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43207
	fblt	＄f1, ＄f16, fbge_else.43209
	fmov	＄f0, ＄f1
	j	fbge_cont.43210
fbge_else.43209:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43211
	fblt	＄f1, ＄f16, fbge_else.43213
	fmov	＄f0, ＄f1
	j	fbge_cont.43214
fbge_else.43213:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43214:
	j	fbge_cont.43212
fbge_else.43211:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43212:
fbge_cont.43210:
	j	fbge_cont.43208
fbge_else.43207:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43215
	fblt	＄f1, ＄f16, fbge_else.43217
	fmov	＄f0, ＄f1
	j	fbge_cont.43218
fbge_else.43217:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43218:
	j	fbge_cont.43216
fbge_else.43215:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43216:
fbge_cont.43208:
fbge_cont.43206:
	j	fbge_cont.43204
fbge_else.43203:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43219
	fblt	＄f1, ＄f16, fbge_else.43221
	fmov	＄f0, ＄f1
	j	fbge_cont.43222
fbge_else.43221:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43223
	fblt	＄f1, ＄f16, fbge_else.43225
	fmov	＄f0, ＄f1
	j	fbge_cont.43226
fbge_else.43225:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43226:
	j	fbge_cont.43224
fbge_else.43223:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43224:
fbge_cont.43222:
	j	fbge_cont.43220
fbge_else.43219:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43227
	fblt	＄f1, ＄f16, fbge_else.43229
	fmov	＄f0, ＄f1
	j	fbge_cont.43230
fbge_else.43229:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43230:
	j	fbge_cont.43228
fbge_else.43227:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43228:
fbge_cont.43220:
fbge_cont.43204:
	fblt	＄f31, ＄f0, fbge_else.43231
	fblt	＄f16, ＄f3, fbge_else.43233
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.43234
fbge_else.43233:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.43234:
	j	fbge_cont.43232
fbge_else.43231:
	fblt	＄f16, ＄f3, fbge_else.43235
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	fbge_cont.43236
fbge_else.43235:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
fbge_cont.43236:
fbge_cont.43232:
	fblt	＄f31, ＄f0, fbge_else.43237
	fmov	＄f1, ＄f0
	j	fbge_cont.43238
fbge_else.43237:
	fsub	＄f1, ＄f29, ＄f0
fbge_cont.43238:
	fblt	＄f22, ＄f1, fbge_else.43239
	fmov	＄f0, ＄f1
	j	fbge_cont.43240
fbge_else.43239:
	fsub	＄f0, ＄f31, ＄f1
fbge_cont.43240:
	fmul	＄f1, ＄f0, ＄f21
	fmul	＄f0, ＄f1, ＄f1
	fdiv	＄f3, ＄f0, ＄f25
	fsub	＄f3, ＄f26, ＄f3
	fdiv	＄f3, ＄f0, ＄f3
	fsub	＄f3, ＄f24, ＄f3
	fdiv	＄f3, ＄f0, ＄f3
	fsub	＄f3, ＄f23, ＄f3
	fdiv	＄f0, ＄f0, ＄f3
	fsub	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	fmul	＄f1, ＄f30, ＄f0
	fmul	＄f0, ＄f0, ＄f0
	fadd	＄f0, ＄f17, ＄f0
	fdiv	＄f1, ＄f1, ＄f0
	beq	＄r3, ＄r0, bne_else.43241
	fmov	＄f0, ＄f1
	j	bne_cont.43242
bne_else.43241:
	fneg	＄f0, ＄f1
bne_cont.43242:
	fmul	＄f3, ＄f5, ＄f0
	# 200.000000
	fmvhi	＄f1, 17224
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f3, ＄f1
	fsti	＄f3, ＄r0, 422
	# -200.000000
	fmvhi	＄f3, 49992
	fmvlo	＄f3, 0
	fmul	＄f3, ＄f4, ＄f3
	fsti	＄f3, ＄r0, 423
	fmul	＄f3, ＄f5, ＄f2
	fmul	＄f1, ＄f3, ＄f1
	fsti	＄f1, ＄r0, 424
	fsti	＄f2, ＄r0, 428
	fsti	＄f16, ＄r0, 429
	fneg	＄f1, ＄f0
	fsti	＄f1, ＄r0, 430
	fneg	＄f1, ＄f4
	fmul	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 425
	fneg	＄f5, ＄f5
	fsti	＄f5, ＄r0, 426
	fmul	＄f0, ＄f1, ＄f2
	fsti	＄f0, ＄r0, 427
	fldi	＄f1, ＄r0, 519
	fldi	＄f0, ＄r0, 422
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 516
	fldi	＄f1, ＄r0, 520
	fldi	＄f0, ＄r0, 423
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 517
	fldi	＄f1, ＄r0, 521
	fldi	＄f0, ＄r0, 424
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 518
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_int
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_float
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fmul	＄f2, ＄f0, ＄f6
	fblt	＄f2, ＄f16, fbge_else.43243
	fmov	＄f1, ＄f2
	j	fbge_cont.43244
fbge_else.43243:
	fneg	＄f1, ＄f2
fbge_cont.43244:
	fblt	＄f29, ＄f1, fbge_else.43245
	fblt	＄f1, ＄f16, fbge_else.43247
	fmov	＄f0, ＄f1
	j	fbge_cont.43248
fbge_else.43247:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43249
	fblt	＄f1, ＄f16, fbge_else.43251
	fmov	＄f0, ＄f1
	j	fbge_cont.43252
fbge_else.43251:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43253
	fblt	＄f1, ＄f16, fbge_else.43255
	fmov	＄f0, ＄f1
	j	fbge_cont.43256
fbge_else.43255:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43256:
	j	fbge_cont.43254
fbge_else.43253:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43254:
fbge_cont.43252:
	j	fbge_cont.43250
fbge_else.43249:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43257
	fblt	＄f1, ＄f16, fbge_else.43259
	fmov	＄f0, ＄f1
	j	fbge_cont.43260
fbge_else.43259:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43260:
	j	fbge_cont.43258
fbge_else.43257:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43258:
fbge_cont.43250:
fbge_cont.43248:
	j	fbge_cont.43246
fbge_else.43245:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43261
	fblt	＄f1, ＄f16, fbge_else.43263
	fmov	＄f0, ＄f1
	j	fbge_cont.43264
fbge_else.43263:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43265
	fblt	＄f1, ＄f16, fbge_else.43267
	fmov	＄f0, ＄f1
	j	fbge_cont.43268
fbge_else.43267:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43268:
	j	fbge_cont.43266
fbge_else.43265:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43266:
fbge_cont.43264:
	j	fbge_cont.43262
fbge_else.43261:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43269
	fblt	＄f1, ＄f16, fbge_else.43271
	fmov	＄f0, ＄f1
	j	fbge_cont.43272
fbge_else.43271:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43272:
	j	fbge_cont.43270
fbge_else.43269:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43270:
fbge_cont.43262:
fbge_cont.43246:
	fblt	＄f31, ＄f0, fbge_else.43273
	fblt	＄f16, ＄f2, fbge_else.43275
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.43276
fbge_else.43275:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.43276:
	j	fbge_cont.43274
fbge_else.43273:
	fblt	＄f16, ＄f2, fbge_else.43277
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	fbge_cont.43278
fbge_else.43277:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
fbge_cont.43278:
fbge_cont.43274:
	fblt	＄f31, ＄f0, fbge_else.43279
	fmov	＄f1, ＄f0
	j	fbge_cont.43280
fbge_else.43279:
	fsub	＄f1, ＄f29, ＄f0
fbge_cont.43280:
	fblt	＄f22, ＄f1, fbge_else.43281
	fmov	＄f0, ＄f1
	j	fbge_cont.43282
fbge_else.43281:
	fsub	＄f0, ＄f31, ＄f1
fbge_cont.43282:
	fmul	＄f1, ＄f0, ＄f21
	fmul	＄f0, ＄f1, ＄f1
	fdiv	＄f3, ＄f0, ＄f25
	fsub	＄f3, ＄f26, ＄f3
	fdiv	＄f3, ＄f0, ＄f3
	fsub	＄f3, ＄f24, ＄f3
	fdiv	＄f3, ＄f0, ＄f3
	fsub	＄f3, ＄f23, ＄f3
	fdiv	＄f0, ＄f0, ＄f3
	fsub	＄f0, ＄f17, ＄f0
	fdiv	＄f1, ＄f1, ＄f0
	fmul	＄f0, ＄f30, ＄f1
	fmul	＄f1, ＄f1, ＄f1
	fadd	＄f1, ＄f17, ＄f1
	fdiv	＄f1, ＄f0, ＄f1
	beq	＄r3, ＄r0, bne_else.43283
	fmov	＄f0, ＄f1
	j	bne_cont.43284
bne_else.43283:
	fneg	＄f0, ＄f1
bne_cont.43284:
	fneg	＄f0, ＄f0
	fsti	＄f0, ＄r0, 514
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_float
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fmul	＄f3, ＄f0, ＄f6
	fsub	＄f2, ＄f22, ＄f2
	fblt	＄f2, ＄f16, fbge_else.43285
	fmov	＄f1, ＄f2
	j	fbge_cont.43286
fbge_else.43285:
	fneg	＄f1, ＄f2
fbge_cont.43286:
	fblt	＄f29, ＄f1, fbge_else.43287
	fblt	＄f1, ＄f16, fbge_else.43289
	fmov	＄f0, ＄f1
	j	fbge_cont.43290
fbge_else.43289:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43291
	fblt	＄f1, ＄f16, fbge_else.43293
	fmov	＄f0, ＄f1
	j	fbge_cont.43294
fbge_else.43293:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43295
	fblt	＄f1, ＄f16, fbge_else.43297
	fmov	＄f0, ＄f1
	j	fbge_cont.43298
fbge_else.43297:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43298:
	j	fbge_cont.43296
fbge_else.43295:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43296:
fbge_cont.43294:
	j	fbge_cont.43292
fbge_else.43291:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43299
	fblt	＄f1, ＄f16, fbge_else.43301
	fmov	＄f0, ＄f1
	j	fbge_cont.43302
fbge_else.43301:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43302:
	j	fbge_cont.43300
fbge_else.43299:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43300:
fbge_cont.43292:
fbge_cont.43290:
	j	fbge_cont.43288
fbge_else.43287:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43303
	fblt	＄f1, ＄f16, fbge_else.43305
	fmov	＄f0, ＄f1
	j	fbge_cont.43306
fbge_else.43305:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43307
	fblt	＄f1, ＄f16, fbge_else.43309
	fmov	＄f0, ＄f1
	j	fbge_cont.43310
fbge_else.43309:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43310:
	j	fbge_cont.43308
fbge_else.43307:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43308:
fbge_cont.43306:
	j	fbge_cont.43304
fbge_else.43303:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43311
	fblt	＄f1, ＄f16, fbge_else.43313
	fmov	＄f0, ＄f1
	j	fbge_cont.43314
fbge_else.43313:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43314:
	j	fbge_cont.43312
fbge_else.43311:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43312:
fbge_cont.43304:
fbge_cont.43288:
	fblt	＄f31, ＄f0, fbge_else.43315
	fblt	＄f16, ＄f2, fbge_else.43317
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.43318
fbge_else.43317:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.43318:
	j	fbge_cont.43316
fbge_else.43315:
	fblt	＄f16, ＄f2, fbge_else.43319
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	fbge_cont.43320
fbge_else.43319:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
fbge_cont.43320:
fbge_cont.43316:
	fblt	＄f31, ＄f0, fbge_else.43321
	fmov	＄f1, ＄f0
	j	fbge_cont.43322
fbge_else.43321:
	fsub	＄f1, ＄f29, ＄f0
fbge_cont.43322:
	fblt	＄f22, ＄f1, fbge_else.43323
	fmov	＄f0, ＄f1
	j	fbge_cont.43324
fbge_else.43323:
	fsub	＄f0, ＄f31, ＄f1
fbge_cont.43324:
	fmul	＄f1, ＄f0, ＄f21
	fmul	＄f0, ＄f1, ＄f1
	fdiv	＄f2, ＄f0, ＄f25
	fsub	＄f2, ＄f26, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f24, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f23, ＄f2
	fdiv	＄f0, ＄f0, ＄f2
	fsub	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	fmul	＄f1, ＄f30, ＄f0
	fmul	＄f0, ＄f0, ＄f0
	fadd	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	beq	＄r3, ＄r0, bne_else.43325
	fmov	＄f4, ＄f0
	j	bne_cont.43326
bne_else.43325:
	fneg	＄f4, ＄f0
bne_cont.43326:
	fblt	＄f3, ＄f16, fbge_else.43327
	fmov	＄f1, ＄f3
	j	fbge_cont.43328
fbge_else.43327:
	fneg	＄f1, ＄f3
fbge_cont.43328:
	fblt	＄f29, ＄f1, fbge_else.43329
	fblt	＄f1, ＄f16, fbge_else.43331
	fmov	＄f0, ＄f1
	j	fbge_cont.43332
fbge_else.43331:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43333
	fblt	＄f1, ＄f16, fbge_else.43335
	fmov	＄f0, ＄f1
	j	fbge_cont.43336
fbge_else.43335:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43337
	fblt	＄f1, ＄f16, fbge_else.43339
	fmov	＄f0, ＄f1
	j	fbge_cont.43340
fbge_else.43339:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43340:
	j	fbge_cont.43338
fbge_else.43337:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43338:
fbge_cont.43336:
	j	fbge_cont.43334
fbge_else.43333:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43341
	fblt	＄f1, ＄f16, fbge_else.43343
	fmov	＄f0, ＄f1
	j	fbge_cont.43344
fbge_else.43343:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43344:
	j	fbge_cont.43342
fbge_else.43341:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43342:
fbge_cont.43334:
fbge_cont.43332:
	j	fbge_cont.43330
fbge_else.43329:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43345
	fblt	＄f1, ＄f16, fbge_else.43347
	fmov	＄f0, ＄f1
	j	fbge_cont.43348
fbge_else.43347:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43349
	fblt	＄f1, ＄f16, fbge_else.43351
	fmov	＄f0, ＄f1
	j	fbge_cont.43352
fbge_else.43351:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43352:
	j	fbge_cont.43350
fbge_else.43349:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43350:
fbge_cont.43348:
	j	fbge_cont.43346
fbge_else.43345:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43353
	fblt	＄f1, ＄f16, fbge_else.43355
	fmov	＄f0, ＄f1
	j	fbge_cont.43356
fbge_else.43355:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43356:
	j	fbge_cont.43354
fbge_else.43353:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43354:
fbge_cont.43346:
fbge_cont.43330:
	fblt	＄f31, ＄f0, fbge_else.43357
	fblt	＄f16, ＄f3, fbge_else.43359
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.43360
fbge_else.43359:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.43360:
	j	fbge_cont.43358
fbge_else.43357:
	fblt	＄f16, ＄f3, fbge_else.43361
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	fbge_cont.43362
fbge_else.43361:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
fbge_cont.43362:
fbge_cont.43358:
	fblt	＄f31, ＄f0, fbge_else.43363
	fmov	＄f1, ＄f0
	j	fbge_cont.43364
fbge_else.43363:
	fsub	＄f1, ＄f29, ＄f0
fbge_cont.43364:
	fblt	＄f22, ＄f1, fbge_else.43365
	fmov	＄f0, ＄f1
	j	fbge_cont.43366
fbge_else.43365:
	fsub	＄f0, ＄f31, ＄f1
fbge_cont.43366:
	fmul	＄f1, ＄f0, ＄f21
	fmul	＄f0, ＄f1, ＄f1
	fdiv	＄f2, ＄f0, ＄f25
	fsub	＄f2, ＄f26, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f24, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f23, ＄f2
	fdiv	＄f0, ＄f0, ＄f2
	fsub	＄f0, ＄f17, ＄f0
	fdiv	＄f1, ＄f1, ＄f0
	fmul	＄f0, ＄f30, ＄f1
	fmul	＄f1, ＄f1, ＄f1
	fadd	＄f1, ＄f17, ＄f1
	fdiv	＄f1, ＄f0, ＄f1
	beq	＄r3, ＄r0, bne_else.43367
	fmov	＄f0, ＄f1
	j	bne_cont.43368
bne_else.43367:
	fneg	＄f0, ＄f1
bne_cont.43368:
	fmul	＄f0, ＄f4, ＄f0
	fsti	＄f0, ＄r0, 513
	fsub	＄f2, ＄f22, ＄f3
	fblt	＄f2, ＄f16, fbge_else.43369
	fmov	＄f1, ＄f2
	j	fbge_cont.43370
fbge_else.43369:
	fneg	＄f1, ＄f2
fbge_cont.43370:
	fblt	＄f29, ＄f1, fbge_else.43371
	fblt	＄f1, ＄f16, fbge_else.43373
	fmov	＄f0, ＄f1
	j	fbge_cont.43374
fbge_else.43373:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43375
	fblt	＄f1, ＄f16, fbge_else.43377
	fmov	＄f0, ＄f1
	j	fbge_cont.43378
fbge_else.43377:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43379
	fblt	＄f1, ＄f16, fbge_else.43381
	fmov	＄f0, ＄f1
	j	fbge_cont.43382
fbge_else.43381:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43382:
	j	fbge_cont.43380
fbge_else.43379:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43380:
fbge_cont.43378:
	j	fbge_cont.43376
fbge_else.43375:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43383
	fblt	＄f1, ＄f16, fbge_else.43385
	fmov	＄f0, ＄f1
	j	fbge_cont.43386
fbge_else.43385:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43386:
	j	fbge_cont.43384
fbge_else.43383:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43384:
fbge_cont.43376:
fbge_cont.43374:
	j	fbge_cont.43372
fbge_else.43371:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43387
	fblt	＄f1, ＄f16, fbge_else.43389
	fmov	＄f0, ＄f1
	j	fbge_cont.43390
fbge_else.43389:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43391
	fblt	＄f1, ＄f16, fbge_else.43393
	fmov	＄f0, ＄f1
	j	fbge_cont.43394
fbge_else.43393:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43394:
	j	fbge_cont.43392
fbge_else.43391:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43392:
fbge_cont.43390:
	j	fbge_cont.43388
fbge_else.43387:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43395
	fblt	＄f1, ＄f16, fbge_else.43397
	fmov	＄f0, ＄f1
	j	fbge_cont.43398
fbge_else.43397:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43398:
	j	fbge_cont.43396
fbge_else.43395:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43396:
fbge_cont.43388:
fbge_cont.43372:
	fblt	＄f31, ＄f0, fbge_else.43399
	fblt	＄f16, ＄f2, fbge_else.43401
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.43402
fbge_else.43401:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.43402:
	j	fbge_cont.43400
fbge_else.43399:
	fblt	＄f16, ＄f2, fbge_else.43403
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	fbge_cont.43404
fbge_else.43403:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
fbge_cont.43404:
fbge_cont.43400:
	fblt	＄f31, ＄f0, fbge_else.43405
	fmov	＄f1, ＄f0
	j	fbge_cont.43406
fbge_else.43405:
	fsub	＄f1, ＄f29, ＄f0
fbge_cont.43406:
	fblt	＄f22, ＄f1, fbge_else.43407
	fmov	＄f0, ＄f1
	j	fbge_cont.43408
fbge_else.43407:
	fsub	＄f0, ＄f31, ＄f1
fbge_cont.43408:
	fmul	＄f0, ＄f0, ＄f21
	fmul	＄f2, ＄f0, ＄f0
	fdiv	＄f1, ＄f2, ＄f25
	fsub	＄f1, ＄f26, ＄f1
	fdiv	＄f1, ＄f2, ＄f1
	fsub	＄f1, ＄f24, ＄f1
	fdiv	＄f1, ＄f2, ＄f1
	fsub	＄f1, ＄f23, ＄f1
	fdiv	＄f1, ＄f2, ＄f1
	fsub	＄f1, ＄f17, ＄f1
	fdiv	＄f0, ＄f0, ＄f1
	fmul	＄f1, ＄f30, ＄f0
	fmul	＄f0, ＄f0, ＄f0
	fadd	＄f0, ＄f17, ＄f0
	fdiv	＄f1, ＄f1, ＄f0
	beq	＄r3, ＄r0, bne_else.43409
	fmov	＄f0, ＄f1
	j	bne_cont.43410
bne_else.43409:
	fneg	＄f0, ＄f1
bne_cont.43410:
	fmul	＄f0, ＄f4, ＄f0
	fsti	＄f0, ＄r0, 515
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_float
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fsti	＄f0, ＄r0, 512
	mvhi	＄r6, 0
	mvlo	＄r6, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	read_object.2755
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r6, 0
	mvlo	＄r6, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	read_and_network.2763
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r6, 0
	mvlo	＄r6, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	read_or_network.2761
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 461
	mvhi	＄r3, 0
	mvlo	＄r3, 80
	output	＄r3
	mvhi	＄r3, 0
	mvlo	＄r3, 51
	output	＄r3
	mvhi	＄r3, 0
	mvlo	＄r3, 10
	output	＄r3
	ldi	＄r14, ＄r0, 440
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	print_int.2587
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r3, 0
	mvlo	＄r3, 32
	output	＄r3
	ldi	＄r14, ＄r0, 441
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	print_int.2587
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r3, 0
	mvlo	＄r3, 32
	output	＄r3
	mvhi	＄r14, 0
	mvlo	＄r14, 255
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	print_int.2587
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r3, 0
	mvlo	＄r3, 10
	output	＄r3
	mvhi	＄r6, 0
	mvlo	＄r6, 120
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 13
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r7, ＄r3
	ldi	＄r2, ＄r0, 591
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 65535
	mvlo	＄r28, -13
	sub	＄r4, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	sti	＄r4, ＄r0, 12
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r4, ＄r3, 1
	sti	＄r7, ＄r3, 0
	mov	＄r4, ＄r3
	mov	＄r3, ＄r6
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r0, 415
	ldi	＄r6, ＄r0, 415
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 9
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r7, ＄r3
	ldi	＄r2, ＄r0, 591
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 65535
	mvlo	＄r28, -9
	sub	＄r4, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	sti	＄r4, ＄r0, 8
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r4, ＄r3, 1
	sti	＄r7, ＄r3, 0
	sti	＄r3, ＄r6, 118
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r7, ＄r3
	ldi	＄r2, ＄r0, 591
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 65535
	mvlo	＄r28, -5
	sub	＄r4, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	sti	＄r4, ＄r0, 4
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r4, ＄r3, 1
	sti	＄r7, ＄r3, 0
	sti	＄r3, ＄r6, 117
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	sti	＄r2, ＄r0, 591
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r2, ＄r0, ＄r28
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r7, ＄r3
	ldi	＄r2, ＄r0, 591
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 65535
	mvlo	＄r28, -1
	sub	＄r4, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	sti	＄r4, ＄r0, 0
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r4, ＄r3, 1
	sti	＄r7, ＄r3, 0
	sti	＄r3, ＄r6, 116
	mvhi	＄r7, 0
	mvlo	＄r7, 115
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	create_dirvec_elements.3071
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r8, 0
	mvlo	＄r8, 3
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	create_dirvecs.3074
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r3, 0
	mvlo	＄r3, 9
	mvhi	＄r7, 0
	mvlo	＄r7, 0
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_float_of_int
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	# 0.200000
	fmvhi	＄f4, 15948
	fmvlo	＄f4, 52420
	fmul	＄f0, ＄f0, ＄f4
	# 0.900000
	fmvhi	＄f3, 16230
	fmvlo	＄f3, 26206
	fsub	＄f0, ＄f0, ＄f3
	mvhi	＄r3, 0
	mvlo	＄r3, 4
	fsti	＄f0, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_float_of_int
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	fmov	＄f1, ＄f0
	fmul	＄f1, ＄f1, ＄f4
	fsub	＄f2, ＄f1, ＄f3
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	fldi	＄f0, ＄r1, 0
	fsti	＄f3, ＄r1, -1
	fsti	＄f4, ＄r1, -2
	fsti	＄f1, ＄r1, -3
	mov	＄r3, ＄r11
	mov	＄r5, ＄r7
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	add	＄r1, ＄r1, ＄r28
	# 0.100000
	fmvhi	＄f5, 15820
	fmvlo	＄f5, 52420
	fldi	＄f1, ＄r1, -3
	fadd	＄f2, ＄f1, ＄f5
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	mvhi	＄r3, 0
	mvlo	＄r3, 2
	fldi	＄f0, ＄r1, 0
	fsti	＄f5, ＄r1, -4
	mov	＄r5, ＄r7
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	mvhi	＄r5, 0
	mvlo	＄r5, 1
	sti	＄r5, ＄r1, -5
	mvhi	＄r28, 0
	mvlo	＄r28, 7
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_float_of_int
	mvhi	＄r28, 0
	mvlo	＄r28, 7
	add	＄r1, ＄r1, ＄r28
	fmov	＄f1, ＄f0
	fldi	＄f4, ＄r1, -2
	fmul	＄f1, ＄f1, ＄f4
	fldi	＄f3, ＄r1, -1
	fsub	＄f2, ＄f1, ＄f3
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	fldi	＄f0, ＄r1, 0
	ldi	＄r5, ＄r1, -5
	fsti	＄f1, ＄r1, -6
	mov	＄r3, ＄r11
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	add	＄r1, ＄r1, ＄r28
	fldi	＄f5, ＄r1, -4
	fldi	＄f1, ＄r1, -6
	fadd	＄f2, ＄f1, ＄f5
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	mvhi	＄r7, 0
	mvlo	＄r7, 2
	fldi	＄f0, ＄r1, 0
	ldi	＄r5, ＄r1, -5
	mov	＄r3, ＄r7
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r3, 0
	mvlo	＄r3, 2
	mvhi	＄r5, 0
	mvlo	＄r5, 2
	sti	＄r5, ＄r1, -7
	mvhi	＄r28, 0
	mvlo	＄r28, 9
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_float_of_int
	mvhi	＄r28, 0
	mvlo	＄r28, 9
	add	＄r1, ＄r1, ＄r28
	fmov	＄f1, ＄f0
	fldi	＄f4, ＄r1, -2
	fmul	＄f1, ＄f1, ＄f4
	fldi	＄f3, ＄r1, -1
	fsub	＄f2, ＄f1, ＄f3
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	fldi	＄f0, ＄r1, 0
	ldi	＄r5, ＄r1, -7
	fsti	＄f1, ＄r1, -8
	mov	＄r3, ＄r11
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	add	＄r1, ＄r1, ＄r28
	fldi	＄f5, ＄r1, -4
	fldi	＄f1, ＄r1, -8
	fadd	＄f2, ＄f1, ＄f5
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	fldi	＄f0, ＄r1, 0
	ldi	＄r5, ＄r1, -7
	mov	＄r3, ＄r7
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r9, 0
	mvlo	＄r9, 1
	mvhi	＄r8, 0
	mvlo	＄r8, 3
	fldi	＄f0, ＄r1, 0
	mov	＄r7, ＄r11
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvecs.3060
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r12, 0
	mvlo	＄r12, 8
	mvhi	＄r11, 0
	mvlo	＄r11, 2
	mvhi	＄r7, 0
	mvlo	＄r7, 4
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec_rows.3065
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	add	＄r1, ＄r1, ＄r28
	ldi	＄r12, ＄r0, 415
	ldi	＄r7, ＄r12, 119
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	add	＄r1, ＄r1, ＄r28
	ldi	＄r7, ＄r12, 118
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	add	＄r1, ＄r1, ＄r28
	ldi	＄r7, ＄r12, 117
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	add	＄r1, ＄r1, ＄r28
	ldi	＄r7, ＄r12, 116
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	add	＄r1, ＄r1, ＄r28
	ldi	＄r7, ＄r12, 115
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	add	＄r1, ＄r1, ＄r28
	ldi	＄r7, ＄r12, 114
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	add	＄r1, ＄r1, ＄r28
	ldi	＄r7, ＄r12, 113
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r13, 0
	mvlo	＄r13, 112
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	sub	＄r1, ＄r1, ＄r28
	call	init_dirvec_constants.3076
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r14, 0
	mvlo	＄r14, 3
	sti	＄r23, ＄r1, -9
	sti	＄r22, ＄r1, -10
	sti	＄r31, ＄r1, -11
	mvhi	＄r28, 0
	mvlo	＄r28, 13
	sub	＄r1, ＄r1, ＄r28
	call	init_vecset_constants.3079
	mvhi	＄r28, 0
	mvlo	＄r28, 13
	add	＄r1, ＄r1, ＄r28
	fldi	＄f0, ＄r0, 513
	fsti	＄f0, ＄r0, 407
	fldi	＄f0, ＄r0, 514
	fsti	＄f0, ＄r0, 408
	fldi	＄f0, ＄r0, 515
	fsti	＄f0, ＄r0, 409
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 65535
	mvlo	＄r28, -345
	sub	＄r7, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 13
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 13
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r6, ＄r3, ＄r28
	blt	＄r6, ＄r0, bge_else.43411
	slli	＄r3, ＄r6, 0
	ldi	＄r3, ＄r3, 522
	ldi	＄r4, ＄r3, 2
	mvhi	＄r5, 0
	mvlo	＄r5, 2
	beq	＄r4, ＄r5, bne_else.43413
	j	bne_cont.43414
bne_else.43413:
	ldi	＄r4, ＄r3, 7
	fldi	＄f0, ＄r4, 0
	fblt	＄f0, ＄f17, fbge_else.43415
	j	fbge_cont.43416
fbge_else.43415:
	ldi	＄r5, ＄r3, 1
	beq	＄r5, ＄r29, bne_else.43417
	mvhi	＄r4, 0
	mvlo	＄r4, 2
	beq	＄r5, ＄r4, bne_else.43419
	j	bne_cont.43420
bne_else.43419:
	slli	＄r4, ＄r6, 2
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r12, ＄r4, ＄r28
	ldi	＄r13, ＄r0, 160
	fsub	＄f9, ＄f17, ＄f0
	ldi	＄r3, ＄r3, 4
	fldi	＄f6, ＄r0, 513
	fldi	＄f7, ＄r3, 0
	fmul	＄f2, ＄f6, ＄f7
	fldi	＄f3, ＄r0, 514
	fldi	＄f1, ＄r3, 1
	fmul	＄f0, ＄f3, ＄f1
	fadd	＄f5, ＄f2, ＄f0
	fldi	＄f4, ＄r0, 515
	fldi	＄f2, ＄r3, 2
	fmul	＄f0, ＄f4, ＄f2
	fadd	＄f0, ＄f5, ＄f0
	fmul	＄f5, ＄f30, ＄f7
	fmul	＄f5, ＄f5, ＄f0
	fsub	＄f5, ＄f5, ＄f6
	fmul	＄f1, ＄f30, ＄f1
	fmul	＄f1, ＄f1, ＄f0
	fsub	＄f3, ＄f1, ＄f3
	fmul	＄f1, ＄f30, ＄f2
	fmul	＄f0, ＄f1, ＄f0
	fsub	＄f1, ＄f0, ＄f4
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 13
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 13
	add	＄r1, ＄r1, ＄r28
	mov	＄r6, ＄r3
	ldi	＄r3, ＄r0, 583
	mov	＄r4, ＄r6
	mvhi	＄r28, 0
	mvlo	＄r28, 13
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 13
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r3, ＄r4, 1
	sti	＄r6, ＄r4, 0
	fsti	＄f5, ＄r6, 0
	fsti	＄f3, ＄r6, 1
	fsti	＄f1, ＄r6, 2
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	sti	＄r4, ＄r1, -12
	mov	＄r7, ＄r4
	mvhi	＄r28, 0
	mvlo	＄r28, 14
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 14
	add	＄r1, ＄r1, ＄r28
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r2, ＄r2, ＄r28
	fsti	＄f9, ＄r3, 2
	ldi	＄r4, ＄r1, -12
	sti	＄r4, ＄r3, 1
	sti	＄r12, ＄r3, 0
	slli	＄r4, ＄r13, 0
	sti	＄r3, ＄r4, 161
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r3, ＄r13, ＄r28
	sti	＄r3, ＄r0, 160
bne_cont.43420:
	j	bne_cont.43418
bne_else.43417:
	slli	＄r12, ＄r6, 2
	ldi	＄r13, ＄r0, 160
	fldi	＄f0, ＄r4, 0
	fsub	＄f12, ＄f17, ＄f0
	fldi	＄f1, ＄r0, 513
	fneg	＄f11, ＄f1
	fldi	＄f10, ＄r0, 514
	fneg	＄f10, ＄f10
	fldi	＄f9, ＄r0, 515
	fneg	＄f9, ＄f9
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r14, ＄r12, ＄r28
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 13
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 13
	add	＄r1, ＄r1, ＄r28
	mov	＄r6, ＄r3
	ldi	＄r3, ＄r0, 583
	mov	＄r4, ＄r6
	mvhi	＄r28, 0
	mvlo	＄r28, 13
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 13
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r3, ＄r4, 1
	sti	＄r6, ＄r4, 0
	fsti	＄f1, ＄r6, 0
	fsti	＄f10, ＄r6, 1
	fsti	＄f9, ＄r6, 2
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	sti	＄r4, ＄r1, -12
	mov	＄r7, ＄r4
	mvhi	＄r28, 0
	mvlo	＄r28, 14
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 14
	add	＄r1, ＄r1, ＄r28
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r2, ＄r2, ＄r28
	fsti	＄f12, ＄r3, 2
	ldi	＄r4, ＄r1, -12
	sti	＄r4, ＄r3, 1
	sti	＄r14, ＄r3, 0
	slli	＄r4, ＄r13, 0
	sti	＄r3, ＄r4, 161
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r15, ＄r13, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r14, ＄r12, ＄r28
	fldi	＄f1, ＄r0, 514
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 14
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 14
	add	＄r1, ＄r1, ＄r28
	mov	＄r6, ＄r3
	ldi	＄r3, ＄r0, 583
	mov	＄r4, ＄r6
	mvhi	＄r28, 0
	mvlo	＄r28, 14
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 14
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r3, ＄r4, 1
	sti	＄r6, ＄r4, 0
	fsti	＄f11, ＄r6, 0
	fsti	＄f1, ＄r6, 1
	fsti	＄f9, ＄r6, 2
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	sti	＄r4, ＄r1, -13
	mov	＄r7, ＄r4
	mvhi	＄r28, 0
	mvlo	＄r28, 15
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 15
	add	＄r1, ＄r1, ＄r28
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r2, ＄r2, ＄r28
	fsti	＄f12, ＄r3, 2
	ldi	＄r4, ＄r1, -13
	sti	＄r4, ＄r3, 1
	sti	＄r14, ＄r3, 0
	slli	＄r4, ＄r15, 0
	sti	＄r3, ＄r4, 161
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r14, ＄r13, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r12, ＄r12, ＄r28
	fldi	＄f1, ＄r0, 515
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 15
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 15
	add	＄r1, ＄r1, ＄r28
	mov	＄r6, ＄r3
	ldi	＄r3, ＄r0, 583
	mov	＄r4, ＄r6
	mvhi	＄r28, 0
	mvlo	＄r28, 15
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 15
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r3, ＄r4, 1
	sti	＄r6, ＄r4, 0
	fsti	＄f11, ＄r6, 0
	fsti	＄f10, ＄r6, 1
	fsti	＄f1, ＄r6, 2
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	sti	＄r4, ＄r1, -14
	mov	＄r7, ＄r4
	mvhi	＄r28, 0
	mvlo	＄r28, 16
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 16
	add	＄r1, ＄r1, ＄r28
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r2, ＄r2, ＄r28
	fsti	＄f12, ＄r3, 2
	ldi	＄r4, ＄r1, -14
	sti	＄r4, ＄r3, 1
	sti	＄r12, ＄r3, 0
	slli	＄r4, ＄r14, 0
	sti	＄r3, ＄r4, 161
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r3, ＄r13, ＄r28
	sti	＄r3, ＄r0, 160
bne_cont.43418:
fbge_cont.43416:
bne_cont.43414:
	j	bge_cont.43412
bge_else.43411:
bge_cont.43412:
	mvhi	＄r27, 0
	mvlo	＄r27, 0
	fldi	＄f3, ＄r0, 437
	ldi	＄r3, ＄r0, 439
	sub	＄r3, ＄r0, ＄r3
	mvhi	＄r28, 0
	mvlo	＄r28, 13
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_float_of_int
	mvhi	＄r28, 0
	mvlo	＄r28, 13
	add	＄r1, ＄r1, ＄r28
	fmul	＄f0, ＄f3, ＄f0
	fldi	＄f1, ＄r0, 425
	fmul	＄f2, ＄f0, ＄f1
	fldi	＄f1, ＄r0, 422
	fadd	＄f13, ＄f2, ＄f1
	fldi	＄f1, ＄r0, 426
	fmul	＄f2, ＄f0, ＄f1
	fldi	＄f1, ＄r0, 423
	fadd	＄f12, ＄f2, ＄f1
	fldi	＄f1, ＄r0, 427
	fmul	＄f1, ＄f0, ＄f1
	fldi	＄f0, ＄r0, 424
	fadd	＄f11, ＄f1, ＄f0
	ldi	＄r3, ＄r0, 440
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r26, ＄r3, ＄r28
	ldi	＄r31, ＄r1, -11
	mvhi	＄r28, 0
	mvlo	＄r28, 13
	sub	＄r1, ＄r1, ＄r28
	call	pretrace_pixels.3017
	mvhi	＄r28, 0
	mvlo	＄r28, 13
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r6, 0
	mvlo	＄r6, 0
	mvhi	＄r27, 0
	mvlo	＄r27, 2
	ldi	＄r3, ＄r0, 441
	blt	＄r6, ＄r3, ble_else.43421
	j	ble_cont.43422
ble_else.43421:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r3, ＄r3, ＄r28
	sti	＄r6, ＄r1, -12
	blt	＄r6, ＄r3, ble_else.43423
	j	ble_cont.43424
ble_else.43423:
	mvhi	＄r4, 0
	mvlo	＄r4, 1
	fldi	＄f3, ＄r0, 437
	ldi	＄r3, ＄r0, 439
	sub	＄r3, ＄r4, ＄r3
	mvhi	＄r28, 0
	mvlo	＄r28, 14
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_float_of_int
	mvhi	＄r28, 0
	mvlo	＄r28, 14
	add	＄r1, ＄r1, ＄r28
	fmul	＄f0, ＄f3, ＄f0
	fldi	＄f1, ＄r0, 425
	fmul	＄f2, ＄f0, ＄f1
	fldi	＄f1, ＄r0, 422
	fadd	＄f13, ＄f2, ＄f1
	fldi	＄f1, ＄r0, 426
	fmul	＄f2, ＄f0, ＄f1
	fldi	＄f1, ＄r0, 423
	fadd	＄f12, ＄f2, ＄f1
	fldi	＄f1, ＄r0, 427
	fmul	＄f1, ＄f0, ＄f1
	fldi	＄f0, ＄r0, 424
	fadd	＄f11, ＄f1, ＄f0
	ldi	＄r3, ＄r0, 440
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r26, ＄r3, ＄r28
	ldi	＄r22, ＄r1, -10
	mov	＄r31, ＄r22
	mvhi	＄r28, 0
	mvlo	＄r28, 14
	sub	＄r1, ＄r1, ＄r28
	call	pretrace_pixels.3017
	mvhi	＄r28, 0
	mvlo	＄r28, 14
	add	＄r1, ＄r1, ＄r28
ble_cont.43424:
	mvhi	＄r25, 0
	mvlo	＄r25, 0
	ldi	＄r6, ＄r1, -12
	ldi	＄r23, ＄r1, -9
	ldi	＄r31, ＄r1, -11
	ldi	＄r22, ＄r1, -10
	mov	＄r27, ＄r31
	mov	＄r26, ＄r6
	mov	＄r31, ＄r23
	mvhi	＄r28, 0
	mvlo	＄r28, 14
	sub	＄r1, ＄r1, ＄r28
	call	scan_pixel.3028
	mvhi	＄r28, 0
	mvlo	＄r28, 14
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r26, 0
	mvlo	＄r26, 1
	mvhi	＄r3, 0
	mvlo	＄r3, 4
	ldi	＄r31, ＄r1, -11
	ldi	＄r22, ＄r1, -10
	ldi	＄r23, ＄r1, -9
	mov	＄r27, ＄r22
	mov	＄r22, ＄r23
	mvhi	＄r28, 0
	mvlo	＄r28, 14
	sub	＄r1, ＄r1, ＄r28
	call	scan_line.3034
	mvhi	＄r28, 0
	mvlo	＄r28, 14
	add	＄r1, ＄r1, ＄r28
ble_cont.43422:
	mvhi	＄r0, 0
	mvlo	＄r0, 0
	halt

#---------------------------------------------------------------------
# args = []
# fargs = [＄f1]
# ret type = Float
#---------------------------------------------------------------------
sin_sub.2547:
	fblt	＄f29, ＄f1, fbge_else.43425
	fblt	＄f1, ＄f16, fbge_else.43426
	fmov	＄f0, ＄f1
	return
fbge_else.43426:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43427
	fblt	＄f1, ＄f16, fbge_else.43428
	fmov	＄f0, ＄f1
	return
fbge_else.43428:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43429
	fblt	＄f1, ＄f16, fbge_else.43430
	fmov	＄f0, ＄f1
	return
fbge_else.43430:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43431
	fblt	＄f1, ＄f16, fbge_else.43432
	fmov	＄f0, ＄f1
	return
fbge_else.43432:
	fadd	＄f1, ＄f1, ＄f29
	j	sin_sub.2547
fbge_else.43431:
	fsub	＄f1, ＄f1, ＄f29
	j	sin_sub.2547
fbge_else.43429:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43433
	fblt	＄f1, ＄f16, fbge_else.43434
	fmov	＄f0, ＄f1
	return
fbge_else.43434:
	fadd	＄f1, ＄f1, ＄f29
	j	sin_sub.2547
fbge_else.43433:
	fsub	＄f1, ＄f1, ＄f29
	j	sin_sub.2547
fbge_else.43427:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43435
	fblt	＄f1, ＄f16, fbge_else.43436
	fmov	＄f0, ＄f1
	return
fbge_else.43436:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43437
	fblt	＄f1, ＄f16, fbge_else.43438
	fmov	＄f0, ＄f1
	return
fbge_else.43438:
	fadd	＄f1, ＄f1, ＄f29
	j	sin_sub.2547
fbge_else.43437:
	fsub	＄f1, ＄f1, ＄f29
	j	sin_sub.2547
fbge_else.43435:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43439
	fblt	＄f1, ＄f16, fbge_else.43440
	fmov	＄f0, ＄f1
	return
fbge_else.43440:
	fadd	＄f1, ＄f1, ＄f29
	j	sin_sub.2547
fbge_else.43439:
	fsub	＄f1, ＄f1, ＄f29
	j	sin_sub.2547
fbge_else.43425:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43441
	fblt	＄f1, ＄f16, fbge_else.43442
	fmov	＄f0, ＄f1
	return
fbge_else.43442:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43443
	fblt	＄f1, ＄f16, fbge_else.43444
	fmov	＄f0, ＄f1
	return
fbge_else.43444:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43445
	fblt	＄f1, ＄f16, fbge_else.43446
	fmov	＄f0, ＄f1
	return
fbge_else.43446:
	fadd	＄f1, ＄f1, ＄f29
	j	sin_sub.2547
fbge_else.43445:
	fsub	＄f1, ＄f1, ＄f29
	j	sin_sub.2547
fbge_else.43443:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43447
	fblt	＄f1, ＄f16, fbge_else.43448
	fmov	＄f0, ＄f1
	return
fbge_else.43448:
	fadd	＄f1, ＄f1, ＄f29
	j	sin_sub.2547
fbge_else.43447:
	fsub	＄f1, ＄f1, ＄f29
	j	sin_sub.2547
fbge_else.43441:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43449
	fblt	＄f1, ＄f16, fbge_else.43450
	fmov	＄f0, ＄f1
	return
fbge_else.43450:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43451
	fblt	＄f1, ＄f16, fbge_else.43452
	fmov	＄f0, ＄f1
	return
fbge_else.43452:
	fadd	＄f1, ＄f1, ＄f29
	j	sin_sub.2547
fbge_else.43451:
	fsub	＄f1, ＄f1, ＄f29
	j	sin_sub.2547
fbge_else.43449:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43453
	fblt	＄f1, ＄f16, fbge_else.43454
	fmov	＄f0, ＄f1
	return
fbge_else.43454:
	fadd	＄f1, ＄f1, ＄f29
	j	sin_sub.2547
fbge_else.43453:
	fsub	＄f1, ＄f1, ＄f29
	j	sin_sub.2547

#---------------------------------------------------------------------
# args = [＄r4, ＄r5]
# fargs = []
# ret type = Int
#---------------------------------------------------------------------
mul_sub.2569:
	beq	＄r5, ＄r0, bne_else.43455
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43456
	slli	＄r3, ＄r4, 1
	srai	＄r6, ＄r5, 1
	sti	＄r4, ＄r1, 0
	beq	＄r6, ＄r0, bne_else.43457
	srai	＄r5, ＄r6, 1
	slli	＄r5, ＄r5, 1
	sub	＄r5, ＄r6, ＄r5
	beq	＄r5, ＄r0, bne_else.43459
	slli	＄r8, ＄r3, 1
	srai	＄r6, ＄r6, 1
	sti	＄r3, ＄r1, -1
	beq	＄r6, ＄r0, bne_else.43461
	srai	＄r5, ＄r6, 1
	slli	＄r5, ＄r5, 1
	sub	＄r5, ＄r6, ＄r5
	beq	＄r5, ＄r0, bne_else.43463
	slli	＄r9, ＄r8, 1
	srai	＄r7, ＄r6, 1
	sti	＄r8, ＄r1, -2
	beq	＄r7, ＄r0, bne_else.43465
	srai	＄r5, ＄r7, 1
	slli	＄r5, ＄r5, 1
	sub	＄r5, ＄r7, ＄r5
	beq	＄r5, ＄r0, bne_else.43467
	slli	＄r6, ＄r9, 1
	srai	＄r5, ＄r7, 1
	sti	＄r9, ＄r1, -3
	mov	＄r4, ＄r6
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	add	＄r1, ＄r1, ＄r28
	mov	＄r5, ＄r3
	ldi	＄r9, ＄r1, -3
	add	＄r5, ＄r5, ＄r9
	j	bne_cont.43468
bne_else.43467:
	slli	＄r6, ＄r9, 1
	srai	＄r5, ＄r7, 1
	mov	＄r4, ＄r6
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	add	＄r1, ＄r1, ＄r28
	mov	＄r5, ＄r3
bne_cont.43468:
	j	bne_cont.43466
bne_else.43465:
	mvhi	＄r5, 0
	mvlo	＄r5, 0
bne_cont.43466:
	ldi	＄r8, ＄r1, -2
	add	＄r5, ＄r5, ＄r8
	j	bne_cont.43464
bne_else.43463:
	slli	＄r8, ＄r8, 1
	srai	＄r7, ＄r6, 1
	beq	＄r7, ＄r0, bne_else.43469
	srai	＄r5, ＄r7, 1
	slli	＄r5, ＄r5, 1
	sub	＄r5, ＄r7, ＄r5
	beq	＄r5, ＄r0, bne_else.43471
	slli	＄r6, ＄r8, 1
	srai	＄r5, ＄r7, 1
	sti	＄r8, ＄r1, -2
	mov	＄r4, ＄r6
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	add	＄r1, ＄r1, ＄r28
	mov	＄r5, ＄r3
	ldi	＄r8, ＄r1, -2
	add	＄r5, ＄r5, ＄r8
	j	bne_cont.43472
bne_else.43471:
	slli	＄r6, ＄r8, 1
	srai	＄r5, ＄r7, 1
	mov	＄r4, ＄r6
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	mov	＄r5, ＄r3
bne_cont.43472:
	j	bne_cont.43470
bne_else.43469:
	mvhi	＄r5, 0
	mvlo	＄r5, 0
bne_cont.43470:
bne_cont.43464:
	j	bne_cont.43462
bne_else.43461:
	mvhi	＄r5, 0
	mvlo	＄r5, 0
bne_cont.43462:
	ldi	＄r3, ＄r1, -1
	add	＄r5, ＄r5, ＄r3
	j	bne_cont.43460
bne_else.43459:
	slli	＄r7, ＄r3, 1
	srai	＄r3, ＄r6, 1
	beq	＄r3, ＄r0, bne_else.43473
	srai	＄r5, ＄r3, 1
	slli	＄r5, ＄r5, 1
	sub	＄r5, ＄r3, ＄r5
	beq	＄r5, ＄r0, bne_else.43475
	slli	＄r6, ＄r7, 1
	srai	＄r5, ＄r3, 1
	sti	＄r7, ＄r1, -1
	beq	＄r5, ＄r0, bne_else.43477
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43479
	slli	＄r3, ＄r6, 1
	srai	＄r5, ＄r5, 1
	sti	＄r6, ＄r1, -2
	mov	＄r4, ＄r3
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	add	＄r1, ＄r1, ＄r28
	ldi	＄r6, ＄r1, -2
	add	＄r3, ＄r3, ＄r6
	j	bne_cont.43480
bne_else.43479:
	slli	＄r3, ＄r6, 1
	srai	＄r5, ＄r5, 1
	mov	＄r4, ＄r3
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
bne_cont.43480:
	j	bne_cont.43478
bne_else.43477:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43478:
	ldi	＄r7, ＄r1, -1
	add	＄r5, ＄r3, ＄r7
	j	bne_cont.43476
bne_else.43475:
	slli	＄r7, ＄r7, 1
	srai	＄r6, ＄r3, 1
	beq	＄r6, ＄r0, bne_else.43481
	srai	＄r3, ＄r6, 1
	slli	＄r3, ＄r3, 1
	sub	＄r5, ＄r6, ＄r3
	beq	＄r5, ＄r0, bne_else.43483
	slli	＄r3, ＄r7, 1
	srai	＄r5, ＄r6, 1
	sti	＄r7, ＄r1, -1
	mov	＄r4, ＄r3
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	ldi	＄r7, ＄r1, -1
	add	＄r5, ＄r3, ＄r7
	j	bne_cont.43484
bne_else.43483:
	slli	＄r3, ＄r7, 1
	srai	＄r5, ＄r6, 1
	mov	＄r4, ＄r3
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mov	＄r5, ＄r3
bne_cont.43484:
	j	bne_cont.43482
bne_else.43481:
	mvhi	＄r5, 0
	mvlo	＄r5, 0
bne_cont.43482:
bne_cont.43476:
	j	bne_cont.43474
bne_else.43473:
	mvhi	＄r5, 0
	mvlo	＄r5, 0
bne_cont.43474:
bne_cont.43460:
	j	bne_cont.43458
bne_else.43457:
	mvhi	＄r5, 0
	mvlo	＄r5, 0
bne_cont.43458:
	ldi	＄r4, ＄r1, 0
	add	＄r3, ＄r5, ＄r4
	return
bne_else.43456:
	slli	＄r4, ＄r4, 1
	srai	＄r5, ＄r5, 1
	beq	＄r5, ＄r0, bne_else.43485
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43486
	slli	＄r6, ＄r4, 1
	srai	＄r5, ＄r5, 1
	sti	＄r4, ＄r1, 0
	beq	＄r5, ＄r0, bne_else.43487
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43489
	slli	＄r7, ＄r6, 1
	srai	＄r5, ＄r5, 1
	sti	＄r6, ＄r1, -1
	beq	＄r5, ＄r0, bne_else.43491
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43493
	slli	＄r3, ＄r7, 1
	srai	＄r5, ＄r5, 1
	sti	＄r7, ＄r1, -2
	mov	＄r4, ＄r3
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	add	＄r1, ＄r1, ＄r28
	ldi	＄r7, ＄r1, -2
	add	＄r3, ＄r3, ＄r7
	j	bne_cont.43494
bne_else.43493:
	slli	＄r3, ＄r7, 1
	srai	＄r5, ＄r5, 1
	mov	＄r4, ＄r3
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
bne_cont.43494:
	j	bne_cont.43492
bne_else.43491:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43492:
	ldi	＄r6, ＄r1, -1
	add	＄r3, ＄r3, ＄r6
	j	bne_cont.43490
bne_else.43489:
	slli	＄r6, ＄r6, 1
	srai	＄r5, ＄r5, 1
	beq	＄r5, ＄r0, bne_else.43495
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43497
	slli	＄r3, ＄r6, 1
	srai	＄r5, ＄r5, 1
	sti	＄r6, ＄r1, -1
	mov	＄r4, ＄r3
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	ldi	＄r6, ＄r1, -1
	add	＄r3, ＄r3, ＄r6
	j	bne_cont.43498
bne_else.43497:
	slli	＄r3, ＄r6, 1
	srai	＄r5, ＄r5, 1
	mov	＄r4, ＄r3
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
bne_cont.43498:
	j	bne_cont.43496
bne_else.43495:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43496:
bne_cont.43490:
	j	bne_cont.43488
bne_else.43487:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43488:
	ldi	＄r4, ＄r1, 0
	add	＄r3, ＄r3, ＄r4
	return
bne_else.43486:
	slli	＄r7, ＄r4, 1
	srai	＄r4, ＄r5, 1
	beq	＄r4, ＄r0, bne_else.43499
	srai	＄r3, ＄r4, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r4, ＄r3
	beq	＄r3, ＄r0, bne_else.43500
	slli	＄r6, ＄r7, 1
	srai	＄r5, ＄r4, 1
	sti	＄r7, ＄r1, 0
	beq	＄r5, ＄r0, bne_else.43501
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43503
	slli	＄r4, ＄r6, 1
	srai	＄r5, ＄r5, 1
	sti	＄r6, ＄r1, -1
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	ldi	＄r6, ＄r1, -1
	add	＄r3, ＄r3, ＄r6
	j	bne_cont.43504
bne_else.43503:
	slli	＄r4, ＄r6, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
bne_cont.43504:
	j	bne_cont.43502
bne_else.43501:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43502:
	ldi	＄r7, ＄r1, 0
	add	＄r3, ＄r3, ＄r7
	return
bne_else.43500:
	slli	＄r6, ＄r7, 1
	srai	＄r5, ＄r4, 1
	beq	＄r5, ＄r0, bne_else.43505
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43506
	slli	＄r4, ＄r6, 1
	srai	＄r5, ＄r5, 1
	sti	＄r6, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r6, ＄r1, 0
	add	＄r3, ＄r3, ＄r6
	return
bne_else.43506:
	slli	＄r4, ＄r6, 1
	srai	＄r5, ＄r5, 1
	j	mul_sub.2569
bne_else.43505:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	return
bne_else.43499:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	return
bne_else.43485:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	return
bne_else.43455:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	return

#---------------------------------------------------------------------
# args = [＄r14, ＄r12, ＄r15, ＄r16]
# fargs = []
# ret type = Int
#---------------------------------------------------------------------
div_binary_search.2575:
	add	＄r3, ＄r15, ＄r16
	srai	＄r13, ＄r3, 1
	blt	＄r12, ＄r0, bge_else.43507
	beq	＄r12, ＄r0, bne_else.43509
	srai	＄r3, ＄r12, 1
	slli	＄r3, ＄r3, 1
	sub	＄r4, ＄r12, ＄r3
	beq	＄r4, ＄r0, bne_else.43511
	slli	＄r10, ＄r13, 1
	srai	＄r4, ＄r12, 1
	beq	＄r4, ＄r0, bne_else.43513
	srai	＄r3, ＄r4, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r4, ＄r3
	beq	＄r3, ＄r0, bne_else.43515
	slli	＄r11, ＄r10, 1
	srai	＄r4, ＄r4, 1
	beq	＄r4, ＄r0, bne_else.43517
	srai	＄r3, ＄r4, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r4, ＄r3
	beq	＄r3, ＄r0, bne_else.43519
	slli	＄r17, ＄r11, 1
	srai	＄r5, ＄r4, 1
	beq	＄r5, ＄r0, bne_else.43521
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43523
	slli	＄r4, ＄r17, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r17
	j	bne_cont.43524
bne_else.43523:
	slli	＄r4, ＄r17, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43524:
	j	bne_cont.43522
bne_else.43521:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43522:
	add	＄r3, ＄r3, ＄r11
	j	bne_cont.43520
bne_else.43519:
	slli	＄r11, ＄r11, 1
	srai	＄r5, ＄r4, 1
	beq	＄r5, ＄r0, bne_else.43525
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43527
	slli	＄r4, ＄r11, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r11
	j	bne_cont.43528
bne_else.43527:
	slli	＄r4, ＄r11, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43528:
	j	bne_cont.43526
bne_else.43525:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43526:
bne_cont.43520:
	j	bne_cont.43518
bne_else.43517:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43518:
	add	＄r3, ＄r3, ＄r10
	j	bne_cont.43516
bne_else.43515:
	slli	＄r11, ＄r10, 1
	srai	＄r4, ＄r4, 1
	beq	＄r4, ＄r0, bne_else.43529
	srai	＄r3, ＄r4, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r4, ＄r3
	beq	＄r3, ＄r0, bne_else.43531
	slli	＄r10, ＄r11, 1
	srai	＄r5, ＄r4, 1
	beq	＄r5, ＄r0, bne_else.43533
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43535
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r10
	j	bne_cont.43536
bne_else.43535:
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43536:
	j	bne_cont.43534
bne_else.43533:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43534:
	add	＄r3, ＄r3, ＄r11
	j	bne_cont.43532
bne_else.43531:
	slli	＄r10, ＄r11, 1
	srai	＄r5, ＄r4, 1
	beq	＄r5, ＄r0, bne_else.43537
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43539
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r10
	j	bne_cont.43540
bne_else.43539:
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43540:
	j	bne_cont.43538
bne_else.43537:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43538:
bne_cont.43532:
	j	bne_cont.43530
bne_else.43529:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43530:
bne_cont.43516:
	j	bne_cont.43514
bne_else.43513:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43514:
	add	＄r4, ＄r3, ＄r13
	j	bne_cont.43512
bne_else.43511:
	slli	＄r10, ＄r13, 1
	srai	＄r3, ＄r12, 1
	beq	＄r3, ＄r0, bne_else.43541
	srai	＄r4, ＄r3, 1
	slli	＄r4, ＄r4, 1
	sub	＄r4, ＄r3, ＄r4
	beq	＄r4, ＄r0, bne_else.43543
	slli	＄r11, ＄r10, 1
	srai	＄r4, ＄r3, 1
	beq	＄r4, ＄r0, bne_else.43545
	srai	＄r3, ＄r4, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r4, ＄r3
	beq	＄r3, ＄r0, bne_else.43547
	slli	＄r17, ＄r11, 1
	srai	＄r5, ＄r4, 1
	beq	＄r5, ＄r0, bne_else.43549
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43551
	slli	＄r4, ＄r17, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r17
	j	bne_cont.43552
bne_else.43551:
	slli	＄r4, ＄r17, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43552:
	j	bne_cont.43550
bne_else.43549:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43550:
	add	＄r3, ＄r3, ＄r11
	j	bne_cont.43548
bne_else.43547:
	slli	＄r11, ＄r11, 1
	srai	＄r5, ＄r4, 1
	beq	＄r5, ＄r0, bne_else.43553
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43555
	slli	＄r4, ＄r11, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r11
	j	bne_cont.43556
bne_else.43555:
	slli	＄r4, ＄r11, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43556:
	j	bne_cont.43554
bne_else.43553:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43554:
bne_cont.43548:
	j	bne_cont.43546
bne_else.43545:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43546:
	add	＄r4, ＄r3, ＄r10
	j	bne_cont.43544
bne_else.43543:
	slli	＄r11, ＄r10, 1
	srai	＄r3, ＄r3, 1
	beq	＄r3, ＄r0, bne_else.43557
	srai	＄r4, ＄r3, 1
	slli	＄r4, ＄r4, 1
	sub	＄r4, ＄r3, ＄r4
	beq	＄r4, ＄r0, bne_else.43559
	slli	＄r10, ＄r11, 1
	srai	＄r5, ＄r3, 1
	beq	＄r5, ＄r0, bne_else.43561
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43563
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r10
	j	bne_cont.43564
bne_else.43563:
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43564:
	j	bne_cont.43562
bne_else.43561:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43562:
	add	＄r4, ＄r3, ＄r11
	j	bne_cont.43560
bne_else.43559:
	slli	＄r10, ＄r11, 1
	srai	＄r3, ＄r3, 1
	beq	＄r3, ＄r0, bne_else.43565
	srai	＄r4, ＄r3, 1
	slli	＄r4, ＄r4, 1
	sub	＄r4, ＄r3, ＄r4
	beq	＄r4, ＄r0, bne_else.43567
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r3, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r4, ＄r3, ＄r10
	j	bne_cont.43568
bne_else.43567:
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r3, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
bne_cont.43568:
	j	bne_cont.43566
bne_else.43565:
	mvhi	＄r4, 0
	mvlo	＄r4, 0
bne_cont.43566:
bne_cont.43560:
	j	bne_cont.43558
bne_else.43557:
	mvhi	＄r4, 0
	mvlo	＄r4, 0
bne_cont.43558:
bne_cont.43544:
	j	bne_cont.43542
bne_else.43541:
	mvhi	＄r4, 0
	mvlo	＄r4, 0
bne_cont.43542:
bne_cont.43512:
	j	bne_cont.43510
bne_else.43509:
	mvhi	＄r4, 0
	mvlo	＄r4, 0
bne_cont.43510:
	j	bge_cont.43508
bge_else.43507:
	sub	＄r11, ＄r0, ＄r13
	sub	＄r5, ＄r0, ＄r12
	beq	＄r5, ＄r0, bne_else.43569
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r4, ＄r5, ＄r3
	beq	＄r4, ＄r0, bne_else.43571
	slli	＄r10, ＄r11, 1
	srai	＄r4, ＄r5, 1
	beq	＄r4, ＄r0, bne_else.43573
	srai	＄r3, ＄r4, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r4, ＄r3
	beq	＄r3, ＄r0, bne_else.43575
	slli	＄r17, ＄r10, 1
	srai	＄r4, ＄r4, 1
	beq	＄r4, ＄r0, bne_else.43577
	srai	＄r3, ＄r4, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r4, ＄r3
	beq	＄r3, ＄r0, bne_else.43579
	slli	＄r18, ＄r17, 1
	srai	＄r5, ＄r4, 1
	beq	＄r5, ＄r0, bne_else.43581
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43583
	slli	＄r4, ＄r18, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r18
	j	bne_cont.43584
bne_else.43583:
	slli	＄r4, ＄r18, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43584:
	j	bne_cont.43582
bne_else.43581:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43582:
	add	＄r3, ＄r3, ＄r17
	j	bne_cont.43580
bne_else.43579:
	slli	＄r17, ＄r17, 1
	srai	＄r5, ＄r4, 1
	beq	＄r5, ＄r0, bne_else.43585
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43587
	slli	＄r4, ＄r17, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r17
	j	bne_cont.43588
bne_else.43587:
	slli	＄r4, ＄r17, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43588:
	j	bne_cont.43586
bne_else.43585:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43586:
bne_cont.43580:
	j	bne_cont.43578
bne_else.43577:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43578:
	add	＄r3, ＄r3, ＄r10
	j	bne_cont.43576
bne_else.43575:
	slli	＄r17, ＄r10, 1
	srai	＄r4, ＄r4, 1
	beq	＄r4, ＄r0, bne_else.43589
	srai	＄r3, ＄r4, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r4, ＄r3
	beq	＄r3, ＄r0, bne_else.43591
	slli	＄r10, ＄r17, 1
	srai	＄r5, ＄r4, 1
	beq	＄r5, ＄r0, bne_else.43593
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43595
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r10
	j	bne_cont.43596
bne_else.43595:
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43596:
	j	bne_cont.43594
bne_else.43593:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43594:
	add	＄r3, ＄r3, ＄r17
	j	bne_cont.43592
bne_else.43591:
	slli	＄r10, ＄r17, 1
	srai	＄r5, ＄r4, 1
	beq	＄r5, ＄r0, bne_else.43597
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43599
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r10
	j	bne_cont.43600
bne_else.43599:
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43600:
	j	bne_cont.43598
bne_else.43597:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43598:
bne_cont.43592:
	j	bne_cont.43590
bne_else.43589:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43590:
bne_cont.43576:
	j	bne_cont.43574
bne_else.43573:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43574:
	add	＄r4, ＄r3, ＄r11
	j	bne_cont.43572
bne_else.43571:
	slli	＄r10, ＄r11, 1
	srai	＄r3, ＄r5, 1
	beq	＄r3, ＄r0, bne_else.43601
	srai	＄r4, ＄r3, 1
	slli	＄r4, ＄r4, 1
	sub	＄r4, ＄r3, ＄r4
	beq	＄r4, ＄r0, bne_else.43603
	slli	＄r11, ＄r10, 1
	srai	＄r4, ＄r3, 1
	beq	＄r4, ＄r0, bne_else.43605
	srai	＄r3, ＄r4, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r4, ＄r3
	beq	＄r3, ＄r0, bne_else.43607
	slli	＄r17, ＄r11, 1
	srai	＄r5, ＄r4, 1
	beq	＄r5, ＄r0, bne_else.43609
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43611
	slli	＄r4, ＄r17, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r17
	j	bne_cont.43612
bne_else.43611:
	slli	＄r4, ＄r17, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43612:
	j	bne_cont.43610
bne_else.43609:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43610:
	add	＄r3, ＄r3, ＄r11
	j	bne_cont.43608
bne_else.43607:
	slli	＄r11, ＄r11, 1
	srai	＄r5, ＄r4, 1
	beq	＄r5, ＄r0, bne_else.43613
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43615
	slli	＄r4, ＄r11, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r11
	j	bne_cont.43616
bne_else.43615:
	slli	＄r4, ＄r11, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43616:
	j	bne_cont.43614
bne_else.43613:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43614:
bne_cont.43608:
	j	bne_cont.43606
bne_else.43605:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43606:
	add	＄r4, ＄r3, ＄r10
	j	bne_cont.43604
bne_else.43603:
	slli	＄r11, ＄r10, 1
	srai	＄r3, ＄r3, 1
	beq	＄r3, ＄r0, bne_else.43617
	srai	＄r4, ＄r3, 1
	slli	＄r4, ＄r4, 1
	sub	＄r4, ＄r3, ＄r4
	beq	＄r4, ＄r0, bne_else.43619
	slli	＄r10, ＄r11, 1
	srai	＄r5, ＄r3, 1
	beq	＄r5, ＄r0, bne_else.43621
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43623
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r10
	j	bne_cont.43624
bne_else.43623:
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43624:
	j	bne_cont.43622
bne_else.43621:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43622:
	add	＄r4, ＄r3, ＄r11
	j	bne_cont.43620
bne_else.43619:
	slli	＄r10, ＄r11, 1
	srai	＄r3, ＄r3, 1
	beq	＄r3, ＄r0, bne_else.43625
	srai	＄r4, ＄r3, 1
	slli	＄r4, ＄r4, 1
	sub	＄r4, ＄r3, ＄r4
	beq	＄r4, ＄r0, bne_else.43627
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r3, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r4, ＄r3, ＄r10
	j	bne_cont.43628
bne_else.43627:
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r3, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
bne_cont.43628:
	j	bne_cont.43626
bne_else.43625:
	mvhi	＄r4, 0
	mvlo	＄r4, 0
bne_cont.43626:
bne_cont.43620:
	j	bne_cont.43618
bne_else.43617:
	mvhi	＄r4, 0
	mvlo	＄r4, 0
bne_cont.43618:
bne_cont.43604:
	j	bne_cont.43602
bne_else.43601:
	mvhi	＄r4, 0
	mvlo	＄r4, 0
bne_cont.43602:
bne_cont.43572:
	j	bne_cont.43570
bne_else.43569:
	mvhi	＄r4, 0
	mvlo	＄r4, 0
bne_cont.43570:
bge_cont.43508:
	sub	＄r3, ＄r16, ＄r15
	blt	＄r29, ＄r3, ble_else.43629
	mov	＄r3, ＄r15
	return
ble_else.43629:
	blt	＄r4, ＄r14, ble_else.43630
	beq	＄r4, ＄r14, bne_else.43631
	add	＄r3, ＄r15, ＄r13
	srai	＄r11, ＄r3, 1
	blt	＄r12, ＄r0, bge_else.43632
	beq	＄r12, ＄r0, bne_else.43634
	srai	＄r3, ＄r12, 1
	slli	＄r3, ＄r3, 1
	sub	＄r4, ＄r12, ＄r3
	beq	＄r4, ＄r0, bne_else.43636
	slli	＄r10, ＄r11, 1
	srai	＄r4, ＄r12, 1
	beq	＄r4, ＄r0, bne_else.43638
	srai	＄r3, ＄r4, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r4, ＄r3
	beq	＄r3, ＄r0, bne_else.43640
	slli	＄r16, ＄r10, 1
	srai	＄r5, ＄r4, 1
	beq	＄r5, ＄r0, bne_else.43642
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43644
	slli	＄r4, ＄r16, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r16
	j	bne_cont.43645
bne_else.43644:
	slli	＄r4, ＄r16, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43645:
	j	bne_cont.43643
bne_else.43642:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43643:
	add	＄r3, ＄r3, ＄r10
	j	bne_cont.43641
bne_else.43640:
	slli	＄r10, ＄r10, 1
	srai	＄r5, ＄r4, 1
	beq	＄r5, ＄r0, bne_else.43646
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43648
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r10
	j	bne_cont.43649
bne_else.43648:
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43649:
	j	bne_cont.43647
bne_else.43646:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43647:
bne_cont.43641:
	j	bne_cont.43639
bne_else.43638:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43639:
	add	＄r4, ＄r3, ＄r11
	j	bne_cont.43637
bne_else.43636:
	slli	＄r16, ＄r11, 1
	srai	＄r3, ＄r12, 1
	beq	＄r3, ＄r0, bne_else.43650
	srai	＄r4, ＄r3, 1
	slli	＄r4, ＄r4, 1
	sub	＄r4, ＄r3, ＄r4
	beq	＄r4, ＄r0, bne_else.43652
	slli	＄r10, ＄r16, 1
	srai	＄r5, ＄r3, 1
	beq	＄r5, ＄r0, bne_else.43654
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43656
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r10
	j	bne_cont.43657
bne_else.43656:
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43657:
	j	bne_cont.43655
bne_else.43654:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43655:
	add	＄r4, ＄r3, ＄r16
	j	bne_cont.43653
bne_else.43652:
	slli	＄r10, ＄r16, 1
	srai	＄r3, ＄r3, 1
	beq	＄r3, ＄r0, bne_else.43658
	srai	＄r4, ＄r3, 1
	slli	＄r4, ＄r4, 1
	sub	＄r4, ＄r3, ＄r4
	beq	＄r4, ＄r0, bne_else.43660
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r3, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r4, ＄r3, ＄r10
	j	bne_cont.43661
bne_else.43660:
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r3, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
bne_cont.43661:
	j	bne_cont.43659
bne_else.43658:
	mvhi	＄r4, 0
	mvlo	＄r4, 0
bne_cont.43659:
bne_cont.43653:
	j	bne_cont.43651
bne_else.43650:
	mvhi	＄r4, 0
	mvlo	＄r4, 0
bne_cont.43651:
bne_cont.43637:
	j	bne_cont.43635
bne_else.43634:
	mvhi	＄r4, 0
	mvlo	＄r4, 0
bne_cont.43635:
	j	bge_cont.43633
bge_else.43632:
	sub	＄r10, ＄r0, ＄r11
	sub	＄r5, ＄r0, ＄r12
	beq	＄r5, ＄r0, bne_else.43662
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r4, ＄r5, ＄r3
	beq	＄r4, ＄r0, bne_else.43664
	slli	＄r16, ＄r10, 1
	srai	＄r4, ＄r5, 1
	beq	＄r4, ＄r0, bne_else.43666
	srai	＄r3, ＄r4, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r4, ＄r3
	beq	＄r3, ＄r0, bne_else.43668
	slli	＄r17, ＄r16, 1
	srai	＄r5, ＄r4, 1
	beq	＄r5, ＄r0, bne_else.43670
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43672
	slli	＄r4, ＄r17, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r17
	j	bne_cont.43673
bne_else.43672:
	slli	＄r4, ＄r17, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43673:
	j	bne_cont.43671
bne_else.43670:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43671:
	add	＄r3, ＄r3, ＄r16
	j	bne_cont.43669
bne_else.43668:
	slli	＄r16, ＄r16, 1
	srai	＄r5, ＄r4, 1
	beq	＄r5, ＄r0, bne_else.43674
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43676
	slli	＄r4, ＄r16, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r16
	j	bne_cont.43677
bne_else.43676:
	slli	＄r4, ＄r16, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43677:
	j	bne_cont.43675
bne_else.43674:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43675:
bne_cont.43669:
	j	bne_cont.43667
bne_else.43666:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43667:
	add	＄r4, ＄r3, ＄r10
	j	bne_cont.43665
bne_else.43664:
	slli	＄r16, ＄r10, 1
	srai	＄r3, ＄r5, 1
	beq	＄r3, ＄r0, bne_else.43678
	srai	＄r4, ＄r3, 1
	slli	＄r4, ＄r4, 1
	sub	＄r4, ＄r3, ＄r4
	beq	＄r4, ＄r0, bne_else.43680
	slli	＄r10, ＄r16, 1
	srai	＄r5, ＄r3, 1
	beq	＄r5, ＄r0, bne_else.43682
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43684
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r10
	j	bne_cont.43685
bne_else.43684:
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43685:
	j	bne_cont.43683
bne_else.43682:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43683:
	add	＄r4, ＄r3, ＄r16
	j	bne_cont.43681
bne_else.43680:
	slli	＄r10, ＄r16, 1
	srai	＄r3, ＄r3, 1
	beq	＄r3, ＄r0, bne_else.43686
	srai	＄r4, ＄r3, 1
	slli	＄r4, ＄r4, 1
	sub	＄r4, ＄r3, ＄r4
	beq	＄r4, ＄r0, bne_else.43688
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r3, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r4, ＄r3, ＄r10
	j	bne_cont.43689
bne_else.43688:
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r3, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
bne_cont.43689:
	j	bne_cont.43687
bne_else.43686:
	mvhi	＄r4, 0
	mvlo	＄r4, 0
bne_cont.43687:
bne_cont.43681:
	j	bne_cont.43679
bne_else.43678:
	mvhi	＄r4, 0
	mvlo	＄r4, 0
bne_cont.43679:
bne_cont.43665:
	j	bne_cont.43663
bne_else.43662:
	mvhi	＄r4, 0
	mvlo	＄r4, 0
bne_cont.43663:
bge_cont.43633:
	sub	＄r3, ＄r13, ＄r15
	blt	＄r29, ＄r3, ble_else.43690
	mov	＄r3, ＄r15
	return
ble_else.43690:
	blt	＄r4, ＄r14, ble_else.43691
	beq	＄r4, ＄r14, bne_else.43692
	mov	＄r16, ＄r11
	j	div_binary_search.2575
bne_else.43692:
	mov	＄r3, ＄r11
	return
ble_else.43691:
	mov	＄r16, ＄r13
	mov	＄r15, ＄r11
	j	div_binary_search.2575
bne_else.43631:
	mov	＄r3, ＄r13
	return
ble_else.43630:
	add	＄r3, ＄r13, ＄r16
	srai	＄r11, ＄r3, 1
	blt	＄r12, ＄r0, bge_else.43693
	beq	＄r12, ＄r0, bne_else.43695
	srai	＄r3, ＄r12, 1
	slli	＄r3, ＄r3, 1
	sub	＄r4, ＄r12, ＄r3
	beq	＄r4, ＄r0, bne_else.43697
	slli	＄r10, ＄r11, 1
	srai	＄r4, ＄r12, 1
	beq	＄r4, ＄r0, bne_else.43699
	srai	＄r3, ＄r4, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r4, ＄r3
	beq	＄r3, ＄r0, bne_else.43701
	slli	＄r15, ＄r10, 1
	srai	＄r5, ＄r4, 1
	beq	＄r5, ＄r0, bne_else.43703
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43705
	slli	＄r4, ＄r15, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r15
	j	bne_cont.43706
bne_else.43705:
	slli	＄r4, ＄r15, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43706:
	j	bne_cont.43704
bne_else.43703:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43704:
	add	＄r3, ＄r3, ＄r10
	j	bne_cont.43702
bne_else.43701:
	slli	＄r10, ＄r10, 1
	srai	＄r5, ＄r4, 1
	beq	＄r5, ＄r0, bne_else.43707
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43709
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r10
	j	bne_cont.43710
bne_else.43709:
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43710:
	j	bne_cont.43708
bne_else.43707:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43708:
bne_cont.43702:
	j	bne_cont.43700
bne_else.43699:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43700:
	add	＄r4, ＄r3, ＄r11
	j	bne_cont.43698
bne_else.43697:
	slli	＄r15, ＄r11, 1
	srai	＄r3, ＄r12, 1
	beq	＄r3, ＄r0, bne_else.43711
	srai	＄r4, ＄r3, 1
	slli	＄r4, ＄r4, 1
	sub	＄r4, ＄r3, ＄r4
	beq	＄r4, ＄r0, bne_else.43713
	slli	＄r10, ＄r15, 1
	srai	＄r5, ＄r3, 1
	beq	＄r5, ＄r0, bne_else.43715
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43717
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r10
	j	bne_cont.43718
bne_else.43717:
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43718:
	j	bne_cont.43716
bne_else.43715:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43716:
	add	＄r4, ＄r3, ＄r15
	j	bne_cont.43714
bne_else.43713:
	slli	＄r10, ＄r15, 1
	srai	＄r3, ＄r3, 1
	beq	＄r3, ＄r0, bne_else.43719
	srai	＄r4, ＄r3, 1
	slli	＄r4, ＄r4, 1
	sub	＄r4, ＄r3, ＄r4
	beq	＄r4, ＄r0, bne_else.43721
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r3, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r4, ＄r3, ＄r10
	j	bne_cont.43722
bne_else.43721:
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r3, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
bne_cont.43722:
	j	bne_cont.43720
bne_else.43719:
	mvhi	＄r4, 0
	mvlo	＄r4, 0
bne_cont.43720:
bne_cont.43714:
	j	bne_cont.43712
bne_else.43711:
	mvhi	＄r4, 0
	mvlo	＄r4, 0
bne_cont.43712:
bne_cont.43698:
	j	bne_cont.43696
bne_else.43695:
	mvhi	＄r4, 0
	mvlo	＄r4, 0
bne_cont.43696:
	j	bge_cont.43694
bge_else.43693:
	sub	＄r10, ＄r0, ＄r11
	sub	＄r5, ＄r0, ＄r12
	beq	＄r5, ＄r0, bne_else.43723
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r4, ＄r5, ＄r3
	beq	＄r4, ＄r0, bne_else.43725
	slli	＄r15, ＄r10, 1
	srai	＄r4, ＄r5, 1
	beq	＄r4, ＄r0, bne_else.43727
	srai	＄r3, ＄r4, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r4, ＄r3
	beq	＄r3, ＄r0, bne_else.43729
	slli	＄r17, ＄r15, 1
	srai	＄r5, ＄r4, 1
	beq	＄r5, ＄r0, bne_else.43731
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43733
	slli	＄r4, ＄r17, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r17
	j	bne_cont.43734
bne_else.43733:
	slli	＄r4, ＄r17, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43734:
	j	bne_cont.43732
bne_else.43731:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43732:
	add	＄r3, ＄r3, ＄r15
	j	bne_cont.43730
bne_else.43729:
	slli	＄r15, ＄r15, 1
	srai	＄r5, ＄r4, 1
	beq	＄r5, ＄r0, bne_else.43735
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43737
	slli	＄r4, ＄r15, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r15
	j	bne_cont.43738
bne_else.43737:
	slli	＄r4, ＄r15, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43738:
	j	bne_cont.43736
bne_else.43735:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43736:
bne_cont.43730:
	j	bne_cont.43728
bne_else.43727:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43728:
	add	＄r4, ＄r3, ＄r10
	j	bne_cont.43726
bne_else.43725:
	slli	＄r15, ＄r10, 1
	srai	＄r3, ＄r5, 1
	beq	＄r3, ＄r0, bne_else.43739
	srai	＄r4, ＄r3, 1
	slli	＄r4, ＄r4, 1
	sub	＄r4, ＄r3, ＄r4
	beq	＄r4, ＄r0, bne_else.43741
	slli	＄r10, ＄r15, 1
	srai	＄r5, ＄r3, 1
	beq	＄r5, ＄r0, bne_else.43743
	srai	＄r3, ＄r5, 1
	slli	＄r3, ＄r3, 1
	sub	＄r3, ＄r5, ＄r3
	beq	＄r3, ＄r0, bne_else.43745
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r3, ＄r3, ＄r10
	j	bne_cont.43746
bne_else.43745:
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
bne_cont.43746:
	j	bne_cont.43744
bne_else.43743:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43744:
	add	＄r4, ＄r3, ＄r15
	j	bne_cont.43742
bne_else.43741:
	slli	＄r10, ＄r15, 1
	srai	＄r3, ＄r3, 1
	beq	＄r3, ＄r0, bne_else.43747
	srai	＄r4, ＄r3, 1
	slli	＄r4, ＄r4, 1
	sub	＄r4, ＄r3, ＄r4
	beq	＄r4, ＄r0, bne_else.43749
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r3, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	add	＄r4, ＄r3, ＄r10
	j	bne_cont.43750
bne_else.43749:
	slli	＄r4, ＄r10, 1
	srai	＄r5, ＄r3, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
bne_cont.43750:
	j	bne_cont.43748
bne_else.43747:
	mvhi	＄r4, 0
	mvlo	＄r4, 0
bne_cont.43748:
bne_cont.43742:
	j	bne_cont.43740
bne_else.43739:
	mvhi	＄r4, 0
	mvlo	＄r4, 0
bne_cont.43740:
bne_cont.43726:
	j	bne_cont.43724
bne_else.43723:
	mvhi	＄r4, 0
	mvlo	＄r4, 0
bne_cont.43724:
bge_cont.43694:
	sub	＄r3, ＄r16, ＄r13
	blt	＄r29, ＄r3, ble_else.43751
	mov	＄r3, ＄r13
	return
ble_else.43751:
	blt	＄r4, ＄r14, ble_else.43752
	beq	＄r4, ＄r14, bne_else.43753
	mov	＄r16, ＄r11
	mov	＄r15, ＄r13
	j	div_binary_search.2575
bne_else.43753:
	mov	＄r3, ＄r11
	return
ble_else.43752:
	mov	＄r15, ＄r11
	j	div_binary_search.2575

#---------------------------------------------------------------------
# args = [＄r14]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
print_int.2587:
	blt	＄r14, ＄r0, bge_else.43754
	mvhi	＄r12, 1525
	mvlo	＄r12, 57600
	mvhi	＄r19, 0
	mvlo	＄r19, 0
	mvhi	＄r16, 0
	mvlo	＄r16, 3
	mvhi	＄r15, 0
	mvlo	＄r15, 1
	mvhi	＄r4, 0
	mvlo	＄r4, 8
	mvhi	＄r5, 190
	mvlo	＄r5, 48160
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r14, ＄r1, 0
	blt	＄r3, ＄r14, ble_else.43755
	beq	＄r3, ＄r14, bne_else.43757
	mov	＄r16, ＄r15
	mov	＄r15, ＄r19
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	div_binary_search.2575
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mov	＄r10, ＄r3
	j	bne_cont.43758
bne_else.43757:
	mvhi	＄r10, 0
	mvlo	＄r10, 1
bne_cont.43758:
	j	ble_cont.43756
ble_else.43755:
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	div_binary_search.2575
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mov	＄r10, ＄r3
ble_cont.43756:
	slli	＄r3, ＄r10, 1
	slli	＄r3, ＄r3, 1
	slli	＄r4, ＄r3, 1
	mvhi	＄r5, 190
	mvlo	＄r5, 48160
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r14, ＄r1, 0
	sub	＄r14, ＄r14, ＄r3
	blt	＄r0, ＄r10, ble_else.43759
	mvhi	＄r20, 0
	mvlo	＄r20, 0
	j	ble_cont.43760
ble_else.43759:
	mvhi	＄r3, 0
	mvlo	＄r3, 48
	add	＄r3, ＄r3, ＄r10
	output	＄r3
	mvhi	＄r20, 0
	mvlo	＄r20, 1
ble_cont.43760:
	mvhi	＄r12, 152
	mvlo	＄r12, 38528
	mvhi	＄r19, 0
	mvlo	＄r19, 0
	mvhi	＄r16, 0
	mvlo	＄r16, 10
	mvhi	＄r15, 0
	mvlo	＄r15, 5
	mvhi	＄r4, 0
	mvlo	＄r4, 40
	mvhi	＄r5, 19
	mvlo	＄r5, 4816
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	sti	＄r14, ＄r1, -1
	blt	＄r3, ＄r14, ble_else.43761
	beq	＄r3, ＄r14, bne_else.43763
	mov	＄r16, ＄r15
	mov	＄r15, ＄r19
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	div_binary_search.2575
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	mov	＄r10, ＄r3
	j	bne_cont.43764
bne_else.43763:
	mvhi	＄r10, 0
	mvlo	＄r10, 5
bne_cont.43764:
	j	ble_cont.43762
ble_else.43761:
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	div_binary_search.2575
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	mov	＄r10, ＄r3
ble_cont.43762:
	slli	＄r3, ＄r10, 1
	slli	＄r3, ＄r3, 1
	slli	＄r4, ＄r3, 1
	mvhi	＄r5, 19
	mvlo	＄r5, 4816
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	ldi	＄r14, ＄r1, -1
	sub	＄r14, ＄r14, ＄r3
	blt	＄r0, ＄r10, ble_else.43765
	beq	＄r20, ＄r0, bne_else.43767
	mvhi	＄r3, 0
	mvlo	＄r3, 48
	add	＄r3, ＄r3, ＄r10
	output	＄r3
	mvhi	＄r21, 0
	mvlo	＄r21, 1
	j	bne_cont.43768
bne_else.43767:
	mvhi	＄r21, 0
	mvlo	＄r21, 0
bne_cont.43768:
	j	ble_cont.43766
ble_else.43765:
	mvhi	＄r3, 0
	mvlo	＄r3, 48
	add	＄r3, ＄r3, ＄r10
	output	＄r3
	mvhi	＄r21, 0
	mvlo	＄r21, 1
ble_cont.43766:
	mvhi	＄r12, 15
	mvlo	＄r12, 16960
	mvhi	＄r19, 0
	mvlo	＄r19, 0
	mvhi	＄r16, 0
	mvlo	＄r16, 10
	mvhi	＄r15, 0
	mvlo	＄r15, 5
	mvhi	＄r4, 0
	mvlo	＄r4, 40
	mvhi	＄r5, 1
	mvlo	＄r5, 59464
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	sti	＄r14, ＄r1, -2
	blt	＄r3, ＄r14, ble_else.43769
	beq	＄r3, ＄r14, bne_else.43771
	mov	＄r16, ＄r15
	mov	＄r15, ＄r19
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	sub	＄r1, ＄r1, ＄r28
	call	div_binary_search.2575
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	add	＄r1, ＄r1, ＄r28
	mov	＄r10, ＄r3
	j	bne_cont.43772
bne_else.43771:
	mvhi	＄r10, 0
	mvlo	＄r10, 5
bne_cont.43772:
	j	ble_cont.43770
ble_else.43769:
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	sub	＄r1, ＄r1, ＄r28
	call	div_binary_search.2575
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	add	＄r1, ＄r1, ＄r28
	mov	＄r10, ＄r3
ble_cont.43770:
	slli	＄r3, ＄r10, 1
	slli	＄r3, ＄r3, 1
	slli	＄r4, ＄r3, 1
	mvhi	＄r5, 1
	mvlo	＄r5, 59464
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	add	＄r1, ＄r1, ＄r28
	ldi	＄r14, ＄r1, -2
	sub	＄r14, ＄r14, ＄r3
	blt	＄r0, ＄r10, ble_else.43773
	beq	＄r21, ＄r0, bne_else.43775
	mvhi	＄r3, 0
	mvlo	＄r3, 48
	add	＄r3, ＄r3, ＄r10
	output	＄r3
	mvhi	＄r20, 0
	mvlo	＄r20, 1
	j	bne_cont.43776
bne_else.43775:
	mvhi	＄r20, 0
	mvlo	＄r20, 0
bne_cont.43776:
	j	ble_cont.43774
ble_else.43773:
	mvhi	＄r3, 0
	mvlo	＄r3, 48
	add	＄r3, ＄r3, ＄r10
	output	＄r3
	mvhi	＄r20, 0
	mvlo	＄r20, 1
ble_cont.43774:
	mvhi	＄r12, 1
	mvlo	＄r12, 34464
	mvhi	＄r19, 0
	mvlo	＄r19, 0
	mvhi	＄r16, 0
	mvlo	＄r16, 10
	mvhi	＄r15, 0
	mvlo	＄r15, 5
	mvhi	＄r4, 0
	mvlo	＄r4, 40
	mvhi	＄r5, 0
	mvlo	＄r5, 12500
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	add	＄r1, ＄r1, ＄r28
	sti	＄r14, ＄r1, -3
	blt	＄r3, ＄r14, ble_else.43777
	beq	＄r3, ＄r14, bne_else.43779
	mov	＄r16, ＄r15
	mov	＄r15, ＄r19
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r1, ＄r1, ＄r28
	call	div_binary_search.2575
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	add	＄r1, ＄r1, ＄r28
	mov	＄r10, ＄r3
	j	bne_cont.43780
bne_else.43779:
	mvhi	＄r10, 0
	mvlo	＄r10, 5
bne_cont.43780:
	j	ble_cont.43778
ble_else.43777:
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r1, ＄r1, ＄r28
	call	div_binary_search.2575
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	add	＄r1, ＄r1, ＄r28
	mov	＄r10, ＄r3
ble_cont.43778:
	slli	＄r3, ＄r10, 1
	slli	＄r3, ＄r3, 1
	slli	＄r4, ＄r3, 1
	mvhi	＄r5, 0
	mvlo	＄r5, 12500
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	add	＄r1, ＄r1, ＄r28
	ldi	＄r14, ＄r1, -3
	sub	＄r14, ＄r14, ＄r3
	blt	＄r0, ＄r10, ble_else.43781
	beq	＄r20, ＄r0, bne_else.43783
	mvhi	＄r3, 0
	mvlo	＄r3, 48
	add	＄r3, ＄r3, ＄r10
	output	＄r3
	mvhi	＄r21, 0
	mvlo	＄r21, 1
	j	bne_cont.43784
bne_else.43783:
	mvhi	＄r21, 0
	mvlo	＄r21, 0
bne_cont.43784:
	j	ble_cont.43782
ble_else.43781:
	mvhi	＄r3, 0
	mvlo	＄r3, 48
	add	＄r3, ＄r3, ＄r10
	output	＄r3
	mvhi	＄r21, 0
	mvlo	＄r21, 1
ble_cont.43782:
	mvhi	＄r12, 0
	mvlo	＄r12, 10000
	mvhi	＄r19, 0
	mvlo	＄r19, 0
	mvhi	＄r16, 0
	mvlo	＄r16, 10
	mvhi	＄r15, 0
	mvlo	＄r15, 5
	mvhi	＄r4, 0
	mvlo	＄r4, 40
	mvhi	＄r5, 0
	mvlo	＄r5, 1250
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	add	＄r1, ＄r1, ＄r28
	sti	＄r14, ＄r1, -4
	blt	＄r3, ＄r14, ble_else.43785
	beq	＄r3, ＄r14, bne_else.43787
	mov	＄r16, ＄r15
	mov	＄r15, ＄r19
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	sub	＄r1, ＄r1, ＄r28
	call	div_binary_search.2575
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	add	＄r1, ＄r1, ＄r28
	mov	＄r10, ＄r3
	j	bne_cont.43788
bne_else.43787:
	mvhi	＄r10, 0
	mvlo	＄r10, 5
bne_cont.43788:
	j	ble_cont.43786
ble_else.43785:
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	sub	＄r1, ＄r1, ＄r28
	call	div_binary_search.2575
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	add	＄r1, ＄r1, ＄r28
	mov	＄r10, ＄r3
ble_cont.43786:
	slli	＄r3, ＄r10, 1
	slli	＄r3, ＄r3, 1
	slli	＄r4, ＄r3, 1
	mvhi	＄r5, 0
	mvlo	＄r5, 1250
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	add	＄r1, ＄r1, ＄r28
	ldi	＄r14, ＄r1, -4
	sub	＄r14, ＄r14, ＄r3
	blt	＄r0, ＄r10, ble_else.43789
	beq	＄r21, ＄r0, bne_else.43791
	mvhi	＄r3, 0
	mvlo	＄r3, 48
	add	＄r3, ＄r3, ＄r10
	output	＄r3
	mvhi	＄r20, 0
	mvlo	＄r20, 1
	j	bne_cont.43792
bne_else.43791:
	mvhi	＄r20, 0
	mvlo	＄r20, 0
bne_cont.43792:
	j	ble_cont.43790
ble_else.43789:
	mvhi	＄r3, 0
	mvlo	＄r3, 48
	add	＄r3, ＄r3, ＄r10
	output	＄r3
	mvhi	＄r20, 0
	mvlo	＄r20, 1
ble_cont.43790:
	mvhi	＄r12, 0
	mvlo	＄r12, 1000
	mvhi	＄r19, 0
	mvlo	＄r19, 0
	mvhi	＄r16, 0
	mvlo	＄r16, 10
	mvhi	＄r15, 0
	mvlo	＄r15, 5
	mvhi	＄r4, 0
	mvlo	＄r4, 40
	mvhi	＄r5, 0
	mvlo	＄r5, 125
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	add	＄r1, ＄r1, ＄r28
	sti	＄r14, ＄r1, -5
	blt	＄r3, ＄r14, ble_else.43793
	beq	＄r3, ＄r14, bne_else.43795
	mov	＄r16, ＄r15
	mov	＄r15, ＄r19
	mvhi	＄r28, 0
	mvlo	＄r28, 7
	sub	＄r1, ＄r1, ＄r28
	call	div_binary_search.2575
	mvhi	＄r28, 0
	mvlo	＄r28, 7
	add	＄r1, ＄r1, ＄r28
	mov	＄r10, ＄r3
	j	bne_cont.43796
bne_else.43795:
	mvhi	＄r10, 0
	mvlo	＄r10, 5
bne_cont.43796:
	j	ble_cont.43794
ble_else.43793:
	mvhi	＄r28, 0
	mvlo	＄r28, 7
	sub	＄r1, ＄r1, ＄r28
	call	div_binary_search.2575
	mvhi	＄r28, 0
	mvlo	＄r28, 7
	add	＄r1, ＄r1, ＄r28
	mov	＄r10, ＄r3
ble_cont.43794:
	slli	＄r3, ＄r10, 1
	slli	＄r3, ＄r3, 1
	slli	＄r4, ＄r3, 1
	mvhi	＄r5, 0
	mvlo	＄r5, 125
	mvhi	＄r28, 0
	mvlo	＄r28, 7
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 7
	add	＄r1, ＄r1, ＄r28
	ldi	＄r14, ＄r1, -5
	sub	＄r14, ＄r14, ＄r3
	blt	＄r0, ＄r10, ble_else.43797
	beq	＄r20, ＄r0, bne_else.43799
	mvhi	＄r3, 0
	mvlo	＄r3, 48
	add	＄r3, ＄r3, ＄r10
	output	＄r3
	mvhi	＄r21, 0
	mvlo	＄r21, 1
	j	bne_cont.43800
bne_else.43799:
	mvhi	＄r21, 0
	mvlo	＄r21, 0
bne_cont.43800:
	j	ble_cont.43798
ble_else.43797:
	mvhi	＄r3, 0
	mvlo	＄r3, 48
	add	＄r3, ＄r3, ＄r10
	output	＄r3
	mvhi	＄r21, 0
	mvlo	＄r21, 1
ble_cont.43798:
	mvhi	＄r12, 0
	mvlo	＄r12, 100
	mvhi	＄r19, 0
	mvlo	＄r19, 0
	mvhi	＄r16, 0
	mvlo	＄r16, 10
	mvhi	＄r15, 0
	mvlo	＄r15, 5
	mvhi	＄r4, 0
	mvlo	＄r4, 40
	mvhi	＄r5, 0
	mvlo	＄r5, 12
	mvhi	＄r28, 0
	mvlo	＄r28, 7
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 7
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 20
	add	＄r4, ＄r3, ＄r28
	sti	＄r14, ＄r1, -6
	blt	＄r4, ＄r14, ble_else.43801
	beq	＄r4, ＄r14, bne_else.43803
	mov	＄r16, ＄r15
	mov	＄r15, ＄r19
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	sub	＄r1, ＄r1, ＄r28
	call	div_binary_search.2575
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	add	＄r1, ＄r1, ＄r28
	j	bne_cont.43804
bne_else.43803:
	mvhi	＄r3, 0
	mvlo	＄r3, 5
bne_cont.43804:
	j	ble_cont.43802
ble_else.43801:
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	sub	＄r1, ＄r1, ＄r28
	call	div_binary_search.2575
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	add	＄r1, ＄r1, ＄r28
ble_cont.43802:
	slli	＄r4, ＄r3, 1
	slli	＄r10, ＄r4, 1
	slli	＄r4, ＄r10, 1
	mvhi	＄r5, 0
	mvlo	＄r5, 12
	sti	＄r3, ＄r1, -7
	mvhi	＄r28, 0
	mvlo	＄r28, 9
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 9
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	add	＄r4, ＄r4, ＄r10
	ldi	＄r14, ＄r1, -6
	sub	＄r14, ＄r14, ＄r4
	ldi	＄r3, ＄r1, -7
	blt	＄r0, ＄r3, ble_else.43805
	beq	＄r21, ＄r0, bne_else.43807
	mvhi	＄r4, 0
	mvlo	＄r4, 48
	add	＄r3, ＄r4, ＄r3
	output	＄r3
	mvhi	＄r20, 0
	mvlo	＄r20, 1
	j	bne_cont.43808
bne_else.43807:
	mvhi	＄r20, 0
	mvlo	＄r20, 0
bne_cont.43808:
	j	ble_cont.43806
ble_else.43805:
	mvhi	＄r4, 0
	mvlo	＄r4, 48
	add	＄r3, ＄r4, ＄r3
	output	＄r3
	mvhi	＄r20, 0
	mvlo	＄r20, 1
ble_cont.43806:
	mvhi	＄r12, 0
	mvlo	＄r12, 10
	mvhi	＄r19, 0
	mvlo	＄r19, 0
	mvhi	＄r16, 0
	mvlo	＄r16, 10
	mvhi	＄r15, 0
	mvlo	＄r15, 5
	mvhi	＄r4, 0
	mvlo	＄r4, 40
	mvhi	＄r5, 0
	mvlo	＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 9
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 9
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	add	＄r4, ＄r3, ＄r28
	sti	＄r14, ＄r1, -8
	blt	＄r4, ＄r14, ble_else.43809
	beq	＄r4, ＄r14, bne_else.43811
	mov	＄r16, ＄r15
	mov	＄r15, ＄r19
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	sub	＄r1, ＄r1, ＄r28
	call	div_binary_search.2575
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	add	＄r1, ＄r1, ＄r28
	j	bne_cont.43812
bne_else.43811:
	mvhi	＄r3, 0
	mvlo	＄r3, 5
bne_cont.43812:
	j	ble_cont.43810
ble_else.43809:
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	sub	＄r1, ＄r1, ＄r28
	call	div_binary_search.2575
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	add	＄r1, ＄r1, ＄r28
ble_cont.43810:
	slli	＄r10, ＄r3, 1
	slli	＄r4, ＄r10, 1
	slli	＄r4, ＄r4, 1
	mvhi	＄r5, 0
	mvlo	＄r5, 1
	sti	＄r3, ＄r1, -9
	mvhi	＄r28, 0
	mvlo	＄r28, 11
	sub	＄r1, ＄r1, ＄r28
	call	mul_sub.2569
	mvhi	＄r28, 0
	mvlo	＄r28, 11
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	add	＄r4, ＄r4, ＄r10
	ldi	＄r14, ＄r1, -8
	sub	＄r4, ＄r14, ＄r4
	ldi	＄r3, ＄r1, -9
	blt	＄r0, ＄r3, ble_else.43813
	beq	＄r20, ＄r0, bne_else.43815
	mvhi	＄r5, 0
	mvlo	＄r5, 48
	add	＄r3, ＄r5, ＄r3
	output	＄r3
	mvhi	＄r5, 0
	mvlo	＄r5, 1
	j	bne_cont.43816
bne_else.43815:
	mvhi	＄r5, 0
	mvlo	＄r5, 0
bne_cont.43816:
	j	ble_cont.43814
ble_else.43813:
	mvhi	＄r5, 0
	mvlo	＄r5, 48
	add	＄r3, ＄r5, ＄r3
	output	＄r3
	mvhi	＄r5, 0
	mvlo	＄r5, 1
ble_cont.43814:
	mvhi	＄r3, 0
	mvlo	＄r3, 48
	add	＄r3, ＄r3, ＄r4
	output	＄r3
	return
bge_else.43754:
	mvhi	＄r3, 0
	mvlo	＄r3, 45
	output	＄r3
	sub	＄r14, ＄r0, ＄r14
	j	print_int.2587

#---------------------------------------------------------------------
# args = [＄r6]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
read_object.2755:
	mvhi	＄r3, 0
	mvlo	＄r3, 60
	blt	＄r6, ＄r3, ble_else.43817
	return
ble_else.43817:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_int
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r8, ＄r3
	beq	＄r8, ＄r30, bne_else.43819
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_int
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r13, ＄r3
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_int
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r10, ＄r3
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_int
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r12, ＄r3
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r5, ＄r3
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_float
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fsti	＄f0, ＄r5, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_float
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fsti	＄f0, ＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_float
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fsti	＄f0, ＄r5, 2
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r7, ＄r3
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_float
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fsti	＄f0, ＄r7, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_float
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fsti	＄f0, ＄r7, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_float
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fsti	＄f0, ＄r7, 2
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_float
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fmov	＄f3, ＄f0
	mvhi	＄r3, 0
	mvlo	＄r3, 2
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r11, ＄r3
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_float
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fsti	＄f0, ＄r11, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_float
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fsti	＄f0, ＄r11, 1
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r14, ＄r3
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_float
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fsti	＄f0, ＄r14, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_float
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fsti	＄f0, ＄r14, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_float
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fsti	＄f0, ＄r14, 2
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r9, ＄r3
	beq	＄r12, ＄r0, bne_else.43821
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_float
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	# 0.017453
	fmvhi	＄f1, 15502
	fmvlo	＄f1, 64045
	fmul	＄f0, ＄f0, ＄f1
	fsti	＄f0, ＄r9, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_float
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fmul	＄f0, ＄f0, ＄f1
	fsti	＄f0, ＄r9, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_float
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fmul	＄f0, ＄f0, ＄f1
	fsti	＄f0, ＄r9, 2
	j	bne_cont.43822
bne_else.43821:
bne_cont.43822:
	mvhi	＄r15, 0
	mvlo	＄r15, 2
	beq	＄r13, ＄r15, bne_else.43823
	fblt	＄f3, ＄f16, fbge_else.43825
	mvhi	＄r15, 0
	mvlo	＄r15, 0
	j	fbge_cont.43826
fbge_else.43825:
	mvhi	＄r15, 0
	mvlo	＄r15, 1
fbge_cont.43826:
	j	bne_cont.43824
bne_else.43823:
	mvhi	＄r15, 0
	mvlo	＄r15, 1
bne_cont.43824:
	mvhi	＄r3, 0
	mvlo	＄r3, 4
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 11
	add	＄r2, ＄r2, ＄r28
	sti	＄r4, ＄r3, 10
	sti	＄r9, ＄r3, 9
	sti	＄r14, ＄r3, 8
	sti	＄r11, ＄r3, 7
	sti	＄r15, ＄r3, 6
	sti	＄r7, ＄r3, 5
	sti	＄r5, ＄r3, 4
	sti	＄r12, ＄r3, 3
	sti	＄r10, ＄r3, 2
	sti	＄r13, ＄r3, 1
	sti	＄r8, ＄r3, 0
	slli	＄r4, ＄r6, 0
	sti	＄r3, ＄r4, 522
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	beq	＄r13, ＄r3, bne_else.43827
	mvhi	＄r3, 0
	mvlo	＄r3, 2
	beq	＄r13, ＄r3, bne_else.43829
	j	bne_cont.43830
bne_else.43829:
	fldi	＄f2, ＄r5, 0
	fmul	＄f1, ＄f2, ＄f2
	fldi	＄f0, ＄r5, 1
	fmul	＄f0, ＄f0, ＄f0
	fadd	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r5, 2
	fmul	＄f0, ＄f0, ＄f0
	fadd	＄f0, ＄f1, ＄f0
	fsqrt	＄f1, ＄f0
	fbne	＄f1, ＄f16, fbeq_else.43831
	fmov	＄f0, ＄f17
	j	fbeq_cont.43832
fbeq_else.43831:
	fblt	＄f3, ＄f16, fbge_else.43833
	fdiv	＄f0, ＄f20, ＄f1
	j	fbge_cont.43834
fbge_else.43833:
	fdiv	＄f0, ＄f17, ＄f1
fbge_cont.43834:
fbeq_cont.43832:
	fmul	＄f1, ＄f2, ＄f0
	fsti	＄f1, ＄r5, 0
	fldi	＄f1, ＄r5, 1
	fmul	＄f1, ＄f1, ＄f0
	fsti	＄f1, ＄r5, 1
	fldi	＄f1, ＄r5, 2
	fmul	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r5, 2
bne_cont.43830:
	j	bne_cont.43828
bne_else.43827:
	fldi	＄f1, ＄r5, 0
	fbne	＄f1, ＄f16, fbeq_else.43835
	fmov	＄f0, ＄f16
	j	fbeq_cont.43836
fbeq_else.43835:
	fbne	＄f1, ＄f16, fbeq_else.43837
	fmov	＄f0, ＄f16
	j	fbeq_cont.43838
fbeq_else.43837:
	fblt	＄f16, ＄f1, fbge_else.43839
	fmov	＄f0, ＄f20
	j	fbge_cont.43840
fbge_else.43839:
	fmov	＄f0, ＄f17
fbge_cont.43840:
fbeq_cont.43838:
	fmul	＄f1, ＄f1, ＄f1
	fdiv	＄f0, ＄f0, ＄f1
fbeq_cont.43836:
	fsti	＄f0, ＄r5, 0
	fldi	＄f1, ＄r5, 1
	fbne	＄f1, ＄f16, fbeq_else.43841
	fmov	＄f0, ＄f16
	j	fbeq_cont.43842
fbeq_else.43841:
	fbne	＄f1, ＄f16, fbeq_else.43843
	fmov	＄f0, ＄f16
	j	fbeq_cont.43844
fbeq_else.43843:
	fblt	＄f16, ＄f1, fbge_else.43845
	fmov	＄f0, ＄f20
	j	fbge_cont.43846
fbge_else.43845:
	fmov	＄f0, ＄f17
fbge_cont.43846:
fbeq_cont.43844:
	fmul	＄f1, ＄f1, ＄f1
	fdiv	＄f0, ＄f0, ＄f1
fbeq_cont.43842:
	fsti	＄f0, ＄r5, 1
	fldi	＄f1, ＄r5, 2
	fbne	＄f1, ＄f16, fbeq_else.43847
	fmov	＄f0, ＄f16
	j	fbeq_cont.43848
fbeq_else.43847:
	fbne	＄f1, ＄f16, fbeq_else.43849
	fmov	＄f0, ＄f16
	j	fbeq_cont.43850
fbeq_else.43849:
	fblt	＄f16, ＄f1, fbge_else.43851
	fmov	＄f0, ＄f20
	j	fbge_cont.43852
fbge_else.43851:
	fmov	＄f0, ＄f17
fbge_cont.43852:
fbeq_cont.43850:
	fmul	＄f1, ＄f1, ＄f1
	fdiv	＄f0, ＄f0, ＄f1
fbeq_cont.43848:
	fsti	＄f0, ＄r5, 2
bne_cont.43828:
	beq	＄r12, ＄r0, bne_else.43853
	fldi	＄f3, ＄r9, 0
	fsub	＄f2, ＄f22, ＄f3
	fblt	＄f2, ＄f16, fbge_else.43855
	fmov	＄f1, ＄f2
	j	fbge_cont.43856
fbge_else.43855:
	fneg	＄f1, ＄f2
fbge_cont.43856:
	fblt	＄f29, ＄f1, fbge_else.43857
	fblt	＄f1, ＄f16, fbge_else.43859
	fmov	＄f0, ＄f1
	j	fbge_cont.43860
fbge_else.43859:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43861
	fblt	＄f1, ＄f16, fbge_else.43863
	fmov	＄f0, ＄f1
	j	fbge_cont.43864
fbge_else.43863:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43865
	fblt	＄f1, ＄f16, fbge_else.43867
	fmov	＄f0, ＄f1
	j	fbge_cont.43868
fbge_else.43867:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43868:
	j	fbge_cont.43866
fbge_else.43865:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43866:
fbge_cont.43864:
	j	fbge_cont.43862
fbge_else.43861:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43869
	fblt	＄f1, ＄f16, fbge_else.43871
	fmov	＄f0, ＄f1
	j	fbge_cont.43872
fbge_else.43871:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43872:
	j	fbge_cont.43870
fbge_else.43869:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43870:
fbge_cont.43862:
fbge_cont.43860:
	j	fbge_cont.43858
fbge_else.43857:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43873
	fblt	＄f1, ＄f16, fbge_else.43875
	fmov	＄f0, ＄f1
	j	fbge_cont.43876
fbge_else.43875:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43877
	fblt	＄f1, ＄f16, fbge_else.43879
	fmov	＄f0, ＄f1
	j	fbge_cont.43880
fbge_else.43879:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43880:
	j	fbge_cont.43878
fbge_else.43877:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43878:
fbge_cont.43876:
	j	fbge_cont.43874
fbge_else.43873:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43881
	fblt	＄f1, ＄f16, fbge_else.43883
	fmov	＄f0, ＄f1
	j	fbge_cont.43884
fbge_else.43883:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43884:
	j	fbge_cont.43882
fbge_else.43881:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43882:
fbge_cont.43874:
fbge_cont.43858:
	fblt	＄f31, ＄f0, fbge_else.43885
	fblt	＄f16, ＄f2, fbge_else.43887
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.43888
fbge_else.43887:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.43888:
	j	fbge_cont.43886
fbge_else.43885:
	fblt	＄f16, ＄f2, fbge_else.43889
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	fbge_cont.43890
fbge_else.43889:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
fbge_cont.43890:
fbge_cont.43886:
	fblt	＄f31, ＄f0, fbge_else.43891
	fmov	＄f1, ＄f0
	j	fbge_cont.43892
fbge_else.43891:
	fsub	＄f1, ＄f29, ＄f0
fbge_cont.43892:
	fblt	＄f22, ＄f1, fbge_else.43893
	fmov	＄f0, ＄f1
	j	fbge_cont.43894
fbge_else.43893:
	fsub	＄f0, ＄f31, ＄f1
fbge_cont.43894:
	fmul	＄f1, ＄f0, ＄f21
	fmul	＄f0, ＄f1, ＄f1
	fdiv	＄f2, ＄f0, ＄f25
	fsub	＄f2, ＄f26, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f24, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f23, ＄f2
	fdiv	＄f0, ＄f0, ＄f2
	fsub	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	fmul	＄f1, ＄f30, ＄f0
	fmul	＄f0, ＄f0, ＄f0
	fadd	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	beq	＄r3, ＄r0, bne_else.43895
	fmov	＄f14, ＄f0
	j	bne_cont.43896
bne_else.43895:
	fneg	＄f14, ＄f0
bne_cont.43896:
	fblt	＄f3, ＄f16, fbge_else.43897
	fmov	＄f1, ＄f3
	j	fbge_cont.43898
fbge_else.43897:
	fneg	＄f1, ＄f3
fbge_cont.43898:
	fblt	＄f29, ＄f1, fbge_else.43899
	fblt	＄f1, ＄f16, fbge_else.43901
	fmov	＄f0, ＄f1
	j	fbge_cont.43902
fbge_else.43901:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43903
	fblt	＄f1, ＄f16, fbge_else.43905
	fmov	＄f0, ＄f1
	j	fbge_cont.43906
fbge_else.43905:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43907
	fblt	＄f1, ＄f16, fbge_else.43909
	fmov	＄f0, ＄f1
	j	fbge_cont.43910
fbge_else.43909:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43910:
	j	fbge_cont.43908
fbge_else.43907:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43908:
fbge_cont.43906:
	j	fbge_cont.43904
fbge_else.43903:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43911
	fblt	＄f1, ＄f16, fbge_else.43913
	fmov	＄f0, ＄f1
	j	fbge_cont.43914
fbge_else.43913:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43914:
	j	fbge_cont.43912
fbge_else.43911:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43912:
fbge_cont.43904:
fbge_cont.43902:
	j	fbge_cont.43900
fbge_else.43899:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43915
	fblt	＄f1, ＄f16, fbge_else.43917
	fmov	＄f0, ＄f1
	j	fbge_cont.43918
fbge_else.43917:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43919
	fblt	＄f1, ＄f16, fbge_else.43921
	fmov	＄f0, ＄f1
	j	fbge_cont.43922
fbge_else.43921:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43922:
	j	fbge_cont.43920
fbge_else.43919:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43920:
fbge_cont.43918:
	j	fbge_cont.43916
fbge_else.43915:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43923
	fblt	＄f1, ＄f16, fbge_else.43925
	fmov	＄f0, ＄f1
	j	fbge_cont.43926
fbge_else.43925:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43926:
	j	fbge_cont.43924
fbge_else.43923:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43924:
fbge_cont.43916:
fbge_cont.43900:
	fblt	＄f31, ＄f0, fbge_else.43927
	fblt	＄f16, ＄f3, fbge_else.43929
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.43930
fbge_else.43929:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.43930:
	j	fbge_cont.43928
fbge_else.43927:
	fblt	＄f16, ＄f3, fbge_else.43931
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	fbge_cont.43932
fbge_else.43931:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
fbge_cont.43932:
fbge_cont.43928:
	fblt	＄f31, ＄f0, fbge_else.43933
	fmov	＄f1, ＄f0
	j	fbge_cont.43934
fbge_else.43933:
	fsub	＄f1, ＄f29, ＄f0
fbge_cont.43934:
	fblt	＄f22, ＄f1, fbge_else.43935
	fmov	＄f0, ＄f1
	j	fbge_cont.43936
fbge_else.43935:
	fsub	＄f0, ＄f31, ＄f1
fbge_cont.43936:
	fmul	＄f1, ＄f0, ＄f21
	fmul	＄f0, ＄f1, ＄f1
	fdiv	＄f2, ＄f0, ＄f25
	fsub	＄f2, ＄f26, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f24, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f23, ＄f2
	fdiv	＄f0, ＄f0, ＄f2
	fsub	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	fmul	＄f1, ＄f30, ＄f0
	fmul	＄f0, ＄f0, ＄f0
	fadd	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	beq	＄r3, ＄r0, bne_else.43937
	fmov	＄f7, ＄f0
	j	bne_cont.43938
bne_else.43937:
	fneg	＄f7, ＄f0
bne_cont.43938:
	fldi	＄f3, ＄r9, 1
	fsub	＄f2, ＄f22, ＄f3
	fblt	＄f2, ＄f16, fbge_else.43939
	fmov	＄f1, ＄f2
	j	fbge_cont.43940
fbge_else.43939:
	fneg	＄f1, ＄f2
fbge_cont.43940:
	fblt	＄f29, ＄f1, fbge_else.43941
	fblt	＄f1, ＄f16, fbge_else.43943
	fmov	＄f0, ＄f1
	j	fbge_cont.43944
fbge_else.43943:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43945
	fblt	＄f1, ＄f16, fbge_else.43947
	fmov	＄f0, ＄f1
	j	fbge_cont.43948
fbge_else.43947:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43949
	fblt	＄f1, ＄f16, fbge_else.43951
	fmov	＄f0, ＄f1
	j	fbge_cont.43952
fbge_else.43951:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43952:
	j	fbge_cont.43950
fbge_else.43949:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43950:
fbge_cont.43948:
	j	fbge_cont.43946
fbge_else.43945:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43953
	fblt	＄f1, ＄f16, fbge_else.43955
	fmov	＄f0, ＄f1
	j	fbge_cont.43956
fbge_else.43955:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43956:
	j	fbge_cont.43954
fbge_else.43953:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43954:
fbge_cont.43946:
fbge_cont.43944:
	j	fbge_cont.43942
fbge_else.43941:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43957
	fblt	＄f1, ＄f16, fbge_else.43959
	fmov	＄f0, ＄f1
	j	fbge_cont.43960
fbge_else.43959:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43961
	fblt	＄f1, ＄f16, fbge_else.43963
	fmov	＄f0, ＄f1
	j	fbge_cont.43964
fbge_else.43963:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43964:
	j	fbge_cont.43962
fbge_else.43961:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43962:
fbge_cont.43960:
	j	fbge_cont.43958
fbge_else.43957:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43965
	fblt	＄f1, ＄f16, fbge_else.43967
	fmov	＄f0, ＄f1
	j	fbge_cont.43968
fbge_else.43967:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43968:
	j	fbge_cont.43966
fbge_else.43965:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43966:
fbge_cont.43958:
fbge_cont.43942:
	fblt	＄f31, ＄f0, fbge_else.43969
	fblt	＄f16, ＄f2, fbge_else.43971
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.43972
fbge_else.43971:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.43972:
	j	fbge_cont.43970
fbge_else.43969:
	fblt	＄f16, ＄f2, fbge_else.43973
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	fbge_cont.43974
fbge_else.43973:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
fbge_cont.43974:
fbge_cont.43970:
	fblt	＄f31, ＄f0, fbge_else.43975
	fmov	＄f1, ＄f0
	j	fbge_cont.43976
fbge_else.43975:
	fsub	＄f1, ＄f29, ＄f0
fbge_cont.43976:
	fblt	＄f22, ＄f1, fbge_else.43977
	fmov	＄f0, ＄f1
	j	fbge_cont.43978
fbge_else.43977:
	fsub	＄f0, ＄f31, ＄f1
fbge_cont.43978:
	fmul	＄f1, ＄f0, ＄f21
	fmul	＄f0, ＄f1, ＄f1
	fdiv	＄f2, ＄f0, ＄f25
	fsub	＄f2, ＄f26, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f24, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f23, ＄f2
	fdiv	＄f0, ＄f0, ＄f2
	fsub	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	fmul	＄f1, ＄f30, ＄f0
	fmul	＄f0, ＄f0, ＄f0
	fadd	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	beq	＄r3, ＄r0, bne_else.43979
	fmov	＄f13, ＄f0
	j	bne_cont.43980
bne_else.43979:
	fneg	＄f13, ＄f0
bne_cont.43980:
	fblt	＄f3, ＄f16, fbge_else.43981
	fmov	＄f1, ＄f3
	j	fbge_cont.43982
fbge_else.43981:
	fneg	＄f1, ＄f3
fbge_cont.43982:
	fblt	＄f29, ＄f1, fbge_else.43983
	fblt	＄f1, ＄f16, fbge_else.43985
	fmov	＄f0, ＄f1
	j	fbge_cont.43986
fbge_else.43985:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43987
	fblt	＄f1, ＄f16, fbge_else.43989
	fmov	＄f0, ＄f1
	j	fbge_cont.43990
fbge_else.43989:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43991
	fblt	＄f1, ＄f16, fbge_else.43993
	fmov	＄f0, ＄f1
	j	fbge_cont.43994
fbge_else.43993:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43994:
	j	fbge_cont.43992
fbge_else.43991:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43992:
fbge_cont.43990:
	j	fbge_cont.43988
fbge_else.43987:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43995
	fblt	＄f1, ＄f16, fbge_else.43997
	fmov	＄f0, ＄f1
	j	fbge_cont.43998
fbge_else.43997:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43998:
	j	fbge_cont.43996
fbge_else.43995:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.43996:
fbge_cont.43988:
fbge_cont.43986:
	j	fbge_cont.43984
fbge_else.43983:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.43999
	fblt	＄f1, ＄f16, fbge_else.44001
	fmov	＄f0, ＄f1
	j	fbge_cont.44002
fbge_else.44001:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.44003
	fblt	＄f1, ＄f16, fbge_else.44005
	fmov	＄f0, ＄f1
	j	fbge_cont.44006
fbge_else.44005:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.44006:
	j	fbge_cont.44004
fbge_else.44003:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.44004:
fbge_cont.44002:
	j	fbge_cont.44000
fbge_else.43999:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.44007
	fblt	＄f1, ＄f16, fbge_else.44009
	fmov	＄f0, ＄f1
	j	fbge_cont.44010
fbge_else.44009:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.44010:
	j	fbge_cont.44008
fbge_else.44007:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.44008:
fbge_cont.44000:
fbge_cont.43984:
	fblt	＄f31, ＄f0, fbge_else.44011
	fblt	＄f16, ＄f3, fbge_else.44013
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44014
fbge_else.44013:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.44014:
	j	fbge_cont.44012
fbge_else.44011:
	fblt	＄f16, ＄f3, fbge_else.44015
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	fbge_cont.44016
fbge_else.44015:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
fbge_cont.44016:
fbge_cont.44012:
	fblt	＄f31, ＄f0, fbge_else.44017
	fmov	＄f1, ＄f0
	j	fbge_cont.44018
fbge_else.44017:
	fsub	＄f1, ＄f29, ＄f0
fbge_cont.44018:
	fblt	＄f22, ＄f1, fbge_else.44019
	fmov	＄f0, ＄f1
	j	fbge_cont.44020
fbge_else.44019:
	fsub	＄f0, ＄f31, ＄f1
fbge_cont.44020:
	fmul	＄f1, ＄f0, ＄f21
	fmul	＄f0, ＄f1, ＄f1
	fdiv	＄f2, ＄f0, ＄f25
	fsub	＄f2, ＄f26, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f24, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f23, ＄f2
	fdiv	＄f0, ＄f0, ＄f2
	fsub	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	fmul	＄f1, ＄f30, ＄f0
	fmul	＄f0, ＄f0, ＄f0
	fadd	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	beq	＄r3, ＄r0, bne_else.44021
	fmov	＄f9, ＄f0
	j	bne_cont.44022
bne_else.44021:
	fneg	＄f9, ＄f0
bne_cont.44022:
	fldi	＄f4, ＄r9, 2
	fsub	＄f2, ＄f22, ＄f4
	fblt	＄f2, ＄f16, fbge_else.44023
	fmov	＄f1, ＄f2
	j	fbge_cont.44024
fbge_else.44023:
	fneg	＄f1, ＄f2
fbge_cont.44024:
	fblt	＄f29, ＄f1, fbge_else.44025
	fblt	＄f1, ＄f16, fbge_else.44027
	fmov	＄f0, ＄f1
	j	fbge_cont.44028
fbge_else.44027:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.44029
	fblt	＄f1, ＄f16, fbge_else.44031
	fmov	＄f0, ＄f1
	j	fbge_cont.44032
fbge_else.44031:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.44033
	fblt	＄f1, ＄f16, fbge_else.44035
	fmov	＄f0, ＄f1
	j	fbge_cont.44036
fbge_else.44035:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.44036:
	j	fbge_cont.44034
fbge_else.44033:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.44034:
fbge_cont.44032:
	j	fbge_cont.44030
fbge_else.44029:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.44037
	fblt	＄f1, ＄f16, fbge_else.44039
	fmov	＄f0, ＄f1
	j	fbge_cont.44040
fbge_else.44039:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.44040:
	j	fbge_cont.44038
fbge_else.44037:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.44038:
fbge_cont.44030:
fbge_cont.44028:
	j	fbge_cont.44026
fbge_else.44025:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.44041
	fblt	＄f1, ＄f16, fbge_else.44043
	fmov	＄f0, ＄f1
	j	fbge_cont.44044
fbge_else.44043:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.44045
	fblt	＄f1, ＄f16, fbge_else.44047
	fmov	＄f0, ＄f1
	j	fbge_cont.44048
fbge_else.44047:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.44048:
	j	fbge_cont.44046
fbge_else.44045:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.44046:
fbge_cont.44044:
	j	fbge_cont.44042
fbge_else.44041:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.44049
	fblt	＄f1, ＄f16, fbge_else.44051
	fmov	＄f0, ＄f1
	j	fbge_cont.44052
fbge_else.44051:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.44052:
	j	fbge_cont.44050
fbge_else.44049:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.44050:
fbge_cont.44042:
fbge_cont.44026:
	fblt	＄f31, ＄f0, fbge_else.44053
	fblt	＄f16, ＄f2, fbge_else.44055
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44056
fbge_else.44055:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.44056:
	j	fbge_cont.44054
fbge_else.44053:
	fblt	＄f16, ＄f2, fbge_else.44057
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	fbge_cont.44058
fbge_else.44057:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
fbge_cont.44058:
fbge_cont.44054:
	fblt	＄f31, ＄f0, fbge_else.44059
	fmov	＄f1, ＄f0
	j	fbge_cont.44060
fbge_else.44059:
	fsub	＄f1, ＄f29, ＄f0
fbge_cont.44060:
	fblt	＄f22, ＄f1, fbge_else.44061
	fmov	＄f0, ＄f1
	j	fbge_cont.44062
fbge_else.44061:
	fsub	＄f0, ＄f31, ＄f1
fbge_cont.44062:
	fmul	＄f1, ＄f0, ＄f21
	fmul	＄f0, ＄f1, ＄f1
	fdiv	＄f2, ＄f0, ＄f25
	fsub	＄f2, ＄f26, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f24, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f23, ＄f2
	fdiv	＄f0, ＄f0, ＄f2
	fsub	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	fmul	＄f1, ＄f30, ＄f0
	fmul	＄f0, ＄f0, ＄f0
	fadd	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	beq	＄r3, ＄r0, bne_else.44063
	fmov	＄f3, ＄f0
	j	bne_cont.44064
bne_else.44063:
	fneg	＄f3, ＄f0
bne_cont.44064:
	fblt	＄f4, ＄f16, fbge_else.44065
	fmov	＄f1, ＄f4
	j	fbge_cont.44066
fbge_else.44065:
	fneg	＄f1, ＄f4
fbge_cont.44066:
	fblt	＄f29, ＄f1, fbge_else.44067
	fblt	＄f1, ＄f16, fbge_else.44069
	fmov	＄f0, ＄f1
	j	fbge_cont.44070
fbge_else.44069:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.44071
	fblt	＄f1, ＄f16, fbge_else.44073
	fmov	＄f0, ＄f1
	j	fbge_cont.44074
fbge_else.44073:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.44075
	fblt	＄f1, ＄f16, fbge_else.44077
	fmov	＄f0, ＄f1
	j	fbge_cont.44078
fbge_else.44077:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.44078:
	j	fbge_cont.44076
fbge_else.44075:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.44076:
fbge_cont.44074:
	j	fbge_cont.44072
fbge_else.44071:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.44079
	fblt	＄f1, ＄f16, fbge_else.44081
	fmov	＄f0, ＄f1
	j	fbge_cont.44082
fbge_else.44081:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.44082:
	j	fbge_cont.44080
fbge_else.44079:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.44080:
fbge_cont.44072:
fbge_cont.44070:
	j	fbge_cont.44068
fbge_else.44067:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.44083
	fblt	＄f1, ＄f16, fbge_else.44085
	fmov	＄f0, ＄f1
	j	fbge_cont.44086
fbge_else.44085:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.44087
	fblt	＄f1, ＄f16, fbge_else.44089
	fmov	＄f0, ＄f1
	j	fbge_cont.44090
fbge_else.44089:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.44090:
	j	fbge_cont.44088
fbge_else.44087:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.44088:
fbge_cont.44086:
	j	fbge_cont.44084
fbge_else.44083:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.44091
	fblt	＄f1, ＄f16, fbge_else.44093
	fmov	＄f0, ＄f1
	j	fbge_cont.44094
fbge_else.44093:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.44094:
	j	fbge_cont.44092
fbge_else.44091:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.44092:
fbge_cont.44084:
fbge_cont.44068:
	fblt	＄f31, ＄f0, fbge_else.44095
	fblt	＄f16, ＄f4, fbge_else.44097
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44098
fbge_else.44097:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.44098:
	j	fbge_cont.44096
fbge_else.44095:
	fblt	＄f16, ＄f4, fbge_else.44099
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	fbge_cont.44100
fbge_else.44099:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
fbge_cont.44100:
fbge_cont.44096:
	fblt	＄f31, ＄f0, fbge_else.44101
	fmov	＄f1, ＄f0
	j	fbge_cont.44102
fbge_else.44101:
	fsub	＄f1, ＄f29, ＄f0
fbge_cont.44102:
	fblt	＄f22, ＄f1, fbge_else.44103
	fmov	＄f0, ＄f1
	j	fbge_cont.44104
fbge_else.44103:
	fsub	＄f0, ＄f31, ＄f1
fbge_cont.44104:
	fmul	＄f1, ＄f0, ＄f21
	fmul	＄f0, ＄f1, ＄f1
	fdiv	＄f2, ＄f0, ＄f25
	fsub	＄f2, ＄f26, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f24, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f23, ＄f2
	fdiv	＄f0, ＄f0, ＄f2
	fsub	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	fmul	＄f1, ＄f30, ＄f0
	fmul	＄f0, ＄f0, ＄f0
	fadd	＄f0, ＄f17, ＄f0
	fdiv	＄f1, ＄f1, ＄f0
	beq	＄r3, ＄r0, bne_else.44105
	fmov	＄f0, ＄f1
	j	bne_cont.44106
bne_else.44105:
	fneg	＄f0, ＄f1
bne_cont.44106:
	fmul	＄f12, ＄f13, ＄f3
	fmul	＄f1, ＄f7, ＄f9
	fmul	＄f4, ＄f1, ＄f3
	fmul	＄f2, ＄f14, ＄f0
	fsub	＄f10, ＄f4, ＄f2
	fmul	＄f2, ＄f14, ＄f9
	fmul	＄f5, ＄f2, ＄f3
	fmul	＄f4, ＄f7, ＄f0
	fadd	＄f6, ＄f5, ＄f4
	fmul	＄f11, ＄f13, ＄f0
	fmul	＄f4, ＄f1, ＄f0
	fmul	＄f1, ＄f14, ＄f3
	fadd	＄f8, ＄f4, ＄f1
	fmul	＄f1, ＄f2, ＄f0
	fmul	＄f0, ＄f7, ＄f3
	fsub	＄f5, ＄f1, ＄f0
	fneg	＄f9, ＄f9
	fmul	＄f7, ＄f7, ＄f13
	fmul	＄f4, ＄f14, ＄f13
	fldi	＄f0, ＄r5, 0
	fldi	＄f2, ＄r5, 1
	fldi	＄f3, ＄r5, 2
	fmul	＄f1, ＄f12, ＄f12
	fmul	＄f13, ＄f0, ＄f1
	fmul	＄f1, ＄f11, ＄f11
	fmul	＄f1, ＄f2, ＄f1
	fadd	＄f13, ＄f13, ＄f1
	fmul	＄f1, ＄f9, ＄f9
	fmul	＄f1, ＄f3, ＄f1
	fadd	＄f1, ＄f13, ＄f1
	fsti	＄f1, ＄r5, 0
	fmul	＄f1, ＄f10, ＄f10
	fmul	＄f13, ＄f0, ＄f1
	fmul	＄f1, ＄f8, ＄f8
	fmul	＄f1, ＄f2, ＄f1
	fadd	＄f13, ＄f13, ＄f1
	fmul	＄f1, ＄f7, ＄f7
	fmul	＄f1, ＄f3, ＄f1
	fadd	＄f1, ＄f13, ＄f1
	fsti	＄f1, ＄r5, 1
	fmul	＄f1, ＄f6, ＄f6
	fmul	＄f13, ＄f0, ＄f1
	fmul	＄f1, ＄f5, ＄f5
	fmul	＄f1, ＄f2, ＄f1
	fadd	＄f13, ＄f13, ＄f1
	fmul	＄f1, ＄f4, ＄f4
	fmul	＄f1, ＄f3, ＄f1
	fadd	＄f1, ＄f13, ＄f1
	fsti	＄f1, ＄r5, 2
	fmul	＄f1, ＄f0, ＄f10
	fmul	＄f13, ＄f1, ＄f6
	fmul	＄f1, ＄f2, ＄f8
	fmul	＄f1, ＄f1, ＄f5
	fadd	＄f13, ＄f13, ＄f1
	fmul	＄f1, ＄f3, ＄f7
	fmul	＄f1, ＄f1, ＄f4
	fadd	＄f1, ＄f13, ＄f1
	fmul	＄f1, ＄f30, ＄f1
	fsti	＄f1, ＄r9, 0
	fmul	＄f1, ＄f0, ＄f12
	fmul	＄f6, ＄f1, ＄f6
	fmul	＄f0, ＄f2, ＄f11
	fmul	＄f2, ＄f0, ＄f5
	fadd	＄f5, ＄f6, ＄f2
	fmul	＄f3, ＄f3, ＄f9
	fmul	＄f2, ＄f3, ＄f4
	fadd	＄f2, ＄f5, ＄f2
	fmul	＄f2, ＄f30, ＄f2
	fsti	＄f2, ＄r9, 1
	fmul	＄f1, ＄f1, ＄f10
	fmul	＄f0, ＄f0, ＄f8
	fadd	＄f1, ＄f1, ＄f0
	fmul	＄f0, ＄f3, ＄f7
	fadd	＄f0, ＄f1, ＄f0
	fmul	＄f0, ＄f30, ＄f0
	fsti	＄f0, ＄r9, 2
	j	bne_cont.43854
bne_else.43853:
bne_cont.43854:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	bne_cont.43820
bne_else.43819:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.43820:
	beq	＄r3, ＄r0, bne_else.44107
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r6, ＄r6, ＄r28
	j	read_object.2755
bne_else.44107:
	sti	＄r6, ＄r0, 583
	return

#---------------------------------------------------------------------
# args = [＄r5]
# fargs = []
# ret type = Array(Int)
#---------------------------------------------------------------------
read_net_item.2759:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_read_int
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	beq	＄r4, ＄r30, bne_else.44109
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r3, ＄r5, ＄r28
	sti	＄r4, ＄r1, 0
	sti	＄r5, ＄r1, -1
	mov	＄r5, ＄r3
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	read_net_item.2759
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	ldi	＄r5, ＄r1, -1
	slli	＄r5, ＄r5, 0
	ldi	＄r4, ＄r1, 0
	add	＄r28, ＄r3, ＄r5
	sti	＄r4, ＄r28, 0
	return
bne_else.44109:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r3, ＄r5, ＄r28
	mvhi	＄r4, 65535
	mvlo	＄r4, -1
	j	min_caml_create_array

#---------------------------------------------------------------------
# args = [＄r6]
# fargs = []
# ret type = Array(Array(Int))
#---------------------------------------------------------------------
read_or_network.2761:
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	read_net_item.2759
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	ldi	＄r3, ＄r4, 0
	beq	＄r3, ＄r30, bne_else.44110
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r3, ＄r6, ＄r28
	sti	＄r4, ＄r1, 0
	sti	＄r6, ＄r1, -1
	mov	＄r6, ＄r3
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	read_or_network.2761
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	ldi	＄r6, ＄r1, -1
	slli	＄r5, ＄r6, 0
	ldi	＄r4, ＄r1, 0
	add	＄r28, ＄r3, ＄r5
	sti	＄r4, ＄r28, 0
	return
bne_else.44110:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r3, ＄r6, ＄r28
	j	min_caml_create_array

#---------------------------------------------------------------------
# args = [＄r6]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
read_and_network.2763:
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	read_net_item.2759
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r4, ＄r3, 0
	beq	＄r4, ＄r30, bne_else.44111
	slli	＄r4, ＄r6, 0
	sti	＄r3, ＄r4, 462
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r6, ＄r6, ＄r28
	j	read_and_network.2763
bne_else.44111:
	return

#---------------------------------------------------------------------
# args = [＄r7, ＄r5]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
iter_setup_dirvec_constants.2860:
	blt	＄r5, ＄r0, bge_else.44113
	slli	＄r3, ＄r5, 0
	ldi	＄r10, ＄r3, 522
	ldi	＄r6, ＄r7, 1
	ldi	＄r8, ＄r7, 0
	ldi	＄r3, ＄r10, 1
	beq	＄r3, ＄r29, bne_else.44114
	mvhi	＄r4, 0
	mvlo	＄r4, 2
	beq	＄r3, ＄r4, bne_else.44116
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fldi	＄f0, ＄r8, 0
	fldi	＄f1, ＄r8, 1
	fldi	＄f2, ＄r8, 2
	fmul	＄f3, ＄f0, ＄f0
	ldi	＄r4, ＄r10, 4
	fldi	＄f5, ＄r4, 0
	fmul	＄f4, ＄f3, ＄f5
	fmul	＄f3, ＄f1, ＄f1
	fldi	＄f6, ＄r4, 1
	fmul	＄f3, ＄f3, ＄f6
	fadd	＄f7, ＄f4, ＄f3
	fmul	＄f3, ＄f2, ＄f2
	fldi	＄f4, ＄r4, 2
	fmul	＄f3, ＄f3, ＄f4
	fadd	＄f7, ＄f7, ＄f3
	ldi	＄r9, ＄r10, 3
	beq	＄r9, ＄r0, bne_else.44118
	fmul	＄f8, ＄f1, ＄f2
	ldi	＄r4, ＄r10, 9
	fldi	＄f3, ＄r4, 0
	fmul	＄f3, ＄f8, ＄f3
	fadd	＄f8, ＄f7, ＄f3
	fmul	＄f7, ＄f2, ＄f0
	fldi	＄f3, ＄r4, 1
	fmul	＄f3, ＄f7, ＄f3
	fadd	＄f8, ＄f8, ＄f3
	fmul	＄f7, ＄f0, ＄f1
	fldi	＄f3, ＄r4, 2
	fmul	＄f3, ＄f7, ＄f3
	fadd	＄f3, ＄f8, ＄f3
	j	bne_cont.44119
bne_else.44118:
	fmov	＄f3, ＄f7
bne_cont.44119:
	fmul	＄f0, ＄f0, ＄f5
	fneg	＄f0, ＄f0
	fmul	＄f1, ＄f1, ＄f6
	fneg	＄f1, ＄f1
	fmul	＄f2, ＄f2, ＄f4
	fneg	＄f2, ＄f2
	fsti	＄f3, ＄r3, 0
	beq	＄r9, ＄r0, bne_else.44120
	fldi	＄f5, ＄r8, 2
	ldi	＄r4, ＄r10, 9
	fldi	＄f4, ＄r4, 1
	fmul	＄f6, ＄f5, ＄f4
	fldi	＄f5, ＄r8, 1
	fldi	＄f4, ＄r4, 2
	fmul	＄f4, ＄f5, ＄f4
	fadd	＄f4, ＄f6, ＄f4
	fmul	＄f4, ＄f4, ＄f21
	fsub	＄f0, ＄f0, ＄f4
	fsti	＄f0, ＄r3, 1
	fldi	＄f4, ＄r8, 2
	fldi	＄f0, ＄r4, 0
	fmul	＄f5, ＄f4, ＄f0
	fldi	＄f4, ＄r8, 0
	fldi	＄f0, ＄r4, 2
	fmul	＄f0, ＄f4, ＄f0
	fadd	＄f0, ＄f5, ＄f0
	fmul	＄f0, ＄f0, ＄f21
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r3, 2
	fldi	＄f1, ＄r8, 1
	fldi	＄f0, ＄r4, 0
	fmul	＄f4, ＄f1, ＄f0
	fldi	＄f1, ＄r8, 0
	fldi	＄f0, ＄r4, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f4, ＄f0
	fmul	＄f0, ＄f0, ＄f21
	fsub	＄f0, ＄f2, ＄f0
	fsti	＄f0, ＄r3, 3
	j	bne_cont.44121
bne_else.44120:
	fsti	＄f0, ＄r3, 1
	fsti	＄f1, ＄r3, 2
	fsti	＄f2, ＄r3, 3
bne_cont.44121:
	fbne	＄f3, ＄f16, fbeq_else.44122
	j	fbeq_cont.44123
fbeq_else.44122:
	fdiv	＄f0, ＄f17, ＄f3
	fsti	＄f0, ＄r3, 4
fbeq_cont.44123:
	slli	＄r4, ＄r5, 0
	add	＄r28, ＄r6, ＄r4
	sti	＄r3, ＄r28, 0
	j	bne_cont.44117
bne_else.44116:
	mvhi	＄r3, 0
	mvlo	＄r3, 4
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fldi	＄f1, ＄r8, 0
	ldi	＄r4, ＄r10, 4
	fldi	＄f0, ＄r4, 0
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r8, 1
	fldi	＄f0, ＄r4, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r8, 2
	fldi	＄f0, ＄r4, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f16, ＄f0, fbge_else.44124
	fsti	＄f16, ＄r3, 0
	j	fbge_cont.44125
fbge_else.44124:
	fdiv	＄f1, ＄f20, ＄f0
	fsti	＄f1, ＄r3, 0
	fldi	＄f1, ＄r4, 0
	fdiv	＄f1, ＄f1, ＄f0
	fneg	＄f1, ＄f1
	fsti	＄f1, ＄r3, 1
	fldi	＄f1, ＄r4, 1
	fdiv	＄f1, ＄f1, ＄f0
	fneg	＄f1, ＄f1
	fsti	＄f1, ＄r3, 2
	fldi	＄f1, ＄r4, 2
	fdiv	＄f0, ＄f1, ＄f0
	fneg	＄f0, ＄f0
	fsti	＄f0, ＄r3, 3
fbge_cont.44125:
	slli	＄r4, ＄r5, 0
	add	＄r28, ＄r6, ＄r4
	sti	＄r3, ＄r28, 0
bne_cont.44117:
	j	bne_cont.44115
bne_else.44114:
	mvhi	＄r3, 0
	mvlo	＄r3, 6
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fldi	＄f0, ＄r8, 0
	fbne	＄f0, ＄f16, fbeq_else.44126
	fsti	＄f16, ＄r3, 1
	j	fbeq_cont.44127
fbeq_else.44126:
	ldi	＄r4, ＄r10, 6
	fblt	＄f0, ＄f16, fbge_else.44128
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	j	fbge_cont.44129
fbge_else.44128:
	mvhi	＄r11, 0
	mvlo	＄r11, 1
fbge_cont.44129:
	ldi	＄r9, ＄r10, 4
	fldi	＄f1, ＄r9, 0
	beq	＄r4, ＄r11, bne_else.44130
	fmov	＄f0, ＄f1
	j	bne_cont.44131
bne_else.44130:
	fneg	＄f0, ＄f1
bne_cont.44131:
	fsti	＄f0, ＄r3, 0
	fldi	＄f0, ＄r8, 0
	fdiv	＄f0, ＄f17, ＄f0
	fsti	＄f0, ＄r3, 1
fbeq_cont.44127:
	fldi	＄f0, ＄r8, 1
	fbne	＄f0, ＄f16, fbeq_else.44132
	fsti	＄f16, ＄r3, 3
	j	fbeq_cont.44133
fbeq_else.44132:
	ldi	＄r4, ＄r10, 6
	fblt	＄f0, ＄f16, fbge_else.44134
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	j	fbge_cont.44135
fbge_else.44134:
	mvhi	＄r11, 0
	mvlo	＄r11, 1
fbge_cont.44135:
	ldi	＄r9, ＄r10, 4
	fldi	＄f1, ＄r9, 1
	beq	＄r4, ＄r11, bne_else.44136
	fmov	＄f0, ＄f1
	j	bne_cont.44137
bne_else.44136:
	fneg	＄f0, ＄f1
bne_cont.44137:
	fsti	＄f0, ＄r3, 2
	fldi	＄f0, ＄r8, 1
	fdiv	＄f0, ＄f17, ＄f0
	fsti	＄f0, ＄r3, 3
fbeq_cont.44133:
	fldi	＄f0, ＄r8, 2
	fbne	＄f0, ＄f16, fbeq_else.44138
	fsti	＄f16, ＄r3, 5
	j	fbeq_cont.44139
fbeq_else.44138:
	ldi	＄r4, ＄r10, 6
	fblt	＄f0, ＄f16, fbge_else.44140
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	j	fbge_cont.44141
fbge_else.44140:
	mvhi	＄r11, 0
	mvlo	＄r11, 1
fbge_cont.44141:
	ldi	＄r9, ＄r10, 4
	fldi	＄f1, ＄r9, 2
	beq	＄r4, ＄r11, bne_else.44142
	fmov	＄f0, ＄f1
	j	bne_cont.44143
bne_else.44142:
	fneg	＄f0, ＄f1
bne_cont.44143:
	fsti	＄f0, ＄r3, 4
	fldi	＄f0, ＄r8, 2
	fdiv	＄f0, ＄f17, ＄f0
	fsti	＄f0, ＄r3, 5
fbeq_cont.44139:
	slli	＄r4, ＄r5, 0
	add	＄r28, ＄r6, ＄r4
	sti	＄r3, ＄r28, 0
bne_cont.44115:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r5, ＄r28
	j	iter_setup_dirvec_constants.2860
bge_else.44113:
	return

#---------------------------------------------------------------------
# args = [＄r3, ＄r4]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
setup_startp_constants.2865:
	blt	＄r4, ＄r0, bge_else.44145
	slli	＄r5, ＄r4, 0
	ldi	＄r5, ＄r5, 522
	ldi	＄r8, ＄r5, 10
	ldi	＄r7, ＄r5, 1
	fldi	＄f1, ＄r3, 0
	ldi	＄r6, ＄r5, 5
	fldi	＄f0, ＄r6, 0
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r8, 0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r6, 1
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r8, 1
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r6, 2
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r8, 2
	mvhi	＄r6, 0
	mvlo	＄r6, 2
	beq	＄r7, ＄r6, bne_else.44146
	mvhi	＄r6, 0
	mvlo	＄r6, 2
	blt	＄r6, ＄r7, ble_else.44148
	j	ble_cont.44149
ble_else.44148:
	fldi	＄f2, ＄r8, 0
	fldi	＄f1, ＄r8, 1
	fldi	＄f0, ＄r8, 2
	fmul	＄f4, ＄f2, ＄f2
	ldi	＄r6, ＄r5, 4
	fldi	＄f3, ＄r6, 0
	fmul	＄f5, ＄f4, ＄f3
	fmul	＄f4, ＄f1, ＄f1
	fldi	＄f3, ＄r6, 1
	fmul	＄f3, ＄f4, ＄f3
	fadd	＄f5, ＄f5, ＄f3
	fmul	＄f4, ＄f0, ＄f0
	fldi	＄f3, ＄r6, 2
	fmul	＄f3, ＄f4, ＄f3
	fadd	＄f4, ＄f5, ＄f3
	ldi	＄r6, ＄r5, 3
	beq	＄r6, ＄r0, bne_else.44150
	fmul	＄f5, ＄f1, ＄f0
	ldi	＄r5, ＄r5, 9
	fldi	＄f3, ＄r5, 0
	fmul	＄f3, ＄f5, ＄f3
	fadd	＄f4, ＄f4, ＄f3
	fmul	＄f3, ＄f0, ＄f2
	fldi	＄f0, ＄r5, 1
	fmul	＄f0, ＄f3, ＄f0
	fadd	＄f4, ＄f4, ＄f0
	fmul	＄f1, ＄f2, ＄f1
	fldi	＄f0, ＄r5, 2
	fmul	＄f3, ＄f1, ＄f0
	fadd	＄f3, ＄f4, ＄f3
	j	bne_cont.44151
bne_else.44150:
	fmov	＄f3, ＄f4
bne_cont.44151:
	mvhi	＄r5, 0
	mvlo	＄r5, 3
	beq	＄r7, ＄r5, bne_else.44152
	fmov	＄f0, ＄f3
	j	bne_cont.44153
bne_else.44152:
	fsub	＄f0, ＄f3, ＄f17
bne_cont.44153:
	fsti	＄f0, ＄r8, 3
ble_cont.44149:
	j	bne_cont.44147
bne_else.44146:
	ldi	＄r5, ＄r5, 4
	fldi	＄f1, ＄r8, 0
	fldi	＄f3, ＄r8, 1
	fldi	＄f2, ＄r8, 2
	fldi	＄f0, ＄r5, 0
	fmul	＄f1, ＄f0, ＄f1
	fldi	＄f0, ＄r5, 1
	fmul	＄f0, ＄f0, ＄f3
	fadd	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r5, 2
	fmul	＄f0, ＄f0, ＄f2
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r8, 3
bne_cont.44147:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r8, ＄r4, ＄r28
	blt	＄r8, ＄r0, bge_else.44154
	slli	＄r4, ＄r8, 0
	ldi	＄r4, ＄r4, 522
	ldi	＄r7, ＄r4, 10
	ldi	＄r6, ＄r4, 1
	fldi	＄f1, ＄r3, 0
	ldi	＄r5, ＄r4, 5
	fldi	＄f0, ＄r5, 0
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r7, 0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r5, 1
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r7, 1
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r5, 2
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r7, 2
	mvhi	＄r5, 0
	mvlo	＄r5, 2
	beq	＄r6, ＄r5, bne_else.44155
	mvhi	＄r5, 0
	mvlo	＄r5, 2
	blt	＄r5, ＄r6, ble_else.44157
	j	ble_cont.44158
ble_else.44157:
	fldi	＄f2, ＄r7, 0
	fldi	＄f1, ＄r7, 1
	fldi	＄f0, ＄r7, 2
	fmul	＄f4, ＄f2, ＄f2
	ldi	＄r5, ＄r4, 4
	fldi	＄f3, ＄r5, 0
	fmul	＄f5, ＄f4, ＄f3
	fmul	＄f4, ＄f1, ＄f1
	fldi	＄f3, ＄r5, 1
	fmul	＄f3, ＄f4, ＄f3
	fadd	＄f5, ＄f5, ＄f3
	fmul	＄f4, ＄f0, ＄f0
	fldi	＄f3, ＄r5, 2
	fmul	＄f3, ＄f4, ＄f3
	fadd	＄f4, ＄f5, ＄f3
	ldi	＄r5, ＄r4, 3
	beq	＄r5, ＄r0, bne_else.44159
	fmul	＄f5, ＄f1, ＄f0
	ldi	＄r4, ＄r4, 9
	fldi	＄f3, ＄r4, 0
	fmul	＄f3, ＄f5, ＄f3
	fadd	＄f4, ＄f4, ＄f3
	fmul	＄f3, ＄f0, ＄f2
	fldi	＄f0, ＄r4, 1
	fmul	＄f0, ＄f3, ＄f0
	fadd	＄f4, ＄f4, ＄f0
	fmul	＄f1, ＄f2, ＄f1
	fldi	＄f0, ＄r4, 2
	fmul	＄f3, ＄f1, ＄f0
	fadd	＄f3, ＄f4, ＄f3
	j	bne_cont.44160
bne_else.44159:
	fmov	＄f3, ＄f4
bne_cont.44160:
	mvhi	＄r4, 0
	mvlo	＄r4, 3
	beq	＄r6, ＄r4, bne_else.44161
	fmov	＄f0, ＄f3
	j	bne_cont.44162
bne_else.44161:
	fsub	＄f0, ＄f3, ＄f17
bne_cont.44162:
	fsti	＄f0, ＄r7, 3
ble_cont.44158:
	j	bne_cont.44156
bne_else.44155:
	ldi	＄r4, ＄r4, 4
	fldi	＄f1, ＄r7, 0
	fldi	＄f3, ＄r7, 1
	fldi	＄f2, ＄r7, 2
	fldi	＄f0, ＄r4, 0
	fmul	＄f1, ＄f0, ＄f1
	fldi	＄f0, ＄r4, 1
	fmul	＄f0, ＄f0, ＄f3
	fadd	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r4, 2
	fmul	＄f0, ＄f0, ＄f2
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r7, 3
bne_cont.44156:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r4, ＄r8, ＄r28
	j	setup_startp_constants.2865
bge_else.44154:
	return
bge_else.44145:
	return

#---------------------------------------------------------------------
# args = [＄r5, ＄r4]
# fargs = [＄f5, ＄f4, ＄f3]
# ret type = Bool
#---------------------------------------------------------------------
check_all_inside.2890:
	slli	＄r3, ＄r5, 0
	add	＄r28, ＄r4, ＄r3
	ldi	＄r6, ＄r28, 0
	beq	＄r6, ＄r30, bne_else.44165
	slli	＄r3, ＄r6, 0
	ldi	＄r7, ＄r3, 522
	ldi	＄r3, ＄r7, 5
	fldi	＄f0, ＄r3, 0
	fsub	＄f0, ＄f5, ＄f0
	fldi	＄f1, ＄r3, 1
	fsub	＄f2, ＄f4, ＄f1
	fldi	＄f1, ＄r3, 2
	fsub	＄f1, ＄f3, ＄f1
	ldi	＄r6, ＄r7, 1
	beq	＄r6, ＄r29, bne_else.44166
	mvhi	＄r3, 0
	mvlo	＄r3, 2
	beq	＄r6, ＄r3, bne_else.44168
	fmul	＄f7, ＄f0, ＄f0
	ldi	＄r3, ＄r7, 4
	fldi	＄f6, ＄r3, 0
	fmul	＄f8, ＄f7, ＄f6
	fmul	＄f7, ＄f2, ＄f2
	fldi	＄f6, ＄r3, 1
	fmul	＄f6, ＄f7, ＄f6
	fadd	＄f8, ＄f8, ＄f6
	fmul	＄f7, ＄f1, ＄f1
	fldi	＄f6, ＄r3, 2
	fmul	＄f6, ＄f7, ＄f6
	fadd	＄f7, ＄f8, ＄f6
	ldi	＄r3, ＄r7, 3
	beq	＄r3, ＄r0, bne_else.44170
	fmul	＄f8, ＄f2, ＄f1
	ldi	＄r3, ＄r7, 9
	fldi	＄f6, ＄r3, 0
	fmul	＄f6, ＄f8, ＄f6
	fadd	＄f7, ＄f7, ＄f6
	fmul	＄f6, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fmul	＄f1, ＄f6, ＄f1
	fadd	＄f7, ＄f7, ＄f1
	fmul	＄f1, ＄f0, ＄f2
	fldi	＄f0, ＄r3, 2
	fmul	＄f6, ＄f1, ＄f0
	fadd	＄f6, ＄f7, ＄f6
	j	bne_cont.44171
bne_else.44170:
	fmov	＄f6, ＄f7
bne_cont.44171:
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	beq	＄r6, ＄r3, bne_else.44172
	fmov	＄f0, ＄f6
	j	bne_cont.44173
bne_else.44172:
	fsub	＄f0, ＄f6, ＄f17
bne_cont.44173:
	ldi	＄r3, ＄r7, 6
	fblt	＄f0, ＄f16, fbge_else.44174
	mvhi	＄r6, 0
	mvlo	＄r6, 0
	j	fbge_cont.44175
fbge_else.44174:
	mvhi	＄r6, 0
	mvlo	＄r6, 1
fbge_cont.44175:
	beq	＄r3, ＄r6, bne_else.44176
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	bne_cont.44177
bne_else.44176:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
bne_cont.44177:
	j	bne_cont.44169
bne_else.44168:
	ldi	＄r3, ＄r7, 4
	fldi	＄f6, ＄r3, 0
	fmul	＄f6, ＄f6, ＄f0
	fldi	＄f0, ＄r3, 1
	fmul	＄f0, ＄f0, ＄f2
	fadd	＄f2, ＄f6, ＄f0
	fldi	＄f0, ＄r3, 2
	fmul	＄f0, ＄f0, ＄f1
	fadd	＄f0, ＄f2, ＄f0
	ldi	＄r3, ＄r7, 6
	fblt	＄f0, ＄f16, fbge_else.44178
	mvhi	＄r6, 0
	mvlo	＄r6, 0
	j	fbge_cont.44179
fbge_else.44178:
	mvhi	＄r6, 0
	mvlo	＄r6, 1
fbge_cont.44179:
	beq	＄r3, ＄r6, bne_else.44180
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	bne_cont.44181
bne_else.44180:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
bne_cont.44181:
bne_cont.44169:
	j	bne_cont.44167
bne_else.44166:
	fblt	＄f0, ＄f16, fbge_else.44182
	fmov	＄f6, ＄f0
	j	fbge_cont.44183
fbge_else.44182:
	fneg	＄f6, ＄f0
fbge_cont.44183:
	ldi	＄r3, ＄r7, 4
	fldi	＄f0, ＄r3, 0
	fblt	＄f6, ＄f0, fbge_else.44184
	mvhi	＄r6, 0
	mvlo	＄r6, 0
	j	fbge_cont.44185
fbge_else.44184:
	fblt	＄f2, ＄f16, fbge_else.44186
	fmov	＄f0, ＄f2
	j	fbge_cont.44187
fbge_else.44186:
	fneg	＄f0, ＄f2
fbge_cont.44187:
	fldi	＄f2, ＄r3, 1
	fblt	＄f0, ＄f2, fbge_else.44188
	mvhi	＄r6, 0
	mvlo	＄r6, 0
	j	fbge_cont.44189
fbge_else.44188:
	fblt	＄f1, ＄f16, fbge_else.44190
	fmov	＄f0, ＄f1
	j	fbge_cont.44191
fbge_else.44190:
	fneg	＄f0, ＄f1
fbge_cont.44191:
	fldi	＄f1, ＄r3, 2
	fblt	＄f0, ＄f1, fbge_else.44192
	mvhi	＄r6, 0
	mvlo	＄r6, 0
	j	fbge_cont.44193
fbge_else.44192:
	mvhi	＄r6, 0
	mvlo	＄r6, 1
fbge_cont.44193:
fbge_cont.44189:
fbge_cont.44185:
	beq	＄r6, ＄r0, bne_else.44194
	ldi	＄r3, ＄r7, 6
	j	bne_cont.44195
bne_else.44194:
	ldi	＄r3, ＄r7, 6
	beq	＄r3, ＄r0, bne_else.44196
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	bne_cont.44197
bne_else.44196:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
bne_cont.44197:
bne_cont.44195:
bne_cont.44167:
	beq	＄r3, ＄r0, bne_else.44198
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	return
bne_else.44198:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r7, ＄r5, ＄r28
	slli	＄r3, ＄r7, 0
	add	＄r28, ＄r4, ＄r3
	ldi	＄r5, ＄r28, 0
	beq	＄r5, ＄r30, bne_else.44199
	slli	＄r3, ＄r5, 0
	ldi	＄r6, ＄r3, 522
	ldi	＄r3, ＄r6, 5
	fldi	＄f0, ＄r3, 0
	fsub	＄f0, ＄f5, ＄f0
	fldi	＄f1, ＄r3, 1
	fsub	＄f2, ＄f4, ＄f1
	fldi	＄f1, ＄r3, 2
	fsub	＄f1, ＄f3, ＄f1
	ldi	＄r5, ＄r6, 1
	beq	＄r5, ＄r29, bne_else.44200
	mvhi	＄r3, 0
	mvlo	＄r3, 2
	beq	＄r5, ＄r3, bne_else.44202
	fmul	＄f7, ＄f0, ＄f0
	ldi	＄r3, ＄r6, 4
	fldi	＄f6, ＄r3, 0
	fmul	＄f8, ＄f7, ＄f6
	fmul	＄f7, ＄f2, ＄f2
	fldi	＄f6, ＄r3, 1
	fmul	＄f6, ＄f7, ＄f6
	fadd	＄f8, ＄f8, ＄f6
	fmul	＄f7, ＄f1, ＄f1
	fldi	＄f6, ＄r3, 2
	fmul	＄f6, ＄f7, ＄f6
	fadd	＄f7, ＄f8, ＄f6
	ldi	＄r3, ＄r6, 3
	beq	＄r3, ＄r0, bne_else.44204
	fmul	＄f8, ＄f2, ＄f1
	ldi	＄r3, ＄r6, 9
	fldi	＄f6, ＄r3, 0
	fmul	＄f6, ＄f8, ＄f6
	fadd	＄f7, ＄f7, ＄f6
	fmul	＄f6, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fmul	＄f1, ＄f6, ＄f1
	fadd	＄f7, ＄f7, ＄f1
	fmul	＄f1, ＄f0, ＄f2
	fldi	＄f0, ＄r3, 2
	fmul	＄f6, ＄f1, ＄f0
	fadd	＄f6, ＄f7, ＄f6
	j	bne_cont.44205
bne_else.44204:
	fmov	＄f6, ＄f7
bne_cont.44205:
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	beq	＄r5, ＄r3, bne_else.44206
	fmov	＄f0, ＄f6
	j	bne_cont.44207
bne_else.44206:
	fsub	＄f0, ＄f6, ＄f17
bne_cont.44207:
	ldi	＄r3, ＄r6, 6
	fblt	＄f0, ＄f16, fbge_else.44208
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	j	fbge_cont.44209
fbge_else.44208:
	mvhi	＄r5, 0
	mvlo	＄r5, 1
fbge_cont.44209:
	beq	＄r3, ＄r5, bne_else.44210
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	bne_cont.44211
bne_else.44210:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
bne_cont.44211:
	j	bne_cont.44203
bne_else.44202:
	ldi	＄r3, ＄r6, 4
	fldi	＄f6, ＄r3, 0
	fmul	＄f6, ＄f6, ＄f0
	fldi	＄f0, ＄r3, 1
	fmul	＄f0, ＄f0, ＄f2
	fadd	＄f2, ＄f6, ＄f0
	fldi	＄f0, ＄r3, 2
	fmul	＄f0, ＄f0, ＄f1
	fadd	＄f0, ＄f2, ＄f0
	ldi	＄r3, ＄r6, 6
	fblt	＄f0, ＄f16, fbge_else.44212
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	j	fbge_cont.44213
fbge_else.44212:
	mvhi	＄r5, 0
	mvlo	＄r5, 1
fbge_cont.44213:
	beq	＄r3, ＄r5, bne_else.44214
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	bne_cont.44215
bne_else.44214:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
bne_cont.44215:
bne_cont.44203:
	j	bne_cont.44201
bne_else.44200:
	fblt	＄f0, ＄f16, fbge_else.44216
	fmov	＄f6, ＄f0
	j	fbge_cont.44217
fbge_else.44216:
	fneg	＄f6, ＄f0
fbge_cont.44217:
	ldi	＄r3, ＄r6, 4
	fldi	＄f0, ＄r3, 0
	fblt	＄f6, ＄f0, fbge_else.44218
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	j	fbge_cont.44219
fbge_else.44218:
	fblt	＄f2, ＄f16, fbge_else.44220
	fmov	＄f0, ＄f2
	j	fbge_cont.44221
fbge_else.44220:
	fneg	＄f0, ＄f2
fbge_cont.44221:
	fldi	＄f2, ＄r3, 1
	fblt	＄f0, ＄f2, fbge_else.44222
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	j	fbge_cont.44223
fbge_else.44222:
	fblt	＄f1, ＄f16, fbge_else.44224
	fmov	＄f0, ＄f1
	j	fbge_cont.44225
fbge_else.44224:
	fneg	＄f0, ＄f1
fbge_cont.44225:
	fldi	＄f1, ＄r3, 2
	fblt	＄f0, ＄f1, fbge_else.44226
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	j	fbge_cont.44227
fbge_else.44226:
	mvhi	＄r5, 0
	mvlo	＄r5, 1
fbge_cont.44227:
fbge_cont.44223:
fbge_cont.44219:
	beq	＄r5, ＄r0, bne_else.44228
	ldi	＄r3, ＄r6, 6
	j	bne_cont.44229
bne_else.44228:
	ldi	＄r3, ＄r6, 6
	beq	＄r3, ＄r0, bne_else.44230
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	bne_cont.44231
bne_else.44230:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
bne_cont.44231:
bne_cont.44229:
bne_cont.44201:
	beq	＄r3, ＄r0, bne_else.44232
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	return
bne_else.44232:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r5, ＄r7, ＄r28
	j	check_all_inside.2890
bne_else.44199:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	return
bne_else.44165:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	return

#---------------------------------------------------------------------
# args = [＄r8, ＄r4]
# fargs = []
# ret type = Bool
#---------------------------------------------------------------------
shadow_check_and_group.2896:
	slli	＄r3, ＄r8, 0
	add	＄r28, ＄r4, ＄r3
	ldi	＄r9, ＄r28, 0
	beq	＄r9, ＄r30, bne_else.44233
	slli	＄r3, ＄r9, 0
	ldi	＄r6, ＄r3, 522
	fldi	＄f1, ＄r0, 455
	ldi	＄r3, ＄r6, 5
	fldi	＄f0, ＄r3, 0
	fsub	＄f3, ＄f1, ＄f0
	fldi	＄f1, ＄r0, 456
	fldi	＄f0, ＄r3, 1
	fsub	＄f4, ＄f1, ＄f0
	fldi	＄f1, ＄r0, 457
	fldi	＄f0, ＄r3, 2
	fsub	＄f2, ＄f1, ＄f0
	slli	＄r3, ＄r9, 0
	ldi	＄r7, ＄r3, 347
	ldi	＄r5, ＄r6, 1
	beq	＄r5, ＄r29, bne_else.44234
	mvhi	＄r3, 0
	mvlo	＄r3, 2
	beq	＄r5, ＄r3, bne_else.44236
	fldi	＄f0, ＄r7, 0
	fbne	＄f0, ＄f16, fbeq_else.44238
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbeq_cont.44239
fbeq_else.44238:
	fldi	＄f1, ＄r7, 1
	fmul	＄f5, ＄f1, ＄f3
	fldi	＄f1, ＄r7, 2
	fmul	＄f1, ＄f1, ＄f4
	fadd	＄f5, ＄f5, ＄f1
	fldi	＄f1, ＄r7, 3
	fmul	＄f1, ＄f1, ＄f2
	fadd	＄f1, ＄f5, ＄f1
	fmul	＄f6, ＄f3, ＄f3
	ldi	＄r3, ＄r6, 4
	fldi	＄f5, ＄r3, 0
	fmul	＄f7, ＄f6, ＄f5
	fmul	＄f6, ＄f4, ＄f4
	fldi	＄f5, ＄r3, 1
	fmul	＄f5, ＄f6, ＄f5
	fadd	＄f7, ＄f7, ＄f5
	fmul	＄f6, ＄f2, ＄f2
	fldi	＄f5, ＄r3, 2
	fmul	＄f5, ＄f6, ＄f5
	fadd	＄f6, ＄f7, ＄f5
	ldi	＄r3, ＄r6, 3
	beq	＄r3, ＄r0, bne_else.44240
	fmul	＄f7, ＄f4, ＄f2
	ldi	＄r3, ＄r6, 9
	fldi	＄f5, ＄r3, 0
	fmul	＄f5, ＄f7, ＄f5
	fadd	＄f6, ＄f6, ＄f5
	fmul	＄f5, ＄f2, ＄f3
	fldi	＄f2, ＄r3, 1
	fmul	＄f2, ＄f5, ＄f2
	fadd	＄f6, ＄f6, ＄f2
	fmul	＄f3, ＄f3, ＄f4
	fldi	＄f2, ＄r3, 2
	fmul	＄f5, ＄f3, ＄f2
	fadd	＄f5, ＄f6, ＄f5
	j	bne_cont.44241
bne_else.44240:
	fmov	＄f5, ＄f6
bne_cont.44241:
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	beq	＄r5, ＄r3, bne_else.44242
	fmov	＄f2, ＄f5
	j	bne_cont.44243
bne_else.44242:
	fsub	＄f2, ＄f5, ＄f17
bne_cont.44243:
	fmul	＄f3, ＄f1, ＄f1
	fmul	＄f0, ＄f0, ＄f2
	fsub	＄f0, ＄f3, ＄f0
	fblt	＄f16, ＄f0, fbge_else.44244
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44245
fbge_else.44244:
	ldi	＄r3, ＄r6, 6
	beq	＄r3, ＄r0, bne_else.44246
	fsqrt	＄f0, ＄f0
	fadd	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r7, 4
	fmul	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 460
	j	bne_cont.44247
bne_else.44246:
	fsqrt	＄f0, ＄f0
	fsub	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r7, 4
	fmul	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 460
bne_cont.44247:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.44245:
fbeq_cont.44239:
	j	bne_cont.44237
bne_else.44236:
	fldi	＄f0, ＄r7, 0
	fblt	＄f0, ＄f16, fbge_else.44248
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44249
fbge_else.44248:
	fldi	＄f0, ＄r7, 1
	fmul	＄f1, ＄f0, ＄f3
	fldi	＄f0, ＄r7, 2
	fmul	＄f0, ＄f0, ＄f4
	fadd	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r7, 3
	fmul	＄f0, ＄f0, ＄f2
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 460
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.44249:
bne_cont.44237:
	j	bne_cont.44235
bne_else.44234:
	fldi	＄f0, ＄r7, 0
	fsub	＄f0, ＄f0, ＄f3
	fldi	＄f1, ＄r7, 1
	fmul	＄f0, ＄f0, ＄f1
	fldi	＄f5, ＄r0, 408
	fmul	＄f5, ＄f0, ＄f5
	fadd	＄f6, ＄f5, ＄f4
	fblt	＄f6, ＄f16, fbge_else.44250
	fmov	＄f5, ＄f6
	j	fbge_cont.44251
fbge_else.44250:
	fneg	＄f5, ＄f6
fbge_cont.44251:
	ldi	＄r5, ＄r6, 4
	fldi	＄f6, ＄r5, 1
	fblt	＄f5, ＄f6, fbge_else.44252
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44253
fbge_else.44252:
	fldi	＄f5, ＄r0, 409
	fmul	＄f5, ＄f0, ＄f5
	fadd	＄f6, ＄f5, ＄f2
	fblt	＄f6, ＄f16, fbge_else.44254
	fmov	＄f5, ＄f6
	j	fbge_cont.44255
fbge_else.44254:
	fneg	＄f5, ＄f6
fbge_cont.44255:
	fldi	＄f6, ＄r5, 2
	fblt	＄f5, ＄f6, fbge_else.44256
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44257
fbge_else.44256:
	fbne	＄f1, ＄f16, fbeq_else.44258
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbeq_cont.44259
fbeq_else.44258:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbeq_cont.44259:
fbge_cont.44257:
fbge_cont.44253:
	beq	＄r3, ＄r0, bne_else.44260
	fsti	＄f0, ＄r0, 460
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	bne_cont.44261
bne_else.44260:
	fldi	＄f0, ＄r7, 2
	fsub	＄f0, ＄f0, ＄f4
	fldi	＄f1, ＄r7, 3
	fmul	＄f0, ＄f0, ＄f1
	fldi	＄f5, ＄r0, 407
	fmul	＄f5, ＄f0, ＄f5
	fadd	＄f6, ＄f5, ＄f3
	fblt	＄f6, ＄f16, fbge_else.44262
	fmov	＄f5, ＄f6
	j	fbge_cont.44263
fbge_else.44262:
	fneg	＄f5, ＄f6
fbge_cont.44263:
	fldi	＄f6, ＄r5, 0
	fblt	＄f5, ＄f6, fbge_else.44264
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44265
fbge_else.44264:
	fldi	＄f5, ＄r0, 409
	fmul	＄f5, ＄f0, ＄f5
	fadd	＄f6, ＄f5, ＄f2
	fblt	＄f6, ＄f16, fbge_else.44266
	fmov	＄f5, ＄f6
	j	fbge_cont.44267
fbge_else.44266:
	fneg	＄f5, ＄f6
fbge_cont.44267:
	fldi	＄f6, ＄r5, 2
	fblt	＄f5, ＄f6, fbge_else.44268
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44269
fbge_else.44268:
	fbne	＄f1, ＄f16, fbeq_else.44270
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbeq_cont.44271
fbeq_else.44270:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbeq_cont.44271:
fbge_cont.44269:
fbge_cont.44265:
	beq	＄r3, ＄r0, bne_else.44272
	fsti	＄f0, ＄r0, 460
	mvhi	＄r3, 0
	mvlo	＄r3, 2
	j	bne_cont.44273
bne_else.44272:
	fldi	＄f0, ＄r7, 4
	fsub	＄f0, ＄f0, ＄f2
	fldi	＄f1, ＄r7, 5
	fmul	＄f0, ＄f0, ＄f1
	fldi	＄f2, ＄r0, 407
	fmul	＄f2, ＄f0, ＄f2
	fadd	＄f3, ＄f2, ＄f3
	fblt	＄f3, ＄f16, fbge_else.44274
	fmov	＄f2, ＄f3
	j	fbge_cont.44275
fbge_else.44274:
	fneg	＄f2, ＄f3
fbge_cont.44275:
	fldi	＄f3, ＄r5, 0
	fblt	＄f2, ＄f3, fbge_else.44276
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44277
fbge_else.44276:
	fldi	＄f2, ＄r0, 408
	fmul	＄f2, ＄f0, ＄f2
	fadd	＄f3, ＄f2, ＄f4
	fblt	＄f3, ＄f16, fbge_else.44278
	fmov	＄f2, ＄f3
	j	fbge_cont.44279
fbge_else.44278:
	fneg	＄f2, ＄f3
fbge_cont.44279:
	fldi	＄f3, ＄r5, 1
	fblt	＄f2, ＄f3, fbge_else.44280
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44281
fbge_else.44280:
	fbne	＄f1, ＄f16, fbeq_else.44282
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbeq_cont.44283
fbeq_else.44282:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbeq_cont.44283:
fbge_cont.44281:
fbge_cont.44277:
	beq	＄r3, ＄r0, bne_else.44284
	fsti	＄f0, ＄r0, 460
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	j	bne_cont.44285
bne_else.44284:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.44285:
bne_cont.44273:
bne_cont.44261:
bne_cont.44235:
	fldi	＄f0, ＄r0, 460
	beq	＄r3, ＄r0, bne_else.44286
	# -0.200000
	fmvhi	＄f1, 48716
	fmvlo	＄f1, 52420
	fblt	＄f0, ＄f1, fbge_else.44288
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44289
fbge_else.44288:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.44289:
	j	bne_cont.44287
bne_else.44286:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.44287:
	beq	＄r3, ＄r0, bne_else.44290
	# 0.010000
	fmvhi	＄f1, 15395
	fmvlo	＄f1, 55050
	fadd	＄f0, ＄f0, ＄f1
	fldi	＄f1, ＄r0, 513
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r0, 455
	fadd	＄f5, ＄f2, ＄f1
	fldi	＄f1, ＄r0, 514
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r0, 456
	fadd	＄f4, ＄f2, ＄f1
	fldi	＄f1, ＄r0, 515
	fmul	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r0, 457
	fadd	＄f3, ＄f1, ＄f0
	ldi	＄r5, ＄r4, 0
	sti	＄r4, ＄r1, 0
	beq	＄r5, ＄r30, bne_else.44291
	slli	＄r3, ＄r5, 0
	ldi	＄r6, ＄r3, 522
	ldi	＄r3, ＄r6, 5
	fldi	＄f0, ＄r3, 0
	fsub	＄f0, ＄f5, ＄f0
	fldi	＄f1, ＄r3, 1
	fsub	＄f2, ＄f4, ＄f1
	fldi	＄f1, ＄r3, 2
	fsub	＄f1, ＄f3, ＄f1
	ldi	＄r5, ＄r6, 1
	beq	＄r5, ＄r29, bne_else.44293
	mvhi	＄r3, 0
	mvlo	＄r3, 2
	beq	＄r5, ＄r3, bne_else.44295
	fmul	＄f7, ＄f0, ＄f0
	ldi	＄r3, ＄r6, 4
	fldi	＄f6, ＄r3, 0
	fmul	＄f8, ＄f7, ＄f6
	fmul	＄f7, ＄f2, ＄f2
	fldi	＄f6, ＄r3, 1
	fmul	＄f6, ＄f7, ＄f6
	fadd	＄f8, ＄f8, ＄f6
	fmul	＄f7, ＄f1, ＄f1
	fldi	＄f6, ＄r3, 2
	fmul	＄f6, ＄f7, ＄f6
	fadd	＄f7, ＄f8, ＄f6
	ldi	＄r3, ＄r6, 3
	beq	＄r3, ＄r0, bne_else.44297
	fmul	＄f8, ＄f2, ＄f1
	ldi	＄r3, ＄r6, 9
	fldi	＄f6, ＄r3, 0
	fmul	＄f6, ＄f8, ＄f6
	fadd	＄f7, ＄f7, ＄f6
	fmul	＄f6, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fmul	＄f1, ＄f6, ＄f1
	fadd	＄f7, ＄f7, ＄f1
	fmul	＄f1, ＄f0, ＄f2
	fldi	＄f0, ＄r3, 2
	fmul	＄f6, ＄f1, ＄f0
	fadd	＄f6, ＄f7, ＄f6
	j	bne_cont.44298
bne_else.44297:
	fmov	＄f6, ＄f7
bne_cont.44298:
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	beq	＄r5, ＄r3, bne_else.44299
	fmov	＄f0, ＄f6
	j	bne_cont.44300
bne_else.44299:
	fsub	＄f0, ＄f6, ＄f17
bne_cont.44300:
	ldi	＄r3, ＄r6, 6
	fblt	＄f0, ＄f16, fbge_else.44301
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	j	fbge_cont.44302
fbge_else.44301:
	mvhi	＄r5, 0
	mvlo	＄r5, 1
fbge_cont.44302:
	beq	＄r3, ＄r5, bne_else.44303
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	bne_cont.44304
bne_else.44303:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
bne_cont.44304:
	j	bne_cont.44296
bne_else.44295:
	ldi	＄r3, ＄r6, 4
	fldi	＄f6, ＄r3, 0
	fmul	＄f6, ＄f6, ＄f0
	fldi	＄f0, ＄r3, 1
	fmul	＄f0, ＄f0, ＄f2
	fadd	＄f2, ＄f6, ＄f0
	fldi	＄f0, ＄r3, 2
	fmul	＄f0, ＄f0, ＄f1
	fadd	＄f0, ＄f2, ＄f0
	ldi	＄r3, ＄r6, 6
	fblt	＄f0, ＄f16, fbge_else.44305
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	j	fbge_cont.44306
fbge_else.44305:
	mvhi	＄r5, 0
	mvlo	＄r5, 1
fbge_cont.44306:
	beq	＄r3, ＄r5, bne_else.44307
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	bne_cont.44308
bne_else.44307:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
bne_cont.44308:
bne_cont.44296:
	j	bne_cont.44294
bne_else.44293:
	fblt	＄f0, ＄f16, fbge_else.44309
	fmov	＄f6, ＄f0
	j	fbge_cont.44310
fbge_else.44309:
	fneg	＄f6, ＄f0
fbge_cont.44310:
	ldi	＄r3, ＄r6, 4
	fldi	＄f0, ＄r3, 0
	fblt	＄f6, ＄f0, fbge_else.44311
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	j	fbge_cont.44312
fbge_else.44311:
	fblt	＄f2, ＄f16, fbge_else.44313
	fmov	＄f0, ＄f2
	j	fbge_cont.44314
fbge_else.44313:
	fneg	＄f0, ＄f2
fbge_cont.44314:
	fldi	＄f2, ＄r3, 1
	fblt	＄f0, ＄f2, fbge_else.44315
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	j	fbge_cont.44316
fbge_else.44315:
	fblt	＄f1, ＄f16, fbge_else.44317
	fmov	＄f0, ＄f1
	j	fbge_cont.44318
fbge_else.44317:
	fneg	＄f0, ＄f1
fbge_cont.44318:
	fldi	＄f1, ＄r3, 2
	fblt	＄f0, ＄f1, fbge_else.44319
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	j	fbge_cont.44320
fbge_else.44319:
	mvhi	＄r5, 0
	mvlo	＄r5, 1
fbge_cont.44320:
fbge_cont.44316:
fbge_cont.44312:
	beq	＄r5, ＄r0, bne_else.44321
	ldi	＄r3, ＄r6, 6
	j	bne_cont.44322
bne_else.44321:
	ldi	＄r3, ＄r6, 6
	beq	＄r3, ＄r0, bne_else.44323
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	bne_cont.44324
bne_else.44323:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
bne_cont.44324:
bne_cont.44322:
bne_cont.44294:
	beq	＄r3, ＄r0, bne_else.44325
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	bne_cont.44326
bne_else.44325:
	mvhi	＄r5, 0
	mvlo	＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	check_all_inside.2890
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
bne_cont.44326:
	j	bne_cont.44292
bne_else.44291:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
bne_cont.44292:
	beq	＄r3, ＄r0, bne_else.44327
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	return
bne_else.44327:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r8, ＄r8, ＄r28
	ldi	＄r4, ＄r1, 0
	j	shadow_check_and_group.2896
bne_else.44290:
	slli	＄r3, ＄r9, 0
	ldi	＄r3, ＄r3, 522
	ldi	＄r3, ＄r3, 6
	beq	＄r3, ＄r0, bne_else.44328
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r8, ＄r8, ＄r28
	j	shadow_check_and_group.2896
bne_else.44328:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	return
bne_else.44233:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	return

#---------------------------------------------------------------------
# args = [＄r11, ＄r10]
# fargs = []
# ret type = Bool
#---------------------------------------------------------------------
shadow_check_one_or_group.2899:
	slli	＄r3, ＄r11, 0
	add	＄r28, ＄r10, ＄r3
	ldi	＄r4, ＄r28, 0
	beq	＄r4, ＄r30, bne_else.44329
	slli	＄r3, ＄r4, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_and_group.2896
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.44330
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	return
bne_else.44330:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r11, ＄r11, ＄r28
	slli	＄r3, ＄r11, 0
	add	＄r28, ＄r10, ＄r3
	ldi	＄r4, ＄r28, 0
	beq	＄r4, ＄r30, bne_else.44331
	slli	＄r3, ＄r4, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_and_group.2896
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.44332
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	return
bne_else.44332:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r11, ＄r11, ＄r28
	slli	＄r3, ＄r11, 0
	add	＄r28, ＄r10, ＄r3
	ldi	＄r4, ＄r28, 0
	beq	＄r4, ＄r30, bne_else.44333
	slli	＄r3, ＄r4, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_and_group.2896
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.44334
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	return
bne_else.44334:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r11, ＄r11, ＄r28
	slli	＄r3, ＄r11, 0
	add	＄r28, ＄r10, ＄r3
	ldi	＄r4, ＄r28, 0
	beq	＄r4, ＄r30, bne_else.44335
	slli	＄r3, ＄r4, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_and_group.2896
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.44336
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	return
bne_else.44336:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r11, ＄r11, ＄r28
	slli	＄r3, ＄r11, 0
	add	＄r28, ＄r10, ＄r3
	ldi	＄r4, ＄r28, 0
	beq	＄r4, ＄r30, bne_else.44337
	slli	＄r3, ＄r4, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_and_group.2896
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.44338
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	return
bne_else.44338:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r11, ＄r11, ＄r28
	slli	＄r3, ＄r11, 0
	add	＄r28, ＄r10, ＄r3
	ldi	＄r4, ＄r28, 0
	beq	＄r4, ＄r30, bne_else.44339
	slli	＄r3, ＄r4, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_and_group.2896
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.44340
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	return
bne_else.44340:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r11, ＄r11, ＄r28
	slli	＄r3, ＄r11, 0
	add	＄r28, ＄r10, ＄r3
	ldi	＄r4, ＄r28, 0
	beq	＄r4, ＄r30, bne_else.44341
	slli	＄r3, ＄r4, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_and_group.2896
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.44342
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	return
bne_else.44342:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r11, ＄r11, ＄r28
	slli	＄r3, ＄r11, 0
	add	＄r28, ＄r10, ＄r3
	ldi	＄r4, ＄r28, 0
	beq	＄r4, ＄r30, bne_else.44343
	slli	＄r3, ＄r4, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_and_group.2896
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.44344
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	return
bne_else.44344:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r11, ＄r11, ＄r28
	j	shadow_check_one_or_group.2899
bne_else.44343:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	return
bne_else.44341:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	return
bne_else.44339:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	return
bne_else.44337:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	return
bne_else.44335:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	return
bne_else.44333:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	return
bne_else.44331:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	return
bne_else.44329:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	return

#---------------------------------------------------------------------
# args = [＄r12, ＄r13]
# fargs = []
# ret type = Bool
#---------------------------------------------------------------------
shadow_check_one_or_matrix.2902:
	slli	＄r3, ＄r12, 0
	add	＄r28, ＄r13, ＄r3
	ldi	＄r10, ＄r28, 0
	ldi	＄r4, ＄r10, 0
	beq	＄r4, ＄r30, bne_else.44345
	mvhi	＄r3, 0
	mvlo	＄r3, 99
	sti	＄r10, ＄r1, 0
	beq	＄r4, ＄r3, bne_else.44346
	slli	＄r3, ＄r4, 0
	ldi	＄r5, ＄r3, 522
	fldi	＄f1, ＄r0, 455
	ldi	＄r3, ＄r5, 5
	fldi	＄f0, ＄r3, 0
	fsub	＄f3, ＄f1, ＄f0
	fldi	＄f1, ＄r0, 456
	fldi	＄f0, ＄r3, 1
	fsub	＄f4, ＄f1, ＄f0
	fldi	＄f1, ＄r0, 457
	fldi	＄f0, ＄r3, 2
	fsub	＄f2, ＄f1, ＄f0
	slli	＄r3, ＄r4, 0
	ldi	＄r6, ＄r3, 347
	ldi	＄r4, ＄r5, 1
	beq	＄r4, ＄r29, bne_else.44348
	mvhi	＄r3, 0
	mvlo	＄r3, 2
	beq	＄r4, ＄r3, bne_else.44350
	fldi	＄f0, ＄r6, 0
	fbne	＄f0, ＄f16, fbeq_else.44352
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbeq_cont.44353
fbeq_else.44352:
	fldi	＄f1, ＄r6, 1
	fmul	＄f5, ＄f1, ＄f3
	fldi	＄f1, ＄r6, 2
	fmul	＄f1, ＄f1, ＄f4
	fadd	＄f5, ＄f5, ＄f1
	fldi	＄f1, ＄r6, 3
	fmul	＄f1, ＄f1, ＄f2
	fadd	＄f1, ＄f5, ＄f1
	fmul	＄f6, ＄f3, ＄f3
	ldi	＄r3, ＄r5, 4
	fldi	＄f5, ＄r3, 0
	fmul	＄f7, ＄f6, ＄f5
	fmul	＄f6, ＄f4, ＄f4
	fldi	＄f5, ＄r3, 1
	fmul	＄f5, ＄f6, ＄f5
	fadd	＄f7, ＄f7, ＄f5
	fmul	＄f6, ＄f2, ＄f2
	fldi	＄f5, ＄r3, 2
	fmul	＄f5, ＄f6, ＄f5
	fadd	＄f6, ＄f7, ＄f5
	ldi	＄r3, ＄r5, 3
	beq	＄r3, ＄r0, bne_else.44354
	fmul	＄f7, ＄f4, ＄f2
	ldi	＄r3, ＄r5, 9
	fldi	＄f5, ＄r3, 0
	fmul	＄f5, ＄f7, ＄f5
	fadd	＄f6, ＄f6, ＄f5
	fmul	＄f5, ＄f2, ＄f3
	fldi	＄f2, ＄r3, 1
	fmul	＄f2, ＄f5, ＄f2
	fadd	＄f6, ＄f6, ＄f2
	fmul	＄f3, ＄f3, ＄f4
	fldi	＄f2, ＄r3, 2
	fmul	＄f5, ＄f3, ＄f2
	fadd	＄f5, ＄f6, ＄f5
	j	bne_cont.44355
bne_else.44354:
	fmov	＄f5, ＄f6
bne_cont.44355:
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	beq	＄r4, ＄r3, bne_else.44356
	fmov	＄f2, ＄f5
	j	bne_cont.44357
bne_else.44356:
	fsub	＄f2, ＄f5, ＄f17
bne_cont.44357:
	fmul	＄f3, ＄f1, ＄f1
	fmul	＄f0, ＄f0, ＄f2
	fsub	＄f0, ＄f3, ＄f0
	fblt	＄f16, ＄f0, fbge_else.44358
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44359
fbge_else.44358:
	ldi	＄r3, ＄r5, 6
	beq	＄r3, ＄r0, bne_else.44360
	fsqrt	＄f0, ＄f0
	fadd	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r6, 4
	fmul	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 460
	j	bne_cont.44361
bne_else.44360:
	fsqrt	＄f0, ＄f0
	fsub	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r6, 4
	fmul	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 460
bne_cont.44361:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.44359:
fbeq_cont.44353:
	j	bne_cont.44351
bne_else.44350:
	fldi	＄f0, ＄r6, 0
	fblt	＄f0, ＄f16, fbge_else.44362
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44363
fbge_else.44362:
	fldi	＄f0, ＄r6, 1
	fmul	＄f1, ＄f0, ＄f3
	fldi	＄f0, ＄r6, 2
	fmul	＄f0, ＄f0, ＄f4
	fadd	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r6, 3
	fmul	＄f0, ＄f0, ＄f2
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 460
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.44363:
bne_cont.44351:
	j	bne_cont.44349
bne_else.44348:
	fldi	＄f0, ＄r6, 0
	fsub	＄f0, ＄f0, ＄f3
	fldi	＄f1, ＄r6, 1
	fmul	＄f0, ＄f0, ＄f1
	fldi	＄f5, ＄r0, 408
	fmul	＄f5, ＄f0, ＄f5
	fadd	＄f6, ＄f5, ＄f4
	fblt	＄f6, ＄f16, fbge_else.44364
	fmov	＄f5, ＄f6
	j	fbge_cont.44365
fbge_else.44364:
	fneg	＄f5, ＄f6
fbge_cont.44365:
	ldi	＄r4, ＄r5, 4
	fldi	＄f6, ＄r4, 1
	fblt	＄f5, ＄f6, fbge_else.44366
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44367
fbge_else.44366:
	fldi	＄f5, ＄r0, 409
	fmul	＄f5, ＄f0, ＄f5
	fadd	＄f6, ＄f5, ＄f2
	fblt	＄f6, ＄f16, fbge_else.44368
	fmov	＄f5, ＄f6
	j	fbge_cont.44369
fbge_else.44368:
	fneg	＄f5, ＄f6
fbge_cont.44369:
	fldi	＄f6, ＄r4, 2
	fblt	＄f5, ＄f6, fbge_else.44370
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44371
fbge_else.44370:
	fbne	＄f1, ＄f16, fbeq_else.44372
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbeq_cont.44373
fbeq_else.44372:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbeq_cont.44373:
fbge_cont.44371:
fbge_cont.44367:
	beq	＄r3, ＄r0, bne_else.44374
	fsti	＄f0, ＄r0, 460
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	bne_cont.44375
bne_else.44374:
	fldi	＄f0, ＄r6, 2
	fsub	＄f1, ＄f0, ＄f4
	fldi	＄f0, ＄r6, 3
	fmul	＄f6, ＄f1, ＄f0
	fldi	＄f1, ＄r0, 407
	fmul	＄f1, ＄f6, ＄f1
	fadd	＄f5, ＄f1, ＄f3
	fblt	＄f5, ＄f16, fbge_else.44376
	fmov	＄f1, ＄f5
	j	fbge_cont.44377
fbge_else.44376:
	fneg	＄f1, ＄f5
fbge_cont.44377:
	fldi	＄f5, ＄r4, 0
	fblt	＄f1, ＄f5, fbge_else.44378
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44379
fbge_else.44378:
	fldi	＄f1, ＄r0, 409
	fmul	＄f1, ＄f6, ＄f1
	fadd	＄f5, ＄f1, ＄f2
	fblt	＄f5, ＄f16, fbge_else.44380
	fmov	＄f1, ＄f5
	j	fbge_cont.44381
fbge_else.44380:
	fneg	＄f1, ＄f5
fbge_cont.44381:
	fldi	＄f5, ＄r4, 2
	fblt	＄f1, ＄f5, fbge_else.44382
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44383
fbge_else.44382:
	fbne	＄f0, ＄f16, fbeq_else.44384
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbeq_cont.44385
fbeq_else.44384:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbeq_cont.44385:
fbge_cont.44383:
fbge_cont.44379:
	beq	＄r3, ＄r0, bne_else.44386
	fsti	＄f6, ＄r0, 460
	mvhi	＄r3, 0
	mvlo	＄r3, 2
	j	bne_cont.44387
bne_else.44386:
	fldi	＄f0, ＄r6, 4
	fsub	＄f0, ＄f0, ＄f2
	fldi	＄f5, ＄r6, 5
	fmul	＄f2, ＄f0, ＄f5
	fldi	＄f0, ＄r0, 407
	fmul	＄f0, ＄f2, ＄f0
	fadd	＄f1, ＄f0, ＄f3
	fblt	＄f1, ＄f16, fbge_else.44388
	fmov	＄f0, ＄f1
	j	fbge_cont.44389
fbge_else.44388:
	fneg	＄f0, ＄f1
fbge_cont.44389:
	fldi	＄f1, ＄r4, 0
	fblt	＄f0, ＄f1, fbge_else.44390
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44391
fbge_else.44390:
	fldi	＄f0, ＄r0, 408
	fmul	＄f0, ＄f2, ＄f0
	fadd	＄f1, ＄f0, ＄f4
	fblt	＄f1, ＄f16, fbge_else.44392
	fmov	＄f0, ＄f1
	j	fbge_cont.44393
fbge_else.44392:
	fneg	＄f0, ＄f1
fbge_cont.44393:
	fldi	＄f1, ＄r4, 1
	fblt	＄f0, ＄f1, fbge_else.44394
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44395
fbge_else.44394:
	fbne	＄f5, ＄f16, fbeq_else.44396
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbeq_cont.44397
fbeq_else.44396:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbeq_cont.44397:
fbge_cont.44395:
fbge_cont.44391:
	beq	＄r3, ＄r0, bne_else.44398
	fsti	＄f2, ＄r0, 460
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	j	bne_cont.44399
bne_else.44398:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.44399:
bne_cont.44387:
bne_cont.44375:
bne_cont.44349:
	beq	＄r3, ＄r0, bne_else.44400
	fldi	＄f1, ＄r0, 460
	# -0.100000
	fmvhi	＄f0, 48588
	fmvlo	＄f0, 52420
	fblt	＄f1, ＄f0, fbge_else.44402
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44403
fbge_else.44402:
	ldi	＄r4, ＄r10, 1
	beq	＄r4, ＄r30, bne_else.44404
	slli	＄r3, ＄r4, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_and_group.2896
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.44406
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	bne_cont.44407
bne_else.44406:
	ldi	＄r4, ＄r10, 2
	beq	＄r4, ＄r30, bne_else.44408
	slli	＄r3, ＄r4, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_and_group.2896
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.44410
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	bne_cont.44411
bne_else.44410:
	ldi	＄r4, ＄r10, 3
	beq	＄r4, ＄r30, bne_else.44412
	slli	＄r3, ＄r4, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_and_group.2896
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.44414
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	bne_cont.44415
bne_else.44414:
	ldi	＄r4, ＄r10, 4
	beq	＄r4, ＄r30, bne_else.44416
	slli	＄r3, ＄r4, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_and_group.2896
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.44418
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	bne_cont.44419
bne_else.44418:
	ldi	＄r4, ＄r10, 5
	beq	＄r4, ＄r30, bne_else.44420
	slli	＄r3, ＄r4, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_and_group.2896
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.44422
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	bne_cont.44423
bne_else.44422:
	ldi	＄r4, ＄r10, 6
	beq	＄r4, ＄r30, bne_else.44424
	slli	＄r3, ＄r4, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_and_group.2896
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.44426
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	bne_cont.44427
bne_else.44426:
	ldi	＄r4, ＄r10, 7
	beq	＄r4, ＄r30, bne_else.44428
	slli	＄r3, ＄r4, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_and_group.2896
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.44430
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	bne_cont.44431
bne_else.44430:
	mvhi	＄r11, 0
	mvlo	＄r11, 8
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_one_or_group.2899
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
bne_cont.44431:
	j	bne_cont.44429
bne_else.44428:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.44429:
bne_cont.44427:
	j	bne_cont.44425
bne_else.44424:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.44425:
bne_cont.44423:
	j	bne_cont.44421
bne_else.44420:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.44421:
bne_cont.44419:
	j	bne_cont.44417
bne_else.44416:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.44417:
bne_cont.44415:
	j	bne_cont.44413
bne_else.44412:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.44413:
bne_cont.44411:
	j	bne_cont.44409
bne_else.44408:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.44409:
bne_cont.44407:
	j	bne_cont.44405
bne_else.44404:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.44405:
	beq	＄r3, ＄r0, bne_else.44432
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	bne_cont.44433
bne_else.44432:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.44433:
fbge_cont.44403:
	j	bne_cont.44401
bne_else.44400:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.44401:
	j	bne_cont.44347
bne_else.44346:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
bne_cont.44347:
	beq	＄r3, ＄r0, bne_else.44434
	ldi	＄r10, ＄r1, 0
	ldi	＄r4, ＄r10, 1
	beq	＄r4, ＄r30, bne_else.44435
	slli	＄r3, ＄r4, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_and_group.2896
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.44437
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	bne_cont.44438
bne_else.44437:
	ldi	＄r4, ＄r10, 2
	beq	＄r4, ＄r30, bne_else.44439
	slli	＄r3, ＄r4, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_and_group.2896
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.44441
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	bne_cont.44442
bne_else.44441:
	ldi	＄r4, ＄r10, 3
	beq	＄r4, ＄r30, bne_else.44443
	slli	＄r3, ＄r4, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_and_group.2896
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.44445
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	bne_cont.44446
bne_else.44445:
	ldi	＄r4, ＄r10, 4
	beq	＄r4, ＄r30, bne_else.44447
	slli	＄r3, ＄r4, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_and_group.2896
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.44449
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	bne_cont.44450
bne_else.44449:
	ldi	＄r4, ＄r10, 5
	beq	＄r4, ＄r30, bne_else.44451
	slli	＄r3, ＄r4, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_and_group.2896
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.44453
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	bne_cont.44454
bne_else.44453:
	ldi	＄r4, ＄r10, 6
	beq	＄r4, ＄r30, bne_else.44455
	slli	＄r3, ＄r4, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_and_group.2896
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.44457
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	bne_cont.44458
bne_else.44457:
	ldi	＄r4, ＄r10, 7
	beq	＄r4, ＄r30, bne_else.44459
	slli	＄r3, ＄r4, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_and_group.2896
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.44461
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	bne_cont.44462
bne_else.44461:
	mvhi	＄r11, 0
	mvlo	＄r11, 8
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_one_or_group.2899
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
bne_cont.44462:
	j	bne_cont.44460
bne_else.44459:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.44460:
bne_cont.44458:
	j	bne_cont.44456
bne_else.44455:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.44456:
bne_cont.44454:
	j	bne_cont.44452
bne_else.44451:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.44452:
bne_cont.44450:
	j	bne_cont.44448
bne_else.44447:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.44448:
bne_cont.44446:
	j	bne_cont.44444
bne_else.44443:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.44444:
bne_cont.44442:
	j	bne_cont.44440
bne_else.44439:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.44440:
bne_cont.44438:
	j	bne_cont.44436
bne_else.44435:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.44436:
	beq	＄r3, ＄r0, bne_else.44463
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	return
bne_else.44463:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r12, ＄r12, ＄r28
	j	shadow_check_one_or_matrix.2902
bne_else.44434:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r12, ＄r12, ＄r28
	j	shadow_check_one_or_matrix.2902
bne_else.44345:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	return

#---------------------------------------------------------------------
# args = [＄r11, ＄r4, ＄r9]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
solve_each_element.2905:
	slli	＄r3, ＄r11, 0
	add	＄r28, ＄r4, ＄r3
	ldi	＄r10, ＄r28, 0
	beq	＄r10, ＄r30, bne_else.44464
	slli	＄r3, ＄r10, 0
	ldi	＄r7, ＄r3, 522
	fldi	＄f1, ＄r0, 434
	ldi	＄r3, ＄r7, 5
	fldi	＄f0, ＄r3, 0
	fsub	＄f7, ＄f1, ＄f0
	fldi	＄f1, ＄r0, 435
	fldi	＄f0, ＄r3, 1
	fsub	＄f8, ＄f1, ＄f0
	fldi	＄f1, ＄r0, 436
	fldi	＄f0, ＄r3, 2
	fsub	＄f6, ＄f1, ＄f0
	ldi	＄r3, ＄r7, 1
	beq	＄r3, ＄r29, bne_else.44465
	mvhi	＄r8, 0
	mvlo	＄r8, 2
	beq	＄r3, ＄r8, bne_else.44467
	fldi	＄f2, ＄r9, 0
	fldi	＄f3, ＄r9, 1
	fldi	＄f1, ＄r9, 2
	fmul	＄f0, ＄f2, ＄f2
	ldi	＄r5, ＄r7, 4
	fldi	＄f11, ＄r5, 0
	fmul	＄f4, ＄f0, ＄f11
	fmul	＄f0, ＄f3, ＄f3
	fldi	＄f13, ＄r5, 1
	fmul	＄f0, ＄f0, ＄f13
	fadd	＄f4, ＄f4, ＄f0
	fmul	＄f0, ＄f1, ＄f1
	fldi	＄f12, ＄r5, 2
	fmul	＄f0, ＄f0, ＄f12
	fadd	＄f0, ＄f4, ＄f0
	ldi	＄r6, ＄r7, 3
	beq	＄r6, ＄r0, bne_else.44469
	fmul	＄f5, ＄f3, ＄f1
	ldi	＄r5, ＄r7, 9
	fldi	＄f4, ＄r5, 0
	fmul	＄f4, ＄f5, ＄f4
	fadd	＄f4, ＄f0, ＄f4
	fmul	＄f5, ＄f1, ＄f2
	fldi	＄f0, ＄r5, 1
	fmul	＄f0, ＄f5, ＄f0
	fadd	＄f4, ＄f4, ＄f0
	fmul	＄f5, ＄f2, ＄f3
	fldi	＄f0, ＄r5, 2
	fmul	＄f10, ＄f5, ＄f0
	fadd	＄f10, ＄f4, ＄f10
	j	bne_cont.44470
bne_else.44469:
	fmov	＄f10, ＄f0
bne_cont.44470:
	fbne	＄f10, ＄f16, fbeq_else.44471
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbeq_cont.44472
fbeq_else.44471:
	fmul	＄f0, ＄f2, ＄f7
	fmul	＄f0, ＄f0, ＄f11
	fmul	＄f4, ＄f3, ＄f8
	fmul	＄f4, ＄f4, ＄f13
	fadd	＄f0, ＄f0, ＄f4
	fmul	＄f4, ＄f1, ＄f6
	fmul	＄f4, ＄f4, ＄f12
	fadd	＄f9, ＄f0, ＄f4
	beq	＄r6, ＄r0, bne_else.44473
	fmul	＄f4, ＄f1, ＄f8
	fmul	＄f0, ＄f3, ＄f6
	fadd	＄f4, ＄f4, ＄f0
	ldi	＄r5, ＄r7, 9
	fldi	＄f0, ＄r5, 0
	fmul	＄f5, ＄f4, ＄f0
	fmul	＄f4, ＄f2, ＄f6
	fmul	＄f0, ＄f1, ＄f7
	fadd	＄f1, ＄f4, ＄f0
	fldi	＄f0, ＄r5, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f5, ＄f0
	fmul	＄f1, ＄f2, ＄f8
	fmul	＄f2, ＄f3, ＄f7
	fadd	＄f2, ＄f1, ＄f2
	fldi	＄f1, ＄r5, 2
	fmul	＄f1, ＄f2, ＄f1
	fadd	＄f0, ＄f0, ＄f1
	fmul	＄f4, ＄f0, ＄f21
	fadd	＄f4, ＄f9, ＄f4
	j	bne_cont.44474
bne_else.44473:
	fmov	＄f4, ＄f9
bne_cont.44474:
	fmul	＄f0, ＄f7, ＄f7
	fmul	＄f1, ＄f0, ＄f11
	fmul	＄f0, ＄f8, ＄f8
	fmul	＄f0, ＄f0, ＄f13
	fadd	＄f1, ＄f1, ＄f0
	fmul	＄f0, ＄f6, ＄f6
	fmul	＄f0, ＄f0, ＄f12
	fadd	＄f1, ＄f1, ＄f0
	beq	＄r6, ＄r0, bne_else.44475
	fmul	＄f2, ＄f8, ＄f6
	ldi	＄r5, ＄r7, 9
	fldi	＄f0, ＄r5, 0
	fmul	＄f0, ＄f2, ＄f0
	fadd	＄f2, ＄f1, ＄f0
	fmul	＄f1, ＄f6, ＄f7
	fldi	＄f0, ＄r5, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fmul	＄f1, ＄f7, ＄f8
	fldi	＄f0, ＄r5, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	j	bne_cont.44476
bne_else.44475:
	fmov	＄f0, ＄f1
bne_cont.44476:
	mvhi	＄r5, 0
	mvlo	＄r5, 3
	beq	＄r3, ＄r5, bne_else.44477
	fmov	＄f1, ＄f0
	j	bne_cont.44478
bne_else.44477:
	fsub	＄f1, ＄f0, ＄f17
bne_cont.44478:
	fmul	＄f2, ＄f4, ＄f4
	fmul	＄f0, ＄f10, ＄f1
	fsub	＄f0, ＄f2, ＄f0
	fblt	＄f16, ＄f0, fbge_else.44479
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbge_cont.44480
fbge_else.44479:
	fsqrt	＄f0, ＄f0
	ldi	＄r3, ＄r7, 6
	beq	＄r3, ＄r0, bne_else.44481
	fmov	＄f1, ＄f0
	j	bne_cont.44482
bne_else.44481:
	fneg	＄f1, ＄f0
bne_cont.44482:
	fsub	＄f0, ＄f1, ＄f4
	fdiv	＄f0, ＄f0, ＄f10
	fsti	＄f0, ＄r0, 460
	mvhi	＄r8, 0
	mvlo	＄r8, 1
fbge_cont.44480:
fbeq_cont.44472:
	j	bne_cont.44468
bne_else.44467:
	ldi	＄r3, ＄r7, 4
	fldi	＄f0, ＄r9, 0
	fldi	＄f1, ＄r3, 0
	fmul	＄f3, ＄f0, ＄f1
	fldi	＄f2, ＄r9, 1
	fldi	＄f0, ＄r3, 1
	fmul	＄f2, ＄f2, ＄f0
	fadd	＄f4, ＄f3, ＄f2
	fldi	＄f2, ＄r9, 2
	fldi	＄f3, ＄r3, 2
	fmul	＄f2, ＄f2, ＄f3
	fadd	＄f2, ＄f4, ＄f2
	fblt	＄f16, ＄f2, fbge_else.44483
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbge_cont.44484
fbge_else.44483:
	fmul	＄f1, ＄f1, ＄f7
	fmul	＄f0, ＄f0, ＄f8
	fadd	＄f1, ＄f1, ＄f0
	fmul	＄f0, ＄f3, ＄f6
	fadd	＄f0, ＄f1, ＄f0
	fneg	＄f0, ＄f0
	fdiv	＄f0, ＄f0, ＄f2
	fsti	＄f0, ＄r0, 460
	mvhi	＄r8, 0
	mvlo	＄r8, 1
fbge_cont.44484:
bne_cont.44468:
	j	bne_cont.44466
bne_else.44465:
	fldi	＄f2, ＄r9, 0
	fbne	＄f2, ＄f16, fbeq_else.44485
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbeq_cont.44486
fbeq_else.44485:
	ldi	＄r5, ＄r7, 4
	ldi	＄r3, ＄r7, 6
	fblt	＄f2, ＄f16, fbge_else.44487
	mvhi	＄r6, 0
	mvlo	＄r6, 0
	j	fbge_cont.44488
fbge_else.44487:
	mvhi	＄r6, 0
	mvlo	＄r6, 1
fbge_cont.44488:
	fldi	＄f1, ＄r5, 0
	beq	＄r3, ＄r6, bne_else.44489
	fmov	＄f0, ＄f1
	j	bne_cont.44490
bne_else.44489:
	fneg	＄f0, ＄f1
bne_cont.44490:
	fsub	＄f0, ＄f0, ＄f7
	fdiv	＄f0, ＄f0, ＄f2
	fldi	＄f1, ＄r9, 1
	fmul	＄f1, ＄f0, ＄f1
	fadd	＄f2, ＄f1, ＄f8
	fblt	＄f2, ＄f16, fbge_else.44491
	fmov	＄f1, ＄f2
	j	fbge_cont.44492
fbge_else.44491:
	fneg	＄f1, ＄f2
fbge_cont.44492:
	fldi	＄f2, ＄r5, 1
	fblt	＄f1, ＄f2, fbge_else.44493
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbge_cont.44494
fbge_else.44493:
	fldi	＄f1, ＄r9, 2
	fmul	＄f1, ＄f0, ＄f1
	fadd	＄f2, ＄f1, ＄f6
	fblt	＄f2, ＄f16, fbge_else.44495
	fmov	＄f1, ＄f2
	j	fbge_cont.44496
fbge_else.44495:
	fneg	＄f1, ＄f2
fbge_cont.44496:
	fldi	＄f2, ＄r5, 2
	fblt	＄f1, ＄f2, fbge_else.44497
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbge_cont.44498
fbge_else.44497:
	fsti	＄f0, ＄r0, 460
	mvhi	＄r8, 0
	mvlo	＄r8, 1
fbge_cont.44498:
fbge_cont.44494:
fbeq_cont.44486:
	beq	＄r8, ＄r0, bne_else.44499
	mvhi	＄r8, 0
	mvlo	＄r8, 1
	j	bne_cont.44500
bne_else.44499:
	fldi	＄f2, ＄r9, 1
	fbne	＄f2, ＄f16, fbeq_else.44501
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbeq_cont.44502
fbeq_else.44501:
	ldi	＄r5, ＄r7, 4
	ldi	＄r3, ＄r7, 6
	fblt	＄f2, ＄f16, fbge_else.44503
	mvhi	＄r6, 0
	mvlo	＄r6, 0
	j	fbge_cont.44504
fbge_else.44503:
	mvhi	＄r6, 0
	mvlo	＄r6, 1
fbge_cont.44504:
	fldi	＄f1, ＄r5, 1
	beq	＄r3, ＄r6, bne_else.44505
	fmov	＄f0, ＄f1
	j	bne_cont.44506
bne_else.44505:
	fneg	＄f0, ＄f1
bne_cont.44506:
	fsub	＄f0, ＄f0, ＄f8
	fdiv	＄f0, ＄f0, ＄f2
	fldi	＄f1, ＄r9, 2
	fmul	＄f1, ＄f0, ＄f1
	fadd	＄f2, ＄f1, ＄f6
	fblt	＄f2, ＄f16, fbge_else.44507
	fmov	＄f1, ＄f2
	j	fbge_cont.44508
fbge_else.44507:
	fneg	＄f1, ＄f2
fbge_cont.44508:
	fldi	＄f2, ＄r5, 2
	fblt	＄f1, ＄f2, fbge_else.44509
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbge_cont.44510
fbge_else.44509:
	fldi	＄f1, ＄r9, 0
	fmul	＄f1, ＄f0, ＄f1
	fadd	＄f2, ＄f1, ＄f7
	fblt	＄f2, ＄f16, fbge_else.44511
	fmov	＄f1, ＄f2
	j	fbge_cont.44512
fbge_else.44511:
	fneg	＄f1, ＄f2
fbge_cont.44512:
	fldi	＄f2, ＄r5, 0
	fblt	＄f1, ＄f2, fbge_else.44513
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbge_cont.44514
fbge_else.44513:
	fsti	＄f0, ＄r0, 460
	mvhi	＄r8, 0
	mvlo	＄r8, 1
fbge_cont.44514:
fbge_cont.44510:
fbeq_cont.44502:
	beq	＄r8, ＄r0, bne_else.44515
	mvhi	＄r8, 0
	mvlo	＄r8, 2
	j	bne_cont.44516
bne_else.44515:
	fldi	＄f2, ＄r9, 2
	fbne	＄f2, ＄f16, fbeq_else.44517
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbeq_cont.44518
fbeq_else.44517:
	ldi	＄r5, ＄r7, 4
	ldi	＄r3, ＄r7, 6
	fblt	＄f2, ＄f16, fbge_else.44519
	mvhi	＄r6, 0
	mvlo	＄r6, 0
	j	fbge_cont.44520
fbge_else.44519:
	mvhi	＄r6, 0
	mvlo	＄r6, 1
fbge_cont.44520:
	fldi	＄f1, ＄r5, 2
	beq	＄r3, ＄r6, bne_else.44521
	fmov	＄f0, ＄f1
	j	bne_cont.44522
bne_else.44521:
	fneg	＄f0, ＄f1
bne_cont.44522:
	fsub	＄f0, ＄f0, ＄f6
	fdiv	＄f2, ＄f0, ＄f2
	fldi	＄f0, ＄r9, 0
	fmul	＄f0, ＄f2, ＄f0
	fadd	＄f1, ＄f0, ＄f7
	fblt	＄f1, ＄f16, fbge_else.44523
	fmov	＄f0, ＄f1
	j	fbge_cont.44524
fbge_else.44523:
	fneg	＄f0, ＄f1
fbge_cont.44524:
	fldi	＄f1, ＄r5, 0
	fblt	＄f0, ＄f1, fbge_else.44525
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbge_cont.44526
fbge_else.44525:
	fldi	＄f0, ＄r9, 1
	fmul	＄f0, ＄f2, ＄f0
	fadd	＄f1, ＄f0, ＄f8
	fblt	＄f1, ＄f16, fbge_else.44527
	fmov	＄f0, ＄f1
	j	fbge_cont.44528
fbge_else.44527:
	fneg	＄f0, ＄f1
fbge_cont.44528:
	fldi	＄f1, ＄r5, 1
	fblt	＄f0, ＄f1, fbge_else.44529
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbge_cont.44530
fbge_else.44529:
	fsti	＄f2, ＄r0, 460
	mvhi	＄r8, 0
	mvlo	＄r8, 1
fbge_cont.44530:
fbge_cont.44526:
fbeq_cont.44518:
	beq	＄r8, ＄r0, bne_else.44531
	mvhi	＄r8, 0
	mvlo	＄r8, 3
	j	bne_cont.44532
bne_else.44531:
	mvhi	＄r8, 0
	mvlo	＄r8, 0
bne_cont.44532:
bne_cont.44516:
bne_cont.44500:
bne_cont.44466:
	beq	＄r8, ＄r0, bne_else.44533
	fldi	＄f0, ＄r0, 460
	sti	＄r4, ＄r1, 0
	fblt	＄f16, ＄f0, fbge_else.44534
	j	fbge_cont.44535
fbge_else.44534:
	fldi	＄f1, ＄r0, 458
	fblt	＄f0, ＄f1, fbge_else.44536
	j	fbge_cont.44537
fbge_else.44536:
	# 0.010000
	fmvhi	＄f1, 15395
	fmvlo	＄f1, 55050
	fadd	＄f9, ＄f0, ＄f1
	fldi	＄f0, ＄r9, 0
	fmul	＄f1, ＄f0, ＄f9
	fldi	＄f0, ＄r0, 434
	fadd	＄f5, ＄f1, ＄f0
	fldi	＄f0, ＄r9, 1
	fmul	＄f1, ＄f0, ＄f9
	fldi	＄f0, ＄r0, 435
	fadd	＄f4, ＄f1, ＄f0
	fldi	＄f0, ＄r9, 2
	fmul	＄f1, ＄f0, ＄f9
	fldi	＄f0, ＄r0, 436
	fadd	＄f3, ＄f1, ＄f0
	ldi	＄r5, ＄r4, 0
	fsti	＄f3, ＄r1, -1
	fsti	＄f4, ＄r1, -2
	fsti	＄f5, ＄r1, -3
	beq	＄r5, ＄r30, bne_else.44538
	slli	＄r3, ＄r5, 0
	ldi	＄r6, ＄r3, 522
	ldi	＄r3, ＄r6, 5
	fldi	＄f0, ＄r3, 0
	fsub	＄f0, ＄f5, ＄f0
	fldi	＄f1, ＄r3, 1
	fsub	＄f2, ＄f4, ＄f1
	fldi	＄f1, ＄r3, 2
	fsub	＄f1, ＄f3, ＄f1
	ldi	＄r5, ＄r6, 1
	beq	＄r5, ＄r29, bne_else.44540
	mvhi	＄r3, 0
	mvlo	＄r3, 2
	beq	＄r5, ＄r3, bne_else.44542
	fmul	＄f7, ＄f0, ＄f0
	ldi	＄r3, ＄r6, 4
	fldi	＄f6, ＄r3, 0
	fmul	＄f8, ＄f7, ＄f6
	fmul	＄f7, ＄f2, ＄f2
	fldi	＄f6, ＄r3, 1
	fmul	＄f6, ＄f7, ＄f6
	fadd	＄f8, ＄f8, ＄f6
	fmul	＄f7, ＄f1, ＄f1
	fldi	＄f6, ＄r3, 2
	fmul	＄f6, ＄f7, ＄f6
	fadd	＄f7, ＄f8, ＄f6
	ldi	＄r3, ＄r6, 3
	beq	＄r3, ＄r0, bne_else.44544
	fmul	＄f8, ＄f2, ＄f1
	ldi	＄r3, ＄r6, 9
	fldi	＄f6, ＄r3, 0
	fmul	＄f6, ＄f8, ＄f6
	fadd	＄f7, ＄f7, ＄f6
	fmul	＄f6, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fmul	＄f1, ＄f6, ＄f1
	fadd	＄f7, ＄f7, ＄f1
	fmul	＄f1, ＄f0, ＄f2
	fldi	＄f0, ＄r3, 2
	fmul	＄f6, ＄f1, ＄f0
	fadd	＄f6, ＄f7, ＄f6
	j	bne_cont.44545
bne_else.44544:
	fmov	＄f6, ＄f7
bne_cont.44545:
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	beq	＄r5, ＄r3, bne_else.44546
	fmov	＄f0, ＄f6
	j	bne_cont.44547
bne_else.44546:
	fsub	＄f0, ＄f6, ＄f17
bne_cont.44547:
	ldi	＄r3, ＄r6, 6
	fblt	＄f0, ＄f16, fbge_else.44548
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	j	fbge_cont.44549
fbge_else.44548:
	mvhi	＄r5, 0
	mvlo	＄r5, 1
fbge_cont.44549:
	beq	＄r3, ＄r5, bne_else.44550
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	bne_cont.44551
bne_else.44550:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
bne_cont.44551:
	j	bne_cont.44543
bne_else.44542:
	ldi	＄r3, ＄r6, 4
	fldi	＄f6, ＄r3, 0
	fmul	＄f6, ＄f6, ＄f0
	fldi	＄f0, ＄r3, 1
	fmul	＄f0, ＄f0, ＄f2
	fadd	＄f2, ＄f6, ＄f0
	fldi	＄f0, ＄r3, 2
	fmul	＄f0, ＄f0, ＄f1
	fadd	＄f0, ＄f2, ＄f0
	ldi	＄r3, ＄r6, 6
	fblt	＄f0, ＄f16, fbge_else.44552
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	j	fbge_cont.44553
fbge_else.44552:
	mvhi	＄r5, 0
	mvlo	＄r5, 1
fbge_cont.44553:
	beq	＄r3, ＄r5, bne_else.44554
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	bne_cont.44555
bne_else.44554:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
bne_cont.44555:
bne_cont.44543:
	j	bne_cont.44541
bne_else.44540:
	fblt	＄f0, ＄f16, fbge_else.44556
	fmov	＄f6, ＄f0
	j	fbge_cont.44557
fbge_else.44556:
	fneg	＄f6, ＄f0
fbge_cont.44557:
	ldi	＄r3, ＄r6, 4
	fldi	＄f0, ＄r3, 0
	fblt	＄f6, ＄f0, fbge_else.44558
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	j	fbge_cont.44559
fbge_else.44558:
	fblt	＄f2, ＄f16, fbge_else.44560
	fmov	＄f0, ＄f2
	j	fbge_cont.44561
fbge_else.44560:
	fneg	＄f0, ＄f2
fbge_cont.44561:
	fldi	＄f2, ＄r3, 1
	fblt	＄f0, ＄f2, fbge_else.44562
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	j	fbge_cont.44563
fbge_else.44562:
	fblt	＄f1, ＄f16, fbge_else.44564
	fmov	＄f0, ＄f1
	j	fbge_cont.44565
fbge_else.44564:
	fneg	＄f0, ＄f1
fbge_cont.44565:
	fldi	＄f1, ＄r3, 2
	fblt	＄f0, ＄f1, fbge_else.44566
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	j	fbge_cont.44567
fbge_else.44566:
	mvhi	＄r5, 0
	mvlo	＄r5, 1
fbge_cont.44567:
fbge_cont.44563:
fbge_cont.44559:
	beq	＄r5, ＄r0, bne_else.44568
	ldi	＄r3, ＄r6, 6
	j	bne_cont.44569
bne_else.44568:
	ldi	＄r3, ＄r6, 6
	beq	＄r3, ＄r0, bne_else.44570
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	bne_cont.44571
bne_else.44570:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
bne_cont.44571:
bne_cont.44569:
bne_cont.44541:
	beq	＄r3, ＄r0, bne_else.44572
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	bne_cont.44573
bne_else.44572:
	mvhi	＄r5, 0
	mvlo	＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r1, ＄r1, ＄r28
	call	check_all_inside.2890
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	add	＄r1, ＄r1, ＄r28
bne_cont.44573:
	j	bne_cont.44539
bne_else.44538:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
bne_cont.44539:
	beq	＄r3, ＄r0, bne_else.44574
	fsti	＄f9, ＄r0, 458
	fldi	＄f5, ＄r1, -3
	fsti	＄f5, ＄r0, 455
	fldi	＄f4, ＄r1, -2
	fsti	＄f4, ＄r0, 456
	fldi	＄f3, ＄r1, -1
	fsti	＄f3, ＄r0, 457
	sti	＄r10, ＄r0, 454
	sti	＄r8, ＄r0, 459
	j	bne_cont.44575
bne_else.44574:
bne_cont.44575:
fbge_cont.44537:
fbge_cont.44535:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r11, ＄r11, ＄r28
	ldi	＄r4, ＄r1, 0
	j	solve_each_element.2905
bne_else.44533:
	slli	＄r3, ＄r10, 0
	ldi	＄r3, ＄r3, 522
	ldi	＄r3, ＄r3, 6
	beq	＄r3, ＄r0, bne_else.44576
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r11, ＄r11, ＄r28
	j	solve_each_element.2905
bne_else.44576:
	return
bne_else.44464:
	return

#---------------------------------------------------------------------
# args = [＄r13, ＄r12, ＄r9]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
solve_one_or_network.2909:
	slli	＄r3, ＄r13, 0
	add	＄r28, ＄r12, ＄r3
	ldi	＄r3, ＄r28, 0
	beq	＄r3, ＄r30, bne_else.44579
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	sti	＄r9, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element.2905
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r13, ＄r13, ＄r28
	slli	＄r3, ＄r13, 0
	add	＄r28, ＄r12, ＄r3
	ldi	＄r3, ＄r28, 0
	beq	＄r3, ＄r30, bne_else.44580
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r9, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element.2905
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r13, ＄r13, ＄r28
	slli	＄r3, ＄r13, 0
	add	＄r28, ＄r12, ＄r3
	ldi	＄r3, ＄r28, 0
	beq	＄r3, ＄r30, bne_else.44581
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r9, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element.2905
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r13, ＄r13, ＄r28
	slli	＄r3, ＄r13, 0
	add	＄r28, ＄r12, ＄r3
	ldi	＄r3, ＄r28, 0
	beq	＄r3, ＄r30, bne_else.44582
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r9, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element.2905
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r13, ＄r13, ＄r28
	slli	＄r3, ＄r13, 0
	add	＄r28, ＄r12, ＄r3
	ldi	＄r3, ＄r28, 0
	beq	＄r3, ＄r30, bne_else.44583
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r9, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element.2905
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r13, ＄r13, ＄r28
	slli	＄r3, ＄r13, 0
	add	＄r28, ＄r12, ＄r3
	ldi	＄r3, ＄r28, 0
	beq	＄r3, ＄r30, bne_else.44584
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r9, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element.2905
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r13, ＄r13, ＄r28
	slli	＄r3, ＄r13, 0
	add	＄r28, ＄r12, ＄r3
	ldi	＄r3, ＄r28, 0
	beq	＄r3, ＄r30, bne_else.44585
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r9, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element.2905
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r13, ＄r13, ＄r28
	slli	＄r3, ＄r13, 0
	add	＄r28, ＄r12, ＄r3
	ldi	＄r3, ＄r28, 0
	beq	＄r3, ＄r30, bne_else.44586
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r9, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element.2905
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r13, ＄r13, ＄r28
	ldi	＄r9, ＄r1, 0
	j	solve_one_or_network.2909
bne_else.44586:
	return
bne_else.44585:
	return
bne_else.44584:
	return
bne_else.44583:
	return
bne_else.44582:
	return
bne_else.44581:
	return
bne_else.44580:
	return
bne_else.44579:
	return

#---------------------------------------------------------------------
# args = [＄r14, ＄r15, ＄r9]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
trace_or_matrix.2913:
	slli	＄r3, ＄r14, 0
	add	＄r28, ＄r15, ＄r3
	ldi	＄r12, ＄r28, 0
	ldi	＄r3, ＄r12, 0
	beq	＄r3, ＄r30, bne_else.44595
	mvhi	＄r4, 0
	mvlo	＄r4, 99
	sti	＄r9, ＄r1, 0
	beq	＄r3, ＄r4, bne_else.44596
	slli	＄r3, ＄r3, 0
	ldi	＄r6, ＄r3, 522
	fldi	＄f1, ＄r0, 434
	ldi	＄r3, ＄r6, 5
	fldi	＄f0, ＄r3, 0
	fsub	＄f7, ＄f1, ＄f0
	fldi	＄f1, ＄r0, 435
	fldi	＄f0, ＄r3, 1
	fsub	＄f8, ＄f1, ＄f0
	fldi	＄f1, ＄r0, 436
	fldi	＄f0, ＄r3, 2
	fsub	＄f6, ＄f1, ＄f0
	ldi	＄r4, ＄r6, 1
	beq	＄r4, ＄r29, bne_else.44598
	mvhi	＄r3, 0
	mvlo	＄r3, 2
	beq	＄r4, ＄r3, bne_else.44600
	fldi	＄f2, ＄r9, 0
	fldi	＄f3, ＄r9, 1
	fldi	＄f1, ＄r9, 2
	fmul	＄f0, ＄f2, ＄f2
	ldi	＄r3, ＄r6, 4
	fldi	＄f11, ＄r3, 0
	fmul	＄f4, ＄f0, ＄f11
	fmul	＄f0, ＄f3, ＄f3
	fldi	＄f13, ＄r3, 1
	fmul	＄f0, ＄f0, ＄f13
	fadd	＄f4, ＄f4, ＄f0
	fmul	＄f0, ＄f1, ＄f1
	fldi	＄f12, ＄r3, 2
	fmul	＄f0, ＄f0, ＄f12
	fadd	＄f0, ＄f4, ＄f0
	ldi	＄r5, ＄r6, 3
	beq	＄r5, ＄r0, bne_else.44602
	fmul	＄f5, ＄f3, ＄f1
	ldi	＄r3, ＄r6, 9
	fldi	＄f4, ＄r3, 0
	fmul	＄f4, ＄f5, ＄f4
	fadd	＄f4, ＄f0, ＄f4
	fmul	＄f5, ＄f1, ＄f2
	fldi	＄f0, ＄r3, 1
	fmul	＄f0, ＄f5, ＄f0
	fadd	＄f4, ＄f4, ＄f0
	fmul	＄f5, ＄f2, ＄f3
	fldi	＄f0, ＄r3, 2
	fmul	＄f10, ＄f5, ＄f0
	fadd	＄f10, ＄f4, ＄f10
	j	bne_cont.44603
bne_else.44602:
	fmov	＄f10, ＄f0
bne_cont.44603:
	fbne	＄f10, ＄f16, fbeq_else.44604
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbeq_cont.44605
fbeq_else.44604:
	fmul	＄f0, ＄f2, ＄f7
	fmul	＄f4, ＄f0, ＄f11
	fmul	＄f0, ＄f3, ＄f8
	fmul	＄f0, ＄f0, ＄f13
	fadd	＄f4, ＄f4, ＄f0
	fmul	＄f0, ＄f1, ＄f6
	fmul	＄f0, ＄f0, ＄f12
	fadd	＄f9, ＄f4, ＄f0
	beq	＄r5, ＄r0, bne_else.44606
	fmul	＄f4, ＄f1, ＄f8
	fmul	＄f0, ＄f3, ＄f6
	fadd	＄f4, ＄f4, ＄f0
	ldi	＄r3, ＄r6, 9
	fldi	＄f0, ＄r3, 0
	fmul	＄f5, ＄f4, ＄f0
	fmul	＄f4, ＄f2, ＄f6
	fmul	＄f0, ＄f1, ＄f7
	fadd	＄f1, ＄f4, ＄f0
	fldi	＄f0, ＄r3, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f5, ＄f0
	fmul	＄f2, ＄f2, ＄f8
	fmul	＄f1, ＄f3, ＄f7
	fadd	＄f2, ＄f2, ＄f1
	fldi	＄f1, ＄r3, 2
	fmul	＄f1, ＄f2, ＄f1
	fadd	＄f0, ＄f0, ＄f1
	fmul	＄f4, ＄f0, ＄f21
	fadd	＄f4, ＄f9, ＄f4
	j	bne_cont.44607
bne_else.44606:
	fmov	＄f4, ＄f9
bne_cont.44607:
	fmul	＄f0, ＄f7, ＄f7
	fmul	＄f1, ＄f0, ＄f11
	fmul	＄f0, ＄f8, ＄f8
	fmul	＄f0, ＄f0, ＄f13
	fadd	＄f1, ＄f1, ＄f0
	fmul	＄f0, ＄f6, ＄f6
	fmul	＄f0, ＄f0, ＄f12
	fadd	＄f1, ＄f1, ＄f0
	beq	＄r5, ＄r0, bne_else.44608
	fmul	＄f2, ＄f8, ＄f6
	ldi	＄r3, ＄r6, 9
	fldi	＄f0, ＄r3, 0
	fmul	＄f0, ＄f2, ＄f0
	fadd	＄f2, ＄f1, ＄f0
	fmul	＄f1, ＄f6, ＄f7
	fldi	＄f0, ＄r3, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fmul	＄f1, ＄f7, ＄f8
	fldi	＄f0, ＄r3, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	j	bne_cont.44609
bne_else.44608:
	fmov	＄f0, ＄f1
bne_cont.44609:
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	beq	＄r4, ＄r3, bne_else.44610
	fmov	＄f1, ＄f0
	j	bne_cont.44611
bne_else.44610:
	fsub	＄f1, ＄f0, ＄f17
bne_cont.44611:
	fmul	＄f2, ＄f4, ＄f4
	fmul	＄f0, ＄f10, ＄f1
	fsub	＄f0, ＄f2, ＄f0
	fblt	＄f16, ＄f0, fbge_else.44612
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44613
fbge_else.44612:
	fsqrt	＄f0, ＄f0
	ldi	＄r3, ＄r6, 6
	beq	＄r3, ＄r0, bne_else.44614
	fmov	＄f1, ＄f0
	j	bne_cont.44615
bne_else.44614:
	fneg	＄f1, ＄f0
bne_cont.44615:
	fsub	＄f0, ＄f1, ＄f4
	fdiv	＄f0, ＄f0, ＄f10
	fsti	＄f0, ＄r0, 460
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.44613:
fbeq_cont.44605:
	j	bne_cont.44601
bne_else.44600:
	ldi	＄r3, ＄r6, 4
	fldi	＄f0, ＄r9, 0
	fldi	＄f4, ＄r3, 0
	fmul	＄f1, ＄f0, ＄f4
	fldi	＄f0, ＄r9, 1
	fldi	＄f3, ＄r3, 1
	fmul	＄f0, ＄f0, ＄f3
	fadd	＄f2, ＄f1, ＄f0
	fldi	＄f0, ＄r9, 2
	fldi	＄f1, ＄r3, 2
	fmul	＄f0, ＄f0, ＄f1
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f16, ＄f0, fbge_else.44616
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44617
fbge_else.44616:
	fmul	＄f4, ＄f4, ＄f7
	fmul	＄f2, ＄f3, ＄f8
	fadd	＄f2, ＄f4, ＄f2
	fmul	＄f1, ＄f1, ＄f6
	fadd	＄f1, ＄f2, ＄f1
	fneg	＄f1, ＄f1
	fdiv	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 460
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.44617:
bne_cont.44601:
	j	bne_cont.44599
bne_else.44598:
	fldi	＄f2, ＄r9, 0
	fbne	＄f2, ＄f16, fbeq_else.44618
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbeq_cont.44619
fbeq_else.44618:
	ldi	＄r4, ＄r6, 4
	ldi	＄r3, ＄r6, 6
	fblt	＄f2, ＄f16, fbge_else.44620
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	j	fbge_cont.44621
fbge_else.44620:
	mvhi	＄r5, 0
	mvlo	＄r5, 1
fbge_cont.44621:
	fldi	＄f1, ＄r4, 0
	beq	＄r3, ＄r5, bne_else.44622
	fmov	＄f0, ＄f1
	j	bne_cont.44623
bne_else.44622:
	fneg	＄f0, ＄f1
bne_cont.44623:
	fsub	＄f0, ＄f0, ＄f7
	fdiv	＄f2, ＄f0, ＄f2
	fldi	＄f0, ＄r9, 1
	fmul	＄f0, ＄f2, ＄f0
	fadd	＄f1, ＄f0, ＄f8
	fblt	＄f1, ＄f16, fbge_else.44624
	fmov	＄f0, ＄f1
	j	fbge_cont.44625
fbge_else.44624:
	fneg	＄f0, ＄f1
fbge_cont.44625:
	fldi	＄f1, ＄r4, 1
	fblt	＄f0, ＄f1, fbge_else.44626
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44627
fbge_else.44626:
	fldi	＄f0, ＄r9, 2
	fmul	＄f0, ＄f2, ＄f0
	fadd	＄f1, ＄f0, ＄f6
	fblt	＄f1, ＄f16, fbge_else.44628
	fmov	＄f0, ＄f1
	j	fbge_cont.44629
fbge_else.44628:
	fneg	＄f0, ＄f1
fbge_cont.44629:
	fldi	＄f1, ＄r4, 2
	fblt	＄f0, ＄f1, fbge_else.44630
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44631
fbge_else.44630:
	fsti	＄f2, ＄r0, 460
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.44631:
fbge_cont.44627:
fbeq_cont.44619:
	beq	＄r3, ＄r0, bne_else.44632
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	bne_cont.44633
bne_else.44632:
	fldi	＄f2, ＄r9, 1
	fbne	＄f2, ＄f16, fbeq_else.44634
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbeq_cont.44635
fbeq_else.44634:
	ldi	＄r4, ＄r6, 4
	ldi	＄r3, ＄r6, 6
	fblt	＄f2, ＄f16, fbge_else.44636
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	j	fbge_cont.44637
fbge_else.44636:
	mvhi	＄r5, 0
	mvlo	＄r5, 1
fbge_cont.44637:
	fldi	＄f1, ＄r4, 1
	beq	＄r3, ＄r5, bne_else.44638
	fmov	＄f0, ＄f1
	j	bne_cont.44639
bne_else.44638:
	fneg	＄f0, ＄f1
bne_cont.44639:
	fsub	＄f0, ＄f0, ＄f8
	fdiv	＄f2, ＄f0, ＄f2
	fldi	＄f0, ＄r9, 2
	fmul	＄f0, ＄f2, ＄f0
	fadd	＄f1, ＄f0, ＄f6
	fblt	＄f1, ＄f16, fbge_else.44640
	fmov	＄f0, ＄f1
	j	fbge_cont.44641
fbge_else.44640:
	fneg	＄f0, ＄f1
fbge_cont.44641:
	fldi	＄f1, ＄r4, 2
	fblt	＄f0, ＄f1, fbge_else.44642
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44643
fbge_else.44642:
	fldi	＄f0, ＄r9, 0
	fmul	＄f0, ＄f2, ＄f0
	fadd	＄f1, ＄f0, ＄f7
	fblt	＄f1, ＄f16, fbge_else.44644
	fmov	＄f0, ＄f1
	j	fbge_cont.44645
fbge_else.44644:
	fneg	＄f0, ＄f1
fbge_cont.44645:
	fldi	＄f1, ＄r4, 0
	fblt	＄f0, ＄f1, fbge_else.44646
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44647
fbge_else.44646:
	fsti	＄f2, ＄r0, 460
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.44647:
fbge_cont.44643:
fbeq_cont.44635:
	beq	＄r3, ＄r0, bne_else.44648
	mvhi	＄r3, 0
	mvlo	＄r3, 2
	j	bne_cont.44649
bne_else.44648:
	fldi	＄f2, ＄r9, 2
	fbne	＄f2, ＄f16, fbeq_else.44650
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbeq_cont.44651
fbeq_else.44650:
	ldi	＄r4, ＄r6, 4
	ldi	＄r3, ＄r6, 6
	fblt	＄f2, ＄f16, fbge_else.44652
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	j	fbge_cont.44653
fbge_else.44652:
	mvhi	＄r5, 0
	mvlo	＄r5, 1
fbge_cont.44653:
	fldi	＄f1, ＄r4, 2
	beq	＄r3, ＄r5, bne_else.44654
	fmov	＄f0, ＄f1
	j	bne_cont.44655
bne_else.44654:
	fneg	＄f0, ＄f1
bne_cont.44655:
	fsub	＄f0, ＄f0, ＄f6
	fdiv	＄f2, ＄f0, ＄f2
	fldi	＄f0, ＄r9, 0
	fmul	＄f0, ＄f2, ＄f0
	fadd	＄f1, ＄f0, ＄f7
	fblt	＄f1, ＄f16, fbge_else.44656
	fmov	＄f0, ＄f1
	j	fbge_cont.44657
fbge_else.44656:
	fneg	＄f0, ＄f1
fbge_cont.44657:
	fldi	＄f1, ＄r4, 0
	fblt	＄f0, ＄f1, fbge_else.44658
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44659
fbge_else.44658:
	fldi	＄f0, ＄r9, 1
	fmul	＄f0, ＄f2, ＄f0
	fadd	＄f1, ＄f0, ＄f8
	fblt	＄f1, ＄f16, fbge_else.44660
	fmov	＄f0, ＄f1
	j	fbge_cont.44661
fbge_else.44660:
	fneg	＄f0, ＄f1
fbge_cont.44661:
	fldi	＄f1, ＄r4, 1
	fblt	＄f0, ＄f1, fbge_else.44662
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44663
fbge_else.44662:
	fsti	＄f2, ＄r0, 460
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.44663:
fbge_cont.44659:
fbeq_cont.44651:
	beq	＄r3, ＄r0, bne_else.44664
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	j	bne_cont.44665
bne_else.44664:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.44665:
bne_cont.44649:
bne_cont.44633:
bne_cont.44599:
	beq	＄r3, ＄r0, bne_else.44666
	fldi	＄f0, ＄r0, 460
	fldi	＄f1, ＄r0, 458
	fblt	＄f0, ＄f1, fbge_else.44668
	j	fbge_cont.44669
fbge_else.44668:
	ldi	＄r3, ＄r12, 1
	beq	＄r3, ＄r30, bne_else.44670
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element.2905
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r12, 2
	beq	＄r3, ＄r30, bne_else.44672
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r9, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element.2905
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r12, 3
	beq	＄r3, ＄r30, bne_else.44674
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r9, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element.2905
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r12, 4
	beq	＄r3, ＄r30, bne_else.44676
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r9, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element.2905
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r12, 5
	beq	＄r3, ＄r30, bne_else.44678
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r9, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element.2905
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r12, 6
	beq	＄r3, ＄r30, bne_else.44680
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r9, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element.2905
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r12, 7
	beq	＄r3, ＄r30, bne_else.44682
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r9, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element.2905
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r13, 0
	mvlo	＄r13, 8
	ldi	＄r9, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_one_or_network.2909
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	j	bne_cont.44683
bne_else.44682:
bne_cont.44683:
	j	bne_cont.44681
bne_else.44680:
bne_cont.44681:
	j	bne_cont.44679
bne_else.44678:
bne_cont.44679:
	j	bne_cont.44677
bne_else.44676:
bne_cont.44677:
	j	bne_cont.44675
bne_else.44674:
bne_cont.44675:
	j	bne_cont.44673
bne_else.44672:
bne_cont.44673:
	j	bne_cont.44671
bne_else.44670:
bne_cont.44671:
fbge_cont.44669:
	j	bne_cont.44667
bne_else.44666:
bne_cont.44667:
	j	bne_cont.44597
bne_else.44596:
	ldi	＄r3, ＄r12, 1
	beq	＄r3, ＄r30, bne_else.44684
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element.2905
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r12, 2
	beq	＄r3, ＄r30, bne_else.44686
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r9, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element.2905
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r12, 3
	beq	＄r3, ＄r30, bne_else.44688
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r9, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element.2905
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r12, 4
	beq	＄r3, ＄r30, bne_else.44690
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r9, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element.2905
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r12, 5
	beq	＄r3, ＄r30, bne_else.44692
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r9, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element.2905
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r12, 6
	beq	＄r3, ＄r30, bne_else.44694
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r9, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element.2905
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r12, 7
	beq	＄r3, ＄r30, bne_else.44696
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r9, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element.2905
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r13, 0
	mvlo	＄r13, 8
	ldi	＄r9, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_one_or_network.2909
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	j	bne_cont.44697
bne_else.44696:
bne_cont.44697:
	j	bne_cont.44695
bne_else.44694:
bne_cont.44695:
	j	bne_cont.44693
bne_else.44692:
bne_cont.44693:
	j	bne_cont.44691
bne_else.44690:
bne_cont.44691:
	j	bne_cont.44689
bne_else.44688:
bne_cont.44689:
	j	bne_cont.44687
bne_else.44686:
bne_cont.44687:
	j	bne_cont.44685
bne_else.44684:
bne_cont.44685:
bne_cont.44597:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r14, ＄r14, ＄r28
	ldi	＄r9, ＄r1, 0
	j	trace_or_matrix.2913
bne_else.44595:
	return

#---------------------------------------------------------------------
# args = [＄r11, ＄r4, ＄r10]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
solve_each_element_fast.2919:
	ldi	＄r5, ＄r10, 0
	slli	＄r3, ＄r11, 0
	add	＄r28, ＄r4, ＄r3
	ldi	＄r9, ＄r28, 0
	beq	＄r9, ＄r30, bne_else.44699
	slli	＄r3, ＄r9, 0
	ldi	＄r12, ＄r3, 522
	ldi	＄r6, ＄r12, 10
	fldi	＄f3, ＄r6, 0
	fldi	＄f4, ＄r6, 1
	fldi	＄f2, ＄r6, 2
	ldi	＄r7, ＄r10, 1
	slli	＄r3, ＄r9, 0
	add	＄r28, ＄r7, ＄r3
	ldi	＄r7, ＄r28, 0
	ldi	＄r3, ＄r12, 1
	beq	＄r3, ＄r29, bne_else.44700
	mvhi	＄r8, 0
	mvlo	＄r8, 2
	beq	＄r3, ＄r8, bne_else.44702
	fldi	＄f0, ＄r7, 0
	fbne	＄f0, ＄f16, fbeq_else.44704
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbeq_cont.44705
fbeq_else.44704:
	fldi	＄f1, ＄r7, 1
	fmul	＄f3, ＄f1, ＄f3
	fldi	＄f1, ＄r7, 2
	fmul	＄f1, ＄f1, ＄f4
	fadd	＄f3, ＄f3, ＄f1
	fldi	＄f1, ＄r7, 3
	fmul	＄f1, ＄f1, ＄f2
	fadd	＄f1, ＄f3, ＄f1
	fldi	＄f2, ＄r6, 3
	fmul	＄f3, ＄f1, ＄f1
	fmul	＄f0, ＄f0, ＄f2
	fsub	＄f0, ＄f3, ＄f0
	fblt	＄f16, ＄f0, fbge_else.44706
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbge_cont.44707
fbge_else.44706:
	ldi	＄r3, ＄r12, 6
	beq	＄r3, ＄r0, bne_else.44708
	fsqrt	＄f0, ＄f0
	fadd	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r7, 4
	fmul	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 460
	j	bne_cont.44709
bne_else.44708:
	fsqrt	＄f0, ＄f0
	fsub	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r7, 4
	fmul	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 460
bne_cont.44709:
	mvhi	＄r8, 0
	mvlo	＄r8, 1
fbge_cont.44707:
fbeq_cont.44705:
	j	bne_cont.44703
bne_else.44702:
	fldi	＄f1, ＄r7, 0
	fblt	＄f1, ＄f16, fbge_else.44710
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbge_cont.44711
fbge_else.44710:
	fldi	＄f0, ＄r6, 3
	fmul	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 460
	mvhi	＄r8, 0
	mvlo	＄r8, 1
fbge_cont.44711:
bne_cont.44703:
	j	bne_cont.44701
bne_else.44700:
	fldi	＄f0, ＄r7, 0
	fsub	＄f0, ＄f0, ＄f3
	fldi	＄f1, ＄r7, 1
	fmul	＄f0, ＄f0, ＄f1
	fldi	＄f5, ＄r5, 1
	fmul	＄f5, ＄f0, ＄f5
	fadd	＄f6, ＄f5, ＄f4
	fblt	＄f6, ＄f16, fbge_else.44712
	fmov	＄f5, ＄f6
	j	fbge_cont.44713
fbge_else.44712:
	fneg	＄f5, ＄f6
fbge_cont.44713:
	ldi	＄r3, ＄r12, 4
	fldi	＄f6, ＄r3, 1
	fblt	＄f5, ＄f6, fbge_else.44714
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbge_cont.44715
fbge_else.44714:
	fldi	＄f5, ＄r5, 2
	fmul	＄f5, ＄f0, ＄f5
	fadd	＄f6, ＄f5, ＄f2
	fblt	＄f6, ＄f16, fbge_else.44716
	fmov	＄f5, ＄f6
	j	fbge_cont.44717
fbge_else.44716:
	fneg	＄f5, ＄f6
fbge_cont.44717:
	fldi	＄f6, ＄r3, 2
	fblt	＄f5, ＄f6, fbge_else.44718
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbge_cont.44719
fbge_else.44718:
	fbne	＄f1, ＄f16, fbeq_else.44720
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbeq_cont.44721
fbeq_else.44720:
	mvhi	＄r8, 0
	mvlo	＄r8, 1
fbeq_cont.44721:
fbge_cont.44719:
fbge_cont.44715:
	beq	＄r8, ＄r0, bne_else.44722
	fsti	＄f0, ＄r0, 460
	mvhi	＄r8, 0
	mvlo	＄r8, 1
	j	bne_cont.44723
bne_else.44722:
	fldi	＄f0, ＄r7, 2
	fsub	＄f0, ＄f0, ＄f4
	fldi	＄f1, ＄r7, 3
	fmul	＄f0, ＄f0, ＄f1
	fldi	＄f5, ＄r5, 0
	fmul	＄f5, ＄f0, ＄f5
	fadd	＄f6, ＄f5, ＄f3
	fblt	＄f6, ＄f16, fbge_else.44724
	fmov	＄f5, ＄f6
	j	fbge_cont.44725
fbge_else.44724:
	fneg	＄f5, ＄f6
fbge_cont.44725:
	fldi	＄f6, ＄r3, 0
	fblt	＄f5, ＄f6, fbge_else.44726
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbge_cont.44727
fbge_else.44726:
	fldi	＄f5, ＄r5, 2
	fmul	＄f5, ＄f0, ＄f5
	fadd	＄f6, ＄f5, ＄f2
	fblt	＄f6, ＄f16, fbge_else.44728
	fmov	＄f5, ＄f6
	j	fbge_cont.44729
fbge_else.44728:
	fneg	＄f5, ＄f6
fbge_cont.44729:
	fldi	＄f6, ＄r3, 2
	fblt	＄f5, ＄f6, fbge_else.44730
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbge_cont.44731
fbge_else.44730:
	fbne	＄f1, ＄f16, fbeq_else.44732
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbeq_cont.44733
fbeq_else.44732:
	mvhi	＄r8, 0
	mvlo	＄r8, 1
fbeq_cont.44733:
fbge_cont.44731:
fbge_cont.44727:
	beq	＄r8, ＄r0, bne_else.44734
	fsti	＄f0, ＄r0, 460
	mvhi	＄r8, 0
	mvlo	＄r8, 2
	j	bne_cont.44735
bne_else.44734:
	fldi	＄f0, ＄r7, 4
	fsub	＄f0, ＄f0, ＄f2
	fldi	＄f1, ＄r7, 5
	fmul	＄f0, ＄f0, ＄f1
	fldi	＄f2, ＄r5, 0
	fmul	＄f2, ＄f0, ＄f2
	fadd	＄f3, ＄f2, ＄f3
	fblt	＄f3, ＄f16, fbge_else.44736
	fmov	＄f2, ＄f3
	j	fbge_cont.44737
fbge_else.44736:
	fneg	＄f2, ＄f3
fbge_cont.44737:
	fldi	＄f3, ＄r3, 0
	fblt	＄f2, ＄f3, fbge_else.44738
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbge_cont.44739
fbge_else.44738:
	fldi	＄f2, ＄r5, 1
	fmul	＄f2, ＄f0, ＄f2
	fadd	＄f3, ＄f2, ＄f4
	fblt	＄f3, ＄f16, fbge_else.44740
	fmov	＄f2, ＄f3
	j	fbge_cont.44741
fbge_else.44740:
	fneg	＄f2, ＄f3
fbge_cont.44741:
	fldi	＄f3, ＄r3, 1
	fblt	＄f2, ＄f3, fbge_else.44742
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbge_cont.44743
fbge_else.44742:
	fbne	＄f1, ＄f16, fbeq_else.44744
	mvhi	＄r8, 0
	mvlo	＄r8, 0
	j	fbeq_cont.44745
fbeq_else.44744:
	mvhi	＄r8, 0
	mvlo	＄r8, 1
fbeq_cont.44745:
fbge_cont.44743:
fbge_cont.44739:
	beq	＄r8, ＄r0, bne_else.44746
	fsti	＄f0, ＄r0, 460
	mvhi	＄r8, 0
	mvlo	＄r8, 3
	j	bne_cont.44747
bne_else.44746:
	mvhi	＄r8, 0
	mvlo	＄r8, 0
bne_cont.44747:
bne_cont.44735:
bne_cont.44723:
bne_cont.44701:
	beq	＄r8, ＄r0, bne_else.44748
	fldi	＄f0, ＄r0, 460
	sti	＄r4, ＄r1, 0
	fblt	＄f16, ＄f0, fbge_else.44749
	j	fbge_cont.44750
fbge_else.44749:
	fldi	＄f1, ＄r0, 458
	fblt	＄f0, ＄f1, fbge_else.44751
	j	fbge_cont.44752
fbge_else.44751:
	# 0.010000
	fmvhi	＄f1, 15395
	fmvlo	＄f1, 55050
	fadd	＄f9, ＄f0, ＄f1
	fldi	＄f0, ＄r5, 0
	fmul	＄f1, ＄f0, ＄f9
	fldi	＄f0, ＄r0, 431
	fadd	＄f5, ＄f1, ＄f0
	fldi	＄f0, ＄r5, 1
	fmul	＄f1, ＄f0, ＄f9
	fldi	＄f0, ＄r0, 432
	fadd	＄f4, ＄f1, ＄f0
	fldi	＄f0, ＄r5, 2
	fmul	＄f1, ＄f0, ＄f9
	fldi	＄f0, ＄r0, 433
	fadd	＄f3, ＄f1, ＄f0
	ldi	＄r5, ＄r4, 0
	fsti	＄f3, ＄r1, -1
	fsti	＄f4, ＄r1, -2
	fsti	＄f5, ＄r1, -3
	beq	＄r5, ＄r30, bne_else.44753
	slli	＄r3, ＄r5, 0
	ldi	＄r6, ＄r3, 522
	ldi	＄r3, ＄r6, 5
	fldi	＄f0, ＄r3, 0
	fsub	＄f0, ＄f5, ＄f0
	fldi	＄f1, ＄r3, 1
	fsub	＄f2, ＄f4, ＄f1
	fldi	＄f1, ＄r3, 2
	fsub	＄f1, ＄f3, ＄f1
	ldi	＄r5, ＄r6, 1
	beq	＄r5, ＄r29, bne_else.44755
	mvhi	＄r3, 0
	mvlo	＄r3, 2
	beq	＄r5, ＄r3, bne_else.44757
	fmul	＄f7, ＄f0, ＄f0
	ldi	＄r3, ＄r6, 4
	fldi	＄f6, ＄r3, 0
	fmul	＄f8, ＄f7, ＄f6
	fmul	＄f7, ＄f2, ＄f2
	fldi	＄f6, ＄r3, 1
	fmul	＄f6, ＄f7, ＄f6
	fadd	＄f8, ＄f8, ＄f6
	fmul	＄f7, ＄f1, ＄f1
	fldi	＄f6, ＄r3, 2
	fmul	＄f6, ＄f7, ＄f6
	fadd	＄f7, ＄f8, ＄f6
	ldi	＄r3, ＄r6, 3
	beq	＄r3, ＄r0, bne_else.44759
	fmul	＄f8, ＄f2, ＄f1
	ldi	＄r3, ＄r6, 9
	fldi	＄f6, ＄r3, 0
	fmul	＄f6, ＄f8, ＄f6
	fadd	＄f7, ＄f7, ＄f6
	fmul	＄f6, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fmul	＄f1, ＄f6, ＄f1
	fadd	＄f7, ＄f7, ＄f1
	fmul	＄f1, ＄f0, ＄f2
	fldi	＄f0, ＄r3, 2
	fmul	＄f6, ＄f1, ＄f0
	fadd	＄f6, ＄f7, ＄f6
	j	bne_cont.44760
bne_else.44759:
	fmov	＄f6, ＄f7
bne_cont.44760:
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	beq	＄r5, ＄r3, bne_else.44761
	fmov	＄f0, ＄f6
	j	bne_cont.44762
bne_else.44761:
	fsub	＄f0, ＄f6, ＄f17
bne_cont.44762:
	ldi	＄r3, ＄r6, 6
	fblt	＄f0, ＄f16, fbge_else.44763
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	j	fbge_cont.44764
fbge_else.44763:
	mvhi	＄r5, 0
	mvlo	＄r5, 1
fbge_cont.44764:
	beq	＄r3, ＄r5, bne_else.44765
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	bne_cont.44766
bne_else.44765:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
bne_cont.44766:
	j	bne_cont.44758
bne_else.44757:
	ldi	＄r3, ＄r6, 4
	fldi	＄f6, ＄r3, 0
	fmul	＄f6, ＄f6, ＄f0
	fldi	＄f0, ＄r3, 1
	fmul	＄f0, ＄f0, ＄f2
	fadd	＄f2, ＄f6, ＄f0
	fldi	＄f0, ＄r3, 2
	fmul	＄f0, ＄f0, ＄f1
	fadd	＄f0, ＄f2, ＄f0
	ldi	＄r3, ＄r6, 6
	fblt	＄f0, ＄f16, fbge_else.44767
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	j	fbge_cont.44768
fbge_else.44767:
	mvhi	＄r5, 0
	mvlo	＄r5, 1
fbge_cont.44768:
	beq	＄r3, ＄r5, bne_else.44769
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	bne_cont.44770
bne_else.44769:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
bne_cont.44770:
bne_cont.44758:
	j	bne_cont.44756
bne_else.44755:
	fblt	＄f0, ＄f16, fbge_else.44771
	fmov	＄f6, ＄f0
	j	fbge_cont.44772
fbge_else.44771:
	fneg	＄f6, ＄f0
fbge_cont.44772:
	ldi	＄r3, ＄r6, 4
	fldi	＄f0, ＄r3, 0
	fblt	＄f6, ＄f0, fbge_else.44773
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	j	fbge_cont.44774
fbge_else.44773:
	fblt	＄f2, ＄f16, fbge_else.44775
	fmov	＄f0, ＄f2
	j	fbge_cont.44776
fbge_else.44775:
	fneg	＄f0, ＄f2
fbge_cont.44776:
	fldi	＄f2, ＄r3, 1
	fblt	＄f0, ＄f2, fbge_else.44777
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	j	fbge_cont.44778
fbge_else.44777:
	fblt	＄f1, ＄f16, fbge_else.44779
	fmov	＄f0, ＄f1
	j	fbge_cont.44780
fbge_else.44779:
	fneg	＄f0, ＄f1
fbge_cont.44780:
	fldi	＄f1, ＄r3, 2
	fblt	＄f0, ＄f1, fbge_else.44781
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	j	fbge_cont.44782
fbge_else.44781:
	mvhi	＄r5, 0
	mvlo	＄r5, 1
fbge_cont.44782:
fbge_cont.44778:
fbge_cont.44774:
	beq	＄r5, ＄r0, bne_else.44783
	ldi	＄r3, ＄r6, 6
	j	bne_cont.44784
bne_else.44783:
	ldi	＄r3, ＄r6, 6
	beq	＄r3, ＄r0, bne_else.44785
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	bne_cont.44786
bne_else.44785:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
bne_cont.44786:
bne_cont.44784:
bne_cont.44756:
	beq	＄r3, ＄r0, bne_else.44787
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	bne_cont.44788
bne_else.44787:
	mvhi	＄r5, 0
	mvlo	＄r5, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r1, ＄r1, ＄r28
	call	check_all_inside.2890
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	add	＄r1, ＄r1, ＄r28
bne_cont.44788:
	j	bne_cont.44754
bne_else.44753:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
bne_cont.44754:
	beq	＄r3, ＄r0, bne_else.44789
	fsti	＄f9, ＄r0, 458
	fldi	＄f5, ＄r1, -3
	fsti	＄f5, ＄r0, 455
	fldi	＄f4, ＄r1, -2
	fsti	＄f4, ＄r0, 456
	fldi	＄f3, ＄r1, -1
	fsti	＄f3, ＄r0, 457
	sti	＄r9, ＄r0, 454
	sti	＄r8, ＄r0, 459
	j	bne_cont.44790
bne_else.44789:
bne_cont.44790:
fbge_cont.44752:
fbge_cont.44750:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r11, ＄r11, ＄r28
	ldi	＄r4, ＄r1, 0
	j	solve_each_element_fast.2919
bne_else.44748:
	slli	＄r3, ＄r9, 0
	ldi	＄r3, ＄r3, 522
	ldi	＄r3, ＄r3, 6
	beq	＄r3, ＄r0, bne_else.44791
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r11, ＄r11, ＄r28
	j	solve_each_element_fast.2919
bne_else.44791:
	return
bne_else.44699:
	return

#---------------------------------------------------------------------
# args = [＄r14, ＄r13, ＄r10]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
solve_one_or_network_fast.2923:
	slli	＄r3, ＄r14, 0
	add	＄r28, ＄r13, ＄r3
	ldi	＄r3, ＄r28, 0
	beq	＄r3, ＄r30, bne_else.44794
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	sti	＄r10, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element_fast.2919
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r14, ＄r14, ＄r28
	slli	＄r3, ＄r14, 0
	add	＄r28, ＄r13, ＄r3
	ldi	＄r3, ＄r28, 0
	beq	＄r3, ＄r30, bne_else.44795
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r10, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element_fast.2919
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r14, ＄r14, ＄r28
	slli	＄r3, ＄r14, 0
	add	＄r28, ＄r13, ＄r3
	ldi	＄r3, ＄r28, 0
	beq	＄r3, ＄r30, bne_else.44796
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r10, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element_fast.2919
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r14, ＄r14, ＄r28
	slli	＄r3, ＄r14, 0
	add	＄r28, ＄r13, ＄r3
	ldi	＄r3, ＄r28, 0
	beq	＄r3, ＄r30, bne_else.44797
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r10, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element_fast.2919
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r14, ＄r14, ＄r28
	slli	＄r3, ＄r14, 0
	add	＄r28, ＄r13, ＄r3
	ldi	＄r3, ＄r28, 0
	beq	＄r3, ＄r30, bne_else.44798
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r10, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element_fast.2919
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r14, ＄r14, ＄r28
	slli	＄r3, ＄r14, 0
	add	＄r28, ＄r13, ＄r3
	ldi	＄r3, ＄r28, 0
	beq	＄r3, ＄r30, bne_else.44799
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r10, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element_fast.2919
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r14, ＄r14, ＄r28
	slli	＄r3, ＄r14, 0
	add	＄r28, ＄r13, ＄r3
	ldi	＄r3, ＄r28, 0
	beq	＄r3, ＄r30, bne_else.44800
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r10, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element_fast.2919
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r14, ＄r14, ＄r28
	slli	＄r3, ＄r14, 0
	add	＄r28, ＄r13, ＄r3
	ldi	＄r3, ＄r28, 0
	beq	＄r3, ＄r30, bne_else.44801
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r10, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element_fast.2919
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r14, ＄r14, ＄r28
	ldi	＄r10, ＄r1, 0
	j	solve_one_or_network_fast.2923
bne_else.44801:
	return
bne_else.44800:
	return
bne_else.44799:
	return
bne_else.44798:
	return
bne_else.44797:
	return
bne_else.44796:
	return
bne_else.44795:
	return
bne_else.44794:
	return

#---------------------------------------------------------------------
# args = [＄r15, ＄r16, ＄r10]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
trace_or_matrix_fast.2927:
	slli	＄r3, ＄r15, 0
	add	＄r28, ＄r16, ＄r3
	ldi	＄r13, ＄r28, 0
	ldi	＄r3, ＄r13, 0
	beq	＄r3, ＄r30, bne_else.44810
	mvhi	＄r4, 0
	mvlo	＄r4, 99
	sti	＄r10, ＄r1, 0
	beq	＄r3, ＄r4, bne_else.44811
	slli	＄r4, ＄r3, 0
	ldi	＄r6, ＄r4, 522
	ldi	＄r5, ＄r6, 10
	fldi	＄f3, ＄r5, 0
	fldi	＄f4, ＄r5, 1
	fldi	＄f2, ＄r5, 2
	ldi	＄r4, ＄r10, 1
	slli	＄r3, ＄r3, 0
	add	＄r28, ＄r4, ＄r3
	ldi	＄r7, ＄r28, 0
	ldi	＄r4, ＄r6, 1
	beq	＄r4, ＄r29, bne_else.44813
	mvhi	＄r3, 0
	mvlo	＄r3, 2
	beq	＄r4, ＄r3, bne_else.44815
	fldi	＄f5, ＄r7, 0
	fbne	＄f5, ＄f16, fbeq_else.44817
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbeq_cont.44818
fbeq_else.44817:
	fldi	＄f0, ＄r7, 1
	fmul	＄f1, ＄f0, ＄f3
	fldi	＄f0, ＄r7, 2
	fmul	＄f0, ＄f0, ＄f4
	fadd	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r7, 3
	fmul	＄f0, ＄f0, ＄f2
	fadd	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r5, 3
	fmul	＄f2, ＄f1, ＄f1
	fmul	＄f0, ＄f5, ＄f0
	fsub	＄f0, ＄f2, ＄f0
	fblt	＄f16, ＄f0, fbge_else.44819
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44820
fbge_else.44819:
	ldi	＄r3, ＄r6, 6
	beq	＄r3, ＄r0, bne_else.44821
	fsqrt	＄f0, ＄f0
	fadd	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r7, 4
	fmul	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 460
	j	bne_cont.44822
bne_else.44821:
	fsqrt	＄f0, ＄f0
	fsub	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r7, 4
	fmul	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 460
bne_cont.44822:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.44820:
fbeq_cont.44818:
	j	bne_cont.44816
bne_else.44815:
	fldi	＄f1, ＄r7, 0
	fblt	＄f1, ＄f16, fbge_else.44823
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44824
fbge_else.44823:
	fldi	＄f0, ＄r5, 3
	fmul	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 460
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.44824:
bne_cont.44816:
	j	bne_cont.44814
bne_else.44813:
	ldi	＄r4, ＄r10, 0
	fldi	＄f0, ＄r7, 0
	fsub	＄f0, ＄f0, ＄f3
	fldi	＄f1, ＄r7, 1
	fmul	＄f0, ＄f0, ＄f1
	fldi	＄f5, ＄r4, 1
	fmul	＄f5, ＄f0, ＄f5
	fadd	＄f6, ＄f5, ＄f4
	fblt	＄f6, ＄f16, fbge_else.44825
	fmov	＄f5, ＄f6
	j	fbge_cont.44826
fbge_else.44825:
	fneg	＄f5, ＄f6
fbge_cont.44826:
	ldi	＄r5, ＄r6, 4
	fldi	＄f6, ＄r5, 1
	fblt	＄f5, ＄f6, fbge_else.44827
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44828
fbge_else.44827:
	fldi	＄f5, ＄r4, 2
	fmul	＄f5, ＄f0, ＄f5
	fadd	＄f6, ＄f5, ＄f2
	fblt	＄f6, ＄f16, fbge_else.44829
	fmov	＄f5, ＄f6
	j	fbge_cont.44830
fbge_else.44829:
	fneg	＄f5, ＄f6
fbge_cont.44830:
	fldi	＄f6, ＄r5, 2
	fblt	＄f5, ＄f6, fbge_else.44831
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44832
fbge_else.44831:
	fbne	＄f1, ＄f16, fbeq_else.44833
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbeq_cont.44834
fbeq_else.44833:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbeq_cont.44834:
fbge_cont.44832:
fbge_cont.44828:
	beq	＄r3, ＄r0, bne_else.44835
	fsti	＄f0, ＄r0, 460
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	bne_cont.44836
bne_else.44835:
	fldi	＄f0, ＄r7, 2
	fsub	＄f1, ＄f0, ＄f4
	fldi	＄f0, ＄r7, 3
	fmul	＄f6, ＄f1, ＄f0
	fldi	＄f1, ＄r4, 0
	fmul	＄f1, ＄f6, ＄f1
	fadd	＄f5, ＄f1, ＄f3
	fblt	＄f5, ＄f16, fbge_else.44837
	fmov	＄f1, ＄f5
	j	fbge_cont.44838
fbge_else.44837:
	fneg	＄f1, ＄f5
fbge_cont.44838:
	fldi	＄f5, ＄r5, 0
	fblt	＄f1, ＄f5, fbge_else.44839
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44840
fbge_else.44839:
	fldi	＄f1, ＄r4, 2
	fmul	＄f1, ＄f6, ＄f1
	fadd	＄f5, ＄f1, ＄f2
	fblt	＄f5, ＄f16, fbge_else.44841
	fmov	＄f1, ＄f5
	j	fbge_cont.44842
fbge_else.44841:
	fneg	＄f1, ＄f5
fbge_cont.44842:
	fldi	＄f5, ＄r5, 2
	fblt	＄f1, ＄f5, fbge_else.44843
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44844
fbge_else.44843:
	fbne	＄f0, ＄f16, fbeq_else.44845
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbeq_cont.44846
fbeq_else.44845:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbeq_cont.44846:
fbge_cont.44844:
fbge_cont.44840:
	beq	＄r3, ＄r0, bne_else.44847
	fsti	＄f6, ＄r0, 460
	mvhi	＄r3, 0
	mvlo	＄r3, 2
	j	bne_cont.44848
bne_else.44847:
	fldi	＄f0, ＄r7, 4
	fsub	＄f0, ＄f0, ＄f2
	fldi	＄f5, ＄r7, 5
	fmul	＄f2, ＄f0, ＄f5
	fldi	＄f0, ＄r4, 0
	fmul	＄f0, ＄f2, ＄f0
	fadd	＄f1, ＄f0, ＄f3
	fblt	＄f1, ＄f16, fbge_else.44849
	fmov	＄f0, ＄f1
	j	fbge_cont.44850
fbge_else.44849:
	fneg	＄f0, ＄f1
fbge_cont.44850:
	fldi	＄f1, ＄r5, 0
	fblt	＄f0, ＄f1, fbge_else.44851
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44852
fbge_else.44851:
	fldi	＄f0, ＄r4, 1
	fmul	＄f0, ＄f2, ＄f0
	fadd	＄f1, ＄f0, ＄f4
	fblt	＄f1, ＄f16, fbge_else.44853
	fmov	＄f0, ＄f1
	j	fbge_cont.44854
fbge_else.44853:
	fneg	＄f0, ＄f1
fbge_cont.44854:
	fldi	＄f1, ＄r5, 1
	fblt	＄f0, ＄f1, fbge_else.44855
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44856
fbge_else.44855:
	fbne	＄f5, ＄f16, fbeq_else.44857
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbeq_cont.44858
fbeq_else.44857:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbeq_cont.44858:
fbge_cont.44856:
fbge_cont.44852:
	beq	＄r3, ＄r0, bne_else.44859
	fsti	＄f2, ＄r0, 460
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	j	bne_cont.44860
bne_else.44859:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
bne_cont.44860:
bne_cont.44848:
bne_cont.44836:
bne_cont.44814:
	beq	＄r3, ＄r0, bne_else.44861
	fldi	＄f0, ＄r0, 460
	fldi	＄f1, ＄r0, 458
	fblt	＄f0, ＄f1, fbge_else.44863
	j	fbge_cont.44864
fbge_else.44863:
	ldi	＄r3, ＄r13, 1
	beq	＄r3, ＄r30, bne_else.44865
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element_fast.2919
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r13, 2
	beq	＄r3, ＄r30, bne_else.44867
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r10, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element_fast.2919
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r13, 3
	beq	＄r3, ＄r30, bne_else.44869
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r10, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element_fast.2919
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r13, 4
	beq	＄r3, ＄r30, bne_else.44871
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r10, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element_fast.2919
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r13, 5
	beq	＄r3, ＄r30, bne_else.44873
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r10, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element_fast.2919
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r13, 6
	beq	＄r3, ＄r30, bne_else.44875
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r10, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element_fast.2919
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r13, 7
	beq	＄r3, ＄r30, bne_else.44877
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r10, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element_fast.2919
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r14, 0
	mvlo	＄r14, 8
	ldi	＄r10, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_one_or_network_fast.2923
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	j	bne_cont.44878
bne_else.44877:
bne_cont.44878:
	j	bne_cont.44876
bne_else.44875:
bne_cont.44876:
	j	bne_cont.44874
bne_else.44873:
bne_cont.44874:
	j	bne_cont.44872
bne_else.44871:
bne_cont.44872:
	j	bne_cont.44870
bne_else.44869:
bne_cont.44870:
	j	bne_cont.44868
bne_else.44867:
bne_cont.44868:
	j	bne_cont.44866
bne_else.44865:
bne_cont.44866:
fbge_cont.44864:
	j	bne_cont.44862
bne_else.44861:
bne_cont.44862:
	j	bne_cont.44812
bne_else.44811:
	ldi	＄r3, ＄r13, 1
	beq	＄r3, ＄r30, bne_else.44879
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element_fast.2919
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r13, 2
	beq	＄r3, ＄r30, bne_else.44881
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r10, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element_fast.2919
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r13, 3
	beq	＄r3, ＄r30, bne_else.44883
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r10, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element_fast.2919
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r13, 4
	beq	＄r3, ＄r30, bne_else.44885
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r10, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element_fast.2919
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r13, 5
	beq	＄r3, ＄r30, bne_else.44887
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r10, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element_fast.2919
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r13, 6
	beq	＄r3, ＄r30, bne_else.44889
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r10, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element_fast.2919
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	ldi	＄r3, ＄r13, 7
	beq	＄r3, ＄r30, bne_else.44891
	slli	＄r3, ＄r3, 0
	ldi	＄r4, ＄r3, 462
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	ldi	＄r10, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_each_element_fast.2919
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r14, 0
	mvlo	＄r14, 8
	ldi	＄r10, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	solve_one_or_network_fast.2923
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	j	bne_cont.44892
bne_else.44891:
bne_cont.44892:
	j	bne_cont.44890
bne_else.44889:
bne_cont.44890:
	j	bne_cont.44888
bne_else.44887:
bne_cont.44888:
	j	bne_cont.44886
bne_else.44885:
bne_cont.44886:
	j	bne_cont.44884
bne_else.44883:
bne_cont.44884:
	j	bne_cont.44882
bne_else.44881:
bne_cont.44882:
	j	bne_cont.44880
bne_else.44879:
bne_cont.44880:
bne_cont.44812:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r15, ＄r15, ＄r28
	ldi	＄r10, ＄r1, 0
	j	trace_or_matrix_fast.2927
bne_else.44810:
	return

#---------------------------------------------------------------------
# args = [＄r17, ＄r19]
# fargs = [＄f11, ＄f10]
# ret type = Unit
#---------------------------------------------------------------------
trace_reflections.2949:
	blt	＄r17, ＄r0, bge_else.44894
	slli	＄r3, ＄r17, 0
	ldi	＄r20, ＄r3, 161
	ldi	＄r18, ＄r20, 1
	# 1000000000.000000
	fmvhi	＄f0, 20078
	fmvlo	＄f0, 27432
	fsti	＄f0, ＄r0, 458
	mvhi	＄r15, 0
	mvlo	＄r15, 0
	ldi	＄r16, ＄r0, 461
	mov	＄r10, ＄r18
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	trace_or_matrix_fast.2927
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fldi	＄f0, ＄r0, 458
	# -0.100000
	fmvhi	＄f1, 48588
	fmvlo	＄f1, 52420
	fblt	＄f1, ＄f0, fbge_else.44895
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44896
fbge_else.44895:
	# 100000000.000000
	fmvhi	＄f1, 19646
	fmvlo	＄f1, 48160
	fblt	＄f0, ＄f1, fbge_else.44897
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44898
fbge_else.44897:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.44898:
fbge_cont.44896:
	beq	＄r3, ＄r0, bne_else.44899
	ldi	＄r3, ＄r0, 454
	slli	＄r4, ＄r3, 2
	ldi	＄r3, ＄r0, 459
	add	＄r3, ＄r4, ＄r3
	ldi	＄r4, ＄r20, 0
	beq	＄r3, ＄r4, bne_else.44901
	j	bne_cont.44902
bne_else.44901:
	mvhi	＄r12, 0
	mvlo	＄r12, 0
	ldi	＄r13, ＄r0, 461
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_one_or_matrix.2902
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.44903
	j	bne_cont.44904
bne_else.44903:
	ldi	＄r3, ＄r18, 0
	fldi	＄f0, ＄r0, 451
	fldi	＄f2, ＄r3, 0
	fmul	＄f1, ＄f0, ＄f2
	fldi	＄f0, ＄r0, 452
	fldi	＄f4, ＄r3, 1
	fmul	＄f0, ＄f0, ＄f4
	fadd	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r0, 453
	fldi	＄f3, ＄r3, 2
	fmul	＄f0, ＄f0, ＄f3
	fadd	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r20, 2
	fmul	＄f5, ＄f0, ＄f11
	fmul	＄f1, ＄f5, ＄f1
	fldi	＄f5, ＄r19, 0
	fmul	＄f5, ＄f5, ＄f2
	fldi	＄f2, ＄r19, 1
	fmul	＄f2, ＄f2, ＄f4
	fadd	＄f4, ＄f5, ＄f2
	fldi	＄f2, ＄r19, 2
	fmul	＄f2, ＄f2, ＄f3
	fadd	＄f2, ＄f4, ＄f2
	fmul	＄f0, ＄f0, ＄f2
	fblt	＄f16, ＄f1, fbge_else.44905
	j	fbge_cont.44906
fbge_else.44905:
	fldi	＄f3, ＄r0, 442
	fldi	＄f2, ＄r0, 448
	fmul	＄f2, ＄f1, ＄f2
	fadd	＄f2, ＄f3, ＄f2
	fsti	＄f2, ＄r0, 442
	fldi	＄f3, ＄r0, 443
	fldi	＄f2, ＄r0, 449
	fmul	＄f2, ＄f1, ＄f2
	fadd	＄f2, ＄f3, ＄f2
	fsti	＄f2, ＄r0, 443
	fldi	＄f3, ＄r0, 444
	fldi	＄f2, ＄r0, 450
	fmul	＄f1, ＄f1, ＄f2
	fadd	＄f1, ＄f3, ＄f1
	fsti	＄f1, ＄r0, 444
fbge_cont.44906:
	fblt	＄f16, ＄f0, fbge_else.44907
	j	fbge_cont.44908
fbge_else.44907:
	fmul	＄f0, ＄f0, ＄f0
	fmul	＄f0, ＄f0, ＄f0
	fmul	＄f0, ＄f0, ＄f10
	fldi	＄f1, ＄r0, 442
	fadd	＄f1, ＄f1, ＄f0
	fsti	＄f1, ＄r0, 442
	fldi	＄f1, ＄r0, 443
	fadd	＄f1, ＄f1, ＄f0
	fsti	＄f1, ＄r0, 443
	fldi	＄f1, ＄r0, 444
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 444
fbge_cont.44908:
bne_cont.44904:
bne_cont.44902:
	j	bne_cont.44900
bne_else.44899:
bne_cont.44900:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r17, ＄r17, ＄r28
	j	trace_reflections.2949
bge_else.44894:
	return

#---------------------------------------------------------------------
# args = [＄r21, ＄r19, ＄r22]
# fargs = [＄f14, ＄f12]
# ret type = Unit
#---------------------------------------------------------------------
trace_ray.2954:
	mvhi	＄r3, 0
	mvlo	＄r3, 4
	blt	＄r3, ＄r21, ble_else.44910
	ldi	＄r24, ＄r22, 2
	# 1000000000.000000
	fmvhi	＄f0, 20078
	fmvlo	＄f0, 27432
	fsti	＄f0, ＄r0, 458
	mvhi	＄r14, 0
	mvlo	＄r14, 0
	ldi	＄r15, ＄r0, 461
	fsti	＄f12, ＄r1, 0
	mov	＄r9, ＄r19
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	trace_or_matrix.2913
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	fldi	＄f0, ＄r0, 458
	# -0.100000
	fmvhi	＄f1, 48588
	fmvlo	＄f1, 52420
	fblt	＄f1, ＄f0, fbge_else.44911
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44912
fbge_else.44911:
	# 100000000.000000
	fmvhi	＄f1, 19646
	fmvlo	＄f1, 48160
	fblt	＄f0, ＄f1, fbge_else.44913
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44914
fbge_else.44913:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.44914:
fbge_cont.44912:
	beq	＄r3, ＄r0, bne_else.44915
	ldi	＄r5, ＄r0, 454
	slli	＄r3, ＄r5, 0
	ldi	＄r4, ＄r3, 522
	ldi	＄r25, ＄r4, 2
	ldi	＄r23, ＄r4, 7
	fldi	＄f0, ＄r23, 0
	fmul	＄f11, ＄f0, ＄f14
	ldi	＄r3, ＄r4, 1
	beq	＄r3, ＄r29, bne_else.44916
	mvhi	＄r6, 0
	mvlo	＄r6, 2
	beq	＄r3, ＄r6, bne_else.44918
	fldi	＄f1, ＄r0, 455
	ldi	＄r3, ＄r4, 5
	fldi	＄f0, ＄r3, 0
	fsub	＄f4, ＄f1, ＄f0
	fldi	＄f1, ＄r0, 456
	fldi	＄f0, ＄r3, 1
	fsub	＄f3, ＄f1, ＄f0
	fldi	＄f1, ＄r0, 457
	fldi	＄f0, ＄r3, 2
	fsub	＄f0, ＄f1, ＄f0
	ldi	＄r3, ＄r4, 4
	fldi	＄f1, ＄r3, 0
	fmul	＄f1, ＄f4, ＄f1
	fldi	＄f2, ＄r3, 1
	fmul	＄f5, ＄f3, ＄f2
	fldi	＄f2, ＄r3, 2
	fmul	＄f7, ＄f0, ＄f2
	ldi	＄r3, ＄r4, 3
	beq	＄r3, ＄r0, bne_else.44920
	ldi	＄r3, ＄r4, 9
	fldi	＄f2, ＄r3, 2
	fmul	＄f6, ＄f3, ＄f2
	fldi	＄f2, ＄r3, 1
	fmul	＄f2, ＄f0, ＄f2
	fadd	＄f2, ＄f6, ＄f2
	fmul	＄f2, ＄f2, ＄f21
	fadd	＄f1, ＄f1, ＄f2
	fsti	＄f1, ＄r0, 451
	fldi	＄f1, ＄r3, 2
	fmul	＄f2, ＄f4, ＄f1
	fldi	＄f1, ＄r3, 0
	fmul	＄f0, ＄f0, ＄f1
	fadd	＄f0, ＄f2, ＄f0
	fmul	＄f0, ＄f0, ＄f21
	fadd	＄f0, ＄f5, ＄f0
	fsti	＄f0, ＄r0, 452
	fldi	＄f0, ＄r3, 1
	fmul	＄f1, ＄f4, ＄f0
	fldi	＄f0, ＄r3, 0
	fmul	＄f0, ＄f3, ＄f0
	fadd	＄f0, ＄f1, ＄f0
	fmul	＄f0, ＄f0, ＄f21
	fadd	＄f0, ＄f7, ＄f0
	fsti	＄f0, ＄r0, 453
	j	bne_cont.44921
bne_else.44920:
	fsti	＄f1, ＄r0, 451
	fsti	＄f5, ＄r0, 452
	fsti	＄f7, ＄r0, 453
bne_cont.44921:
	ldi	＄r3, ＄r4, 6
	fldi	＄f2, ＄r0, 451
	fmul	＄f1, ＄f2, ＄f2
	fldi	＄f0, ＄r0, 452
	fmul	＄f0, ＄f0, ＄f0
	fadd	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r0, 453
	fmul	＄f0, ＄f0, ＄f0
	fadd	＄f0, ＄f1, ＄f0
	fsqrt	＄f1, ＄f0
	fbne	＄f1, ＄f16, fbeq_else.44922
	fmov	＄f0, ＄f17
	j	fbeq_cont.44923
fbeq_else.44922:
	beq	＄r3, ＄r0, bne_else.44924
	fdiv	＄f0, ＄f20, ＄f1
	j	bne_cont.44925
bne_else.44924:
	fdiv	＄f0, ＄f17, ＄f1
bne_cont.44925:
fbeq_cont.44923:
	fmul	＄f1, ＄f2, ＄f0
	fsti	＄f1, ＄r0, 451
	fldi	＄f1, ＄r0, 452
	fmul	＄f1, ＄f1, ＄f0
	fsti	＄f1, ＄r0, 452
	fldi	＄f1, ＄r0, 453
	fmul	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 453
	j	bne_cont.44919
bne_else.44918:
	ldi	＄r3, ＄r4, 4
	fldi	＄f0, ＄r3, 0
	fneg	＄f0, ＄f0
	fsti	＄f0, ＄r0, 451
	fldi	＄f0, ＄r3, 1
	fneg	＄f0, ＄f0
	fsti	＄f0, ＄r0, 452
	fldi	＄f0, ＄r3, 2
	fneg	＄f0, ＄f0
	fsti	＄f0, ＄r0, 453
bne_cont.44919:
	j	bne_cont.44917
bne_else.44916:
	ldi	＄r3, ＄r0, 459
	fsti	＄f16, ＄r0, 451
	fsti	＄f16, ＄r0, 452
	fsti	＄f16, ＄r0, 453
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r6, ＄r3, ＄r28
	slli	＄r3, ＄r6, 0
	add	＄r28, ＄r19, ＄r3
	fldi	＄f1, ＄r28, 0
	fbne	＄f1, ＄f16, fbeq_else.44926
	fmov	＄f0, ＄f16
	j	fbeq_cont.44927
fbeq_else.44926:
	fblt	＄f16, ＄f1, fbge_else.44928
	fmov	＄f0, ＄f20
	j	fbge_cont.44929
fbge_else.44928:
	fmov	＄f0, ＄f17
fbge_cont.44929:
fbeq_cont.44927:
	fneg	＄f0, ＄f0
	slli	＄r3, ＄r6, 0
	fsti	＄f0, ＄r3, 451
bne_cont.44917:
	fldi	＄f0, ＄r0, 455
	fsti	＄f0, ＄r0, 434
	fldi	＄f0, ＄r0, 456
	fsti	＄f0, ＄r0, 435
	fldi	＄f0, ＄r0, 457
	fsti	＄f0, ＄r0, 436
	ldi	＄r3, ＄r4, 0
	ldi	＄r6, ＄r4, 8
	fldi	＄f0, ＄r6, 0
	fsti	＄f0, ＄r0, 448
	fldi	＄f0, ＄r6, 1
	fsti	＄f0, ＄r0, 449
	fldi	＄f0, ＄r6, 2
	fsti	＄f0, ＄r0, 450
	beq	＄r3, ＄r29, bne_else.44930
	mvhi	＄r6, 0
	mvlo	＄r6, 2
	beq	＄r3, ＄r6, bne_else.44932
	mvhi	＄r6, 0
	mvlo	＄r6, 3
	beq	＄r3, ＄r6, bne_else.44934
	mvhi	＄r6, 0
	mvlo	＄r6, 4
	beq	＄r3, ＄r6, bne_else.44936
	j	bne_cont.44937
bne_else.44936:
	fldi	＄f1, ＄r0, 455
	ldi	＄r6, ＄r4, 5
	fldi	＄f0, ＄r6, 0
	fsub	＄f1, ＄f1, ＄f0
	ldi	＄r7, ＄r4, 4
	fldi	＄f0, ＄r7, 0
	fsqrt	＄f0, ＄f0
	fmul	＄f1, ＄f1, ＄f0
	fldi	＄f2, ＄r0, 457
	fldi	＄f0, ＄r6, 2
	fsub	＄f2, ＄f2, ＄f0
	fldi	＄f0, ＄r7, 2
	fsqrt	＄f0, ＄f0
	fmul	＄f2, ＄f2, ＄f0
	fmul	＄f3, ＄f1, ＄f1
	fmul	＄f0, ＄f2, ＄f2
	fadd	＄f5, ＄f3, ＄f0
	fblt	＄f1, ＄f16, fbge_else.44938
	fmov	＄f0, ＄f1
	j	fbge_cont.44939
fbge_else.44938:
	fneg	＄f0, ＄f1
fbge_cont.44939:
	# 0.000100
	fmvhi	＄f6, 14545
	fmvlo	＄f6, 46863
	fblt	＄f0, ＄f6, fbge_else.44940
	fdiv	＄f1, ＄f2, ＄f1
	fblt	＄f1, ＄f16, fbge_else.44942
	fmov	＄f0, ＄f1
	j	fbge_cont.44943
fbge_else.44942:
	fneg	＄f0, ＄f1
fbge_cont.44943:
	fblt	＄f17, ＄f0, fbge_else.44944
	fblt	＄f0, ＄f20, fbge_else.44946
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44947
fbge_else.44946:
	mvhi	＄r3, 65535
	mvlo	＄r3, -1
fbge_cont.44947:
	j	fbge_cont.44945
fbge_else.44944:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.44945:
	beq	＄r3, ＄r0, bne_else.44948
	fdiv	＄f4, ＄f17, ＄f0
	j	bne_cont.44949
bne_else.44948:
	fmov	＄f4, ＄f0
bne_cont.44949:
	fmul	＄f0, ＄f4, ＄f4
	# 121.000000
	fmvhi	＄f1, 17138
	fmvlo	＄f1, 0
	fmul	＄f2, ＄f1, ＄f0
	# 23.000000
	fmvhi	＄f1, 16824
	fmvlo	＄f1, 0
	fdiv	＄f2, ＄f2, ＄f1
	# 100.000000
	fmvhi	＄f1, 17096
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	# 21.000000
	fmvhi	＄f1, 16808
	fmvlo	＄f1, 0
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 81.000000
	fmvhi	＄f1, 17058
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	# 19.000000
	fmvhi	＄f1, 16792
	fmvlo	＄f1, 0
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 64.000000
	fmvhi	＄f1, 17024
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	# 17.000000
	fmvhi	＄f1, 16776
	fmvlo	＄f1, 0
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 49.000000
	fmvhi	＄f1, 16964
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	fadd	＄f1, ＄f28, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 36.000000
	fmvhi	＄f1, 16912
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	# 13.000000
	fmvhi	＄f1, 16720
	fmvlo	＄f1, 0
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 25.000000
	fmvhi	＄f1, 16840
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	# 11.000000
	fmvhi	＄f1, 16688
	fmvlo	＄f1, 0
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 16.000000
	fmvhi	＄f1, 16768
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	fadd	＄f1, ＄f25, ＄f2
	fdiv	＄f1, ＄f3, ＄f1
	fmul	＄f2, ＄f25, ＄f0
	fadd	＄f1, ＄f26, ＄f1
	fdiv	＄f2, ＄f2, ＄f1
	# 4.000000
	fmvhi	＄f1, 16512
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	fadd	＄f1, ＄f24, ＄f2
	fdiv	＄f1, ＄f3, ＄f1
	fadd	＄f1, ＄f23, ＄f1
	fdiv	＄f0, ＄f0, ＄f1
	fadd	＄f0, ＄f17, ＄f0
	fdiv	＄f1, ＄f4, ＄f0
	blt	＄r0, ＄r3, ble_else.44950
	blt	＄r3, ＄r0, bge_else.44952
	fmov	＄f0, ＄f1
	j	bge_cont.44953
bge_else.44952:
	# -1.570796
	fmvhi	＄f0, 49097
	fmvlo	＄f0, 4058
	fsub	＄f0, ＄f0, ＄f1
bge_cont.44953:
	j	ble_cont.44951
ble_else.44950:
	fsub	＄f0, ＄f22, ＄f1
ble_cont.44951:
	# 30.000000
	fmvhi	＄f1, 16880
	fmvlo	＄f1, 0
	fmul	＄f1, ＄f0, ＄f1
	# 3.141593
	fmvhi	＄f0, 16457
	fmvlo	＄f0, 4058
	fdiv	＄f0, ＄f1, ＄f0
	j	fbge_cont.44941
fbge_else.44940:
	fmov	＄f0, ＄f28
fbge_cont.44941:
	fsti	＄f0, ＄r1, -1
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_floor
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	fmov	＄f1, ＄f0
	fldi	＄f0, ＄r1, -1
	fsub	＄f7, ＄f0, ＄f1
	fldi	＄f1, ＄r0, 456
	fldi	＄f0, ＄r6, 1
	fsub	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r7, 1
	fsqrt	＄f0, ＄f0
	fmul	＄f1, ＄f1, ＄f0
	fblt	＄f5, ＄f16, fbge_else.44954
	fmov	＄f0, ＄f5
	j	fbge_cont.44955
fbge_else.44954:
	fneg	＄f0, ＄f5
fbge_cont.44955:
	fblt	＄f0, ＄f6, fbge_else.44956
	fdiv	＄f1, ＄f1, ＄f5
	fblt	＄f1, ＄f16, fbge_else.44958
	fmov	＄f0, ＄f1
	j	fbge_cont.44959
fbge_else.44958:
	fneg	＄f0, ＄f1
fbge_cont.44959:
	fblt	＄f17, ＄f0, fbge_else.44960
	fblt	＄f0, ＄f20, fbge_else.44962
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.44963
fbge_else.44962:
	mvhi	＄r3, 65535
	mvlo	＄r3, -1
fbge_cont.44963:
	j	fbge_cont.44961
fbge_else.44960:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.44961:
	beq	＄r3, ＄r0, bne_else.44964
	fdiv	＄f4, ＄f17, ＄f0
	j	bne_cont.44965
bne_else.44964:
	fmov	＄f4, ＄f0
bne_cont.44965:
	fmul	＄f0, ＄f4, ＄f4
	# 121.000000
	fmvhi	＄f1, 17138
	fmvlo	＄f1, 0
	fmul	＄f2, ＄f1, ＄f0
	# 23.000000
	fmvhi	＄f1, 16824
	fmvlo	＄f1, 0
	fdiv	＄f2, ＄f2, ＄f1
	# 100.000000
	fmvhi	＄f1, 17096
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	# 21.000000
	fmvhi	＄f1, 16808
	fmvlo	＄f1, 0
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 81.000000
	fmvhi	＄f1, 17058
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	# 19.000000
	fmvhi	＄f1, 16792
	fmvlo	＄f1, 0
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 64.000000
	fmvhi	＄f1, 17024
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	# 17.000000
	fmvhi	＄f1, 16776
	fmvlo	＄f1, 0
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 49.000000
	fmvhi	＄f1, 16964
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	fadd	＄f1, ＄f28, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 36.000000
	fmvhi	＄f1, 16912
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	# 13.000000
	fmvhi	＄f1, 16720
	fmvlo	＄f1, 0
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 25.000000
	fmvhi	＄f1, 16840
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	# 11.000000
	fmvhi	＄f1, 16688
	fmvlo	＄f1, 0
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 16.000000
	fmvhi	＄f1, 16768
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	fadd	＄f1, ＄f25, ＄f2
	fdiv	＄f1, ＄f3, ＄f1
	fmul	＄f2, ＄f25, ＄f0
	fadd	＄f1, ＄f26, ＄f1
	fdiv	＄f2, ＄f2, ＄f1
	# 4.000000
	fmvhi	＄f1, 16512
	fmvlo	＄f1, 0
	fmul	＄f1, ＄f1, ＄f0
	fadd	＄f2, ＄f24, ＄f2
	fdiv	＄f1, ＄f1, ＄f2
	fadd	＄f1, ＄f23, ＄f1
	fdiv	＄f0, ＄f0, ＄f1
	fadd	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f4, ＄f0
	blt	＄r0, ＄r3, ble_else.44966
	blt	＄r3, ＄r0, bge_else.44968
	fmov	＄f1, ＄f0
	j	bge_cont.44969
bge_else.44968:
	# -1.570796
	fmvhi	＄f1, 49097
	fmvlo	＄f1, 4058
	fsub	＄f1, ＄f1, ＄f0
bge_cont.44969:
	j	ble_cont.44967
ble_else.44966:
	fsub	＄f1, ＄f22, ＄f0
ble_cont.44967:
	# 30.000000
	fmvhi	＄f0, 16880
	fmvlo	＄f0, 0
	fmul	＄f1, ＄f1, ＄f0
	# 3.141593
	fmvhi	＄f0, 16457
	fmvlo	＄f0, 4058
	fdiv	＄f0, ＄f1, ＄f0
	j	fbge_cont.44957
fbge_else.44956:
	fmov	＄f0, ＄f28
fbge_cont.44957:
	fsti	＄f0, ＄r1, -2
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_floor
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	add	＄r1, ＄r1, ＄r28
	fmov	＄f1, ＄f0
	fldi	＄f0, ＄r1, -2
	fsub	＄f0, ＄f0, ＄f1
	# 0.150000
	fmvhi	＄f2, 15897
	fmvlo	＄f2, 39321
	fsub	＄f1, ＄f21, ＄f7
	fmul	＄f1, ＄f1, ＄f1
	fsub	＄f1, ＄f2, ＄f1
	fsub	＄f0, ＄f21, ＄f0
	fmul	＄f0, ＄f0, ＄f0
	fsub	＄f1, ＄f1, ＄f0
	fblt	＄f1, ＄f16, fbge_else.44970
	fmov	＄f0, ＄f1
	j	fbge_cont.44971
fbge_else.44970:
	fmov	＄f0, ＄f16
fbge_cont.44971:
	fmul	＄f1, ＄f27, ＄f0
	# 0.300000
	fmvhi	＄f0, 16025
	fmvlo	＄f0, 39321
	fdiv	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 450
bne_cont.44937:
	j	bne_cont.44935
bne_else.44934:
	fldi	＄f1, ＄r0, 455
	ldi	＄r3, ＄r4, 5
	fldi	＄f0, ＄r3, 0
	fsub	＄f1, ＄f1, ＄f0
	fldi	＄f2, ＄r0, 457
	fldi	＄f0, ＄r3, 2
	fsub	＄f0, ＄f2, ＄f0
	fmul	＄f1, ＄f1, ＄f1
	fmul	＄f0, ＄f0, ＄f0
	fadd	＄f0, ＄f1, ＄f0
	fsqrt	＄f1, ＄f0
	# 10.000000
	fmvhi	＄f0, 16672
	fmvlo	＄f0, 0
	fdiv	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r1, -1
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_floor
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	fmov	＄f1, ＄f0
	fldi	＄f0, ＄r1, -1
	fsub	＄f1, ＄f0, ＄f1
	# 3.141593
	fmvhi	＄f0, 16457
	fmvlo	＄f0, 4058
	fmul	＄f0, ＄f1, ＄f0
	fsub	＄f2, ＄f22, ＄f0
	fblt	＄f2, ＄f16, fbge_else.44972
	fmov	＄f1, ＄f2
	j	fbge_cont.44973
fbge_else.44972:
	fneg	＄f1, ＄f2
fbge_cont.44973:
	fblt	＄f29, ＄f1, fbge_else.44974
	fblt	＄f1, ＄f16, fbge_else.44976
	fmov	＄f0, ＄f1
	j	fbge_cont.44977
fbge_else.44976:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.44978
	fblt	＄f1, ＄f16, fbge_else.44980
	fmov	＄f0, ＄f1
	j	fbge_cont.44981
fbge_else.44980:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.44982
	fblt	＄f1, ＄f16, fbge_else.44984
	fmov	＄f0, ＄f1
	j	fbge_cont.44985
fbge_else.44984:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.44985:
	j	fbge_cont.44983
fbge_else.44982:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.44983:
fbge_cont.44981:
	j	fbge_cont.44979
fbge_else.44978:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.44986
	fblt	＄f1, ＄f16, fbge_else.44988
	fmov	＄f0, ＄f1
	j	fbge_cont.44989
fbge_else.44988:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.44989:
	j	fbge_cont.44987
fbge_else.44986:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.44987:
fbge_cont.44979:
fbge_cont.44977:
	j	fbge_cont.44975
fbge_else.44974:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.44990
	fblt	＄f1, ＄f16, fbge_else.44992
	fmov	＄f0, ＄f1
	j	fbge_cont.44993
fbge_else.44992:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.44994
	fblt	＄f1, ＄f16, fbge_else.44996
	fmov	＄f0, ＄f1
	j	fbge_cont.44997
fbge_else.44996:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.44997:
	j	fbge_cont.44995
fbge_else.44994:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.44995:
fbge_cont.44993:
	j	fbge_cont.44991
fbge_else.44990:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.44998
	fblt	＄f1, ＄f16, fbge_else.45000
	fmov	＄f0, ＄f1
	j	fbge_cont.45001
fbge_else.45000:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45001:
	j	fbge_cont.44999
fbge_else.44998:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.44999:
fbge_cont.44991:
fbge_cont.44975:
	fblt	＄f31, ＄f0, fbge_else.45002
	fblt	＄f16, ＄f2, fbge_else.45004
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.45005
fbge_else.45004:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.45005:
	j	fbge_cont.45003
fbge_else.45002:
	fblt	＄f16, ＄f2, fbge_else.45006
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	fbge_cont.45007
fbge_else.45006:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
fbge_cont.45007:
fbge_cont.45003:
	fblt	＄f31, ＄f0, fbge_else.45008
	fmov	＄f1, ＄f0
	j	fbge_cont.45009
fbge_else.45008:
	fsub	＄f1, ＄f29, ＄f0
fbge_cont.45009:
	fblt	＄f22, ＄f1, fbge_else.45010
	fmov	＄f0, ＄f1
	j	fbge_cont.45011
fbge_else.45010:
	fsub	＄f0, ＄f31, ＄f1
fbge_cont.45011:
	fmul	＄f1, ＄f0, ＄f21
	fmul	＄f0, ＄f1, ＄f1
	fdiv	＄f2, ＄f0, ＄f25
	fsub	＄f2, ＄f26, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f24, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f23, ＄f2
	fdiv	＄f0, ＄f0, ＄f2
	fsub	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	fmul	＄f1, ＄f30, ＄f0
	fmul	＄f0, ＄f0, ＄f0
	fadd	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	beq	＄r3, ＄r0, bne_else.45012
	fmov	＄f1, ＄f0
	j	bne_cont.45013
bne_else.45012:
	fneg	＄f1, ＄f0
bne_cont.45013:
	fmul	＄f0, ＄f1, ＄f1
	fmul	＄f1, ＄f0, ＄f27
	fsti	＄f1, ＄r0, 449
	fsub	＄f0, ＄f17, ＄f0
	fmul	＄f0, ＄f0, ＄f27
	fsti	＄f0, ＄r0, 450
bne_cont.44935:
	j	bne_cont.44933
bne_else.44932:
	fldi	＄f1, ＄r0, 456
	# 0.250000
	fmvhi	＄f0, 16000
	fmvlo	＄f0, 0
	fmul	＄f2, ＄f1, ＄f0
	fblt	＄f2, ＄f16, fbge_else.45014
	fmov	＄f1, ＄f2
	j	fbge_cont.45015
fbge_else.45014:
	fneg	＄f1, ＄f2
fbge_cont.45015:
	fblt	＄f29, ＄f1, fbge_else.45016
	fblt	＄f1, ＄f16, fbge_else.45018
	fmov	＄f0, ＄f1
	j	fbge_cont.45019
fbge_else.45018:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.45020
	fblt	＄f1, ＄f16, fbge_else.45022
	fmov	＄f0, ＄f1
	j	fbge_cont.45023
fbge_else.45022:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.45024
	fblt	＄f1, ＄f16, fbge_else.45026
	fmov	＄f0, ＄f1
	j	fbge_cont.45027
fbge_else.45026:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
fbge_cont.45027:
	j	fbge_cont.45025
fbge_else.45024:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
fbge_cont.45025:
fbge_cont.45023:
	j	fbge_cont.45021
fbge_else.45020:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.45028
	fblt	＄f1, ＄f16, fbge_else.45030
	fmov	＄f0, ＄f1
	j	fbge_cont.45031
fbge_else.45030:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
fbge_cont.45031:
	j	fbge_cont.45029
fbge_else.45028:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
fbge_cont.45029:
fbge_cont.45021:
fbge_cont.45019:
	j	fbge_cont.45017
fbge_else.45016:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.45032
	fblt	＄f1, ＄f16, fbge_else.45034
	fmov	＄f0, ＄f1
	j	fbge_cont.45035
fbge_else.45034:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.45036
	fblt	＄f1, ＄f16, fbge_else.45038
	fmov	＄f0, ＄f1
	j	fbge_cont.45039
fbge_else.45038:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
fbge_cont.45039:
	j	fbge_cont.45037
fbge_else.45036:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
fbge_cont.45037:
fbge_cont.45035:
	j	fbge_cont.45033
fbge_else.45032:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.45040
	fblt	＄f1, ＄f16, fbge_else.45042
	fmov	＄f0, ＄f1
	j	fbge_cont.45043
fbge_else.45042:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
fbge_cont.45043:
	j	fbge_cont.45041
fbge_else.45040:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
fbge_cont.45041:
fbge_cont.45033:
fbge_cont.45017:
	fblt	＄f31, ＄f0, fbge_else.45044
	fblt	＄f16, ＄f2, fbge_else.45046
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.45047
fbge_else.45046:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.45047:
	j	fbge_cont.45045
fbge_else.45044:
	fblt	＄f16, ＄f2, fbge_else.45048
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	fbge_cont.45049
fbge_else.45048:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
fbge_cont.45049:
fbge_cont.45045:
	fblt	＄f31, ＄f0, fbge_else.45050
	fmov	＄f1, ＄f0
	j	fbge_cont.45051
fbge_else.45050:
	fsub	＄f1, ＄f29, ＄f0
fbge_cont.45051:
	fblt	＄f22, ＄f1, fbge_else.45052
	fmov	＄f0, ＄f1
	j	fbge_cont.45053
fbge_else.45052:
	fsub	＄f0, ＄f31, ＄f1
fbge_cont.45053:
	fmul	＄f1, ＄f0, ＄f21
	fmul	＄f0, ＄f1, ＄f1
	fdiv	＄f2, ＄f0, ＄f25
	fsub	＄f2, ＄f26, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f24, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f23, ＄f2
	fdiv	＄f0, ＄f0, ＄f2
	fsub	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	fmul	＄f1, ＄f30, ＄f0
	fmul	＄f0, ＄f0, ＄f0
	fadd	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	beq	＄r3, ＄r0, bne_else.45054
	fmov	＄f1, ＄f0
	j	bne_cont.45055
bne_else.45054:
	fneg	＄f1, ＄f0
bne_cont.45055:
	fmul	＄f0, ＄f1, ＄f1
	fmul	＄f1, ＄f27, ＄f0
	fsti	＄f1, ＄r0, 448
	fsub	＄f0, ＄f17, ＄f0
	fmul	＄f0, ＄f27, ＄f0
	fsti	＄f0, ＄r0, 449
bne_cont.44933:
	j	bne_cont.44931
bne_else.44930:
	fldi	＄f1, ＄r0, 455
	ldi	＄r6, ＄r4, 5
	fldi	＄f0, ＄r6, 0
	fsub	＄f5, ＄f1, ＄f0
	# 0.050000
	fmvhi	＄f6, 15692
	fmvlo	＄f6, 52420
	fmul	＄f0, ＄f5, ＄f6
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_floor
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	# 20.000000
	fmvhi	＄f7, 16800
	fmvlo	＄f7, 0
	fmul	＄f0, ＄f0, ＄f7
	fsub	＄f8, ＄f5, ＄f0
	# 10.000000
	fmvhi	＄f5, 16672
	fmvlo	＄f5, 0
	fldi	＄f1, ＄r0, 457
	fldi	＄f0, ＄r6, 2
	fsub	＄f9, ＄f1, ＄f0
	fmul	＄f0, ＄f9, ＄f6
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_floor
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	fmul	＄f0, ＄f0, ＄f7
	fsub	＄f0, ＄f9, ＄f0
	fblt	＄f8, ＄f5, fbge_else.45056
	fblt	＄f0, ＄f5, fbge_else.45058
	fmov	＄f8, ＄f27
	j	fbge_cont.45059
fbge_else.45058:
	fmov	＄f8, ＄f16
fbge_cont.45059:
	j	fbge_cont.45057
fbge_else.45056:
	fblt	＄f0, ＄f5, fbge_else.45060
	fmov	＄f8, ＄f16
	j	fbge_cont.45061
fbge_else.45060:
	fmov	＄f8, ＄f27
fbge_cont.45061:
fbge_cont.45057:
	fsti	＄f8, ＄r0, 449
bne_cont.44931:
	slli	＄r4, ＄r5, 2
	ldi	＄r3, ＄r0, 459
	add	＄r4, ＄r4, ＄r3
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r24, ＄r3
	sti	＄r4, ＄r28, 0
	ldi	＄r4, ＄r22, 1
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r4, ＄r3
	ldi	＄r3, ＄r28, 0
	fldi	＄f0, ＄r0, 455
	fsti	＄f0, ＄r3, 0
	fldi	＄f0, ＄r0, 456
	fsti	＄f0, ＄r3, 1
	fldi	＄f0, ＄r0, 457
	fsti	＄f0, ＄r3, 2
	ldi	＄r4, ＄r22, 3
	fldi	＄f0, ＄r23, 0
	fblt	＄f0, ＄f21, fbge_else.45062
	mvhi	＄r5, 0
	mvlo	＄r5, 1
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r4, ＄r3
	sti	＄r5, ＄r28, 0
	ldi	＄r4, ＄r22, 4
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r4, ＄r3
	ldi	＄r3, ＄r28, 0
	fldi	＄f0, ＄r0, 448
	fsti	＄f0, ＄r3, 0
	fldi	＄f0, ＄r0, 449
	fsti	＄f0, ＄r3, 1
	fldi	＄f0, ＄r0, 450
	fsti	＄f0, ＄r3, 2
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r4, ＄r3
	ldi	＄r3, ＄r28, 0
	# 0.003906
	fmvhi	＄f0, 15232
	fmvlo	＄f0, 0
	fmul	＄f0, ＄f0, ＄f11
	fldi	＄f1, ＄r3, 0
	fmul	＄f1, ＄f1, ＄f0
	fsti	＄f1, ＄r3, 0
	fldi	＄f1, ＄r3, 1
	fmul	＄f1, ＄f1, ＄f0
	fsti	＄f1, ＄r3, 1
	fldi	＄f1, ＄r3, 2
	fmul	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r3, 2
	ldi	＄r4, ＄r22, 7
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r4, ＄r3
	ldi	＄r3, ＄r28, 0
	fldi	＄f0, ＄r0, 451
	fsti	＄f0, ＄r3, 0
	fldi	＄f0, ＄r0, 452
	fsti	＄f0, ＄r3, 1
	fldi	＄f0, ＄r0, 453
	fsti	＄f0, ＄r3, 2
	j	fbge_cont.45063
fbge_else.45062:
	mvhi	＄r5, 0
	mvlo	＄r5, 0
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r4, ＄r3
	sti	＄r5, ＄r28, 0
fbge_cont.45063:
	# -2.000000
	fmvhi	＄f2, 49152
	fmvlo	＄f2, 0
	fldi	＄f1, ＄r19, 0
	fldi	＄f0, ＄r0, 451
	fmul	＄f5, ＄f1, ＄f0
	fldi	＄f4, ＄r19, 1
	fldi	＄f3, ＄r0, 452
	fmul	＄f3, ＄f4, ＄f3
	fadd	＄f5, ＄f5, ＄f3
	fldi	＄f4, ＄r19, 2
	fldi	＄f3, ＄r0, 453
	fmul	＄f3, ＄f4, ＄f3
	fadd	＄f3, ＄f5, ＄f3
	fmul	＄f2, ＄f2, ＄f3
	fmul	＄f0, ＄f2, ＄f0
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r19, 0
	fldi	＄f1, ＄r19, 1
	fldi	＄f0, ＄r0, 452
	fmul	＄f0, ＄f2, ＄f0
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r19, 1
	fldi	＄f1, ＄r19, 2
	fldi	＄f0, ＄r0, 453
	fmul	＄f0, ＄f2, ＄f0
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r19, 2
	fldi	＄f0, ＄r23, 1
	fmul	＄f10, ＄f14, ＄f0
	mvhi	＄r12, 0
	mvlo	＄r12, 0
	ldi	＄r13, ＄r0, 461
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_one_or_matrix.2902
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.45064
	j	bne_cont.45065
bne_else.45064:
	fldi	＄f1, ＄r0, 451
	fldi	＄f0, ＄r0, 513
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r0, 452
	fldi	＄f3, ＄r0, 514
	fmul	＄f1, ＄f1, ＄f3
	fadd	＄f4, ＄f2, ＄f1
	fldi	＄f1, ＄r0, 453
	fldi	＄f2, ＄r0, 515
	fmul	＄f1, ＄f1, ＄f2
	fadd	＄f1, ＄f4, ＄f1
	fneg	＄f1, ＄f1
	fmul	＄f1, ＄f1, ＄f11
	fldi	＄f4, ＄r19, 0
	fmul	＄f4, ＄f4, ＄f0
	fldi	＄f0, ＄r19, 1
	fmul	＄f0, ＄f0, ＄f3
	fadd	＄f3, ＄f4, ＄f0
	fldi	＄f0, ＄r19, 2
	fmul	＄f0, ＄f0, ＄f2
	fadd	＄f0, ＄f3, ＄f0
	fneg	＄f0, ＄f0
	fblt	＄f16, ＄f1, fbge_else.45066
	j	fbge_cont.45067
fbge_else.45066:
	fldi	＄f3, ＄r0, 442
	fldi	＄f2, ＄r0, 448
	fmul	＄f2, ＄f1, ＄f2
	fadd	＄f2, ＄f3, ＄f2
	fsti	＄f2, ＄r0, 442
	fldi	＄f3, ＄r0, 443
	fldi	＄f2, ＄r0, 449
	fmul	＄f2, ＄f1, ＄f2
	fadd	＄f2, ＄f3, ＄f2
	fsti	＄f2, ＄r0, 443
	fldi	＄f3, ＄r0, 444
	fldi	＄f2, ＄r0, 450
	fmul	＄f1, ＄f1, ＄f2
	fadd	＄f1, ＄f3, ＄f1
	fsti	＄f1, ＄r0, 444
fbge_cont.45067:
	fblt	＄f16, ＄f0, fbge_else.45068
	j	fbge_cont.45069
fbge_else.45068:
	fmul	＄f0, ＄f0, ＄f0
	fmul	＄f0, ＄f0, ＄f0
	fmul	＄f0, ＄f0, ＄f10
	fldi	＄f1, ＄r0, 442
	fadd	＄f1, ＄f1, ＄f0
	fsti	＄f1, ＄r0, 442
	fldi	＄f1, ＄r0, 443
	fadd	＄f1, ＄f1, ＄f0
	fsti	＄f1, ＄r0, 443
	fldi	＄f1, ＄r0, 444
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 444
fbge_cont.45069:
bne_cont.45065:
	fldi	＄f0, ＄r0, 455
	fsti	＄f0, ＄r0, 431
	fldi	＄f0, ＄r0, 456
	fsti	＄f0, ＄r0, 432
	fldi	＄f0, ＄r0, 457
	fsti	＄f0, ＄r0, 433
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r7, ＄r3, ＄r28
	blt	＄r7, ＄r0, bge_else.45070
	slli	＄r3, ＄r7, 0
	ldi	＄r3, ＄r3, 522
	ldi	＄r6, ＄r3, 10
	ldi	＄r5, ＄r3, 1
	fldi	＄f1, ＄r0, 455
	ldi	＄r4, ＄r3, 5
	fldi	＄f0, ＄r4, 0
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 0
	fldi	＄f1, ＄r0, 456
	fldi	＄f0, ＄r4, 1
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 1
	fldi	＄f1, ＄r0, 457
	fldi	＄f0, ＄r4, 2
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 2
	mvhi	＄r4, 0
	mvlo	＄r4, 2
	beq	＄r5, ＄r4, bne_else.45072
	mvhi	＄r4, 0
	mvlo	＄r4, 2
	blt	＄r4, ＄r5, ble_else.45074
	j	ble_cont.45075
ble_else.45074:
	fldi	＄f2, ＄r6, 0
	fldi	＄f1, ＄r6, 1
	fldi	＄f0, ＄r6, 2
	fmul	＄f4, ＄f2, ＄f2
	ldi	＄r4, ＄r3, 4
	fldi	＄f3, ＄r4, 0
	fmul	＄f5, ＄f4, ＄f3
	fmul	＄f4, ＄f1, ＄f1
	fldi	＄f3, ＄r4, 1
	fmul	＄f3, ＄f4, ＄f3
	fadd	＄f5, ＄f5, ＄f3
	fmul	＄f4, ＄f0, ＄f0
	fldi	＄f3, ＄r4, 2
	fmul	＄f3, ＄f4, ＄f3
	fadd	＄f4, ＄f5, ＄f3
	ldi	＄r4, ＄r3, 3
	beq	＄r4, ＄r0, bne_else.45076
	fmul	＄f5, ＄f1, ＄f0
	ldi	＄r3, ＄r3, 9
	fldi	＄f3, ＄r3, 0
	fmul	＄f3, ＄f5, ＄f3
	fadd	＄f4, ＄f4, ＄f3
	fmul	＄f3, ＄f0, ＄f2
	fldi	＄f0, ＄r3, 1
	fmul	＄f0, ＄f3, ＄f0
	fadd	＄f4, ＄f4, ＄f0
	fmul	＄f1, ＄f2, ＄f1
	fldi	＄f0, ＄r3, 2
	fmul	＄f3, ＄f1, ＄f0
	fadd	＄f3, ＄f4, ＄f3
	j	bne_cont.45077
bne_else.45076:
	fmov	＄f3, ＄f4
bne_cont.45077:
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	beq	＄r5, ＄r3, bne_else.45078
	fmov	＄f0, ＄f3
	j	bne_cont.45079
bne_else.45078:
	fsub	＄f0, ＄f3, ＄f17
bne_cont.45079:
	fsti	＄f0, ＄r6, 3
ble_cont.45075:
	j	bne_cont.45073
bne_else.45072:
	ldi	＄r3, ＄r3, 4
	fldi	＄f1, ＄r6, 0
	fldi	＄f3, ＄r6, 1
	fldi	＄f2, ＄r6, 2
	fldi	＄f0, ＄r3, 0
	fmul	＄f1, ＄f0, ＄f1
	fldi	＄f0, ＄r3, 1
	fmul	＄f0, ＄f0, ＄f3
	fadd	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r3, 2
	fmul	＄f0, ＄f0, ＄f2
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 3
bne_cont.45073:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r4, ＄r7, ＄r28
	mvhi	＄r28, 65535
	mvlo	＄r28, -455
	sub	＄r3, ＄r0, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	setup_startp_constants.2865
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	j	bge_cont.45071
bge_else.45070:
bge_cont.45071:
	ldi	＄r3, ＄r0, 160
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r17, ＄r3, ＄r28
	sti	＄r19, ＄r1, -1
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_reflections.2949
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	# 0.100000
	fmvhi	＄f0, 15820
	fmvlo	＄f0, 52420
	fblt	＄f0, ＄f14, fbge_else.45080
	return
fbge_else.45080:
	mvhi	＄r3, 0
	mvlo	＄r3, 4
	blt	＄r21, ＄r3, ble_else.45082
	j	ble_cont.45083
ble_else.45082:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r3, ＄r21, ＄r28
	mvhi	＄r4, 65535
	mvlo	＄r4, -1
	slli	＄r3, ＄r3, 0
	add	＄r28, ＄r24, ＄r3
	sti	＄r4, ＄r28, 0
ble_cont.45083:
	mvhi	＄r3, 0
	mvlo	＄r3, 2
	beq	＄r25, ＄r3, bne_else.45084
	return
bne_else.45084:
	fldi	＄f0, ＄r23, 0
	fsub	＄f0, ＄f17, ＄f0
	fmul	＄f14, ＄f14, ＄f0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r21, ＄r21, ＄r28
	fldi	＄f0, ＄r0, 458
	fldi	＄f12, ＄r1, 0
	fadd	＄f12, ＄f12, ＄f0
	ldi	＄r19, ＄r1, -1
	j	trace_ray.2954
bne_else.44915:
	mvhi	＄r4, 65535
	mvlo	＄r4, -1
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r24, ＄r3
	sti	＄r4, ＄r28, 0
	beq	＄r21, ＄r0, bne_else.45086
	fldi	＄f1, ＄r19, 0
	fldi	＄f0, ＄r0, 513
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r19, 1
	fldi	＄f0, ＄r0, 514
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r19, 2
	fldi	＄f0, ＄r0, 515
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fneg	＄f0, ＄f0
	fblt	＄f16, ＄f0, fbge_else.45087
	return
fbge_else.45087:
	fmul	＄f1, ＄f0, ＄f0
	fmul	＄f0, ＄f1, ＄f0
	fmul	＄f1, ＄f0, ＄f14
	fldi	＄f0, ＄r0, 512
	fmul	＄f0, ＄f1, ＄f0
	fldi	＄f1, ＄r0, 442
	fadd	＄f1, ＄f1, ＄f0
	fsti	＄f1, ＄r0, 442
	fldi	＄f1, ＄r0, 443
	fadd	＄f1, ＄f1, ＄f0
	fsti	＄f1, ＄r0, 443
	fldi	＄f1, ＄r0, 444
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 444
	return
bne_else.45086:
	return
ble_else.44910:
	return

#---------------------------------------------------------------------
# args = [＄r10]
# fargs = [＄f10]
# ret type = Unit
#---------------------------------------------------------------------
trace_diffuse_ray.2960:
	# 1000000000.000000
	fmvhi	＄f0, 20078
	fmvlo	＄f0, 27432
	fsti	＄f0, ＄r0, 458
	mvhi	＄r15, 0
	mvlo	＄r15, 0
	ldi	＄r16, ＄r0, 461
	sti	＄r10, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	trace_or_matrix_fast.2927
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	fldi	＄f0, ＄r0, 458
	# -0.100000
	fmvhi	＄f1, 48588
	fmvlo	＄f1, 52420
	fblt	＄f1, ＄f0, fbge_else.45092
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.45093
fbge_else.45092:
	# 100000000.000000
	fmvhi	＄f1, 19646
	fmvlo	＄f1, 48160
	fblt	＄f0, ＄f1, fbge_else.45094
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.45095
fbge_else.45094:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.45095:
fbge_cont.45093:
	beq	＄r3, ＄r0, bne_else.45096
	ldi	＄r3, ＄r0, 454
	slli	＄r3, ＄r3, 0
	ldi	＄r14, ＄r3, 522
	ldi	＄r10, ＄r1, 0
	ldi	＄r4, ＄r10, 0
	ldi	＄r3, ＄r14, 1
	beq	＄r3, ＄r29, bne_else.45097
	mvhi	＄r4, 0
	mvlo	＄r4, 2
	beq	＄r3, ＄r4, bne_else.45099
	fldi	＄f1, ＄r0, 455
	ldi	＄r3, ＄r14, 5
	fldi	＄f0, ＄r3, 0
	fsub	＄f4, ＄f1, ＄f0
	fldi	＄f1, ＄r0, 456
	fldi	＄f0, ＄r3, 1
	fsub	＄f3, ＄f1, ＄f0
	fldi	＄f1, ＄r0, 457
	fldi	＄f0, ＄r3, 2
	fsub	＄f0, ＄f1, ＄f0
	ldi	＄r3, ＄r14, 4
	fldi	＄f1, ＄r3, 0
	fmul	＄f2, ＄f4, ＄f1
	fldi	＄f1, ＄r3, 1
	fmul	＄f6, ＄f3, ＄f1
	fldi	＄f1, ＄r3, 2
	fmul	＄f7, ＄f0, ＄f1
	ldi	＄r3, ＄r14, 3
	beq	＄r3, ＄r0, bne_else.45101
	ldi	＄r3, ＄r14, 9
	fldi	＄f1, ＄r3, 2
	fmul	＄f5, ＄f3, ＄f1
	fldi	＄f1, ＄r3, 1
	fmul	＄f1, ＄f0, ＄f1
	fadd	＄f1, ＄f5, ＄f1
	fmul	＄f1, ＄f1, ＄f21
	fadd	＄f1, ＄f2, ＄f1
	fsti	＄f1, ＄r0, 451
	fldi	＄f1, ＄r3, 2
	fmul	＄f2, ＄f4, ＄f1
	fldi	＄f1, ＄r3, 0
	fmul	＄f0, ＄f0, ＄f1
	fadd	＄f0, ＄f2, ＄f0
	fmul	＄f0, ＄f0, ＄f21
	fadd	＄f0, ＄f6, ＄f0
	fsti	＄f0, ＄r0, 452
	fldi	＄f0, ＄r3, 1
	fmul	＄f1, ＄f4, ＄f0
	fldi	＄f0, ＄r3, 0
	fmul	＄f0, ＄f3, ＄f0
	fadd	＄f0, ＄f1, ＄f0
	fmul	＄f0, ＄f0, ＄f21
	fadd	＄f0, ＄f7, ＄f0
	fsti	＄f0, ＄r0, 453
	j	bne_cont.45102
bne_else.45101:
	fsti	＄f2, ＄r0, 451
	fsti	＄f6, ＄r0, 452
	fsti	＄f7, ＄r0, 453
bne_cont.45102:
	ldi	＄r3, ＄r14, 6
	fldi	＄f2, ＄r0, 451
	fmul	＄f1, ＄f2, ＄f2
	fldi	＄f0, ＄r0, 452
	fmul	＄f0, ＄f0, ＄f0
	fadd	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r0, 453
	fmul	＄f0, ＄f0, ＄f0
	fadd	＄f0, ＄f1, ＄f0
	fsqrt	＄f1, ＄f0
	fbne	＄f1, ＄f16, fbeq_else.45103
	fmov	＄f0, ＄f17
	j	fbeq_cont.45104
fbeq_else.45103:
	beq	＄r3, ＄r0, bne_else.45105
	fdiv	＄f0, ＄f20, ＄f1
	j	bne_cont.45106
bne_else.45105:
	fdiv	＄f0, ＄f17, ＄f1
bne_cont.45106:
fbeq_cont.45104:
	fmul	＄f1, ＄f2, ＄f0
	fsti	＄f1, ＄r0, 451
	fldi	＄f1, ＄r0, 452
	fmul	＄f1, ＄f1, ＄f0
	fsti	＄f1, ＄r0, 452
	fldi	＄f1, ＄r0, 453
	fmul	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 453
	j	bne_cont.45100
bne_else.45099:
	ldi	＄r3, ＄r14, 4
	fldi	＄f0, ＄r3, 0
	fneg	＄f0, ＄f0
	fsti	＄f0, ＄r0, 451
	fldi	＄f0, ＄r3, 1
	fneg	＄f0, ＄f0
	fsti	＄f0, ＄r0, 452
	fldi	＄f0, ＄r3, 2
	fneg	＄f0, ＄f0
	fsti	＄f0, ＄r0, 453
bne_cont.45100:
	j	bne_cont.45098
bne_else.45097:
	ldi	＄r3, ＄r0, 459
	fsti	＄f16, ＄r0, 451
	fsti	＄f16, ＄r0, 452
	fsti	＄f16, ＄r0, 453
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	slli	＄r3, ＄r5, 0
	add	＄r28, ＄r4, ＄r3
	fldi	＄f1, ＄r28, 0
	fbne	＄f1, ＄f16, fbeq_else.45107
	fmov	＄f0, ＄f16
	j	fbeq_cont.45108
fbeq_else.45107:
	fblt	＄f16, ＄f1, fbge_else.45109
	fmov	＄f0, ＄f20
	j	fbge_cont.45110
fbge_else.45109:
	fmov	＄f0, ＄f17
fbge_cont.45110:
fbeq_cont.45108:
	fneg	＄f0, ＄f0
	slli	＄r3, ＄r5, 0
	fsti	＄f0, ＄r3, 451
bne_cont.45098:
	ldi	＄r3, ＄r14, 0
	ldi	＄r4, ＄r14, 8
	fldi	＄f0, ＄r4, 0
	fsti	＄f0, ＄r0, 448
	fldi	＄f0, ＄r4, 1
	fsti	＄f0, ＄r0, 449
	fldi	＄f0, ＄r4, 2
	fsti	＄f0, ＄r0, 450
	beq	＄r3, ＄r29, bne_else.45111
	mvhi	＄r4, 0
	mvlo	＄r4, 2
	beq	＄r3, ＄r4, bne_else.45113
	mvhi	＄r4, 0
	mvlo	＄r4, 3
	beq	＄r3, ＄r4, bne_else.45115
	mvhi	＄r4, 0
	mvlo	＄r4, 4
	beq	＄r3, ＄r4, bne_else.45117
	j	bne_cont.45118
bne_else.45117:
	fldi	＄f1, ＄r0, 455
	ldi	＄r5, ＄r14, 5
	fldi	＄f0, ＄r5, 0
	fsub	＄f1, ＄f1, ＄f0
	ldi	＄r6, ＄r14, 4
	fldi	＄f0, ＄r6, 0
	fsqrt	＄f0, ＄f0
	fmul	＄f1, ＄f1, ＄f0
	fldi	＄f2, ＄r0, 457
	fldi	＄f0, ＄r5, 2
	fsub	＄f2, ＄f2, ＄f0
	fldi	＄f0, ＄r6, 2
	fsqrt	＄f0, ＄f0
	fmul	＄f2, ＄f2, ＄f0
	fmul	＄f3, ＄f1, ＄f1
	fmul	＄f0, ＄f2, ＄f2
	fadd	＄f5, ＄f3, ＄f0
	fblt	＄f1, ＄f16, fbge_else.45119
	fmov	＄f0, ＄f1
	j	fbge_cont.45120
fbge_else.45119:
	fneg	＄f0, ＄f1
fbge_cont.45120:
	# 0.000100
	fmvhi	＄f6, 14545
	fmvlo	＄f6, 46863
	fblt	＄f0, ＄f6, fbge_else.45121
	fdiv	＄f1, ＄f2, ＄f1
	fblt	＄f1, ＄f16, fbge_else.45123
	fmov	＄f0, ＄f1
	j	fbge_cont.45124
fbge_else.45123:
	fneg	＄f0, ＄f1
fbge_cont.45124:
	fblt	＄f17, ＄f0, fbge_else.45125
	fblt	＄f0, ＄f20, fbge_else.45127
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.45128
fbge_else.45127:
	mvhi	＄r3, 65535
	mvlo	＄r3, -1
fbge_cont.45128:
	j	fbge_cont.45126
fbge_else.45125:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.45126:
	beq	＄r3, ＄r0, bne_else.45129
	fdiv	＄f4, ＄f17, ＄f0
	j	bne_cont.45130
bne_else.45129:
	fmov	＄f4, ＄f0
bne_cont.45130:
	fmul	＄f0, ＄f4, ＄f4
	# 121.000000
	fmvhi	＄f1, 17138
	fmvlo	＄f1, 0
	fmul	＄f2, ＄f1, ＄f0
	# 23.000000
	fmvhi	＄f1, 16824
	fmvlo	＄f1, 0
	fdiv	＄f2, ＄f2, ＄f1
	# 100.000000
	fmvhi	＄f1, 17096
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	# 21.000000
	fmvhi	＄f1, 16808
	fmvlo	＄f1, 0
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 81.000000
	fmvhi	＄f1, 17058
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	# 19.000000
	fmvhi	＄f1, 16792
	fmvlo	＄f1, 0
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 64.000000
	fmvhi	＄f1, 17024
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	# 17.000000
	fmvhi	＄f1, 16776
	fmvlo	＄f1, 0
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 49.000000
	fmvhi	＄f1, 16964
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	fadd	＄f1, ＄f28, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 36.000000
	fmvhi	＄f1, 16912
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	# 13.000000
	fmvhi	＄f1, 16720
	fmvlo	＄f1, 0
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 25.000000
	fmvhi	＄f1, 16840
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	# 11.000000
	fmvhi	＄f1, 16688
	fmvlo	＄f1, 0
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 16.000000
	fmvhi	＄f1, 16768
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	fadd	＄f1, ＄f25, ＄f2
	fdiv	＄f1, ＄f3, ＄f1
	fmul	＄f2, ＄f25, ＄f0
	fadd	＄f1, ＄f26, ＄f1
	fdiv	＄f2, ＄f2, ＄f1
	# 4.000000
	fmvhi	＄f1, 16512
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	fadd	＄f1, ＄f24, ＄f2
	fdiv	＄f1, ＄f3, ＄f1
	fadd	＄f1, ＄f23, ＄f1
	fdiv	＄f0, ＄f0, ＄f1
	fadd	＄f0, ＄f17, ＄f0
	fdiv	＄f1, ＄f4, ＄f0
	blt	＄r0, ＄r3, ble_else.45131
	blt	＄r3, ＄r0, bge_else.45133
	fmov	＄f0, ＄f1
	j	bge_cont.45134
bge_else.45133:
	# -1.570796
	fmvhi	＄f0, 49097
	fmvlo	＄f0, 4058
	fsub	＄f0, ＄f0, ＄f1
bge_cont.45134:
	j	ble_cont.45132
ble_else.45131:
	fsub	＄f0, ＄f22, ＄f1
ble_cont.45132:
	# 30.000000
	fmvhi	＄f1, 16880
	fmvlo	＄f1, 0
	fmul	＄f1, ＄f0, ＄f1
	# 3.141593
	fmvhi	＄f0, 16457
	fmvlo	＄f0, 4058
	fdiv	＄f0, ＄f1, ＄f0
	j	fbge_cont.45122
fbge_else.45121:
	fmov	＄f0, ＄f28
fbge_cont.45122:
	fsti	＄f0, ＄r1, -1
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_floor
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	fmov	＄f1, ＄f0
	fldi	＄f0, ＄r1, -1
	fsub	＄f7, ＄f0, ＄f1
	fldi	＄f1, ＄r0, 456
	fldi	＄f0, ＄r5, 1
	fsub	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r6, 1
	fsqrt	＄f0, ＄f0
	fmul	＄f1, ＄f1, ＄f0
	fblt	＄f5, ＄f16, fbge_else.45135
	fmov	＄f0, ＄f5
	j	fbge_cont.45136
fbge_else.45135:
	fneg	＄f0, ＄f5
fbge_cont.45136:
	fblt	＄f0, ＄f6, fbge_else.45137
	fdiv	＄f1, ＄f1, ＄f5
	fblt	＄f1, ＄f16, fbge_else.45139
	fmov	＄f0, ＄f1
	j	fbge_cont.45140
fbge_else.45139:
	fneg	＄f0, ＄f1
fbge_cont.45140:
	fblt	＄f17, ＄f0, fbge_else.45141
	fblt	＄f0, ＄f20, fbge_else.45143
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.45144
fbge_else.45143:
	mvhi	＄r3, 65535
	mvlo	＄r3, -1
fbge_cont.45144:
	j	fbge_cont.45142
fbge_else.45141:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.45142:
	beq	＄r3, ＄r0, bne_else.45145
	fdiv	＄f4, ＄f17, ＄f0
	j	bne_cont.45146
bne_else.45145:
	fmov	＄f4, ＄f0
bne_cont.45146:
	fmul	＄f0, ＄f4, ＄f4
	# 121.000000
	fmvhi	＄f1, 17138
	fmvlo	＄f1, 0
	fmul	＄f2, ＄f1, ＄f0
	# 23.000000
	fmvhi	＄f1, 16824
	fmvlo	＄f1, 0
	fdiv	＄f2, ＄f2, ＄f1
	# 100.000000
	fmvhi	＄f1, 17096
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	# 21.000000
	fmvhi	＄f1, 16808
	fmvlo	＄f1, 0
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 81.000000
	fmvhi	＄f1, 17058
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	# 19.000000
	fmvhi	＄f1, 16792
	fmvlo	＄f1, 0
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 64.000000
	fmvhi	＄f1, 17024
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	# 17.000000
	fmvhi	＄f1, 16776
	fmvlo	＄f1, 0
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 49.000000
	fmvhi	＄f1, 16964
	fmvlo	＄f1, 0
	fmul	＄f1, ＄f1, ＄f0
	fadd	＄f2, ＄f28, ＄f2
	fdiv	＄f2, ＄f1, ＄f2
	# 36.000000
	fmvhi	＄f1, 16912
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	# 13.000000
	fmvhi	＄f1, 16720
	fmvlo	＄f1, 0
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 25.000000
	fmvhi	＄f1, 16840
	fmvlo	＄f1, 0
	fmul	＄f3, ＄f1, ＄f0
	# 11.000000
	fmvhi	＄f1, 16688
	fmvlo	＄f1, 0
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f1, ＄f3, ＄f1
	# 16.000000
	fmvhi	＄f2, 16768
	fmvlo	＄f2, 0
	fmul	＄f2, ＄f2, ＄f0
	fadd	＄f1, ＄f25, ＄f1
	fdiv	＄f2, ＄f2, ＄f1
	fmul	＄f1, ＄f25, ＄f0
	fadd	＄f2, ＄f26, ＄f2
	fdiv	＄f1, ＄f1, ＄f2
	# 4.000000
	fmvhi	＄f2, 16512
	fmvlo	＄f2, 0
	fmul	＄f2, ＄f2, ＄f0
	fadd	＄f1, ＄f24, ＄f1
	fdiv	＄f1, ＄f2, ＄f1
	fadd	＄f1, ＄f23, ＄f1
	fdiv	＄f0, ＄f0, ＄f1
	fadd	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f4, ＄f0
	blt	＄r0, ＄r3, ble_else.45147
	blt	＄r3, ＄r0, bge_else.45149
	fmov	＄f1, ＄f0
	j	bge_cont.45150
bge_else.45149:
	# -1.570796
	fmvhi	＄f1, 49097
	fmvlo	＄f1, 4058
	fsub	＄f1, ＄f1, ＄f0
bge_cont.45150:
	j	ble_cont.45148
ble_else.45147:
	fsub	＄f1, ＄f22, ＄f0
ble_cont.45148:
	# 30.000000
	fmvhi	＄f0, 16880
	fmvlo	＄f0, 0
	fmul	＄f1, ＄f1, ＄f0
	# 3.141593
	fmvhi	＄f0, 16457
	fmvlo	＄f0, 4058
	fdiv	＄f0, ＄f1, ＄f0
	j	fbge_cont.45138
fbge_else.45137:
	fmov	＄f0, ＄f28
fbge_cont.45138:
	fsti	＄f0, ＄r1, -2
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_floor
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	add	＄r1, ＄r1, ＄r28
	fmov	＄f1, ＄f0
	fldi	＄f0, ＄r1, -2
	fsub	＄f0, ＄f0, ＄f1
	# 0.150000
	fmvhi	＄f2, 15897
	fmvlo	＄f2, 39321
	fsub	＄f1, ＄f21, ＄f7
	fmul	＄f1, ＄f1, ＄f1
	fsub	＄f1, ＄f2, ＄f1
	fsub	＄f0, ＄f21, ＄f0
	fmul	＄f0, ＄f0, ＄f0
	fsub	＄f1, ＄f1, ＄f0
	fblt	＄f1, ＄f16, fbge_else.45151
	fmov	＄f0, ＄f1
	j	fbge_cont.45152
fbge_else.45151:
	fmov	＄f0, ＄f16
fbge_cont.45152:
	fmul	＄f1, ＄f27, ＄f0
	# 0.300000
	fmvhi	＄f0, 16025
	fmvlo	＄f0, 39321
	fdiv	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 450
bne_cont.45118:
	j	bne_cont.45116
bne_else.45115:
	fldi	＄f1, ＄r0, 455
	ldi	＄r3, ＄r14, 5
	fldi	＄f0, ＄r3, 0
	fsub	＄f0, ＄f1, ＄f0
	fldi	＄f2, ＄r0, 457
	fldi	＄f1, ＄r3, 2
	fsub	＄f1, ＄f2, ＄f1
	fmul	＄f0, ＄f0, ＄f0
	fmul	＄f1, ＄f1, ＄f1
	fadd	＄f0, ＄f0, ＄f1
	fsqrt	＄f0, ＄f0
	# 10.000000
	fmvhi	＄f1, 16672
	fmvlo	＄f1, 0
	fdiv	＄f0, ＄f0, ＄f1
	fsti	＄f0, ＄r1, -1
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_floor
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	fmov	＄f1, ＄f0
	fldi	＄f0, ＄r1, -1
	fsub	＄f1, ＄f0, ＄f1
	# 3.141593
	fmvhi	＄f0, 16457
	fmvlo	＄f0, 4058
	fmul	＄f0, ＄f1, ＄f0
	fsub	＄f2, ＄f22, ＄f0
	fblt	＄f2, ＄f16, fbge_else.45153
	fmov	＄f1, ＄f2
	j	fbge_cont.45154
fbge_else.45153:
	fneg	＄f1, ＄f2
fbge_cont.45154:
	fblt	＄f29, ＄f1, fbge_else.45155
	fblt	＄f1, ＄f16, fbge_else.45157
	fmov	＄f0, ＄f1
	j	fbge_cont.45158
fbge_else.45157:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.45159
	fblt	＄f1, ＄f16, fbge_else.45161
	fmov	＄f0, ＄f1
	j	fbge_cont.45162
fbge_else.45161:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.45163
	fblt	＄f1, ＄f16, fbge_else.45165
	fmov	＄f0, ＄f1
	j	fbge_cont.45166
fbge_else.45165:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45166:
	j	fbge_cont.45164
fbge_else.45163:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45164:
fbge_cont.45162:
	j	fbge_cont.45160
fbge_else.45159:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.45167
	fblt	＄f1, ＄f16, fbge_else.45169
	fmov	＄f0, ＄f1
	j	fbge_cont.45170
fbge_else.45169:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45170:
	j	fbge_cont.45168
fbge_else.45167:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45168:
fbge_cont.45160:
fbge_cont.45158:
	j	fbge_cont.45156
fbge_else.45155:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.45171
	fblt	＄f1, ＄f16, fbge_else.45173
	fmov	＄f0, ＄f1
	j	fbge_cont.45174
fbge_else.45173:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.45175
	fblt	＄f1, ＄f16, fbge_else.45177
	fmov	＄f0, ＄f1
	j	fbge_cont.45178
fbge_else.45177:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45178:
	j	fbge_cont.45176
fbge_else.45175:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45176:
fbge_cont.45174:
	j	fbge_cont.45172
fbge_else.45171:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.45179
	fblt	＄f1, ＄f16, fbge_else.45181
	fmov	＄f0, ＄f1
	j	fbge_cont.45182
fbge_else.45181:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45182:
	j	fbge_cont.45180
fbge_else.45179:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45180:
fbge_cont.45172:
fbge_cont.45156:
	fblt	＄f31, ＄f0, fbge_else.45183
	fblt	＄f16, ＄f2, fbge_else.45185
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.45186
fbge_else.45185:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.45186:
	j	fbge_cont.45184
fbge_else.45183:
	fblt	＄f16, ＄f2, fbge_else.45187
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	fbge_cont.45188
fbge_else.45187:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
fbge_cont.45188:
fbge_cont.45184:
	fblt	＄f31, ＄f0, fbge_else.45189
	fmov	＄f1, ＄f0
	j	fbge_cont.45190
fbge_else.45189:
	fsub	＄f1, ＄f29, ＄f0
fbge_cont.45190:
	fblt	＄f22, ＄f1, fbge_else.45191
	fmov	＄f0, ＄f1
	j	fbge_cont.45192
fbge_else.45191:
	fsub	＄f0, ＄f31, ＄f1
fbge_cont.45192:
	fmul	＄f1, ＄f0, ＄f21
	fmul	＄f0, ＄f1, ＄f1
	fdiv	＄f2, ＄f0, ＄f25
	fsub	＄f2, ＄f26, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f24, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f23, ＄f2
	fdiv	＄f0, ＄f0, ＄f2
	fsub	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	fmul	＄f1, ＄f30, ＄f0
	fmul	＄f0, ＄f0, ＄f0
	fadd	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	beq	＄r3, ＄r0, bne_else.45193
	fmov	＄f1, ＄f0
	j	bne_cont.45194
bne_else.45193:
	fneg	＄f1, ＄f0
bne_cont.45194:
	fmul	＄f0, ＄f1, ＄f1
	fmul	＄f1, ＄f0, ＄f27
	fsti	＄f1, ＄r0, 449
	fsub	＄f0, ＄f17, ＄f0
	fmul	＄f0, ＄f0, ＄f27
	fsti	＄f0, ＄r0, 450
bne_cont.45116:
	j	bne_cont.45114
bne_else.45113:
	fldi	＄f1, ＄r0, 456
	# 0.250000
	fmvhi	＄f0, 16000
	fmvlo	＄f0, 0
	fmul	＄f2, ＄f1, ＄f0
	fblt	＄f2, ＄f16, fbge_else.45195
	fmov	＄f1, ＄f2
	j	fbge_cont.45196
fbge_else.45195:
	fneg	＄f1, ＄f2
fbge_cont.45196:
	fblt	＄f29, ＄f1, fbge_else.45197
	fblt	＄f1, ＄f16, fbge_else.45199
	fmov	＄f0, ＄f1
	j	fbge_cont.45200
fbge_else.45199:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.45201
	fblt	＄f1, ＄f16, fbge_else.45203
	fmov	＄f0, ＄f1
	j	fbge_cont.45204
fbge_else.45203:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.45205
	fblt	＄f1, ＄f16, fbge_else.45207
	fmov	＄f0, ＄f1
	j	fbge_cont.45208
fbge_else.45207:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
fbge_cont.45208:
	j	fbge_cont.45206
fbge_else.45205:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
fbge_cont.45206:
fbge_cont.45204:
	j	fbge_cont.45202
fbge_else.45201:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.45209
	fblt	＄f1, ＄f16, fbge_else.45211
	fmov	＄f0, ＄f1
	j	fbge_cont.45212
fbge_else.45211:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
fbge_cont.45212:
	j	fbge_cont.45210
fbge_else.45209:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
fbge_cont.45210:
fbge_cont.45202:
fbge_cont.45200:
	j	fbge_cont.45198
fbge_else.45197:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.45213
	fblt	＄f1, ＄f16, fbge_else.45215
	fmov	＄f0, ＄f1
	j	fbge_cont.45216
fbge_else.45215:
	fadd	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.45217
	fblt	＄f1, ＄f16, fbge_else.45219
	fmov	＄f0, ＄f1
	j	fbge_cont.45220
fbge_else.45219:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
fbge_cont.45220:
	j	fbge_cont.45218
fbge_else.45217:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
fbge_cont.45218:
fbge_cont.45216:
	j	fbge_cont.45214
fbge_else.45213:
	fsub	＄f1, ＄f1, ＄f29
	fblt	＄f29, ＄f1, fbge_else.45221
	fblt	＄f1, ＄f16, fbge_else.45223
	fmov	＄f0, ＄f1
	j	fbge_cont.45224
fbge_else.45223:
	fadd	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
fbge_cont.45224:
	j	fbge_cont.45222
fbge_else.45221:
	fsub	＄f1, ＄f1, ＄f29
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	sin_sub.2547
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
fbge_cont.45222:
fbge_cont.45214:
fbge_cont.45198:
	fblt	＄f31, ＄f0, fbge_else.45225
	fblt	＄f16, ＄f2, fbge_else.45227
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	fbge_cont.45228
fbge_else.45227:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
fbge_cont.45228:
	j	fbge_cont.45226
fbge_else.45225:
	fblt	＄f16, ＄f2, fbge_else.45229
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	j	fbge_cont.45230
fbge_else.45229:
	mvhi	＄r3, 0
	mvlo	＄r3, 0
fbge_cont.45230:
fbge_cont.45226:
	fblt	＄f31, ＄f0, fbge_else.45231
	fmov	＄f1, ＄f0
	j	fbge_cont.45232
fbge_else.45231:
	fsub	＄f1, ＄f29, ＄f0
fbge_cont.45232:
	fblt	＄f22, ＄f1, fbge_else.45233
	fmov	＄f0, ＄f1
	j	fbge_cont.45234
fbge_else.45233:
	fsub	＄f0, ＄f31, ＄f1
fbge_cont.45234:
	fmul	＄f1, ＄f0, ＄f21
	fmul	＄f0, ＄f1, ＄f1
	fdiv	＄f2, ＄f0, ＄f25
	fsub	＄f2, ＄f26, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f24, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f23, ＄f2
	fdiv	＄f0, ＄f0, ＄f2
	fsub	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	fmul	＄f1, ＄f30, ＄f0
	fmul	＄f0, ＄f0, ＄f0
	fadd	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	beq	＄r3, ＄r0, bne_else.45235
	fmov	＄f1, ＄f0
	j	bne_cont.45236
bne_else.45235:
	fneg	＄f1, ＄f0
bne_cont.45236:
	fmul	＄f0, ＄f1, ＄f1
	fmul	＄f1, ＄f27, ＄f0
	fsti	＄f1, ＄r0, 448
	fsub	＄f0, ＄f17, ＄f0
	fmul	＄f0, ＄f27, ＄f0
	fsti	＄f0, ＄r0, 449
bne_cont.45114:
	j	bne_cont.45112
bne_else.45111:
	fldi	＄f1, ＄r0, 455
	ldi	＄r5, ＄r14, 5
	fldi	＄f0, ＄r5, 0
	fsub	＄f5, ＄f1, ＄f0
	# 0.050000
	fmvhi	＄f9, 15692
	fmvlo	＄f9, 52420
	fmul	＄f0, ＄f5, ＄f9
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_floor
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	# 20.000000
	fmvhi	＄f8, 16800
	fmvlo	＄f8, 0
	fmul	＄f0, ＄f0, ＄f8
	fsub	＄f7, ＄f5, ＄f0
	# 10.000000
	fmvhi	＄f6, 16672
	fmvlo	＄f6, 0
	fldi	＄f1, ＄r0, 457
	fldi	＄f0, ＄r5, 2
	fsub	＄f5, ＄f1, ＄f0
	fmul	＄f0, ＄f5, ＄f9
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_floor
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	fmul	＄f0, ＄f0, ＄f8
	fsub	＄f1, ＄f5, ＄f0
	fblt	＄f7, ＄f6, fbge_else.45237
	fblt	＄f1, ＄f6, fbge_else.45239
	fmov	＄f0, ＄f27
	j	fbge_cont.45240
fbge_else.45239:
	fmov	＄f0, ＄f16
fbge_cont.45240:
	j	fbge_cont.45238
fbge_else.45237:
	fblt	＄f1, ＄f6, fbge_else.45241
	fmov	＄f0, ＄f16
	j	fbge_cont.45242
fbge_else.45241:
	fmov	＄f0, ＄f27
fbge_cont.45242:
fbge_cont.45238:
	fsti	＄f0, ＄r0, 449
bne_cont.45112:
	mvhi	＄r12, 0
	mvlo	＄r12, 0
	ldi	＄r13, ＄r0, 461
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	shadow_check_one_or_matrix.2902
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	beq	＄r3, ＄r0, bne_else.45243
	return
bne_else.45243:
	fldi	＄f1, ＄r0, 451
	fldi	＄f0, ＄r0, 513
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r0, 452
	fldi	＄f0, ＄r0, 514
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r0, 453
	fldi	＄f0, ＄r0, 515
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f1, ＄f2, ＄f0
	fneg	＄f1, ＄f1
	fblt	＄f16, ＄f1, fbge_else.45245
	fmov	＄f0, ＄f16
	j	fbge_cont.45246
fbge_else.45245:
	fmov	＄f0, ＄f1
fbge_cont.45246:
	fmul	＄f1, ＄f10, ＄f0
	ldi	＄r3, ＄r14, 7
	fldi	＄f0, ＄r3, 0
	fmul	＄f0, ＄f1, ＄f0
	fldi	＄f2, ＄r0, 445
	fldi	＄f1, ＄r0, 448
	fmul	＄f1, ＄f0, ＄f1
	fadd	＄f1, ＄f2, ＄f1
	fsti	＄f1, ＄r0, 445
	fldi	＄f2, ＄r0, 446
	fldi	＄f1, ＄r0, 449
	fmul	＄f1, ＄f0, ＄f1
	fadd	＄f1, ＄f2, ＄f1
	fsti	＄f1, ＄r0, 446
	fldi	＄f2, ＄r0, 447
	fldi	＄f1, ＄r0, 450
	fmul	＄f0, ＄f0, ＄f1
	fadd	＄f0, ＄f2, ＄f0
	fsti	＄f0, ＄r0, 447
	return
bne_else.45096:
	return

#---------------------------------------------------------------------
# args = [＄r18, ＄r17, ＄r19, ＄r20]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
iter_trace_diffuse_rays.2963:
	blt	＄r20, ＄r0, bge_else.45249
	slli	＄r3, ＄r20, 0
	add	＄r28, ＄r18, ＄r3
	ldi	＄r3, ＄r28, 0
	ldi	＄r3, ＄r3, 0
	fldi	＄f1, ＄r3, 0
	fldi	＄f0, ＄r17, 0
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r17, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r17, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f0, ＄f16, fbge_else.45250
	slli	＄r3, ＄r20, 0
	add	＄r28, ＄r18, ＄r3
	ldi	＄r10, ＄r28, 0
	fdiv	＄f10, ＄f0, ＄f19
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	j	fbge_cont.45251
fbge_else.45250:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r3, ＄r20, ＄r28
	slli	＄r3, ＄r3, 0
	add	＄r28, ＄r18, ＄r3
	ldi	＄r10, ＄r28, 0
	fdiv	＄f10, ＄f0, ＄f18
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.45251:
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r20, ＄r20, ＄r28
	blt	＄r20, ＄r0, bge_else.45252
	slli	＄r3, ＄r20, 0
	add	＄r28, ＄r18, ＄r3
	ldi	＄r3, ＄r28, 0
	ldi	＄r3, ＄r3, 0
	fldi	＄f1, ＄r3, 0
	fldi	＄f0, ＄r17, 0
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r17, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r17, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f0, ＄f16, fbge_else.45253
	slli	＄r3, ＄r20, 0
	add	＄r28, ＄r18, ＄r3
	ldi	＄r10, ＄r28, 0
	fdiv	＄f10, ＄f0, ＄f19
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	j	fbge_cont.45254
fbge_else.45253:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r3, ＄r20, ＄r28
	slli	＄r3, ＄r3, 0
	add	＄r28, ＄r18, ＄r3
	ldi	＄r10, ＄r28, 0
	fdiv	＄f10, ＄f0, ＄f18
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.45254:
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r20, ＄r20, ＄r28
	blt	＄r20, ＄r0, bge_else.45255
	slli	＄r3, ＄r20, 0
	add	＄r28, ＄r18, ＄r3
	ldi	＄r3, ＄r28, 0
	ldi	＄r3, ＄r3, 0
	fldi	＄f1, ＄r3, 0
	fldi	＄f0, ＄r17, 0
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r17, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r17, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f0, ＄f16, fbge_else.45256
	slli	＄r3, ＄r20, 0
	add	＄r28, ＄r18, ＄r3
	ldi	＄r10, ＄r28, 0
	fdiv	＄f10, ＄f0, ＄f19
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	j	fbge_cont.45257
fbge_else.45256:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r3, ＄r20, ＄r28
	slli	＄r3, ＄r3, 0
	add	＄r28, ＄r18, ＄r3
	ldi	＄r10, ＄r28, 0
	fdiv	＄f10, ＄f0, ＄f18
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.45257:
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r20, ＄r20, ＄r28
	blt	＄r20, ＄r0, bge_else.45258
	slli	＄r3, ＄r20, 0
	add	＄r28, ＄r18, ＄r3
	ldi	＄r3, ＄r28, 0
	ldi	＄r3, ＄r3, 0
	fldi	＄f1, ＄r3, 0
	fldi	＄f0, ＄r17, 0
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r17, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r17, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f0, ＄f16, fbge_else.45259
	slli	＄r3, ＄r20, 0
	add	＄r28, ＄r18, ＄r3
	ldi	＄r10, ＄r28, 0
	fdiv	＄f10, ＄f0, ＄f19
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	j	fbge_cont.45260
fbge_else.45259:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r3, ＄r20, ＄r28
	slli	＄r3, ＄r3, 0
	add	＄r28, ＄r18, ＄r3
	ldi	＄r10, ＄r28, 0
	fdiv	＄f10, ＄f0, ＄f18
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.45260:
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r20, ＄r20, ＄r28
	j	iter_trace_diffuse_rays.2963
bge_else.45258:
	return
bge_else.45255:
	return
bge_else.45252:
	return
bge_else.45249:
	return

#---------------------------------------------------------------------
# args = [＄r23, ＄r21]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
do_without_neighbors.2985:
	mvhi	＄r3, 0
	mvlo	＄r3, 4
	blt	＄r3, ＄r21, ble_else.45265
	ldi	＄r4, ＄r23, 2
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r4, ＄r3
	ldi	＄r3, ＄r28, 0
	blt	＄r3, ＄r0, bge_else.45266
	ldi	＄r4, ＄r23, 3
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r4, ＄r3
	ldi	＄r3, ＄r28, 0
	beq	＄r3, ＄r0, bne_else.45267
	ldi	＄r4, ＄r23, 5
	ldi	＄r5, ＄r23, 7
	ldi	＄r6, ＄r23, 1
	ldi	＄r24, ＄r23, 4
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r4, ＄r3
	ldi	＄r3, ＄r28, 0
	fldi	＄f0, ＄r3, 0
	fsti	＄f0, ＄r0, 445
	fldi	＄f0, ＄r3, 1
	fsti	＄f0, ＄r0, 446
	fldi	＄f0, ＄r3, 2
	fsti	＄f0, ＄r0, 447
	ldi	＄r3, ＄r23, 6
	ldi	＄r22, ＄r3, 0
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r5, ＄r3
	ldi	＄r17, ＄r28, 0
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r6, ＄r3
	ldi	＄r19, ＄r28, 0
	sti	＄r17, ＄r1, 0
	sti	＄r19, ＄r1, -1
	beq	＄r22, ＄r0, bne_else.45269
	ldi	＄r18, ＄r0, 411
	fldi	＄f0, ＄r19, 0
	fsti	＄f0, ＄r0, 431
	fldi	＄f0, ＄r19, 1
	fsti	＄f0, ＄r0, 432
	fldi	＄f0, ＄r19, 2
	fsti	＄f0, ＄r0, 433
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r7, ＄r3, ＄r28
	blt	＄r7, ＄r0, bge_else.45271
	slli	＄r3, ＄r7, 0
	ldi	＄r3, ＄r3, 522
	ldi	＄r6, ＄r3, 10
	ldi	＄r5, ＄r3, 1
	fldi	＄f1, ＄r19, 0
	ldi	＄r4, ＄r3, 5
	fldi	＄f0, ＄r4, 0
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 0
	fldi	＄f1, ＄r19, 1
	fldi	＄f0, ＄r4, 1
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 1
	fldi	＄f1, ＄r19, 2
	fldi	＄f0, ＄r4, 2
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 2
	mvhi	＄r4, 0
	mvlo	＄r4, 2
	beq	＄r5, ＄r4, bne_else.45273
	mvhi	＄r4, 0
	mvlo	＄r4, 2
	blt	＄r4, ＄r5, ble_else.45275
	j	ble_cont.45276
ble_else.45275:
	fldi	＄f2, ＄r6, 0
	fldi	＄f1, ＄r6, 1
	fldi	＄f0, ＄r6, 2
	fmul	＄f4, ＄f2, ＄f2
	ldi	＄r4, ＄r3, 4
	fldi	＄f3, ＄r4, 0
	fmul	＄f5, ＄f4, ＄f3
	fmul	＄f4, ＄f1, ＄f1
	fldi	＄f3, ＄r4, 1
	fmul	＄f3, ＄f4, ＄f3
	fadd	＄f5, ＄f5, ＄f3
	fmul	＄f4, ＄f0, ＄f0
	fldi	＄f3, ＄r4, 2
	fmul	＄f3, ＄f4, ＄f3
	fadd	＄f4, ＄f5, ＄f3
	ldi	＄r4, ＄r3, 3
	beq	＄r4, ＄r0, bne_else.45277
	fmul	＄f5, ＄f1, ＄f0
	ldi	＄r3, ＄r3, 9
	fldi	＄f3, ＄r3, 0
	fmul	＄f3, ＄f5, ＄f3
	fadd	＄f4, ＄f4, ＄f3
	fmul	＄f3, ＄f0, ＄f2
	fldi	＄f0, ＄r3, 1
	fmul	＄f0, ＄f3, ＄f0
	fadd	＄f4, ＄f4, ＄f0
	fmul	＄f1, ＄f2, ＄f1
	fldi	＄f0, ＄r3, 2
	fmul	＄f3, ＄f1, ＄f0
	fadd	＄f3, ＄f4, ＄f3
	j	bne_cont.45278
bne_else.45277:
	fmov	＄f3, ＄f4
bne_cont.45278:
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	beq	＄r5, ＄r3, bne_else.45279
	fmov	＄f0, ＄f3
	j	bne_cont.45280
bne_else.45279:
	fsub	＄f0, ＄f3, ＄f17
bne_cont.45280:
	fsti	＄f0, ＄r6, 3
ble_cont.45276:
	j	bne_cont.45274
bne_else.45273:
	ldi	＄r3, ＄r3, 4
	fldi	＄f1, ＄r6, 0
	fldi	＄f3, ＄r6, 1
	fldi	＄f2, ＄r6, 2
	fldi	＄f0, ＄r3, 0
	fmul	＄f1, ＄f0, ＄f1
	fldi	＄f0, ＄r3, 1
	fmul	＄f0, ＄f0, ＄f3
	fadd	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r3, 2
	fmul	＄f0, ＄f0, ＄f2
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 3
bne_cont.45274:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r4, ＄r7, ＄r28
	mov	＄r3, ＄r19
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	setup_startp_constants.2865
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	bge_cont.45272
bge_else.45271:
bge_cont.45272:
	ldi	＄r3, ＄r18, 118
	ldi	＄r3, ＄r3, 0
	fldi	＄f1, ＄r3, 0
	fldi	＄f0, ＄r17, 0
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r17, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r17, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f0, ＄f16, fbge_else.45281
	ldi	＄r10, ＄r18, 118
	fdiv	＄f10, ＄f0, ＄f19
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	fbge_cont.45282
fbge_else.45281:
	ldi	＄r10, ＄r18, 119
	fdiv	＄f10, ＄f0, ＄f18
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45282:
	ldi	＄r3, ＄r18, 116
	ldi	＄r3, ＄r3, 0
	fldi	＄f1, ＄r3, 0
	fldi	＄f0, ＄r17, 0
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r17, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r17, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f0, ＄f16, fbge_else.45283
	ldi	＄r10, ＄r18, 116
	fdiv	＄f10, ＄f0, ＄f19
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	fbge_cont.45284
fbge_else.45283:
	ldi	＄r10, ＄r18, 117
	fdiv	＄f10, ＄f0, ＄f18
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45284:
	ldi	＄r3, ＄r18, 114
	ldi	＄r3, ＄r3, 0
	fldi	＄f1, ＄r3, 0
	fldi	＄f0, ＄r17, 0
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r17, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r17, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f0, ＄f16, fbge_else.45285
	ldi	＄r10, ＄r18, 114
	fdiv	＄f10, ＄f0, ＄f19
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	fbge_cont.45286
fbge_else.45285:
	ldi	＄r10, ＄r18, 115
	fdiv	＄f10, ＄f0, ＄f18
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45286:
	mvhi	＄r20, 0
	mvlo	＄r20, 112
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	iter_trace_diffuse_rays.2963
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	bne_cont.45270
bne_else.45269:
bne_cont.45270:
	beq	＄r22, ＄r29, bne_else.45287
	ldi	＄r18, ＄r0, 412
	ldi	＄r19, ＄r1, -1
	fldi	＄f0, ＄r19, 0
	fsti	＄f0, ＄r0, 431
	fldi	＄f0, ＄r19, 1
	fsti	＄f0, ＄r0, 432
	fldi	＄f0, ＄r19, 2
	fsti	＄f0, ＄r0, 433
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r7, ＄r3, ＄r28
	blt	＄r7, ＄r0, bge_else.45289
	slli	＄r3, ＄r7, 0
	ldi	＄r3, ＄r3, 522
	ldi	＄r6, ＄r3, 10
	ldi	＄r5, ＄r3, 1
	fldi	＄f1, ＄r19, 0
	ldi	＄r4, ＄r3, 5
	fldi	＄f0, ＄r4, 0
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 0
	fldi	＄f1, ＄r19, 1
	fldi	＄f0, ＄r4, 1
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 1
	fldi	＄f1, ＄r19, 2
	fldi	＄f0, ＄r4, 2
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 2
	mvhi	＄r4, 0
	mvlo	＄r4, 2
	beq	＄r5, ＄r4, bne_else.45291
	mvhi	＄r4, 0
	mvlo	＄r4, 2
	blt	＄r4, ＄r5, ble_else.45293
	j	ble_cont.45294
ble_else.45293:
	fldi	＄f2, ＄r6, 0
	fldi	＄f1, ＄r6, 1
	fldi	＄f0, ＄r6, 2
	fmul	＄f4, ＄f2, ＄f2
	ldi	＄r4, ＄r3, 4
	fldi	＄f3, ＄r4, 0
	fmul	＄f5, ＄f4, ＄f3
	fmul	＄f4, ＄f1, ＄f1
	fldi	＄f3, ＄r4, 1
	fmul	＄f3, ＄f4, ＄f3
	fadd	＄f5, ＄f5, ＄f3
	fmul	＄f4, ＄f0, ＄f0
	fldi	＄f3, ＄r4, 2
	fmul	＄f3, ＄f4, ＄f3
	fadd	＄f4, ＄f5, ＄f3
	ldi	＄r4, ＄r3, 3
	beq	＄r4, ＄r0, bne_else.45295
	fmul	＄f5, ＄f1, ＄f0
	ldi	＄r3, ＄r3, 9
	fldi	＄f3, ＄r3, 0
	fmul	＄f3, ＄f5, ＄f3
	fadd	＄f4, ＄f4, ＄f3
	fmul	＄f3, ＄f0, ＄f2
	fldi	＄f0, ＄r3, 1
	fmul	＄f0, ＄f3, ＄f0
	fadd	＄f4, ＄f4, ＄f0
	fmul	＄f1, ＄f2, ＄f1
	fldi	＄f0, ＄r3, 2
	fmul	＄f3, ＄f1, ＄f0
	fadd	＄f3, ＄f4, ＄f3
	j	bne_cont.45296
bne_else.45295:
	fmov	＄f3, ＄f4
bne_cont.45296:
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	beq	＄r5, ＄r3, bne_else.45297
	fmov	＄f0, ＄f3
	j	bne_cont.45298
bne_else.45297:
	fsub	＄f0, ＄f3, ＄f17
bne_cont.45298:
	fsti	＄f0, ＄r6, 3
ble_cont.45294:
	j	bne_cont.45292
bne_else.45291:
	ldi	＄r3, ＄r3, 4
	fldi	＄f1, ＄r6, 0
	fldi	＄f3, ＄r6, 1
	fldi	＄f2, ＄r6, 2
	fldi	＄f0, ＄r3, 0
	fmul	＄f1, ＄f0, ＄f1
	fldi	＄f0, ＄r3, 1
	fmul	＄f0, ＄f0, ＄f3
	fadd	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r3, 2
	fmul	＄f0, ＄f0, ＄f2
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 3
bne_cont.45292:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r4, ＄r7, ＄r28
	mov	＄r3, ＄r19
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	setup_startp_constants.2865
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	bge_cont.45290
bge_else.45289:
bge_cont.45290:
	ldi	＄r3, ＄r18, 118
	ldi	＄r3, ＄r3, 0
	fldi	＄f1, ＄r3, 0
	ldi	＄r17, ＄r1, 0
	fldi	＄f0, ＄r17, 0
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r17, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r17, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f0, ＄f16, fbge_else.45299
	ldi	＄r10, ＄r18, 118
	fdiv	＄f10, ＄f0, ＄f19
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	fbge_cont.45300
fbge_else.45299:
	ldi	＄r10, ＄r18, 119
	fdiv	＄f10, ＄f0, ＄f18
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45300:
	ldi	＄r3, ＄r18, 116
	ldi	＄r3, ＄r3, 0
	fldi	＄f1, ＄r3, 0
	fldi	＄f0, ＄r17, 0
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r17, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r17, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f0, ＄f16, fbge_else.45301
	ldi	＄r10, ＄r18, 116
	fdiv	＄f10, ＄f0, ＄f19
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	fbge_cont.45302
fbge_else.45301:
	ldi	＄r10, ＄r18, 117
	fdiv	＄f10, ＄f0, ＄f18
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45302:
	ldi	＄r3, ＄r18, 114
	ldi	＄r3, ＄r3, 0
	fldi	＄f1, ＄r3, 0
	fldi	＄f0, ＄r17, 0
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r17, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r17, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f0, ＄f16, fbge_else.45303
	ldi	＄r10, ＄r18, 114
	fdiv	＄f10, ＄f0, ＄f19
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	fbge_cont.45304
fbge_else.45303:
	ldi	＄r10, ＄r18, 115
	fdiv	＄f10, ＄f0, ＄f18
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45304:
	mvhi	＄r20, 0
	mvlo	＄r20, 112
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	iter_trace_diffuse_rays.2963
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	bne_cont.45288
bne_else.45287:
bne_cont.45288:
	mvhi	＄r3, 0
	mvlo	＄r3, 2
	beq	＄r22, ＄r3, bne_else.45305
	ldi	＄r18, ＄r0, 413
	ldi	＄r19, ＄r1, -1
	fldi	＄f0, ＄r19, 0
	fsti	＄f0, ＄r0, 431
	fldi	＄f0, ＄r19, 1
	fsti	＄f0, ＄r0, 432
	fldi	＄f0, ＄r19, 2
	fsti	＄f0, ＄r0, 433
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r7, ＄r3, ＄r28
	blt	＄r7, ＄r0, bge_else.45307
	slli	＄r3, ＄r7, 0
	ldi	＄r3, ＄r3, 522
	ldi	＄r6, ＄r3, 10
	ldi	＄r5, ＄r3, 1
	fldi	＄f1, ＄r19, 0
	ldi	＄r4, ＄r3, 5
	fldi	＄f0, ＄r4, 0
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 0
	fldi	＄f1, ＄r19, 1
	fldi	＄f0, ＄r4, 1
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 1
	fldi	＄f1, ＄r19, 2
	fldi	＄f0, ＄r4, 2
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 2
	mvhi	＄r4, 0
	mvlo	＄r4, 2
	beq	＄r5, ＄r4, bne_else.45309
	mvhi	＄r4, 0
	mvlo	＄r4, 2
	blt	＄r4, ＄r5, ble_else.45311
	j	ble_cont.45312
ble_else.45311:
	fldi	＄f2, ＄r6, 0
	fldi	＄f1, ＄r6, 1
	fldi	＄f0, ＄r6, 2
	fmul	＄f4, ＄f2, ＄f2
	ldi	＄r4, ＄r3, 4
	fldi	＄f3, ＄r4, 0
	fmul	＄f5, ＄f4, ＄f3
	fmul	＄f4, ＄f1, ＄f1
	fldi	＄f3, ＄r4, 1
	fmul	＄f3, ＄f4, ＄f3
	fadd	＄f5, ＄f5, ＄f3
	fmul	＄f4, ＄f0, ＄f0
	fldi	＄f3, ＄r4, 2
	fmul	＄f3, ＄f4, ＄f3
	fadd	＄f4, ＄f5, ＄f3
	ldi	＄r4, ＄r3, 3
	beq	＄r4, ＄r0, bne_else.45313
	fmul	＄f5, ＄f1, ＄f0
	ldi	＄r3, ＄r3, 9
	fldi	＄f3, ＄r3, 0
	fmul	＄f3, ＄f5, ＄f3
	fadd	＄f4, ＄f4, ＄f3
	fmul	＄f3, ＄f0, ＄f2
	fldi	＄f0, ＄r3, 1
	fmul	＄f0, ＄f3, ＄f0
	fadd	＄f4, ＄f4, ＄f0
	fmul	＄f1, ＄f2, ＄f1
	fldi	＄f0, ＄r3, 2
	fmul	＄f3, ＄f1, ＄f0
	fadd	＄f3, ＄f4, ＄f3
	j	bne_cont.45314
bne_else.45313:
	fmov	＄f3, ＄f4
bne_cont.45314:
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	beq	＄r5, ＄r3, bne_else.45315
	fmov	＄f0, ＄f3
	j	bne_cont.45316
bne_else.45315:
	fsub	＄f0, ＄f3, ＄f17
bne_cont.45316:
	fsti	＄f0, ＄r6, 3
ble_cont.45312:
	j	bne_cont.45310
bne_else.45309:
	ldi	＄r3, ＄r3, 4
	fldi	＄f1, ＄r6, 0
	fldi	＄f3, ＄r6, 1
	fldi	＄f2, ＄r6, 2
	fldi	＄f0, ＄r3, 0
	fmul	＄f1, ＄f0, ＄f1
	fldi	＄f0, ＄r3, 1
	fmul	＄f0, ＄f0, ＄f3
	fadd	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r3, 2
	fmul	＄f0, ＄f0, ＄f2
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 3
bne_cont.45310:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r4, ＄r7, ＄r28
	mov	＄r3, ＄r19
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	setup_startp_constants.2865
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	bge_cont.45308
bge_else.45307:
bge_cont.45308:
	ldi	＄r3, ＄r18, 118
	ldi	＄r3, ＄r3, 0
	fldi	＄f1, ＄r3, 0
	ldi	＄r17, ＄r1, 0
	fldi	＄f0, ＄r17, 0
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r17, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r17, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f0, ＄f16, fbge_else.45317
	ldi	＄r10, ＄r18, 118
	fdiv	＄f10, ＄f0, ＄f19
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	fbge_cont.45318
fbge_else.45317:
	ldi	＄r10, ＄r18, 119
	fdiv	＄f10, ＄f0, ＄f18
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45318:
	ldi	＄r3, ＄r18, 116
	ldi	＄r3, ＄r3, 0
	fldi	＄f1, ＄r3, 0
	fldi	＄f0, ＄r17, 0
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r17, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r17, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f0, ＄f16, fbge_else.45319
	ldi	＄r10, ＄r18, 116
	fdiv	＄f10, ＄f0, ＄f19
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	fbge_cont.45320
fbge_else.45319:
	ldi	＄r10, ＄r18, 117
	fdiv	＄f10, ＄f0, ＄f18
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45320:
	ldi	＄r3, ＄r18, 114
	ldi	＄r3, ＄r3, 0
	fldi	＄f1, ＄r3, 0
	fldi	＄f0, ＄r17, 0
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r17, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r17, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f0, ＄f16, fbge_else.45321
	ldi	＄r10, ＄r18, 114
	fdiv	＄f10, ＄f0, ＄f19
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	fbge_cont.45322
fbge_else.45321:
	ldi	＄r10, ＄r18, 115
	fdiv	＄f10, ＄f0, ＄f18
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45322:
	mvhi	＄r20, 0
	mvlo	＄r20, 112
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	iter_trace_diffuse_rays.2963
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	bne_cont.45306
bne_else.45305:
bne_cont.45306:
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	beq	＄r22, ＄r3, bne_else.45323
	ldi	＄r18, ＄r0, 414
	ldi	＄r19, ＄r1, -1
	fldi	＄f0, ＄r19, 0
	fsti	＄f0, ＄r0, 431
	fldi	＄f0, ＄r19, 1
	fsti	＄f0, ＄r0, 432
	fldi	＄f0, ＄r19, 2
	fsti	＄f0, ＄r0, 433
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r7, ＄r3, ＄r28
	blt	＄r7, ＄r0, bge_else.45325
	slli	＄r3, ＄r7, 0
	ldi	＄r3, ＄r3, 522
	ldi	＄r6, ＄r3, 10
	ldi	＄r5, ＄r3, 1
	fldi	＄f1, ＄r19, 0
	ldi	＄r4, ＄r3, 5
	fldi	＄f0, ＄r4, 0
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 0
	fldi	＄f1, ＄r19, 1
	fldi	＄f0, ＄r4, 1
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 1
	fldi	＄f1, ＄r19, 2
	fldi	＄f0, ＄r4, 2
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 2
	mvhi	＄r4, 0
	mvlo	＄r4, 2
	beq	＄r5, ＄r4, bne_else.45327
	mvhi	＄r4, 0
	mvlo	＄r4, 2
	blt	＄r4, ＄r5, ble_else.45329
	j	ble_cont.45330
ble_else.45329:
	fldi	＄f2, ＄r6, 0
	fldi	＄f1, ＄r6, 1
	fldi	＄f0, ＄r6, 2
	fmul	＄f4, ＄f2, ＄f2
	ldi	＄r4, ＄r3, 4
	fldi	＄f3, ＄r4, 0
	fmul	＄f5, ＄f4, ＄f3
	fmul	＄f4, ＄f1, ＄f1
	fldi	＄f3, ＄r4, 1
	fmul	＄f3, ＄f4, ＄f3
	fadd	＄f5, ＄f5, ＄f3
	fmul	＄f4, ＄f0, ＄f0
	fldi	＄f3, ＄r4, 2
	fmul	＄f3, ＄f4, ＄f3
	fadd	＄f4, ＄f5, ＄f3
	ldi	＄r4, ＄r3, 3
	beq	＄r4, ＄r0, bne_else.45331
	fmul	＄f5, ＄f1, ＄f0
	ldi	＄r3, ＄r3, 9
	fldi	＄f3, ＄r3, 0
	fmul	＄f3, ＄f5, ＄f3
	fadd	＄f4, ＄f4, ＄f3
	fmul	＄f3, ＄f0, ＄f2
	fldi	＄f0, ＄r3, 1
	fmul	＄f0, ＄f3, ＄f0
	fadd	＄f4, ＄f4, ＄f0
	fmul	＄f1, ＄f2, ＄f1
	fldi	＄f0, ＄r3, 2
	fmul	＄f3, ＄f1, ＄f0
	fadd	＄f3, ＄f4, ＄f3
	j	bne_cont.45332
bne_else.45331:
	fmov	＄f3, ＄f4
bne_cont.45332:
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	beq	＄r5, ＄r3, bne_else.45333
	fmov	＄f0, ＄f3
	j	bne_cont.45334
bne_else.45333:
	fsub	＄f0, ＄f3, ＄f17
bne_cont.45334:
	fsti	＄f0, ＄r6, 3
ble_cont.45330:
	j	bne_cont.45328
bne_else.45327:
	ldi	＄r3, ＄r3, 4
	fldi	＄f1, ＄r6, 0
	fldi	＄f3, ＄r6, 1
	fldi	＄f2, ＄r6, 2
	fldi	＄f0, ＄r3, 0
	fmul	＄f1, ＄f0, ＄f1
	fldi	＄f0, ＄r3, 1
	fmul	＄f0, ＄f0, ＄f3
	fadd	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r3, 2
	fmul	＄f0, ＄f0, ＄f2
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 3
bne_cont.45328:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r4, ＄r7, ＄r28
	mov	＄r3, ＄r19
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	setup_startp_constants.2865
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	bge_cont.45326
bge_else.45325:
bge_cont.45326:
	ldi	＄r3, ＄r18, 118
	ldi	＄r3, ＄r3, 0
	fldi	＄f1, ＄r3, 0
	ldi	＄r17, ＄r1, 0
	fldi	＄f0, ＄r17, 0
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r17, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r17, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f0, ＄f16, fbge_else.45335
	ldi	＄r10, ＄r18, 118
	fdiv	＄f10, ＄f0, ＄f19
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	fbge_cont.45336
fbge_else.45335:
	ldi	＄r10, ＄r18, 119
	fdiv	＄f10, ＄f0, ＄f18
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45336:
	ldi	＄r3, ＄r18, 116
	ldi	＄r3, ＄r3, 0
	fldi	＄f1, ＄r3, 0
	fldi	＄f0, ＄r17, 0
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r17, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r17, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f0, ＄f16, fbge_else.45337
	ldi	＄r10, ＄r18, 116
	fdiv	＄f10, ＄f0, ＄f19
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	fbge_cont.45338
fbge_else.45337:
	ldi	＄r10, ＄r18, 117
	fdiv	＄f10, ＄f0, ＄f18
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45338:
	ldi	＄r3, ＄r18, 114
	ldi	＄r3, ＄r3, 0
	fldi	＄f1, ＄r3, 0
	fldi	＄f0, ＄r17, 0
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r17, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r17, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f0, ＄f16, fbge_else.45339
	ldi	＄r10, ＄r18, 114
	fdiv	＄f10, ＄f0, ＄f19
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	fbge_cont.45340
fbge_else.45339:
	ldi	＄r10, ＄r18, 115
	fdiv	＄f10, ＄f0, ＄f18
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45340:
	mvhi	＄r20, 0
	mvlo	＄r20, 112
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	iter_trace_diffuse_rays.2963
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	bne_cont.45324
bne_else.45323:
bne_cont.45324:
	mvhi	＄r3, 0
	mvlo	＄r3, 4
	beq	＄r22, ＄r3, bne_else.45341
	ldi	＄r18, ＄r0, 415
	ldi	＄r19, ＄r1, -1
	fldi	＄f0, ＄r19, 0
	fsti	＄f0, ＄r0, 431
	fldi	＄f0, ＄r19, 1
	fsti	＄f0, ＄r0, 432
	fldi	＄f0, ＄r19, 2
	fsti	＄f0, ＄r0, 433
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r7, ＄r3, ＄r28
	blt	＄r7, ＄r0, bge_else.45343
	slli	＄r3, ＄r7, 0
	ldi	＄r3, ＄r3, 522
	ldi	＄r6, ＄r3, 10
	ldi	＄r5, ＄r3, 1
	fldi	＄f1, ＄r19, 0
	ldi	＄r4, ＄r3, 5
	fldi	＄f0, ＄r4, 0
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 0
	fldi	＄f1, ＄r19, 1
	fldi	＄f0, ＄r4, 1
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 1
	fldi	＄f1, ＄r19, 2
	fldi	＄f0, ＄r4, 2
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 2
	mvhi	＄r4, 0
	mvlo	＄r4, 2
	beq	＄r5, ＄r4, bne_else.45345
	mvhi	＄r4, 0
	mvlo	＄r4, 2
	blt	＄r4, ＄r5, ble_else.45347
	j	ble_cont.45348
ble_else.45347:
	fldi	＄f2, ＄r6, 0
	fldi	＄f1, ＄r6, 1
	fldi	＄f0, ＄r6, 2
	fmul	＄f4, ＄f2, ＄f2
	ldi	＄r4, ＄r3, 4
	fldi	＄f3, ＄r4, 0
	fmul	＄f5, ＄f4, ＄f3
	fmul	＄f4, ＄f1, ＄f1
	fldi	＄f3, ＄r4, 1
	fmul	＄f3, ＄f4, ＄f3
	fadd	＄f5, ＄f5, ＄f3
	fmul	＄f4, ＄f0, ＄f0
	fldi	＄f3, ＄r4, 2
	fmul	＄f3, ＄f4, ＄f3
	fadd	＄f4, ＄f5, ＄f3
	ldi	＄r4, ＄r3, 3
	beq	＄r4, ＄r0, bne_else.45349
	fmul	＄f5, ＄f1, ＄f0
	ldi	＄r3, ＄r3, 9
	fldi	＄f3, ＄r3, 0
	fmul	＄f3, ＄f5, ＄f3
	fadd	＄f4, ＄f4, ＄f3
	fmul	＄f3, ＄f0, ＄f2
	fldi	＄f0, ＄r3, 1
	fmul	＄f0, ＄f3, ＄f0
	fadd	＄f4, ＄f4, ＄f0
	fmul	＄f1, ＄f2, ＄f1
	fldi	＄f0, ＄r3, 2
	fmul	＄f3, ＄f1, ＄f0
	fadd	＄f3, ＄f4, ＄f3
	j	bne_cont.45350
bne_else.45349:
	fmov	＄f3, ＄f4
bne_cont.45350:
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	beq	＄r5, ＄r3, bne_else.45351
	fmov	＄f0, ＄f3
	j	bne_cont.45352
bne_else.45351:
	fsub	＄f0, ＄f3, ＄f17
bne_cont.45352:
	fsti	＄f0, ＄r6, 3
ble_cont.45348:
	j	bne_cont.45346
bne_else.45345:
	ldi	＄r3, ＄r3, 4
	fldi	＄f1, ＄r6, 0
	fldi	＄f3, ＄r6, 1
	fldi	＄f2, ＄r6, 2
	fldi	＄f0, ＄r3, 0
	fmul	＄f1, ＄f0, ＄f1
	fldi	＄f0, ＄r3, 1
	fmul	＄f0, ＄f0, ＄f3
	fadd	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r3, 2
	fmul	＄f0, ＄f0, ＄f2
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 3
bne_cont.45346:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r4, ＄r7, ＄r28
	mov	＄r3, ＄r19
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	setup_startp_constants.2865
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	bge_cont.45344
bge_else.45343:
bge_cont.45344:
	ldi	＄r3, ＄r18, 118
	ldi	＄r3, ＄r3, 0
	fldi	＄f1, ＄r3, 0
	ldi	＄r17, ＄r1, 0
	fldi	＄f0, ＄r17, 0
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r17, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r17, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f0, ＄f16, fbge_else.45353
	ldi	＄r10, ＄r18, 118
	fdiv	＄f10, ＄f0, ＄f19
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	fbge_cont.45354
fbge_else.45353:
	ldi	＄r10, ＄r18, 119
	fdiv	＄f10, ＄f0, ＄f18
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45354:
	ldi	＄r3, ＄r18, 116
	ldi	＄r3, ＄r3, 0
	fldi	＄f1, ＄r3, 0
	fldi	＄f0, ＄r17, 0
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r17, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r17, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f0, ＄f16, fbge_else.45355
	ldi	＄r10, ＄r18, 116
	fdiv	＄f10, ＄f0, ＄f19
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	fbge_cont.45356
fbge_else.45355:
	ldi	＄r10, ＄r18, 117
	fdiv	＄f10, ＄f0, ＄f18
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45356:
	ldi	＄r3, ＄r18, 114
	ldi	＄r3, ＄r3, 0
	fldi	＄f1, ＄r3, 0
	fldi	＄f0, ＄r17, 0
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r17, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r17, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f0, ＄f16, fbge_else.45357
	ldi	＄r10, ＄r18, 114
	fdiv	＄f10, ＄f0, ＄f19
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	fbge_cont.45358
fbge_else.45357:
	ldi	＄r10, ＄r18, 115
	fdiv	＄f10, ＄f0, ＄f18
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
fbge_cont.45358:
	mvhi	＄r20, 0
	mvlo	＄r20, 112
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	iter_trace_diffuse_rays.2963
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	j	bne_cont.45342
bne_else.45341:
bne_cont.45342:
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r24, ＄r3
	ldi	＄r3, ＄r28, 0
	fldi	＄f2, ＄r0, 442
	fldi	＄f1, ＄r3, 0
	fldi	＄f0, ＄r0, 445
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fsti	＄f0, ＄r0, 442
	fldi	＄f2, ＄r0, 443
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r0, 446
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fsti	＄f0, ＄r0, 443
	fldi	＄f2, ＄r0, 444
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r0, 447
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fsti	＄f0, ＄r0, 444
	j	bne_cont.45268
bne_else.45267:
bne_cont.45268:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r21, ＄r21, ＄r28
	j	do_without_neighbors.2985
bge_else.45266:
	return
ble_else.45265:
	return

#---------------------------------------------------------------------
# args = [＄r4, ＄r10, ＄r9, ＄r5, ＄r8, ＄r21]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
try_exploit_neighbors.3001:
	slli	＄r3, ＄r4, 0
	add	＄r28, ＄r5, ＄r3
	ldi	＄r6, ＄r28, 0
	mvhi	＄r3, 0
	mvlo	＄r3, 4
	blt	＄r3, ＄r21, ble_else.45361
	ldi	＄r7, ＄r6, 2
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r7, ＄r3
	ldi	＄r3, ＄r28, 0
	blt	＄r3, ＄r0, bge_else.45362
	slli	＄r7, ＄r4, 0
	add	＄r28, ＄r9, ＄r7
	ldi	＄r7, ＄r28, 0
	ldi	＄r12, ＄r7, 2
	slli	＄r11, ＄r21, 0
	add	＄r28, ＄r12, ＄r11
	ldi	＄r11, ＄r28, 0
	beq	＄r11, ＄r3, bne_else.45363
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	j	bne_cont.45364
bne_else.45363:
	slli	＄r11, ＄r4, 0
	add	＄r28, ＄r8, ＄r11
	ldi	＄r11, ＄r28, 0
	ldi	＄r12, ＄r11, 2
	slli	＄r11, ＄r21, 0
	add	＄r28, ＄r12, ＄r11
	ldi	＄r11, ＄r28, 0
	beq	＄r11, ＄r3, bne_else.45365
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	j	bne_cont.45366
bne_else.45365:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r11, ＄r4, ＄r28
	slli	＄r11, ＄r11, 0
	add	＄r28, ＄r5, ＄r11
	ldi	＄r11, ＄r28, 0
	ldi	＄r12, ＄r11, 2
	slli	＄r11, ＄r21, 0
	add	＄r28, ＄r12, ＄r11
	ldi	＄r11, ＄r28, 0
	beq	＄r11, ＄r3, bne_else.45367
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	j	bne_cont.45368
bne_else.45367:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r11, ＄r4, ＄r28
	slli	＄r11, ＄r11, 0
	add	＄r28, ＄r5, ＄r11
	ldi	＄r11, ＄r28, 0
	ldi	＄r12, ＄r11, 2
	slli	＄r11, ＄r21, 0
	add	＄r28, ＄r12, ＄r11
	ldi	＄r11, ＄r28, 0
	beq	＄r11, ＄r3, bne_else.45369
	mvhi	＄r11, 0
	mvlo	＄r11, 0
	j	bne_cont.45370
bne_else.45369:
	mvhi	＄r11, 0
	mvlo	＄r11, 1
bne_cont.45370:
bne_cont.45368:
bne_cont.45366:
bne_cont.45364:
	beq	＄r11, ＄r0, bne_else.45371
	ldi	＄r11, ＄r6, 3
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r11, ＄r3
	ldi	＄r3, ＄r28, 0
	beq	＄r3, ＄r0, bne_else.45372
	ldi	＄r7, ＄r7, 5
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r3, ＄r4, ＄r28
	slli	＄r3, ＄r3, 0
	add	＄r28, ＄r5, ＄r3
	ldi	＄r3, ＄r28, 0
	ldi	＄r11, ＄r3, 5
	ldi	＄r6, ＄r6, 5
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r3, ＄r4, ＄r28
	slli	＄r3, ＄r3, 0
	add	＄r28, ＄r5, ＄r3
	ldi	＄r3, ＄r28, 0
	ldi	＄r12, ＄r3, 5
	slli	＄r3, ＄r4, 0
	add	＄r28, ＄r8, ＄r3
	ldi	＄r3, ＄r28, 0
	ldi	＄r13, ＄r3, 5
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r7, ＄r3
	ldi	＄r3, ＄r28, 0
	fldi	＄f0, ＄r3, 0
	fsti	＄f0, ＄r0, 445
	fldi	＄f0, ＄r3, 1
	fsti	＄f0, ＄r0, 446
	fldi	＄f0, ＄r3, 2
	fsti	＄f0, ＄r0, 447
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r11, ＄r3
	ldi	＄r3, ＄r28, 0
	fldi	＄f1, ＄r0, 445
	fldi	＄f0, ＄r3, 0
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 445
	fldi	＄f1, ＄r0, 446
	fldi	＄f0, ＄r3, 1
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 446
	fldi	＄f1, ＄r0, 447
	fldi	＄f0, ＄r3, 2
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 447
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r6, ＄r3
	ldi	＄r3, ＄r28, 0
	fldi	＄f1, ＄r0, 445
	fldi	＄f0, ＄r3, 0
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 445
	fldi	＄f1, ＄r0, 446
	fldi	＄f0, ＄r3, 1
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 446
	fldi	＄f1, ＄r0, 447
	fldi	＄f0, ＄r3, 2
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 447
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r12, ＄r3
	ldi	＄r3, ＄r28, 0
	fldi	＄f1, ＄r0, 445
	fldi	＄f0, ＄r3, 0
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 445
	fldi	＄f1, ＄r0, 446
	fldi	＄f0, ＄r3, 1
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 446
	fldi	＄f1, ＄r0, 447
	fldi	＄f0, ＄r3, 2
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 447
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r13, ＄r3
	ldi	＄r3, ＄r28, 0
	fldi	＄f1, ＄r0, 445
	fldi	＄f0, ＄r3, 0
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 445
	fldi	＄f1, ＄r0, 446
	fldi	＄f0, ＄r3, 1
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 446
	fldi	＄f1, ＄r0, 447
	fldi	＄f0, ＄r3, 2
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 447
	slli	＄r3, ＄r4, 0
	add	＄r28, ＄r5, ＄r3
	ldi	＄r3, ＄r28, 0
	ldi	＄r6, ＄r3, 4
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r6, ＄r3
	ldi	＄r3, ＄r28, 0
	fldi	＄f2, ＄r0, 442
	fldi	＄f1, ＄r3, 0
	fldi	＄f0, ＄r0, 445
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fsti	＄f0, ＄r0, 442
	fldi	＄f2, ＄r0, 443
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r0, 446
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fsti	＄f0, ＄r0, 443
	fldi	＄f2, ＄r0, 444
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r0, 447
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fsti	＄f0, ＄r0, 444
	j	bne_cont.45373
bne_else.45372:
bne_cont.45373:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r21, ＄r21, ＄r28
	j	try_exploit_neighbors.3001
bne_else.45371:
	slli	＄r3, ＄r4, 0
	add	＄r28, ＄r5, ＄r3
	ldi	＄r23, ＄r28, 0
	j	do_without_neighbors.2985
bge_else.45362:
	return
ble_else.45361:
	return

#---------------------------------------------------------------------
# args = [＄r22, ＄r21]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
pretrace_diffuse_rays.3014:
	mvhi	＄r3, 0
	mvlo	＄r3, 4
	blt	＄r3, ＄r21, ble_else.45376
	ldi	＄r4, ＄r22, 2
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r4, ＄r3
	ldi	＄r3, ＄r28, 0
	blt	＄r3, ＄r0, bge_else.45377
	ldi	＄r4, ＄r22, 3
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r4, ＄r3
	ldi	＄r3, ＄r28, 0
	beq	＄r3, ＄r0, bne_else.45378
	ldi	＄r3, ＄r22, 6
	ldi	＄r3, ＄r3, 0
	fsti	＄f16, ＄r0, 445
	fsti	＄f16, ＄r0, 446
	fsti	＄f16, ＄r0, 447
	ldi	＄r4, ＄r22, 7
	ldi	＄r5, ＄r22, 1
	slli	＄r3, ＄r3, 0
	ldi	＄r18, ＄r3, 411
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r4, ＄r3
	ldi	＄r17, ＄r28, 0
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r5, ＄r3
	ldi	＄r19, ＄r28, 0
	fldi	＄f0, ＄r19, 0
	fsti	＄f0, ＄r0, 431
	fldi	＄f0, ＄r19, 1
	fsti	＄f0, ＄r0, 432
	fldi	＄f0, ＄r19, 2
	fsti	＄f0, ＄r0, 433
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r7, ＄r3, ＄r28
	blt	＄r7, ＄r0, bge_else.45380
	slli	＄r3, ＄r7, 0
	ldi	＄r3, ＄r3, 522
	ldi	＄r6, ＄r3, 10
	ldi	＄r5, ＄r3, 1
	fldi	＄f1, ＄r19, 0
	ldi	＄r4, ＄r3, 5
	fldi	＄f0, ＄r4, 0
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 0
	fldi	＄f1, ＄r19, 1
	fldi	＄f0, ＄r4, 1
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 1
	fldi	＄f1, ＄r19, 2
	fldi	＄f0, ＄r4, 2
	fsub	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 2
	mvhi	＄r4, 0
	mvlo	＄r4, 2
	beq	＄r5, ＄r4, bne_else.45382
	mvhi	＄r4, 0
	mvlo	＄r4, 2
	blt	＄r4, ＄r5, ble_else.45384
	j	ble_cont.45385
ble_else.45384:
	fldi	＄f2, ＄r6, 0
	fldi	＄f1, ＄r6, 1
	fldi	＄f0, ＄r6, 2
	fmul	＄f4, ＄f2, ＄f2
	ldi	＄r4, ＄r3, 4
	fldi	＄f3, ＄r4, 0
	fmul	＄f5, ＄f4, ＄f3
	fmul	＄f4, ＄f1, ＄f1
	fldi	＄f3, ＄r4, 1
	fmul	＄f3, ＄f4, ＄f3
	fadd	＄f5, ＄f5, ＄f3
	fmul	＄f4, ＄f0, ＄f0
	fldi	＄f3, ＄r4, 2
	fmul	＄f3, ＄f4, ＄f3
	fadd	＄f4, ＄f5, ＄f3
	ldi	＄r4, ＄r3, 3
	beq	＄r4, ＄r0, bne_else.45386
	fmul	＄f5, ＄f1, ＄f0
	ldi	＄r3, ＄r3, 9
	fldi	＄f3, ＄r3, 0
	fmul	＄f3, ＄f5, ＄f3
	fadd	＄f4, ＄f4, ＄f3
	fmul	＄f3, ＄f0, ＄f2
	fldi	＄f0, ＄r3, 1
	fmul	＄f0, ＄f3, ＄f0
	fadd	＄f4, ＄f4, ＄f0
	fmul	＄f1, ＄f2, ＄f1
	fldi	＄f0, ＄r3, 2
	fmul	＄f3, ＄f1, ＄f0
	fadd	＄f3, ＄f4, ＄f3
	j	bne_cont.45387
bne_else.45386:
	fmov	＄f3, ＄f4
bne_cont.45387:
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	beq	＄r5, ＄r3, bne_else.45388
	fmov	＄f0, ＄f3
	j	bne_cont.45389
bne_else.45388:
	fsub	＄f0, ＄f3, ＄f17
bne_cont.45389:
	fsti	＄f0, ＄r6, 3
ble_cont.45385:
	j	bne_cont.45383
bne_else.45382:
	ldi	＄r3, ＄r3, 4
	fldi	＄f1, ＄r6, 0
	fldi	＄f3, ＄r6, 1
	fldi	＄f2, ＄r6, 2
	fldi	＄f0, ＄r3, 0
	fmul	＄f1, ＄f0, ＄f1
	fldi	＄f0, ＄r3, 1
	fmul	＄f0, ＄f0, ＄f3
	fadd	＄f1, ＄f1, ＄f0
	fldi	＄f0, ＄r3, 2
	fmul	＄f0, ＄f0, ＄f2
	fadd	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r6, 3
bne_cont.45383:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r4, ＄r7, ＄r28
	mov	＄r3, ＄r19
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	setup_startp_constants.2865
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	j	bge_cont.45381
bge_else.45380:
bge_cont.45381:
	ldi	＄r3, ＄r18, 118
	ldi	＄r3, ＄r3, 0
	fldi	＄f1, ＄r3, 0
	fldi	＄f0, ＄r17, 0
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r17, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r17, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f0, ＄f16, fbge_else.45390
	ldi	＄r10, ＄r18, 118
	fdiv	＄f10, ＄f0, ＄f19
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	j	fbge_cont.45391
fbge_else.45390:
	ldi	＄r10, ＄r18, 119
	fdiv	＄f10, ＄f0, ＄f18
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.45391:
	ldi	＄r3, ＄r18, 116
	ldi	＄r3, ＄r3, 0
	fldi	＄f1, ＄r3, 0
	fldi	＄f0, ＄r17, 0
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r17, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r17, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f0, ＄f16, fbge_else.45392
	ldi	＄r10, ＄r18, 116
	fdiv	＄f10, ＄f0, ＄f19
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	j	fbge_cont.45393
fbge_else.45392:
	ldi	＄r10, ＄r18, 117
	fdiv	＄f10, ＄f0, ＄f18
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.45393:
	ldi	＄r3, ＄r18, 114
	ldi	＄r3, ＄r3, 0
	fldi	＄f1, ＄r3, 0
	fldi	＄f0, ＄r17, 0
	fmul	＄f2, ＄f1, ＄f0
	fldi	＄f1, ＄r3, 1
	fldi	＄f0, ＄r17, 1
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f1, ＄r3, 2
	fldi	＄f0, ＄r17, 2
	fmul	＄f0, ＄f1, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fblt	＄f0, ＄f16, fbge_else.45394
	ldi	＄r10, ＄r18, 114
	fdiv	＄f10, ＄f0, ＄f19
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	j	fbge_cont.45395
fbge_else.45394:
	ldi	＄r10, ＄r18, 115
	fdiv	＄f10, ＄f0, ＄f18
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	trace_diffuse_ray.2960
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
fbge_cont.45395:
	mvhi	＄r20, 0
	mvlo	＄r20, 112
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_trace_diffuse_rays.2963
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r4, ＄r22, 5
	slli	＄r3, ＄r21, 0
	add	＄r28, ＄r4, ＄r3
	ldi	＄r3, ＄r28, 0
	fldi	＄f0, ＄r0, 445
	fsti	＄f0, ＄r3, 0
	fldi	＄f0, ＄r0, 446
	fsti	＄f0, ＄r3, 1
	fldi	＄f0, ＄r0, 447
	fsti	＄f0, ＄r3, 2
	j	bne_cont.45379
bne_else.45378:
bne_cont.45379:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r21, ＄r21, ＄r28
	j	pretrace_diffuse_rays.3014
bge_else.45377:
	return
ble_else.45376:
	return

#---------------------------------------------------------------------
# args = [＄r31, ＄r26, ＄r27]
# fargs = [＄f13, ＄f12, ＄f11]
# ret type = Unit
#---------------------------------------------------------------------
pretrace_pixels.3017:
	blt	＄r26, ＄r0, bge_else.45398
	fldi	＄f3, ＄r0, 437
	ldi	＄r3, ＄r0, 438
	sub	＄r3, ＄r26, ＄r3
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_float_of_int
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	fmul	＄f0, ＄f3, ＄f0
	fldi	＄f1, ＄r0, 428
	fmul	＄f1, ＄f0, ＄f1
	fadd	＄f1, ＄f1, ＄f13
	fsti	＄f1, ＄r0, 419
	fldi	＄f1, ＄r0, 429
	fmul	＄f1, ＄f0, ＄f1
	fadd	＄f1, ＄f1, ＄f12
	fsti	＄f1, ＄r0, 420
	fldi	＄f1, ＄r0, 430
	fmul	＄f0, ＄f0, ＄f1
	fadd	＄f0, ＄f0, ＄f11
	fsti	＄f0, ＄r0, 421
	fldi	＄f1, ＄r0, 419
	fmul	＄f2, ＄f1, ＄f1
	fldi	＄f0, ＄r0, 420
	fmul	＄f0, ＄f0, ＄f0
	fadd	＄f2, ＄f2, ＄f0
	fldi	＄f0, ＄r0, 421
	fmul	＄f0, ＄f0, ＄f0
	fadd	＄f0, ＄f2, ＄f0
	fsqrt	＄f2, ＄f0
	fbne	＄f2, ＄f16, fbeq_else.45399
	fmov	＄f0, ＄f17
	j	fbeq_cont.45400
fbeq_else.45399:
	fdiv	＄f0, ＄f17, ＄f2
fbeq_cont.45400:
	fmul	＄f1, ＄f1, ＄f0
	fsti	＄f1, ＄r0, 419
	fldi	＄f1, ＄r0, 420
	fmul	＄f1, ＄f1, ＄f0
	fsti	＄f1, ＄r0, 420
	fldi	＄f1, ＄r0, 421
	fmul	＄f0, ＄f1, ＄f0
	fsti	＄f0, ＄r0, 421
	fsti	＄f16, ＄r0, 442
	fsti	＄f16, ＄r0, 443
	fsti	＄f16, ＄r0, 444
	fldi	＄f0, ＄r0, 516
	fsti	＄f0, ＄r0, 434
	fldi	＄f0, ＄r0, 517
	fsti	＄f0, ＄r0, 435
	fldi	＄f0, ＄r0, 518
	fsti	＄f0, ＄r0, 436
	mvhi	＄r21, 0
	mvlo	＄r21, 0
	slli	＄r3, ＄r26, 0
	add	＄r28, ＄r31, ＄r3
	ldi	＄r22, ＄r28, 0
	mvhi	＄r28, 65535
	mvlo	＄r28, -419
	sub	＄r19, ＄r0, ＄r28
	fsti	＄f11, ＄r1, 0
	fsti	＄f12, ＄r1, -1
	fsti	＄f13, ＄r1, -2
	fmov	＄f12, ＄f16
	fmov	＄f14, ＄f17
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	sub	＄r1, ＄r1, ＄r28
	call	trace_ray.2954
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	add	＄r1, ＄r1, ＄r28
	slli	＄r3, ＄r26, 0
	add	＄r28, ＄r31, ＄r3
	ldi	＄r3, ＄r28, 0
	ldi	＄r3, ＄r3, 0
	fldi	＄f0, ＄r0, 442
	fsti	＄f0, ＄r3, 0
	fldi	＄f0, ＄r0, 443
	fsti	＄f0, ＄r3, 1
	fldi	＄f0, ＄r0, 444
	fsti	＄f0, ＄r3, 2
	slli	＄r3, ＄r26, 0
	add	＄r28, ＄r31, ＄r3
	ldi	＄r3, ＄r28, 0
	ldi	＄r3, ＄r3, 6
	sti	＄r27, ＄r3, 0
	slli	＄r3, ＄r26, 0
	add	＄r28, ＄r31, ＄r3
	ldi	＄r22, ＄r28, 0
	mvhi	＄r21, 0
	mvlo	＄r21, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	sub	＄r1, ＄r1, ＄r28
	call	pretrace_diffuse_rays.3014
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r26, ＄r26, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r4, ＄r27, ＄r28
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	blt	＄r4, ＄r3, ble_else.45401
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r3, ＄r4, ＄r28
	j	ble_cont.45402
ble_else.45401:
	mov	＄r3, ＄r4
ble_cont.45402:
	fldi	＄f13, ＄r1, -2
	fldi	＄f12, ＄r1, -1
	fldi	＄f11, ＄r1, 0
	mov	＄r27, ＄r3
	j	pretrace_pixels.3017
bge_else.45398:
	return

#---------------------------------------------------------------------
# args = [＄r25, ＄r26, ＄r31, ＄r27, ＄r22]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
scan_pixel.3028:
	ldi	＄r3, ＄r0, 440
	blt	＄r25, ＄r3, ble_else.45404
	return
ble_else.45404:
	slli	＄r3, ＄r25, 0
	add	＄r28, ＄r27, ＄r3
	ldi	＄r3, ＄r28, 0
	ldi	＄r3, ＄r3, 0
	fldi	＄f0, ＄r3, 0
	fsti	＄f0, ＄r0, 442
	fldi	＄f0, ＄r3, 1
	fsti	＄f0, ＄r0, 443
	fldi	＄f0, ＄r3, 2
	fsti	＄f0, ＄r0, 444
	ldi	＄r4, ＄r0, 441
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r3, ＄r26, ＄r28
	blt	＄r3, ＄r4, ble_else.45406
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	ble_cont.45407
ble_else.45406:
	blt	＄r0, ＄r26, ble_else.45408
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	ble_cont.45409
ble_else.45408:
	ldi	＄r4, ＄r0, 440
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r3, ＄r25, ＄r28
	blt	＄r3, ＄r4, ble_else.45410
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	ble_cont.45411
ble_else.45410:
	blt	＄r0, ＄r25, ble_else.45412
	mvhi	＄r3, 0
	mvlo	＄r3, 0
	j	ble_cont.45413
ble_else.45412:
	mvhi	＄r3, 0
	mvlo	＄r3, 1
ble_cont.45413:
ble_cont.45411:
ble_cont.45409:
ble_cont.45407:
	sti	＄r22, ＄r1, 0
	beq	＄r3, ＄r0, bne_else.45414
	mvhi	＄r21, 0
	mvlo	＄r21, 0
	mov	＄r8, ＄r22
	mov	＄r5, ＄r27
	mov	＄r9, ＄r31
	mov	＄r10, ＄r26
	mov	＄r4, ＄r25
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	try_exploit_neighbors.3001
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	j	bne_cont.45415
bne_else.45414:
	slli	＄r3, ＄r25, 0
	add	＄r28, ＄r27, ＄r3
	ldi	＄r23, ＄r28, 0
	mvhi	＄r21, 0
	mvlo	＄r21, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	do_without_neighbors.2985
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
bne_cont.45415:
	fldi	＄f0, ＄r0, 442
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_int_of_float
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r14, 0
	mvlo	＄r14, 255
	blt	＄r14, ＄r3, ble_else.45416
	blt	＄r3, ＄r0, bge_else.45418
	mov	＄r14, ＄r3
	j	bge_cont.45419
bge_else.45418:
	mvhi	＄r14, 0
	mvlo	＄r14, 0
bge_cont.45419:
	j	ble_cont.45417
ble_else.45416:
	mvhi	＄r14, 0
	mvlo	＄r14, 255
ble_cont.45417:
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	print_int.2587
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r3, 0
	mvlo	＄r3, 32
	output	＄r3
	fldi	＄f0, ＄r0, 443
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_int_of_float
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r14, 0
	mvlo	＄r14, 255
	blt	＄r14, ＄r3, ble_else.45420
	blt	＄r3, ＄r0, bge_else.45422
	mov	＄r14, ＄r3
	j	bge_cont.45423
bge_else.45422:
	mvhi	＄r14, 0
	mvlo	＄r14, 0
bge_cont.45423:
	j	ble_cont.45421
ble_else.45420:
	mvhi	＄r14, 0
	mvlo	＄r14, 255
ble_cont.45421:
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	print_int.2587
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r3, 0
	mvlo	＄r3, 32
	output	＄r3
	fldi	＄f0, ＄r0, 444
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_int_of_float
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r14, 0
	mvlo	＄r14, 255
	blt	＄r14, ＄r3, ble_else.45424
	blt	＄r3, ＄r0, bge_else.45426
	mov	＄r14, ＄r3
	j	bge_cont.45427
bge_else.45426:
	mvhi	＄r14, 0
	mvlo	＄r14, 0
bge_cont.45427:
	j	ble_cont.45425
ble_else.45424:
	mvhi	＄r14, 0
	mvlo	＄r14, 255
ble_cont.45425:
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	print_int.2587
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r3, 0
	mvlo	＄r3, 10
	output	＄r3
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r25, ＄r25, ＄r28
	ldi	＄r22, ＄r1, 0
	j	scan_pixel.3028

#---------------------------------------------------------------------
# args = [＄r26, ＄r31, ＄r27, ＄r22, ＄r3]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
scan_line.3034:
	ldi	＄r4, ＄r0, 441
	blt	＄r26, ＄r4, ble_else.45428
	return
ble_else.45428:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r4, ＄r4, ＄r28
	sti	＄r3, ＄r1, 0
	sti	＄r22, ＄r1, -1
	sti	＄r27, ＄r1, -2
	sti	＄r31, ＄r1, -3
	sti	＄r26, ＄r1, -4
	blt	＄r26, ＄r4, ble_else.45430
	j	ble_cont.45431
ble_else.45430:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r5, ＄r26, ＄r28
	fldi	＄f3, ＄r0, 437
	ldi	＄r4, ＄r0, 439
	sub	＄r6, ＄r5, ＄r4
	mov	＄r3, ＄r6
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_float_of_int
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	add	＄r1, ＄r1, ＄r28
	fmul	＄f0, ＄f3, ＄f0
	fldi	＄f1, ＄r0, 425
	fmul	＄f2, ＄f0, ＄f1
	fldi	＄f1, ＄r0, 422
	fadd	＄f13, ＄f2, ＄f1
	fldi	＄f1, ＄r0, 426
	fmul	＄f2, ＄f0, ＄f1
	fldi	＄f1, ＄r0, 423
	fadd	＄f12, ＄f2, ＄f1
	fldi	＄f1, ＄r0, 427
	fmul	＄f1, ＄f0, ＄f1
	fldi	＄f0, ＄r0, 424
	fadd	＄f11, ＄f1, ＄f0
	ldi	＄r4, ＄r0, 440
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r4, ＄r4, ＄r28
	ldi	＄r3, ＄r1, 0
	mov	＄r27, ＄r3
	mov	＄r26, ＄r4
	mov	＄r31, ＄r22
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	sub	＄r1, ＄r1, ＄r28
	call	pretrace_pixels.3017
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	add	＄r1, ＄r1, ＄r28
ble_cont.45431:
	mvhi	＄r25, 0
	mvlo	＄r25, 0
	ldi	＄r26, ＄r1, -4
	ldi	＄r31, ＄r1, -3
	ldi	＄r27, ＄r1, -2
	ldi	＄r22, ＄r1, -1
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	sub	＄r1, ＄r1, ＄r28
	call	scan_pixel.3028
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	add	＄r1, ＄r1, ＄r28
	ldi	＄r26, ＄r1, -4
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r7, ＄r26, ＄r28
	ldi	＄r3, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r3, ＄r3, ＄r28
	mvhi	＄r6, 0
	mvlo	＄r6, 5
	blt	＄r3, ＄r6, ble_else.45432
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r6, ＄r3, ＄r28
	j	ble_cont.45433
ble_else.45432:
	mov	＄r6, ＄r3
ble_cont.45433:
	ldi	＄r3, ＄r0, 441
	blt	＄r7, ＄r3, ble_else.45434
	return
ble_else.45434:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r3, ＄r3, ＄r28
	sti	＄r6, ＄r1, -5
	sti	＄r7, ＄r1, -6
	blt	＄r7, ＄r3, ble_else.45436
	j	ble_cont.45437
ble_else.45436:
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r4, ＄r7, ＄r28
	fldi	＄f3, ＄r0, 437
	ldi	＄r3, ＄r0, 439
	sub	＄r3, ＄r4, ＄r3
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_float_of_int
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	add	＄r1, ＄r1, ＄r28
	fmul	＄f0, ＄f3, ＄f0
	fldi	＄f1, ＄r0, 425
	fmul	＄f2, ＄f0, ＄f1
	fldi	＄f1, ＄r0, 422
	fadd	＄f13, ＄f2, ＄f1
	fldi	＄f1, ＄r0, 426
	fmul	＄f2, ＄f0, ＄f1
	fldi	＄f1, ＄r0, 423
	fadd	＄f12, ＄f2, ＄f1
	fldi	＄f1, ＄r0, 427
	fmul	＄f1, ＄f0, ＄f1
	fldi	＄f0, ＄r0, 424
	fadd	＄f11, ＄f1, ＄f0
	ldi	＄r3, ＄r0, 440
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r26, ＄r3, ＄r28
	ldi	＄r31, ＄r1, -3
	mov	＄r27, ＄r6
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	sub	＄r1, ＄r1, ＄r28
	call	pretrace_pixels.3017
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	add	＄r1, ＄r1, ＄r28
ble_cont.45437:
	mvhi	＄r25, 0
	mvlo	＄r25, 0
	ldi	＄r7, ＄r1, -6
	ldi	＄r27, ＄r1, -2
	ldi	＄r22, ＄r1, -1
	ldi	＄r31, ＄r1, -3
	mov	＄r26, ＄r7
	mov	＄r28, ＄r22
	mov	＄r22, ＄r31
	mov	＄r31, ＄r27
	mov	＄r27, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	sub	＄r1, ＄r1, ＄r28
	call	scan_pixel.3028
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	add	＄r1, ＄r1, ＄r28
	ldi	＄r7, ＄r1, -6
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r26, ＄r7, ＄r28
	ldi	＄r6, ＄r1, -5
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r4, ＄r6, ＄r28
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	blt	＄r4, ＄r3, ble_else.45438
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r3, ＄r4, ＄r28
	j	ble_cont.45439
ble_else.45438:
	mov	＄r3, ＄r4
ble_cont.45439:
	ldi	＄r22, ＄r1, -1
	ldi	＄r31, ＄r1, -3
	ldi	＄r27, ＄r1, -2
	mov	＄r28, ＄r22
	mov	＄r22, ＄r27
	mov	＄r27, ＄r31
	mov	＄r31, ＄r28
	j	scan_line.3034

#---------------------------------------------------------------------
# args = [＄r10, ＄r9]
# fargs = []
# ret type = Array((Array(Float) * Array(Array(Float)) * Array(Int) * Array(Bool) * Array(Array(Float)) * Array(Array(Float)) * Array(Int) * Array(Array(Float))))
#---------------------------------------------------------------------
init_line_elements.3044:
	blt	＄r9, ＄r0, bge_else.45440
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r13, ＄r3
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r8, ＄r3
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r8, 1
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r8, 2
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r8, 3
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r8, 4
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r12, ＄r3
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r11, ＄r3
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r7, ＄r3
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r7, 1
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r7, 2
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r7, 3
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r7, 4
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r6, ＄r3
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r6, 1
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r6, 2
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r6, 3
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r6, 4
	mvhi	＄r3, 0
	mvlo	＄r3, 1
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r14, ＄r3
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r5, ＄r3
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r5, 1
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r5, 2
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r5, 3
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	sti	＄r3, ＄r5, 4
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	add	＄r2, ＄r2, ＄r28
	sti	＄r5, ＄r3, 7
	sti	＄r14, ＄r3, 6
	sti	＄r6, ＄r3, 5
	sti	＄r7, ＄r3, 4
	sti	＄r11, ＄r3, 3
	sti	＄r12, ＄r3, 2
	sti	＄r8, ＄r3, 1
	sti	＄r13, ＄r3, 0
	slli	＄r4, ＄r9, 0
	add	＄r28, ＄r10, ＄r4
	sti	＄r3, ＄r28, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r9, ＄r9, ＄r28
	j	init_line_elements.3044
bge_else.45440:
	mov	＄r3, ＄r10
	return

#---------------------------------------------------------------------
# args = [＄r4, ＄r5, ＄r3]
# fargs = [＄f5, ＄f1, ＄f2, ＄f0]
# ret type = Unit
#---------------------------------------------------------------------
calc_dirvec.3052:
	fsti	＄f0, ＄r1, 0
	fsti	＄f2, ＄r1, -1
	mvhi	＄r6, 0
	mvlo	＄r6, 5
	blt	＄r4, ＄r6, ble_else.45441
	fmul	＄f2, ＄f5, ＄f5
	fmul	＄f0, ＄f1, ＄f1
	fadd	＄f0, ＄f2, ＄f0
	fadd	＄f0, ＄f0, ＄f17
	fsqrt	＄f0, ＄f0
	fdiv	＄f2, ＄f5, ＄f0
	fdiv	＄f1, ＄f1, ＄f0
	fdiv	＄f0, ＄f17, ＄f0
	slli	＄r4, ＄r5, 0
	ldi	＄r5, ＄r4, 411
	slli	＄r4, ＄r3, 0
	add	＄r28, ＄r5, ＄r4
	ldi	＄r4, ＄r28, 0
	ldi	＄r4, ＄r4, 0
	fsti	＄f2, ＄r4, 0
	fsti	＄f1, ＄r4, 1
	fsti	＄f0, ＄r4, 2
	mvhi	＄r28, 0
	mvlo	＄r28, 40
	add	＄r4, ＄r3, ＄r28
	slli	＄r4, ＄r4, 0
	add	＄r28, ＄r5, ＄r4
	ldi	＄r4, ＄r28, 0
	ldi	＄r4, ＄r4, 0
	fneg	＄f4, ＄f1
	fsti	＄f2, ＄r4, 0
	fsti	＄f0, ＄r4, 1
	fsti	＄f4, ＄r4, 2
	mvhi	＄r28, 0
	mvlo	＄r28, 80
	add	＄r4, ＄r3, ＄r28
	slli	＄r4, ＄r4, 0
	add	＄r28, ＄r5, ＄r4
	ldi	＄r4, ＄r28, 0
	ldi	＄r4, ＄r4, 0
	fneg	＄f3, ＄f2
	fsti	＄f0, ＄r4, 0
	fsti	＄f3, ＄r4, 1
	fsti	＄f4, ＄r4, 2
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r4, ＄r3, ＄r28
	slli	＄r4, ＄r4, 0
	add	＄r28, ＄r5, ＄r4
	ldi	＄r4, ＄r28, 0
	ldi	＄r4, ＄r4, 0
	fneg	＄f0, ＄f0
	fsti	＄f3, ＄r4, 0
	fsti	＄f4, ＄r4, 1
	fsti	＄f0, ＄r4, 2
	mvhi	＄r28, 0
	mvlo	＄r28, 41
	add	＄r4, ＄r3, ＄r28
	slli	＄r4, ＄r4, 0
	add	＄r28, ＄r5, ＄r4
	ldi	＄r4, ＄r28, 0
	ldi	＄r4, ＄r4, 0
	fsti	＄f3, ＄r4, 0
	fsti	＄f0, ＄r4, 1
	fsti	＄f1, ＄r4, 2
	mvhi	＄r28, 0
	mvlo	＄r28, 81
	add	＄r3, ＄r3, ＄r28
	slli	＄r3, ＄r3, 0
	add	＄r28, ＄r5, ＄r3
	ldi	＄r3, ＄r28, 0
	ldi	＄r3, ＄r3, 0
	fsti	＄f0, ＄r3, 0
	fsti	＄f2, ＄r3, 1
	fsti	＄f1, ＄r3, 2
	return
ble_else.45441:
	fmul	＄f0, ＄f1, ＄f1
	# 0.100000
	fmvhi	＄f6, 15820
	fmvlo	＄f6, 52420
	fadd	＄f0, ＄f0, ＄f6
	fsqrt	＄f5, ＄f0
	fdiv	＄f0, ＄f17, ＄f5
	fblt	＄f17, ＄f0, fbge_else.45443
	fblt	＄f0, ＄f20, fbge_else.45445
	mvhi	＄r6, 0
	mvlo	＄r6, 0
	j	fbge_cont.45446
fbge_else.45445:
	mvhi	＄r6, 65535
	mvlo	＄r6, -1
fbge_cont.45446:
	j	fbge_cont.45444
fbge_else.45443:
	mvhi	＄r6, 0
	mvlo	＄r6, 1
fbge_cont.45444:
	beq	＄r6, ＄r0, bne_else.45447
	fdiv	＄f4, ＄f17, ＄f0
	j	bne_cont.45448
bne_else.45447:
	fmov	＄f4, ＄f0
bne_cont.45448:
	fmul	＄f0, ＄f4, ＄f4
	# 121.000000
	fmvhi	＄f13, 17138
	fmvlo	＄f13, 0
	fmul	＄f1, ＄f13, ＄f0
	# 23.000000
	fmvhi	＄f14, 16824
	fmvlo	＄f14, 0
	fdiv	＄f3, ＄f1, ＄f14
	# 100.000000
	fmvhi	＄f1, 17096
	fmvlo	＄f1, 0
	fsti	＄f1, ＄r1, -2
	fldi	＄f1, ＄r1, -2
	fmul	＄f2, ＄f1, ＄f0
	# 21.000000
	fmvhi	＄f1, 16808
	fmvlo	＄f1, 0
	fsti	＄f1, ＄r1, -3
	fldi	＄f1, ＄r1, -3
	fadd	＄f1, ＄f1, ＄f3
	fdiv	＄f2, ＄f2, ＄f1
	# 81.000000
	fmvhi	＄f12, 17058
	fmvlo	＄f12, 0
	fmul	＄f3, ＄f12, ＄f0
	# 19.000000
	fmvhi	＄f1, 16792
	fmvlo	＄f1, 0
	fsti	＄f1, ＄r1, -4
	fldi	＄f1, ＄r1, -4
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 64.000000
	fmvhi	＄f11, 17024
	fmvlo	＄f11, 0
	fmul	＄f3, ＄f11, ＄f0
	# 17.000000
	fmvhi	＄f1, 16776
	fmvlo	＄f1, 0
	fsti	＄f1, ＄r1, -5
	fldi	＄f1, ＄r1, -5
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f1, ＄f3, ＄f1
	# 49.000000
	fmvhi	＄f9, 16964
	fmvlo	＄f9, 0
	fmul	＄f2, ＄f9, ＄f0
	fadd	＄f1, ＄f28, ＄f1
	fdiv	＄f2, ＄f2, ＄f1
	# 36.000000
	fmvhi	＄f10, 16912
	fmvlo	＄f10, 0
	fmul	＄f3, ＄f10, ＄f0
	# 13.000000
	fmvhi	＄f1, 16720
	fmvlo	＄f1, 0
	fsti	＄f1, ＄r1, -6
	fldi	＄f1, ＄r1, -6
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f2, ＄f3, ＄f1
	# 4.000000
	fmvhi	＄f1, 16512
	fmvlo	＄f1, 0
	fsti	＄f1, ＄r1, -7
	# 25.000000
	fmvhi	＄f8, 16840
	fmvlo	＄f8, 0
	fmul	＄f3, ＄f8, ＄f0
	# 11.000000
	fmvhi	＄f1, 16688
	fmvlo	＄f1, 0
	fsti	＄f1, ＄r1, -8
	fldi	＄f1, ＄r1, -8
	fadd	＄f1, ＄f1, ＄f2
	fdiv	＄f1, ＄f3, ＄f1
	# 16.000000
	fmvhi	＄f7, 16768
	fmvlo	＄f7, 0
	fmul	＄f2, ＄f7, ＄f0
	fadd	＄f1, ＄f25, ＄f1
	fdiv	＄f1, ＄f2, ＄f1
	fmul	＄f2, ＄f25, ＄f0
	fadd	＄f1, ＄f26, ＄f1
	fdiv	＄f2, ＄f2, ＄f1
	fldi	＄f1, ＄r1, -7
	fmul	＄f3, ＄f1, ＄f0
	fadd	＄f1, ＄f24, ＄f2
	fdiv	＄f1, ＄f3, ＄f1
	fadd	＄f1, ＄f23, ＄f1
	fdiv	＄f0, ＄f0, ＄f1
	fadd	＄f0, ＄f17, ＄f0
	fdiv	＄f1, ＄f4, ＄f0
	blt	＄r0, ＄r6, ble_else.45449
	blt	＄r6, ＄r0, bge_else.45451
	fmov	＄f0, ＄f1
	j	bge_cont.45452
bge_else.45451:
	# -1.570796
	fmvhi	＄f0, 49097
	fmvlo	＄f0, 4058
	fsub	＄f0, ＄f0, ＄f1
bge_cont.45452:
	j	ble_cont.45450
ble_else.45449:
	fsub	＄f0, ＄f22, ＄f1
ble_cont.45450:
	fldi	＄f1, ＄r1, -1
	fmul	＄f1, ＄f0, ＄f1
	fmul	＄f0, ＄f1, ＄f1
	fdiv	＄f2, ＄f0, ＄f25
	fsub	＄f2, ＄f26, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f24, ＄f2
	fdiv	＄f2, ＄f0, ＄f2
	fsub	＄f2, ＄f23, ＄f2
	fdiv	＄f0, ＄f0, ＄f2
	fsub	＄f0, ＄f17, ＄f0
	fdiv	＄f0, ＄f1, ＄f0
	fmul	＄f5, ＄f0, ＄f5
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r4, ＄r4, ＄r28
	fmul	＄f0, ＄f5, ＄f5
	fadd	＄f0, ＄f0, ＄f6
	fsqrt	＄f6, ＄f0
	fdiv	＄f0, ＄f17, ＄f6
	fblt	＄f17, ＄f0, fbge_else.45453
	fblt	＄f0, ＄f20, fbge_else.45455
	mvhi	＄r6, 0
	mvlo	＄r6, 0
	j	fbge_cont.45456
fbge_else.45455:
	mvhi	＄r6, 65535
	mvlo	＄r6, -1
fbge_cont.45456:
	j	fbge_cont.45454
fbge_else.45453:
	mvhi	＄r6, 0
	mvlo	＄r6, 1
fbge_cont.45454:
	beq	＄r6, ＄r0, bne_else.45457
	fdiv	＄f1, ＄f17, ＄f0
	j	bne_cont.45458
bne_else.45457:
	fmov	＄f1, ＄f0
bne_cont.45458:
	fmul	＄f0, ＄f1, ＄f1
	fmul	＄f2, ＄f13, ＄f0
	fdiv	＄f3, ＄f2, ＄f14
	fldi	＄f2, ＄r1, -2
	fmul	＄f4, ＄f2, ＄f0
	fldi	＄f2, ＄r1, -3
	fadd	＄f2, ＄f2, ＄f3
	fdiv	＄f3, ＄f4, ＄f2
	fmul	＄f4, ＄f12, ＄f0
	fldi	＄f2, ＄r1, -4
	fadd	＄f2, ＄f2, ＄f3
	fdiv	＄f3, ＄f4, ＄f2
	fmul	＄f4, ＄f11, ＄f0
	fldi	＄f2, ＄r1, -5
	fadd	＄f2, ＄f2, ＄f3
	fdiv	＄f2, ＄f4, ＄f2
	fmul	＄f3, ＄f9, ＄f0
	fadd	＄f2, ＄f28, ＄f2
	fdiv	＄f2, ＄f3, ＄f2
	fmul	＄f3, ＄f10, ＄f0
	fldi	＄f4, ＄r1, -6
	fadd	＄f2, ＄f4, ＄f2
	fdiv	＄f2, ＄f3, ＄f2
	fmul	＄f4, ＄f8, ＄f0
	fldi	＄f3, ＄r1, -8
	fadd	＄f2, ＄f3, ＄f2
	fdiv	＄f2, ＄f4, ＄f2
	fmul	＄f3, ＄f7, ＄f0
	fadd	＄f2, ＄f25, ＄f2
	fdiv	＄f2, ＄f3, ＄f2
	fmul	＄f3, ＄f25, ＄f0
	fadd	＄f2, ＄f26, ＄f2
	fdiv	＄f2, ＄f3, ＄f2
	fldi	＄f3, ＄r1, -7
	fmul	＄f3, ＄f3, ＄f0
	fadd	＄f2, ＄f24, ＄f2
	fdiv	＄f2, ＄f3, ＄f2
	fadd	＄f2, ＄f23, ＄f2
	fdiv	＄f0, ＄f0, ＄f2
	fadd	＄f0, ＄f17, ＄f0
	fdiv	＄f1, ＄f1, ＄f0
	blt	＄r0, ＄r6, ble_else.45459
	blt	＄r6, ＄r0, bge_else.45461
	fmov	＄f0, ＄f1
	j	bge_cont.45462
bge_else.45461:
	# -1.570796
	fmvhi	＄f0, 49097
	fmvlo	＄f0, 4058
	fsub	＄f0, ＄f0, ＄f1
bge_cont.45462:
	j	ble_cont.45460
ble_else.45459:
	fsub	＄f0, ＄f22, ＄f1
ble_cont.45460:
	fldi	＄f1, ＄r1, 0
	fmul	＄f0, ＄f0, ＄f1
	fmul	＄f2, ＄f0, ＄f0
	fdiv	＄f1, ＄f2, ＄f25
	fsub	＄f1, ＄f26, ＄f1
	fdiv	＄f1, ＄f2, ＄f1
	fsub	＄f1, ＄f24, ＄f1
	fdiv	＄f1, ＄f2, ＄f1
	fsub	＄f1, ＄f23, ＄f1
	fdiv	＄f1, ＄f2, ＄f1
	fsub	＄f1, ＄f17, ＄f1
	fdiv	＄f0, ＄f0, ＄f1
	fmul	＄f1, ＄f0, ＄f6
	fldi	＄f2, ＄r1, -1
	fldi	＄f0, ＄r1, 0
	j	calc_dirvec.3052

#---------------------------------------------------------------------
# args = [＄r9, ＄r8, ＄r7]
# fargs = [＄f0]
# ret type = Unit
#---------------------------------------------------------------------
calc_dirvecs.3060:
	blt	＄r9, ＄r0, bge_else.45463
	fsti	＄f0, ＄r1, 0
	mov	＄r3, ＄r9
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_float_of_int
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	fmov	＄f1, ＄f0
	# 0.200000
	fmvhi	＄f5, 15948
	fmvlo	＄f5, 52420
	fmul	＄f1, ＄f1, ＄f5
	# 0.900000
	fmvhi	＄f4, 16230
	fmvlo	＄f4, 26206
	fsub	＄f2, ＄f1, ＄f4
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	fldi	＄f0, ＄r1, 0
	fsti	＄f4, ＄r1, -1
	fsti	＄f5, ＄r1, -2
	fsti	＄f1, ＄r1, -3
	mov	＄r3, ＄r7
	mov	＄r5, ＄r8
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	add	＄r1, ＄r1, ＄r28
	# 0.100000
	fmvhi	＄f3, 15820
	fmvlo	＄f3, 52420
	fldi	＄f1, ＄r1, -3
	fadd	＄f2, ＄f1, ＄f3
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r10, ＄r7, ＄r28
	fldi	＄f0, ＄r1, 0
	fsti	＄f3, ＄r1, -4
	mov	＄r3, ＄r10
	mov	＄r5, ＄r8
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r9, ＄r9, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r3, ＄r8, ＄r28
	mvhi	＄r8, 0
	mvlo	＄r8, 5
	blt	＄r3, ＄r8, ble_else.45464
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r8, ＄r3, ＄r28
	j	ble_cont.45465
ble_else.45464:
	mov	＄r8, ＄r3
ble_cont.45465:
	blt	＄r9, ＄r0, bge_else.45466
	mov	＄r3, ＄r9
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_float_of_int
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	add	＄r1, ＄r1, ＄r28
	fmov	＄f1, ＄f0
	fldi	＄f5, ＄r1, -2
	fmul	＄f1, ＄f1, ＄f5
	fldi	＄f4, ＄r1, -1
	fsub	＄f2, ＄f1, ＄f4
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	fldi	＄f0, ＄r1, 0
	fsti	＄f1, ＄r1, -5
	mov	＄r3, ＄r7
	mov	＄r5, ＄r8
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 7
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 7
	add	＄r1, ＄r1, ＄r28
	fldi	＄f3, ＄r1, -4
	fldi	＄f1, ＄r1, -5
	fadd	＄f2, ＄f1, ＄f3
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	fldi	＄f0, ＄r1, 0
	mov	＄r3, ＄r10
	mov	＄r5, ＄r8
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 7
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 7
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r9, ＄r9, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r3, ＄r8, ＄r28
	mvhi	＄r8, 0
	mvlo	＄r8, 5
	blt	＄r3, ＄r8, ble_else.45467
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r8, ＄r3, ＄r28
	j	ble_cont.45468
ble_else.45467:
	mov	＄r8, ＄r3
ble_cont.45468:
	blt	＄r9, ＄r0, bge_else.45469
	mov	＄r3, ＄r9
	mvhi	＄r28, 0
	mvlo	＄r28, 7
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_float_of_int
	mvhi	＄r28, 0
	mvlo	＄r28, 7
	add	＄r1, ＄r1, ＄r28
	fmov	＄f1, ＄f0
	fldi	＄f5, ＄r1, -2
	fmul	＄f1, ＄f1, ＄f5
	fldi	＄f4, ＄r1, -1
	fsub	＄f2, ＄f1, ＄f4
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	fldi	＄f0, ＄r1, 0
	fsti	＄f1, ＄r1, -6
	mov	＄r3, ＄r7
	mov	＄r5, ＄r8
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	add	＄r1, ＄r1, ＄r28
	fldi	＄f3, ＄r1, -4
	fldi	＄f1, ＄r1, -6
	fadd	＄f2, ＄f1, ＄f3
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	fldi	＄f0, ＄r1, 0
	mov	＄r3, ＄r10
	mov	＄r5, ＄r8
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r9, ＄r9, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r3, ＄r8, ＄r28
	mvhi	＄r8, 0
	mvlo	＄r8, 5
	blt	＄r3, ＄r8, ble_else.45470
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r8, ＄r3, ＄r28
	j	ble_cont.45471
ble_else.45470:
	mov	＄r8, ＄r3
ble_cont.45471:
	blt	＄r9, ＄r0, bge_else.45472
	mov	＄r3, ＄r9
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_float_of_int
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	add	＄r1, ＄r1, ＄r28
	fmov	＄f1, ＄f0
	fldi	＄f5, ＄r1, -2
	fmul	＄f1, ＄f1, ＄f5
	fldi	＄f4, ＄r1, -1
	fsub	＄f2, ＄f1, ＄f4
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	fldi	＄f0, ＄r1, 0
	fsti	＄f1, ＄r1, -7
	mov	＄r3, ＄r7
	mov	＄r5, ＄r8
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 9
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 9
	add	＄r1, ＄r1, ＄r28
	fldi	＄f3, ＄r1, -4
	fldi	＄f1, ＄r1, -7
	fadd	＄f2, ＄f1, ＄f3
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	fldi	＄f0, ＄r1, 0
	mov	＄r3, ＄r10
	mov	＄r5, ＄r8
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 9
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 9
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r9, ＄r9, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r4, ＄r8, ＄r28
	mvhi	＄r3, 0
	mvlo	＄r3, 5
	blt	＄r4, ＄r3, ble_else.45473
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r3, ＄r4, ＄r28
	j	ble_cont.45474
ble_else.45473:
	mov	＄r3, ＄r4
ble_cont.45474:
	fldi	＄f0, ＄r1, 0
	mov	＄r8, ＄r3
	j	calc_dirvecs.3060
bge_else.45472:
	return
bge_else.45469:
	return
bge_else.45466:
	return
bge_else.45463:
	return

#---------------------------------------------------------------------
# args = [＄r12, ＄r11, ＄r7]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
calc_dirvec_rows.3065:
	blt	＄r12, ＄r0, bge_else.45479
	mov	＄r3, ＄r12
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_float_of_int
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	# 0.200000
	fmvhi	＄f4, 15948
	fmvlo	＄f4, 52420
	fmul	＄f0, ＄f0, ＄f4
	# 0.900000
	fmvhi	＄f3, 16230
	fmvlo	＄f3, 26206
	fsub	＄f0, ＄f0, ＄f3
	mvhi	＄r3, 0
	mvlo	＄r3, 4
	fsti	＄f0, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_float_of_int
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	fmov	＄f1, ＄f0
	fmul	＄f1, ＄f1, ＄f4
	fsub	＄f10, ＄f1, ＄f3
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	fldi	＄f0, ＄r1, 0
	fsti	＄f10, ＄r1, -1
	fsti	＄f3, ＄r1, -2
	fsti	＄f4, ＄r1, -3
	fsti	＄f1, ＄r1, -4
	mov	＄r3, ＄r7
	mov	＄r5, ＄r11
	fmov	＄f2, ＄f10
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	add	＄r1, ＄r1, ＄r28
	# 0.100000
	fmvhi	＄f5, 15820
	fmvlo	＄f5, 52420
	fldi	＄f1, ＄r1, -4
	fadd	＄f9, ＄f1, ＄f5
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r9, ＄r7, ＄r28
	fldi	＄f0, ＄r1, 0
	fsti	＄f9, ＄r1, -5
	fsti	＄f5, ＄r1, -6
	mov	＄r3, ＄r9
	mov	＄r5, ＄r11
	fmov	＄f2, ＄f9
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r6, 0
	mvlo	＄r6, 3
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r3, ＄r11, ＄r28
	mvhi	＄r8, 0
	mvlo	＄r8, 5
	blt	＄r3, ＄r8, ble_else.45480
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r8, ＄r3, ＄r28
	j	ble_cont.45481
ble_else.45480:
	mov	＄r8, ＄r3
ble_cont.45481:
	mov	＄r3, ＄r6
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_float_of_int
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	add	＄r1, ＄r1, ＄r28
	fmov	＄f1, ＄f0
	fldi	＄f4, ＄r1, -3
	fmul	＄f1, ＄f1, ＄f4
	fldi	＄f3, ＄r1, -2
	fsub	＄f8, ＄f1, ＄f3
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	fldi	＄f0, ＄r1, 0
	fsti	＄f8, ＄r1, -7
	fsti	＄f1, ＄r1, -8
	mov	＄r3, ＄r7
	mov	＄r5, ＄r8
	fmov	＄f2, ＄f8
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	add	＄r1, ＄r1, ＄r28
	fldi	＄f5, ＄r1, -6
	fldi	＄f1, ＄r1, -8
	fadd	＄f7, ＄f1, ＄f5
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	fldi	＄f0, ＄r1, 0
	fsti	＄f7, ＄r1, -9
	mov	＄r3, ＄r9
	mov	＄r5, ＄r8
	fmov	＄f2, ＄f7
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 11
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 11
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r6, 0
	mvlo	＄r6, 2
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r3, ＄r8, ＄r28
	mvhi	＄r8, 0
	mvlo	＄r8, 5
	blt	＄r3, ＄r8, ble_else.45482
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r8, ＄r3, ＄r28
	j	ble_cont.45483
ble_else.45482:
	mov	＄r8, ＄r3
ble_cont.45483:
	mov	＄r3, ＄r6
	mvhi	＄r28, 0
	mvlo	＄r28, 11
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_float_of_int
	mvhi	＄r28, 0
	mvlo	＄r28, 11
	add	＄r1, ＄r1, ＄r28
	fmov	＄f1, ＄f0
	fldi	＄f4, ＄r1, -3
	fmul	＄f1, ＄f1, ＄f4
	fldi	＄f3, ＄r1, -2
	fsub	＄f6, ＄f1, ＄f3
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	fldi	＄f0, ＄r1, 0
	fsti	＄f6, ＄r1, -10
	fsti	＄f1, ＄r1, -11
	mov	＄r3, ＄r7
	mov	＄r5, ＄r8
	fmov	＄f2, ＄f6
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 13
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 13
	add	＄r1, ＄r1, ＄r28
	fldi	＄f5, ＄r1, -6
	fldi	＄f1, ＄r1, -11
	fadd	＄f2, ＄f1, ＄f5
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	fldi	＄f0, ＄r1, 0
	fsti	＄f2, ＄r1, -12
	mov	＄r3, ＄r9
	mov	＄r5, ＄r8
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 14
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 14
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r6, 0
	mvlo	＄r6, 1
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r3, ＄r8, ＄r28
	mvhi	＄r8, 0
	mvlo	＄r8, 5
	blt	＄r3, ＄r8, ble_else.45484
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r8, ＄r3, ＄r28
	j	ble_cont.45485
ble_else.45484:
	mov	＄r8, ＄r3
ble_cont.45485:
	mov	＄r3, ＄r6
	mvhi	＄r28, 0
	mvlo	＄r28, 14
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_float_of_int
	mvhi	＄r28, 0
	mvlo	＄r28, 14
	add	＄r1, ＄r1, ＄r28
	fmov	＄f1, ＄f0
	fldi	＄f4, ＄r1, -3
	fmul	＄f11, ＄f1, ＄f4
	fldi	＄f3, ＄r1, -2
	fsub	＄f1, ＄f11, ＄f3
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	fldi	＄f0, ＄r1, 0
	fsti	＄f11, ＄r1, -13
	mov	＄r3, ＄r7
	mov	＄r5, ＄r8
	fmov	＄f2, ＄f1
	fmov	＄f5, ＄f16
	fmov	＄f1, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 15
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 15
	add	＄r1, ＄r1, ＄r28
	fldi	＄f5, ＄r1, -6
	fldi	＄f11, ＄r1, -13
	fadd	＄f1, ＄f11, ＄f5
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	fldi	＄f0, ＄r1, 0
	mov	＄r3, ＄r9
	mov	＄r5, ＄r8
	fmov	＄f2, ＄f1
	fmov	＄f5, ＄f16
	fmov	＄f1, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 15
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 15
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r9, 0
	mvlo	＄r9, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r3, ＄r8, ＄r28
	mvhi	＄r8, 0
	mvlo	＄r8, 5
	blt	＄r3, ＄r8, ble_else.45486
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r8, ＄r3, ＄r28
	j	ble_cont.45487
ble_else.45486:
	mov	＄r8, ＄r3
ble_cont.45487:
	fldi	＄f0, ＄r1, 0
	sti	＄r7, ＄r1, -14
	mvhi	＄r28, 0
	mvlo	＄r28, 16
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvecs.3060
	mvhi	＄r28, 0
	mvlo	＄r28, 16
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r13, ＄r12, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r3, ＄r11, ＄r28
	mvhi	＄r11, 0
	mvlo	＄r11, 5
	blt	＄r3, ＄r11, ble_else.45488
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r11, ＄r3, ＄r28
	j	ble_cont.45489
ble_else.45488:
	mov	＄r11, ＄r3
ble_cont.45489:
	ldi	＄r7, ＄r1, -14
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	add	＄r12, ＄r7, ＄r28
	blt	＄r13, ＄r0, bge_else.45490
	mov	＄r3, ＄r13
	mvhi	＄r28, 0
	mvlo	＄r28, 16
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_float_of_int
	mvhi	＄r28, 0
	mvlo	＄r28, 16
	add	＄r1, ＄r1, ＄r28
	fldi	＄f4, ＄r1, -3
	fmul	＄f0, ＄f0, ＄f4
	fldi	＄f3, ＄r1, -2
	fsub	＄f0, ＄f0, ＄f3
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	fldi	＄f10, ＄r1, -1
	fsti	＄f0, ＄r1, -15
	mov	＄r3, ＄r12
	mov	＄r5, ＄r11
	fmov	＄f2, ＄f10
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 17
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 17
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r7, ＄r12, ＄r28
	fldi	＄f9, ＄r1, -5
	fldi	＄f0, ＄r1, -15
	mov	＄r3, ＄r7
	mov	＄r5, ＄r11
	fmov	＄f2, ＄f9
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 17
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 17
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r3, ＄r11, ＄r28
	mvhi	＄r5, 0
	mvlo	＄r5, 5
	blt	＄r3, ＄r5, ble_else.45491
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r5, ＄r3, ＄r28
	j	ble_cont.45492
ble_else.45491:
	mov	＄r5, ＄r3
ble_cont.45492:
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	fldi	＄f8, ＄r1, -7
	fldi	＄f0, ＄r1, -15
	sti	＄r5, ＄r1, -16
	mov	＄r3, ＄r12
	fmov	＄f2, ＄f8
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 18
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 18
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	fldi	＄f7, ＄r1, -9
	fldi	＄f0, ＄r1, -15
	ldi	＄r5, ＄r1, -16
	mov	＄r3, ＄r7
	fmov	＄f2, ＄f7
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 18
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 18
	add	＄r1, ＄r1, ＄r28
	ldi	＄r5, ＄r1, -16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r3, ＄r5, ＄r28
	mvhi	＄r5, 0
	mvlo	＄r5, 5
	blt	＄r3, ＄r5, ble_else.45493
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r5, ＄r3, ＄r28
	j	ble_cont.45494
ble_else.45493:
	mov	＄r5, ＄r3
ble_cont.45494:
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	fldi	＄f6, ＄r1, -10
	fldi	＄f0, ＄r1, -15
	sti	＄r5, ＄r1, -17
	mov	＄r3, ＄r12
	fmov	＄f2, ＄f6
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 19
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 19
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r4, 0
	mvlo	＄r4, 0
	fldi	＄f2, ＄r1, -12
	fldi	＄f0, ＄r1, -15
	ldi	＄r5, ＄r1, -17
	mov	＄r3, ＄r7
	fmov	＄f1, ＄f16
	fmov	＄f5, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 19
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvec.3052
	mvhi	＄r28, 0
	mvlo	＄r28, 19
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r9, 0
	mvlo	＄r9, 1
	ldi	＄r5, ＄r1, -17
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r3, ＄r5, ＄r28
	mvhi	＄r8, 0
	mvlo	＄r8, 5
	blt	＄r3, ＄r8, ble_else.45495
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r8, ＄r3, ＄r28
	j	ble_cont.45496
ble_else.45495:
	mov	＄r8, ＄r3
ble_cont.45496:
	fldi	＄f0, ＄r1, -15
	mov	＄r7, ＄r12
	mvhi	＄r28, 0
	mvlo	＄r28, 19
	sub	＄r1, ＄r1, ＄r28
	call	calc_dirvecs.3060
	mvhi	＄r28, 0
	mvlo	＄r28, 19
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r4, ＄r13, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r3, ＄r11, ＄r28
	mvhi	＄r11, 0
	mvlo	＄r11, 5
	blt	＄r3, ＄r11, ble_else.45497
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r11, ＄r3, ＄r28
	j	ble_cont.45498
ble_else.45497:
	mov	＄r11, ＄r3
ble_cont.45498:
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	add	＄r7, ＄r12, ＄r28
	mov	＄r12, ＄r4
	j	calc_dirvec_rows.3065
bge_else.45490:
	return
bge_else.45479:
	return

#---------------------------------------------------------------------
# args = [＄r6, ＄r7]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
create_dirvec_elements.3071:
	blt	＄r7, ＄r0, bge_else.45501
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	ldi	＄r3, ＄r0, 583
	sti	＄r4, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mov	＄r5, ＄r3
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r5, ＄r3, 1
	ldi	＄r4, ＄r1, 0
	sti	＄r4, ＄r3, 0
	slli	＄r4, ＄r7, 0
	add	＄r28, ＄r6, ＄r4
	sti	＄r3, ＄r28, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r7, ＄r7, ＄r28
	blt	＄r7, ＄r0, bge_else.45502
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	ldi	＄r3, ＄r0, 583
	sti	＄r4, ＄r1, -1
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	mov	＄r5, ＄r3
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r5, ＄r3, 1
	ldi	＄r4, ＄r1, -1
	sti	＄r4, ＄r3, 0
	slli	＄r4, ＄r7, 0
	add	＄r28, ＄r6, ＄r4
	sti	＄r3, ＄r28, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r7, ＄r7, ＄r28
	blt	＄r7, ＄r0, bge_else.45503
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	ldi	＄r3, ＄r0, 583
	sti	＄r4, ＄r1, -2
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	add	＄r1, ＄r1, ＄r28
	mov	＄r5, ＄r3
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r5, ＄r3, 1
	ldi	＄r4, ＄r1, -2
	sti	＄r4, ＄r3, 0
	slli	＄r4, ＄r7, 0
	add	＄r28, ＄r6, ＄r4
	sti	＄r3, ＄r28, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r7, ＄r7, ＄r28
	blt	＄r7, ＄r0, bge_else.45504
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	ldi	＄r3, ＄r0, 583
	sti	＄r4, ＄r1, -3
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	add	＄r1, ＄r1, ＄r28
	mov	＄r5, ＄r3
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r5, ＄r3, 1
	ldi	＄r4, ＄r1, -3
	sti	＄r4, ＄r3, 0
	slli	＄r4, ＄r7, 0
	add	＄r28, ＄r6, ＄r4
	sti	＄r3, ＄r28, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r7, ＄r7, ＄r28
	j	create_dirvec_elements.3071
bge_else.45504:
	return
bge_else.45503:
	return
bge_else.45502:
	return
bge_else.45501:
	return

#---------------------------------------------------------------------
# args = [＄r8]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
create_dirvecs.3074:
	blt	＄r8, ＄r0, bge_else.45509
	mvhi	＄r6, 0
	mvlo	＄r6, 120
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	ldi	＄r3, ＄r0, 583
	sti	＄r4, ＄r1, 0
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mov	＄r5, ＄r3
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r5, ＄r3, 1
	ldi	＄r4, ＄r1, 0
	sti	＄r4, ＄r3, 0
	mov	＄r4, ＄r3
	mov	＄r3, ＄r6
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	slli	＄r4, ＄r8, 0
	sti	＄r3, ＄r4, 411
	slli	＄r3, ＄r8, 0
	ldi	＄r6, ＄r3, 411
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	ldi	＄r3, ＄r0, 583
	sti	＄r4, ＄r1, -1
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	mov	＄r5, ＄r3
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r5, ＄r3, 1
	ldi	＄r4, ＄r1, -1
	sti	＄r4, ＄r3, 0
	sti	＄r3, ＄r6, 118
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 3
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	ldi	＄r3, ＄r0, 583
	sti	＄r4, ＄r1, -2
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	add	＄r1, ＄r1, ＄r28
	mov	＄r5, ＄r3
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r5, ＄r3, 1
	ldi	＄r4, ＄r1, -2
	sti	＄r4, ＄r3, 0
	sti	＄r3, ＄r6, 117
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 4
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	ldi	＄r3, ＄r0, 583
	sti	＄r4, ＄r1, -3
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	add	＄r1, ＄r1, ＄r28
	mov	＄r5, ＄r3
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r5, ＄r3, 1
	ldi	＄r4, ＄r1, -3
	sti	＄r4, ＄r3, 0
	sti	＄r3, ＄r6, 116
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 5
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	ldi	＄r3, ＄r0, 583
	sti	＄r4, ＄r1, -4
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	add	＄r1, ＄r1, ＄r28
	mov	＄r5, ＄r3
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r5, ＄r3, 1
	ldi	＄r4, ＄r1, -4
	sti	＄r4, ＄r3, 0
	sti	＄r3, ＄r6, 115
	mvhi	＄r7, 0
	mvlo	＄r7, 114
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	sub	＄r1, ＄r1, ＄r28
	call	create_dirvec_elements.3071
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r8, ＄r8, ＄r28
	blt	＄r8, ＄r0, bge_else.45510
	mvhi	＄r6, 0
	mvlo	＄r6, 120
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 6
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	ldi	＄r3, ＄r0, 583
	sti	＄r4, ＄r1, -5
	mvhi	＄r28, 0
	mvlo	＄r28, 7
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 7
	add	＄r1, ＄r1, ＄r28
	mov	＄r5, ＄r3
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r5, ＄r3, 1
	ldi	＄r4, ＄r1, -5
	sti	＄r4, ＄r3, 0
	mov	＄r4, ＄r3
	mov	＄r3, ＄r6
	mvhi	＄r28, 0
	mvlo	＄r28, 7
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 7
	add	＄r1, ＄r1, ＄r28
	slli	＄r4, ＄r8, 0
	sti	＄r3, ＄r4, 411
	slli	＄r3, ＄r8, 0
	ldi	＄r6, ＄r3, 411
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 7
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 7
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	ldi	＄r3, ＄r0, 583
	sti	＄r4, ＄r1, -6
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	add	＄r1, ＄r1, ＄r28
	mov	＄r5, ＄r3
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r5, ＄r3, 1
	ldi	＄r4, ＄r1, -6
	sti	＄r4, ＄r3, 0
	sti	＄r3, ＄r6, 118
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 8
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	ldi	＄r3, ＄r0, 583
	sti	＄r4, ＄r1, -7
	mvhi	＄r28, 0
	mvlo	＄r28, 9
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 9
	add	＄r1, ＄r1, ＄r28
	mov	＄r5, ＄r3
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r5, ＄r3, 1
	ldi	＄r4, ＄r1, -7
	sti	＄r4, ＄r3, 0
	sti	＄r3, ＄r6, 117
	mvhi	＄r3, 0
	mvlo	＄r3, 3
	fmov	＄f0, ＄f16
	mvhi	＄r28, 0
	mvlo	＄r28, 9
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_float_array
	mvhi	＄r28, 0
	mvlo	＄r28, 9
	add	＄r1, ＄r1, ＄r28
	mov	＄r4, ＄r3
	ldi	＄r3, ＄r0, 583
	sti	＄r4, ＄r1, -8
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	sub	＄r1, ＄r1, ＄r28
	call	min_caml_create_array
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	add	＄r1, ＄r1, ＄r28
	mov	＄r5, ＄r3
	mov	＄r3, ＄r2
	mvhi	＄r28, 0
	mvlo	＄r28, 2
	add	＄r2, ＄r2, ＄r28
	sti	＄r5, ＄r3, 1
	ldi	＄r4, ＄r1, -8
	sti	＄r4, ＄r3, 0
	sti	＄r3, ＄r6, 116
	mvhi	＄r7, 0
	mvlo	＄r7, 115
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	sub	＄r1, ＄r1, ＄r28
	call	create_dirvec_elements.3071
	mvhi	＄r28, 0
	mvlo	＄r28, 10
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r8, ＄r8, ＄r28
	j	create_dirvecs.3074
bge_else.45510:
	return
bge_else.45509:
	return

#---------------------------------------------------------------------
# args = [＄r12, ＄r13]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
init_dirvec_constants.3076:
	blt	＄r13, ＄r0, bge_else.45513
	slli	＄r3, ＄r13, 0
	add	＄r28, ＄r12, ＄r3
	ldi	＄r7, ＄r28, 0
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r13, ＄r13, ＄r28
	blt	＄r13, ＄r0, bge_else.45514
	slli	＄r3, ＄r13, 0
	add	＄r28, ＄r12, ＄r3
	ldi	＄r7, ＄r28, 0
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r13, ＄r13, ＄r28
	blt	＄r13, ＄r0, bge_else.45515
	slli	＄r3, ＄r13, 0
	add	＄r28, ＄r12, ＄r3
	ldi	＄r7, ＄r28, 0
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r13, ＄r13, ＄r28
	blt	＄r13, ＄r0, bge_else.45516
	slli	＄r3, ＄r13, 0
	add	＄r28, ＄r12, ＄r3
	ldi	＄r7, ＄r28, 0
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r13, ＄r13, ＄r28
	blt	＄r13, ＄r0, bge_else.45517
	slli	＄r3, ＄r13, 0
	add	＄r28, ＄r12, ＄r3
	ldi	＄r7, ＄r28, 0
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r13, ＄r13, ＄r28
	blt	＄r13, ＄r0, bge_else.45518
	slli	＄r3, ＄r13, 0
	add	＄r28, ＄r12, ＄r3
	ldi	＄r7, ＄r28, 0
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r13, ＄r13, ＄r28
	blt	＄r13, ＄r0, bge_else.45519
	slli	＄r3, ＄r13, 0
	add	＄r28, ＄r12, ＄r3
	ldi	＄r7, ＄r28, 0
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r13, ＄r13, ＄r28
	blt	＄r13, ＄r0, bge_else.45520
	slli	＄r3, ＄r13, 0
	add	＄r28, ＄r12, ＄r3
	ldi	＄r7, ＄r28, 0
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r13, ＄r13, ＄r28
	j	init_dirvec_constants.3076
bge_else.45520:
	return
bge_else.45519:
	return
bge_else.45518:
	return
bge_else.45517:
	return
bge_else.45516:
	return
bge_else.45515:
	return
bge_else.45514:
	return
bge_else.45513:
	return

#---------------------------------------------------------------------
# args = [＄r14]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
init_vecset_constants.3079:
	blt	＄r14, ＄r0, bge_else.45529
	slli	＄r3, ＄r14, 0
	ldi	＄r12, ＄r3, 411
	ldi	＄r7, ＄r12, 119
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r7, ＄r12, 118
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r7, ＄r12, 117
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r7, ＄r12, 116
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r7, ＄r12, 115
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r7, ＄r12, 114
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r7, ＄r12, 113
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r7, ＄r12, 112
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r13, 0
	mvlo	＄r13, 111
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	init_dirvec_constants.3076
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r14, ＄r14, ＄r28
	blt	＄r14, ＄r0, bge_else.45530
	slli	＄r3, ＄r14, 0
	ldi	＄r12, ＄r3, 411
	ldi	＄r7, ＄r12, 119
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r7, ＄r12, 118
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r7, ＄r12, 117
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r7, ＄r12, 116
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r7, ＄r12, 115
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r7, ＄r12, 114
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	ldi	＄r7, ＄r12, 113
	ldi	＄r3, ＄r0, 583
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r5, ＄r3, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	iter_setup_dirvec_constants.2860
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r13, 0
	mvlo	＄r13, 112
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r1, ＄r1, ＄r28
	call	init_dirvec_constants.3076
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	add	＄r1, ＄r1, ＄r28
	mvhi	＄r28, 0
	mvlo	＄r28, 1
	sub	＄r14, ＄r14, ＄r28
	j	init_vecset_constants.3079
bge_else.45530:
	return
bge_else.45529:
	return
