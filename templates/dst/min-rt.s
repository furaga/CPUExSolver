.init_heap_size	0
	jmp	min_caml_start
!----------------------------------------------------------------------
!
! lib_asm.s
!
!----------------------------------------------------------------------

! * create_array
min_caml_create_array:
	slli %g3, %g3, 2
	add %g5, %g3, %g2
	mov %g3, %g2
CREATE_ARRAY_LOOP:
	jlt  %g2, %g5, CREATE_ARRAY_CONTINUE
	return
CREATE_ARRAY_CONTINUE:
	sti %g4, %g2, 0	
	addi %g2, %g2, 4	
	jmp CREATE_ARRAY_LOOP

! * create_float_array
min_caml_create_float_array:
	slli %g3, %g3, 2
	add %g4, %g3, %g2
	mov %g3, %g2
CREATE_FLOAT_ARRAY_LOOP:
	jlt %g2, %g4, CREATE_FLOAT_ARRAY_CONTINUE
	return
CREATE_FLOAT_ARRAY_CONTINUE:
	fsti %f0, %g2, 0
	addi %g2, %g2, 4
	jmp CREATE_FLOAT_ARRAY_LOOP

! * floor		%f0 + MAGICF - MAGICF
min_caml_floor:
	fmov %f1, %f0
	! %f4 <- 0.0
	! fset %f4, 0.0
	mvhi %g30, 0
	mvlo %g30, 0
	sti %g30, %g1, 0
	fldi %f4, %g1, 0

	fjlt %f0, %f4, FLOOR_NEGATIVE	! if (%f4 <= %f0) goto FLOOR_PISITIVE
FLOOR_POSITIVE:
	! %f2 <- 8388608.0(0x4b000000)
	mvhi %g30, 19200
	mvlo %g30, 0
	sti %g30, %g1, 0
	fldi %f2, %g1, 0

	fjlt %f2, %f0, FLOOR_POSITIVE_RET
FLOOR_POSITIVE_MAIN:
	fmov %f1, %f0
	fadd %f0, %f0, %f2
	fsti %f0, %g1, 0
	ldi %g4, %g1, 0
	fsub %f0, %f0, %f2
	fsti %f0, %g1, 0
	ldi %g4, %g1, 0
	fjlt %f1, %f0, FLOOR_POSITIVE_RET
	return
FLOOR_POSITIVE_RET:
	! %f3 <- 1.0
	! fset %f3, 1.0
	mvhi %g30, 16256
	mvlo %g30, 0
	sti %g30, %g1, 0
	fldi %f3, %g1, 0

	fsub %f0, %f0, %f3
	return
FLOOR_NEGATIVE:
	fneg %f0, %f0
	! %f2 <- 8388608.0(0x4b000000)
	mvhi %g30, 19200
	mvlo %g30, 0
	sti %g30, %g1, 0
	fldi %f2, %g1, 0

	fjlt %f2, %f0, FLOOR_NEGATIVE_RET
FLOOR_NEGATIVE_MAIN:
	fadd %f0, %f0, %f2
	fsub %f0, %f0, %f2
	fneg %f1, %f1
	fjlt %f0, %f1, FLOOR_NEGATIVE_PRE_RET
	jmp FLOOR_NEGATIVE_RET
FLOOR_NEGATIVE_PRE_RET:
	fadd %f0, %f0, %f2
	! %f3 <- 1.0
	! fset %f3, 1.0
	mvhi %g30, 16256
	mvlo %g30, 0
	sti %g30, %g1, 0
	fldi %f3, %g1, 0

	fadd %f0, %f0, %f3
	fsub %f0, %f0, %f2
FLOOR_NEGATIVE_RET:
	fneg %f0, %f0
	return
	
min_caml_ceil:
	fneg %f0, %f0
	call min_caml_floor
	fneg %f0, %f0
	return

! * float_of_int
min_caml_float_of_int:
	jlt %g3, %g0, ITOF_NEGATIVE_MAIN		! if (%g0 <= %g3) goto ITOF_MAIN
ITOF_MAIN:
	! %f1 <- 8388608.0(0x4b000000)
	mvhi %g30, 19200
	mvlo %g30, 0
	sti %g30, %g1, 0
	fldi %f1, %g1, 0

	! %g4 <- 0x4b000000
	mvhi %g4, 19200
	mvlo %g4, 0
	! %g5 <- 0x00800000
	mvhi %g5, 128
	mvlo %g5, 0
	jlt %g3, %g5, ITOF_SMALL
ITOF_BIG:
	! %f2 <- 0.0
	! fset %f2, 0.0
	mvhi %g30, 0
	mvlo %g30, 0
	sti %g30, %g1, 0
	fldi %f2, %g1, 0

ITOF_LOOP:
	sub %g3, %g3, %g5
	fadd %f2, %f2, %f1
	jlt %g3, %g5, ITOF_RET
	jmp ITOF_LOOP
ITOF_RET:
	add %g3, %g3, %g4
	sti %g3, %g1, 0
	fldi  %f0, %g1, 0
	fsub %f0, %f0, %f1
	fadd %f0, %f0, %f2
	return
ITOF_SMALL:
	add %g3, %g3, %g4
	sti %g3, %g1, 0
	fldi  %f0, %g1, 0
	fsub %f0, %f0, %f1
	return
ITOF_NEGATIVE_MAIN:
	sub %g3, %g0, %g3

	call ITOF_MAIN

	fneg %f0, %f0
	return

! * int_of_float
min_caml_int_of_float:
	! %f1 <- 0.0
	! fset %f1, 0.0
	mvhi %g30, 0
	mvlo %g30, 0
	sti %g30, %g1, 0
	fldi %f1, %g1, 0

	fjlt %f0, %f1, FTOI_NEGATIVE_MAIN			! if (0.0 <= %f0) goto FTOI_MAIN
FTOI_POSITIVE_MAIN:
	call min_caml_floor
	! %f2 <- 8388608.0(0x4b000000)
	mvhi %g30, 19200
	mvlo %g30, 0
	sti %g30, %g1, 0
	fldi %f2, %g1, 0

	! %g4 <- 0x4b000000
	mvhi %g4, 19200
	mvlo %g4, 0
	fjlt %f0, %f2, FTOI_SMALL		! if (MAGICF <= %f0) goto FTOI_BIG
	! %g5 <- 0x00800000
	mvhi %g5, 128
	mvlo %g5, 0
	mov %g3, %g0
FTOI_LOOP:
	fsub %f0, %f0, %f2
	add %g3, %g3, %g5
	fjlt %f0, %f2, FTOI_RET
	jmp FTOI_LOOP
FTOI_RET:
	fadd %f0, %f0, %f2
	fsti %f0, %g1, 0
	ldi %g5, %g1, 0
	sub %g5, %g5, %g4
	add %g3, %g5, %g3
	return
FTOI_SMALL:
	fadd %f0, %f0, %f2
	fsti %f0, %g1, 0
	ldi %g3, %g1, 0
	sub %g3, %g3, %g4
	return
FTOI_NEGATIVE_MAIN:
	fneg %f0, %f0
	call FTOI_POSITIVE_MAIN
	sub %g3, %g0, %g3
	return
	
! * truncate
min_caml_truncate:
	jmp min_caml_int_of_float
	
! ビッグエンディアン
min_caml_read_int:
	add %g3, %g0, %g0
	! 24 - 31
	input %g4
	add %g3, %g3, %g4
	slli %g3, %g3, 8
	! 16 - 23
	input %g4
	add %g3, %g3, %g4
	slli %g3, %g3, 8
	! 8 - 15
	input %g4
	add %g3, %g3, %g4
	slli %g3, %g3, 8
	! 0 - 7
	input %g4
	add %g3, %g3, %g4
	return

min_caml_read_float:
	call min_caml_read_int
	sti %g3, %g1, 0
	fldi  %f0, %g1, 0
	return

!----------------------------------------------------------------------
!
! lib_asm.s
!
!----------------------------------------------------------------------


min_caml_start:
	mvhi	%g2, 0
	mvlo	%g2, 1724
	addi	%g28, %g0, 1
	sub	%g29, %g0, %g28
	! 0.000000
	addi	%g30, %g0, 0
	sti	%g30, %g1, 4
	fldi	%f16, %g1, 4
	! 1.000000
	mvhi	%g30, 16256
	mvlo	%g30, 0
	sti	%g30, %g1, 4
	fldi	%f17, %g1, 4
	! 255.000000
	mvhi	%g30, 17279
	mvlo	%g30, 0
	sti	%g30, %g1, 4
	fldi	%f18, %g1, 4
	! 0.500000
	mvhi	%g30, 16128
	mvlo	%g30, 0
	sti	%g30, %g1, 4
	fldi	%f19, %g1, 4
	! 2.000000
	mvhi	%g30, 16384
	mvlo	%g30, 0
	sti	%g30, %g1, 4
	fldi	%f20, %g1, 4
	! -1.000000
	mvhi	%g30, 49024
	mvlo	%g30, 0
	sti	%g30, %g1, 4
	fldi	%f21, %g1, 4
	! 1000000000.000000
	mvhi	%g30, 20078
	mvlo	%g30, 27432
	sti	%g30, %g1, 4
	fldi	%f22, %g1, 4
	! 0.100000
	mvhi	%g30, 15820
	mvlo	%g30, 52420
	sti	%g30, %g1, 4
	fldi	%f23, %g1, 4
	! 3.141593
	mvhi	%g30, 16457
	mvlo	%g30, 4058
	sti	%g30, %g1, 4
	fldi	%f24, %g1, 4
	! -0.100000
	mvhi	%g30, 48588
	mvlo	%g30, 52420
	sti	%g30, %g1, 4
	fldi	%f25, %g1, 4
	! 0.010000
	mvhi	%g30, 15395
	mvlo	%g30, 55050
	sti	%g30, %g1, 4
	fldi	%f26, %g1, 4
	! 1.570796
	mvhi	%g30, 16329
	mvlo	%g30, 4058
	sti	%g30, %g1, 4
	fldi	%f27, %g1, 4
	! 0.900000
	mvhi	%g30, 16230
	mvlo	%g30, 26206
	sti	%g30, %g1, 4
	fldi	%f28, %g1, 4
	! 0.200000
	mvhi	%g30, 15948
	mvlo	%g30, 52420
	sti	%g30, %g1, 4
	fldi	%f29, %g1, 4
	! 15.000000
	mvhi	%g30, 16752
	mvlo	%g30, 0
	sti	%g30, %g1, 4
	fldi	%f30, %g1, 4
	! 30.000000
	mvhi	%g30, 16880
	mvlo	%g30, 0
	sti	%g30, %g1, 4
	fldi	%f31, %g1, 4
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1716
	subi	%g1, %g1, 4
	call	min_caml_create_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1712
	call	min_caml_create_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1708
	call	min_caml_create_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1704
	call	min_caml_create_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 1
	addi	%g4, %g0, 1
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1700
	call	min_caml_create_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1696
	call	min_caml_create_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1692
	call	min_caml_create_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 0
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1688
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g4, %g3
	ldi	%g2, %g0, -1724
	addi	%g6, %g0, 60
	addi	%g10, %g0, 0
	addi	%g9, %g0, 0
	addi	%g8, %g0, 0
	addi	%g7, %g0, 0
	addi	%g5, %g0, 0
	mov	%g3, %g2
	addi	%g2, %g2, 44
	sti	%g4, %g3, -40
	sti	%g4, %g3, -36
	sti	%g4, %g3, -32
	sti	%g4, %g3, -28
	sti	%g5, %g3, -24
	sti	%g4, %g3, -20
	sti	%g4, %g3, -16
	sti	%g7, %g3, -12
	sti	%g8, %g3, -8
	sti	%g9, %g3, -4
	sti	%g10, %g3, 0
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1448
	mov	%g4, %g3
	mov	%g3, %g6
	call	min_caml_create_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 3
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1436
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 3
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1424
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 3
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1412
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 1
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1408
	fmov	%f0, %f18
	call	min_caml_create_float_array
	ldi	%g2, %g0, -1724
	addi	%g6, %g0, 50
	addi	%g3, %g0, 1
	addi	%g4, %g0, -1
	call	min_caml_create_array
	mov	%g4, %g3
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1208
	mov	%g3, %g6
	call	min_caml_create_array
	ldi	%g2, %g0, -1724
	addi	%g6, %g0, 1
	addi	%g3, %g0, 1
	ldi	%g4, %g0, -1208
	call	min_caml_create_array
	mov	%g4, %g3
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1204
	mov	%g3, %g6
	call	min_caml_create_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 1
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1200
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1196
	call	min_caml_create_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 1
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1192
	fmov	%f0, %f22
	call	min_caml_create_float_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 3
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1180
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1176
	call	min_caml_create_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 3
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1164
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 3
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1152
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 3
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1140
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 3
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1128
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 2
	addi	%g4, %g0, 0
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1120
	call	min_caml_create_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 2
	addi	%g4, %g0, 0
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1112
	call	min_caml_create_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 1
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1108
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 3
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1096
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 3
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1084
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 3
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1072
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 3
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1060
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 3
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1048
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 3
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1036
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 0
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1032
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g7, %g3
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 0
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1028
	subi	%g4, %g0, -1032
	call	min_caml_create_array
	mov	%g4, %g3
	ldi	%g2, %g0, -1724
	addi	%g6, %g0, 0
	mov	%g3, %g2
	addi	%g2, %g2, 8
	sti	%g4, %g3, -4
	sti	%g7, %g3, 0
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1024
	mov	%g4, %g3
	mov	%g3, %g6
	call	min_caml_create_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 5
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1004
	subi	%g4, %g0, -1024
	call	min_caml_create_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 0
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 1000
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 3
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 988
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g6, %g3
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 60
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 748
	subi	%g4, %g0, -1000
	call	min_caml_create_array
	mov	%g4, %g3
	ldi	%g2, %g0, -1724
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 740
	mov	%g3, %g2
	addi	%g2, %g2, 8
	sti	%g4, %g3, -4
	sti	%g6, %g3, 0
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 0
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 736
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g6, %g3
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 0
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 732
	subi	%g4, %g0, -736
	call	min_caml_create_array
	ldi	%g2, %g0, -1724
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 724
	mov	%g4, %g2
	addi	%g2, %g2, 8
	sti	%g3, %g4, -4
	sti	%g6, %g4, 0
	ldi	%g2, %g0, -1724
	addi	%g6, %g0, 180
	addi	%g5, %g0, 0
	mov	%g3, %g2
	addi	%g2, %g2, 12
	fsti	%f16, %g3, -8
	sti	%g4, %g3, -4
	sti	%g5, %g3, 0
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 4
	mov	%g4, %g3
	mov	%g3, %g6
	call	min_caml_create_array
	ldi	%g2, %g0, -1724
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g0, -1724
	addi	%g2, %g0, 0
	call	min_caml_create_array
	ldi	%g2, %g0, -1724
	addi	%g6, %g0, 128
	addi	%g3, %g0, 128
	call	rt.3134
	addi	%g1, %g1, 4
	addi	%g0, %g0, 0
	halt

!---------------------------------------------------------------------
! args = []
! fargs = [%f1, %f0]
! ret type = Bool
!---------------------------------------------------------------------
fless.2546:
	fjlt	%f1, %f0, fjge_else.7652
	addi	%g3, %g0, 0
	return
fjge_else.7652:
	addi	%g3, %g0, 1
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f0]
! ret type = Bool
!---------------------------------------------------------------------
fispos.2549:
	fjlt	%f16, %f0, fjge_else.7653
	addi	%g3, %g0, 0
	return
fjge_else.7653:
	addi	%g3, %g0, 1
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f0]
! ret type = Bool
!---------------------------------------------------------------------
fisneg.2551:
	fjlt	%f0, %f16, fjge_else.7654
	addi	%g3, %g0, 0
	return
fjge_else.7654:
	addi	%g3, %g0, 1
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f0]
! ret type = Bool
!---------------------------------------------------------------------
fiszero.2553:
	fjeq	%f0, %f16, fjne_else.7655
	addi	%g3, %g0, 0
	return
fjne_else.7655:
	addi	%g3, %g0, 1
	return

!---------------------------------------------------------------------
! args = [%g4, %g3]
! fargs = []
! ret type = Bool
!---------------------------------------------------------------------
xor.2555:
	jeq	%g4, %g3, jne_else.7656
	addi	%g3, %g0, 1
	return
jne_else.7656:
	addi	%g3, %g0, 0
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f1]
! ret type = Float
!---------------------------------------------------------------------
fabs.2558:
	fjlt	%f1, %f16, fjge_else.7657
	fmov	%f0, %f1
	return
fjge_else.7657:
	fneg	%f0, %f1
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f0]
! ret type = Float
!---------------------------------------------------------------------
fneg.2562:
	fneg	%f0, %f0
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f0]
! ret type = Float
!---------------------------------------------------------------------
fhalf.2564:
	fmul	%f0, %f0, %f19
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f0]
! ret type = Float
!---------------------------------------------------------------------
fsqr.2566:
	fmul	%f0, %f0, %f0
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f2, %f3, %f1]
! ret type = Float
!---------------------------------------------------------------------
atan_sub.2571:
	fjlt	%f2, %f19, fjge_else.7658
	fsub	%f0, %f2, %f17
	fmul	%f4, %f2, %f2
	fmul	%f4, %f4, %f3
	fadd	%f2, %f2, %f2
	fadd	%f2, %f2, %f17
	fadd	%f1, %f2, %f1
	fdiv	%f1, %f4, %f1
	fmov	%f2, %f0
	jmp	atan_sub.2571
fjge_else.7658:
	fmov	%f0, %f1
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f0]
! ret type = Float
!---------------------------------------------------------------------
atan.2575:
	fjlt	%f17, %f0, fjge_else.7659
	fjlt	%f0, %f21, fjge_else.7661
	addi	%g3, %g0, 0
	jmp	fjge_cont.7662
fjge_else.7661:
	addi	%g3, %g0, -1
fjge_cont.7662:
	jmp	fjge_cont.7660
fjge_else.7659:
	addi	%g3, %g0, 1
fjge_cont.7660:
	jeq	%g3, %g0, jne_else.7663
	fdiv	%f5, %f17, %f0
	jmp	jne_cont.7664
jne_else.7663:
	fmov	%f5, %f0
jne_cont.7664:
	! 11.000000
	mvhi	%g30, 16688
	mvlo	%g30, 0
	sti	%g30, %g1, 4
	fldi	%f2, %g1, 4
	fmul	%f3, %f5, %f5
	fmov	%f1, %f16
	subi	%g1, %g1, 4
	call	atan_sub.2571
	addi	%g1, %g1, 4
	fadd	%f0, %f17, %f0
	fdiv	%f1, %f5, %f0
	jlt	%g0, %g3, jle_else.7665
	jlt	%g3, %g0, jge_else.7666
	fmov	%f0, %f1
	return
jge_else.7666:
	! -1.570796
	mvhi	%g30, 49097
	mvlo	%g30, 4058
	sti	%g30, %g1, 4
	fldi	%f0, %g1, 4
	fsub	%f0, %f0, %f1
	return
jle_else.7665:
	fsub	%f0, %f27, %f1
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f2, %f3, %f1]
! ret type = Float
!---------------------------------------------------------------------
tan_sub.6310:
	! 2.500000
	mvhi	%g30, 16416
	mvlo	%g30, 0
	sti	%g30, %g1, 4
	fldi	%f0, %g1, 4
	fjlt	%f2, %f0, fjge_else.7667
	fsub	%f0, %f2, %f20
	fsub	%f1, %f2, %f1
	fdiv	%f1, %f3, %f1
	fmov	%f2, %f0
	jmp	tan_sub.6310
fjge_else.7667:
	fmov	%f0, %f1
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f0]
! ret type = Float
!---------------------------------------------------------------------
tan.2577:
	! 9.000000
	mvhi	%g30, 16656
	mvlo	%g30, 0
	sti	%g30, %g1, 4
	fldi	%f2, %g1, 4
	fmul	%f3, %f0, %f0
	fsti	%f0, %g1, 0
	fmov	%f1, %f16
	subi	%g1, %g1, 8
	call	tan_sub.6310
	addi	%g1, %g1, 8
	fmov	%f1, %f0
	fsub	%f1, %f17, %f1
	fldi	%f0, %g1, 0
	fdiv	%f0, %f0, %f1
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f1]
! ret type = Float
!---------------------------------------------------------------------
sin_sub.2579:
	! 6.283185
	mvhi	%g30, 16585
	mvlo	%g30, 4058
	sti	%g30, %g1, 4
	fldi	%f2, %g1, 4
	fjlt	%f2, %f1, fjge_else.7668
	fjlt	%f1, %f16, fjge_else.7669
	fmov	%f0, %f1
	return
fjge_else.7669:
	fadd	%f1, %f1, %f2
	jmp	sin_sub.2579
fjge_else.7668:
	fsub	%f1, %f1, %f2
	jmp	sin_sub.2579

!---------------------------------------------------------------------
! args = []
! fargs = [%f3]
! ret type = Float
!---------------------------------------------------------------------
sin.2581:
	! 3.141593
	mvhi	%g30, 16457
	mvlo	%g30, 4058
	sti	%g30, %g1, 4
	fldi	%f4, %g1, 4
	! 6.283185
	mvhi	%g30, 16585
	mvlo	%g30, 4058
	sti	%g30, %g1, 4
	fldi	%f5, %g1, 4
	fmov	%f1, %f3
	subi	%g1, %g1, 4
	call	fabs.2558
	fmov	%f1, %f0
	call	sin_sub.2579
	addi	%g1, %g1, 4
	fjlt	%f4, %f0, fjge_else.7670
	fjlt	%f16, %f3, fjge_else.7672
	addi	%g3, %g0, 0
	jmp	fjge_cont.7673
fjge_else.7672:
	addi	%g3, %g0, 1
fjge_cont.7673:
	jmp	fjge_cont.7671
fjge_else.7670:
	fjlt	%f16, %f3, fjge_else.7674
	addi	%g3, %g0, 1
	jmp	fjge_cont.7675
fjge_else.7674:
	addi	%g3, %g0, 0
fjge_cont.7675:
fjge_cont.7671:
	fjlt	%f4, %f0, fjge_else.7676
	fmov	%f1, %f0
	jmp	fjge_cont.7677
fjge_else.7676:
	fsub	%f1, %f5, %f0
fjge_cont.7677:
	fjlt	%f27, %f1, fjge_else.7678
	fmov	%f0, %f1
	jmp	fjge_cont.7679
fjge_else.7678:
	fsub	%f0, %f4, %f1
fjge_cont.7679:
	fmul	%f0, %f0, %f19
	subi	%g1, %g1, 4
	call	tan.2577
	addi	%g1, %g1, 4
	fmul	%f1, %f20, %f0
	fmul	%f0, %f0, %f0
	fadd	%f0, %f17, %f0
	fdiv	%f1, %f1, %f0
	jeq	%g3, %g0, jne_else.7680
	fmov	%f0, %f1
	return
jne_else.7680:
	fmov	%f0, %f1
	jmp	fneg.2562

!---------------------------------------------------------------------
! args = []
! fargs = [%f0]
! ret type = Float
!---------------------------------------------------------------------
cos.2583:
	fsub	%f3, %f27, %f0
	jmp	sin.2581

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
mul10.2585:
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	return

!---------------------------------------------------------------------
! args = [%g5, %g4]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
read_int_token.2589:
	input	%g6
	addi	%g3, %g0, 48
	jlt	%g6, %g3, jle_else.7681
	addi	%g3, %g0, 57
	jlt	%g3, %g6, jle_else.7683
	addi	%g3, %g0, 0
	jmp	jle_cont.7684
jle_else.7683:
	addi	%g3, %g0, 1
jle_cont.7684:
	jmp	jle_cont.7682
jle_else.7681:
	addi	%g3, %g0, 1
jle_cont.7682:
	jeq	%g3, %g0, jne_else.7685
	jeq	%g5, %g0, jne_else.7686
	ldi	%g3, %g0, -1712
	jeq	%g3, %g28, jne_else.7687
	ldi	%g3, %g0, -1716
	sub	%g3, %g0, %g3
	return
jne_else.7687:
	ldi	%g3, %g0, -1716
	return
jne_else.7686:
	addi	%g5, %g0, 0
	mov	%g4, %g6
	jmp	read_int_token.2589
jne_else.7685:
	ldi	%g3, %g0, -1712
	jeq	%g3, %g0, jne_else.7688
	jmp	jne_cont.7689
jne_else.7688:
	addi	%g3, %g0, 45
	jeq	%g4, %g3, jne_else.7690
	addi	%g3, %g0, 1
	sti	%g3, %g0, -1712
	jmp	jne_cont.7691
jne_else.7690:
	addi	%g3, %g0, -1
	sti	%g3, %g0, -1712
jne_cont.7691:
jne_cont.7689:
	ldi	%g3, %g0, -1716
	subi	%g1, %g1, 4
	call	mul10.2585
	addi	%g1, %g1, 4
	subi	%g4, %g6, 48
	add	%g3, %g3, %g4
	sti	%g3, %g0, -1716
	addi	%g5, %g0, 1
	mov	%g4, %g6
	jmp	read_int_token.2589

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
read_int.2592:
	addi	%g3, %g0, 0
	sti	%g3, %g0, -1716
	addi	%g3, %g0, 0
	sti	%g3, %g0, -1712
	addi	%g5, %g0, 0
	addi	%g4, %g0, 32
	jmp	read_int_token.2589

!---------------------------------------------------------------------
! args = [%g6, %g4]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
read_float_token1.2598:
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.7692
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.7694
	addi	%g3, %g0, 0
	jmp	jle_cont.7695
jle_else.7694:
	addi	%g3, %g0, 1
jle_cont.7695:
	jmp	jle_cont.7693
jle_else.7692:
	addi	%g3, %g0, 1
jle_cont.7693:
	jeq	%g3, %g0, jne_else.7696
	jeq	%g6, %g0, jne_else.7697
	mov	%g3, %g5
	return
jne_else.7697:
	addi	%g6, %g0, 0
	mov	%g4, %g5
	jmp	read_float_token1.2598
jne_else.7696:
	ldi	%g3, %g0, -1696
	jeq	%g3, %g0, jne_else.7698
	jmp	jne_cont.7699
jne_else.7698:
	addi	%g3, %g0, 45
	jeq	%g4, %g3, jne_else.7700
	addi	%g3, %g0, 1
	sti	%g3, %g0, -1696
	jmp	jne_cont.7701
jne_else.7700:
	addi	%g3, %g0, -1
	sti	%g3, %g0, -1696
jne_cont.7701:
jne_cont.7699:
	ldi	%g3, %g0, -1708
	subi	%g1, %g1, 4
	call	mul10.2585
	addi	%g1, %g1, 4
	subi	%g4, %g5, 48
	add	%g3, %g3, %g4
	sti	%g3, %g0, -1708
	addi	%g6, %g0, 1
	mov	%g4, %g5
	jmp	read_float_token1.2598

!---------------------------------------------------------------------
! args = [%g4]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
read_float_token2.2601:
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.7702
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.7704
	addi	%g3, %g0, 0
	jmp	jle_cont.7705
jle_else.7704:
	addi	%g3, %g0, 1
jle_cont.7705:
	jmp	jle_cont.7703
jle_else.7702:
	addi	%g3, %g0, 1
jle_cont.7703:
	jeq	%g3, %g0, jne_else.7706
	jeq	%g4, %g0, jne_else.7707
	return
jne_else.7707:
	addi	%g4, %g0, 0
	jmp	read_float_token2.2601
jne_else.7706:
	ldi	%g3, %g0, -1704
	subi	%g1, %g1, 4
	call	mul10.2585
	subi	%g4, %g5, 48
	add	%g3, %g3, %g4
	sti	%g3, %g0, -1704
	ldi	%g3, %g0, -1700
	call	mul10.2585
	addi	%g1, %g1, 4
	sti	%g3, %g0, -1700
	addi	%g4, %g0, 1
	jmp	read_float_token2.2601

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
read_float.2603:
	addi	%g3, %g0, 0
	sti	%g3, %g0, -1708
	addi	%g3, %g0, 0
	sti	%g3, %g0, -1704
	addi	%g3, %g0, 1
	sti	%g3, %g0, -1700
	addi	%g3, %g0, 0
	sti	%g3, %g0, -1696
	addi	%g6, %g0, 0
	addi	%g4, %g0, 32
	subi	%g1, %g1, 4
	call	read_float_token1.2598
	addi	%g1, %g1, 4
	addi	%g4, %g0, 46
	jeq	%g3, %g4, jne_else.7709
	ldi	%g3, %g0, -1708
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fmov	%f1, %f0
	jmp	jne_cont.7710
jne_else.7709:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2601
	ldi	%g3, %g0, -1708
	call	min_caml_float_of_int
	fmov	%f4, %f0
	ldi	%g3, %g0, -1704
	call	min_caml_float_of_int
	fmov	%f3, %f0
	ldi	%g3, %g0, -1700
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f1, %f3, %f0
	fadd	%f1, %f4, %f1
jne_cont.7710:
	ldi	%g3, %g0, -1696
	jeq	%g3, %g28, jne_else.7711
	fneg	%f0, %f1
	return
jne_else.7711:
	fmov	%f0, %f1
	return

!---------------------------------------------------------------------
! args = [%g8, %g7, %g5, %g6]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
div_binary_search.2611:
	add	%g3, %g5, %g6
	srli	%g4, %g3, 1
	mul	%g9, %g4, %g7
	sub	%g3, %g6, %g5
	jlt	%g28, %g3, jle_else.7712
	mov	%g3, %g5
	return
jle_else.7712:
	jlt	%g9, %g8, jle_else.7713
	jeq	%g9, %g8, jne_else.7714
	mov	%g6, %g4
	jmp	div_binary_search.2611
jne_else.7714:
	mov	%g3, %g4
	return
jle_else.7713:
	mov	%g5, %g4
	jmp	div_binary_search.2611

!---------------------------------------------------------------------
! args = [%g8]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
print_int.2623:
	jlt	%g8, %g0, jge_else.7715
	mvhi	%g7, 1525
	mvlo	%g7, 57600
	addi	%g5, %g0, 0
	addi	%g6, %g0, 3
	sti	%g8, %g1, 0
	subi	%g1, %g1, 8
	call	div_binary_search.2611
	addi	%g1, %g1, 8
	mvhi	%g4, 1525
	mvlo	%g4, 57600
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 0
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.7716
	addi	%g10, %g0, 0
	jmp	jle_cont.7717
jle_else.7716:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jle_cont.7717:
	mvhi	%g7, 152
	mvlo	%g7, 38528
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 4
	subi	%g1, %g1, 12
	call	div_binary_search.2611
	addi	%g1, %g1, 12
	mvhi	%g4, 152
	mvlo	%g4, 38528
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 4
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.7718
	jeq	%g10, %g0, jne_else.7720
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
	jmp	jne_cont.7721
jne_else.7720:
	addi	%g11, %g0, 0
jne_cont.7721:
	jmp	jle_cont.7719
jle_else.7718:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jle_cont.7719:
	mvhi	%g7, 15
	mvlo	%g7, 16960
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 8
	subi	%g1, %g1, 16
	call	div_binary_search.2611
	addi	%g1, %g1, 16
	mvhi	%g4, 15
	mvlo	%g4, 16960
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 8
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.7722
	jeq	%g11, %g0, jne_else.7724
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
	jmp	jne_cont.7725
jne_else.7724:
	addi	%g10, %g0, 0
jne_cont.7725:
	jmp	jle_cont.7723
jle_else.7722:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jle_cont.7723:
	mvhi	%g7, 1
	mvlo	%g7, 34464
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 12
	subi	%g1, %g1, 20
	call	div_binary_search.2611
	addi	%g1, %g1, 20
	mvhi	%g4, 1
	mvlo	%g4, 34464
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 12
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.7726
	jeq	%g10, %g0, jne_else.7728
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
	jmp	jne_cont.7729
jne_else.7728:
	addi	%g11, %g0, 0
jne_cont.7729:
	jmp	jle_cont.7727
jle_else.7726:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jle_cont.7727:
	addi	%g7, %g0, 10000
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 16
	subi	%g1, %g1, 24
	call	div_binary_search.2611
	addi	%g1, %g1, 24
	addi	%g4, %g0, 10000
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 16
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.7730
	jeq	%g11, %g0, jne_else.7732
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
	jmp	jne_cont.7733
jne_else.7732:
	addi	%g10, %g0, 0
jne_cont.7733:
	jmp	jle_cont.7731
jle_else.7730:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jle_cont.7731:
	addi	%g7, %g0, 1000
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 20
	subi	%g1, %g1, 28
	call	div_binary_search.2611
	addi	%g1, %g1, 28
	muli	%g4, %g3, 1000
	ldi	%g8, %g1, 20
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.7734
	jeq	%g10, %g0, jne_else.7736
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
	jmp	jne_cont.7737
jne_else.7736:
	addi	%g11, %g0, 0
jne_cont.7737:
	jmp	jle_cont.7735
jle_else.7734:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jle_cont.7735:
	addi	%g7, %g0, 100
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 24
	subi	%g1, %g1, 32
	call	div_binary_search.2611
	addi	%g1, %g1, 32
	muli	%g4, %g3, 100
	ldi	%g8, %g1, 24
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.7738
	jeq	%g11, %g0, jne_else.7740
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
	jmp	jne_cont.7741
jne_else.7740:
	addi	%g10, %g0, 0
jne_cont.7741:
	jmp	jle_cont.7739
jle_else.7738:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jle_cont.7739:
	addi	%g7, %g0, 10
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 28
	subi	%g1, %g1, 36
	call	div_binary_search.2611
	addi	%g1, %g1, 36
	muli	%g4, %g3, 10
	ldi	%g8, %g1, 28
	sub	%g4, %g8, %g4
	jlt	%g0, %g3, jle_else.7742
	jeq	%g10, %g0, jne_else.7744
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g5, %g0, 1
	jmp	jne_cont.7745
jne_else.7744:
	addi	%g5, %g0, 0
jne_cont.7745:
	jmp	jle_cont.7743
jle_else.7742:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g5, %g0, 1
jle_cont.7743:
	addi	%g3, %g0, 48
	add	%g3, %g3, %g4
	output	%g3
	return
jge_else.7715:
	addi	%g3, %g0, 45
	output	%g3
	sub	%g8, %g0, %g8
	jmp	print_int.2623

!---------------------------------------------------------------------
! args = []
! fargs = [%f1]
! ret type = Float
!---------------------------------------------------------------------
sgn.2655:
	fmov	%f0, %f1
	subi	%g1, %g1, 4
	call	fiszero.2553
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7746
	fmov	%f0, %f16
	return
jne_else.7746:
	fmov	%f0, %f1
	subi	%g1, %g1, 4
	call	fispos.2549
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7747
	fmov	%f0, %f17
	return
jne_else.7747:
	fmov	%f0, %f21
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = [%f1]
! ret type = Float
!---------------------------------------------------------------------
fneg_cond.2657:
	jeq	%g3, %g0, jne_else.7748
	fmov	%f0, %f1
	return
jne_else.7748:
	fmov	%f0, %f1
	jmp	fneg.2562

!---------------------------------------------------------------------
! args = [%g4, %g3]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
add_mod5.2660:
	add	%g4, %g4, %g3
	addi	%g3, %g0, 5
	jlt	%g4, %g3, jle_else.7749
	subi	%g3, %g4, 5
	return
jle_else.7749:
	mov	%g3, %g4
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = [%f2, %f1, %f0]
! ret type = Unit
!---------------------------------------------------------------------
vecset.2663:
	fsti	%f2, %g3, 0
	fsti	%f1, %g3, -4
	fsti	%f0, %g3, -8
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = [%f0]
! ret type = Unit
!---------------------------------------------------------------------
vecfill.2668:
	fsti	%f0, %g3, 0
	fsti	%f0, %g3, -4
	fsti	%f0, %g3, -8
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
vecbzero.2671:
	fmov	%f0, %f16
	jmp	vecfill.2668

!---------------------------------------------------------------------
! args = [%g4, %g3]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
veccpy.2673:
	fldi	%f0, %g3, 0
	fsti	%f0, %g4, 0
	fldi	%f0, %g3, -4
	fsti	%f0, %g4, -4
	fldi	%f0, %g3, -8
	fsti	%f0, %g4, -8
	return

!---------------------------------------------------------------------
! args = [%g4, %g5]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
vecunit_sgn.2681:
	fldi	%f1, %g4, 0
	fmov	%f0, %f1
	subi	%g1, %g1, 4
	call	fsqr.2566
	fmov	%f2, %f0
	fldi	%f0, %g4, -4
	call	fsqr.2566
	fadd	%f2, %f2, %f0
	fldi	%f0, %g4, -8
	call	fsqr.2566
	fadd	%f0, %f2, %f0
	fsqrt	%f2, %f0
	fmov	%f0, %f2
	call	fiszero.2553
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7753
	fmov	%f0, %f17
	jmp	jne_cont.7754
jne_else.7753:
	jeq	%g5, %g0, jne_else.7755
	fdiv	%f0, %f21, %f2
	jmp	jne_cont.7756
jne_else.7755:
	fdiv	%f0, %f17, %f2
jne_cont.7756:
jne_cont.7754:
	fmul	%f1, %f1, %f0
	fsti	%f1, %g4, 0
	fldi	%f1, %g4, -4
	fmul	%f1, %f1, %f0
	fsti	%f1, %g4, -4
	fldi	%f1, %g4, -8
	fmul	%f0, %f1, %f0
	fsti	%f0, %g4, -8
	return

!---------------------------------------------------------------------
! args = [%g4, %g3]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
veciprod.2684:
	fldi	%f1, %g4, 0
	fldi	%f0, %g3, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g4, -4
	fldi	%f0, %g3, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g4, -8
	fldi	%f0, %g3, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = [%f2, %f1, %f0]
! ret type = Float
!---------------------------------------------------------------------
veciprod2.2687:
	fldi	%f3, %g3, 0
	fmul	%f3, %f3, %f2
	fldi	%f2, %g3, -4
	fmul	%f1, %f2, %f1
	fadd	%f2, %f3, %f1
	fldi	%f1, %g3, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	return

!---------------------------------------------------------------------
! args = [%g4, %g3]
! fargs = [%f0]
! ret type = Unit
!---------------------------------------------------------------------
vecaccum.2692:
	fldi	%f2, %g4, 0
	fldi	%f1, %g3, 0
	fmul	%f1, %f0, %f1
	fadd	%f1, %f2, %f1
	fsti	%f1, %g4, 0
	fldi	%f2, %g4, -4
	fldi	%f1, %g3, -4
	fmul	%f1, %f0, %f1
	fadd	%f1, %f2, %f1
	fsti	%f1, %g4, -4
	fldi	%f2, %g4, -8
	fldi	%f1, %g3, -8
	fmul	%f0, %f0, %f1
	fadd	%f0, %f2, %f0
	fsti	%f0, %g4, -8
	return

!---------------------------------------------------------------------
! args = [%g4, %g3]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
vecadd.2696:
	fldi	%f1, %g4, 0
	fldi	%f0, %g3, 0
	fadd	%f0, %f1, %f0
	fsti	%f0, %g4, 0
	fldi	%f1, %g4, -4
	fldi	%f0, %g3, -4
	fadd	%f0, %f1, %f0
	fsti	%f0, %g4, -4
	fldi	%f1, %g4, -8
	fldi	%f0, %g3, -8
	fadd	%f0, %f1, %f0
	fsti	%f0, %g4, -8
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = [%f0]
! ret type = Unit
!---------------------------------------------------------------------
vecscale.2702:
	fldi	%f1, %g3, 0
	fmul	%f1, %f1, %f0
	fsti	%f1, %g3, 0
	fldi	%f1, %g3, -4
	fmul	%f1, %f1, %f0
	fsti	%f1, %g3, -4
	fldi	%f1, %g3, -8
	fmul	%f0, %f1, %f0
	fsti	%f0, %g3, -8
	return

!---------------------------------------------------------------------
! args = [%g5, %g4, %g3]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
vecaccumv.2705:
	fldi	%f2, %g5, 0
	fldi	%f1, %g4, 0
	fldi	%f0, %g3, 0
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fsti	%f0, %g5, 0
	fldi	%f2, %g5, -4
	fldi	%f1, %g4, -4
	fldi	%f0, %g3, -4
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fsti	%f0, %g5, -4
	fldi	%f2, %g5, -8
	fldi	%f1, %g4, -8
	fldi	%f0, %g3, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fsti	%f0, %g5, -8
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
o_texturetype.2709:
	ldi	%g3, %g3, 0
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
o_form.2711:
	ldi	%g3, %g3, -4
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
o_reflectiontype.2713:
	ldi	%g3, %g3, -8
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Bool
!---------------------------------------------------------------------
o_isinvert.2715:
	ldi	%g3, %g3, -24
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
o_isrot.2717:
	ldi	%g3, %g3, -12
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_param_a.2719:
	ldi	%g3, %g3, -16
	fldi	%f0, %g3, 0
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_param_b.2721:
	ldi	%g3, %g3, -16
	fldi	%f0, %g3, -4
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_param_c.2723:
	ldi	%g3, %g3, -16
	fldi	%f0, %g3, -8
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Array(Float)
!---------------------------------------------------------------------
o_param_abc.2725:
	ldi	%g3, %g3, -16
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_param_x.2727:
	ldi	%g3, %g3, -20
	fldi	%f0, %g3, 0
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_param_y.2729:
	ldi	%g3, %g3, -20
	fldi	%f0, %g3, -4
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_param_z.2731:
	ldi	%g3, %g3, -20
	fldi	%f0, %g3, -8
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_diffuse.2733:
	ldi	%g3, %g3, -28
	fldi	%f0, %g3, 0
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_hilight.2735:
	ldi	%g3, %g3, -28
	fldi	%f0, %g3, -4
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_color_red.2737:
	ldi	%g3, %g3, -32
	fldi	%f0, %g3, 0
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_color_green.2739:
	ldi	%g3, %g3, -32
	fldi	%f0, %g3, -4
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_color_blue.2741:
	ldi	%g3, %g3, -32
	fldi	%f0, %g3, -8
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_param_r1.2743:
	ldi	%g3, %g3, -36
	fldi	%f0, %g3, 0
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_param_r2.2745:
	ldi	%g3, %g3, -36
	fldi	%f0, %g3, -4
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_param_r3.2747:
	ldi	%g3, %g3, -36
	fldi	%f0, %g3, -8
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Array(Float)
!---------------------------------------------------------------------
o_param_ctbl.2749:
	ldi	%g3, %g3, -40
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Array(Float)
!---------------------------------------------------------------------
p_rgb.2751:
	ldi	%g3, %g3, 0
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Array(Array(Float))
!---------------------------------------------------------------------
p_intersection_points.2753:
	ldi	%g3, %g3, -4
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Array(Int)
!---------------------------------------------------------------------
p_surface_ids.2755:
	ldi	%g3, %g3, -8
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Array(Bool)
!---------------------------------------------------------------------
p_calc_diffuse.2757:
	ldi	%g3, %g3, -12
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Array(Array(Float))
!---------------------------------------------------------------------
p_energy.2759:
	ldi	%g3, %g3, -16
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Array(Array(Float))
!---------------------------------------------------------------------
p_received_ray_20percent.2761:
	ldi	%g3, %g3, -20
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
p_group_id.2763:
	ldi	%g3, %g3, -24
	ldi	%g3, %g3, 0
	return

!---------------------------------------------------------------------
! args = [%g3, %g4]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
p_set_group_id.2765:
	ldi	%g3, %g3, -24
	sti	%g4, %g3, 0
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Array(Array(Float))
!---------------------------------------------------------------------
p_nvectors.2768:
	ldi	%g3, %g3, -28
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Array(Float)
!---------------------------------------------------------------------
d_vec.2770:
	ldi	%g3, %g3, 0
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Array(Array(Float))
!---------------------------------------------------------------------
d_const.2772:
	ldi	%g3, %g3, -4
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
r_surface_id.2774:
	ldi	%g3, %g3, 0
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = (Array(Float) * Array(Array(Float)))
!---------------------------------------------------------------------
r_dvec.2776:
	ldi	%g3, %g3, -4
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
r_bright.2778:
	fldi	%f0, %g3, -8
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f0]
! ret type = Float
!---------------------------------------------------------------------
rad.2780:
	! 0.017453
	mvhi	%g30, 15502
	mvlo	%g30, 64045
	sti	%g30, %g1, 4
	fldi	%f1, %g1, 4
	fmul	%f0, %f0, %f1
	return

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
read_screen_settings.2782:
	subi	%g1, %g1, 4
	call	read_float.2603
	fsti	%f0, %g0, -1436
	call	read_float.2603
	fsti	%f0, %g0, -1440
	call	read_float.2603
	fsti	%f0, %g0, -1444
	call	read_float.2603
	call	rad.2780
	addi	%g1, %g1, 4
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	cos.2583
	addi	%g1, %g1, 8
	fmov	%f7, %f0
	fldi	%f0, %g1, 0
	fmov	%f3, %f0
	subi	%g1, %g1, 8
	call	sin.2581
	fmov	%f8, %f0
	call	read_float.2603
	call	rad.2780
	addi	%g1, %g1, 8
	fsti	%f0, %g1, 4
	subi	%g1, %g1, 12
	call	cos.2583
	addi	%g1, %g1, 12
	fmov	%f6, %f0
	fldi	%f0, %g1, 4
	fmov	%f3, %f0
	subi	%g1, %g1, 12
	call	sin.2581
	addi	%g1, %g1, 12
	fmul	%f1, %f7, %f0
	! 200.000000
	mvhi	%g30, 17224
	mvlo	%g30, 0
	sti	%g30, %g1, 12
	fldi	%f2, %g1, 12
	fmul	%f1, %f1, %f2
	fsti	%f1, %g0, -1048
	! -200.000000
	mvhi	%g30, 49992
	mvlo	%g30, 0
	sti	%g30, %g1, 12
	fldi	%f1, %g1, 12
	fmul	%f1, %f8, %f1
	fsti	%f1, %g0, -1052
	fmul	%f1, %f7, %f6
	fmul	%f1, %f1, %f2
	fsti	%f1, %g0, -1056
	fsti	%f6, %g0, -1072
	fsti	%f16, %g0, -1076
	fsti	%f0, %g1, 8
	subi	%g1, %g1, 16
	call	fneg.2562
	fmov	%f1, %f0
	fsti	%f1, %g0, -1080
	fmov	%f0, %f8
	call	fneg.2562
	addi	%g1, %g1, 16
	fmov	%f1, %f0
	fldi	%f0, %g1, 8
	fmul	%f0, %f1, %f0
	fsti	%f0, %g0, -1060
	fmov	%f0, %f7
	subi	%g1, %g1, 16
	call	fneg.2562
	addi	%g1, %g1, 16
	fsti	%f0, %g0, -1064
	fmul	%f0, %f1, %f6
	fsti	%f0, %g0, -1068
	fldi	%f1, %g0, -1436
	fldi	%f0, %g0, -1048
	fsub	%f0, %f1, %f0
	fsti	%f0, %g0, -1424
	fldi	%f1, %g0, -1440
	fldi	%f0, %g0, -1052
	fsub	%f0, %f1, %f0
	fsti	%f0, %g0, -1428
	fldi	%f1, %g0, -1444
	fldi	%f0, %g0, -1056
	fsub	%f0, %f1, %f0
	fsti	%f0, %g0, -1432
	return

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
read_light.2784:
	subi	%g1, %g1, 4
	call	read_int.2592
	call	read_float.2603
	call	rad.2780
	fmov	%f7, %f0
	fmov	%f3, %f7
	call	sin.2581
	call	fneg.2562
	fsti	%f0, %g0, -1416
	call	read_float.2603
	call	rad.2780
	fmov	%f6, %f0
	fmov	%f0, %f7
	call	cos.2583
	fmov	%f7, %f0
	fmov	%f3, %f6
	call	sin.2581
	fmul	%f0, %f7, %f0
	fsti	%f0, %g0, -1412
	fmov	%f0, %f6
	call	cos.2583
	fmul	%f0, %f7, %f0
	fsti	%f0, %g0, -1420
	call	read_float.2603
	addi	%g1, %g1, 4
	fsti	%f0, %g0, -1408
	return

!---------------------------------------------------------------------
! args = [%g5, %g4]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
rotate_quadratic_matrix.2786:
	fldi	%f6, %g4, 0
	fmov	%f0, %f6
	subi	%g1, %g1, 4
	call	cos.2583
	fmov	%f9, %f0
	fmov	%f3, %f6
	call	sin.2581
	fmov	%f7, %f0
	fldi	%f6, %g4, -4
	fmov	%f0, %f6
	call	cos.2583
	fmov	%f8, %f0
	fmov	%f3, %f6
	call	sin.2581
	fmov	%f10, %f0
	fldi	%f11, %g4, -8
	fmov	%f0, %f11
	call	cos.2583
	fmov	%f6, %f0
	fmov	%f3, %f11
	call	sin.2581
	addi	%g1, %g1, 4
	fmul	%f1, %f8, %f6
	fsti	%f1, %g1, 0
	fmul	%f4, %f7, %f10
	fmul	%f2, %f4, %f6
	fmul	%f1, %f9, %f0
	fsub	%f13, %f2, %f1
	fmul	%f1, %f9, %f10
	fmul	%f3, %f1, %f6
	fmul	%f2, %f7, %f0
	fadd	%f11, %f3, %f2
	fmul	%f14, %f8, %f0
	fmul	%f3, %f4, %f0
	fmul	%f2, %f9, %f6
	fadd	%f12, %f3, %f2
	fmul	%f1, %f1, %f0
	fmul	%f0, %f7, %f6
	fsub	%f5, %f1, %f0
	fmov	%f0, %f10
	subi	%g1, %g1, 8
	call	fneg.2562
	addi	%g1, %g1, 8
	fmov	%f10, %f0
	fmul	%f6, %f7, %f8
	fmul	%f4, %f9, %f8
	fldi	%f1, %g5, 0
	fldi	%f2, %g5, -4
	fldi	%f3, %g5, -8
	fldi	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fsqr.2566
	fmul	%f7, %f1, %f0
	fmov	%f0, %f14
	call	fsqr.2566
	fmul	%f0, %f2, %f0
	fadd	%f7, %f7, %f0
	fmov	%f0, %f10
	call	fsqr.2566
	fmul	%f0, %f3, %f0
	fadd	%f0, %f7, %f0
	fsti	%f0, %g5, 0
	fmov	%f0, %f13
	call	fsqr.2566
	fmul	%f7, %f1, %f0
	fmov	%f0, %f12
	call	fsqr.2566
	fmul	%f0, %f2, %f0
	fadd	%f7, %f7, %f0
	fmov	%f0, %f6
	call	fsqr.2566
	fmul	%f0, %f3, %f0
	fadd	%f0, %f7, %f0
	fsti	%f0, %g5, -4
	fmov	%f0, %f11
	call	fsqr.2566
	fmul	%f7, %f1, %f0
	fmov	%f0, %f5
	call	fsqr.2566
	fmul	%f0, %f2, %f0
	fadd	%f7, %f7, %f0
	fmov	%f0, %f4
	call	fsqr.2566
	addi	%g1, %g1, 8
	fmul	%f0, %f3, %f0
	fadd	%f0, %f7, %f0
	fsti	%f0, %g5, -8
	fmul	%f0, %f1, %f13
	fmul	%f7, %f0, %f11
	fmul	%f0, %f2, %f12
	fmul	%f0, %f0, %f5
	fadd	%f7, %f7, %f0
	fmul	%f0, %f3, %f6
	fmul	%f0, %f0, %f4
	fadd	%f0, %f7, %f0
	fmul	%f0, %f20, %f0
	fsti	%f0, %g4, 0
	fldi	%f0, %g1, 0
	fmul	%f1, %f1, %f0
	fmul	%f7, %f1, %f11
	fmul	%f0, %f2, %f14
	fmul	%f2, %f0, %f5
	fadd	%f5, %f7, %f2
	fmul	%f3, %f3, %f10
	fmul	%f2, %f3, %f4
	fadd	%f2, %f5, %f2
	fmul	%f2, %f20, %f2
	fsti	%f2, %g4, -4
	fmul	%f1, %f1, %f13
	fmul	%f0, %f0, %f12
	fadd	%f1, %f1, %f0
	fmul	%f0, %f3, %f6
	fadd	%f0, %f1, %f0
	fmul	%f0, %f20, %f0
	fsti	%f0, %g4, -8
	return

!---------------------------------------------------------------------
! args = [%g10]
! fargs = []
! ret type = Bool
!---------------------------------------------------------------------
read_nth_object.2789:
	subi	%g1, %g1, 4
	call	read_int.2592
	addi	%g1, %g1, 4
	mov	%g12, %g3
	jeq	%g12, %g29, jne_else.7766
	subi	%g1, %g1, 4
	call	read_int.2592
	mov	%g16, %g3
	call	read_int.2592
	mov	%g14, %g3
	call	read_int.2592
	mov	%g8, %g3
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g7, %g3
	call	read_float.2603
	fsti	%f0, %g7, 0
	call	read_float.2603
	fsti	%f0, %g7, -4
	call	read_float.2603
	fsti	%f0, %g7, -8
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g11, %g3
	call	read_float.2603
	fsti	%f0, %g11, 0
	call	read_float.2603
	fsti	%f0, %g11, -4
	call	read_float.2603
	fsti	%f0, %g11, -8
	call	read_float.2603
	call	fisneg.2551
	mov	%g9, %g3
	addi	%g3, %g0, 2
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g15, %g3
	call	read_float.2603
	fsti	%f0, %g15, 0
	call	read_float.2603
	fsti	%f0, %g15, -4
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g17, %g3
	call	read_float.2603
	fsti	%f0, %g17, 0
	call	read_float.2603
	fsti	%f0, %g17, -4
	call	read_float.2603
	fsti	%f0, %g17, -8
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	mov	%g13, %g3
	jeq	%g8, %g0, jne_else.7767
	subi	%g1, %g1, 4
	call	read_float.2603
	call	rad.2780
	fsti	%f0, %g13, 0
	call	read_float.2603
	call	rad.2780
	fsti	%f0, %g13, -4
	call	read_float.2603
	call	rad.2780
	addi	%g1, %g1, 4
	fsti	%f0, %g13, -8
	jmp	jne_cont.7768
jne_else.7767:
jne_cont.7768:
	addi	%g5, %g0, 2
	jeq	%g16, %g5, jne_else.7769
	mov	%g5, %g9
	jmp	jne_cont.7770
jne_else.7769:
	addi	%g5, %g0, 1
jne_cont.7770:
	addi	%g3, %g0, 4
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	mov	%g4, %g3
	mov	%g3, %g2
	addi	%g2, %g2, 44
	sti	%g4, %g3, -40
	sti	%g13, %g3, -36
	sti	%g17, %g3, -32
	sti	%g15, %g3, -28
	sti	%g5, %g3, -24
	sti	%g11, %g3, -20
	sti	%g7, %g3, -16
	sti	%g8, %g3, -12
	sti	%g14, %g3, -8
	sti	%g16, %g3, -4
	sti	%g12, %g3, 0
	slli	%g4, %g10, 2
	sti	%g3, %g4, -1448
	addi	%g3, %g0, 3
	jeq	%g16, %g3, jne_else.7771
	addi	%g3, %g0, 2
	jeq	%g16, %g3, jne_else.7773
	jmp	jne_cont.7774
jne_else.7773:
	jeq	%g9, %g0, jne_else.7775
	addi	%g5, %g0, 0
	jmp	jne_cont.7776
jne_else.7775:
	addi	%g5, %g0, 1
jne_cont.7776:
	mov	%g4, %g7
	subi	%g1, %g1, 4
	call	vecunit_sgn.2681
	addi	%g1, %g1, 4
jne_cont.7774:
	jmp	jne_cont.7772
jne_else.7771:
	fldi	%f1, %g7, 0
	fmov	%f0, %f1
	subi	%g1, %g1, 4
	call	fiszero.2553
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7777
	fmov	%f0, %f16
	jmp	jne_cont.7778
jne_else.7777:
	fsti	%f1, %g1, 0
	subi	%g1, %g1, 8
	call	sgn.2655
	addi	%g1, %g1, 8
	fmov	%f2, %f0
	fldi	%f1, %g1, 0
	fmov	%f0, %f1
	subi	%g1, %g1, 8
	call	fsqr.2566
	addi	%g1, %g1, 8
	fdiv	%f0, %f2, %f0
jne_cont.7778:
	fsti	%f0, %g7, 0
	fldi	%f1, %g7, -4
	fmov	%f0, %f1
	subi	%g1, %g1, 4
	call	fiszero.2553
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7779
	fmov	%f0, %f16
	jmp	jne_cont.7780
jne_else.7779:
	fsti	%f1, %g1, 0
	subi	%g1, %g1, 8
	call	sgn.2655
	addi	%g1, %g1, 8
	fmov	%f2, %f0
	fldi	%f1, %g1, 0
	fmov	%f0, %f1
	subi	%g1, %g1, 8
	call	fsqr.2566
	addi	%g1, %g1, 8
	fdiv	%f0, %f2, %f0
jne_cont.7780:
	fsti	%f0, %g7, -4
	fldi	%f1, %g7, -8
	fmov	%f0, %f1
	subi	%g1, %g1, 4
	call	fiszero.2553
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7781
	fmov	%f0, %f16
	jmp	jne_cont.7782
jne_else.7781:
	fsti	%f1, %g1, 0
	subi	%g1, %g1, 8
	call	sgn.2655
	addi	%g1, %g1, 8
	fmov	%f2, %f0
	fldi	%f1, %g1, 0
	fmov	%f0, %f1
	subi	%g1, %g1, 8
	call	fsqr.2566
	addi	%g1, %g1, 8
	fdiv	%f0, %f2, %f0
jne_cont.7782:
	fsti	%f0, %g7, -8
jne_cont.7772:
	jeq	%g8, %g0, jne_else.7783
	mov	%g4, %g13
	mov	%g5, %g7
	subi	%g1, %g1, 4
	call	rotate_quadratic_matrix.2786
	addi	%g1, %g1, 4
	jmp	jne_cont.7784
jne_else.7783:
jne_cont.7784:
	addi	%g3, %g0, 1
	return
jne_else.7766:
	addi	%g3, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g10]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
read_object.2791:
	addi	%g3, %g0, 60
	jlt	%g10, %g3, jle_else.7785
	return
jle_else.7785:
	sti	%g10, %g1, 0
	subi	%g1, %g1, 8
	call	read_nth_object.2789
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.7787
	ldi	%g10, %g1, 0
	addi	%g10, %g10, 1
	jmp	read_object.2791
jne_else.7787:
	ldi	%g10, %g1, 0
	sti	%g10, %g0, -1692
	return

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
read_all_object.2793:
	addi	%g10, %g0, 0
	jmp	read_object.2791

!---------------------------------------------------------------------
! args = [%g7]
! fargs = []
! ret type = Array(Int)
!---------------------------------------------------------------------
read_net_item.2795:
	subi	%g1, %g1, 4
	call	read_int.2592
	addi	%g1, %g1, 4
	mov	%g4, %g3
	jeq	%g4, %g29, jne_else.7789
	addi	%g3, %g7, 1
	sti	%g4, %g1, 0
	sti	%g7, %g1, 4
	mov	%g7, %g3
	subi	%g1, %g1, 12
	call	read_net_item.2795
	addi	%g1, %g1, 12
	ldi	%g7, %g1, 4
	slli	%g5, %g7, 2
	ldi	%g4, %g1, 0
	st	%g4, %g3, %g5
	return
jne_else.7789:
	addi	%g3, %g7, 1
	addi	%g4, %g0, -1
	jmp	min_caml_create_array

!---------------------------------------------------------------------
! args = [%g8]
! fargs = []
! ret type = Array(Array(Int))
!---------------------------------------------------------------------
read_or_network.2797:
	addi	%g7, %g0, 0
	subi	%g1, %g1, 4
	call	read_net_item.2795
	addi	%g1, %g1, 4
	mov	%g4, %g3
	ldi	%g3, %g4, 0
	jeq	%g3, %g29, jne_else.7790
	addi	%g3, %g8, 1
	sti	%g4, %g1, 0
	sti	%g8, %g1, 4
	mov	%g8, %g3
	subi	%g1, %g1, 12
	call	read_or_network.2797
	addi	%g1, %g1, 12
	ldi	%g8, %g1, 4
	slli	%g5, %g8, 2
	ldi	%g4, %g1, 0
	st	%g4, %g3, %g5
	return
jne_else.7790:
	addi	%g3, %g8, 1
	jmp	min_caml_create_array

!---------------------------------------------------------------------
! args = [%g8]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
read_and_network.2799:
	addi	%g7, %g0, 0
	subi	%g1, %g1, 4
	call	read_net_item.2795
	addi	%g1, %g1, 4
	ldi	%g4, %g3, 0
	jeq	%g4, %g29, jne_else.7791
	slli	%g4, %g8, 2
	sti	%g3, %g4, -1208
	addi	%g8, %g8, 1
	jmp	read_and_network.2799
jne_else.7791:
	return

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
read_parameter.2801:
	subi	%g1, %g1, 4
	call	read_screen_settings.2782
	call	read_light.2784
	call	read_all_object.2793
	addi	%g8, %g0, 0
	call	read_and_network.2799
	addi	%g8, %g0, 0
	call	read_or_network.2797
	addi	%g1, %g1, 4
	sti	%g3, %g0, -1204
	return

!---------------------------------------------------------------------
! args = [%g4, %g8, %g7, %g6, %g5]
! fargs = [%f4, %f3, %f2]
! ret type = Bool
!---------------------------------------------------------------------
solver_rect_surface.2803:
	slli	%g3, %g7, 2
	fld	%f5, %g8, %g3
	fmov	%f0, %f5
	subi	%g1, %g1, 4
	call	fiszero.2553
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7794
	addi	%g3, %g0, 0
	return
jne_else.7794:
	mov	%g3, %g4
	subi	%g1, %g1, 4
	call	o_param_abc.2725
	mov	%g9, %g3
	mov	%g3, %g4
	call	o_isinvert.2715
	mov	%g4, %g3
	fmov	%f0, %f5
	call	fisneg.2551
	call	xor.2555
	slli	%g4, %g7, 2
	fld	%f1, %g9, %g4
	call	fneg_cond.2657
	fsub	%f0, %f0, %f4
	fdiv	%f4, %f0, %f5
	slli	%g3, %g6, 2
	fld	%f0, %g8, %g3
	fmul	%f0, %f4, %f0
	fadd	%f1, %f0, %f3
	call	fabs.2558
	fmov	%f1, %f0
	slli	%g3, %g6, 2
	fld	%f0, %g9, %g3
	call	fless.2546
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7795
	slli	%g3, %g5, 2
	fld	%f0, %g8, %g3
	fmul	%f0, %f4, %f0
	fadd	%f1, %f0, %f2
	subi	%g1, %g1, 4
	call	fabs.2558
	fmov	%f1, %f0
	slli	%g3, %g5, 2
	fld	%f0, %g9, %g3
	call	fless.2546
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7796
	fsti	%f4, %g0, -1200
	addi	%g3, %g0, 1
	return
jne_else.7796:
	addi	%g3, %g0, 0
	return
jne_else.7795:
	addi	%g3, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g4, %g8]
! fargs = [%f8, %f7, %f6]
! ret type = Int
!---------------------------------------------------------------------
solver_rect.2812:
	addi	%g7, %g0, 0
	addi	%g6, %g0, 1
	addi	%g5, %g0, 2
	sti	%g8, %g1, 0
	sti	%g4, %g1, 4
	fmov	%f2, %f6
	fmov	%f3, %f7
	fmov	%f4, %f8
	subi	%g1, %g1, 12
	call	solver_rect_surface.2803
	addi	%g1, %g1, 12
	jeq	%g3, %g0, jne_else.7797
	addi	%g3, %g0, 1
	return
jne_else.7797:
	addi	%g7, %g0, 1
	addi	%g6, %g0, 2
	addi	%g5, %g0, 0
	ldi	%g4, %g1, 4
	ldi	%g8, %g1, 0
	fmov	%f2, %f8
	fmov	%f3, %f6
	fmov	%f4, %f7
	subi	%g1, %g1, 12
	call	solver_rect_surface.2803
	addi	%g1, %g1, 12
	jeq	%g3, %g0, jne_else.7798
	addi	%g3, %g0, 2
	return
jne_else.7798:
	addi	%g7, %g0, 2
	addi	%g6, %g0, 0
	addi	%g5, %g0, 1
	ldi	%g4, %g1, 4
	ldi	%g8, %g1, 0
	fmov	%f2, %f7
	fmov	%f3, %f8
	fmov	%f4, %f6
	subi	%g1, %g1, 12
	call	solver_rect_surface.2803
	addi	%g1, %g1, 12
	jeq	%g3, %g0, jne_else.7799
	addi	%g3, %g0, 3
	return
jne_else.7799:
	addi	%g3, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g3, %g4]
! fargs = [%f2, %f1, %f4]
! ret type = Int
!---------------------------------------------------------------------
solver_surface.2818:
	subi	%g1, %g1, 4
	call	o_param_abc.2725
	addi	%g1, %g1, 4
	mov	%g5, %g3
	fsti	%f1, %g1, 0
	fsti	%f2, %g1, 4
	mov	%g3, %g5
	subi	%g1, %g1, 12
	call	veciprod.2684
	fmov	%f5, %f0
	fmov	%f0, %f5
	call	fispos.2549
	addi	%g1, %g1, 12
	jeq	%g3, %g0, jne_else.7800
	fldi	%f2, %g1, 4
	fldi	%f1, %g1, 0
	mov	%g3, %g5
	fmov	%f0, %f4
	subi	%g1, %g1, 12
	call	veciprod2.2687
	call	fneg.2562
	addi	%g1, %g1, 12
	fdiv	%f0, %f0, %f5
	fsti	%f0, %g0, -1200
	addi	%g3, %g0, 1
	return
jne_else.7800:
	addi	%g3, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = [%f3, %f2, %f1]
! ret type = Float
!---------------------------------------------------------------------
quadratic.2824:
	fmov	%f0, %f3
	subi	%g1, %g1, 4
	call	fsqr.2566
	addi	%g1, %g1, 4
	fmov	%f4, %f0
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_a.2719
	fmul	%f5, %f4, %f0
	fmov	%f0, %f2
	call	fsqr.2566
	addi	%g1, %g1, 8
	fmov	%f4, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_b.2721
	fmul	%f0, %f4, %f0
	fadd	%f5, %f5, %f0
	fmov	%f0, %f1
	call	fsqr.2566
	addi	%g1, %g1, 8
	fmov	%f4, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_c.2723
	addi	%g1, %g1, 8
	fmul	%f0, %f4, %f0
	fadd	%f4, %f5, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_isrot.2717
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jeq	%g4, %g0, jne_else.7801
	fmul	%f5, %f2, %f1
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r1.2743
	addi	%g1, %g1, 8
	fmul	%f0, %f5, %f0
	fadd	%f4, %f4, %f0
	fmul	%f1, %f1, %f3
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r2.2745
	addi	%g1, %g1, 8
	fmul	%f0, %f1, %f0
	fadd	%f4, %f4, %f0
	fmul	%f1, %f3, %f2
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r3.2747
	addi	%g1, %g1, 8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f4, %f0
	return
jne_else.7801:
	fmov	%f0, %f4
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = [%f5, %f7, %f2, %f6, %f4, %f1]
! ret type = Float
!---------------------------------------------------------------------
bilinear.2829:
	fmul	%f3, %f5, %f6
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_a.2719
	addi	%g1, %g1, 8
	fmul	%f8, %f3, %f0
	fmul	%f3, %f7, %f4
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_b.2721
	addi	%g1, %g1, 8
	fmul	%f0, %f3, %f0
	fadd	%f8, %f8, %f0
	fmul	%f3, %f2, %f1
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_c.2723
	addi	%g1, %g1, 8
	fmul	%f0, %f3, %f0
	fadd	%f3, %f8, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_isrot.2717
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jeq	%g4, %g0, jne_else.7802
	fmul	%f8, %f2, %f4
	fmul	%f0, %f7, %f1
	fadd	%f8, %f8, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r1.2743
	addi	%g1, %g1, 8
	fmul	%f8, %f8, %f0
	fmul	%f1, %f5, %f1
	fmul	%f0, %f2, %f6
	fadd	%f1, %f1, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r2.2745
	addi	%g1, %g1, 8
	fmul	%f0, %f1, %f0
	fadd	%f2, %f8, %f0
	fmul	%f1, %f5, %f4
	fmul	%f0, %f7, %f6
	fadd	%f1, %f1, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r3.2747
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	call	fhalf.2564
	addi	%g1, %g1, 8
	fadd	%f0, %f3, %f0
	return
jne_else.7802:
	fmov	%f0, %f3
	return

!---------------------------------------------------------------------
! args = [%g5, %g3]
! fargs = [%f6, %f10, %f1]
! ret type = Int
!---------------------------------------------------------------------
solver_second.2837:
	fldi	%f12, %g3, 0
	fldi	%f7, %g3, -4
	fldi	%f11, %g3, -8
	fsti	%f1, %g1, 0
	mov	%g3, %g5
	fmov	%f1, %f11
	fmov	%f2, %f7
	fmov	%f3, %f12
	subi	%g1, %g1, 8
	call	quadratic.2824
	fmov	%f9, %f0
	fmov	%f0, %f9
	call	fiszero.2553
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.7803
	addi	%g3, %g0, 0
	return
jne_else.7803:
	fldi	%f1, %g1, 0
	fsti	%f6, %g1, 4
	mov	%g3, %g5
	fmov	%f4, %f10
	fmov	%f2, %f11
	fmov	%f5, %f12
	subi	%g1, %g1, 12
	call	bilinear.2829
	addi	%g1, %g1, 12
	fmov	%f7, %f0
	fldi	%f6, %g1, 4
	fldi	%f1, %g1, 0
	mov	%g3, %g5
	fmov	%f2, %f10
	fmov	%f3, %f6
	subi	%g1, %g1, 12
	call	quadratic.2824
	mov	%g3, %g5
	call	o_form.2711
	addi	%g1, %g1, 12
	addi	%g4, %g0, 3
	jeq	%g3, %g4, jne_else.7804
	fmov	%f1, %f0
	jmp	jne_cont.7805
jne_else.7804:
	fsub	%f1, %f0, %f17
jne_cont.7805:
	fmov	%f0, %f7
	subi	%g1, %g1, 12
	call	fsqr.2566
	addi	%g1, %g1, 12
	fmul	%f1, %f9, %f1
	fsub	%f0, %f0, %f1
	fsti	%f0, %g1, 8
	subi	%g1, %g1, 16
	call	fispos.2549
	addi	%g1, %g1, 16
	jeq	%g3, %g0, jne_else.7806
	fldi	%f0, %g1, 8
	fsqrt	%f1, %f0
	mov	%g3, %g5
	subi	%g1, %g1, 16
	call	o_isinvert.2715
	addi	%g1, %g1, 16
	jeq	%g3, %g0, jne_else.7807
	fmov	%f0, %f1
	jmp	jne_cont.7808
jne_else.7807:
	fmov	%f0, %f1
	subi	%g1, %g1, 16
	call	fneg.2562
	addi	%g1, %g1, 16
jne_cont.7808:
	fsub	%f0, %f0, %f7
	fdiv	%f0, %f0, %f9
	fsti	%f0, %g0, -1200
	addi	%g3, %g0, 1
	return
jne_else.7806:
	addi	%g3, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g3, %g8, %g4]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
solver.2843:
	slli	%g3, %g3, 2
	ldi	%g10, %g3, -1448
	fldi	%f1, %g4, 0
	mov	%g3, %g10
	subi	%g1, %g1, 4
	call	o_param_x.2727
	fsub	%f8, %f1, %f0
	fldi	%f1, %g4, -4
	mov	%g3, %g10
	call	o_param_y.2729
	fsub	%f10, %f1, %f0
	fldi	%f1, %g4, -8
	mov	%g3, %g10
	call	o_param_z.2731
	fsub	%f6, %f1, %f0
	mov	%g3, %g10
	call	o_form.2711
	addi	%g1, %g1, 4
	mov	%g4, %g3
	jeq	%g4, %g28, jne_else.7809
	addi	%g3, %g0, 2
	jeq	%g4, %g3, jne_else.7810
	mov	%g3, %g8
	mov	%g5, %g10
	fmov	%f1, %f6
	fmov	%f6, %f8
	jmp	solver_second.2837
jne_else.7810:
	mov	%g4, %g8
	mov	%g3, %g10
	fmov	%f4, %f6
	fmov	%f1, %f10
	fmov	%f2, %f8
	jmp	solver_surface.2818
jne_else.7809:
	mov	%g4, %g10
	fmov	%f7, %f10
	jmp	solver_rect.2812

!---------------------------------------------------------------------
! args = [%g6, %g4, %g5]
! fargs = [%f5, %f7, %f4]
! ret type = Int
!---------------------------------------------------------------------
solver_rect_fast.2847:
	fldi	%f0, %g5, 0
	fsub	%f0, %f0, %f5
	fldi	%f2, %g5, -4
	fmul	%f3, %f0, %f2
	fldi	%f0, %g4, -4
	fmul	%f0, %f3, %f0
	fadd	%f1, %f0, %f7
	subi	%g1, %g1, 4
	call	fabs.2558
	fmov	%f1, %f0
	mov	%g3, %g6
	call	o_param_b.2721
	fmov	%f6, %f0
	fmov	%f0, %f6
	call	fless.2546
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7811
	fldi	%f0, %g4, -8
	fmul	%f0, %f3, %f0
	fadd	%f1, %f0, %f4
	subi	%g1, %g1, 4
	call	fabs.2558
	fmov	%f1, %f0
	mov	%g3, %g6
	call	o_param_c.2723
	call	fless.2546
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7813
	fmov	%f0, %f2
	subi	%g1, %g1, 4
	call	fiszero.2553
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7815
	addi	%g3, %g0, 0
	jmp	jne_cont.7816
jne_else.7815:
	addi	%g3, %g0, 1
jne_cont.7816:
	jmp	jne_cont.7814
jne_else.7813:
	addi	%g3, %g0, 0
jne_cont.7814:
	jmp	jne_cont.7812
jne_else.7811:
	addi	%g3, %g0, 0
jne_cont.7812:
	jeq	%g3, %g0, jne_else.7817
	fsti	%f3, %g0, -1200
	addi	%g3, %g0, 1
	return
jne_else.7817:
	fldi	%f0, %g5, -8
	fsub	%f0, %f0, %f7
	fldi	%f2, %g5, -12
	fmul	%f8, %f0, %f2
	fldi	%f0, %g4, 0
	fmul	%f0, %f8, %f0
	fadd	%f1, %f0, %f5
	subi	%g1, %g1, 4
	call	fabs.2558
	fmov	%f1, %f0
	mov	%g3, %g6
	call	o_param_a.2719
	fmov	%f3, %f0
	fmov	%f0, %f3
	call	fless.2546
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7818
	fldi	%f0, %g4, -8
	fmul	%f0, %f8, %f0
	fadd	%f1, %f0, %f4
	subi	%g1, %g1, 4
	call	fabs.2558
	fmov	%f1, %f0
	mov	%g3, %g6
	call	o_param_c.2723
	call	fless.2546
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7820
	fmov	%f0, %f2
	subi	%g1, %g1, 4
	call	fiszero.2553
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7822
	addi	%g3, %g0, 0
	jmp	jne_cont.7823
jne_else.7822:
	addi	%g3, %g0, 1
jne_cont.7823:
	jmp	jne_cont.7821
jne_else.7820:
	addi	%g3, %g0, 0
jne_cont.7821:
	jmp	jne_cont.7819
jne_else.7818:
	addi	%g3, %g0, 0
jne_cont.7819:
	jeq	%g3, %g0, jne_else.7824
	fsti	%f8, %g0, -1200
	addi	%g3, %g0, 2
	return
jne_else.7824:
	fldi	%f0, %g5, -16
	fsub	%f0, %f0, %f4
	fldi	%f2, %g5, -20
	fmul	%f4, %f0, %f2
	fldi	%f0, %g4, 0
	fmul	%f0, %f4, %f0
	fadd	%f1, %f0, %f5
	subi	%g1, %g1, 4
	call	fabs.2558
	fmov	%f1, %f0
	fmov	%f0, %f3
	call	fless.2546
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7825
	fldi	%f0, %g4, -4
	fmul	%f0, %f4, %f0
	fadd	%f1, %f0, %f7
	subi	%g1, %g1, 4
	call	fabs.2558
	fmov	%f1, %f0
	fmov	%f0, %f6
	call	fless.2546
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7827
	fmov	%f0, %f2
	subi	%g1, %g1, 4
	call	fiszero.2553
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7829
	addi	%g3, %g0, 0
	jmp	jne_cont.7830
jne_else.7829:
	addi	%g3, %g0, 1
jne_cont.7830:
	jmp	jne_cont.7828
jne_else.7827:
	addi	%g3, %g0, 0
jne_cont.7828:
	jmp	jne_cont.7826
jne_else.7825:
	addi	%g3, %g0, 0
jne_cont.7826:
	jeq	%g3, %g0, jne_else.7831
	fsti	%f4, %g0, -1200
	addi	%g3, %g0, 3
	return
jne_else.7831:
	addi	%g3, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g3, %g4]
! fargs = [%f3, %f2, %f1]
! ret type = Int
!---------------------------------------------------------------------
solver_surface_fast.2854:
	fldi	%f0, %g4, 0
	subi	%g1, %g1, 4
	call	fisneg.2551
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7832
	fldi	%f0, %g4, -4
	fmul	%f3, %f0, %f3
	fldi	%f0, %g4, -8
	fmul	%f0, %f0, %f2
	fadd	%f2, %f3, %f0
	fldi	%f0, %g4, -12
	fmul	%f0, %f0, %f1
	fadd	%f0, %f2, %f0
	fsti	%f0, %g0, -1200
	addi	%g3, %g0, 1
	return
jne_else.7832:
	addi	%g3, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g6, %g5]
! fargs = [%f3, %f2, %f1]
! ret type = Int
!---------------------------------------------------------------------
solver_second_fast.2860:
	fldi	%f6, %g5, 0
	fmov	%f0, %f6
	subi	%g1, %g1, 4
	call	fiszero.2553
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7833
	addi	%g3, %g0, 0
	return
jne_else.7833:
	fldi	%f0, %g5, -4
	fmul	%f4, %f0, %f3
	fldi	%f0, %g5, -8
	fmul	%f0, %f0, %f2
	fadd	%f4, %f4, %f0
	fldi	%f0, %g5, -12
	fmul	%f0, %f0, %f1
	fadd	%f7, %f4, %f0
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	quadratic.2824
	mov	%g3, %g6
	call	o_form.2711
	addi	%g1, %g1, 4
	addi	%g4, %g0, 3
	jeq	%g3, %g4, jne_else.7834
	fmov	%f1, %f0
	jmp	jne_cont.7835
jne_else.7834:
	fsub	%f1, %f0, %f17
jne_cont.7835:
	fmov	%f0, %f7
	subi	%g1, %g1, 4
	call	fsqr.2566
	addi	%g1, %g1, 4
	fmul	%f1, %f6, %f1
	fsub	%f0, %f0, %f1
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fispos.2549
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.7836
	mov	%g3, %g6
	subi	%g1, %g1, 8
	call	o_isinvert.2715
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.7837
	fldi	%f0, %g1, 0
	fsqrt	%f0, %f0
	fadd	%f1, %f7, %f0
	fldi	%f0, %g5, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g0, -1200
	jmp	jne_cont.7838
jne_else.7837:
	fldi	%f0, %g1, 0
	fsqrt	%f0, %f0
	fsub	%f1, %f7, %f0
	fldi	%f0, %g5, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g0, -1200
jne_cont.7838:
	addi	%g3, %g0, 1
	return
jne_else.7836:
	addi	%g3, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g5, %g7, %g4]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
solver_fast.2866:
	slli	%g3, %g5, 2
	ldi	%g6, %g3, -1448
	fldi	%f1, %g4, 0
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	o_param_x.2727
	fsub	%f3, %f1, %f0
	fldi	%f1, %g4, -4
	mov	%g3, %g6
	call	o_param_y.2729
	fsub	%f2, %f1, %f0
	fldi	%f1, %g4, -8
	mov	%g3, %g6
	call	o_param_z.2731
	fsub	%f1, %f1, %f0
	mov	%g3, %g7
	call	d_const.2772
	slli	%g4, %g5, 2
	ld	%g5, %g3, %g4
	mov	%g3, %g6
	call	o_form.2711
	addi	%g1, %g1, 4
	mov	%g4, %g3
	jeq	%g4, %g28, jne_else.7839
	addi	%g3, %g0, 2
	jeq	%g4, %g3, jne_else.7840
	jmp	solver_second_fast.2860
jne_else.7840:
	mov	%g4, %g5
	mov	%g3, %g6
	jmp	solver_surface_fast.2854
jne_else.7839:
	mov	%g3, %g7
	subi	%g1, %g1, 4
	call	d_vec.2770
	addi	%g1, %g1, 4
	mov	%g4, %g3
	fmov	%f4, %f1
	fmov	%f7, %f2
	fmov	%f5, %f3
	jmp	solver_rect_fast.2847

!---------------------------------------------------------------------
! args = [%g3, %g5, %g4]
! fargs = [%f2, %f1, %f0]
! ret type = Int
!---------------------------------------------------------------------
solver_surface_fast2.2870:
	fldi	%f0, %g5, 0
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fisneg.2551
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.7841
	fldi	%f1, %g4, -12
	fldi	%f0, %g1, 0
	fmul	%f0, %f0, %f1
	fsti	%f0, %g0, -1200
	addi	%g3, %g0, 1
	return
jne_else.7841:
	addi	%g3, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g6, %g5, %g4]
! fargs = [%f3, %f2, %f1]
! ret type = Int
!---------------------------------------------------------------------
solver_second_fast2.2877:
	fldi	%f4, %g5, 0
	fmov	%f0, %f4
	subi	%g1, %g1, 4
	call	fiszero.2553
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7842
	addi	%g3, %g0, 0
	return
jne_else.7842:
	fldi	%f0, %g5, -4
	fmul	%f3, %f0, %f3
	fldi	%f0, %g5, -8
	fmul	%f0, %f0, %f2
	fadd	%f2, %f3, %f0
	fldi	%f0, %g5, -12
	fmul	%f0, %f0, %f1
	fadd	%f1, %f2, %f0
	fldi	%f2, %g4, -12
	fmov	%f0, %f1
	subi	%g1, %g1, 4
	call	fsqr.2566
	addi	%g1, %g1, 4
	fmul	%f2, %f4, %f2
	fsub	%f0, %f0, %f2
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fispos.2549
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.7843
	mov	%g3, %g6
	subi	%g1, %g1, 8
	call	o_isinvert.2715
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.7844
	fldi	%f0, %g1, 0
	fsqrt	%f0, %f0
	fadd	%f1, %f1, %f0
	fldi	%f0, %g5, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g0, -1200
	jmp	jne_cont.7845
jne_else.7844:
	fldi	%f0, %g1, 0
	fsqrt	%f0, %f0
	fsub	%f1, %f1, %f0
	fldi	%f0, %g5, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g0, -1200
jne_cont.7845:
	addi	%g3, %g0, 1
	return
jne_else.7843:
	addi	%g3, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g4, %g5]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
solver_fast2.2884:
	slli	%g3, %g4, 2
	ldi	%g6, %g3, -1448
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	o_param_ctbl.2749
	mov	%g8, %g3
	fldi	%f5, %g8, 0
	fldi	%f7, %g8, -4
	fldi	%f4, %g8, -8
	mov	%g3, %g5
	call	d_const.2772
	slli	%g4, %g4, 2
	ld	%g7, %g3, %g4
	mov	%g3, %g6
	call	o_form.2711
	addi	%g1, %g1, 4
	mov	%g4, %g3
	jeq	%g4, %g28, jne_else.7846
	addi	%g3, %g0, 2
	jeq	%g4, %g3, jne_else.7847
	mov	%g4, %g8
	mov	%g5, %g7
	fmov	%f1, %f4
	fmov	%f2, %f7
	fmov	%f3, %f5
	jmp	solver_second_fast2.2877
jne_else.7847:
	mov	%g4, %g8
	mov	%g5, %g7
	mov	%g3, %g6
	fmov	%f0, %f4
	fmov	%f1, %f7
	fmov	%f2, %f5
	jmp	solver_surface_fast2.2870
jne_else.7846:
	mov	%g3, %g5
	subi	%g1, %g1, 4
	call	d_vec.2770
	addi	%g1, %g1, 4
	mov	%g4, %g3
	mov	%g5, %g7
	jmp	solver_rect_fast.2847

!---------------------------------------------------------------------
! args = [%g5, %g6]
! fargs = []
! ret type = Array(Float)
!---------------------------------------------------------------------
setup_rect_table.2887:
	addi	%g3, %g0, 6
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	fldi	%f0, %g5, 0
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	fiszero.2553
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jeq	%g4, %g0, jne_else.7848
	ldi	%g3, %g1, 0
	fsti	%f16, %g3, -4
	jmp	jne_cont.7849
jne_else.7848:
	mov	%g3, %g6
	subi	%g1, %g1, 8
	call	o_isinvert.2715
	mov	%g4, %g3
	fldi	%f0, %g5, 0
	call	fisneg.2551
	mov	%g7, %g3
	mov	%g3, %g7
	call	xor.2555
	mov	%g4, %g3
	mov	%g3, %g6
	call	o_param_a.2719
	fmov	%f1, %f0
	mov	%g3, %g4
	call	fneg_cond.2657
	addi	%g1, %g1, 8
	ldi	%g3, %g1, 0
	fsti	%f0, %g3, 0
	fldi	%f0, %g5, 0
	fdiv	%f0, %f17, %f0
	fsti	%f0, %g3, -4
jne_cont.7849:
	fldi	%f0, %g5, -4
	subi	%g1, %g1, 8
	call	fiszero.2553
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jeq	%g4, %g0, jne_else.7850
	ldi	%g3, %g1, 0
	fsti	%f16, %g3, -12
	jmp	jne_cont.7851
jne_else.7850:
	mov	%g3, %g6
	subi	%g1, %g1, 8
	call	o_isinvert.2715
	mov	%g4, %g3
	fldi	%f0, %g5, -4
	call	fisneg.2551
	mov	%g7, %g3
	mov	%g3, %g7
	call	xor.2555
	mov	%g4, %g3
	mov	%g3, %g6
	call	o_param_b.2721
	fmov	%f1, %f0
	mov	%g3, %g4
	call	fneg_cond.2657
	addi	%g1, %g1, 8
	ldi	%g3, %g1, 0
	fsti	%f0, %g3, -8
	fldi	%f0, %g5, -4
	fdiv	%f0, %f17, %f0
	fsti	%f0, %g3, -12
jne_cont.7851:
	fldi	%f0, %g5, -8
	subi	%g1, %g1, 8
	call	fiszero.2553
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jeq	%g4, %g0, jne_else.7852
	ldi	%g3, %g1, 0
	fsti	%f16, %g3, -20
	jmp	jne_cont.7853
jne_else.7852:
	mov	%g3, %g6
	subi	%g1, %g1, 8
	call	o_isinvert.2715
	mov	%g4, %g3
	fldi	%f0, %g5, -8
	call	fisneg.2551
	mov	%g7, %g3
	mov	%g3, %g7
	call	xor.2555
	mov	%g4, %g3
	mov	%g3, %g6
	call	o_param_c.2723
	fmov	%f1, %f0
	mov	%g3, %g4
	call	fneg_cond.2657
	addi	%g1, %g1, 8
	ldi	%g3, %g1, 0
	fsti	%f0, %g3, -16
	fldi	%f0, %g5, -8
	fdiv	%f0, %f17, %f0
	fsti	%f0, %g3, -20
jne_cont.7853:
	return

!---------------------------------------------------------------------
! args = [%g5, %g6]
! fargs = []
! ret type = Array(Float)
!---------------------------------------------------------------------
setup_surface_table.2890:
	addi	%g3, %g0, 4
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	fldi	%f1, %g5, 0
	sti	%g3, %g1, 0
	mov	%g3, %g6
	subi	%g1, %g1, 8
	call	o_param_a.2719
	fmov	%f4, %f0
	fmul	%f2, %f1, %f4
	fldi	%f1, %g5, -4
	mov	%g3, %g6
	call	o_param_b.2721
	fmov	%f3, %f0
	fmul	%f0, %f1, %f3
	fadd	%f5, %f2, %f0
	fldi	%f1, %g5, -8
	mov	%g3, %g6
	call	o_param_c.2723
	fmov	%f2, %f0
	fmul	%f0, %f1, %f2
	fadd	%f1, %f5, %f0
	fmov	%f0, %f1
	call	fispos.2549
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jeq	%g4, %g0, jne_else.7854
	fdiv	%f0, %f21, %f1
	ldi	%g3, %g1, 0
	fsti	%f0, %g3, 0
	fdiv	%f0, %f4, %f1
	subi	%g1, %g1, 8
	call	fneg.2562
	fsti	%f0, %g3, -4
	fdiv	%f0, %f3, %f1
	call	fneg.2562
	fsti	%f0, %g3, -8
	fdiv	%f0, %f2, %f1
	call	fneg.2562
	addi	%g1, %g1, 8
	fsti	%f0, %g3, -12
	jmp	jne_cont.7855
jne_else.7854:
	ldi	%g3, %g1, 0
	fsti	%f16, %g3, 0
jne_cont.7855:
	return

!---------------------------------------------------------------------
! args = [%g5, %g6]
! fargs = []
! ret type = Array(Float)
!---------------------------------------------------------------------
setup_second_table.2893:
	addi	%g3, %g0, 5
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	fldi	%f3, %g5, 0
	fldi	%f7, %g5, -4
	fldi	%f1, %g5, -8
	sti	%g3, %g1, 0
	fsti	%f1, %g1, 4
	fsti	%f3, %g1, 8
	mov	%g3, %g6
	fmov	%f2, %f7
	subi	%g1, %g1, 16
	call	quadratic.2824
	fmov	%f6, %f0
	mov	%g3, %g6
	call	o_param_a.2719
	addi	%g1, %g1, 16
	fldi	%f3, %g1, 8
	fmul	%f0, %f3, %f0
	subi	%g1, %g1, 16
	call	fneg.2562
	fmov	%f2, %f0
	mov	%g3, %g6
	call	o_param_b.2721
	fmul	%f0, %f7, %f0
	call	fneg.2562
	fmov	%f3, %f0
	mov	%g3, %g6
	call	o_param_c.2723
	addi	%g1, %g1, 16
	fldi	%f1, %g1, 4
	fmul	%f0, %f1, %f0
	subi	%g1, %g1, 16
	call	fneg.2562
	addi	%g1, %g1, 16
	fmov	%f5, %f0
	ldi	%g3, %g1, 0
	fsti	%f6, %g3, 0
	mov	%g3, %g6
	subi	%g1, %g1, 16
	call	o_isrot.2717
	addi	%g1, %g1, 16
	mov	%g4, %g3
	jeq	%g4, %g0, jne_else.7856
	fldi	%f1, %g5, -8
	mov	%g3, %g6
	subi	%g1, %g1, 16
	call	o_param_r2.2745
	fmov	%f4, %f0
	fmul	%f8, %f1, %f4
	fldi	%f7, %g5, -4
	mov	%g3, %g6
	call	o_param_r3.2747
	fmov	%f1, %f0
	fmul	%f0, %f7, %f1
	fadd	%f0, %f8, %f0
	call	fhalf.2564
	addi	%g1, %g1, 16
	fsub	%f0, %f2, %f0
	ldi	%g3, %g1, 0
	fsti	%f0, %g3, -4
	fldi	%f7, %g5, -8
	mov	%g3, %g6
	subi	%g1, %g1, 16
	call	o_param_r1.2743
	fmov	%f2, %f0
	fmul	%f7, %f7, %f2
	fldi	%f0, %g5, 0
	fmul	%f0, %f0, %f1
	fadd	%f0, %f7, %f0
	call	fhalf.2564
	addi	%g1, %g1, 16
	fsub	%f0, %f3, %f0
	ldi	%g3, %g1, 0
	fsti	%f0, %g3, -8
	fldi	%f0, %g5, -4
	fmul	%f1, %f0, %f2
	fldi	%f0, %g5, 0
	fmul	%f0, %f0, %f4
	fadd	%f0, %f1, %f0
	subi	%g1, %g1, 16
	call	fhalf.2564
	addi	%g1, %g1, 16
	fsub	%f0, %f5, %f0
	fsti	%f0, %g3, -12
	jmp	jne_cont.7857
jne_else.7856:
	ldi	%g3, %g1, 0
	fsti	%f2, %g3, -4
	fsti	%f3, %g3, -8
	fsti	%f5, %g3, -12
jne_cont.7857:
	fmov	%f0, %f6
	subi	%g1, %g1, 16
	call	fiszero.2553
	addi	%g1, %g1, 16
	mov	%g4, %g3
	jeq	%g4, %g0, jne_else.7858
	jmp	jne_cont.7859
jne_else.7858:
	fdiv	%f0, %f17, %f6
	ldi	%g3, %g1, 0
	fsti	%f0, %g3, -16
jne_cont.7859:
	ldi	%g3, %g1, 0
	return

!---------------------------------------------------------------------
! args = [%g9, %g8]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
iter_setup_dirvec_constants.2896:
	jlt	%g8, %g0, jge_else.7860
	slli	%g3, %g8, 2
	ldi	%g6, %g3, -1448
	mov	%g3, %g9
	subi	%g1, %g1, 4
	call	d_const.2772
	mov	%g10, %g3
	mov	%g3, %g9
	call	d_vec.2770
	mov	%g5, %g3
	mov	%g3, %g6
	call	o_form.2711
	addi	%g1, %g1, 4
	jeq	%g3, %g28, jne_else.7861
	addi	%g4, %g0, 2
	jeq	%g3, %g4, jne_else.7863
	subi	%g1, %g1, 4
	call	setup_second_table.2893
	addi	%g1, %g1, 4
	slli	%g4, %g8, 2
	st	%g3, %g10, %g4
	jmp	jne_cont.7864
jne_else.7863:
	subi	%g1, %g1, 4
	call	setup_surface_table.2890
	addi	%g1, %g1, 4
	slli	%g4, %g8, 2
	st	%g3, %g10, %g4
jne_cont.7864:
	jmp	jne_cont.7862
jne_else.7861:
	subi	%g1, %g1, 4
	call	setup_rect_table.2887
	addi	%g1, %g1, 4
	slli	%g4, %g8, 2
	st	%g3, %g10, %g4
jne_cont.7862:
	subi	%g8, %g8, 1
	jmp	iter_setup_dirvec_constants.2896
jge_else.7860:
	return

!---------------------------------------------------------------------
! args = [%g9]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
setup_dirvec_constants.2899:
	ldi	%g3, %g0, -1692
	subi	%g8, %g3, 1
	jmp	iter_setup_dirvec_constants.2896

!---------------------------------------------------------------------
! args = [%g6, %g5]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
setup_startp_constants.2901:
	jlt	%g5, %g0, jge_else.7866
	slli	%g3, %g5, 2
	ldi	%g3, %g3, -1448
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_ctbl.2749
	addi	%g1, %g1, 8
	mov	%g7, %g3
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_form.2711
	addi	%g1, %g1, 8
	mov	%g8, %g3
	fldi	%f1, %g6, 0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_x.2727
	addi	%g1, %g1, 8
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, 0
	fldi	%f1, %g6, -4
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_y.2729
	addi	%g1, %g1, 8
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, -4
	fldi	%f1, %g6, -8
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_z.2731
	addi	%g1, %g1, 8
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, -8
	addi	%g4, %g0, 2
	jeq	%g8, %g4, jne_else.7867
	addi	%g4, %g0, 2
	jlt	%g4, %g8, jle_else.7869
	jmp	jle_cont.7870
jle_else.7869:
	fldi	%f3, %g7, 0
	fldi	%f2, %g7, -4
	fldi	%f1, %g7, -8
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	quadratic.2824
	addi	%g1, %g1, 8
	addi	%g3, %g0, 3
	jeq	%g8, %g3, jne_else.7871
	fmov	%f1, %f0
	jmp	jne_cont.7872
jne_else.7871:
	fsub	%f1, %f0, %f17
jne_cont.7872:
	fsti	%f1, %g7, -12
jle_cont.7870:
	jmp	jne_cont.7868
jne_else.7867:
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_abc.2725
	fldi	%f2, %g7, 0
	fldi	%f1, %g7, -4
	fldi	%f0, %g7, -8
	call	veciprod2.2687
	addi	%g1, %g1, 8
	fsti	%f0, %g7, -12
jne_cont.7868:
	subi	%g5, %g5, 1
	jmp	setup_startp_constants.2901
jge_else.7866:
	return

!---------------------------------------------------------------------
! args = [%g6]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
setup_startp.2904:
	subi	%g4, %g0, -1084
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	veccpy.2673
	addi	%g1, %g1, 4
	ldi	%g3, %g0, -1692
	subi	%g5, %g3, 1
	jmp	setup_startp_constants.2901

!---------------------------------------------------------------------
! args = [%g4]
! fargs = [%f1, %f3, %f2]
! ret type = Bool
!---------------------------------------------------------------------
is_rect_outside.2906:
	subi	%g1, %g1, 4
	call	fabs.2558
	fmov	%f1, %f0
	mov	%g3, %g4
	call	o_param_a.2719
	call	fless.2546
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7874
	fmov	%f1, %f3
	subi	%g1, %g1, 4
	call	fabs.2558
	fmov	%f1, %f0
	mov	%g3, %g4
	call	o_param_b.2721
	call	fless.2546
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7876
	fmov	%f1, %f2
	subi	%g1, %g1, 4
	call	fabs.2558
	fmov	%f1, %f0
	mov	%g3, %g4
	call	o_param_c.2723
	call	fless.2546
	addi	%g1, %g1, 4
	jmp	jne_cont.7877
jne_else.7876:
	addi	%g3, %g0, 0
jne_cont.7877:
	jmp	jne_cont.7875
jne_else.7874:
	addi	%g3, %g0, 0
jne_cont.7875:
	jeq	%g3, %g0, jne_else.7878
	mov	%g3, %g4
	jmp	o_isinvert.2715
jne_else.7878:
	mov	%g3, %g4
	subi	%g1, %g1, 4
	call	o_isinvert.2715
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7879
	addi	%g3, %g0, 0
	return
jne_else.7879:
	addi	%g3, %g0, 1
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = [%f2, %f1, %f0]
! ret type = Bool
!---------------------------------------------------------------------
is_plane_outside.2911:
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_abc.2725
	mov	%g4, %g3
	mov	%g3, %g4
	call	veciprod2.2687
	addi	%g1, %g1, 8
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_isinvert.2715
	mov	%g4, %g3
	call	fisneg.2551
	call	xor.2555
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.7880
	addi	%g3, %g0, 0
	return
jne_else.7880:
	addi	%g3, %g0, 1
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = [%f3, %f2, %f1]
! ret type = Bool
!---------------------------------------------------------------------
is_second_outside.2916:
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	quadratic.2824
	addi	%g1, %g1, 8
	fmov	%f1, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_form.2711
	addi	%g1, %g1, 8
	mov	%g4, %g3
	addi	%g5, %g0, 3
	jeq	%g4, %g5, jne_else.7881
	fmov	%f0, %f1
	jmp	jne_cont.7882
jne_else.7881:
	fsub	%f0, %f1, %f17
jne_cont.7882:
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_isinvert.2715
	mov	%g4, %g3
	call	fisneg.2551
	call	xor.2555
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.7883
	addi	%g3, %g0, 0
	return
jne_else.7883:
	addi	%g3, %g0, 1
	return

!---------------------------------------------------------------------
! args = [%g6]
! fargs = [%f3, %f2, %f1]
! ret type = Bool
!---------------------------------------------------------------------
is_outside.2921:
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	o_param_x.2727
	fsub	%f8, %f3, %f0
	mov	%g3, %g6
	call	o_param_y.2729
	fsub	%f7, %f2, %f0
	mov	%g3, %g6
	call	o_param_z.2731
	fsub	%f6, %f1, %f0
	mov	%g3, %g6
	call	o_form.2711
	addi	%g1, %g1, 4
	mov	%g4, %g3
	jeq	%g4, %g28, jne_else.7884
	addi	%g3, %g0, 2
	jeq	%g4, %g3, jne_else.7885
	mov	%g3, %g6
	fmov	%f1, %f6
	fmov	%f2, %f7
	fmov	%f3, %f8
	jmp	is_second_outside.2916
jne_else.7885:
	mov	%g3, %g6
	fmov	%f0, %f6
	fmov	%f1, %f7
	fmov	%f2, %f8
	jmp	is_plane_outside.2911
jne_else.7884:
	mov	%g4, %g6
	fmov	%f2, %f6
	fmov	%f3, %f7
	fmov	%f1, %f8
	jmp	is_rect_outside.2906

!---------------------------------------------------------------------
! args = [%g7, %g8]
! fargs = [%f3, %f2, %f1]
! ret type = Bool
!---------------------------------------------------------------------
check_all_inside.2926:
	slli	%g3, %g7, 2
	ld	%g4, %g8, %g3
	jeq	%g4, %g29, jne_else.7886
	slli	%g3, %g4, 2
	ldi	%g6, %g3, -1448
	fsti	%f1, %g1, 0
	fsti	%f2, %g1, 4
	fsti	%f3, %g1, 8
	subi	%g1, %g1, 16
	call	is_outside.2921
	addi	%g1, %g1, 16
	jeq	%g3, %g0, jne_else.7887
	addi	%g3, %g0, 0
	return
jne_else.7887:
	addi	%g7, %g7, 1
	fldi	%f3, %g1, 8
	fldi	%f2, %g1, 4
	fldi	%f1, %g1, 0
	jmp	check_all_inside.2926
jne_else.7886:
	addi	%g3, %g0, 1
	return

!---------------------------------------------------------------------
! args = [%g9, %g8]
! fargs = []
! ret type = Bool
!---------------------------------------------------------------------
shadow_check_and_group.2932:
	slli	%g3, %g9, 2
	ld	%g5, %g8, %g3
	jeq	%g5, %g29, jne_else.7888
	subi	%g4, %g0, -1180
	subi	%g7, %g0, -740
	sti	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	solver_fast.2866
	addi	%g1, %g1, 8
	fldi	%f1, %g0, -1200
	fsti	%f1, %g1, 4
	jeq	%g3, %g0, jne_else.7889
	! -0.200000
	mvhi	%g30, 48716
	mvlo	%g30, 52420
	sti	%g30, %g1, 12
	fldi	%f0, %g1, 12
	subi	%g1, %g1, 12
	call	fless.2546
	addi	%g1, %g1, 12
	jmp	jne_cont.7890
jne_else.7889:
	addi	%g3, %g0, 0
jne_cont.7890:
	jeq	%g3, %g0, jne_else.7891
	fldi	%f1, %g1, 4
	fadd	%f0, %f1, %f26
	fldi	%f1, %g0, -1412
	fmul	%f2, %f1, %f0
	fldi	%f1, %g0, -1180
	fadd	%f3, %f2, %f1
	fldi	%f1, %g0, -1416
	fmul	%f2, %f1, %f0
	fldi	%f1, %g0, -1184
	fadd	%f2, %f2, %f1
	fldi	%f1, %g0, -1420
	fmul	%f1, %f1, %f0
	fldi	%f0, %g0, -1188
	fadd	%f1, %f1, %f0
	addi	%g7, %g0, 0
	sti	%g8, %g1, 8
	subi	%g1, %g1, 16
	call	check_all_inside.2926
	addi	%g1, %g1, 16
	jeq	%g3, %g0, jne_else.7892
	addi	%g3, %g0, 1
	return
jne_else.7892:
	addi	%g9, %g9, 1
	ldi	%g8, %g1, 8
	jmp	shadow_check_and_group.2932
jne_else.7891:
	ldi	%g5, %g1, 0
	slli	%g3, %g5, 2
	ldi	%g3, %g3, -1448
	subi	%g1, %g1, 12
	call	o_isinvert.2715
	addi	%g1, %g1, 12
	jeq	%g3, %g0, jne_else.7893
	addi	%g9, %g9, 1
	jmp	shadow_check_and_group.2932
jne_else.7893:
	addi	%g3, %g0, 0
	return
jne_else.7888:
	addi	%g3, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g10, %g11]
! fargs = []
! ret type = Bool
!---------------------------------------------------------------------
shadow_check_one_or_group.2935:
	slli	%g3, %g10, 2
	ld	%g4, %g11, %g3
	jeq	%g4, %g29, jne_else.7894
	slli	%g3, %g4, 2
	ldi	%g8, %g3, -1208
	addi	%g9, %g0, 0
	subi	%g1, %g1, 4
	call	shadow_check_and_group.2932
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7895
	addi	%g3, %g0, 1
	return
jne_else.7895:
	addi	%g10, %g10, 1
	jmp	shadow_check_one_or_group.2935
jne_else.7894:
	addi	%g3, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g12, %g13]
! fargs = []
! ret type = Bool
!---------------------------------------------------------------------
shadow_check_one_or_matrix.2938:
	slli	%g3, %g12, 2
	ld	%g11, %g13, %g3
	ldi	%g5, %g11, 0
	jeq	%g5, %g29, jne_else.7896
	addi	%g3, %g0, 99
	sti	%g11, %g1, 0
	jeq	%g5, %g3, jne_else.7897
	subi	%g4, %g0, -1180
	subi	%g7, %g0, -740
	subi	%g1, %g1, 8
	call	solver_fast.2866
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.7899
	fldi	%f1, %g0, -1200
	fmov	%f0, %f25
	subi	%g1, %g1, 8
	call	fless.2546
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.7901
	addi	%g10, %g0, 1
	subi	%g1, %g1, 8
	call	shadow_check_one_or_group.2935
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.7903
	addi	%g3, %g0, 1
	jmp	jne_cont.7904
jne_else.7903:
	addi	%g3, %g0, 0
jne_cont.7904:
	jmp	jne_cont.7902
jne_else.7901:
	addi	%g3, %g0, 0
jne_cont.7902:
	jmp	jne_cont.7900
jne_else.7899:
	addi	%g3, %g0, 0
jne_cont.7900:
	jmp	jne_cont.7898
jne_else.7897:
	addi	%g3, %g0, 1
jne_cont.7898:
	jeq	%g3, %g0, jne_else.7905
	addi	%g10, %g0, 1
	ldi	%g11, %g1, 0
	subi	%g1, %g1, 8
	call	shadow_check_one_or_group.2935
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.7906
	addi	%g3, %g0, 1
	return
jne_else.7906:
	addi	%g12, %g12, 1
	jmp	shadow_check_one_or_matrix.2938
jne_else.7905:
	addi	%g12, %g12, 1
	jmp	shadow_check_one_or_matrix.2938
jne_else.7896:
	addi	%g3, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g11, %g14, %g13]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
solve_each_element.2941:
	slli	%g3, %g11, 2
	ld	%g12, %g14, %g3
	jeq	%g12, %g29, jne_else.7907
	subi	%g4, %g0, -1096
	mov	%g8, %g13
	mov	%g3, %g12
	subi	%g1, %g1, 4
	call	solver.2843
	addi	%g1, %g1, 4
	mov	%g9, %g3
	jeq	%g9, %g0, jne_else.7908
	fldi	%f2, %g0, -1200
	fmov	%f0, %f2
	fmov	%f1, %f16
	subi	%g1, %g1, 4
	call	fless.2546
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7909
	fldi	%f0, %g0, -1192
	fmov	%f1, %f2
	subi	%g1, %g1, 4
	call	fless.2546
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7911
	fadd	%f11, %f2, %f26
	fldi	%f0, %g13, 0
	fmul	%f1, %f0, %f11
	fldi	%f0, %g0, -1096
	fadd	%f3, %f1, %f0
	fldi	%f0, %g13, -4
	fmul	%f1, %f0, %f11
	fldi	%f0, %g0, -1100
	fadd	%f10, %f1, %f0
	fldi	%f0, %g13, -8
	fmul	%f1, %f0, %f11
	fldi	%f0, %g0, -1104
	fadd	%f9, %f1, %f0
	addi	%g7, %g0, 0
	fsti	%f3, %g1, 0
	mov	%g8, %g14
	fmov	%f1, %f9
	fmov	%f2, %f10
	subi	%g1, %g1, 8
	call	check_all_inside.2926
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.7913
	fsti	%f11, %g0, -1192
	subi	%g3, %g0, -1180
	fldi	%f3, %g1, 0
	fmov	%f0, %f9
	fmov	%f1, %f10
	fmov	%f2, %f3
	subi	%g1, %g1, 8
	call	vecset.2663
	addi	%g1, %g1, 8
	sti	%g12, %g0, -1176
	sti	%g9, %g0, -1196
	jmp	jne_cont.7914
jne_else.7913:
jne_cont.7914:
	jmp	jne_cont.7912
jne_else.7911:
jne_cont.7912:
	jmp	jne_cont.7910
jne_else.7909:
jne_cont.7910:
	addi	%g11, %g11, 1
	jmp	solve_each_element.2941
jne_else.7908:
	slli	%g3, %g12, 2
	ldi	%g3, %g3, -1448
	subi	%g1, %g1, 4
	call	o_isinvert.2715
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7915
	addi	%g11, %g11, 1
	jmp	solve_each_element.2941
jne_else.7915:
	return
jne_else.7907:
	return

!---------------------------------------------------------------------
! args = [%g15, %g16, %g13]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
solve_one_or_network.2945:
	slli	%g3, %g15, 2
	ld	%g3, %g16, %g3
	jeq	%g3, %g29, jne_else.7918
	slli	%g3, %g3, 2
	ldi	%g14, %g3, -1208
	addi	%g11, %g0, 0
	sti	%g13, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2941
	addi	%g1, %g1, 8
	addi	%g15, %g15, 1
	ldi	%g13, %g1, 0
	jmp	solve_one_or_network.2945
jne_else.7918:
	return

!---------------------------------------------------------------------
! args = [%g17, %g18, %g13]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
trace_or_matrix.2949:
	slli	%g3, %g17, 2
	ld	%g16, %g18, %g3
	ldi	%g3, %g16, 0
	jeq	%g3, %g29, jne_else.7920
	addi	%g4, %g0, 99
	sti	%g13, %g1, 0
	jeq	%g3, %g4, jne_else.7921
	subi	%g4, %g0, -1096
	mov	%g8, %g13
	subi	%g1, %g1, 8
	call	solver.2843
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.7923
	fldi	%f1, %g0, -1200
	fldi	%f0, %g0, -1192
	subi	%g1, %g1, 8
	call	fless.2546
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.7925
	addi	%g15, %g0, 1
	subi	%g1, %g1, 8
	call	solve_one_or_network.2945
	addi	%g1, %g1, 8
	jmp	jne_cont.7926
jne_else.7925:
jne_cont.7926:
	jmp	jne_cont.7924
jne_else.7923:
jne_cont.7924:
	jmp	jne_cont.7922
jne_else.7921:
	addi	%g15, %g0, 1
	subi	%g1, %g1, 8
	call	solve_one_or_network.2945
	addi	%g1, %g1, 8
jne_cont.7922:
	addi	%g17, %g17, 1
	ldi	%g13, %g1, 0
	jmp	trace_or_matrix.2949
jne_else.7920:
	return

!---------------------------------------------------------------------
! args = [%g13]
! fargs = []
! ret type = Bool
!---------------------------------------------------------------------
judge_intersection.2953:
	fsti	%f22, %g0, -1192
	addi	%g17, %g0, 0
	ldi	%g18, %g0, -1204
	subi	%g1, %g1, 4
	call	trace_or_matrix.2949
	fldi	%f2, %g0, -1192
	fmov	%f0, %f2
	fmov	%f1, %f25
	call	fless.2546
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7928
	! 100000000.000000
	mvhi	%g30, 19646
	mvlo	%g30, 48160
	sti	%g30, %g1, 4
	fldi	%f0, %g1, 4
	fmov	%f1, %f2
	jmp	fless.2546
jne_else.7928:
	addi	%g3, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g9, %g12, %g11]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
solve_each_element_fast.2955:
	mov	%g3, %g11
	subi	%g1, %g1, 4
	call	d_vec.2770
	addi	%g1, %g1, 4
	mov	%g13, %g3
	slli	%g3, %g9, 2
	ld	%g10, %g12, %g3
	jeq	%g10, %g29, jne_else.7929
	mov	%g5, %g11
	mov	%g4, %g10
	subi	%g1, %g1, 4
	call	solver_fast2.2884
	addi	%g1, %g1, 4
	mov	%g14, %g3
	jeq	%g14, %g0, jne_else.7930
	fldi	%f2, %g0, -1200
	fmov	%f0, %f2
	fmov	%f1, %f16
	subi	%g1, %g1, 4
	call	fless.2546
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7931
	fldi	%f0, %g0, -1192
	fmov	%f1, %f2
	subi	%g1, %g1, 4
	call	fless.2546
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7933
	fadd	%f11, %f2, %f26
	fldi	%f0, %g13, 0
	fmul	%f1, %f0, %f11
	fldi	%f0, %g0, -1084
	fadd	%f3, %f1, %f0
	fldi	%f0, %g13, -4
	fmul	%f1, %f0, %f11
	fldi	%f0, %g0, -1088
	fadd	%f10, %f1, %f0
	fldi	%f0, %g13, -8
	fmul	%f1, %f0, %f11
	fldi	%f0, %g0, -1092
	fadd	%f9, %f1, %f0
	addi	%g7, %g0, 0
	fsti	%f3, %g1, 0
	mov	%g8, %g12
	fmov	%f1, %f9
	fmov	%f2, %f10
	subi	%g1, %g1, 8
	call	check_all_inside.2926
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.7935
	fsti	%f11, %g0, -1192
	subi	%g3, %g0, -1180
	fldi	%f3, %g1, 0
	fmov	%f0, %f9
	fmov	%f1, %f10
	fmov	%f2, %f3
	subi	%g1, %g1, 8
	call	vecset.2663
	addi	%g1, %g1, 8
	sti	%g10, %g0, -1176
	sti	%g14, %g0, -1196
	jmp	jne_cont.7936
jne_else.7935:
jne_cont.7936:
	jmp	jne_cont.7934
jne_else.7933:
jne_cont.7934:
	jmp	jne_cont.7932
jne_else.7931:
jne_cont.7932:
	addi	%g9, %g9, 1
	jmp	solve_each_element_fast.2955
jne_else.7930:
	slli	%g3, %g10, 2
	ldi	%g3, %g3, -1448
	subi	%g1, %g1, 4
	call	o_isinvert.2715
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7937
	addi	%g9, %g9, 1
	jmp	solve_each_element_fast.2955
jne_else.7937:
	return
jne_else.7929:
	return

!---------------------------------------------------------------------
! args = [%g15, %g16, %g11]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
solve_one_or_network_fast.2959:
	slli	%g3, %g15, 2
	ld	%g3, %g16, %g3
	jeq	%g3, %g29, jne_else.7940
	slli	%g3, %g3, 2
	ldi	%g12, %g3, -1208
	addi	%g9, %g0, 0
	sti	%g11, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element_fast.2955
	addi	%g1, %g1, 8
	addi	%g15, %g15, 1
	ldi	%g11, %g1, 0
	jmp	solve_one_or_network_fast.2959
jne_else.7940:
	return

!---------------------------------------------------------------------
! args = [%g17, %g18, %g11]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
trace_or_matrix_fast.2963:
	slli	%g3, %g17, 2
	ld	%g16, %g18, %g3
	ldi	%g4, %g16, 0
	jeq	%g4, %g29, jne_else.7942
	addi	%g3, %g0, 99
	sti	%g11, %g1, 0
	jeq	%g4, %g3, jne_else.7943
	mov	%g5, %g11
	subi	%g1, %g1, 8
	call	solver_fast2.2884
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.7945
	fldi	%f1, %g0, -1200
	fldi	%f0, %g0, -1192
	subi	%g1, %g1, 8
	call	fless.2546
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.7947
	addi	%g15, %g0, 1
	subi	%g1, %g1, 8
	call	solve_one_or_network_fast.2959
	addi	%g1, %g1, 8
	jmp	jne_cont.7948
jne_else.7947:
jne_cont.7948:
	jmp	jne_cont.7946
jne_else.7945:
jne_cont.7946:
	jmp	jne_cont.7944
jne_else.7943:
	addi	%g15, %g0, 1
	subi	%g1, %g1, 8
	call	solve_one_or_network_fast.2959
	addi	%g1, %g1, 8
jne_cont.7944:
	addi	%g17, %g17, 1
	ldi	%g11, %g1, 0
	jmp	trace_or_matrix_fast.2963
jne_else.7942:
	return

!---------------------------------------------------------------------
! args = [%g11]
! fargs = []
! ret type = Bool
!---------------------------------------------------------------------
judge_intersection_fast.2967:
	fsti	%f22, %g0, -1192
	addi	%g17, %g0, 0
	ldi	%g18, %g0, -1204
	subi	%g1, %g1, 4
	call	trace_or_matrix_fast.2963
	fldi	%f2, %g0, -1192
	fmov	%f0, %f2
	fmov	%f1, %f25
	call	fless.2546
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7950
	! 100000000.000000
	mvhi	%g30, 19646
	mvlo	%g30, 48160
	sti	%g30, %g1, 4
	fldi	%f0, %g1, 4
	fmov	%f1, %f2
	jmp	fless.2546
jne_else.7950:
	addi	%g3, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g4]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
get_nvector_rect.2969:
	ldi	%g5, %g0, -1196
	subi	%g3, %g0, -1164
	subi	%g1, %g1, 4
	call	vecbzero.2671
	subi	%g5, %g5, 1
	slli	%g3, %g5, 2
	fld	%f1, %g4, %g3
	call	sgn.2655
	call	fneg.2562
	addi	%g1, %g1, 4
	slli	%g3, %g5, 2
	fsti	%f0, %g3, -1164
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
get_nvector_plane.2971:
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_a.2719
	call	fneg.2562
	addi	%g1, %g1, 8
	fsti	%f0, %g0, -1164
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_b.2721
	call	fneg.2562
	addi	%g1, %g1, 8
	fsti	%f0, %g0, -1168
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_c.2723
	call	fneg.2562
	addi	%g1, %g1, 8
	fsti	%f0, %g0, -1172
	return

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
get_nvector_second.2973:
	fldi	%f1, %g0, -1180
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_x.2727
	addi	%g1, %g1, 8
	fsub	%f5, %f1, %f0
	fldi	%f1, %g0, -1184
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_y.2729
	addi	%g1, %g1, 8
	fsub	%f2, %f1, %f0
	fldi	%f1, %g0, -1188
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_z.2731
	addi	%g1, %g1, 8
	fsub	%f1, %f1, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_a.2719
	addi	%g1, %g1, 8
	fmul	%f8, %f5, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_b.2721
	addi	%g1, %g1, 8
	fmul	%f3, %f2, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_c.2723
	addi	%g1, %g1, 8
	fmul	%f6, %f1, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_isrot.2717
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jeq	%g4, %g0, jne_else.7953
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r3.2747
	addi	%g1, %g1, 8
	fmov	%f7, %f0
	fmul	%f9, %f2, %f7
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r2.2745
	fmov	%f4, %f0
	fmul	%f0, %f1, %f4
	fadd	%f0, %f9, %f0
	call	fhalf.2564
	addi	%g1, %g1, 8
	fadd	%f0, %f8, %f0
	fsti	%f0, %g0, -1164
	fmul	%f8, %f5, %f7
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r1.2743
	fmov	%f7, %f0
	fmul	%f0, %f1, %f7
	fadd	%f0, %f8, %f0
	call	fhalf.2564
	fadd	%f0, %f3, %f0
	fsti	%f0, %g0, -1168
	fmul	%f1, %f5, %f4
	fmul	%f0, %f2, %f7
	fadd	%f0, %f1, %f0
	call	fhalf.2564
	addi	%g1, %g1, 8
	fadd	%f0, %f6, %f0
	fsti	%f0, %g0, -1172
	jmp	jne_cont.7954
jne_else.7953:
	fsti	%f8, %g0, -1164
	fsti	%f3, %g0, -1168
	fsti	%f6, %g0, -1172
jne_cont.7954:
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_isinvert.2715
	addi	%g1, %g1, 8
	mov	%g5, %g3
	subi	%g4, %g0, -1164
	jmp	vecunit_sgn.2681

!---------------------------------------------------------------------
! args = [%g3, %g4]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
get_nvector.2975:
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_form.2711
	addi	%g1, %g1, 8
	mov	%g5, %g3
	jeq	%g5, %g28, jne_else.7955
	addi	%g4, %g0, 2
	jeq	%g5, %g4, jne_else.7956
	ldi	%g3, %g1, 0
	jmp	get_nvector_second.2973
jne_else.7956:
	ldi	%g3, %g1, 0
	jmp	get_nvector_plane.2971
jne_else.7955:
	jmp	get_nvector_rect.2969

!---------------------------------------------------------------------
! args = [%g6, %g5]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
utexture.2978:
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	o_texturetype.2709
	mov	%g4, %g3
	mov	%g3, %g6
	call	o_color_red.2737
	fsti	%f0, %g0, -1152
	mov	%g3, %g6
	call	o_color_green.2739
	fsti	%f0, %g0, -1156
	mov	%g3, %g6
	call	o_color_blue.2741
	addi	%g1, %g1, 4
	fsti	%f0, %g0, -1160
	jeq	%g4, %g28, jne_else.7957
	addi	%g3, %g0, 2
	jeq	%g4, %g3, jne_else.7958
	addi	%g3, %g0, 3
	jeq	%g4, %g3, jne_else.7959
	addi	%g3, %g0, 4
	jeq	%g4, %g3, jne_else.7960
	return
jne_else.7960:
	fldi	%f1, %g5, 0
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	o_param_x.2727
	fsub	%f1, %f1, %f0
	mov	%g3, %g6
	call	o_param_a.2719
	fsqrt	%f0, %f0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g5, -8
	mov	%g3, %g6
	call	o_param_z.2731
	fsub	%f1, %f1, %f0
	mov	%g3, %g6
	call	o_param_c.2723
	fsqrt	%f0, %f0
	fmul	%f3, %f1, %f0
	fmov	%f0, %f2
	call	fsqr.2566
	fmov	%f1, %f0
	fmov	%f0, %f3
	call	fsqr.2566
	fadd	%f7, %f1, %f0
	fmov	%f1, %f2
	call	fabs.2558
	addi	%g1, %g1, 4
	fmov	%f1, %f0
	! 0.000100
	mvhi	%g30, 14545
	mvlo	%g30, 46863
	sti	%g30, %g1, 4
	fldi	%f6, %g1, 4
	fmov	%f0, %f6
	subi	%g1, %g1, 4
	call	fless.2546
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7962
	fmov	%f0, %f30
	jmp	jne_cont.7963
jne_else.7962:
	fdiv	%f1, %f3, %f2
	subi	%g1, %g1, 4
	call	fabs.2558
	call	atan.2575
	addi	%g1, %g1, 4
	fmul	%f0, %f0, %f31
	fdiv	%f0, %f0, %f24
jne_cont.7963:
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	min_caml_floor
	addi	%g1, %g1, 8
	fmov	%f1, %f0
	fldi	%f0, %g1, 0
	fsub	%f8, %f0, %f1
	fldi	%f1, %g5, -4
	mov	%g3, %g6
	subi	%g1, %g1, 8
	call	o_param_y.2729
	fsub	%f1, %f1, %f0
	mov	%g3, %g6
	call	o_param_b.2721
	fsqrt	%f0, %f0
	fmul	%f2, %f1, %f0
	fmov	%f1, %f7
	call	fabs.2558
	fmov	%f1, %f0
	fmov	%f0, %f6
	call	fless.2546
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.7964
	fmov	%f0, %f30
	jmp	jne_cont.7965
jne_else.7964:
	fdiv	%f1, %f2, %f7
	subi	%g1, %g1, 8
	call	fabs.2558
	call	atan.2575
	addi	%g1, %g1, 8
	fmul	%f0, %f0, %f31
	fdiv	%f0, %f0, %f24
jne_cont.7965:
	fsti	%f0, %g1, 4
	subi	%g1, %g1, 12
	call	min_caml_floor
	addi	%g1, %g1, 12
	fmov	%f1, %f0
	fldi	%f0, %g1, 4
	fsub	%f1, %f0, %f1
	! 0.150000
	mvhi	%g30, 15897
	mvlo	%g30, 39321
	sti	%g30, %g1, 12
	fldi	%f2, %g1, 12
	fsub	%f0, %f19, %f8
	subi	%g1, %g1, 12
	call	fsqr.2566
	fsub	%f2, %f2, %f0
	fsub	%f0, %f19, %f1
	call	fsqr.2566
	fsub	%f1, %f2, %f0
	fmov	%f0, %f1
	call	fisneg.2551
	addi	%g1, %g1, 12
	jeq	%g3, %g0, jne_else.7966
	fmov	%f0, %f16
	jmp	jne_cont.7967
jne_else.7966:
	fmov	%f0, %f1
jne_cont.7967:
	fmul	%f1, %f18, %f0
	! 0.300000
	mvhi	%g30, 16025
	mvlo	%g30, 39321
	sti	%g30, %g1, 12
	fldi	%f0, %g1, 12
	fdiv	%f0, %f1, %f0
	fsti	%f0, %g0, -1160
	return
jne_else.7959:
	fldi	%f1, %g5, 0
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	o_param_x.2727
	fsub	%f1, %f1, %f0
	fldi	%f2, %g5, -8
	mov	%g3, %g6
	call	o_param_z.2731
	addi	%g1, %g1, 4
	fsub	%f0, %f2, %f0
	fsti	%f0, %g1, 0
	fmov	%f0, %f1
	subi	%g1, %g1, 8
	call	fsqr.2566
	addi	%g1, %g1, 8
	fmov	%f1, %f0
	fldi	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fsqr.2566
	addi	%g1, %g1, 8
	fadd	%f0, %f1, %f0
	fsqrt	%f0, %f0
	! 10.000000
	mvhi	%g30, 16672
	mvlo	%g30, 0
	sti	%g30, %g1, 8
	fldi	%f1, %g1, 8
	fdiv	%f0, %f0, %f1
	fsti	%f0, %g1, 4
	subi	%g1, %g1, 12
	call	min_caml_floor
	addi	%g1, %g1, 12
	fmov	%f1, %f0
	fldi	%f0, %g1, 4
	fsub	%f0, %f0, %f1
	fmul	%f0, %f0, %f24
	subi	%g1, %g1, 12
	call	cos.2583
	call	fsqr.2566
	addi	%g1, %g1, 12
	fmul	%f1, %f0, %f18
	fsti	%f1, %g0, -1156
	fsub	%f0, %f17, %f0
	fmul	%f0, %f0, %f18
	fsti	%f0, %g0, -1160
	return
jne_else.7958:
	fldi	%f1, %g5, -4
	! 0.250000
	mvhi	%g30, 16000
	mvlo	%g30, 0
	sti	%g30, %g1, 4
	fldi	%f0, %g1, 4
	fmul	%f3, %f1, %f0
	subi	%g1, %g1, 4
	call	sin.2581
	call	fsqr.2566
	addi	%g1, %g1, 4
	fmul	%f1, %f18, %f0
	fsti	%f1, %g0, -1152
	fsub	%f0, %f17, %f0
	fmul	%f0, %f18, %f0
	fsti	%f0, %g0, -1156
	return
jne_else.7957:
	fldi	%f1, %g5, 0
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	o_param_x.2727
	addi	%g1, %g1, 4
	fsub	%f5, %f1, %f0
	! 0.050000
	mvhi	%g30, 15692
	mvlo	%g30, 52420
	sti	%g30, %g1, 4
	fldi	%f8, %g1, 4
	fmul	%f0, %f5, %f8
	subi	%g1, %g1, 4
	call	min_caml_floor
	addi	%g1, %g1, 4
	! 20.000000
	mvhi	%g30, 16800
	mvlo	%g30, 0
	sti	%g30, %g1, 4
	fldi	%f7, %g1, 4
	fmul	%f0, %f0, %f7
	fsub	%f1, %f5, %f0
	! 10.000000
	mvhi	%g30, 16672
	mvlo	%g30, 0
	sti	%g30, %g1, 4
	fldi	%f5, %g1, 4
	fmov	%f0, %f5
	subi	%g1, %g1, 4
	call	fless.2546
	mov	%g7, %g3
	fldi	%f1, %g5, -8
	mov	%g3, %g6
	call	o_param_z.2731
	fsub	%f6, %f1, %f0
	fmul	%f0, %f6, %f8
	call	min_caml_floor
	fmul	%f0, %f0, %f7
	fsub	%f1, %f6, %f0
	fmov	%f0, %f5
	call	fless.2546
	addi	%g1, %g1, 4
	jeq	%g7, %g0, jne_else.7971
	jeq	%g3, %g0, jne_else.7973
	fmov	%f0, %f18
	jmp	jne_cont.7974
jne_else.7973:
	fmov	%f0, %f16
jne_cont.7974:
	jmp	jne_cont.7972
jne_else.7971:
	jeq	%g3, %g0, jne_else.7975
	fmov	%f0, %f16
	jmp	jne_cont.7976
jne_else.7975:
	fmov	%f0, %f18
jne_cont.7976:
jne_cont.7972:
	fsti	%f0, %g0, -1156
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f0, %f4, %f3]
! ret type = Unit
!---------------------------------------------------------------------
add_light.2981:
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fispos.2549
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.7978
	subi	%g3, %g0, -1152
	subi	%g4, %g0, -1128
	fldi	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	vecaccum.2692
	addi	%g1, %g1, 8
	jmp	jne_cont.7979
jne_else.7978:
jne_cont.7979:
	fmov	%f0, %f4
	subi	%g1, %g1, 8
	call	fispos.2549
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.7980
	fmov	%f0, %f4
	subi	%g1, %g1, 8
	call	fsqr.2566
	call	fsqr.2566
	addi	%g1, %g1, 8
	fmul	%f0, %f0, %f3
	fldi	%f1, %g0, -1128
	fadd	%f1, %f1, %f0
	fsti	%f1, %g0, -1128
	fldi	%f1, %g0, -1132
	fadd	%f1, %f1, %f0
	fsti	%f1, %g0, -1132
	fldi	%f1, %g0, -1136
	fadd	%f0, %f1, %f0
	fsti	%f0, %g0, -1136
	return
jne_else.7980:
	return

!---------------------------------------------------------------------
! args = [%g19, %g21]
! fargs = [%f13, %f12]
! ret type = Unit
!---------------------------------------------------------------------
trace_reflections.2985:
	jlt	%g19, %g0, jge_else.7983
	slli	%g3, %g19, 2
	ldi	%g20, %g3, -4
	mov	%g3, %g20
	subi	%g1, %g1, 4
	call	r_dvec.2776
	mov	%g22, %g3
	mov	%g11, %g22
	call	judge_intersection_fast.2967
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7984
	ldi	%g3, %g0, -1176
	slli	%g4, %g3, 2
	ldi	%g3, %g0, -1196
	add	%g4, %g4, %g3
	mov	%g3, %g20
	subi	%g1, %g1, 4
	call	r_surface_id.2774
	addi	%g1, %g1, 4
	jeq	%g4, %g3, jne_else.7986
	jmp	jne_cont.7987
jne_else.7986:
	addi	%g12, %g0, 0
	ldi	%g13, %g0, -1204
	subi	%g1, %g1, 4
	call	shadow_check_one_or_matrix.2938
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.7988
	jmp	jne_cont.7989
jne_else.7988:
	mov	%g3, %g22
	subi	%g1, %g1, 4
	call	d_vec.2770
	addi	%g1, %g1, 4
	subi	%g4, %g0, -1164
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	veciprod.2684
	addi	%g1, %g1, 8
	fsti	%f0, %g1, 4
	mov	%g3, %g20
	subi	%g1, %g1, 12
	call	r_bright.2778
	addi	%g1, %g1, 12
	fmov	%f3, %f0
	fmul	%f1, %f3, %f13
	fldi	%f0, %g1, 4
	fmul	%f0, %f1, %f0
	ldi	%g3, %g1, 0
	fsti	%f0, %g1, 8
	mov	%g4, %g21
	subi	%g1, %g1, 16
	call	veciprod.2684
	addi	%g1, %g1, 16
	fmov	%f1, %f0
	fmul	%f4, %f3, %f1
	fldi	%f0, %g1, 8
	fmov	%f3, %f12
	subi	%g1, %g1, 16
	call	add_light.2981
	addi	%g1, %g1, 16
jne_cont.7989:
jne_cont.7987:
	jmp	jne_cont.7985
jne_else.7984:
jne_cont.7985:
	subi	%g19, %g19, 1
	jmp	trace_reflections.2985
jge_else.7983:
	return

!---------------------------------------------------------------------
! args = [%g23, %g21, %g24]
! fargs = [%f14, %f11]
! ret type = Unit
!---------------------------------------------------------------------
trace_ray.2990:
	addi	%g3, %g0, 4
	jlt	%g3, %g23, jle_else.7991
	mov	%g3, %g24
	subi	%g1, %g1, 4
	call	p_surface_ids.2755
	addi	%g1, %g1, 4
	mov	%g25, %g3
	fsti	%f11, %g1, 0
	mov	%g13, %g21
	subi	%g1, %g1, 8
	call	judge_intersection.2953
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.7992
	ldi	%g8, %g0, -1176
	slli	%g3, %g8, 2
	ldi	%g6, %g3, -1448
	mov	%g3, %g6
	subi	%g1, %g1, 8
	call	o_reflectiontype.2713
	mov	%g26, %g3
	mov	%g3, %g6
	call	o_diffuse.2733
	fmov	%f10, %f0
	fmul	%f13, %f10, %f14
	mov	%g4, %g21
	mov	%g3, %g6
	call	get_nvector.2975
	subi	%g3, %g0, -1180
	subi	%g4, %g0, -1096
	call	veccpy.2673
	addi	%g1, %g1, 8
	subi	%g5, %g0, -1180
	sti	%g6, %g1, 4
	subi	%g1, %g1, 12
	call	utexture.2978
	slli	%g4, %g8, 2
	ldi	%g3, %g0, -1196
	add	%g4, %g4, %g3
	slli	%g3, %g23, 2
	st	%g4, %g25, %g3
	mov	%g3, %g24
	call	p_intersection_points.2753
	slli	%g4, %g23, 2
	ld	%g4, %g3, %g4
	subi	%g3, %g0, -1180
	call	veccpy.2673
	mov	%g3, %g24
	call	p_calc_diffuse.2757
	addi	%g1, %g1, 12
	sti	%g3, %g1, 8
	fmov	%f0, %f19
	fmov	%f1, %f10
	subi	%g1, %g1, 16
	call	fless.2546
	addi	%g1, %g1, 16
	mov	%g4, %g3
	jeq	%g4, %g0, jne_else.7993
	addi	%g5, %g0, 0
	slli	%g4, %g23, 2
	ldi	%g3, %g1, 8
	st	%g5, %g3, %g4
	jmp	jne_cont.7994
jne_else.7993:
	addi	%g5, %g0, 1
	slli	%g4, %g23, 2
	ldi	%g3, %g1, 8
	st	%g5, %g3, %g4
	mov	%g3, %g24
	subi	%g1, %g1, 16
	call	p_energy.2759
	mov	%g5, %g3
	slli	%g3, %g23, 2
	ld	%g4, %g5, %g3
	subi	%g3, %g0, -1152
	call	veccpy.2673
	addi	%g1, %g1, 16
	slli	%g3, %g23, 2
	ld	%g3, %g5, %g3
	! 0.003906
	mvhi	%g30, 15232
	mvlo	%g30, 0
	sti	%g30, %g1, 16
	fldi	%f0, %g1, 16
	fmul	%f0, %f0, %f13
	subi	%g1, %g1, 16
	call	vecscale.2702
	mov	%g3, %g24
	call	p_nvectors.2768
	slli	%g4, %g23, 2
	ld	%g4, %g3, %g4
	subi	%g3, %g0, -1164
	call	veccpy.2673
	addi	%g1, %g1, 16
jne_cont.7994:
	! -2.000000
	mvhi	%g30, 49152
	mvlo	%g30, 0
	sti	%g30, %g1, 16
	fldi	%f3, %g1, 16
	subi	%g3, %g0, -1164
	mov	%g4, %g21
	subi	%g1, %g1, 16
	call	veciprod.2684
	fmul	%f0, %f3, %f0
	subi	%g3, %g0, -1164
	mov	%g4, %g21
	call	vecaccum.2692
	addi	%g1, %g1, 16
	ldi	%g6, %g1, 4
	mov	%g3, %g6
	subi	%g1, %g1, 16
	call	o_hilight.2735
	fmul	%f12, %f14, %f0
	addi	%g12, %g0, 0
	ldi	%g13, %g0, -1204
	call	shadow_check_one_or_matrix.2938
	addi	%g1, %g1, 16
	jeq	%g3, %g0, jne_else.7995
	jmp	jne_cont.7996
jne_else.7995:
	subi	%g3, %g0, -1412
	subi	%g4, %g0, -1164
	subi	%g1, %g1, 16
	call	veciprod.2684
	call	fneg.2562
	fmul	%f5, %f0, %f13
	subi	%g3, %g0, -1412
	mov	%g4, %g21
	call	veciprod.2684
	call	fneg.2562
	fmov	%f4, %f0
	fmov	%f3, %f12
	fmov	%f0, %f5
	call	add_light.2981
	addi	%g1, %g1, 16
jne_cont.7996:
	subi	%g6, %g0, -1180
	subi	%g1, %g1, 16
	call	setup_startp.2904
	addi	%g1, %g1, 16
	ldi	%g3, %g0, 0
	subi	%g19, %g3, 1
	sti	%g21, %g1, 12
	fsti	%f10, %g1, 16
	subi	%g1, %g1, 24
	call	trace_reflections.2985
	fmov	%f0, %f14
	fmov	%f1, %f23
	call	fless.2546
	addi	%g1, %g1, 24
	jeq	%g3, %g0, jne_else.7997
	addi	%g3, %g0, 4
	jlt	%g23, %g3, jle_else.7998
	jmp	jle_cont.7999
jle_else.7998:
	addi	%g3, %g23, 1
	addi	%g4, %g0, -1
	slli	%g3, %g3, 2
	st	%g4, %g25, %g3
jle_cont.7999:
	addi	%g3, %g0, 2
	jeq	%g26, %g3, jne_else.8000
	return
jne_else.8000:
	fldi	%f10, %g1, 16
	fsub	%f0, %f17, %f10
	fmul	%f14, %f14, %f0
	addi	%g23, %g23, 1
	fldi	%f0, %g0, -1192
	fldi	%f11, %g1, 0
	fadd	%f11, %f11, %f0
	ldi	%g21, %g1, 12
	jmp	trace_ray.2990
jne_else.7997:
	return
jne_else.7992:
	addi	%g4, %g0, -1
	slli	%g3, %g23, 2
	st	%g4, %g25, %g3
	jeq	%g23, %g0, jne_else.8003
	subi	%g3, %g0, -1412
	mov	%g4, %g21
	subi	%g1, %g1, 8
	call	veciprod.2684
	call	fneg.2562
	addi	%g1, %g1, 8
	fsti	%f0, %g1, 4
	subi	%g1, %g1, 12
	call	fispos.2549
	addi	%g1, %g1, 12
	jeq	%g3, %g0, jne_else.8004
	fldi	%f0, %g1, 4
	subi	%g1, %g1, 12
	call	fsqr.2566
	addi	%g1, %g1, 12
	fmov	%f1, %f0
	fldi	%f0, %g1, 4
	fmul	%f0, %f1, %f0
	fmul	%f1, %f0, %f14
	fldi	%f0, %g0, -1408
	fmul	%f0, %f1, %f0
	fldi	%f1, %g0, -1128
	fadd	%f1, %f1, %f0
	fsti	%f1, %g0, -1128
	fldi	%f1, %g0, -1132
	fadd	%f1, %f1, %f0
	fsti	%f1, %g0, -1132
	fldi	%f1, %g0, -1136
	fadd	%f0, %f1, %f0
	fsti	%f0, %g0, -1136
	return
jne_else.8004:
	return
jne_else.8003:
	return
jle_else.7991:
	return

!---------------------------------------------------------------------
! args = [%g11]
! fargs = [%f12]
! ret type = Unit
!---------------------------------------------------------------------
trace_diffuse_ray.2996:
	sti	%g11, %g1, 0
	subi	%g1, %g1, 8
	call	judge_intersection_fast.2967
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.8009
	ldi	%g3, %g0, -1176
	slli	%g3, %g3, 2
	ldi	%g14, %g3, -1448
	ldi	%g11, %g1, 0
	mov	%g3, %g11
	subi	%g1, %g1, 8
	call	d_vec.2770
	mov	%g4, %g3
	mov	%g3, %g14
	call	get_nvector.2975
	subi	%g5, %g0, -1180
	mov	%g6, %g14
	call	utexture.2978
	addi	%g12, %g0, 0
	ldi	%g13, %g0, -1204
	call	shadow_check_one_or_matrix.2938
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.8010
	return
jne_else.8010:
	subi	%g3, %g0, -1412
	subi	%g4, %g0, -1164
	subi	%g1, %g1, 8
	call	veciprod.2684
	call	fneg.2562
	addi	%g1, %g1, 8
	fsti	%f0, %g1, 4
	subi	%g1, %g1, 12
	call	fispos.2549
	addi	%g1, %g1, 12
	jeq	%g3, %g0, jne_else.8012
	fldi	%f0, %g1, 4
	fmov	%f1, %f0
	jmp	jne_cont.8013
jne_else.8012:
	fmov	%f1, %f16
jne_cont.8013:
	fmul	%f1, %f12, %f1
	mov	%g3, %g14
	subi	%g1, %g1, 12
	call	o_diffuse.2733
	addi	%g1, %g1, 12
	fmul	%f0, %f1, %f0
	subi	%g3, %g0, -1152
	subi	%g4, %g0, -1140
	jmp	vecaccum.2692
jne_else.8009:
	return

!---------------------------------------------------------------------
! args = [%g22, %g21, %g20, %g19]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
iter_trace_diffuse_rays.2999:
	jlt	%g19, %g0, jge_else.8015
	slli	%g3, %g19, 2
	ld	%g3, %g22, %g3
	subi	%g1, %g1, 4
	call	d_vec.2770
	mov	%g4, %g3
	mov	%g3, %g21
	call	veciprod.2684
	addi	%g1, %g1, 4
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fisneg.2551
	addi	%g1, %g1, 8
	jeq	%g3, %g0, jne_else.8016
	addi	%g3, %g19, 1
	slli	%g3, %g3, 2
	ld	%g11, %g22, %g3
	! -150.000000
	mvhi	%g30, 49942
	mvlo	%g30, 0
	sti	%g30, %g1, 8
	fldi	%f1, %g1, 8
	fldi	%f0, %g1, 0
	fdiv	%f12, %f0, %f1
	subi	%g1, %g1, 8
	call	trace_diffuse_ray.2996
	addi	%g1, %g1, 8
	jmp	jne_cont.8017
jne_else.8016:
	slli	%g3, %g19, 2
	ld	%g11, %g22, %g3
	! 150.000000
	mvhi	%g30, 17174
	mvlo	%g30, 0
	sti	%g30, %g1, 8
	fldi	%f1, %g1, 8
	fldi	%f0, %g1, 0
	fdiv	%f12, %f0, %f1
	subi	%g1, %g1, 8
	call	trace_diffuse_ray.2996
	addi	%g1, %g1, 8
jne_cont.8017:
	subi	%g19, %g19, 2
	jmp	iter_trace_diffuse_rays.2999
jge_else.8015:
	return

!---------------------------------------------------------------------
! args = [%g22, %g21, %g20]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
trace_diffuse_rays.3004:
	mov	%g6, %g20
	subi	%g1, %g1, 4
	call	setup_startp.2904
	addi	%g1, %g1, 4
	addi	%g19, %g0, 118
	jmp	iter_trace_diffuse_rays.2999

!---------------------------------------------------------------------
! args = [%g23, %g21, %g20]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
trace_diffuse_ray_80percent.3008:
	sti	%g20, %g1, 0
	sti	%g21, %g1, 4
	jeq	%g23, %g0, jne_else.8019
	ldi	%g22, %g0, -1004
	subi	%g1, %g1, 12
	call	trace_diffuse_rays.3004
	addi	%g1, %g1, 12
	jmp	jne_cont.8020
jne_else.8019:
jne_cont.8020:
	jeq	%g23, %g28, jne_else.8021
	ldi	%g22, %g0, -1008
	ldi	%g21, %g1, 4
	ldi	%g20, %g1, 0
	subi	%g1, %g1, 12
	call	trace_diffuse_rays.3004
	addi	%g1, %g1, 12
	jmp	jne_cont.8022
jne_else.8021:
jne_cont.8022:
	addi	%g3, %g0, 2
	jeq	%g23, %g3, jne_else.8023
	ldi	%g22, %g0, -1012
	ldi	%g21, %g1, 4
	ldi	%g20, %g1, 0
	subi	%g1, %g1, 12
	call	trace_diffuse_rays.3004
	addi	%g1, %g1, 12
	jmp	jne_cont.8024
jne_else.8023:
jne_cont.8024:
	addi	%g3, %g0, 3
	jeq	%g23, %g3, jne_else.8025
	ldi	%g22, %g0, -1016
	ldi	%g21, %g1, 4
	ldi	%g20, %g1, 0
	subi	%g1, %g1, 12
	call	trace_diffuse_rays.3004
	addi	%g1, %g1, 12
	jmp	jne_cont.8026
jne_else.8025:
jne_cont.8026:
	addi	%g3, %g0, 4
	jeq	%g23, %g3, jne_else.8027
	ldi	%g22, %g0, -1020
	ldi	%g21, %g1, 4
	ldi	%g20, %g1, 0
	jmp	trace_diffuse_rays.3004
jne_else.8027:
	return

!---------------------------------------------------------------------
! args = [%g3, %g24]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
calc_diffuse_using_1point.3012:
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	p_received_ray_20percent.2761
	addi	%g1, %g1, 8
	mov	%g4, %g3
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	p_nvectors.2768
	addi	%g1, %g1, 8
	mov	%g6, %g3
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	p_intersection_points.2753
	addi	%g1, %g1, 8
	mov	%g7, %g3
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	p_energy.2759
	mov	%g25, %g3
	slli	%g5, %g24, 2
	ld	%g5, %g4, %g5
	subi	%g4, %g0, -1140
	mov	%g3, %g5
	call	veccpy.2673
	addi	%g1, %g1, 8
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	p_group_id.2763
	mov	%g23, %g3
	slli	%g3, %g24, 2
	ld	%g21, %g6, %g3
	slli	%g3, %g24, 2
	ld	%g20, %g7, %g3
	call	trace_diffuse_ray_80percent.3008
	addi	%g1, %g1, 8
	slli	%g3, %g24, 2
	ld	%g4, %g25, %g3
	subi	%g3, %g0, -1140
	subi	%g5, %g0, -1128
	jmp	vecaccumv.2705

!---------------------------------------------------------------------
! args = [%g5, %g3, %g7, %g4, %g6]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
calc_diffuse_using_5points.3015:
	slli	%g8, %g5, 2
	ld	%g3, %g3, %g8
	subi	%g1, %g1, 4
	call	p_received_ray_20percent.2761
	mov	%g8, %g3
	subi	%g3, %g5, 1
	slli	%g3, %g3, 2
	ld	%g3, %g7, %g3
	call	p_received_ray_20percent.2761
	mov	%g10, %g3
	slli	%g3, %g5, 2
	ld	%g3, %g7, %g3
	call	p_received_ray_20percent.2761
	mov	%g12, %g3
	addi	%g3, %g5, 1
	slli	%g3, %g3, 2
	ld	%g3, %g7, %g3
	call	p_received_ray_20percent.2761
	mov	%g9, %g3
	slli	%g3, %g5, 2
	ld	%g3, %g4, %g3
	call	p_received_ray_20percent.2761
	mov	%g11, %g3
	slli	%g3, %g6, 2
	ld	%g3, %g8, %g3
	subi	%g4, %g0, -1140
	call	veccpy.2673
	slli	%g3, %g6, 2
	ld	%g3, %g10, %g3
	subi	%g4, %g0, -1140
	call	vecadd.2696
	slli	%g3, %g6, 2
	ld	%g3, %g12, %g3
	subi	%g4, %g0, -1140
	call	vecadd.2696
	slli	%g3, %g6, 2
	ld	%g3, %g9, %g3
	subi	%g4, %g0, -1140
	call	vecadd.2696
	slli	%g3, %g6, 2
	ld	%g3, %g11, %g3
	subi	%g4, %g0, -1140
	call	vecadd.2696
	slli	%g3, %g5, 2
	ld	%g3, %g7, %g3
	call	p_energy.2759
	addi	%g1, %g1, 4
	slli	%g4, %g6, 2
	ld	%g4, %g3, %g4
	subi	%g3, %g0, -1140
	subi	%g5, %g0, -1128
	jmp	vecaccumv.2705

!---------------------------------------------------------------------
! args = [%g3, %g24]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
do_without_neighbors.3021:
	addi	%g4, %g0, 4
	jlt	%g4, %g24, jle_else.8029
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	p_surface_ids.2755
	addi	%g1, %g1, 8
	mov	%g4, %g3
	slli	%g5, %g24, 2
	ld	%g4, %g4, %g5
	jlt	%g4, %g0, jge_else.8030
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	p_calc_diffuse.2757
	addi	%g1, %g1, 8
	mov	%g4, %g3
	slli	%g5, %g24, 2
	ld	%g4, %g4, %g5
	sti	%g24, %g1, 4
	jeq	%g4, %g0, jne_else.8031
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 12
	call	calc_diffuse_using_1point.3012
	addi	%g1, %g1, 12
	jmp	jne_cont.8032
jne_else.8031:
jne_cont.8032:
	ldi	%g24, %g1, 4
	addi	%g24, %g24, 1
	ldi	%g3, %g1, 0
	jmp	do_without_neighbors.3021
jge_else.8030:
	return
jle_else.8029:
	return

!---------------------------------------------------------------------
! args = [%g5, %g4, %g3]
! fargs = []
! ret type = Bool
!---------------------------------------------------------------------
neighbors_exist.3024:
	ldi	%g6, %g0, -1124
	addi	%g3, %g4, 1
	jlt	%g3, %g6, jle_else.8035
	addi	%g3, %g0, 0
	return
jle_else.8035:
	jlt	%g0, %g4, jle_else.8036
	addi	%g3, %g0, 0
	return
jle_else.8036:
	ldi	%g4, %g0, -1120
	addi	%g3, %g5, 1
	jlt	%g3, %g4, jle_else.8037
	addi	%g3, %g0, 0
	return
jle_else.8037:
	jlt	%g0, %g5, jle_else.8038
	addi	%g3, %g0, 0
	return
jle_else.8038:
	addi	%g3, %g0, 1
	return

!---------------------------------------------------------------------
! args = [%g3, %g4]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
get_surface_id.3028:
	subi	%g1, %g1, 4
	call	p_surface_ids.2755
	addi	%g1, %g1, 4
	slli	%g4, %g4, 2
	ld	%g3, %g3, %g4
	return

!---------------------------------------------------------------------
! args = [%g5, %g6, %g8, %g7, %g4]
! fargs = []
! ret type = Bool
!---------------------------------------------------------------------
neighbors_are_available.3031:
	slli	%g3, %g5, 2
	ld	%g3, %g8, %g3
	sti	%g4, %g1, 0
	subi	%g1, %g1, 8
	call	get_surface_id.3028
	addi	%g1, %g1, 8
	mov	%g9, %g3
	slli	%g3, %g5, 2
	ld	%g3, %g6, %g3
	ldi	%g4, %g1, 0
	subi	%g1, %g1, 8
	call	get_surface_id.3028
	addi	%g1, %g1, 8
	jeq	%g3, %g9, jne_else.8039
	addi	%g3, %g0, 0
	return
jne_else.8039:
	slli	%g3, %g5, 2
	ld	%g3, %g7, %g3
	ldi	%g4, %g1, 0
	subi	%g1, %g1, 8
	call	get_surface_id.3028
	addi	%g1, %g1, 8
	jeq	%g3, %g9, jne_else.8040
	addi	%g3, %g0, 0
	return
jne_else.8040:
	subi	%g3, %g5, 1
	slli	%g3, %g3, 2
	ld	%g3, %g8, %g3
	ldi	%g4, %g1, 0
	subi	%g1, %g1, 8
	call	get_surface_id.3028
	addi	%g1, %g1, 8
	jeq	%g3, %g9, jne_else.8041
	addi	%g3, %g0, 0
	return
jne_else.8041:
	addi	%g3, %g5, 1
	slli	%g3, %g3, 2
	ld	%g3, %g8, %g3
	ldi	%g4, %g1, 0
	subi	%g1, %g1, 8
	call	get_surface_id.3028
	addi	%g1, %g1, 8
	jeq	%g3, %g9, jne_else.8042
	addi	%g3, %g0, 0
	return
jne_else.8042:
	addi	%g3, %g0, 1
	return

!---------------------------------------------------------------------
! args = [%g5, %g13, %g14, %g16, %g15, %g24]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
try_exploit_neighbors.3037:
	slli	%g3, %g5, 2
	ld	%g3, %g16, %g3
	addi	%g4, %g0, 4
	jlt	%g4, %g24, jle_else.8043
	sti	%g3, %g1, 0
	mov	%g4, %g24
	subi	%g1, %g1, 8
	call	get_surface_id.3028
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jlt	%g4, %g0, jge_else.8044
	sti	%g5, %g1, 4
	mov	%g4, %g24
	mov	%g7, %g15
	mov	%g8, %g16
	mov	%g6, %g14
	subi	%g1, %g1, 12
	call	neighbors_are_available.3031
	addi	%g1, %g1, 12
	mov	%g4, %g3
	jeq	%g4, %g0, jne_else.8045
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 12
	call	p_calc_diffuse.2757
	addi	%g1, %g1, 12
	slli	%g4, %g24, 2
	ld	%g3, %g3, %g4
	jeq	%g3, %g0, jne_else.8046
	ldi	%g5, %g1, 4
	mov	%g6, %g24
	mov	%g4, %g15
	mov	%g7, %g16
	mov	%g3, %g14
	subi	%g1, %g1, 12
	call	calc_diffuse_using_5points.3015
	addi	%g1, %g1, 12
	jmp	jne_cont.8047
jne_else.8046:
jne_cont.8047:
	addi	%g24, %g24, 1
	ldi	%g5, %g1, 4
	jmp	try_exploit_neighbors.3037
jne_else.8045:
	ldi	%g5, %g1, 4
	slli	%g3, %g5, 2
	ld	%g3, %g16, %g3
	jmp	do_without_neighbors.3021
jge_else.8044:
	return
jle_else.8043:
	return

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
write_ppm_header.3044:
	addi	%g3, %g0, 80
	output	%g3
	addi	%g3, %g0, 51
	output	%g3
	addi	%g3, %g0, 10
	output	%g3
	ldi	%g8, %g0, -1120
	subi	%g1, %g1, 4
	call	print_int.2623
	addi	%g3, %g0, 32
	output	%g3
	ldi	%g8, %g0, -1124
	call	print_int.2623
	addi	%g3, %g0, 32
	output	%g3
	addi	%g8, %g0, 255
	call	print_int.2623
	addi	%g1, %g1, 4
	addi	%g3, %g0, 10
	output	%g3
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f0]
! ret type = Unit
!---------------------------------------------------------------------
write_rgb_element.3046:
	subi	%g1, %g1, 4
	call	min_caml_int_of_float
	addi	%g1, %g1, 4
	addi	%g8, %g0, 255
	jlt	%g8, %g3, jle_else.8050
	jlt	%g3, %g0, jge_else.8052
	mov	%g8, %g3
	jmp	jge_cont.8053
jge_else.8052:
	addi	%g8, %g0, 0
jge_cont.8053:
	jmp	jle_cont.8051
jle_else.8050:
	addi	%g8, %g0, 255
jle_cont.8051:
	jmp	print_int.2623

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
write_rgb.3048:
	fldi	%f0, %g0, -1128
	subi	%g1, %g1, 4
	call	write_rgb_element.3046
	addi	%g3, %g0, 32
	output	%g3
	fldi	%f0, %g0, -1132
	call	write_rgb_element.3046
	addi	%g3, %g0, 32
	output	%g3
	fldi	%f0, %g0, -1136
	call	write_rgb_element.3046
	addi	%g1, %g1, 4
	addi	%g3, %g0, 10
	output	%g3
	return

!---------------------------------------------------------------------
! args = [%g23, %g24]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
pretrace_diffuse_rays.3050:
	addi	%g3, %g0, 4
	jlt	%g3, %g24, jle_else.8054
	mov	%g4, %g24
	mov	%g3, %g23
	subi	%g1, %g1, 4
	call	get_surface_id.3028
	addi	%g1, %g1, 4
	jlt	%g3, %g0, jge_else.8055
	mov	%g3, %g23
	subi	%g1, %g1, 4
	call	p_calc_diffuse.2757
	addi	%g1, %g1, 4
	slli	%g4, %g24, 2
	ld	%g3, %g3, %g4
	jeq	%g3, %g0, jne_else.8056
	mov	%g3, %g23
	subi	%g1, %g1, 4
	call	p_group_id.2763
	mov	%g5, %g3
	subi	%g3, %g0, -1140
	call	vecbzero.2671
	mov	%g3, %g23
	call	p_nvectors.2768
	addi	%g1, %g1, 4
	sti	%g3, %g1, 0
	mov	%g3, %g23
	subi	%g1, %g1, 8
	call	p_intersection_points.2753
	addi	%g1, %g1, 8
	mov	%g4, %g3
	slli	%g5, %g5, 2
	ldi	%g22, %g5, -1004
	slli	%g5, %g24, 2
	ldi	%g3, %g1, 0
	ld	%g21, %g3, %g5
	slli	%g3, %g24, 2
	ld	%g20, %g4, %g3
	subi	%g1, %g1, 8
	call	trace_diffuse_rays.3004
	mov	%g3, %g23
	call	p_received_ray_20percent.2761
	slli	%g4, %g24, 2
	ld	%g4, %g3, %g4
	subi	%g3, %g0, -1140
	call	veccpy.2673
	addi	%g1, %g1, 8
	jmp	jne_cont.8057
jne_else.8056:
jne_cont.8057:
	addi	%g24, %g24, 1
	jmp	pretrace_diffuse_rays.3050
jge_else.8055:
	return
jle_else.8054:
	return

!---------------------------------------------------------------------
! args = [%g31, %g27, %g25]
! fargs = [%f3, %f14, %f13]
! ret type = Unit
!---------------------------------------------------------------------
pretrace_pixels.3053:
	jlt	%g27, %g0, jge_else.8060
	fldi	%f4, %g0, -1108
	ldi	%g3, %g0, -1112
	sub	%g3, %g27, %g3
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmul	%f0, %f4, %f0
	fldi	%f1, %g0, -1072
	fmul	%f1, %f0, %f1
	fadd	%f1, %f1, %f3
	fsti	%f1, %g0, -1036
	fldi	%f1, %g0, -1076
	fmul	%f1, %f0, %f1
	fadd	%f1, %f1, %f14
	fsti	%f1, %g0, -1040
	fldi	%f1, %g0, -1080
	fmul	%f0, %f0, %f1
	fadd	%f0, %f0, %f13
	fsti	%f0, %g0, -1044
	addi	%g5, %g0, 0
	subi	%g4, %g0, -1036
	call	vecunit_sgn.2681
	subi	%g3, %g0, -1128
	call	vecbzero.2671
	subi	%g3, %g0, -1424
	subi	%g4, %g0, -1096
	call	veccpy.2673
	addi	%g1, %g1, 4
	addi	%g23, %g0, 0
	slli	%g3, %g27, 2
	ld	%g24, %g31, %g3
	subi	%g21, %g0, -1036
	fsti	%f13, %g1, 0
	fsti	%f14, %g1, 4
	fsti	%f3, %g1, 8
	sti	%g25, %g1, 12
	fmov	%f11, %f16
	fmov	%f14, %f17
	subi	%g1, %g1, 20
	call	trace_ray.2990
	slli	%g3, %g27, 2
	ld	%g3, %g31, %g3
	call	p_rgb.2751
	mov	%g4, %g3
	subi	%g3, %g0, -1128
	call	veccpy.2673
	addi	%g1, %g1, 20
	slli	%g3, %g27, 2
	ld	%g3, %g31, %g3
	ldi	%g25, %g1, 12
	mov	%g4, %g25
	subi	%g1, %g1, 20
	call	p_set_group_id.2765
	slli	%g3, %g27, 2
	ld	%g23, %g31, %g3
	addi	%g24, %g0, 0
	call	pretrace_diffuse_rays.3050
	subi	%g27, %g27, 1
	addi	%g3, %g0, 1
	mov	%g4, %g25
	call	add_mod5.2660
	addi	%g1, %g1, 20
	fldi	%f3, %g1, 8
	fldi	%f14, %g1, 4
	fldi	%f13, %g1, 0
	mov	%g25, %g3
	jmp	pretrace_pixels.3053
jge_else.8060:
	return

!---------------------------------------------------------------------
! args = [%g31, %g3, %g25]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
pretrace_line.3060:
	fldi	%f3, %g0, -1108
	ldi	%g4, %g0, -1116
	sub	%g3, %g3, %g4
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fmul	%f0, %f3, %f0
	fldi	%f1, %g0, -1060
	fmul	%f2, %f0, %f1
	fldi	%f1, %g0, -1048
	fadd	%f3, %f2, %f1
	fldi	%f1, %g0, -1064
	fmul	%f2, %f0, %f1
	fldi	%f1, %g0, -1052
	fadd	%f14, %f2, %f1
	fldi	%f1, %g0, -1068
	fmul	%f1, %f0, %f1
	fldi	%f0, %g0, -1056
	fadd	%f13, %f1, %f0
	ldi	%g3, %g0, -1120
	subi	%g27, %g3, 1
	jmp	pretrace_pixels.3053

!---------------------------------------------------------------------
! args = [%g27, %g26, %g31, %g16, %g15]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
scan_pixel.3064:
	ldi	%g3, %g0, -1120
	jlt	%g27, %g3, jle_else.8062
	return
jle_else.8062:
	slli	%g3, %g27, 2
	ld	%g3, %g16, %g3
	subi	%g1, %g1, 4
	call	p_rgb.2751
	subi	%g4, %g0, -1128
	call	veccpy.2673
	mov	%g3, %g15
	mov	%g4, %g26
	mov	%g5, %g27
	call	neighbors_exist.3024
	addi	%g1, %g1, 4
	sti	%g15, %g1, 0
	sti	%g16, %g1, 4
	jeq	%g3, %g0, jne_else.8064
	addi	%g24, %g0, 0
	mov	%g14, %g31
	mov	%g13, %g26
	mov	%g5, %g27
	subi	%g1, %g1, 12
	call	try_exploit_neighbors.3037
	addi	%g1, %g1, 12
	jmp	jne_cont.8065
jne_else.8064:
	slli	%g3, %g27, 2
	ld	%g3, %g16, %g3
	addi	%g24, %g0, 0
	subi	%g1, %g1, 12
	call	do_without_neighbors.3021
	addi	%g1, %g1, 12
jne_cont.8065:
	subi	%g1, %g1, 12
	call	write_rgb.3048
	addi	%g1, %g1, 12
	addi	%g27, %g27, 1
	ldi	%g16, %g1, 4
	ldi	%g15, %g1, 0
	jmp	scan_pixel.3064

!---------------------------------------------------------------------
! args = [%g26, %g31, %g16, %g15, %g25]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
scan_line.3070:
	ldi	%g3, %g0, -1124
	jlt	%g26, %g3, jle_else.8066
	return
jle_else.8066:
	subi	%g3, %g3, 1
	sti	%g25, %g1, 0
	sti	%g15, %g1, 4
	sti	%g16, %g1, 8
	sti	%g31, %g1, 12
	sti	%g26, %g1, 16
	jlt	%g26, %g3, jle_else.8068
	jmp	jle_cont.8069
jle_else.8068:
	addi	%g3, %g26, 1
	mov	%g31, %g15
	subi	%g1, %g1, 24
	call	pretrace_line.3060
	addi	%g1, %g1, 24
jle_cont.8069:
	addi	%g27, %g0, 0
	ldi	%g26, %g1, 16
	ldi	%g31, %g1, 12
	ldi	%g16, %g1, 8
	ldi	%g15, %g1, 4
	subi	%g1, %g1, 24
	call	scan_pixel.3064
	addi	%g1, %g1, 24
	ldi	%g26, %g1, 16
	addi	%g26, %g26, 1
	addi	%g3, %g0, 2
	ldi	%g25, %g1, 0
	mov	%g4, %g25
	subi	%g1, %g1, 24
	call	add_mod5.2660
	addi	%g1, %g1, 24
	ldi	%g16, %g1, 8
	ldi	%g15, %g1, 4
	ldi	%g31, %g1, 12
	mov	%g25, %g3
	mov	%g30, %g15
	mov	%g15, %g31
	mov	%g31, %g16
	mov	%g16, %g30
	jmp	scan_line.3070

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = Array(Array(Float))
!---------------------------------------------------------------------
create_float5x3array.3076:
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	mov	%g4, %g3
	addi	%g3, %g0, 5
	call	min_caml_create_array
	addi	%g1, %g1, 4
	addi	%g5, %g0, 3
	sti	%g3, %g1, 0
	mov	%g3, %g5
	fmov	%f0, %f16
	subi	%g1, %g1, 8
	call	min_caml_create_float_array
	addi	%g1, %g1, 8
	mov	%g4, %g3
	ldi	%g3, %g1, 0
	sti	%g4, %g3, -4
	addi	%g5, %g0, 3
	mov	%g3, %g5
	fmov	%f0, %f16
	subi	%g1, %g1, 8
	call	min_caml_create_float_array
	addi	%g1, %g1, 8
	mov	%g4, %g3
	ldi	%g3, %g1, 0
	sti	%g4, %g3, -8
	addi	%g5, %g0, 3
	mov	%g3, %g5
	fmov	%f0, %f16
	subi	%g1, %g1, 8
	call	min_caml_create_float_array
	addi	%g1, %g1, 8
	mov	%g4, %g3
	ldi	%g3, %g1, 0
	sti	%g4, %g3, -12
	addi	%g5, %g0, 3
	mov	%g3, %g5
	fmov	%f0, %f16
	subi	%g1, %g1, 8
	call	min_caml_create_float_array
	addi	%g1, %g1, 8
	mov	%g4, %g3
	ldi	%g3, %g1, 0
	sti	%g4, %g3, -16
	return

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = (Array(Float) * Array(Array(Float)) * Array(Int) * Array(Bool) * Array(Array(Float)) * Array(Array(Float)) * Array(Int) * Array(Array(Float)))
!---------------------------------------------------------------------
create_pixel.3078:
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	mov	%g7, %g3
	call	create_float5x3array.3076
	mov	%g9, %g3
	addi	%g3, %g0, 5
	addi	%g4, %g0, 0
	call	min_caml_create_array
	mov	%g6, %g3
	addi	%g3, %g0, 5
	addi	%g4, %g0, 0
	call	min_caml_create_array
	mov	%g12, %g3
	call	create_float5x3array.3076
	mov	%g11, %g3
	call	create_float5x3array.3076
	mov	%g8, %g3
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	call	min_caml_create_array
	mov	%g10, %g3
	call	create_float5x3array.3076
	addi	%g1, %g1, 4
	mov	%g4, %g3
	mov	%g3, %g2
	addi	%g2, %g2, 32
	sti	%g4, %g3, -28
	sti	%g10, %g3, -24
	sti	%g8, %g3, -20
	sti	%g11, %g3, -16
	sti	%g12, %g3, -12
	sti	%g6, %g3, -8
	sti	%g9, %g3, -4
	sti	%g7, %g3, 0
	return

!---------------------------------------------------------------------
! args = [%g13, %g14]
! fargs = []
! ret type = Array((Array(Float) * Array(Array(Float)) * Array(Int) * Array(Bool) * Array(Array(Float)) * Array(Array(Float)) * Array(Int) * Array(Array(Float))))
!---------------------------------------------------------------------
init_line_elements.3080:
	jlt	%g14, %g0, jge_else.8070
	subi	%g1, %g1, 4
	call	create_pixel.3078
	addi	%g1, %g1, 4
	slli	%g4, %g14, 2
	st	%g3, %g13, %g4
	subi	%g14, %g14, 1
	jmp	init_line_elements.3080
jge_else.8070:
	mov	%g3, %g13
	return

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = Array((Array(Float) * Array(Array(Float)) * Array(Int) * Array(Bool) * Array(Array(Float)) * Array(Array(Float)) * Array(Int) * Array(Array(Float))))
!---------------------------------------------------------------------
create_pixelline.3083:
	ldi	%g3, %g0, -1120
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	create_pixel.3078
	addi	%g1, %g1, 8
	mov	%g4, %g3
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	min_caml_create_array
	addi	%g1, %g1, 8
	mov	%g13, %g3
	ldi	%g3, %g0, -1120
	subi	%g14, %g3, 2
	jmp	init_line_elements.3080

!---------------------------------------------------------------------
! args = []
! fargs = [%f0, %f6]
! ret type = Float
!---------------------------------------------------------------------
adjust_position.3085:
	fmul	%f0, %f0, %f0
	fadd	%f0, %f0, %f23
	fsqrt	%f7, %f0
	fdiv	%f0, %f17, %f7
	subi	%g1, %g1, 4
	call	atan.2575
	fmul	%f0, %f0, %f6
	call	tan.2577
	addi	%g1, %g1, 4
	fmul	%f0, %f0, %f7
	return

!---------------------------------------------------------------------
! args = [%g4, %g6, %g5]
! fargs = [%f1, %f8, %f10, %f9]
! ret type = Unit
!---------------------------------------------------------------------
calc_dirvec.3088:
	addi	%g3, %g0, 5
	jlt	%g4, %g3, jle_else.8071
	fmov	%f0, %f1
	subi	%g1, %g1, 4
	call	fsqr.2566
	fmov	%f2, %f0
	fmov	%f0, %f8
	call	fsqr.2566
	fadd	%f0, %f2, %f0
	fadd	%f0, %f0, %f17
	fsqrt	%f0, %f0
	fdiv	%f5, %f1, %f0
	fdiv	%f4, %f8, %f0
	fdiv	%f3, %f17, %f0
	slli	%g3, %g6, 2
	ldi	%g4, %g3, -1004
	slli	%g3, %g5, 2
	ld	%g3, %g4, %g3
	call	d_vec.2770
	fmov	%f0, %f3
	fmov	%f1, %f4
	fmov	%f2, %f5
	call	vecset.2663
	addi	%g3, %g5, 40
	slli	%g3, %g3, 2
	ld	%g3, %g4, %g3
	call	d_vec.2770
	fmov	%f0, %f4
	call	fneg.2562
	fmov	%f7, %f0
	fmov	%f0, %f7
	fmov	%f1, %f3
	fmov	%f2, %f5
	call	vecset.2663
	addi	%g3, %g5, 80
	slli	%g3, %g3, 2
	ld	%g3, %g4, %g3
	call	d_vec.2770
	fmov	%f0, %f5
	call	fneg.2562
	fmov	%f6, %f0
	fmov	%f0, %f7
	fmov	%f1, %f6
	fmov	%f2, %f3
	call	vecset.2663
	addi	%g3, %g5, 1
	slli	%g3, %g3, 2
	ld	%g3, %g4, %g3
	call	d_vec.2770
	fmov	%f0, %f3
	call	fneg.2562
	fmov	%f3, %f0
	fmov	%f0, %f3
	fmov	%f1, %f7
	fmov	%f2, %f6
	call	vecset.2663
	addi	%g3, %g5, 41
	slli	%g3, %g3, 2
	ld	%g3, %g4, %g3
	call	d_vec.2770
	fmov	%f0, %f4
	fmov	%f1, %f3
	fmov	%f2, %f6
	call	vecset.2663
	addi	%g3, %g5, 81
	slli	%g3, %g3, 2
	ld	%g3, %g4, %g3
	call	d_vec.2770
	addi	%g1, %g1, 4
	fmov	%f0, %f4
	fmov	%f1, %f5
	fmov	%f2, %f3
	jmp	vecset.2663
jle_else.8071:
	fmov	%f6, %f10
	fmov	%f0, %f8
	subi	%g1, %g1, 4
	call	adjust_position.3085
	addi	%g1, %g1, 4
	addi	%g4, %g4, 1
	fsti	%f0, %g1, 0
	fmov	%f6, %f9
	subi	%g1, %g1, 8
	call	adjust_position.3085
	addi	%g1, %g1, 8
	fmov	%f8, %f0
	fldi	%f0, %g1, 0
	fmov	%f1, %f0
	jmp	calc_dirvec.3088

!---------------------------------------------------------------------
! args = [%g8, %g6, %g7]
! fargs = [%f9]
! ret type = Unit
!---------------------------------------------------------------------
calc_dirvecs.3096:
	jlt	%g8, %g0, jge_else.8072
	mov	%g3, %g8
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fmul	%f11, %f0, %f29
	fsub	%f10, %f11, %f28
	addi	%g4, %g0, 0
	fsti	%f9, %g1, 0
	sti	%g6, %g1, 4
	mov	%g5, %g7
	fmov	%f8, %f16
	fmov	%f1, %f16
	subi	%g1, %g1, 12
	call	calc_dirvec.3088
	addi	%g1, %g1, 12
	fadd	%f10, %f11, %f23
	addi	%g4, %g0, 0
	addi	%g5, %g7, 2
	fldi	%f9, %g1, 0
	ldi	%g6, %g1, 4
	fmov	%f8, %f16
	fmov	%f1, %f16
	subi	%g1, %g1, 12
	call	calc_dirvec.3088
	addi	%g1, %g1, 12
	subi	%g8, %g8, 1
	addi	%g3, %g0, 1
	ldi	%g6, %g1, 4
	mov	%g4, %g6
	subi	%g1, %g1, 12
	call	add_mod5.2660
	addi	%g1, %g1, 12
	fldi	%f9, %g1, 0
	mov	%g6, %g3
	jmp	calc_dirvecs.3096
jge_else.8072:
	return

!---------------------------------------------------------------------
! args = [%g9, %g6, %g7]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
calc_dirvec_rows.3101:
	jlt	%g9, %g0, jge_else.8074
	mov	%g3, %g9
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fmul	%f0, %f0, %f29
	fsub	%f9, %f0, %f28
	addi	%g8, %g0, 4
	sti	%g7, %g1, 0
	sti	%g6, %g1, 4
	subi	%g1, %g1, 12
	call	calc_dirvecs.3096
	addi	%g1, %g1, 12
	subi	%g9, %g9, 1
	addi	%g3, %g0, 2
	ldi	%g6, %g1, 4
	mov	%g4, %g6
	subi	%g1, %g1, 12
	call	add_mod5.2660
	addi	%g1, %g1, 12
	ldi	%g7, %g1, 0
	addi	%g7, %g7, 4
	mov	%g6, %g3
	jmp	calc_dirvec_rows.3101
jge_else.8074:
	return

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = (Array(Float) * Array(Array(Float)))
!---------------------------------------------------------------------
create_dirvec.3105:
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	mov	%g4, %g3
	ldi	%g3, %g0, -1692
	sti	%g4, %g1, 0
	subi	%g1, %g1, 8
	call	min_caml_create_array
	addi	%g1, %g1, 8
	mov	%g5, %g3
	mov	%g3, %g2
	addi	%g2, %g2, 8
	sti	%g5, %g3, -4
	ldi	%g4, %g1, 0
	sti	%g4, %g3, 0
	return

!---------------------------------------------------------------------
! args = [%g7, %g6]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
create_dirvec_elements.3107:
	jlt	%g6, %g0, jge_else.8076
	subi	%g1, %g1, 4
	call	create_dirvec.3105
	addi	%g1, %g1, 4
	slli	%g4, %g6, 2
	st	%g3, %g7, %g4
	subi	%g6, %g6, 1
	jmp	create_dirvec_elements.3107
jge_else.8076:
	return

!---------------------------------------------------------------------
! args = [%g8]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
create_dirvecs.3110:
	jlt	%g8, %g0, jge_else.8078
	addi	%g3, %g0, 120
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	create_dirvec.3105
	addi	%g1, %g1, 8
	mov	%g4, %g3
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	min_caml_create_array
	slli	%g4, %g8, 2
	sti	%g3, %g4, -1004
	slli	%g3, %g8, 2
	ldi	%g7, %g3, -1004
	addi	%g6, %g0, 118
	call	create_dirvec_elements.3107
	addi	%g1, %g1, 8
	subi	%g8, %g8, 1
	jmp	create_dirvecs.3110
jge_else.8078:
	return

!---------------------------------------------------------------------
! args = [%g12, %g11]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
init_dirvec_constants.3112:
	jlt	%g11, %g0, jge_else.8080
	slli	%g3, %g11, 2
	ld	%g9, %g12, %g3
	subi	%g1, %g1, 4
	call	setup_dirvec_constants.2899
	addi	%g1, %g1, 4
	subi	%g11, %g11, 1
	jmp	init_dirvec_constants.3112
jge_else.8080:
	return

!---------------------------------------------------------------------
! args = [%g13]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
init_vecset_constants.3115:
	jlt	%g13, %g0, jge_else.8082
	slli	%g3, %g13, 2
	ldi	%g12, %g3, -1004
	addi	%g11, %g0, 119
	subi	%g1, %g1, 4
	call	init_dirvec_constants.3112
	addi	%g1, %g1, 4
	subi	%g13, %g13, 1
	jmp	init_vecset_constants.3115
jge_else.8082:
	return

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
init_dirvecs.3117:
	addi	%g8, %g0, 4
	subi	%g1, %g1, 4
	call	create_dirvecs.3110
	addi	%g9, %g0, 9
	addi	%g6, %g0, 0
	addi	%g7, %g0, 0
	call	calc_dirvec_rows.3101
	addi	%g1, %g1, 4
	addi	%g13, %g0, 4
	jmp	init_vecset_constants.3115

!---------------------------------------------------------------------
! args = [%g12, %g11]
! fargs = [%f9, %f2, %f1, %f0]
! ret type = Unit
!---------------------------------------------------------------------
add_reflection.3119:
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	create_dirvec.3105
	mov	%g9, %g3
	mov	%g3, %g9
	call	d_vec.2770
	addi	%g1, %g1, 8
	fldi	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	vecset.2663
	addi	%g1, %g1, 8
	sti	%g9, %g1, 4
	subi	%g1, %g1, 12
	call	setup_dirvec_constants.2899
	addi	%g1, %g1, 12
	mov	%g3, %g2
	addi	%g2, %g2, 12
	fsti	%f9, %g3, -8
	ldi	%g9, %g1, 4
	sti	%g9, %g3, -4
	sti	%g11, %g3, 0
	slli	%g4, %g12, 2
	sti	%g3, %g4, -4
	return

!---------------------------------------------------------------------
! args = [%g3, %g4]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
setup_rect_reflection.3126:
	slli	%g14, %g3, 2
	ldi	%g13, %g0, 0
	mov	%g3, %g4
	subi	%g1, %g1, 4
	call	o_diffuse.2733
	fsub	%f9, %f17, %f0
	fldi	%f2, %g0, -1412
	fmov	%f0, %f2
	call	fneg.2562
	fmov	%f11, %f0
	fldi	%f0, %g0, -1416
	call	fneg.2562
	fmov	%f10, %f0
	fldi	%f0, %g0, -1420
	call	fneg.2562
	addi	%g1, %g1, 4
	addi	%g11, %g14, 1
	fsti	%f0, %g1, 0
	fsti	%f9, %g1, 4
	mov	%g12, %g13
	fmov	%f1, %f10
	subi	%g1, %g1, 12
	call	add_reflection.3119
	addi	%g1, %g1, 12
	addi	%g12, %g13, 1
	addi	%g11, %g14, 2
	fldi	%f1, %g0, -1416
	fldi	%f9, %g1, 4
	fldi	%f0, %g1, 0
	fmov	%f2, %f11
	subi	%g1, %g1, 12
	call	add_reflection.3119
	addi	%g1, %g1, 12
	addi	%g12, %g13, 2
	addi	%g11, %g14, 3
	fldi	%f0, %g0, -1420
	fldi	%f9, %g1, 4
	fmov	%f1, %f10
	fmov	%f2, %f11
	subi	%g1, %g1, 12
	call	add_reflection.3119
	addi	%g1, %g1, 12
	addi	%g3, %g13, 3
	sti	%g3, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g3, %g5]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
setup_surface_reflection.3129:
	slli	%g3, %g3, 2
	addi	%g11, %g3, 1
	ldi	%g12, %g0, 0
	mov	%g3, %g5
	subi	%g1, %g1, 4
	call	o_diffuse.2733
	fsub	%f9, %f17, %f0
	mov	%g3, %g5
	call	o_param_abc.2725
	subi	%g4, %g0, -1412
	call	veciprod.2684
	fmov	%f3, %f0
	mov	%g3, %g5
	call	o_param_a.2719
	fmul	%f0, %f20, %f0
	fmul	%f1, %f0, %f3
	fldi	%f0, %g0, -1412
	fsub	%f2, %f1, %f0
	mov	%g3, %g5
	call	o_param_b.2721
	fmul	%f0, %f20, %f0
	fmul	%f1, %f0, %f3
	fldi	%f0, %g0, -1416
	fsub	%f1, %f1, %f0
	mov	%g3, %g5
	call	o_param_c.2723
	addi	%g1, %g1, 4
	fmul	%f0, %f20, %f0
	fmul	%f3, %f0, %f3
	fldi	%f0, %g0, -1420
	fsub	%f0, %f3, %f0
	sti	%g12, %g1, 0
	subi	%g1, %g1, 8
	call	add_reflection.3119
	addi	%g1, %g1, 8
	ldi	%g12, %g1, 0
	addi	%g3, %g12, 1
	sti	%g3, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g15]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
setup_reflections.3132:
	jlt	%g15, %g0, jge_else.8087
	slli	%g3, %g15, 2
	ldi	%g4, %g3, -1448
	mov	%g3, %g4
	subi	%g1, %g1, 4
	call	o_reflectiontype.2713
	addi	%g1, %g1, 4
	addi	%g5, %g0, 2
	jeq	%g3, %g5, jne_else.8088
	return
jne_else.8088:
	mov	%g3, %g4
	subi	%g1, %g1, 4
	call	o_diffuse.2733
	fmov	%f1, %f0
	fmov	%f0, %f17
	call	fless.2546
	addi	%g1, %g1, 4
	jeq	%g3, %g0, jne_else.8090
	mov	%g3, %g4
	subi	%g1, %g1, 4
	call	o_form.2711
	addi	%g1, %g1, 4
	jeq	%g3, %g28, jne_else.8091
	addi	%g5, %g0, 2
	jeq	%g3, %g5, jne_else.8092
	return
jne_else.8092:
	mov	%g5, %g4
	mov	%g3, %g15
	jmp	setup_surface_reflection.3129
jne_else.8091:
	mov	%g3, %g15
	jmp	setup_rect_reflection.3126
jne_else.8090:
	return
jge_else.8087:
	return

!---------------------------------------------------------------------
! args = [%g6, %g3]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
rt.3134:
	sti	%g6, %g0, -1120
	sti	%g3, %g0, -1124
	srli	%g4, %g6, 1
	sti	%g4, %g0, -1112
	srli	%g3, %g3, 1
	sti	%g3, %g0, -1116
	! 128.000000
	mvhi	%g30, 17152
	mvlo	%g30, 0
	sti	%g30, %g1, 4
	fldi	%f3, %g1, 4
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fdiv	%f0, %f3, %f0
	fsti	%f0, %g0, -1108
	call	create_pixelline.3083
	mov	%g31, %g3
	call	create_pixelline.3083
	mov	%g16, %g3
	call	create_pixelline.3083
	addi	%g1, %g1, 4
	mov	%g18, %g3
	sti	%g16, %g1, 0
	subi	%g1, %g1, 8
	call	read_parameter.2801
	call	write_ppm_header.3044
	call	init_dirvecs.3117
	subi	%g3, %g0, -740
	call	d_vec.2770
	mov	%g4, %g3
	subi	%g3, %g0, -1412
	call	veccpy.2673
	subi	%g9, %g0, -740
	call	setup_dirvec_constants.2899
	ldi	%g3, %g0, -1692
	subi	%g15, %g3, 1
	call	setup_reflections.3132
	addi	%g1, %g1, 8
	addi	%g3, %g0, 0
	addi	%g25, %g0, 0
	ldi	%g16, %g1, 0
	sti	%g18, %g1, 4
	sti	%g31, %g1, 8
	mov	%g31, %g16
	subi	%g1, %g1, 16
	call	pretrace_line.3060
	addi	%g1, %g1, 16
	addi	%g26, %g0, 0
	addi	%g25, %g0, 2
	ldi	%g31, %g1, 8
	ldi	%g16, %g1, 0
	ldi	%g18, %g1, 4
	mov	%g15, %g18
	jmp	scan_line.3070
