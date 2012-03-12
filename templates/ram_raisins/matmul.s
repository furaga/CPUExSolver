	j	min_caml_start

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


min_caml_start:
	lui	$r29, 0
	lli	$r29, 11
	addi	$r1, $r0, 1
	sub	$r2, $r0, $r1
	# 0.000000
	flui	$f16, 0
	flli	$f16, 0
	# 12.000000
	flui	$f17, 16704
	flli	$f17, 0
	# 11.000000
	flui	$f18, 16688
	flli	$f18, 0
	# 10.000000
	flui	$f19, 16672
	flli	$f19, 0
	# 9.000000
	flui	$f20, 16656
	flli	$f20, 0
	# 8.000000
	flui	$f21, 16640
	flli	$f21, 0
	# 7.000000
	flui	$f22, 16608
	flli	$f22, 0
	# 6.000000
	flui	$f23, 16576
	flli	$f23, 0
	# 5.000000
	flui	$f24, 16544
	flli	$f24, 0
	# 4.000000
	flui	$f25, 16512
	flli	$f25, 0
	# 3.000000
	flui	$f26, 16448
	flli	$f26, 0
	# 1.000000
	flui	$f27, 16256
	flli	$f27, 0
	# 2.000000
	flui	$f28, 16384
	flli	$f28, 0
	fmov	$f0, $f28
	addi	$r3, $r0, 1
	addi	$r4, $r0, 0
	store	$r29, $r0, 11
	addi	$r29, $r0, 9
	fmovi	$r27, $f0
	store	$r27, $r30, 0
	store	$r31, $r30, -2
	subi	$r30, $r30, 3
	jal	min_caml_create_array
	addi	$r30, $r30, 3
	load	$r31, $r30, -2
	load	$r29, $r0, 11
	addi	$r3, $r0, 1
	addi	$r4, $r0, 0
	store	$r29, $r0, 11
	addi	$r29, $r0, 8
	store	$r31, $r30, -2
	subi	$r30, $r30, 3
	jal	min_caml_create_array
	addi	$r30, $r30, 3
	load	$r31, $r30, -2
	load	$r29, $r0, 11
	addi	$r3, $r0, 1
	addi	$r4, $r0, 0
	store	$r29, $r0, 11
	addi	$r29, $r0, 7
	store	$r31, $r30, -2
	subi	$r30, $r30, 3
	jal	min_caml_create_array
	addi	$r30, $r30, 3
	load	$r31, $r30, -2
	load	$r29, $r0, 11
	addi	$r3, $r0, 1
	addi	$r4, $r0, 0
	store	$r29, $r0, 11
	addi	$r29, $r0, 6
	store	$r31, $r30, -2
	subi	$r30, $r30, 3
	jal	min_caml_create_array
	addi	$r30, $r30, 3
	load	$r31, $r30, -2
	load	$r29, $r0, 11
	addi	$r3, $r0, 1
	addi	$r4, $r0, 1
	store	$r29, $r0, 11
	addi	$r29, $r0, 5
	store	$r31, $r30, -2
	subi	$r30, $r30, 3
	jal	min_caml_create_array
	addi	$r30, $r30, 3
	load	$r31, $r30, -2
	load	$r29, $r0, 11
	addi	$r3, $r0, 1
	addi	$r4, $r0, 0
	store	$r29, $r0, 11
	addi	$r29, $r0, 4
	store	$r31, $r30, -2
	subi	$r30, $r30, 3
	jal	min_caml_create_array
	addi	$r30, $r30, 3
	load	$r31, $r30, -2
	load	$r29, $r0, 11
	addi	$r3, $r0, 0
	fmov	$f0, $f16
	store	$r29, $r0, 11
	addi	$r29, $r0, 3
	store	$r31, $r30, -2
	subi	$r30, $r30, 3
	jal	min_caml_create_float_array
	addi	$r30, $r30, 3
	load	$r31, $r30, -2
	load	$r29, $r0, 11
	addi	$r3, $r0, 2
	addi	$r4, $r0, 3
	store	$r31, $r30, -2
	subi	$r30, $r30, 3
	jal	make.513
	addi	$r30, $r30, 3
	load	$r31, $r30, -2
	store	$r3, $r0, 2
	addi	$r4, $r0, 3
	addi	$r5, $r0, 2
	store	$r3, $r30, -1
	mov	$r3, $r4
	mov	$r4, $r5
	store	$r31, $r30, -3
	subi	$r30, $r30, 4
	jal	make.513
	addi	$r30, $r30, 4
	load	$r31, $r30, -3
	store	$r3, $r0, 1
	addi	$r4, $r0, 2
	addi	$r5, $r0, 2
	store	$r3, $r30, -2
	mov	$r3, $r4
	mov	$r4, $r5
	store	$r31, $r30, -4
	subi	$r30, $r30, 5
	jal	make.513
	addi	$r30, $r30, 5
	load	$r31, $r30, -4
	mov	$r8, $r3
	store	$r8, $r0, 0
	load	$r6, $r30, -1
	load	$r3, $r6, 0
	fmov	$f0, $f27
	fmovi	$r27, $f0
	store	$r27, $r3, 0
	load	$r3, $r6, 0
	load	$r27, $r30, 0
	imovf	$f0, $r27
	fmovi	$r27, $f0
	store	$r27, $r3, 1
	load	$r3, $r6, 0
	fmov	$f0, $f26
	fmovi	$r27, $f0
	store	$r27, $r3, 2
	load	$r3, $r6, 1
	fmov	$f0, $f25
	fmovi	$r27, $f0
	store	$r27, $r3, 0
	load	$r3, $r6, 1
	fmov	$f0, $f24
	fmovi	$r27, $f0
	store	$r27, $r3, 1
	load	$r3, $r6, 1
	fmov	$f0, $f23
	fmovi	$r27, $f0
	store	$r27, $r3, 2
	load	$r7, $r30, -2
	load	$r3, $r7, 0
	fmov	$f0, $f22
	fmovi	$r27, $f0
	store	$r27, $r3, 0
	load	$r3, $r7, 0
	fmov	$f0, $f21
	fmovi	$r27, $f0
	store	$r27, $r3, 1
	load	$r3, $r7, 1
	fmov	$f0, $f20
	fmovi	$r27, $f0
	store	$r27, $r3, 0
	load	$r3, $r7, 1
	fmov	$f0, $f19
	fmovi	$r27, $f0
	store	$r27, $r3, 1
	load	$r3, $r7, 2
	fmov	$f0, $f18
	fmovi	$r27, $f0
	store	$r27, $r3, 0
	load	$r3, $r7, 2
	fmov	$f0, $f17
	fmovi	$r27, $f0
	store	$r27, $r3, 1
	addi	$r3, $r0, 2
	addi	$r4, $r0, 3
	addi	$r5, $r0, 2
	store	$r8, $r30, -3
	store	$r31, $r30, -5
	subi	$r30, $r30, 6
	jal	mul.505
	addi	$r30, $r30, 6
	load	$r31, $r30, -5
	load	$r3, $r30, -3
	load	$r4, $r3, 0
	load	$r27, $r4, 0
	imovf	$f0, $r27
	store	$r31, $r30, -5
	subi	$r30, $r30, 6
	jal	min_caml_truncate
	addi	$r30, $r30, 6
	load	$r31, $r30, -5
	store	$r31, $r30, -5
	subi	$r30, $r30, 6
	jal	print_int.503
	addi	$r30, $r30, 6
	load	$r31, $r30, -5
	store	$r3, $r30, -5
	addi	$r3, $r0, 10
	iost	$r3
	load	$r3, $r30, -5
	load	$r3, $r30, -3
	load	$r4, $r3, 0
	load	$r27, $r4, 1
	imovf	$f0, $r27
	store	$r31, $r30, -5
	subi	$r30, $r30, 6
	jal	min_caml_truncate
	addi	$r30, $r30, 6
	load	$r31, $r30, -5
	store	$r31, $r30, -5
	subi	$r30, $r30, 6
	jal	print_int.503
	addi	$r30, $r30, 6
	load	$r31, $r30, -5
	store	$r3, $r30, -5
	addi	$r3, $r0, 10
	iost	$r3
	load	$r3, $r30, -5
	load	$r3, $r30, -3
	load	$r4, $r3, 1
	load	$r27, $r4, 0
	imovf	$f0, $r27
	store	$r31, $r30, -5
	subi	$r30, $r30, 6
	jal	min_caml_truncate
	addi	$r30, $r30, 6
	load	$r31, $r30, -5
	store	$r31, $r30, -5
	subi	$r30, $r30, 6
	jal	print_int.503
	addi	$r30, $r30, 6
	load	$r31, $r30, -5
	store	$r3, $r30, -5
	addi	$r3, $r0, 10
	iost	$r3
	load	$r3, $r30, -5
	load	$r3, $r30, -3
	load	$r3, $r3, 1
	load	$r27, $r3, 1
	imovf	$f0, $r27
	store	$r31, $r30, -5
	subi	$r30, $r30, 6
	jal	min_caml_truncate
	addi	$r30, $r30, 6
	load	$r31, $r30, -5
	store	$r31, $r30, -5
	subi	$r30, $r30, 6
	jal	print_int.503
	addi	$r30, $r30, 6
	load	$r31, $r30, -5
	store	$r3, $r30, -5
	addi	$r3, $r0, 10
	iost	$r3
	load	$r3, $r30, -5
	hlt

#---------------------------------------------------------------------
# args = [$r3, $r4, $r5, $r6]
# fargs = []
# ret type = Int
#---------------------------------------------------------------------
div_binary_search.491:
	add	$r7, $r5, $r6
	srli	$r7, $r7, 1
	mul	$r8, $r7, $r4
	sub	$r9, $r6, $r5
	blt	$r1, $r9, ble_else.1194
	mov	$r3, $r5
	jr	$r31
ble_else.1194:
	blt	$r8, $r3, ble_else.1195
	bne	$r8, $r3, beq_else.1196
	mov	$r3, $r7
	jr	$r31
beq_else.1196:
	mov	$r6, $r7
	j	div_binary_search.491
ble_else.1195:
	mov	$r5, $r7
	j	div_binary_search.491

#---------------------------------------------------------------------
# args = [$r3]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
print_int.503:
	blt	$r3, $r0, bge_else.1197
	lui	$r4, 1525
	lli	$r4, 57600
	addi	$r5, $r0, 0
	addi	$r6, $r0, 3
	store	$r3, $r30, 0
	store	$r31, $r30, -2
	subi	$r30, $r30, 3
	jal	div_binary_search.491
	addi	$r30, $r30, 3
	load	$r31, $r30, -2
	lui	$r4, 1525
	lli	$r4, 57600
	mul	$r4, $r3, $r4
	load	$r5, $r30, 0
	sub	$r4, $r5, $r4
	store	$r4, $r30, -1
	blt	$r0, $r3, ble_else.1198
	addi	$r3, $r0, 0
	j	ble_cont.1199
ble_else.1198:
	addi	$r5, $r0, 48
	add	$r3, $r5, $r3
	iost	$r3
	addi	$r3, $r0, 1
ble_cont.1199:
	lui	$r4, 152
	lli	$r4, 38528
	addi	$r5, $r0, 0
	addi	$r6, $r0, 10
	load	$r7, $r30, -1
	store	$r3, $r30, -2
	mov	$r3, $r7
	store	$r31, $r30, -4
	subi	$r30, $r30, 5
	jal	div_binary_search.491
	addi	$r30, $r30, 5
	load	$r31, $r30, -4
	lui	$r4, 152
	lli	$r4, 38528
	mul	$r4, $r3, $r4
	load	$r5, $r30, -1
	sub	$r4, $r5, $r4
	store	$r4, $r30, -3
	blt	$r0, $r3, ble_else.1200
	load	$r5, $r30, -2
	bne	$r5, $r0, beq_else.1202
	addi	$r3, $r0, 0
	j	beq_cont.1203
beq_else.1202:
	addi	$r5, $r0, 48
	add	$r3, $r5, $r3
	iost	$r3
	addi	$r3, $r0, 1
beq_cont.1203:
	j	ble_cont.1201
ble_else.1200:
	addi	$r5, $r0, 48
	add	$r3, $r5, $r3
	iost	$r3
	addi	$r3, $r0, 1
ble_cont.1201:
	lui	$r4, 15
	lli	$r4, 16960
	addi	$r5, $r0, 0
	addi	$r6, $r0, 10
	load	$r7, $r30, -3
	store	$r3, $r30, -4
	mov	$r3, $r7
	store	$r31, $r30, -6
	subi	$r30, $r30, 7
	jal	div_binary_search.491
	addi	$r30, $r30, 7
	load	$r31, $r30, -6
	lui	$r4, 15
	lli	$r4, 16960
	mul	$r4, $r3, $r4
	load	$r5, $r30, -3
	sub	$r4, $r5, $r4
	store	$r4, $r30, -5
	blt	$r0, $r3, ble_else.1204
	load	$r5, $r30, -4
	bne	$r5, $r0, beq_else.1206
	addi	$r3, $r0, 0
	j	beq_cont.1207
beq_else.1206:
	addi	$r5, $r0, 48
	add	$r3, $r5, $r3
	iost	$r3
	addi	$r3, $r0, 1
beq_cont.1207:
	j	ble_cont.1205
ble_else.1204:
	addi	$r5, $r0, 48
	add	$r3, $r5, $r3
	iost	$r3
	addi	$r3, $r0, 1
ble_cont.1205:
	lui	$r4, 1
	lli	$r4, 34464
	addi	$r5, $r0, 0
	addi	$r6, $r0, 10
	load	$r7, $r30, -5
	store	$r3, $r30, -6
	mov	$r3, $r7
	store	$r31, $r30, -8
	subi	$r30, $r30, 9
	jal	div_binary_search.491
	addi	$r30, $r30, 9
	load	$r31, $r30, -8
	lui	$r4, 1
	lli	$r4, 34464
	mul	$r4, $r3, $r4
	load	$r5, $r30, -5
	sub	$r4, $r5, $r4
	store	$r4, $r30, -7
	blt	$r0, $r3, ble_else.1208
	load	$r5, $r30, -6
	bne	$r5, $r0, beq_else.1210
	addi	$r3, $r0, 0
	j	beq_cont.1211
beq_else.1210:
	addi	$r5, $r0, 48
	add	$r3, $r5, $r3
	iost	$r3
	addi	$r3, $r0, 1
beq_cont.1211:
	j	ble_cont.1209
ble_else.1208:
	addi	$r5, $r0, 48
	add	$r3, $r5, $r3
	iost	$r3
	addi	$r3, $r0, 1
ble_cont.1209:
	addi	$r4, $r0, 10000
	addi	$r5, $r0, 0
	addi	$r6, $r0, 10
	load	$r7, $r30, -7
	store	$r3, $r30, -8
	mov	$r3, $r7
	store	$r31, $r30, -10
	subi	$r30, $r30, 11
	jal	div_binary_search.491
	addi	$r30, $r30, 11
	load	$r31, $r30, -10
	addi	$r4, $r0, 10000
	mul	$r4, $r3, $r4
	load	$r5, $r30, -7
	sub	$r4, $r5, $r4
	store	$r4, $r30, -9
	blt	$r0, $r3, ble_else.1212
	load	$r5, $r30, -8
	bne	$r5, $r0, beq_else.1214
	addi	$r3, $r0, 0
	j	beq_cont.1215
beq_else.1214:
	addi	$r5, $r0, 48
	add	$r3, $r5, $r3
	iost	$r3
	addi	$r3, $r0, 1
beq_cont.1215:
	j	ble_cont.1213
ble_else.1212:
	addi	$r5, $r0, 48
	add	$r3, $r5, $r3
	iost	$r3
	addi	$r3, $r0, 1
ble_cont.1213:
	addi	$r4, $r0, 1000
	addi	$r5, $r0, 0
	addi	$r6, $r0, 10
	load	$r7, $r30, -9
	store	$r3, $r30, -10
	mov	$r3, $r7
	store	$r31, $r30, -12
	subi	$r30, $r30, 13
	jal	div_binary_search.491
	addi	$r30, $r30, 13
	load	$r31, $r30, -12
	muli	$r4, $r3, 1000
	load	$r5, $r30, -9
	sub	$r4, $r5, $r4
	store	$r4, $r30, -11
	blt	$r0, $r3, ble_else.1216
	load	$r5, $r30, -10
	bne	$r5, $r0, beq_else.1218
	addi	$r3, $r0, 0
	j	beq_cont.1219
beq_else.1218:
	addi	$r5, $r0, 48
	add	$r3, $r5, $r3
	iost	$r3
	addi	$r3, $r0, 1
beq_cont.1219:
	j	ble_cont.1217
ble_else.1216:
	addi	$r5, $r0, 48
	add	$r3, $r5, $r3
	iost	$r3
	addi	$r3, $r0, 1
ble_cont.1217:
	addi	$r4, $r0, 100
	addi	$r5, $r0, 0
	addi	$r6, $r0, 10
	load	$r7, $r30, -11
	store	$r3, $r30, -12
	mov	$r3, $r7
	store	$r31, $r30, -14
	subi	$r30, $r30, 15
	jal	div_binary_search.491
	addi	$r30, $r30, 15
	load	$r31, $r30, -14
	muli	$r4, $r3, 100
	load	$r5, $r30, -11
	sub	$r4, $r5, $r4
	store	$r4, $r30, -13
	blt	$r0, $r3, ble_else.1220
	load	$r5, $r30, -12
	bne	$r5, $r0, beq_else.1222
	addi	$r3, $r0, 0
	j	beq_cont.1223
beq_else.1222:
	addi	$r5, $r0, 48
	add	$r3, $r5, $r3
	iost	$r3
	addi	$r3, $r0, 1
beq_cont.1223:
	j	ble_cont.1221
ble_else.1220:
	addi	$r5, $r0, 48
	add	$r3, $r5, $r3
	iost	$r3
	addi	$r3, $r0, 1
ble_cont.1221:
	addi	$r4, $r0, 10
	addi	$r5, $r0, 0
	addi	$r6, $r0, 10
	load	$r7, $r30, -13
	store	$r3, $r30, -14
	mov	$r3, $r7
	store	$r31, $r30, -16
	subi	$r30, $r30, 17
	jal	div_binary_search.491
	addi	$r30, $r30, 17
	load	$r31, $r30, -16
	muli	$r4, $r3, 10
	load	$r5, $r30, -13
	sub	$r4, $r5, $r4
	store	$r4, $r30, -15
	blt	$r0, $r3, ble_else.1224
	load	$r5, $r30, -14
	bne	$r5, $r0, beq_else.1226
	addi	$r3, $r0, 0
	j	beq_cont.1227
beq_else.1226:
	addi	$r5, $r0, 48
	add	$r3, $r5, $r3
	iost	$r3
	addi	$r3, $r0, 1
beq_cont.1227:
	j	ble_cont.1225
ble_else.1224:
	addi	$r5, $r0, 48
	add	$r3, $r5, $r3
	iost	$r3
	addi	$r3, $r0, 1
ble_cont.1225:
	addi	$r3, $r0, 48
	load	$r4, $r30, -15
	add	$r3, $r3, $r4
	iost	$r3
	jr	$r31
bge_else.1197:
	addi	$r4, $r0, 45
	store	$r3, $r30, 0
	iost	$r4
	load	$r3, $r30, 0
	sub	$r3, $r0, $r3
	j	print_int.503

#---------------------------------------------------------------------
# args = [$r3]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
loop3.644:
	load	$r4, $r28, 5
	load	$r5, $r28, 4
	load	$r6, $r28, 3
	load	$r7, $r28, 2
	load	$r8, $r28, 1
	blt	$r3, $r0, bge_else.1228
	slli	$r9, $r5, 0
	add	$r27, $r6, $r9
	load	$r6, $r27, 0
	slli	$r9, $r4, 0
	add	$r27, $r6, $r9
	load	$r27, $r27, 0
	imovf	$f0, $r27
	slli	$r5, $r5, 0
	add	$r27, $r8, $r5
	load	$r5, $r27, 0
	slli	$r8, $r3, 0
	add	$r27, $r5, $r8
	load	$r27, $r27, 0
	imovf	$f1, $r27
	slli	$r5, $r3, 0
	add	$r27, $r7, $r5
	load	$r5, $r27, 0
	slli	$r7, $r4, 0
	add	$r27, $r5, $r7
	load	$r27, $r27, 0
	imovf	$f2, $r27
	fmul	$f1, $f1, $f2
	fadd	$f0, $f0, $f1
	slli	$r4, $r4, 0
	add	$r27, $r6, $r4
	store	$r3, $r30, -1
	fmovi	$r3, $f0
	store	$r3, $r27, 0
	load	$r3, $r30, -1
	subi	$r3, $r3, 1
	load	$r27, $r28, 0
	jr	$r27
bge_else.1228:
	jr	$r31

#---------------------------------------------------------------------
# args = [$r3]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
loop2.637:
	load	$r4, $r28, 5
	load	$r5, $r28, 4
	load	$r6, $r28, 3
	load	$r7, $r28, 2
	load	$r8, $r28, 1
	blt	$r3, $r0, bge_else.1230
	mov	$r9, $r29
	addi	$r29, $r29, 6
	setl $r10, loop3.644
	store	$r10, $r9, 0
	store	$r3, $r9, 5
	store	$r5, $r9, 4
	store	$r6, $r9, 3
	store	$r7, $r9, 2
	store	$r8, $r9, 1
	subi	$r4, $r4, 1
	store	$r28, $r30, 0
	store	$r3, $r30, -1
	mov	$r3, $r4
	mov	$r28, $r9
	store	$r31, $r30, -3
	subi	$r30, $r30, 4
	load	$r27, $r28, 0
	jalr	$r27
	addi	$r30, $r30, 4
	load	$r31, $r30, -3
	load	$r3, $r30, -1
	subi	$r3, $r3, 1
	load	$r28, $r30, 0
	load	$r27, $r28, 0
	jr	$r27
bge_else.1230:
	jr	$r31

#---------------------------------------------------------------------
# args = [$r3]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
loop1.633:
	load	$r4, $r28, 5
	load	$r5, $r28, 4
	load	$r6, $r28, 3
	load	$r7, $r28, 2
	load	$r8, $r28, 1
	blt	$r3, $r0, bge_else.1232
	mov	$r9, $r29
	addi	$r29, $r29, 6
	setl $r10, loop2.637
	store	$r10, $r9, 0
	store	$r5, $r9, 5
	store	$r3, $r9, 4
	store	$r6, $r9, 3
	store	$r7, $r9, 2
	store	$r8, $r9, 1
	subi	$r4, $r4, 1
	store	$r28, $r30, 0
	store	$r3, $r30, -1
	mov	$r3, $r4
	mov	$r28, $r9
	store	$r31, $r30, -3
	subi	$r30, $r30, 4
	load	$r27, $r28, 0
	jalr	$r27
	addi	$r30, $r30, 4
	load	$r31, $r30, -3
	load	$r3, $r30, -1
	subi	$r3, $r3, 1
	load	$r28, $r30, 0
	load	$r27, $r28, 0
	jr	$r27
bge_else.1232:
	jr	$r31

#---------------------------------------------------------------------
# args = [$r3, $r4, $r5, $r6, $r7, $r8]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
mul.505:
	mov	$r28, $r29
	addi	$r29, $r29, 6
	setl $r9, loop1.633
	store	$r9, $r28, 0
	store	$r5, $r28, 5
	store	$r4, $r28, 4
	store	$r8, $r28, 3
	store	$r7, $r28, 2
	store	$r6, $r28, 1
	subi	$r3, $r3, 1
	load	$r27, $r28, 0
	jr	$r27

#---------------------------------------------------------------------
# args = [$r3]
# fargs = []
# ret type = Unit
#---------------------------------------------------------------------
init.621:
	load	$r4, $r28, 2
	load	$r5, $r28, 1
	blt	$r3, $r0, bge_else.1234
	fmov	$f0, $f16
	store	$r28, $r30, 0
	store	$r5, $r30, -1
	store	$r3, $r30, -2
	mov	$r3, $r4
	store	$r31, $r30, -4
	subi	$r30, $r30, 5
	jal	min_caml_create_float_array
	addi	$r30, $r30, 5
	load	$r31, $r30, -4
	load	$r4, $r30, -2
	slli	$r5, $r4, 0
	load	$r6, $r30, -1
	add	$r27, $r6, $r5
	store	$r3, $r27, 0
	subi	$r3, $r4, 1
	load	$r28, $r30, 0
	load	$r27, $r28, 0
	jr	$r27
bge_else.1234:
	jr	$r31

#---------------------------------------------------------------------
# args = [$r3, $r4]
# fargs = []
# ret type = Array(Array(Float))
#---------------------------------------------------------------------
make.513:
	subi	$r5, $r0, -3
	store	$r3, $r30, 0
	store	$r4, $r30, -1
	mov	$r4, $r5
	store	$r31, $r30, -3
	subi	$r30, $r30, 4
	jal	min_caml_create_array
	addi	$r30, $r30, 4
	load	$r31, $r30, -3
	mov	$r28, $r29
	addi	$r29, $r29, 3
	setl $r4, init.621
	store	$r4, $r28, 0
	load	$r4, $r30, -1
	store	$r4, $r28, 2
	store	$r3, $r28, 1
	load	$r4, $r30, 0
	subi	$r4, $r4, 1
	store	$r3, $r30, -2
	mov	$r3, $r4
	store	$r31, $r30, -4
	subi	$r30, $r30, 5
	load	$r27, $r28, 0
	jalr	$r27
	addi	$r30, $r30, 5
	load	$r31, $r30, -4
	load	$r3, $r30, -2
	jr	$r31
