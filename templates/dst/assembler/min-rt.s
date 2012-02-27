.init_heap_size	1440
FLOAT_ZERO:		! 0.0
	.long 0x0
FLOAT_ONE:		! 1.0
	.long 0x3f800000
FLOAT_MONE:		! -1.0
	.long 0xbf800000
FLOAT_MAGICI:	! 8388608
	.long 0x800000
FLOAT_MAGICF:	! 8388608.0
	.long 0x4b000000
FLOAT_MAGICFHX:	! 1258291200
	.long 0x4b000000
l.7379:	! 128.000000
	.long	0x43000000
l.7321:	! 0.900000
	.long	0x3f66665e
l.7319:	! 0.200000
	.long	0x3e4cccc4
l.7124:	! 150.000000
	.long	0x43160000
l.7120:	! -150.000000
	.long	0xc3160000
l.7085:	! 0.100000
	.long	0x3dccccc4
l.7073:	! -2.000000
	.long	0xc0000000
l.7068:	! 0.003906
	.long	0x3b800000
l.7017:	! 20.000000
	.long	0x41a00000
l.7015:	! 0.050000
	.long	0x3d4cccc4
l.7007:	! 0.250000
	.long	0x3e800000
l.6998:	! 10.000000
	.long	0x41200000
l.6991:	! 0.300000
	.long	0x3e999999
l.6986:	! 0.150000
	.long	0x3e199999
l.6979:	! 3.141593
	.long	0x40490fda
l.6977:	! 30.000000
	.long	0x41f00000
l.6975:	! 15.000000
	.long	0x41700000
l.6973:	! 0.000100
	.long	0x38d1b70f
l.6896:	! 100000000.000000
	.long	0x4cbebc20
l.6847:	! -0.100000
	.long	0xbdccccc4
l.6819:	! 0.010000
	.long	0x3c23d70a
l.6817:	! -0.200000
	.long	0xbe4cccc4
l.6481:	! -200.000000
	.long	0xc3480000
l.6478:	! 200.000000
	.long	0x43480000
l.6473:	! 0.017453
	.long	0x3c8efa2d
l.6320:	! 3.141593
	.long	0x40490fda
l.6317:	! 6.283185
	.long	0x40c90fda
l.6314:	! 9.000000
	.long	0x41100000
l.6311:	! 2.000000
	.long	0x40000000
l.6309:	! 2.500000
	.long	0x40200000
l.6307:	! -1.570796
	.long	0xbfc90fda
l.6305:	! 1.570796
	.long	0x3fc90fda
l.6302:	! 11.000000
	.long	0x41300000
l.6300:	! -1.000000
	.long	0xbf800000
l.6297:	! 1.000000
	.long	0x3f800000
l.6294:	! 0.500000
	.long	0x3f000000
l.6225:	! 1000000000.000000
	.long	0x4e6e6b28
l.6221:	! 255.000000
	.long	0x437f0000
l.6207:	! 0.000000
	.long	0x0
	jmp	min_caml_start

!#####################################################################
!
! 		↓　ここから lib_asm.s
!
!#####################################################################

! * create_array
min_caml_create_array:
	slli %g3, %g3, 2
	add %g5, %g3, %g2
	mov %g3, %g2
CREATE_ARRAY_LOOP:
	jlt %g5, %g2, CREATE_ARRAY_END
	jeq %g5, %g2, CREATE_ARRAY_END
	sti %g4, %g2, 0
	addi %g2, %g2, 4
	jmp CREATE_ARRAY_LOOP
CREATE_ARRAY_END:
	return

! * create_float_array
min_caml_create_float_array:
	slli %g3, %g3, 2
	add %g4, %g3, %g2
	mov %g3, %g2
CREATE_FLOAT_ARRAY_LOOP:
	jlt %g4, %g2, CREATE_FLOAT_ARRAY_END
	jeq %g4, %g2, CREATE_FLOAT_ARRAY_END
	fsti %f0, %g2, 0
	addi %g2, %g2, 4
	jmp CREATE_FLOAT_ARRAY_LOOP
CREATE_FLOAT_ARRAY_END:
	return

! * floor		%f0 + MAGICF - MAGICF
min_caml_floor:
	fmov %f1, %f0
	! %f4 = 0.0
	setL %g3, FLOAT_ZERO
	fldi %f4, %g3, 0
	fjlt %f4, %f0, FLOOR_POSITIVE	! if (%f4 <= %f0) goto FLOOR_PISITIVE
	fjeq %f4, %f0, FLOOR_POSITIVE
FLOOR_NEGATIVE:
	fneg %f0, %f0
	setL %g3, FLOAT_MAGICF
	! %f2 = FLOAT_MAGICF
	fldi %f2, %g3, 0
	fjlt %f0, %f2, FLOOR_NEGATIVE_MAIN
	fjeq %f0, %f2, FLOOR_NEGATIVE_MAIN
	fneg %f0, %f0
	return
FLOOR_NEGATIVE_MAIN:
	fadd %f0, %f0, %f2
	fsub %f0, %f0, %f2
	fneg %f1, %f1
	fjlt %f1, %f0, FLOOR_RET2
	fjeq %f1, %f0, FLOOR_RET2
	fadd %f0, %f0, %f2
	! %f3 = 1.0
	setL %g3, FLOAT_ONE
	fldi %f3, %g3, 0
	fadd %f0, %f0, %f3
	fsub %f0, %f0, %f2
	fneg %f0, %f0
	return
FLOOR_POSITIVE:
	setL %g3, FLOAT_MAGICF
	fldi %f2, %g3, 0
	fjlt %f0, %f2, FLOOR_POSITIVE_MAIN
	fjeq %f0, %f2, FLOOR_POSITIVE_MAIN
	return
FLOOR_POSITIVE_MAIN:
	fmov %f1, %f0
	fadd %f0, %f0, %f2
	fsti %f0, %g1, 0
	ldi %g4, %g1, 0
	fsub %f0, %f0, %f2
	fsti %f0, %g1, 0
	ldi %g4, %g1, 0
	fjlt %f0, %f1, FLOOR_RET
	fjeq %f0, %f1, FLOOR_RET
	setL %g3, FLOAT_ONE
	fldi %f3, %g3, 0
	fsub %f0, %f0, %f3
FLOOR_RET:
	return
FLOOR_RET2:
	fneg %f0, %f0
	return
	
min_caml_ceil:
	fneg %f0, %f0
	call min_caml_floor
	fneg %f0, %f0
	return

! * float_of_int
min_caml_float_of_int:
	jlt %g0, %g3, ITOF_MAIN		! if (%g0 <= %g3) goto ITOF_MAIN
	jeq %g0, %g3, ITOF_MAIN
	sub %g3, %g0, %g3
	call ITOF_MAIN
	fneg %f0, %f0
	return
ITOF_MAIN:

	! %f1 <= FLOAT_MAGICF
	! %g4 <= FLOAT_MAGICFHX
	! %g5 <= FLOAT_MAGICI

	setL %g5, FLOAT_MAGICF
	fldi %f1, %g5, 0
	setL %g5, FLOAT_MAGICFHX
	ldi %g4, %g5, 0
	setL %g5, FLOAT_MAGICI
	ldi %g5, %g5, 0
	jlt %g5, %g3, ITOF_BIG
	jeq %g5, %g3, ITOF_BIG
	add %g3, %g3, %g4
	sti %g3, %g1, 0
	fldi %f0, %g1, 0
	fsub %f0, %f0, %f1
	return
ITOF_BIG:
	setL %g4, FLOAT_ZERO
	fldi %f2, %g4, 0
ITOF_LOOP:
	sub %g3, %g3, %g5
	fadd %f2, %f2, %f1
	jlt %g5, %g3, ITOF_LOOP
	jeq %g5, %g3, ITOF_LOOP
	add %g3, %g3, %g4
	sti %g3, %g1, 0
	fldi %f0, %g1, 0
	fsub %f0, %f0, %f1
	fadd %f0, %f0, %f2
	return

! * int_of_float
min_caml_int_of_float:
	! %f1 <= 0.0
	setL %g3, FLOAT_ZERO
	fldi %f1, %g3, 0
	fjlt %f1, %f0, FTOI_MAIN			! if (0.0 <= %f0) goto FTOI_MAIN
	fjeq %f1, %f0, FTOI_MAIN
	fneg %f0, %f0
	call FTOI_MAIN
	sub %g3, %g0, %g3
	return
FTOI_MAIN:
	call min_caml_floor
	! %f2 <= FLOAT_MAGICF
	! %g4 <= FLOAT_MAGICFHX
	setL %g4, FLOAT_MAGICF
	fldi %f2, %g4, 0
	setL %g4, FLOAT_MAGICFHX
	ldi %g4, %g4, 0
	fjlt %f2, %f0, FTOI_BIG		! if (MAGICF <= %f0) goto FTOI_BIG
	fjeq %f2, %f0, FTOI_BIG
	fadd %f0, %f0, %f2
	fsti %f0, %g1, 0
	ldi %g3, %g1, 0
	sub %g3, %g3, %g4
	return
FTOI_BIG:
	setL %g5, FLOAT_MAGICI
	ldi %g5, %g5, 0
	mov %g3, %g0
FTOI_LOOP:
	fsub %f0, %f0, %f2
	add %g3, %g3, %g5
	fjlt %f2, %f0, FTOI_LOOP
	fjeq %f2, %f0, FTOI_LOOP
	fadd %f0, %f0, %f2
	fsti %f0, %g1, 0
	ldi %g5, %g1, 0
	sub %g5, %g5, %g4
	add %g3, %g5, %g3
	return
	
! * truncate
min_caml_truncate:
	jmp min_caml_int_of_float
	
min_caml_read_int:
	addi %g3, %g0, 0
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
	fldi %f0, %g1, 0
	return

!#####################################################################
!
! 		↑　ここまで lib_asm.s
!
!#####################################################################
min_caml_start:
	mov	%g31, %g1
	subi	%g1, %g1, 1728
	addi	%g28, %g0, 1
	addi	%g29, %g0, -1
	setL %g27, l.6207
	fldi	%f16, %g27, 0
	setL %g27, l.6297
	fldi	%f17, %g27, 0
	setL %g27, l.6221
	fldi	%f18, %g27, 0
	setL %g27, l.6294
	fldi	%f19, %g27, 0
	setL %g27, l.6311
	fldi	%f20, %g27, 0
	setL %g27, l.6300
	fldi	%f21, %g27, 0
	setL %g27, l.7085
	fldi	%f22, %g27, 0
	setL %g27, l.6979
	fldi	%f23, %g27, 0
	setL %g27, l.6847
	fldi	%f24, %g27, 0
	setL %g27, l.6819
	fldi	%f25, %g27, 0
	setL %g27, l.6305
	fldi	%f26, %g27, 0
	setL %g27, l.6225
	fldi	%f27, %g27, 0
	setL %g27, l.7321
	fldi	%f28, %g27, 0
	setL %g27, l.7319
	fldi	%f29, %g27, 0
	setL %g27, l.6998
	fldi	%f30, %g27, 0
	setL %g27, l.6977
	fldi	%f31, %g27, 0
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 4
	subi	%g1, %g1, 4
	call	min_caml_create_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 8
	call	min_caml_create_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 12
	call	min_caml_create_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 16
	call	min_caml_create_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 1
	addi	%g4, %g0, 1
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 20
	call	min_caml_create_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 24
	call	min_caml_create_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 28
	call	min_caml_create_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 0
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 32
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g4, %g3
	ldi	%g2, %g31, 1724
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
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 272
	mov	%g4, %g3
	mov	%g3, %g6
	call	min_caml_create_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 3
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 284
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 3
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 296
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 3
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 308
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 1
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 312
	fmov	%f0, %f18
	call	min_caml_create_float_array
	ldi	%g2, %g31, 1724
	addi	%g6, %g0, 50
	addi	%g3, %g0, 1
	addi	%g4, %g0, -1
	call	min_caml_create_array
	mov	%g4, %g3
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 512
	mov	%g3, %g6
	call	min_caml_create_array
	ldi	%g2, %g31, 1724
	addi	%g6, %g0, 1
	addi	%g3, %g0, 1
	ldi	%g4, %g31, 512
	call	min_caml_create_array
	mov	%g4, %g3
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 516
	mov	%g3, %g6
	call	min_caml_create_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 1
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 520
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 524
	call	min_caml_create_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 1
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 528
	fmov	%f0, %f27
	call	min_caml_create_float_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 3
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 540
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 544
	call	min_caml_create_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 3
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 556
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 3
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 568
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 3
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 580
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 3
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 592
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 2
	addi	%g4, %g0, 0
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 600
	call	min_caml_create_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 2
	addi	%g4, %g0, 0
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 608
	call	min_caml_create_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 1
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 612
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 3
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 624
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 3
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 636
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 3
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 648
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 3
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 660
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 3
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 672
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 3
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 684
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 0
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 688
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g7, %g3
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 0
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 692
	subi	%g4, %g31, 688
	call	min_caml_create_array
	mov	%g4, %g3
	ldi	%g2, %g31, 1724
	addi	%g6, %g0, 0
	mov	%g3, %g2
	addi	%g2, %g2, 8
	sti	%g4, %g3, -4
	sti	%g7, %g3, 0
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 696
	mov	%g4, %g3
	mov	%g3, %g6
	call	min_caml_create_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 5
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 716
	subi	%g4, %g31, 696
	call	min_caml_create_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 0
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 720
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 3
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 732
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g6, %g3
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 60
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 972
	subi	%g4, %g31, 720
	call	min_caml_create_array
	mov	%g4, %g3
	ldi	%g2, %g31, 1724
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 980
	mov	%g3, %g2
	addi	%g2, %g2, 8
	sti	%g4, %g3, -4
	sti	%g6, %g3, 0
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 0
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 984
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g6, %g3
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 0
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 988
	subi	%g4, %g31, 984
	call	min_caml_create_array
	ldi	%g2, %g31, 1724
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 996
	mov	%g4, %g2
	addi	%g2, %g2, 8
	sti	%g3, %g4, -4
	sti	%g6, %g4, 0
	ldi	%g2, %g31, 1724
	addi	%g6, %g0, 180
	addi	%g5, %g0, 0
	mov	%g3, %g2
	addi	%g2, %g2, 12
	fsti	%f16, %g3, -8
	sti	%g4, %g3, -4
	sti	%g5, %g3, 0
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 1716
	mov	%g4, %g3
	mov	%g3, %g6
	call	min_caml_create_array
	ldi	%g2, %g31, 1724
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 1724
	subi	%g2, %g31, 1720
	call	min_caml_create_array
	ldi	%g2, %g31, 1724
	addi	%g6, %g0, 128
	addi	%g3, %g0, 128
	call	rt.3056
	addi	%g1, %g1, 4
	addi	%g0, %g0, 0
	halt

!==============================
! args = []
! fargs = [%f1, %f0]
! use_regs = [%g3, %g27, %f15, %f1, %f0]
! ret type = Bool
!================================
fless.2485:
	fjlt	%f1, %f0, fjge_else.7660
	addi	%g3, %g0, 0
	return
fjge_else.7660:
	addi	%g3, %g0, 1
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g3, %g27, %f16, %f15, %f0]
! ret type = Bool
!================================
fispos.2488:
	fjlt	%f16, %f0, fjge_else.7661
	addi	%g3, %g0, 0
	return
fjge_else.7661:
	addi	%g3, %g0, 1
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g3, %g27, %f16, %f15, %f0]
! ret type = Bool
!================================
fisneg.2490:
	fjlt	%f0, %f16, fjge_else.7662
	addi	%g3, %g0, 0
	return
fjge_else.7662:
	addi	%g3, %g0, 1
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g3, %g27, %f16, %f15, %f0]
! ret type = Bool
!================================
fiszero.2492:
	fjeq	%f0, %f16, fjne_else.7663
	addi	%g3, %g0, 0
	return
fjne_else.7663:
	addi	%g3, %g0, 1
	return

!==============================
! args = [%g4, %g3]
! fargs = []
! use_regs = [%g4, %g3, %g27, %f15]
! ret type = Bool
!================================
xor.2494:
	jne	%g4, %g3, jeq_else.7664
	addi	%g3, %g0, 0
	return
jeq_else.7664:
	addi	%g3, %g0, 1
	return

!==============================
! args = []
! fargs = [%f1]
! use_regs = [%g27, %f16, %f15, %f1, %f0]
! ret type = Float
!================================
fabs.2497:
	fjlt	%f1, %f16, fjge_else.7665
	fmov	%f0, %f1
	return
fjge_else.7665:
	fneg	%f0, %f1
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g27, %f15, %f0]
! ret type = Float
!================================
fneg.2501:
	fneg	%f0, %f0
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g27, %f19, %f15, %f0]
! ret type = Float
!================================
fhalf.2503:
	fmul	%f0, %f0, %f19
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g27, %f15, %f0]
! ret type = Float
!================================
fsqr.2505:
	fmul	%f0, %f0, %f0
	return

!==============================
! args = []
! fargs = [%f2, %f3, %f1]
! use_regs = [%g27, %f4, %f3, %f2, %f19, %f17, %f15, %f1, %f0]
! ret type = Float
!================================
atan_sub.2510:
	fjlt	%f2, %f19, fjge_else.7666
	fsub	%f0, %f2, %f17
	fmul	%f4, %f2, %f2
	fmul	%f4, %f4, %f3
	fadd	%f2, %f2, %f2
	fadd	%f2, %f2, %f17
	fadd	%f1, %f2, %f1
	fdiv	%f1, %f4, %f1
	fmov	%f2, %f0
	jmp	atan_sub.2510
fjge_else.7666:
	fmov	%f0, %f1
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g4, %g3, %g27, %f5, %f4, %f3, %f26, %f21, %f2, %f19, %f17, %f16, %f15, %f1, %f0]
! ret type = Float
!================================
atan.2514:
	fjlt	%f17, %f0, fjge_else.7667
	fjlt	%f0, %f21, fjge_else.7669
	addi	%g3, %g0, 0
	jmp	fjge_cont.7670
fjge_else.7669:
	addi	%g3, %g0, -1
fjge_cont.7670:
	jmp	fjge_cont.7668
fjge_else.7667:
	addi	%g3, %g0, 1
fjge_cont.7668:
	jne	%g3, %g0, jeq_else.7671
	fmov	%f5, %f0
	jmp	jeq_cont.7672
jeq_else.7671:
	fdiv	%f5, %f17, %f0
jeq_cont.7672:
	setL %g4, l.6302
	fldi	%f2, %g4, 0
	fmul	%f3, %f5, %f5
	fmov	%f1, %f16
	subi	%g1, %g1, 4
	call	atan_sub.2510
	addi	%g1, %g1, 4
	fadd	%f0, %f17, %f0
	fdiv	%f1, %f5, %f0
	jlt	%g0, %g3, jle_else.7673
	jlt	%g3, %g0, jge_else.7674
	fmov	%f0, %f1
	return
jge_else.7674:
	setL %g3, l.6307
	fldi	%f0, %g3, 0
	fsub	%f0, %f0, %f1
	return
jle_else.7673:
	fsub	%f0, %f26, %f1
	return

!==============================
! args = []
! fargs = [%f2, %f3, %f1]
! use_regs = [%g3, %g27, %f3, %f20, %f2, %f15, %f1, %f0]
! ret type = Float
!================================
tan_sub.6158:
	setL %g3, l.6309
	fldi	%f0, %g3, 0
	fjlt	%f2, %f0, fjge_else.7675
	fsub	%f0, %f2, %f20
	fsub	%f1, %f2, %f1
	fdiv	%f1, %f3, %f1
	fmov	%f2, %f0
	jmp	tan_sub.6158
fjge_else.7675:
	fmov	%f0, %f1
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g3, %g27, %f3, %f20, %f2, %f17, %f16, %f15, %f1, %f0]
! ret type = Float
!================================
tan.2516:
	setL %g3, l.6314
	fldi	%f2, %g3, 0
	fmul	%f3, %f0, %f0
	fsti	%f0, %g1, 0
	fmov	%f1, %f16
	subi	%g1, %g1, 8
	call	tan_sub.6158
	addi	%g1, %g1, 8
	fmov	%f1, %f0
	fsub	%f1, %f17, %f1
	fldi	%f0, %g1, 0
	fdiv	%f0, %f0, %f1
	return

!==============================
! args = []
! fargs = [%f1]
! use_regs = [%g3, %g27, %f2, %f16, %f15, %f1, %f0]
! ret type = Float
!================================
sin_sub.2518:
	setL %g3, l.6317
	fldi	%f2, %g3, 0
	fjlt	%f2, %f1, fjge_else.7676
	fjlt	%f1, %f16, fjge_else.7677
	fmov	%f0, %f1
	return
fjge_else.7677:
	fadd	%f1, %f1, %f2
	jmp	sin_sub.2518
fjge_else.7676:
	fsub	%f1, %f1, %f2
	jmp	sin_sub.2518

!==============================
! args = []
! fargs = [%f3]
! use_regs = [%g4, %g3, %g27, %f5, %f4, %f3, %f26, %f20, %f2, %f19, %f17, %f16, %f15, %f1, %f0]
! ret type = Float
!================================
sin.2520:
	setL %g3, l.6320
	fldi	%f5, %g3, 0
	setL %g3, l.6317
	fldi	%f4, %g3, 0
	fmov	%f1, %f3
	subi	%g1, %g1, 4
	call	fabs.2497
	fmov	%f1, %f0
	call	sin_sub.2518
	addi	%g1, %g1, 4
	fjlt	%f5, %f0, fjge_else.7678
	fjlt	%f16, %f3, fjge_else.7680
	addi	%g4, %g0, 0
	jmp	fjge_cont.7681
fjge_else.7680:
	addi	%g4, %g0, 1
fjge_cont.7681:
	jmp	fjge_cont.7679
fjge_else.7678:
	fjlt	%f16, %f3, fjge_else.7682
	addi	%g4, %g0, 1
	jmp	fjge_cont.7683
fjge_else.7682:
	addi	%g4, %g0, 0
fjge_cont.7683:
fjge_cont.7679:
	fjlt	%f5, %f0, fjge_else.7684
	fmov	%f1, %f0
	jmp	fjge_cont.7685
fjge_else.7684:
	fsub	%f1, %f4, %f0
fjge_cont.7685:
	fjlt	%f26, %f1, fjge_else.7686
	fmov	%f0, %f1
	jmp	fjge_cont.7687
fjge_else.7686:
	fsub	%f0, %f5, %f1
fjge_cont.7687:
	fmul	%f0, %f0, %f19
	subi	%g1, %g1, 4
	call	tan.2516
	addi	%g1, %g1, 4
	fmul	%f1, %f20, %f0
	fmul	%f0, %f0, %f0
	fadd	%f0, %f17, %f0
	fdiv	%f1, %f1, %f0
	jne	%g4, %g0, jeq_else.7688
	fmov	%f0, %f1
	jmp	fneg.2501
jeq_else.7688:
	fmov	%f0, %f1
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g4, %g3, %g27, %f5, %f4, %f3, %f26, %f20, %f2, %f19, %f17, %f16, %f15, %f1, %f0]
! ret type = Float
!================================
cos.2522:
	fsub	%f3, %f26, %f0
	jmp	sin.2520

!==============================
! args = [%g8, %g7, %g5, %g6]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %f15]
! ret type = Int
!================================
div_binary_search.2540:
	add	%g3, %g5, %g6
	srli	%g4, %g3, 1
	mul	%g9, %g4, %g7
	sub	%g3, %g6, %g5
	jlt	%g28, %g3, jle_else.7689
	mov	%g3, %g5
	return
jle_else.7689:
	jlt	%g9, %g8, jle_else.7690
	jne	%g9, %g8, jeq_else.7691
	mov	%g3, %g4
	return
jeq_else.7691:
	mov	%g6, %g4
	jmp	div_binary_search.2540
jle_else.7690:
	mov	%g5, %g4
	jmp	div_binary_search.2540

!==============================
! args = [%g8]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g11, %g10, %f15, %dummy]
! ret type = Unit
!================================
print_int.2545:
	jlt	%g8, %g0, jge_else.7692
	mvhi	%g7, 1525
	mvlo	%g7, 57600
	addi	%g5, %g0, 0
	addi	%g6, %g0, 3
	sti	%g8, %g1, 0
	subi	%g1, %g1, 8
	call	div_binary_search.2540
	addi	%g1, %g1, 8
	mvhi	%g4, 1525
	mvlo	%g4, 57600
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 0
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.7693
	addi	%g10, %g0, 0
	jmp	jle_cont.7694
jle_else.7693:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jle_cont.7694:
	mvhi	%g7, 152
	mvlo	%g7, 38528
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 4
	subi	%g1, %g1, 12
	call	div_binary_search.2540
	addi	%g1, %g1, 12
	mvhi	%g4, 152
	mvlo	%g4, 38528
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 4
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.7695
	jne	%g10, %g0, jeq_else.7697
	addi	%g11, %g0, 0
	jmp	jeq_cont.7698
jeq_else.7697:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jeq_cont.7698:
	jmp	jle_cont.7696
jle_else.7695:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jle_cont.7696:
	mvhi	%g7, 15
	mvlo	%g7, 16960
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 8
	subi	%g1, %g1, 16
	call	div_binary_search.2540
	addi	%g1, %g1, 16
	mvhi	%g4, 15
	mvlo	%g4, 16960
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 8
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.7699
	jne	%g11, %g0, jeq_else.7701
	addi	%g10, %g0, 0
	jmp	jeq_cont.7702
jeq_else.7701:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jeq_cont.7702:
	jmp	jle_cont.7700
jle_else.7699:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jle_cont.7700:
	mvhi	%g7, 1
	mvlo	%g7, 34464
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 12
	subi	%g1, %g1, 20
	call	div_binary_search.2540
	addi	%g1, %g1, 20
	mvhi	%g4, 1
	mvlo	%g4, 34464
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 12
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.7703
	jne	%g10, %g0, jeq_else.7705
	addi	%g11, %g0, 0
	jmp	jeq_cont.7706
jeq_else.7705:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jeq_cont.7706:
	jmp	jle_cont.7704
jle_else.7703:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jle_cont.7704:
	addi	%g7, %g0, 10000
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 16
	subi	%g1, %g1, 24
	call	div_binary_search.2540
	addi	%g1, %g1, 24
	addi	%g4, %g0, 10000
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 16
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.7707
	jne	%g11, %g0, jeq_else.7709
	addi	%g10, %g0, 0
	jmp	jeq_cont.7710
jeq_else.7709:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jeq_cont.7710:
	jmp	jle_cont.7708
jle_else.7707:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jle_cont.7708:
	addi	%g7, %g0, 1000
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 20
	subi	%g1, %g1, 28
	call	div_binary_search.2540
	addi	%g1, %g1, 28
	muli	%g4, %g3, 1000
	ldi	%g8, %g1, 20
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.7711
	jne	%g10, %g0, jeq_else.7713
	addi	%g11, %g0, 0
	jmp	jeq_cont.7714
jeq_else.7713:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jeq_cont.7714:
	jmp	jle_cont.7712
jle_else.7711:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jle_cont.7712:
	addi	%g7, %g0, 100
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 24
	subi	%g1, %g1, 32
	call	div_binary_search.2540
	addi	%g1, %g1, 32
	muli	%g4, %g3, 100
	ldi	%g8, %g1, 24
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.7715
	jne	%g11, %g0, jeq_else.7717
	addi	%g10, %g0, 0
	jmp	jeq_cont.7718
jeq_else.7717:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jeq_cont.7718:
	jmp	jle_cont.7716
jle_else.7715:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jle_cont.7716:
	addi	%g7, %g0, 10
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 28
	subi	%g1, %g1, 36
	call	div_binary_search.2540
	addi	%g1, %g1, 36
	muli	%g4, %g3, 10
	ldi	%g8, %g1, 28
	sub	%g4, %g8, %g4
	jlt	%g0, %g3, jle_else.7719
	jne	%g10, %g0, jeq_else.7721
	addi	%g5, %g0, 0
	jmp	jeq_cont.7722
jeq_else.7721:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g5, %g0, 1
jeq_cont.7722:
	jmp	jle_cont.7720
jle_else.7719:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g5, %g0, 1
jle_cont.7720:
	addi	%g3, %g0, 48
	add	%g3, %g3, %g4
	output	%g3
	return
jge_else.7692:
	addi	%g3, %g0, 45
	output	%g3
	sub	%g8, %g0, %g8
	jmp	print_int.2545

!==============================
! args = []
! fargs = [%f1]
! use_regs = [%g3, %g27, %f16, %f15, %f1, %f0]
! ret type = Float
!================================
sgn.2577:
	fmov	%f0, %f1
	subi	%g1, %g1, 4
	call	fiszero.2492
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7723
	fmov	%f0, %f1
	subi	%g1, %g1, 4
	call	fispos.2488
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7724
	setL %g3, l.6300
	fldi	%f0, %g3, 0
	return
jeq_else.7724:
	setL %g3, l.6297
	fldi	%f0, %g3, 0
	return
jeq_else.7723:
	setL %g3, l.6207
	fldi	%f0, %g3, 0
	return

!==============================
! args = [%g3]
! fargs = [%f1]
! use_regs = [%g3, %g27, %f15, %f1, %f0]
! ret type = Float
!================================
fneg_cond.2579:
	jne	%g3, %g0, jeq_else.7725
	fmov	%f0, %f1
	jmp	fneg.2501
jeq_else.7725:
	fmov	%f0, %f1
	return

!==============================
! args = [%g4, %g3]
! fargs = []
! use_regs = [%g4, %g3, %g27, %f15]
! ret type = Int
!================================
add_mod5.2582:
	add	%g4, %g4, %g3
	addi	%g3, %g0, 5
	jlt	%g4, %g3, jle_else.7726
	subi	%g3, %g4, 5
	return
jle_else.7726:
	mov	%g3, %g4
	return

!==============================
! args = [%g3]
! fargs = [%f2, %f1, %f0]
! use_regs = [%g3, %g27, %f2, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
vecset.2585:
	fsti	%f2, %g3, 0
	fsti	%f1, %g3, -4
	fsti	%f0, %g3, -8
	return

!==============================
! args = [%g3]
! fargs = [%f0]
! use_regs = [%g3, %g27, %f15, %f0, %dummy]
! ret type = Unit
!================================
vecfill.2590:
	fsti	%f0, %g3, 0
	fsti	%f0, %g3, -4
	fsti	%f0, %g3, -8
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f16, %f15, %f0, %dummy]
! ret type = Unit
!================================
vecbzero.2593:
	fmov	%f0, %f16
	jmp	vecfill.2590

!==============================
! args = [%g4, %g3]
! fargs = []
! use_regs = [%g4, %g3, %g27, %f15, %f0, %dummy]
! ret type = Unit
!================================
veccpy.2595:
	fldi	%f0, %g3, 0
	fsti	%f0, %g4, 0
	fldi	%f0, %g3, -4
	fsti	%f0, %g4, -4
	fldi	%f0, %g3, -8
	fsti	%f0, %g4, -8
	return

!==============================
! args = [%g4, %g5]
! fargs = []
! use_regs = [%g5, %g4, %g3, %g27, %f21, %f2, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
vecunit_sgn.2603:
	fldi	%f1, %g4, 0
	fmov	%f0, %f1
	subi	%g1, %g1, 4
	call	fsqr.2505
	fmov	%f2, %f0
	fldi	%f0, %g4, -4
	call	fsqr.2505
	fadd	%f2, %f2, %f0
	fldi	%f0, %g4, -8
	call	fsqr.2505
	addi	%g1, %g1, 4
	fadd	%f0, %f2, %f0
	fsqrt	%f0, %f0
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fiszero.2492
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7730
	jne	%g5, %g0, jeq_else.7732
	fldi	%f0, %g1, 0
	fdiv	%f2, %f17, %f0
	jmp	jeq_cont.7733
jeq_else.7732:
	fldi	%f0, %g1, 0
	fdiv	%f2, %f21, %f0
jeq_cont.7733:
	jmp	jeq_cont.7731
jeq_else.7730:
	setL %g3, l.6297
	fldi	%f2, %g3, 0
jeq_cont.7731:
	fmul	%f0, %f1, %f2
	fsti	%f0, %g4, 0
	fldi	%f0, %g4, -4
	fmul	%f0, %f0, %f2
	fsti	%f0, %g4, -4
	fldi	%f0, %g4, -8
	fmul	%f0, %f0, %f2
	fsti	%f0, %g4, -8
	return

!==============================
! args = [%g4, %g3]
! fargs = []
! use_regs = [%g4, %g3, %g27, %f2, %f15, %f1, %f0]
! ret type = Float
!================================
veciprod.2606:
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

!==============================
! args = [%g3]
! fargs = [%f2, %f1, %f0]
! use_regs = [%g3, %g27, %f3, %f2, %f15, %f1, %f0]
! ret type = Float
!================================
veciprod2.2609:
	fldi	%f3, %g3, 0
	fmul	%f3, %f3, %f2
	fldi	%f2, %g3, -4
	fmul	%f1, %f2, %f1
	fadd	%f2, %f3, %f1
	fldi	%f1, %g3, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	return

!==============================
! args = [%g4, %g3]
! fargs = [%f0]
! use_regs = [%g4, %g3, %g27, %f2, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
vecaccum.2614:
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

!==============================
! args = [%g4, %g3]
! fargs = []
! use_regs = [%g4, %g3, %g27, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
vecadd.2618:
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

!==============================
! args = [%g3]
! fargs = [%f0]
! use_regs = [%g3, %g27, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
vecscale.2624:
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

!==============================
! args = [%g5, %g4, %g3]
! fargs = []
! use_regs = [%g5, %g4, %g3, %g27, %f2, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
vecaccumv.2627:
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

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Int
!================================
o_texturetype.2631:
	ldi	%g3, %g3, 0
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Int
!================================
o_form.2633:
	ldi	%g3, %g3, -4
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Int
!================================
o_reflectiontype.2635:
	ldi	%g3, %g3, -8
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Bool
!================================
o_isinvert.2637:
	ldi	%g3, %g3, -24
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Int
!================================
o_isrot.2639:
	ldi	%g3, %g3, -12
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_param_a.2641:
	ldi	%g3, %g3, -16
	fldi	%f0, %g3, 0
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_param_b.2643:
	ldi	%g3, %g3, -16
	fldi	%f0, %g3, -4
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_param_c.2645:
	ldi	%g3, %g3, -16
	fldi	%f0, %g3, -8
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Array(Float)
!================================
o_param_abc.2647:
	ldi	%g3, %g3, -16
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_param_x.2649:
	ldi	%g3, %g3, -20
	fldi	%f0, %g3, 0
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_param_y.2651:
	ldi	%g3, %g3, -20
	fldi	%f0, %g3, -4
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_param_z.2653:
	ldi	%g3, %g3, -20
	fldi	%f0, %g3, -8
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_diffuse.2655:
	ldi	%g3, %g3, -28
	fldi	%f0, %g3, 0
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_hilight.2657:
	ldi	%g3, %g3, -28
	fldi	%f0, %g3, -4
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_color_red.2659:
	ldi	%g3, %g3, -32
	fldi	%f0, %g3, 0
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_color_green.2661:
	ldi	%g3, %g3, -32
	fldi	%f0, %g3, -4
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_color_blue.2663:
	ldi	%g3, %g3, -32
	fldi	%f0, %g3, -8
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_param_r1.2665:
	ldi	%g3, %g3, -36
	fldi	%f0, %g3, 0
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_param_r2.2667:
	ldi	%g3, %g3, -36
	fldi	%f0, %g3, -4
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_param_r3.2669:
	ldi	%g3, %g3, -36
	fldi	%f0, %g3, -8
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Array(Float)
!================================
o_param_ctbl.2671:
	ldi	%g3, %g3, -40
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Array(Float)
!================================
p_rgb.2673:
	ldi	%g3, %g3, 0
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Array(Array(Float))
!================================
p_intersection_points.2675:
	ldi	%g3, %g3, -4
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Array(Int)
!================================
p_surface_ids.2677:
	ldi	%g3, %g3, -8
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Array(Bool)
!================================
p_calc_diffuse.2679:
	ldi	%g3, %g3, -12
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Array(Array(Float))
!================================
p_energy.2681:
	ldi	%g3, %g3, -16
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Array(Array(Float))
!================================
p_received_ray_20percent.2683:
	ldi	%g3, %g3, -20
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Int
!================================
p_group_id.2685:
	ldi	%g3, %g3, -24
	ldi	%g3, %g3, 0
	return

!==============================
! args = [%g3, %g4]
! fargs = []
! use_regs = [%g4, %g3, %g27, %f15, %dummy]
! ret type = Unit
!================================
p_set_group_id.2687:
	ldi	%g3, %g3, -24
	sti	%g4, %g3, 0
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Array(Array(Float))
!================================
p_nvectors.2690:
	ldi	%g3, %g3, -28
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Array(Float)
!================================
d_vec.2692:
	ldi	%g3, %g3, 0
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Array(Array(Float))
!================================
d_const.2694:
	ldi	%g3, %g3, -4
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Int
!================================
r_surface_id.2696:
	ldi	%g3, %g3, 0
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = (Array(Float) * Array(Array(Float)))
!================================
r_dvec.2698:
	ldi	%g3, %g3, -4
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
r_bright.2700:
	fldi	%f0, %g3, -8
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g3, %g27, %f15, %f1, %f0]
! ret type = Float
!================================
rad.2702:
	setL %g3, l.6473
	fldi	%f1, %g3, 0
	fmul	%f0, %f0, %f1
	return

!==============================
! args = []
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f26, %f20, %f2, %f19, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
read_screen_settings.2704:
	subi	%g1, %g1, 4
	call	min_caml_read_float
	fsti	%f0, %g31, 284
	call	min_caml_read_float
	fsti	%f0, %g31, 280
	call	min_caml_read_float
	fsti	%f0, %g31, 276
	call	min_caml_read_float
	call	rad.2702
	addi	%g1, %g1, 4
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	cos.2522
	addi	%g1, %g1, 8
	fmov	%f7, %f0
	fldi	%f0, %g1, 0
	fmov	%f3, %f0
	subi	%g1, %g1, 8
	call	sin.2520
	addi	%g1, %g1, 8
	fmov	%f8, %f0
	fsti	%f8, %g1, 4
	fsti	%f7, %g1, 8
	subi	%g1, %g1, 16
	call	min_caml_read_float
	call	rad.2702
	addi	%g1, %g1, 16
	fsti	%f0, %g1, 12
	subi	%g1, %g1, 20
	call	cos.2522
	addi	%g1, %g1, 20
	fmov	%f6, %f0
	fldi	%f0, %g1, 12
	fmov	%f3, %f0
	subi	%g1, %g1, 20
	call	sin.2520
	addi	%g1, %g1, 20
	fldi	%f7, %g1, 8
	fmul	%f1, %f7, %f0
	setL %g3, l.6478
	fldi	%f2, %g3, 0
	fmul	%f1, %f1, %f2
	fsti	%f1, %g31, 672
	setL %g3, l.6481
	fldi	%f1, %g3, 0
	fldi	%f8, %g1, 4
	fmul	%f1, %f8, %f1
	fsti	%f1, %g31, 668
	fmul	%f1, %f7, %f6
	fmul	%f1, %f1, %f2
	fsti	%f1, %g31, 664
	fsti	%f6, %g31, 648
	fsti	%f16, %g31, 644
	fsti	%f0, %g1, 16
	subi	%g1, %g1, 24
	call	fneg.2501
	fmov	%f1, %f0
	fsti	%f1, %g31, 640
	fmov	%f0, %f8
	call	fneg.2501
	addi	%g1, %g1, 24
	fmov	%f1, %f0
	fldi	%f0, %g1, 16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g31, 660
	fmov	%f0, %f7
	subi	%g1, %g1, 24
	call	fneg.2501
	addi	%g1, %g1, 24
	fsti	%f0, %g31, 656
	fmul	%f0, %f1, %f6
	fsti	%f0, %g31, 652
	fldi	%f1, %g31, 284
	fldi	%f0, %g31, 672
	fsub	%f0, %f1, %f0
	fsti	%f0, %g31, 296
	fldi	%f1, %g31, 280
	fldi	%f0, %g31, 668
	fsub	%f0, %f1, %f0
	fsti	%f0, %g31, 292
	fldi	%f1, %g31, 276
	fldi	%f0, %g31, 664
	fsub	%f0, %f1, %f0
	fsti	%f0, %g31, 288
	return

!==============================
! args = []
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f26, %f20, %f2, %f19, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
read_light.2706:
	subi	%g1, %g1, 4
	call	min_caml_read_int
	call	min_caml_read_float
	call	rad.2702
	fmov	%f7, %f0
	fmov	%f3, %f7
	call	sin.2520
	call	fneg.2501
	addi	%g1, %g1, 4
	fsti	%f0, %g31, 304
	fsti	%f7, %g1, 0
	subi	%g1, %g1, 8
	call	min_caml_read_float
	call	rad.2702
	addi	%g1, %g1, 8
	fmov	%f6, %f0
	fldi	%f7, %g1, 0
	fmov	%f0, %f7
	subi	%g1, %g1, 8
	call	cos.2522
	fmov	%f7, %f0
	fmov	%f3, %f6
	call	sin.2520
	fmul	%f0, %f7, %f0
	fsti	%f0, %g31, 308
	fmov	%f0, %f6
	call	cos.2522
	fmul	%f0, %f7, %f0
	fsti	%f0, %g31, 300
	call	min_caml_read_float
	addi	%g1, %g1, 8
	fsti	%f0, %g31, 312
	return

!==============================
! args = [%g6, %g5]
! fargs = []
! use_regs = [%g6, %g5, %g4, %g3, %g27, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f26, %f20, %f2, %f19, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
rotate_quadratic_matrix.2708:
	fldi	%f6, %g5, 0
	fmov	%f0, %f6
	subi	%g1, %g1, 4
	call	cos.2522
	fmov	%f9, %f0
	fmov	%f3, %f6
	call	sin.2520
	fmov	%f7, %f0
	fldi	%f6, %g5, -4
	fmov	%f0, %f6
	call	cos.2522
	fmov	%f8, %f0
	fmov	%f3, %f6
	call	sin.2520
	fmov	%f10, %f0
	fldi	%f11, %g5, -8
	fmov	%f0, %f11
	call	cos.2522
	fmov	%f6, %f0
	fmov	%f3, %f11
	call	sin.2520
	addi	%g1, %g1, 4
	fmul	%f15, %f8, %f6
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
	fsti	%f15, %g1, 0
	fmov	%f0, %f10
	subi	%g1, %g1, 8
	call	fneg.2501
	addi	%g1, %g1, 8
	fmov	%f10, %f0
	fmul	%f6, %f7, %f8
	fmul	%f4, %f9, %f8
	fldi	%f1, %g6, 0
	fldi	%f2, %g6, -4
	fldi	%f3, %g6, -8
	fldi	%f15, %g1, 0
	fmov	%f0, %f15
	subi	%g1, %g1, 8
	call	fsqr.2505
	fmul	%f7, %f1, %f0
	fmov	%f0, %f14
	call	fsqr.2505
	fmul	%f0, %f2, %f0
	fadd	%f7, %f7, %f0
	fmov	%f0, %f10
	call	fsqr.2505
	fmul	%f0, %f3, %f0
	fadd	%f0, %f7, %f0
	fsti	%f0, %g6, 0
	fmov	%f0, %f13
	call	fsqr.2505
	fmul	%f7, %f1, %f0
	fmov	%f0, %f12
	call	fsqr.2505
	fmul	%f0, %f2, %f0
	fadd	%f7, %f7, %f0
	fmov	%f0, %f6
	call	fsqr.2505
	fmul	%f0, %f3, %f0
	fadd	%f0, %f7, %f0
	fsti	%f0, %g6, -4
	fmov	%f0, %f11
	call	fsqr.2505
	fmul	%f7, %f1, %f0
	fmov	%f0, %f5
	call	fsqr.2505
	fmul	%f0, %f2, %f0
	fadd	%f7, %f7, %f0
	fmov	%f0, %f4
	call	fsqr.2505
	addi	%g1, %g1, 8
	fmul	%f0, %f3, %f0
	fadd	%f0, %f7, %f0
	fsti	%f0, %g6, -8
	fmul	%f0, %f1, %f13
	fmul	%f7, %f0, %f11
	fmul	%f0, %f2, %f12
	fmul	%f0, %f0, %f5
	fadd	%f7, %f7, %f0
	fmul	%f0, %f3, %f6
	fmul	%f0, %f0, %f4
	fadd	%f0, %f7, %f0
	fmul	%f0, %f20, %f0
	fsti	%f0, %g5, 0
	fldi	%f15, %g1, 0
	fmul	%f1, %f1, %f15
	fmul	%f7, %f1, %f11
	fmul	%f0, %f2, %f14
	fmul	%f2, %f0, %f5
	fadd	%f5, %f7, %f2
	fmul	%f3, %f3, %f10
	fmul	%f2, %f3, %f4
	fadd	%f2, %f5, %f2
	fmul	%f2, %f20, %f2
	fsti	%f2, %g5, -4
	fmul	%f1, %f1, %f13
	fmul	%f0, %f0, %f12
	fadd	%f1, %f1, %f0
	fmul	%f0, %f3, %f6
	fadd	%f0, %f1, %f0
	fmul	%f0, %f20, %f0
	fsti	%f0, %g5, -8
	return

!==============================
! args = [%g10]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g2, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f26, %f21, %f20, %f2, %f19, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Bool
!================================
read_nth_object.2711:
	sti	%g10, %g1, 0
	subi	%g1, %g1, 8
	call	min_caml_read_int
	addi	%g1, %g1, 8
	mov	%g12, %g3
	jne	%g12, %g29, jeq_else.7743
	addi	%g3, %g0, 0
	return
jeq_else.7743:
	sti	%g12, %g1, 4
	subi	%g1, %g1, 12
	call	min_caml_read_int
	addi	%g1, %g1, 12
	mov	%g5, %g3
	sti	%g5, %g1, 8
	subi	%g1, %g1, 16
	call	min_caml_read_int
	addi	%g1, %g1, 16
	mov	%g14, %g3
	sti	%g14, %g1, 12
	subi	%g1, %g1, 20
	call	min_caml_read_int
	mov	%g7, %g3
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	addi	%g1, %g1, 20
	mov	%g6, %g3
	sti	%g7, %g1, 16
	sti	%g6, %g1, 20
	subi	%g1, %g1, 28
	call	min_caml_read_float
	addi	%g1, %g1, 28
	ldi	%g6, %g1, 20
	fsti	%f0, %g6, 0
	subi	%g1, %g1, 28
	call	min_caml_read_float
	addi	%g1, %g1, 28
	ldi	%g6, %g1, 20
	fsti	%f0, %g6, -4
	subi	%g1, %g1, 28
	call	min_caml_read_float
	addi	%g1, %g1, 28
	ldi	%g6, %g1, 20
	fsti	%f0, %g6, -8
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 28
	call	min_caml_create_float_array
	addi	%g1, %g1, 28
	mov	%g11, %g3
	sti	%g11, %g1, 24
	subi	%g1, %g1, 32
	call	min_caml_read_float
	addi	%g1, %g1, 32
	ldi	%g11, %g1, 24
	fsti	%f0, %g11, 0
	subi	%g1, %g1, 32
	call	min_caml_read_float
	addi	%g1, %g1, 32
	ldi	%g11, %g1, 24
	fsti	%f0, %g11, -4
	subi	%g1, %g1, 32
	call	min_caml_read_float
	addi	%g1, %g1, 32
	ldi	%g11, %g1, 24
	fsti	%f0, %g11, -8
	subi	%g1, %g1, 32
	call	min_caml_read_float
	call	fisneg.2490
	mov	%g8, %g3
	addi	%g3, %g0, 2
	fmov	%f0, %f16
	call	min_caml_create_float_array
	addi	%g1, %g1, 32
	mov	%g15, %g3
	sti	%g8, %g1, 28
	sti	%g15, %g1, 32
	subi	%g1, %g1, 40
	call	min_caml_read_float
	addi	%g1, %g1, 40
	ldi	%g15, %g1, 32
	fsti	%f0, %g15, 0
	subi	%g1, %g1, 40
	call	min_caml_read_float
	addi	%g1, %g1, 40
	ldi	%g15, %g1, 32
	fsti	%f0, %g15, -4
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 40
	call	min_caml_create_float_array
	addi	%g1, %g1, 40
	mov	%g16, %g3
	sti	%g16, %g1, 36
	subi	%g1, %g1, 44
	call	min_caml_read_float
	addi	%g1, %g1, 44
	ldi	%g16, %g1, 36
	fsti	%f0, %g16, 0
	subi	%g1, %g1, 44
	call	min_caml_read_float
	addi	%g1, %g1, 44
	ldi	%g16, %g1, 36
	fsti	%f0, %g16, -4
	subi	%g1, %g1, 44
	call	min_caml_read_float
	addi	%g1, %g1, 44
	ldi	%g16, %g1, 36
	fsti	%f0, %g16, -8
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 44
	call	min_caml_create_float_array
	addi	%g1, %g1, 44
	mov	%g13, %g3
	ldi	%g7, %g1, 16
	jne	%g7, %g0, jeq_else.7744
	jmp	jeq_cont.7745
jeq_else.7744:
	sti	%g13, %g1, 40
	subi	%g1, %g1, 48
	call	min_caml_read_float
	call	rad.2702
	addi	%g1, %g1, 48
	ldi	%g13, %g1, 40
	fsti	%f0, %g13, 0
	subi	%g1, %g1, 48
	call	min_caml_read_float
	call	rad.2702
	addi	%g1, %g1, 48
	ldi	%g13, %g1, 40
	fsti	%f0, %g13, -4
	subi	%g1, %g1, 48
	call	min_caml_read_float
	call	rad.2702
	addi	%g1, %g1, 48
	ldi	%g13, %g1, 40
	fsti	%f0, %g13, -8
jeq_cont.7745:
	addi	%g9, %g0, 2
	ldi	%g5, %g1, 8
	jne	%g5, %g9, jeq_else.7746
	addi	%g9, %g0, 1
	jmp	jeq_cont.7747
jeq_else.7746:
	ldi	%g8, %g1, 28
	mov	%g9, %g8
jeq_cont.7747:
	addi	%g3, %g0, 4
	fmov	%f0, %f16
	subi	%g1, %g1, 48
	call	min_caml_create_float_array
	addi	%g1, %g1, 48
	mov	%g4, %g3
	mov	%g3, %g2
	addi	%g2, %g2, 44
	sti	%g4, %g3, -40
	sti	%g13, %g3, -36
	ldi	%g16, %g1, 36
	sti	%g16, %g3, -32
	ldi	%g15, %g1, 32
	sti	%g15, %g3, -28
	sti	%g9, %g3, -24
	ldi	%g11, %g1, 24
	sti	%g11, %g3, -20
	ldi	%g6, %g1, 20
	sti	%g6, %g3, -16
	ldi	%g7, %g1, 16
	sti	%g7, %g3, -12
	ldi	%g14, %g1, 12
	sti	%g14, %g3, -8
	sti	%g5, %g3, -4
	ldi	%g12, %g1, 4
	sti	%g12, %g3, 0
	ldi	%g10, %g1, 0
	slli	%g4, %g10, 2
	add	%g4, %g31, %g4
	sti	%g3, %g4, 272
	addi	%g3, %g0, 3
	jne	%g5, %g3, jeq_else.7748
	fldi	%f1, %g6, 0
	fmov	%f0, %f1
	subi	%g1, %g1, 48
	call	fiszero.2492
	addi	%g1, %g1, 48
	jne	%g3, %g0, jeq_else.7750
	fsti	%f1, %g1, 44
	subi	%g1, %g1, 52
	call	sgn.2577
	addi	%g1, %g1, 52
	fmov	%f2, %f0
	fldi	%f1, %g1, 44
	fmov	%f0, %f1
	subi	%g1, %g1, 52
	call	fsqr.2505
	addi	%g1, %g1, 52
	fdiv	%f0, %f2, %f0
	jmp	jeq_cont.7751
jeq_else.7750:
	fmov	%f0, %f16
jeq_cont.7751:
	fsti	%f0, %g6, 0
	fldi	%f1, %g6, -4
	fmov	%f0, %f1
	subi	%g1, %g1, 52
	call	fiszero.2492
	addi	%g1, %g1, 52
	jne	%g3, %g0, jeq_else.7752
	fsti	%f1, %g1, 48
	subi	%g1, %g1, 56
	call	sgn.2577
	addi	%g1, %g1, 56
	fmov	%f2, %f0
	fldi	%f1, %g1, 48
	fmov	%f0, %f1
	subi	%g1, %g1, 56
	call	fsqr.2505
	addi	%g1, %g1, 56
	fdiv	%f0, %f2, %f0
	jmp	jeq_cont.7753
jeq_else.7752:
	fmov	%f0, %f16
jeq_cont.7753:
	fsti	%f0, %g6, -4
	fldi	%f1, %g6, -8
	fmov	%f0, %f1
	subi	%g1, %g1, 56
	call	fiszero.2492
	addi	%g1, %g1, 56
	jne	%g3, %g0, jeq_else.7754
	fsti	%f1, %g1, 52
	subi	%g1, %g1, 60
	call	sgn.2577
	addi	%g1, %g1, 60
	fmov	%f2, %f0
	fldi	%f1, %g1, 52
	fmov	%f0, %f1
	subi	%g1, %g1, 60
	call	fsqr.2505
	addi	%g1, %g1, 60
	fdiv	%f0, %f2, %f0
	jmp	jeq_cont.7755
jeq_else.7754:
	fmov	%f0, %f16
jeq_cont.7755:
	fsti	%f0, %g6, -8
	jmp	jeq_cont.7749
jeq_else.7748:
	addi	%g3, %g0, 2
	jne	%g5, %g3, jeq_else.7756
	ldi	%g8, %g1, 28
	jne	%g8, %g0, jeq_else.7758
	addi	%g5, %g0, 1
	jmp	jeq_cont.7759
jeq_else.7758:
	addi	%g5, %g0, 0
jeq_cont.7759:
	mov	%g4, %g6
	subi	%g1, %g1, 60
	call	vecunit_sgn.2603
	addi	%g1, %g1, 60
	jmp	jeq_cont.7757
jeq_else.7756:
jeq_cont.7757:
jeq_cont.7749:
	jne	%g7, %g0, jeq_else.7760
	jmp	jeq_cont.7761
jeq_else.7760:
	mov	%g5, %g13
	subi	%g1, %g1, 60
	call	rotate_quadratic_matrix.2708
	addi	%g1, %g1, 60
jeq_cont.7761:
	addi	%g3, %g0, 1
	return

!==============================
! args = [%g10]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g2, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f26, %f21, %f20, %f2, %f19, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
read_object.2713:
	addi	%g3, %g0, 60
	jlt	%g10, %g3, jle_else.7762
	return
jle_else.7762:
	sti	%g10, %g1, 0
	subi	%g1, %g1, 8
	call	read_nth_object.2711
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7764
	ldi	%g10, %g1, 0
	sti	%g10, %g31, 28
	return
jeq_else.7764:
	ldi	%g10, %g1, 0
	addi	%g10, %g10, 1
	jmp	read_object.2713

!==============================
! args = []
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g2, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f26, %f21, %f20, %f2, %f19, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
read_all_object.2715:
	addi	%g10, %g0, 0
	jmp	read_object.2713

!==============================
! args = [%g4]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Array(Int)
!================================
read_net_item.2717:
	sti	%g4, %g1, 0
	subi	%g1, %g1, 8
	call	min_caml_read_int
	addi	%g1, %g1, 8
	mov	%g5, %g3
	jne	%g5, %g29, jeq_else.7766
	ldi	%g4, %g1, 0
	addi	%g3, %g4, 1
	addi	%g4, %g0, -1
	jmp	min_caml_create_array
jeq_else.7766:
	ldi	%g4, %g1, 0
	addi	%g3, %g4, 1
	sti	%g5, %g1, 4
	mov	%g4, %g3
	subi	%g1, %g1, 12
	call	read_net_item.2717
	addi	%g1, %g1, 12
	ldi	%g4, %g1, 0
	slli	%g4, %g4, 2
	ldi	%g5, %g1, 4
	st	%g5, %g3, %g4
	return

!==============================
! args = [%g4]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Array(Array(Int))
!================================
read_or_network.2719:
	addi	%g3, %g0, 0
	sti	%g4, %g1, 0
	mov	%g4, %g3
	subi	%g1, %g1, 8
	call	read_net_item.2717
	addi	%g1, %g1, 8
	mov	%g6, %g3
	ldi	%g3, %g6, 0
	jne	%g3, %g29, jeq_else.7767
	ldi	%g4, %g1, 0
	addi	%g3, %g4, 1
	mov	%g4, %g6
	jmp	min_caml_create_array
jeq_else.7767:
	ldi	%g4, %g1, 0
	addi	%g3, %g4, 1
	sti	%g6, %g1, 4
	mov	%g4, %g3
	subi	%g1, %g1, 12
	call	read_or_network.2719
	addi	%g1, %g1, 12
	ldi	%g4, %g1, 0
	slli	%g4, %g4, 2
	ldi	%g6, %g1, 4
	st	%g6, %g3, %g4
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
read_and_network.2721:
	addi	%g4, %g0, 0
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	read_net_item.2717
	addi	%g1, %g1, 8
	mov	%g4, %g3
	ldi	%g5, %g4, 0
	jne	%g5, %g29, jeq_else.7768
	return
jeq_else.7768:
	ldi	%g3, %g1, 0
	slli	%g5, %g3, 2
	add	%g5, %g31, %g5
	sti	%g4, %g5, 512
	addi	%g3, %g3, 1
	jmp	read_and_network.2721

!==============================
! args = []
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g2, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f26, %f21, %f20, %f2, %f19, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
read_parameter.2723:
	subi	%g1, %g1, 4
	call	read_screen_settings.2704
	call	read_light.2706
	call	read_all_object.2715
	addi	%g3, %g0, 0
	call	read_and_network.2721
	addi	%g4, %g0, 0
	call	read_or_network.2719
	addi	%g1, %g1, 4
	sti	%g3, %g31, 516
	return

!==============================
! args = [%g4, %g8, %g7, %g6, %g5]
! fargs = [%f4, %f3, %f2]
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %f5, %f4, %f3, %f2, %f16, %f15, %f1, %f0, %dummy]
! ret type = Bool
!================================
solver_rect_surface.2725:
	slli	%g3, %g7, 2
	fld	%f5, %g8, %g3
	fmov	%f0, %f5
	subi	%g1, %g1, 4
	call	fiszero.2492
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7771
	mov	%g3, %g4
	subi	%g1, %g1, 4
	call	o_param_abc.2647
	mov	%g9, %g3
	mov	%g3, %g4
	call	o_isinvert.2637
	mov	%g4, %g3
	fmov	%f0, %f5
	call	fisneg.2490
	call	xor.2494
	slli	%g4, %g7, 2
	fld	%f1, %g9, %g4
	call	fneg_cond.2579
	fsub	%f0, %f0, %f4
	fdiv	%f4, %f0, %f5
	slli	%g3, %g6, 2
	fld	%f0, %g8, %g3
	fmul	%f0, %f4, %f0
	fadd	%f1, %f0, %f3
	call	fabs.2497
	fmov	%f1, %f0
	slli	%g3, %g6, 2
	fld	%f0, %g9, %g3
	call	fless.2485
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7772
	addi	%g3, %g0, 0
	return
jeq_else.7772:
	slli	%g3, %g5, 2
	fld	%f0, %g8, %g3
	fmul	%f0, %f4, %f0
	fadd	%f1, %f0, %f2
	subi	%g1, %g1, 4
	call	fabs.2497
	fmov	%f1, %f0
	slli	%g3, %g5, 2
	fld	%f0, %g9, %g3
	call	fless.2485
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7773
	addi	%g3, %g0, 0
	return
jeq_else.7773:
	fsti	%f4, %g31, 520
	addi	%g3, %g0, 1
	return
jeq_else.7771:
	addi	%g3, %g0, 0
	return

!==============================
! args = [%g4, %g8]
! fargs = [%f8, %f7, %f6]
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f16, %f15, %f1, %f0, %dummy]
! ret type = Int
!================================
solver_rect.2734:
	addi	%g7, %g0, 0
	addi	%g6, %g0, 1
	addi	%g5, %g0, 2
	sti	%g8, %g1, 0
	sti	%g4, %g1, 4
	fmov	%f2, %f6
	fmov	%f3, %f7
	fmov	%f4, %f8
	subi	%g1, %g1, 12
	call	solver_rect_surface.2725
	addi	%g1, %g1, 12
	jne	%g3, %g0, jeq_else.7774
	addi	%g7, %g0, 1
	addi	%g6, %g0, 2
	addi	%g5, %g0, 0
	ldi	%g4, %g1, 4
	ldi	%g8, %g1, 0
	fmov	%f2, %f8
	fmov	%f3, %f6
	fmov	%f4, %f7
	subi	%g1, %g1, 12
	call	solver_rect_surface.2725
	addi	%g1, %g1, 12
	jne	%g3, %g0, jeq_else.7775
	addi	%g7, %g0, 2
	addi	%g6, %g0, 0
	addi	%g5, %g0, 1
	ldi	%g4, %g1, 4
	ldi	%g8, %g1, 0
	fmov	%f2, %f7
	fmov	%f3, %f8
	fmov	%f4, %f6
	subi	%g1, %g1, 12
	call	solver_rect_surface.2725
	addi	%g1, %g1, 12
	jne	%g3, %g0, jeq_else.7776
	addi	%g3, %g0, 0
	return
jeq_else.7776:
	addi	%g3, %g0, 3
	return
jeq_else.7775:
	addi	%g3, %g0, 2
	return
jeq_else.7774:
	addi	%g3, %g0, 1
	return

!==============================
! args = [%g3, %g4]
! fargs = [%f2, %f1, %f4]
! use_regs = [%g5, %g4, %g3, %g27, %f5, %f4, %f3, %f2, %f16, %f15, %f1, %f0, %dummy]
! ret type = Int
!================================
solver_surface.2740:
	subi	%g1, %g1, 4
	call	o_param_abc.2647
	addi	%g1, %g1, 4
	mov	%g5, %g3
	fsti	%f1, %g1, 0
	fsti	%f2, %g1, 4
	mov	%g3, %g5
	subi	%g1, %g1, 12
	call	veciprod.2606
	fmov	%f5, %f0
	fmov	%f0, %f5
	call	fispos.2488
	addi	%g1, %g1, 12
	jne	%g3, %g0, jeq_else.7777
	addi	%g3, %g0, 0
	return
jeq_else.7777:
	fldi	%f2, %g1, 4
	fldi	%f1, %g1, 0
	mov	%g3, %g5
	fmov	%f0, %f4
	subi	%g1, %g1, 12
	call	veciprod2.2609
	call	fneg.2501
	addi	%g1, %g1, 12
	fdiv	%f0, %f0, %f5
	fsti	%f0, %g31, 520
	addi	%g3, %g0, 1
	return

!==============================
! args = [%g3]
! fargs = [%f3, %f2, %f1]
! use_regs = [%g4, %g3, %g27, %f5, %f4, %f3, %f2, %f15, %f1, %f0]
! ret type = Float
!================================
quadratic.2746:
	fmov	%f0, %f3
	subi	%g1, %g1, 4
	call	fsqr.2505
	addi	%g1, %g1, 4
	fmov	%f4, %f0
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_a.2641
	fmul	%f5, %f4, %f0
	fmov	%f0, %f2
	call	fsqr.2505
	addi	%g1, %g1, 8
	fmov	%f4, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_b.2643
	fmul	%f0, %f4, %f0
	fadd	%f5, %f5, %f0
	fmov	%f0, %f1
	call	fsqr.2505
	addi	%g1, %g1, 8
	fmov	%f4, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_c.2645
	addi	%g1, %g1, 8
	fmul	%f0, %f4, %f0
	fadd	%f4, %f5, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_isrot.2639
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jne	%g4, %g0, jeq_else.7778
	fmov	%f0, %f4
	return
jeq_else.7778:
	fmul	%f5, %f2, %f1
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r1.2665
	addi	%g1, %g1, 8
	fmul	%f0, %f5, %f0
	fadd	%f4, %f4, %f0
	fmul	%f1, %f1, %f3
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r2.2667
	addi	%g1, %g1, 8
	fmul	%f0, %f1, %f0
	fadd	%f4, %f4, %f0
	fmul	%f1, %f3, %f2
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r3.2669
	addi	%g1, %g1, 8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f4, %f0
	return

!==============================
! args = [%g3]
! fargs = [%f5, %f7, %f2, %f6, %f4, %f1]
! use_regs = [%g4, %g3, %g27, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f19, %f15, %f1, %f0]
! ret type = Float
!================================
bilinear.2751:
	fmul	%f3, %f5, %f6
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_a.2641
	addi	%g1, %g1, 8
	fmul	%f8, %f3, %f0
	fmul	%f3, %f7, %f4
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_b.2643
	addi	%g1, %g1, 8
	fmul	%f0, %f3, %f0
	fadd	%f8, %f8, %f0
	fmul	%f3, %f2, %f1
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_c.2645
	addi	%g1, %g1, 8
	fmul	%f0, %f3, %f0
	fadd	%f3, %f8, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_isrot.2639
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jne	%g4, %g0, jeq_else.7779
	fmov	%f0, %f3
	return
jeq_else.7779:
	fmul	%f8, %f2, %f4
	fmul	%f0, %f7, %f1
	fadd	%f8, %f8, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r1.2665
	addi	%g1, %g1, 8
	fmul	%f8, %f8, %f0
	fmul	%f1, %f5, %f1
	fmul	%f0, %f2, %f6
	fadd	%f1, %f1, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r2.2667
	addi	%g1, %g1, 8
	fmul	%f0, %f1, %f0
	fadd	%f2, %f8, %f0
	fmul	%f1, %f5, %f4
	fmul	%f0, %f7, %f6
	fadd	%f1, %f1, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r3.2669
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	call	fhalf.2503
	addi	%g1, %g1, 8
	fadd	%f0, %f3, %f0
	return

!==============================
! args = [%g5, %g3]
! fargs = [%f6, %f10, %f1]
! use_regs = [%g5, %g4, %g3, %g27, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f19, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Int
!================================
solver_second.2759:
	fldi	%f12, %g3, 0
	fldi	%f7, %g3, -4
	fldi	%f11, %g3, -8
	fsti	%f1, %g1, 0
	mov	%g3, %g5
	fmov	%f1, %f11
	fmov	%f2, %f7
	fmov	%f3, %f12
	subi	%g1, %g1, 8
	call	quadratic.2746
	fmov	%f9, %f0
	fmov	%f0, %f9
	call	fiszero.2492
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7780
	fldi	%f1, %g1, 0
	fsti	%f6, %g1, 4
	mov	%g3, %g5
	fmov	%f4, %f10
	fmov	%f2, %f11
	fmov	%f5, %f12
	subi	%g1, %g1, 12
	call	bilinear.2751
	addi	%g1, %g1, 12
	fmov	%f7, %f0
	fldi	%f6, %g1, 4
	fldi	%f1, %g1, 0
	mov	%g3, %g5
	fmov	%f2, %f10
	fmov	%f3, %f6
	subi	%g1, %g1, 12
	call	quadratic.2746
	mov	%g3, %g5
	call	o_form.2633
	addi	%g1, %g1, 12
	addi	%g4, %g0, 3
	jne	%g3, %g4, jeq_else.7781
	fsub	%f1, %f0, %f17
	jmp	jeq_cont.7782
jeq_else.7781:
	fmov	%f1, %f0
jeq_cont.7782:
	fmov	%f0, %f7
	subi	%g1, %g1, 12
	call	fsqr.2505
	addi	%g1, %g1, 12
	fmul	%f1, %f9, %f1
	fsub	%f0, %f0, %f1
	fsti	%f0, %g1, 8
	subi	%g1, %g1, 16
	call	fispos.2488
	addi	%g1, %g1, 16
	jne	%g3, %g0, jeq_else.7783
	addi	%g3, %g0, 0
	return
jeq_else.7783:
	fldi	%f0, %g1, 8
	fsqrt	%f1, %f0
	mov	%g3, %g5
	subi	%g1, %g1, 16
	call	o_isinvert.2637
	addi	%g1, %g1, 16
	jne	%g3, %g0, jeq_else.7784
	fmov	%f0, %f1
	subi	%g1, %g1, 16
	call	fneg.2501
	addi	%g1, %g1, 16
	jmp	jeq_cont.7785
jeq_else.7784:
	fmov	%f0, %f1
jeq_cont.7785:
	fsub	%f0, %f0, %f7
	fdiv	%f0, %f0, %f9
	fsti	%f0, %g31, 520
	addi	%g3, %g0, 1
	return
jeq_else.7780:
	addi	%g3, %g0, 0
	return

!==============================
! args = [%g3, %g8, %g4]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f19, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Int
!================================
solver.2765:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g10, %g3, 272
	fldi	%f1, %g4, 0
	mov	%g3, %g10
	subi	%g1, %g1, 4
	call	o_param_x.2649
	fsub	%f8, %f1, %f0
	fldi	%f1, %g4, -4
	mov	%g3, %g10
	call	o_param_y.2651
	fsub	%f10, %f1, %f0
	fldi	%f1, %g4, -8
	mov	%g3, %g10
	call	o_param_z.2653
	fsub	%f6, %f1, %f0
	mov	%g3, %g10
	call	o_form.2633
	addi	%g1, %g1, 4
	mov	%g4, %g3
	jne	%g4, %g28, jeq_else.7786
	mov	%g4, %g10
	fmov	%f7, %f10
	jmp	solver_rect.2734
jeq_else.7786:
	addi	%g3, %g0, 2
	jne	%g4, %g3, jeq_else.7787
	mov	%g4, %g8
	mov	%g3, %g10
	fmov	%f4, %f6
	fmov	%f1, %f10
	fmov	%f2, %f8
	jmp	solver_surface.2740
jeq_else.7787:
	mov	%g3, %g8
	mov	%g5, %g10
	fmov	%f1, %f6
	fmov	%f6, %f8
	jmp	solver_second.2759

!==============================
! args = [%g6, %g4, %g5]
! fargs = [%f4, %f6, %f3]
! use_regs = [%g6, %g5, %g4, %g3, %g27, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f16, %f15, %f1, %f0, %dummy]
! ret type = Int
!================================
solver_rect_fast.2769:
	fldi	%f0, %g5, 0
	fsub	%f0, %f0, %f4
	fldi	%f2, %g5, -4
	fmul	%f7, %f0, %f2
	fldi	%f0, %g4, -4
	fmul	%f0, %f7, %f0
	fadd	%f1, %f0, %f6
	subi	%g1, %g1, 4
	call	fabs.2497
	fmov	%f1, %f0
	mov	%g3, %g6
	call	o_param_b.2643
	fmov	%f5, %f0
	fmov	%f0, %f5
	call	fless.2485
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7788
	addi	%g3, %g0, 0
	jmp	jeq_cont.7789
jeq_else.7788:
	fldi	%f0, %g4, -8
	fmul	%f0, %f7, %f0
	fadd	%f1, %f0, %f3
	subi	%g1, %g1, 4
	call	fabs.2497
	fmov	%f1, %f0
	mov	%g3, %g6
	call	o_param_c.2645
	call	fless.2485
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7790
	addi	%g3, %g0, 0
	jmp	jeq_cont.7791
jeq_else.7790:
	fmov	%f0, %f2
	subi	%g1, %g1, 4
	call	fiszero.2492
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7792
	addi	%g3, %g0, 1
	jmp	jeq_cont.7793
jeq_else.7792:
	addi	%g3, %g0, 0
jeq_cont.7793:
jeq_cont.7791:
jeq_cont.7789:
	jne	%g3, %g0, jeq_else.7794
	fldi	%f0, %g5, -8
	fsub	%f0, %f0, %f6
	fldi	%f7, %g5, -12
	fmul	%f8, %f0, %f7
	fldi	%f0, %g4, 0
	fmul	%f0, %f8, %f0
	fadd	%f1, %f0, %f4
	subi	%g1, %g1, 4
	call	fabs.2497
	fmov	%f1, %f0
	mov	%g3, %g6
	call	o_param_a.2641
	fmov	%f2, %f0
	fmov	%f0, %f2
	call	fless.2485
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7795
	addi	%g3, %g0, 0
	jmp	jeq_cont.7796
jeq_else.7795:
	fldi	%f0, %g4, -8
	fmul	%f0, %f8, %f0
	fadd	%f1, %f0, %f3
	subi	%g1, %g1, 4
	call	fabs.2497
	fmov	%f1, %f0
	mov	%g3, %g6
	call	o_param_c.2645
	call	fless.2485
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7797
	addi	%g3, %g0, 0
	jmp	jeq_cont.7798
jeq_else.7797:
	fmov	%f0, %f7
	subi	%g1, %g1, 4
	call	fiszero.2492
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7799
	addi	%g3, %g0, 1
	jmp	jeq_cont.7800
jeq_else.7799:
	addi	%g3, %g0, 0
jeq_cont.7800:
jeq_cont.7798:
jeq_cont.7796:
	jne	%g3, %g0, jeq_else.7801
	fldi	%f0, %g5, -16
	fsub	%f0, %f0, %f3
	fldi	%f3, %g5, -20
	fmul	%f7, %f0, %f3
	fldi	%f0, %g4, 0
	fmul	%f0, %f7, %f0
	fadd	%f1, %f0, %f4
	subi	%g1, %g1, 4
	call	fabs.2497
	fmov	%f1, %f0
	fmov	%f0, %f2
	call	fless.2485
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7802
	addi	%g3, %g0, 0
	jmp	jeq_cont.7803
jeq_else.7802:
	fldi	%f0, %g4, -4
	fmul	%f0, %f7, %f0
	fadd	%f1, %f0, %f6
	subi	%g1, %g1, 4
	call	fabs.2497
	fmov	%f1, %f0
	fmov	%f0, %f5
	call	fless.2485
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7804
	addi	%g3, %g0, 0
	jmp	jeq_cont.7805
jeq_else.7804:
	fmov	%f0, %f3
	subi	%g1, %g1, 4
	call	fiszero.2492
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7806
	addi	%g3, %g0, 1
	jmp	jeq_cont.7807
jeq_else.7806:
	addi	%g3, %g0, 0
jeq_cont.7807:
jeq_cont.7805:
jeq_cont.7803:
	jne	%g3, %g0, jeq_else.7808
	addi	%g3, %g0, 0
	return
jeq_else.7808:
	fsti	%f7, %g31, 520
	addi	%g3, %g0, 3
	return
jeq_else.7801:
	fsti	%f8, %g31, 520
	addi	%g3, %g0, 2
	return
jeq_else.7794:
	fsti	%f7, %g31, 520
	addi	%g3, %g0, 1
	return

!==============================
! args = [%g3, %g4]
! fargs = [%f3, %f2, %f1]
! use_regs = [%g4, %g3, %g27, %f3, %f2, %f16, %f15, %f1, %f0, %dummy]
! ret type = Int
!================================
solver_surface_fast.2776:
	fldi	%f0, %g4, 0
	subi	%g1, %g1, 4
	call	fisneg.2490
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7809
	addi	%g3, %g0, 0
	return
jeq_else.7809:
	fldi	%f0, %g4, -4
	fmul	%f3, %f0, %f3
	fldi	%f0, %g4, -8
	fmul	%f0, %f0, %f2
	fadd	%f2, %f3, %f0
	fldi	%f0, %g4, -12
	fmul	%f0, %f0, %f1
	fadd	%f0, %f2, %f0
	fsti	%f0, %g31, 520
	addi	%g3, %g0, 1
	return

!==============================
! args = [%g6, %g5]
! fargs = [%f3, %f2, %f1]
! use_regs = [%g6, %g5, %g4, %g3, %g27, %f7, %f6, %f5, %f4, %f3, %f2, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Int
!================================
solver_second_fast.2782:
	fldi	%f7, %g5, 0
	fmov	%f0, %f7
	subi	%g1, %g1, 4
	call	fiszero.2492
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7810
	fldi	%f0, %g5, -4
	fmul	%f4, %f0, %f3
	fldi	%f0, %g5, -8
	fmul	%f0, %f0, %f2
	fadd	%f4, %f4, %f0
	fldi	%f0, %g5, -12
	fmul	%f0, %f0, %f1
	fadd	%f6, %f4, %f0
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	quadratic.2746
	mov	%g3, %g6
	call	o_form.2633
	addi	%g1, %g1, 4
	addi	%g4, %g0, 3
	jne	%g3, %g4, jeq_else.7811
	fsub	%f1, %f0, %f17
	jmp	jeq_cont.7812
jeq_else.7811:
	fmov	%f1, %f0
jeq_cont.7812:
	fmov	%f0, %f6
	subi	%g1, %g1, 4
	call	fsqr.2505
	addi	%g1, %g1, 4
	fmul	%f1, %f7, %f1
	fsub	%f0, %f0, %f1
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fispos.2488
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7813
	addi	%g3, %g0, 0
	return
jeq_else.7813:
	mov	%g3, %g6
	subi	%g1, %g1, 8
	call	o_isinvert.2637
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7814
	fldi	%f0, %g1, 0
	fsqrt	%f0, %f0
	fsub	%f1, %f6, %f0
	fldi	%f0, %g5, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g31, 520
	jmp	jeq_cont.7815
jeq_else.7814:
	fldi	%f0, %g1, 0
	fsqrt	%f0, %f0
	fadd	%f1, %f6, %f0
	fldi	%f0, %g5, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g31, 520
jeq_cont.7815:
	addi	%g3, %g0, 1
	return
jeq_else.7810:
	addi	%g3, %g0, 0
	return

!==============================
! args = [%g5, %g7, %g4]
! fargs = []
! use_regs = [%g7, %g6, %g5, %g4, %g3, %g27, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Int
!================================
solver_fast.2788:
	slli	%g3, %g5, 2
	add	%g3, %g31, %g3
	ldi	%g6, %g3, 272
	fldi	%f1, %g4, 0
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	o_param_x.2649
	fsub	%f3, %f1, %f0
	fldi	%f1, %g4, -4
	mov	%g3, %g6
	call	o_param_y.2651
	fsub	%f2, %f1, %f0
	fldi	%f1, %g4, -8
	mov	%g3, %g6
	call	o_param_z.2653
	fsub	%f1, %f1, %f0
	mov	%g3, %g7
	call	d_const.2694
	slli	%g4, %g5, 2
	ld	%g5, %g3, %g4
	mov	%g3, %g6
	call	o_form.2633
	addi	%g1, %g1, 4
	mov	%g4, %g3
	jne	%g4, %g28, jeq_else.7816
	mov	%g3, %g7
	subi	%g1, %g1, 4
	call	d_vec.2692
	addi	%g1, %g1, 4
	mov	%g4, %g3
	fmov	%f6, %f2
	fmov	%f4, %f3
	fmov	%f3, %f1
	jmp	solver_rect_fast.2769
jeq_else.7816:
	addi	%g3, %g0, 2
	jne	%g4, %g3, jeq_else.7817
	mov	%g4, %g5
	mov	%g3, %g6
	jmp	solver_surface_fast.2776
jeq_else.7817:
	jmp	solver_second_fast.2782

!==============================
! args = [%g3, %g5, %g4]
! fargs = [%f2, %f1, %f0]
! use_regs = [%g5, %g4, %g3, %g27, %f2, %f16, %f15, %f1, %f0, %dummy]
! ret type = Int
!================================
solver_surface_fast2.2792:
	fldi	%f0, %g5, 0
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fisneg.2490
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7818
	addi	%g3, %g0, 0
	return
jeq_else.7818:
	fldi	%f1, %g4, -12
	fldi	%f0, %g1, 0
	fmul	%f0, %f0, %f1
	fsti	%f0, %g31, 520
	addi	%g3, %g0, 1
	return

!==============================
! args = [%g6, %g5, %g4]
! fargs = [%f3, %f2, %f1]
! use_regs = [%g6, %g5, %g4, %g3, %g27, %f4, %f3, %f2, %f16, %f15, %f1, %f0, %dummy]
! ret type = Int
!================================
solver_second_fast2.2799:
	fldi	%f4, %g5, 0
	fmov	%f0, %f4
	subi	%g1, %g1, 4
	call	fiszero.2492
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7819
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
	call	fsqr.2505
	addi	%g1, %g1, 4
	fmul	%f2, %f4, %f2
	fsub	%f0, %f0, %f2
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fispos.2488
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7820
	addi	%g3, %g0, 0
	return
jeq_else.7820:
	mov	%g3, %g6
	subi	%g1, %g1, 8
	call	o_isinvert.2637
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7821
	fldi	%f0, %g1, 0
	fsqrt	%f0, %f0
	fsub	%f1, %f1, %f0
	fldi	%f0, %g5, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g31, 520
	jmp	jeq_cont.7822
jeq_else.7821:
	fldi	%f0, %g1, 0
	fsqrt	%f0, %f0
	fadd	%f1, %f1, %f0
	fldi	%f0, %g5, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g31, 520
jeq_cont.7822:
	addi	%g3, %g0, 1
	return
jeq_else.7819:
	addi	%g3, %g0, 0
	return

!==============================
! args = [%g4, %g5]
! fargs = []
! use_regs = [%g8, %g7, %g6, %g5, %g4, %g3, %g27, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f16, %f15, %f1, %f0, %dummy]
! ret type = Int
!================================
solver_fast2.2806:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g6, %g3, 272
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	o_param_ctbl.2671
	mov	%g8, %g3
	fldi	%f4, %g8, 0
	fldi	%f6, %g8, -4
	fldi	%f3, %g8, -8
	mov	%g3, %g5
	call	d_const.2694
	slli	%g4, %g4, 2
	ld	%g7, %g3, %g4
	mov	%g3, %g6
	call	o_form.2633
	addi	%g1, %g1, 4
	mov	%g4, %g3
	jne	%g4, %g28, jeq_else.7823
	mov	%g3, %g5
	subi	%g1, %g1, 4
	call	d_vec.2692
	addi	%g1, %g1, 4
	mov	%g4, %g3
	mov	%g5, %g7
	jmp	solver_rect_fast.2769
jeq_else.7823:
	addi	%g3, %g0, 2
	jne	%g4, %g3, jeq_else.7824
	mov	%g4, %g8
	mov	%g5, %g7
	mov	%g3, %g6
	fmov	%f0, %f3
	fmov	%f1, %f6
	fmov	%f2, %f4
	jmp	solver_surface_fast2.2792
jeq_else.7824:
	mov	%g4, %g8
	mov	%g5, %g7
	fmov	%f1, %f3
	fmov	%f2, %f6
	fmov	%f3, %f4
	jmp	solver_second_fast2.2799

!==============================
! args = [%g5, %g6]
! fargs = []
! use_regs = [%g7, %g6, %g5, %g4, %g3, %g27, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Array(Float)
!================================
setup_rect_table.2809:
	addi	%g3, %g0, 6
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	fldi	%f0, %g5, 0
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	fiszero.2492
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jne	%g4, %g0, jeq_else.7825
	mov	%g3, %g6
	subi	%g1, %g1, 8
	call	o_isinvert.2637
	mov	%g4, %g3
	fldi	%f0, %g5, 0
	call	fisneg.2490
	mov	%g7, %g3
	mov	%g3, %g7
	call	xor.2494
	mov	%g4, %g3
	mov	%g3, %g6
	call	o_param_a.2641
	fmov	%f1, %f0
	mov	%g3, %g4
	call	fneg_cond.2579
	addi	%g1, %g1, 8
	ldi	%g3, %g1, 0
	fsti	%f0, %g3, 0
	fldi	%f0, %g5, 0
	fdiv	%f0, %f17, %f0
	fsti	%f0, %g3, -4
	jmp	jeq_cont.7826
jeq_else.7825:
	ldi	%g3, %g1, 0
	fsti	%f16, %g3, -4
jeq_cont.7826:
	fldi	%f0, %g5, -4
	subi	%g1, %g1, 8
	call	fiszero.2492
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jne	%g4, %g0, jeq_else.7827
	mov	%g3, %g6
	subi	%g1, %g1, 8
	call	o_isinvert.2637
	mov	%g4, %g3
	fldi	%f0, %g5, -4
	call	fisneg.2490
	mov	%g7, %g3
	mov	%g3, %g7
	call	xor.2494
	mov	%g4, %g3
	mov	%g3, %g6
	call	o_param_b.2643
	fmov	%f1, %f0
	mov	%g3, %g4
	call	fneg_cond.2579
	addi	%g1, %g1, 8
	ldi	%g3, %g1, 0
	fsti	%f0, %g3, -8
	fldi	%f0, %g5, -4
	fdiv	%f0, %f17, %f0
	fsti	%f0, %g3, -12
	jmp	jeq_cont.7828
jeq_else.7827:
	ldi	%g3, %g1, 0
	fsti	%f16, %g3, -12
jeq_cont.7828:
	fldi	%f0, %g5, -8
	subi	%g1, %g1, 8
	call	fiszero.2492
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jne	%g4, %g0, jeq_else.7829
	mov	%g3, %g6
	subi	%g1, %g1, 8
	call	o_isinvert.2637
	mov	%g4, %g3
	fldi	%f0, %g5, -8
	call	fisneg.2490
	mov	%g7, %g3
	mov	%g3, %g7
	call	xor.2494
	mov	%g4, %g3
	mov	%g3, %g6
	call	o_param_c.2645
	fmov	%f1, %f0
	mov	%g3, %g4
	call	fneg_cond.2579
	addi	%g1, %g1, 8
	ldi	%g3, %g1, 0
	fsti	%f0, %g3, -16
	fldi	%f0, %g5, -8
	fdiv	%f0, %f17, %f0
	fsti	%f0, %g3, -20
	jmp	jeq_cont.7830
jeq_else.7829:
	ldi	%g3, %g1, 0
	fsti	%f16, %g3, -20
jeq_cont.7830:
	return

!==============================
! args = [%g5, %g6]
! fargs = []
! use_regs = [%g6, %g5, %g4, %g3, %g27, %f5, %f4, %f3, %f21, %f2, %f16, %f15, %f1, %f0, %dummy]
! ret type = Array(Float)
!================================
setup_surface_table.2812:
	addi	%g3, %g0, 4
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	fldi	%f1, %g5, 0
	sti	%g3, %g1, 0
	mov	%g3, %g6
	subi	%g1, %g1, 8
	call	o_param_a.2641
	fmov	%f4, %f0
	fmul	%f2, %f1, %f4
	fldi	%f1, %g5, -4
	mov	%g3, %g6
	call	o_param_b.2643
	fmov	%f3, %f0
	fmul	%f0, %f1, %f3
	fadd	%f5, %f2, %f0
	fldi	%f1, %g5, -8
	mov	%g3, %g6
	call	o_param_c.2645
	fmov	%f2, %f0
	fmul	%f0, %f1, %f2
	fadd	%f1, %f5, %f0
	fmov	%f0, %f1
	call	fispos.2488
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jne	%g4, %g0, jeq_else.7831
	ldi	%g3, %g1, 0
	fsti	%f16, %g3, 0
	jmp	jeq_cont.7832
jeq_else.7831:
	fdiv	%f0, %f21, %f1
	ldi	%g3, %g1, 0
	fsti	%f0, %g3, 0
	fdiv	%f0, %f4, %f1
	subi	%g1, %g1, 8
	call	fneg.2501
	fsti	%f0, %g3, -4
	fdiv	%f0, %f3, %f1
	call	fneg.2501
	fsti	%f0, %g3, -8
	fdiv	%f0, %f2, %f1
	call	fneg.2501
	addi	%g1, %g1, 8
	fsti	%f0, %g3, -12
jeq_cont.7832:
	return

!==============================
! args = [%g5, %g6]
! fargs = []
! use_regs = [%g6, %g5, %g4, %g3, %g27, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f19, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Array(Float)
!================================
setup_second_table.2815:
	addi	%g3, %g0, 5
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	fldi	%f3, %g5, 0
	fldi	%f2, %g5, -4
	fldi	%f6, %g5, -8
	sti	%g3, %g1, 0
	fsti	%f2, %g1, 4
	fsti	%f3, %g1, 8
	mov	%g3, %g6
	fmov	%f1, %f6
	subi	%g1, %g1, 16
	call	quadratic.2746
	fmov	%f5, %f0
	mov	%g3, %g6
	call	o_param_a.2641
	addi	%g1, %g1, 16
	fldi	%f3, %g1, 8
	fmul	%f0, %f3, %f0
	subi	%g1, %g1, 16
	call	fneg.2501
	fmov	%f1, %f0
	mov	%g3, %g6
	call	o_param_b.2643
	addi	%g1, %g1, 16
	fldi	%f2, %g1, 4
	fmul	%f0, %f2, %f0
	subi	%g1, %g1, 16
	call	fneg.2501
	fmov	%f2, %f0
	mov	%g3, %g6
	call	o_param_c.2645
	fmul	%f0, %f6, %f0
	call	fneg.2501
	addi	%g1, %g1, 16
	fmov	%f4, %f0
	ldi	%g3, %g1, 0
	fsti	%f5, %g3, 0
	mov	%g3, %g6
	subi	%g1, %g1, 16
	call	o_isrot.2639
	addi	%g1, %g1, 16
	mov	%g4, %g3
	jne	%g4, %g0, jeq_else.7833
	ldi	%g3, %g1, 0
	fsti	%f1, %g3, -4
	fsti	%f2, %g3, -8
	fsti	%f4, %g3, -12
	jmp	jeq_cont.7834
jeq_else.7833:
	fldi	%f6, %g5, -8
	mov	%g3, %g6
	subi	%g1, %g1, 16
	call	o_param_r2.2667
	fmov	%f3, %f0
	fmul	%f8, %f6, %f3
	fldi	%f7, %g5, -4
	mov	%g3, %g6
	call	o_param_r3.2669
	fmov	%f6, %f0
	fmul	%f0, %f7, %f6
	fadd	%f0, %f8, %f0
	call	fhalf.2503
	addi	%g1, %g1, 16
	fsub	%f0, %f1, %f0
	ldi	%g3, %g1, 0
	fsti	%f0, %g3, -4
	fldi	%f7, %g5, -8
	mov	%g3, %g6
	subi	%g1, %g1, 16
	call	o_param_r1.2665
	fmov	%f1, %f0
	fmul	%f7, %f7, %f1
	fldi	%f0, %g5, 0
	fmul	%f0, %f0, %f6
	fadd	%f0, %f7, %f0
	call	fhalf.2503
	addi	%g1, %g1, 16
	fsub	%f0, %f2, %f0
	ldi	%g3, %g1, 0
	fsti	%f0, %g3, -8
	fldi	%f0, %g5, -4
	fmul	%f1, %f0, %f1
	fldi	%f0, %g5, 0
	fmul	%f0, %f0, %f3
	fadd	%f0, %f1, %f0
	subi	%g1, %g1, 16
	call	fhalf.2503
	addi	%g1, %g1, 16
	fsub	%f0, %f4, %f0
	fsti	%f0, %g3, -12
jeq_cont.7834:
	fmov	%f0, %f5
	subi	%g1, %g1, 16
	call	fiszero.2492
	addi	%g1, %g1, 16
	mov	%g4, %g3
	jne	%g4, %g0, jeq_else.7835
	fdiv	%f0, %f17, %f5
	ldi	%g3, %g1, 0
	fsti	%f0, %g3, -16
	jmp	jeq_cont.7836
jeq_else.7835:
jeq_cont.7836:
	ldi	%g3, %g1, 0
	return

!==============================
! args = [%g9, %g8]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g10, %f8, %f7, %f6, %f5, %f4, %f3, %f21, %f2, %f19, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
iter_setup_dirvec_constants.2818:
	jlt	%g8, %g0, jge_else.7837
	slli	%g3, %g8, 2
	add	%g3, %g31, %g3
	ldi	%g6, %g3, 272
	mov	%g3, %g9
	subi	%g1, %g1, 4
	call	d_const.2694
	mov	%g10, %g3
	mov	%g3, %g9
	call	d_vec.2692
	mov	%g5, %g3
	mov	%g3, %g6
	call	o_form.2633
	addi	%g1, %g1, 4
	jne	%g3, %g28, jeq_else.7838
	subi	%g1, %g1, 4
	call	setup_rect_table.2809
	addi	%g1, %g1, 4
	slli	%g4, %g8, 2
	st	%g3, %g10, %g4
	jmp	jeq_cont.7839
jeq_else.7838:
	addi	%g4, %g0, 2
	jne	%g3, %g4, jeq_else.7840
	subi	%g1, %g1, 4
	call	setup_surface_table.2812
	addi	%g1, %g1, 4
	slli	%g4, %g8, 2
	st	%g3, %g10, %g4
	jmp	jeq_cont.7841
jeq_else.7840:
	subi	%g1, %g1, 4
	call	setup_second_table.2815
	addi	%g1, %g1, 4
	slli	%g4, %g8, 2
	st	%g3, %g10, %g4
jeq_cont.7841:
jeq_cont.7839:
	subi	%g8, %g8, 1
	jmp	iter_setup_dirvec_constants.2818
jge_else.7837:
	return

!==============================
! args = [%g9]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g10, %f8, %f7, %f6, %f5, %f4, %f3, %f21, %f2, %f19, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
setup_dirvec_constants.2821:
	ldi	%g3, %g31, 28
	subi	%g8, %g3, 1
	jmp	iter_setup_dirvec_constants.2818

!==============================
! args = [%g6, %g5]
! fargs = []
! use_regs = [%g8, %g7, %g6, %g5, %g4, %g3, %g27, %f5, %f4, %f3, %f2, %f17, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
setup_startp_constants.2823:
	jlt	%g5, %g0, jge_else.7843
	slli	%g3, %g5, 2
	add	%g3, %g31, %g3
	ldi	%g3, %g3, 272
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_ctbl.2671
	addi	%g1, %g1, 8
	mov	%g7, %g3
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_form.2633
	addi	%g1, %g1, 8
	mov	%g8, %g3
	fldi	%f1, %g6, 0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_x.2649
	addi	%g1, %g1, 8
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, 0
	fldi	%f1, %g6, -4
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_y.2651
	addi	%g1, %g1, 8
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, -4
	fldi	%f1, %g6, -8
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_z.2653
	addi	%g1, %g1, 8
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, -8
	addi	%g4, %g0, 2
	jne	%g8, %g4, jeq_else.7844
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_abc.2647
	fldi	%f2, %g7, 0
	fldi	%f1, %g7, -4
	fldi	%f0, %g7, -8
	call	veciprod2.2609
	addi	%g1, %g1, 8
	fsti	%f0, %g7, -12
	jmp	jeq_cont.7845
jeq_else.7844:
	addi	%g4, %g0, 2
	jlt	%g4, %g8, jle_else.7846
	jmp	jle_cont.7847
jle_else.7846:
	fldi	%f3, %g7, 0
	fldi	%f2, %g7, -4
	fldi	%f1, %g7, -8
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	quadratic.2746
	addi	%g1, %g1, 8
	addi	%g3, %g0, 3
	jne	%g8, %g3, jeq_else.7848
	fsub	%f1, %f0, %f17
	jmp	jeq_cont.7849
jeq_else.7848:
	fmov	%f1, %f0
jeq_cont.7849:
	fsti	%f1, %g7, -12
jle_cont.7847:
jeq_cont.7845:
	subi	%g5, %g5, 1
	jmp	setup_startp_constants.2823
jge_else.7843:
	return

!==============================
! args = [%g6]
! fargs = []
! use_regs = [%g8, %g7, %g6, %g5, %g4, %g3, %g27, %f5, %f4, %f3, %f2, %f17, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
setup_startp.2826:
	subi	%g4, %g31, 636
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	veccpy.2595
	addi	%g1, %g1, 4
	ldi	%g3, %g31, 28
	subi	%g5, %g3, 1
	jmp	setup_startp_constants.2823

!==============================
! args = [%g4]
! fargs = [%f1, %f3, %f2]
! use_regs = [%g4, %g3, %g27, %f3, %f2, %f16, %f15, %f1, %f0]
! ret type = Bool
!================================
is_rect_outside.2828:
	subi	%g1, %g1, 4
	call	fabs.2497
	fmov	%f1, %f0
	mov	%g3, %g4
	call	o_param_a.2641
	call	fless.2485
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7851
	addi	%g3, %g0, 0
	jmp	jeq_cont.7852
jeq_else.7851:
	fmov	%f1, %f3
	subi	%g1, %g1, 4
	call	fabs.2497
	fmov	%f1, %f0
	mov	%g3, %g4
	call	o_param_b.2643
	call	fless.2485
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7853
	addi	%g3, %g0, 0
	jmp	jeq_cont.7854
jeq_else.7853:
	fmov	%f1, %f2
	subi	%g1, %g1, 4
	call	fabs.2497
	fmov	%f1, %f0
	mov	%g3, %g4
	call	o_param_c.2645
	call	fless.2485
	addi	%g1, %g1, 4
jeq_cont.7854:
jeq_cont.7852:
	jne	%g3, %g0, jeq_else.7855
	mov	%g3, %g4
	subi	%g1, %g1, 4
	call	o_isinvert.2637
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7856
	addi	%g3, %g0, 1
	return
jeq_else.7856:
	addi	%g3, %g0, 0
	return
jeq_else.7855:
	mov	%g3, %g4
	jmp	o_isinvert.2637

!==============================
! args = [%g3]
! fargs = [%f2, %f1, %f0]
! use_regs = [%g4, %g3, %g27, %f3, %f2, %f16, %f15, %f1, %f0]
! ret type = Bool
!================================
is_plane_outside.2833:
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_abc.2647
	mov	%g4, %g3
	mov	%g3, %g4
	call	veciprod2.2609
	addi	%g1, %g1, 8
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_isinvert.2637
	mov	%g4, %g3
	call	fisneg.2490
	call	xor.2494
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7857
	addi	%g3, %g0, 1
	return
jeq_else.7857:
	addi	%g3, %g0, 0
	return

!==============================
! args = [%g3]
! fargs = [%f3, %f2, %f1]
! use_regs = [%g5, %g4, %g3, %g27, %f5, %f4, %f3, %f2, %f17, %f16, %f15, %f1, %f0]
! ret type = Bool
!================================
is_second_outside.2838:
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	quadratic.2746
	addi	%g1, %g1, 8
	fmov	%f1, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_form.2633
	addi	%g1, %g1, 8
	mov	%g4, %g3
	addi	%g5, %g0, 3
	jne	%g4, %g5, jeq_else.7858
	fsub	%f0, %f1, %f17
	jmp	jeq_cont.7859
jeq_else.7858:
	fmov	%f0, %f1
jeq_cont.7859:
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_isinvert.2637
	mov	%g4, %g3
	call	fisneg.2490
	call	xor.2494
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7860
	addi	%g3, %g0, 1
	return
jeq_else.7860:
	addi	%g3, %g0, 0
	return

!==============================
! args = [%g6]
! fargs = [%f3, %f2, %f1]
! use_regs = [%g6, %g5, %g4, %g3, %g27, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f17, %f16, %f15, %f1, %f0]
! ret type = Bool
!================================
is_outside.2843:
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	o_param_x.2649
	fsub	%f8, %f3, %f0
	mov	%g3, %g6
	call	o_param_y.2651
	fsub	%f7, %f2, %f0
	mov	%g3, %g6
	call	o_param_z.2653
	fsub	%f6, %f1, %f0
	mov	%g3, %g6
	call	o_form.2633
	addi	%g1, %g1, 4
	mov	%g4, %g3
	jne	%g4, %g28, jeq_else.7861
	mov	%g4, %g6
	fmov	%f2, %f6
	fmov	%f3, %f7
	fmov	%f1, %f8
	jmp	is_rect_outside.2828
jeq_else.7861:
	addi	%g3, %g0, 2
	jne	%g4, %g3, jeq_else.7862
	mov	%g3, %g6
	fmov	%f0, %f6
	fmov	%f1, %f7
	fmov	%f2, %f8
	jmp	is_plane_outside.2833
jeq_else.7862:
	mov	%g3, %g6
	fmov	%f1, %f6
	fmov	%f2, %f7
	fmov	%f3, %f8
	jmp	is_second_outside.2838

!==============================
! args = [%g7, %g8]
! fargs = [%f3, %f2, %f1]
! use_regs = [%g8, %g7, %g6, %g5, %g4, %g3, %g27, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f17, %f16, %f15, %f1, %f0]
! ret type = Bool
!================================
check_all_inside.2848:
	slli	%g3, %g7, 2
	ld	%g4, %g8, %g3
	jne	%g4, %g29, jeq_else.7863
	addi	%g3, %g0, 1
	return
jeq_else.7863:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g6, %g3, 272
	fsti	%f1, %g1, 0
	fsti	%f2, %g1, 4
	fsti	%f3, %g1, 8
	subi	%g1, %g1, 16
	call	is_outside.2843
	addi	%g1, %g1, 16
	jne	%g3, %g0, jeq_else.7864
	addi	%g7, %g7, 1
	fldi	%f3, %g1, 8
	fldi	%f2, %g1, 4
	fldi	%f1, %g1, 0
	jmp	check_all_inside.2848
jeq_else.7864:
	addi	%g3, %g0, 0
	return

!==============================
! args = [%g9, %g8]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %f8, %f7, %f6, %f5, %f4, %f3, %f25, %f2, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Bool
!================================
shadow_check_and_group.2854:
	slli	%g3, %g9, 2
	ld	%g5, %g8, %g3
	jne	%g5, %g29, jeq_else.7865
	addi	%g3, %g0, 0
	return
jeq_else.7865:
	subi	%g4, %g31, 540
	subi	%g7, %g31, 980
	sti	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	solver_fast.2788
	addi	%g1, %g1, 8
	fldi	%f1, %g31, 520
	fsti	%f1, %g1, 4
	jne	%g3, %g0, jeq_else.7866
	addi	%g3, %g0, 0
	jmp	jeq_cont.7867
jeq_else.7866:
	setL %g3, l.6817
	fldi	%f0, %g3, 0
	subi	%g1, %g1, 12
	call	fless.2485
	addi	%g1, %g1, 12
jeq_cont.7867:
	jne	%g3, %g0, jeq_else.7868
	ldi	%g5, %g1, 0
	slli	%g3, %g5, 2
	add	%g3, %g31, %g3
	ldi	%g3, %g3, 272
	subi	%g1, %g1, 12
	call	o_isinvert.2637
	addi	%g1, %g1, 12
	jne	%g3, %g0, jeq_else.7869
	addi	%g3, %g0, 0
	return
jeq_else.7869:
	addi	%g9, %g9, 1
	jmp	shadow_check_and_group.2854
jeq_else.7868:
	fldi	%f1, %g1, 4
	fadd	%f0, %f1, %f25
	fldi	%f1, %g31, 308
	fmul	%f2, %f1, %f0
	fldi	%f1, %g31, 540
	fadd	%f3, %f2, %f1
	fldi	%f1, %g31, 304
	fmul	%f2, %f1, %f0
	fldi	%f1, %g31, 536
	fadd	%f2, %f2, %f1
	fldi	%f1, %g31, 300
	fmul	%f1, %f1, %f0
	fldi	%f0, %g31, 532
	fadd	%f1, %f1, %f0
	addi	%g7, %g0, 0
	sti	%g8, %g1, 8
	subi	%g1, %g1, 16
	call	check_all_inside.2848
	addi	%g1, %g1, 16
	jne	%g3, %g0, jeq_else.7870
	addi	%g9, %g9, 1
	ldi	%g8, %g1, 8
	jmp	shadow_check_and_group.2854
jeq_else.7870:
	addi	%g3, %g0, 1
	return

!==============================
! args = [%g10, %g11]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g11, %g10, %f8, %f7, %f6, %f5, %f4, %f3, %f25, %f2, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Bool
!================================
shadow_check_one_or_group.2857:
	slli	%g3, %g10, 2
	ld	%g4, %g11, %g3
	jne	%g4, %g29, jeq_else.7871
	addi	%g3, %g0, 0
	return
jeq_else.7871:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g8, %g3, 512
	addi	%g9, %g0, 0
	subi	%g1, %g1, 4
	call	shadow_check_and_group.2854
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7872
	addi	%g10, %g10, 1
	jmp	shadow_check_one_or_group.2857
jeq_else.7872:
	addi	%g3, %g0, 1
	return

!==============================
! args = [%g12, %g13]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g13, %g12, %g11, %g10, %f8, %f7, %f6, %f5, %f4, %f3, %f25, %f24, %f2, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Bool
!================================
shadow_check_one_or_matrix.2860:
	slli	%g3, %g12, 2
	ld	%g11, %g13, %g3
	ldi	%g5, %g11, 0
	jne	%g5, %g29, jeq_else.7873
	addi	%g3, %g0, 0
	return
jeq_else.7873:
	addi	%g3, %g0, 99
	sti	%g11, %g1, 0
	jne	%g5, %g3, jeq_else.7874
	addi	%g3, %g0, 1
	jmp	jeq_cont.7875
jeq_else.7874:
	subi	%g4, %g31, 540
	subi	%g7, %g31, 980
	subi	%g1, %g1, 8
	call	solver_fast.2788
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7876
	addi	%g3, %g0, 0
	jmp	jeq_cont.7877
jeq_else.7876:
	fldi	%f1, %g31, 520
	fmov	%f0, %f24
	subi	%g1, %g1, 8
	call	fless.2485
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7878
	addi	%g3, %g0, 0
	jmp	jeq_cont.7879
jeq_else.7878:
	addi	%g10, %g0, 1
	subi	%g1, %g1, 8
	call	shadow_check_one_or_group.2857
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7880
	addi	%g3, %g0, 0
	jmp	jeq_cont.7881
jeq_else.7880:
	addi	%g3, %g0, 1
jeq_cont.7881:
jeq_cont.7879:
jeq_cont.7877:
jeq_cont.7875:
	jne	%g3, %g0, jeq_else.7882
	addi	%g12, %g12, 1
	jmp	shadow_check_one_or_matrix.2860
jeq_else.7882:
	addi	%g10, %g0, 1
	ldi	%g11, %g1, 0
	subi	%g1, %g1, 8
	call	shadow_check_one_or_group.2857
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7883
	addi	%g12, %g12, 1
	jmp	shadow_check_one_or_matrix.2860
jeq_else.7883:
	addi	%g3, %g0, 1
	return

!==============================
! args = [%g11, %g14, %g13]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f25, %f2, %f19, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
solve_each_element.2863:
	slli	%g3, %g11, 2
	ld	%g12, %g14, %g3
	jne	%g12, %g29, jeq_else.7884
	return
jeq_else.7884:
	subi	%g4, %g31, 624
	mov	%g8, %g13
	mov	%g3, %g12
	subi	%g1, %g1, 4
	call	solver.2765
	addi	%g1, %g1, 4
	mov	%g9, %g3
	jne	%g9, %g0, jeq_else.7886
	slli	%g3, %g12, 2
	add	%g3, %g31, %g3
	ldi	%g3, %g3, 272
	subi	%g1, %g1, 4
	call	o_isinvert.2637
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7887
	return
jeq_else.7887:
	addi	%g11, %g11, 1
	jmp	solve_each_element.2863
jeq_else.7886:
	fldi	%f2, %g31, 520
	fmov	%f0, %f2
	fmov	%f1, %f16
	subi	%g1, %g1, 4
	call	fless.2485
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7889
	jmp	jeq_cont.7890
jeq_else.7889:
	fldi	%f0, %g31, 528
	fmov	%f1, %f2
	subi	%g1, %g1, 4
	call	fless.2485
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7891
	jmp	jeq_cont.7892
jeq_else.7891:
	fadd	%f11, %f2, %f25
	fldi	%f0, %g13, 0
	fmul	%f1, %f0, %f11
	fldi	%f0, %g31, 624
	fadd	%f3, %f1, %f0
	fldi	%f0, %g13, -4
	fmul	%f1, %f0, %f11
	fldi	%f0, %g31, 620
	fadd	%f10, %f1, %f0
	fldi	%f0, %g13, -8
	fmul	%f1, %f0, %f11
	fldi	%f0, %g31, 616
	fadd	%f9, %f1, %f0
	addi	%g7, %g0, 0
	fsti	%f3, %g1, 0
	mov	%g8, %g14
	fmov	%f1, %f9
	fmov	%f2, %f10
	subi	%g1, %g1, 8
	call	check_all_inside.2848
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7893
	jmp	jeq_cont.7894
jeq_else.7893:
	fsti	%f11, %g31, 528
	subi	%g3, %g31, 540
	fldi	%f3, %g1, 0
	fmov	%f0, %f9
	fmov	%f1, %f10
	fmov	%f2, %f3
	subi	%g1, %g1, 8
	call	vecset.2585
	addi	%g1, %g1, 8
	sti	%g12, %g31, 544
	sti	%g9, %g31, 524
jeq_cont.7894:
jeq_cont.7892:
jeq_cont.7890:
	addi	%g11, %g11, 1
	jmp	solve_each_element.2863

!==============================
! args = [%g15, %g16, %g13]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f25, %f2, %f19, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
solve_one_or_network.2867:
	slli	%g3, %g15, 2
	ld	%g3, %g16, %g3
	jne	%g3, %g29, jeq_else.7895
	return
jeq_else.7895:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g14, %g3, 512
	addi	%g11, %g0, 0
	sti	%g13, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2863
	addi	%g1, %g1, 8
	addi	%g15, %g15, 1
	ldi	%g13, %g1, 0
	jmp	solve_one_or_network.2867

!==============================
! args = [%g17, %g18, %g13]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f25, %f2, %f19, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
trace_or_matrix.2871:
	slli	%g3, %g17, 2
	ld	%g16, %g18, %g3
	ldi	%g3, %g16, 0
	jne	%g3, %g29, jeq_else.7897
	return
jeq_else.7897:
	addi	%g4, %g0, 99
	sti	%g13, %g1, 0
	jne	%g3, %g4, jeq_else.7899
	addi	%g15, %g0, 1
	subi	%g1, %g1, 8
	call	solve_one_or_network.2867
	addi	%g1, %g1, 8
	jmp	jeq_cont.7900
jeq_else.7899:
	subi	%g4, %g31, 624
	mov	%g8, %g13
	subi	%g1, %g1, 8
	call	solver.2765
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7901
	jmp	jeq_cont.7902
jeq_else.7901:
	fldi	%f1, %g31, 520
	fldi	%f0, %g31, 528
	subi	%g1, %g1, 8
	call	fless.2485
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7903
	jmp	jeq_cont.7904
jeq_else.7903:
	addi	%g15, %g0, 1
	subi	%g1, %g1, 8
	call	solve_one_or_network.2867
	addi	%g1, %g1, 8
jeq_cont.7904:
jeq_cont.7902:
jeq_cont.7900:
	addi	%g17, %g17, 1
	ldi	%g13, %g1, 0
	jmp	trace_or_matrix.2871

!==============================
! args = [%g13]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f27, %f25, %f24, %f2, %f19, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Bool
!================================
judge_intersection.2875:
	fsti	%f27, %g31, 528
	addi	%g17, %g0, 0
	ldi	%g18, %g31, 516
	subi	%g1, %g1, 4
	call	trace_or_matrix.2871
	fldi	%f2, %g31, 528
	fmov	%f0, %f2
	fmov	%f1, %f24
	call	fless.2485
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7905
	addi	%g3, %g0, 0
	return
jeq_else.7905:
	setL %g3, l.6896
	fldi	%f0, %g3, 0
	fmov	%f1, %f2
	jmp	fless.2485

!==============================
! args = [%g9, %g12, %g11]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f25, %f2, %f17, %f16, %f15, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
solve_each_element_fast.2877:
	mov	%g3, %g11
	subi	%g1, %g1, 4
	call	d_vec.2692
	addi	%g1, %g1, 4
	mov	%g13, %g3
	slli	%g3, %g9, 2
	ld	%g10, %g12, %g3
	jne	%g10, %g29, jeq_else.7906
	return
jeq_else.7906:
	mov	%g5, %g11
	mov	%g4, %g10
	subi	%g1, %g1, 4
	call	solver_fast2.2806
	addi	%g1, %g1, 4
	mov	%g14, %g3
	jne	%g14, %g0, jeq_else.7908
	slli	%g3, %g10, 2
	add	%g3, %g31, %g3
	ldi	%g3, %g3, 272
	subi	%g1, %g1, 4
	call	o_isinvert.2637
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7909
	return
jeq_else.7909:
	addi	%g9, %g9, 1
	jmp	solve_each_element_fast.2877
jeq_else.7908:
	fldi	%f2, %g31, 520
	fmov	%f0, %f2
	fmov	%f1, %f16
	subi	%g1, %g1, 4
	call	fless.2485
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7911
	jmp	jeq_cont.7912
jeq_else.7911:
	fldi	%f0, %g31, 528
	fmov	%f1, %f2
	subi	%g1, %g1, 4
	call	fless.2485
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7913
	jmp	jeq_cont.7914
jeq_else.7913:
	fadd	%f11, %f2, %f25
	fldi	%f0, %g13, 0
	fmul	%f1, %f0, %f11
	fldi	%f0, %g31, 636
	fadd	%f3, %f1, %f0
	fldi	%f0, %g13, -4
	fmul	%f1, %f0, %f11
	fldi	%f0, %g31, 632
	fadd	%f10, %f1, %f0
	fldi	%f0, %g13, -8
	fmul	%f1, %f0, %f11
	fldi	%f0, %g31, 628
	fadd	%f9, %f1, %f0
	addi	%g7, %g0, 0
	fsti	%f3, %g1, 0
	mov	%g8, %g12
	fmov	%f1, %f9
	fmov	%f2, %f10
	subi	%g1, %g1, 8
	call	check_all_inside.2848
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7915
	jmp	jeq_cont.7916
jeq_else.7915:
	fsti	%f11, %g31, 528
	subi	%g3, %g31, 540
	fldi	%f3, %g1, 0
	fmov	%f0, %f9
	fmov	%f1, %f10
	fmov	%f2, %f3
	subi	%g1, %g1, 8
	call	vecset.2585
	addi	%g1, %g1, 8
	sti	%g10, %g31, 544
	sti	%g14, %g31, 524
jeq_cont.7916:
jeq_cont.7914:
jeq_cont.7912:
	addi	%g9, %g9, 1
	jmp	solve_each_element_fast.2877

!==============================
! args = [%g15, %g16, %g11]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f25, %f2, %f17, %f16, %f15, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
solve_one_or_network_fast.2881:
	slli	%g3, %g15, 2
	ld	%g3, %g16, %g3
	jne	%g3, %g29, jeq_else.7917
	return
jeq_else.7917:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g12, %g3, 512
	addi	%g9, %g0, 0
	sti	%g11, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element_fast.2877
	addi	%g1, %g1, 8
	addi	%g15, %g15, 1
	ldi	%g11, %g1, 0
	jmp	solve_one_or_network_fast.2881

!==============================
! args = [%g17, %g18, %g11]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f25, %f2, %f17, %f16, %f15, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
trace_or_matrix_fast.2885:
	slli	%g3, %g17, 2
	ld	%g16, %g18, %g3
	ldi	%g4, %g16, 0
	jne	%g4, %g29, jeq_else.7919
	return
jeq_else.7919:
	addi	%g3, %g0, 99
	sti	%g11, %g1, 0
	jne	%g4, %g3, jeq_else.7921
	addi	%g15, %g0, 1
	subi	%g1, %g1, 8
	call	solve_one_or_network_fast.2881
	addi	%g1, %g1, 8
	jmp	jeq_cont.7922
jeq_else.7921:
	mov	%g5, %g11
	subi	%g1, %g1, 8
	call	solver_fast2.2806
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7923
	jmp	jeq_cont.7924
jeq_else.7923:
	fldi	%f1, %g31, 520
	fldi	%f0, %g31, 528
	subi	%g1, %g1, 8
	call	fless.2485
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7925
	jmp	jeq_cont.7926
jeq_else.7925:
	addi	%g15, %g0, 1
	subi	%g1, %g1, 8
	call	solve_one_or_network_fast.2881
	addi	%g1, %g1, 8
jeq_cont.7926:
jeq_cont.7924:
jeq_cont.7922:
	addi	%g17, %g17, 1
	ldi	%g11, %g1, 0
	jmp	trace_or_matrix_fast.2885

!==============================
! args = [%g11]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f27, %f25, %f24, %f2, %f17, %f16, %f15, %f11, %f10, %f1, %f0, %dummy]
! ret type = Bool
!================================
judge_intersection_fast.2889:
	fsti	%f27, %g31, 528
	addi	%g17, %g0, 0
	ldi	%g18, %g31, 516
	subi	%g1, %g1, 4
	call	trace_or_matrix_fast.2885
	fldi	%f2, %g31, 528
	fmov	%f0, %f2
	fmov	%f1, %f24
	call	fless.2485
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7927
	addi	%g3, %g0, 0
	return
jeq_else.7927:
	setL %g3, l.6896
	fldi	%f0, %g3, 0
	fmov	%f1, %f2
	jmp	fless.2485

!==============================
! args = [%g4]
! fargs = []
! use_regs = [%g5, %g4, %g3, %g27, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
get_nvector_rect.2891:
	ldi	%g5, %g31, 524
	subi	%g3, %g31, 556
	subi	%g1, %g1, 4
	call	vecbzero.2593
	subi	%g5, %g5, 1
	slli	%g3, %g5, 2
	fld	%f1, %g4, %g3
	call	sgn.2577
	call	fneg.2501
	addi	%g1, %g1, 4
	slli	%g3, %g5, 2
	add	%g3, %g31, %g3
	fsti	%f0, %g3, 556
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0, %dummy]
! ret type = Unit
!================================
get_nvector_plane.2893:
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_a.2641
	call	fneg.2501
	addi	%g1, %g1, 8
	fsti	%f0, %g31, 556
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_b.2643
	call	fneg.2501
	addi	%g1, %g1, 8
	fsti	%f0, %g31, 552
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_c.2645
	call	fneg.2501
	addi	%g1, %g1, 8
	fsti	%f0, %g31, 548
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g5, %g4, %g3, %g27, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f21, %f2, %f19, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
get_nvector_second.2895:
	fldi	%f1, %g31, 540
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_x.2649
	addi	%g1, %g1, 8
	fsub	%f5, %f1, %f0
	fldi	%f1, %g31, 536
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_y.2651
	addi	%g1, %g1, 8
	fsub	%f2, %f1, %f0
	fldi	%f1, %g31, 532
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_z.2653
	addi	%g1, %g1, 8
	fsub	%f1, %f1, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_a.2641
	addi	%g1, %g1, 8
	fmul	%f8, %f5, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_b.2643
	addi	%g1, %g1, 8
	fmul	%f3, %f2, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_c.2645
	addi	%g1, %g1, 8
	fmul	%f6, %f1, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_isrot.2639
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jne	%g4, %g0, jeq_else.7930
	fsti	%f8, %g31, 556
	fsti	%f3, %g31, 552
	fsti	%f6, %g31, 548
	jmp	jeq_cont.7931
jeq_else.7930:
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r3.2669
	addi	%g1, %g1, 8
	fmov	%f7, %f0
	fmul	%f9, %f2, %f7
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r2.2667
	fmov	%f4, %f0
	fmul	%f0, %f1, %f4
	fadd	%f0, %f9, %f0
	call	fhalf.2503
	addi	%g1, %g1, 8
	fadd	%f0, %f8, %f0
	fsti	%f0, %g31, 556
	fmul	%f8, %f5, %f7
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r1.2665
	fmov	%f7, %f0
	fmul	%f0, %f1, %f7
	fadd	%f0, %f8, %f0
	call	fhalf.2503
	fadd	%f0, %f3, %f0
	fsti	%f0, %g31, 552
	fmul	%f1, %f5, %f4
	fmul	%f0, %f2, %f7
	fadd	%f0, %f1, %f0
	call	fhalf.2503
	addi	%g1, %g1, 8
	fadd	%f0, %f6, %f0
	fsti	%f0, %g31, 548
jeq_cont.7931:
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_isinvert.2637
	addi	%g1, %g1, 8
	mov	%g5, %g3
	subi	%g4, %g31, 556
	jmp	vecunit_sgn.2603

!==============================
! args = [%g3, %g4]
! fargs = []
! use_regs = [%g5, %g4, %g3, %g27, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f21, %f2, %f19, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
get_nvector.2897:
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_form.2633
	addi	%g1, %g1, 8
	mov	%g5, %g3
	jne	%g5, %g28, jeq_else.7932
	jmp	get_nvector_rect.2891
jeq_else.7932:
	addi	%g4, %g0, 2
	jne	%g5, %g4, jeq_else.7933
	ldi	%g3, %g1, 0
	jmp	get_nvector_plane.2893
jeq_else.7933:
	ldi	%g3, %g1, 0
	jmp	get_nvector_second.2895

!==============================
! args = [%g6, %g5]
! fargs = []
! use_regs = [%g7, %g6, %g5, %g4, %g3, %g27, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f26, %f23, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
utexture.2900:
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	o_texturetype.2631
	mov	%g4, %g3
	mov	%g3, %g6
	call	o_color_red.2659
	fsti	%f0, %g31, 568
	mov	%g3, %g6
	call	o_color_green.2661
	fsti	%f0, %g31, 564
	mov	%g3, %g6
	call	o_color_blue.2663
	addi	%g1, %g1, 4
	fsti	%f0, %g31, 560
	jne	%g4, %g28, jeq_else.7934
	fldi	%f1, %g5, 0
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	o_param_x.2649
	fsub	%f5, %f1, %f0
	setL %g3, l.7015
	fldi	%f7, %g3, 0
	fmul	%f0, %f5, %f7
	call	min_caml_floor
	setL %g3, l.7017
	fldi	%f6, %g3, 0
	fmul	%f0, %f0, %f6
	fsub	%f1, %f5, %f0
	fmov	%f0, %f30
	call	fless.2485
	mov	%g7, %g3
	fldi	%f1, %g5, -8
	mov	%g3, %g6
	call	o_param_z.2653
	fsub	%f5, %f1, %f0
	fmul	%f0, %f5, %f7
	call	min_caml_floor
	fmul	%f0, %f0, %f6
	fsub	%f1, %f5, %f0
	fmov	%f0, %f30
	call	fless.2485
	addi	%g1, %g1, 4
	jne	%g7, %g0, jeq_else.7935
	jne	%g3, %g0, jeq_else.7937
	setL %g3, l.6221
	fldi	%f0, %g3, 0
	jmp	jeq_cont.7938
jeq_else.7937:
	setL %g3, l.6207
	fldi	%f0, %g3, 0
jeq_cont.7938:
	jmp	jeq_cont.7936
jeq_else.7935:
	jne	%g3, %g0, jeq_else.7939
	setL %g3, l.6207
	fldi	%f0, %g3, 0
	jmp	jeq_cont.7940
jeq_else.7939:
	setL %g3, l.6221
	fldi	%f0, %g3, 0
jeq_cont.7940:
jeq_cont.7936:
	fsti	%f0, %g31, 564
	return
jeq_else.7934:
	addi	%g3, %g0, 2
	jne	%g4, %g3, jeq_else.7942
	fldi	%f1, %g5, -4
	setL %g3, l.7007
	fldi	%f0, %g3, 0
	fmul	%f3, %f1, %f0
	subi	%g1, %g1, 4
	call	sin.2520
	call	fsqr.2505
	addi	%g1, %g1, 4
	fmul	%f1, %f18, %f0
	fsti	%f1, %g31, 568
	fsub	%f0, %f17, %f0
	fmul	%f0, %f18, %f0
	fsti	%f0, %g31, 564
	return
jeq_else.7942:
	addi	%g3, %g0, 3
	jne	%g4, %g3, jeq_else.7944
	fldi	%f1, %g5, 0
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	o_param_x.2649
	fsub	%f1, %f1, %f0
	fldi	%f2, %g5, -8
	mov	%g3, %g6
	call	o_param_z.2653
	addi	%g1, %g1, 4
	fsub	%f0, %f2, %f0
	fsti	%f0, %g1, 0
	fmov	%f0, %f1
	subi	%g1, %g1, 8
	call	fsqr.2505
	addi	%g1, %g1, 8
	fmov	%f1, %f0
	fldi	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fsqr.2505
	addi	%g1, %g1, 8
	fadd	%f0, %f1, %f0
	fsqrt	%f0, %f0
	fdiv	%f0, %f0, %f30
	fsti	%f0, %g1, 4
	subi	%g1, %g1, 12
	call	min_caml_floor
	addi	%g1, %g1, 12
	fmov	%f1, %f0
	fldi	%f0, %g1, 4
	fsub	%f0, %f0, %f1
	fmul	%f0, %f0, %f23
	subi	%g1, %g1, 12
	call	cos.2522
	call	fsqr.2505
	addi	%g1, %g1, 12
	fmul	%f1, %f0, %f18
	fsti	%f1, %g31, 564
	fsub	%f0, %f17, %f0
	fmul	%f0, %f0, %f18
	fsti	%f0, %g31, 560
	return
jeq_else.7944:
	addi	%g3, %g0, 4
	jne	%g4, %g3, jeq_else.7946
	fldi	%f1, %g5, 0
	mov	%g3, %g6
	subi	%g1, %g1, 12
	call	o_param_x.2649
	fsub	%f1, %f1, %f0
	mov	%g3, %g6
	call	o_param_a.2641
	fsqrt	%f0, %f0
	fmul	%f3, %f1, %f0
	fldi	%f1, %g5, -8
	mov	%g3, %g6
	call	o_param_z.2653
	fsub	%f1, %f1, %f0
	mov	%g3, %g6
	call	o_param_c.2645
	fsqrt	%f0, %f0
	fmul	%f2, %f1, %f0
	fmov	%f0, %f3
	call	fsqr.2505
	fmov	%f1, %f0
	fmov	%f0, %f2
	call	fsqr.2505
	fadd	%f7, %f1, %f0
	fmov	%f1, %f3
	call	fabs.2497
	fmov	%f1, %f0
	setL %g3, l.6973
	fldi	%f6, %g3, 0
	fmov	%f0, %f6
	call	fless.2485
	addi	%g1, %g1, 12
	jne	%g3, %g0, jeq_else.7947
	fdiv	%f1, %f2, %f3
	subi	%g1, %g1, 12
	call	fabs.2497
	call	atan.2514
	addi	%g1, %g1, 12
	fmul	%f0, %f0, %f31
	fdiv	%f0, %f0, %f23
	jmp	jeq_cont.7948
jeq_else.7947:
	setL %g3, l.6975
	fldi	%f0, %g3, 0
jeq_cont.7948:
	fsti	%f0, %g1, 8
	subi	%g1, %g1, 16
	call	min_caml_floor
	addi	%g1, %g1, 16
	fmov	%f1, %f0
	fldi	%f0, %g1, 8
	fsub	%f8, %f0, %f1
	fldi	%f1, %g5, -4
	mov	%g3, %g6
	subi	%g1, %g1, 16
	call	o_param_y.2651
	fsub	%f1, %f1, %f0
	mov	%g3, %g6
	call	o_param_b.2643
	fsqrt	%f0, %f0
	fmul	%f2, %f1, %f0
	fmov	%f1, %f7
	call	fabs.2497
	fmov	%f1, %f0
	fmov	%f0, %f6
	call	fless.2485
	addi	%g1, %g1, 16
	jne	%g3, %g0, jeq_else.7949
	fdiv	%f1, %f2, %f7
	subi	%g1, %g1, 16
	call	fabs.2497
	call	atan.2514
	addi	%g1, %g1, 16
	fmul	%f0, %f0, %f31
	fdiv	%f0, %f0, %f23
	jmp	jeq_cont.7950
jeq_else.7949:
	setL %g3, l.6975
	fldi	%f0, %g3, 0
jeq_cont.7950:
	fsti	%f0, %g1, 12
	subi	%g1, %g1, 20
	call	min_caml_floor
	addi	%g1, %g1, 20
	fmov	%f1, %f0
	fldi	%f0, %g1, 12
	fsub	%f1, %f0, %f1
	setL %g3, l.6986
	fldi	%f2, %g3, 0
	fsub	%f0, %f19, %f8
	subi	%g1, %g1, 20
	call	fsqr.2505
	fsub	%f2, %f2, %f0
	fsub	%f0, %f19, %f1
	call	fsqr.2505
	addi	%g1, %g1, 20
	fsub	%f0, %f2, %f0
	fsti	%f0, %g1, 16
	subi	%g1, %g1, 24
	call	fisneg.2490
	addi	%g1, %g1, 24
	jne	%g3, %g0, jeq_else.7951
	fldi	%f0, %g1, 16
	fmov	%f1, %f0
	jmp	jeq_cont.7952
jeq_else.7951:
	setL %g3, l.6207
	fldi	%f1, %g3, 0
jeq_cont.7952:
	fmul	%f1, %f18, %f1
	setL %g3, l.6991
	fldi	%f0, %g3, 0
	fdiv	%f0, %f1, %f0
	fsti	%f0, %g31, 560
	return
jeq_else.7946:
	return

!==============================
! args = []
! fargs = [%f0, %f4, %f3]
! use_regs = [%g4, %g3, %g27, %f4, %f3, %f2, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
add_light.2903:
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fispos.2488
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7955
	jmp	jeq_cont.7956
jeq_else.7955:
	subi	%g3, %g31, 568
	subi	%g4, %g31, 592
	fldi	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	vecaccum.2614
	addi	%g1, %g1, 8
jeq_cont.7956:
	fmov	%f0, %f4
	subi	%g1, %g1, 8
	call	fispos.2488
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7957
	return
jeq_else.7957:
	fmov	%f0, %f4
	subi	%g1, %g1, 8
	call	fsqr.2505
	call	fsqr.2505
	addi	%g1, %g1, 8
	fmul	%f0, %f0, %f3
	fldi	%f1, %g31, 592
	fadd	%f1, %f1, %f0
	fsti	%f1, %g31, 592
	fldi	%f1, %g31, 588
	fadd	%f1, %f1, %f0
	fsti	%f1, %g31, 588
	fldi	%f1, %g31, 584
	fadd	%f0, %f1, %f0
	fsti	%f0, %g31, 584
	return

!==============================
! args = [%g19, %g21]
! fargs = [%f13, %f12]
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f27, %f25, %f24, %f2, %f17, %f16, %f15, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
trace_reflections.2907:
	jlt	%g19, %g0, jge_else.7960
	slli	%g3, %g19, 2
	add	%g3, %g31, %g3
	ldi	%g20, %g3, 1716
	mov	%g3, %g20
	subi	%g1, %g1, 4
	call	r_dvec.2698
	mov	%g22, %g3
	mov	%g11, %g22
	call	judge_intersection_fast.2889
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7961
	jmp	jeq_cont.7962
jeq_else.7961:
	ldi	%g3, %g31, 544
	slli	%g4, %g3, 2
	ldi	%g3, %g31, 524
	add	%g4, %g4, %g3
	mov	%g3, %g20
	subi	%g1, %g1, 4
	call	r_surface_id.2696
	addi	%g1, %g1, 4
	jne	%g4, %g3, jeq_else.7963
	addi	%g12, %g0, 0
	ldi	%g13, %g31, 516
	subi	%g1, %g1, 4
	call	shadow_check_one_or_matrix.2860
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7965
	mov	%g3, %g22
	subi	%g1, %g1, 4
	call	d_vec.2692
	addi	%g1, %g1, 4
	subi	%g4, %g31, 556
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	veciprod.2606
	addi	%g1, %g1, 8
	fsti	%f0, %g1, 4
	mov	%g3, %g20
	subi	%g1, %g1, 12
	call	r_bright.2700
	addi	%g1, %g1, 12
	fmov	%f3, %f0
	fmul	%f1, %f3, %f13
	fldi	%f0, %g1, 4
	fmul	%f0, %f1, %f0
	ldi	%g3, %g1, 0
	fsti	%f0, %g1, 8
	mov	%g4, %g21
	subi	%g1, %g1, 16
	call	veciprod.2606
	addi	%g1, %g1, 16
	fmov	%f1, %f0
	fmul	%f4, %f3, %f1
	fldi	%f0, %g1, 8
	fmov	%f3, %f12
	subi	%g1, %g1, 16
	call	add_light.2903
	addi	%g1, %g1, 16
	jmp	jeq_cont.7966
jeq_else.7965:
jeq_cont.7966:
	jmp	jeq_cont.7964
jeq_else.7963:
jeq_cont.7964:
jeq_cont.7962:
	subi	%g19, %g19, 1
	jmp	trace_reflections.2907
jge_else.7960:
	return

!==============================
! args = [%g23, %g21, %g24]
! fargs = [%f14, %f11]
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f22, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
trace_ray.2912:
	addi	%g3, %g0, 4
	jlt	%g3, %g23, jle_else.7968
	mov	%g3, %g24
	subi	%g1, %g1, 4
	call	p_surface_ids.2677
	addi	%g1, %g1, 4
	mov	%g25, %g3
	fsti	%f11, %g1, 0
	mov	%g13, %g21
	subi	%g1, %g1, 8
	call	judge_intersection.2875
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7969
	addi	%g4, %g0, -1
	slli	%g3, %g23, 2
	st	%g4, %g25, %g3
	jne	%g23, %g0, jeq_else.7970
	return
jeq_else.7970:
	subi	%g3, %g31, 308
	mov	%g4, %g21
	subi	%g1, %g1, 8
	call	veciprod.2606
	call	fneg.2501
	addi	%g1, %g1, 8
	fsti	%f0, %g1, 4
	subi	%g1, %g1, 12
	call	fispos.2488
	addi	%g1, %g1, 12
	jne	%g3, %g0, jeq_else.7972
	return
jeq_else.7972:
	fldi	%f0, %g1, 4
	subi	%g1, %g1, 12
	call	fsqr.2505
	addi	%g1, %g1, 12
	fmov	%f1, %f0
	fldi	%f0, %g1, 4
	fmul	%f0, %f1, %f0
	fmul	%f1, %f0, %f14
	fldi	%f0, %g31, 312
	fmul	%f0, %f1, %f0
	fldi	%f1, %g31, 592
	fadd	%f1, %f1, %f0
	fsti	%f1, %g31, 592
	fldi	%f1, %g31, 588
	fadd	%f1, %f1, %f0
	fsti	%f1, %g31, 588
	fldi	%f1, %g31, 584
	fadd	%f0, %f1, %f0
	fsti	%f0, %g31, 584
	return
jeq_else.7969:
	ldi	%g8, %g31, 544
	slli	%g3, %g8, 2
	add	%g3, %g31, %g3
	ldi	%g6, %g3, 272
	mov	%g3, %g6
	subi	%g1, %g1, 12
	call	o_reflectiontype.2635
	mov	%g26, %g3
	mov	%g3, %g6
	call	o_diffuse.2655
	fmov	%f10, %f0
	fmul	%f13, %f10, %f14
	mov	%g4, %g21
	mov	%g3, %g6
	call	get_nvector.2897
	subi	%g3, %g31, 540
	subi	%g4, %g31, 624
	call	veccpy.2595
	addi	%g1, %g1, 12
	subi	%g5, %g31, 540
	sti	%g6, %g1, 8
	subi	%g1, %g1, 16
	call	utexture.2900
	slli	%g4, %g8, 2
	ldi	%g3, %g31, 524
	add	%g4, %g4, %g3
	slli	%g3, %g23, 2
	st	%g4, %g25, %g3
	mov	%g3, %g24
	call	p_intersection_points.2675
	slli	%g4, %g23, 2
	ld	%g4, %g3, %g4
	subi	%g3, %g31, 540
	call	veccpy.2595
	mov	%g3, %g24
	call	p_calc_diffuse.2679
	addi	%g1, %g1, 16
	sti	%g3, %g1, 12
	fmov	%f0, %f19
	fmov	%f1, %f10
	subi	%g1, %g1, 20
	call	fless.2485
	addi	%g1, %g1, 20
	mov	%g4, %g3
	jne	%g4, %g0, jeq_else.7975
	addi	%g5, %g0, 1
	slli	%g4, %g23, 2
	ldi	%g3, %g1, 12
	st	%g5, %g3, %g4
	mov	%g3, %g24
	subi	%g1, %g1, 20
	call	p_energy.2681
	mov	%g5, %g3
	slli	%g3, %g23, 2
	ld	%g4, %g5, %g3
	subi	%g3, %g31, 568
	call	veccpy.2595
	slli	%g3, %g23, 2
	ld	%g3, %g5, %g3
	setL %g4, l.7068
	fldi	%f0, %g4, 0
	fmul	%f0, %f0, %f13
	call	vecscale.2624
	mov	%g3, %g24
	call	p_nvectors.2690
	slli	%g4, %g23, 2
	ld	%g4, %g3, %g4
	subi	%g3, %g31, 556
	call	veccpy.2595
	addi	%g1, %g1, 20
	jmp	jeq_cont.7976
jeq_else.7975:
	addi	%g5, %g0, 0
	slli	%g4, %g23, 2
	ldi	%g3, %g1, 12
	st	%g5, %g3, %g4
jeq_cont.7976:
	setL %g3, l.7073
	fldi	%f3, %g3, 0
	subi	%g3, %g31, 556
	mov	%g4, %g21
	subi	%g1, %g1, 20
	call	veciprod.2606
	fmul	%f0, %f3, %f0
	subi	%g3, %g31, 556
	mov	%g4, %g21
	call	vecaccum.2614
	addi	%g1, %g1, 20
	ldi	%g6, %g1, 8
	mov	%g3, %g6
	subi	%g1, %g1, 20
	call	o_hilight.2657
	fmul	%f12, %f14, %f0
	addi	%g12, %g0, 0
	ldi	%g13, %g31, 516
	call	shadow_check_one_or_matrix.2860
	addi	%g1, %g1, 20
	jne	%g3, %g0, jeq_else.7977
	subi	%g3, %g31, 308
	subi	%g4, %g31, 556
	subi	%g1, %g1, 20
	call	veciprod.2606
	call	fneg.2501
	fmul	%f5, %f0, %f13
	subi	%g3, %g31, 308
	mov	%g4, %g21
	call	veciprod.2606
	call	fneg.2501
	fmov	%f4, %f0
	fmov	%f3, %f12
	fmov	%f0, %f5
	call	add_light.2903
	addi	%g1, %g1, 20
	jmp	jeq_cont.7978
jeq_else.7977:
jeq_cont.7978:
	subi	%g6, %g31, 540
	subi	%g1, %g1, 20
	call	setup_startp.2826
	addi	%g1, %g1, 20
	ldi	%g3, %g31, 1720
	subi	%g19, %g3, 1
	sti	%g21, %g1, 16
	fsti	%f10, %g1, 20
	subi	%g1, %g1, 28
	call	trace_reflections.2907
	fmov	%f0, %f14
	fmov	%f1, %f22
	call	fless.2485
	addi	%g1, %g1, 28
	jne	%g3, %g0, jeq_else.7979
	return
jeq_else.7979:
	addi	%g3, %g0, 4
	jlt	%g23, %g3, jle_else.7981
	jmp	jle_cont.7982
jle_else.7981:
	addi	%g3, %g23, 1
	addi	%g4, %g0, -1
	slli	%g3, %g3, 2
	st	%g4, %g25, %g3
jle_cont.7982:
	addi	%g3, %g0, 2
	jne	%g26, %g3, jeq_else.7983
	fldi	%f10, %g1, 20
	fsub	%f0, %f17, %f10
	fmul	%f14, %f14, %f0
	addi	%g23, %g23, 1
	fldi	%f0, %g31, 528
	fldi	%f11, %g1, 0
	fadd	%f11, %f11, %f0
	ldi	%g21, %g1, 16
	jmp	trace_ray.2912
jeq_else.7983:
	return
jle_else.7968:
	return

!==============================
! args = [%g11]
! fargs = [%f12]
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
trace_diffuse_ray.2918:
	sti	%g11, %g1, 0
	subi	%g1, %g1, 8
	call	judge_intersection_fast.2889
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7986
	return
jeq_else.7986:
	ldi	%g3, %g31, 544
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g14, %g3, 272
	ldi	%g11, %g1, 0
	mov	%g3, %g11
	subi	%g1, %g1, 8
	call	d_vec.2692
	mov	%g4, %g3
	mov	%g3, %g14
	call	get_nvector.2897
	subi	%g5, %g31, 540
	mov	%g6, %g14
	call	utexture.2900
	addi	%g12, %g0, 0
	ldi	%g13, %g31, 516
	call	shadow_check_one_or_matrix.2860
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7988
	subi	%g3, %g31, 308
	subi	%g4, %g31, 556
	subi	%g1, %g1, 8
	call	veciprod.2606
	call	fneg.2501
	addi	%g1, %g1, 8
	fsti	%f0, %g1, 4
	subi	%g1, %g1, 12
	call	fispos.2488
	addi	%g1, %g1, 12
	jne	%g3, %g0, jeq_else.7989
	setL %g3, l.6207
	fldi	%f1, %g3, 0
	jmp	jeq_cont.7990
jeq_else.7989:
	fldi	%f0, %g1, 4
	fmov	%f1, %f0
jeq_cont.7990:
	fmul	%f1, %f12, %f1
	mov	%g3, %g14
	subi	%g1, %g1, 12
	call	o_diffuse.2655
	addi	%g1, %g1, 12
	fmul	%f0, %f1, %f0
	subi	%g3, %g31, 568
	subi	%g4, %g31, 580
	jmp	vecaccum.2614
jeq_else.7988:
	return

!==============================
! args = [%g22, %g21, %g20, %g19]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
iter_trace_diffuse_rays.2921:
	jlt	%g19, %g0, jge_else.7992
	slli	%g3, %g19, 2
	ld	%g3, %g22, %g3
	subi	%g1, %g1, 4
	call	d_vec.2692
	mov	%g4, %g3
	mov	%g3, %g21
	call	veciprod.2606
	addi	%g1, %g1, 4
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fisneg.2490
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7993
	slli	%g3, %g19, 2
	ld	%g11, %g22, %g3
	setL %g3, l.7124
	fldi	%f1, %g3, 0
	fldi	%f0, %g1, 0
	fdiv	%f12, %f0, %f1
	subi	%g1, %g1, 8
	call	trace_diffuse_ray.2918
	addi	%g1, %g1, 8
	jmp	jeq_cont.7994
jeq_else.7993:
	addi	%g3, %g19, 1
	slli	%g3, %g3, 2
	ld	%g11, %g22, %g3
	setL %g3, l.7120
	fldi	%f1, %g3, 0
	fldi	%f0, %g1, 0
	fdiv	%f12, %f0, %f1
	subi	%g1, %g1, 8
	call	trace_diffuse_ray.2918
	addi	%g1, %g1, 8
jeq_cont.7994:
	subi	%g19, %g19, 2
	jmp	iter_trace_diffuse_rays.2921
jge_else.7992:
	return

!==============================
! args = [%g22, %g21, %g20]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
trace_diffuse_rays.2926:
	mov	%g6, %g20
	subi	%g1, %g1, 4
	call	setup_startp.2826
	addi	%g1, %g1, 4
	addi	%g19, %g0, 118
	jmp	iter_trace_diffuse_rays.2921

!==============================
! args = [%g23, %g21, %g20]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
trace_diffuse_ray_80percent.2930:
	sti	%g20, %g1, 0
	sti	%g21, %g1, 4
	jne	%g23, %g0, jeq_else.7996
	jmp	jeq_cont.7997
jeq_else.7996:
	ldi	%g22, %g31, 716
	subi	%g1, %g1, 12
	call	trace_diffuse_rays.2926
	addi	%g1, %g1, 12
jeq_cont.7997:
	jne	%g23, %g28, jeq_else.7998
	jmp	jeq_cont.7999
jeq_else.7998:
	ldi	%g22, %g31, 712
	ldi	%g21, %g1, 4
	ldi	%g20, %g1, 0
	subi	%g1, %g1, 12
	call	trace_diffuse_rays.2926
	addi	%g1, %g1, 12
jeq_cont.7999:
	addi	%g3, %g0, 2
	jne	%g23, %g3, jeq_else.8000
	jmp	jeq_cont.8001
jeq_else.8000:
	ldi	%g22, %g31, 708
	ldi	%g21, %g1, 4
	ldi	%g20, %g1, 0
	subi	%g1, %g1, 12
	call	trace_diffuse_rays.2926
	addi	%g1, %g1, 12
jeq_cont.8001:
	addi	%g3, %g0, 3
	jne	%g23, %g3, jeq_else.8002
	jmp	jeq_cont.8003
jeq_else.8002:
	ldi	%g22, %g31, 704
	ldi	%g21, %g1, 4
	ldi	%g20, %g1, 0
	subi	%g1, %g1, 12
	call	trace_diffuse_rays.2926
	addi	%g1, %g1, 12
jeq_cont.8003:
	addi	%g3, %g0, 4
	jne	%g23, %g3, jeq_else.8004
	return
jeq_else.8004:
	ldi	%g22, %g31, 700
	ldi	%g21, %g1, 4
	ldi	%g20, %g1, 0
	jmp	trace_diffuse_rays.2926

!==============================
! args = [%g3, %g24]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
calc_diffuse_using_1point.2934:
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	p_received_ray_20percent.2683
	addi	%g1, %g1, 8
	mov	%g4, %g3
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	p_nvectors.2690
	addi	%g1, %g1, 8
	mov	%g6, %g3
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	p_intersection_points.2675
	addi	%g1, %g1, 8
	mov	%g7, %g3
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	p_energy.2681
	mov	%g25, %g3
	slli	%g5, %g24, 2
	ld	%g5, %g4, %g5
	subi	%g4, %g31, 580
	mov	%g3, %g5
	call	veccpy.2595
	addi	%g1, %g1, 8
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	p_group_id.2685
	mov	%g23, %g3
	slli	%g3, %g24, 2
	ld	%g21, %g6, %g3
	slli	%g3, %g24, 2
	ld	%g20, %g7, %g3
	call	trace_diffuse_ray_80percent.2930
	addi	%g1, %g1, 8
	slli	%g3, %g24, 2
	ld	%g4, %g25, %g3
	subi	%g3, %g31, 580
	subi	%g5, %g31, 592
	jmp	vecaccumv.2627

!==============================
! args = [%g5, %g3, %g7, %g4, %g6]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g12, %g11, %g10, %f2, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
calc_diffuse_using_5points.2937:
	slli	%g8, %g5, 2
	ld	%g3, %g3, %g8
	subi	%g1, %g1, 4
	call	p_received_ray_20percent.2683
	mov	%g8, %g3
	subi	%g3, %g5, 1
	slli	%g3, %g3, 2
	ld	%g3, %g7, %g3
	call	p_received_ray_20percent.2683
	mov	%g10, %g3
	slli	%g3, %g5, 2
	ld	%g3, %g7, %g3
	call	p_received_ray_20percent.2683
	mov	%g12, %g3
	addi	%g3, %g5, 1
	slli	%g3, %g3, 2
	ld	%g3, %g7, %g3
	call	p_received_ray_20percent.2683
	mov	%g9, %g3
	slli	%g3, %g5, 2
	ld	%g3, %g4, %g3
	call	p_received_ray_20percent.2683
	mov	%g11, %g3
	slli	%g3, %g6, 2
	ld	%g3, %g8, %g3
	subi	%g4, %g31, 580
	call	veccpy.2595
	slli	%g3, %g6, 2
	ld	%g3, %g10, %g3
	subi	%g4, %g31, 580
	call	vecadd.2618
	slli	%g3, %g6, 2
	ld	%g3, %g12, %g3
	subi	%g4, %g31, 580
	call	vecadd.2618
	slli	%g3, %g6, 2
	ld	%g3, %g9, %g3
	subi	%g4, %g31, 580
	call	vecadd.2618
	slli	%g3, %g6, 2
	ld	%g3, %g11, %g3
	subi	%g4, %g31, 580
	call	vecadd.2618
	slli	%g3, %g5, 2
	ld	%g3, %g7, %g3
	call	p_energy.2681
	addi	%g1, %g1, 4
	slli	%g4, %g6, 2
	ld	%g4, %g3, %g4
	subi	%g3, %g31, 580
	subi	%g5, %g31, 592
	jmp	vecaccumv.2627

!==============================
! args = [%g3, %g24]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
do_without_neighbors.2943:
	addi	%g4, %g0, 4
	jlt	%g4, %g24, jle_else.8006
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	p_surface_ids.2677
	addi	%g1, %g1, 8
	mov	%g4, %g3
	slli	%g5, %g24, 2
	ld	%g4, %g4, %g5
	jlt	%g4, %g0, jge_else.8007
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	p_calc_diffuse.2679
	addi	%g1, %g1, 8
	mov	%g4, %g3
	slli	%g5, %g24, 2
	ld	%g4, %g4, %g5
	sti	%g24, %g1, 4
	jne	%g4, %g0, jeq_else.8008
	jmp	jeq_cont.8009
jeq_else.8008:
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 12
	call	calc_diffuse_using_1point.2934
	addi	%g1, %g1, 12
jeq_cont.8009:
	ldi	%g24, %g1, 4
	addi	%g24, %g24, 1
	ldi	%g3, %g1, 0
	jmp	do_without_neighbors.2943
jge_else.8007:
	return
jle_else.8006:
	return

!==============================
! args = [%g5, %g4, %g3]
! fargs = []
! use_regs = [%g6, %g5, %g4, %g3, %g27, %f15]
! ret type = Bool
!================================
neighbors_exist.2946:
	ldi	%g6, %g31, 596
	addi	%g3, %g4, 1
	jlt	%g3, %g6, jle_else.8012
	addi	%g3, %g0, 0
	return
jle_else.8012:
	jlt	%g0, %g4, jle_else.8013
	addi	%g3, %g0, 0
	return
jle_else.8013:
	ldi	%g4, %g31, 600
	addi	%g3, %g5, 1
	jlt	%g3, %g4, jle_else.8014
	addi	%g3, %g0, 0
	return
jle_else.8014:
	jlt	%g0, %g5, jle_else.8015
	addi	%g3, %g0, 0
	return
jle_else.8015:
	addi	%g3, %g0, 1
	return

!==============================
! args = [%g3, %g4]
! fargs = []
! use_regs = [%g4, %g3, %g27, %f15]
! ret type = Int
!================================
get_surface_id.2950:
	subi	%g1, %g1, 4
	call	p_surface_ids.2677
	addi	%g1, %g1, 4
	slli	%g4, %g4, 2
	ld	%g3, %g3, %g4
	return

!==============================
! args = [%g5, %g6, %g8, %g7, %g4]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %f15]
! ret type = Bool
!================================
neighbors_are_available.2953:
	slli	%g3, %g5, 2
	ld	%g3, %g8, %g3
	sti	%g4, %g1, 0
	subi	%g1, %g1, 8
	call	get_surface_id.2950
	addi	%g1, %g1, 8
	mov	%g9, %g3
	slli	%g3, %g5, 2
	ld	%g3, %g6, %g3
	ldi	%g4, %g1, 0
	subi	%g1, %g1, 8
	call	get_surface_id.2950
	addi	%g1, %g1, 8
	jne	%g3, %g9, jeq_else.8016
	slli	%g3, %g5, 2
	ld	%g3, %g7, %g3
	ldi	%g4, %g1, 0
	subi	%g1, %g1, 8
	call	get_surface_id.2950
	addi	%g1, %g1, 8
	jne	%g3, %g9, jeq_else.8017
	subi	%g3, %g5, 1
	slli	%g3, %g3, 2
	ld	%g3, %g8, %g3
	ldi	%g4, %g1, 0
	subi	%g1, %g1, 8
	call	get_surface_id.2950
	addi	%g1, %g1, 8
	jne	%g3, %g9, jeq_else.8018
	addi	%g3, %g5, 1
	slli	%g3, %g3, 2
	ld	%g3, %g8, %g3
	ldi	%g4, %g1, 0
	subi	%g1, %g1, 8
	call	get_surface_id.2950
	addi	%g1, %g1, 8
	jne	%g3, %g9, jeq_else.8019
	addi	%g3, %g0, 1
	return
jeq_else.8019:
	addi	%g3, %g0, 0
	return
jeq_else.8018:
	addi	%g3, %g0, 0
	return
jeq_else.8017:
	addi	%g3, %g0, 0
	return
jeq_else.8016:
	addi	%g3, %g0, 0
	return

!==============================
! args = [%g5, %g13, %g14, %g16, %g15, %g24]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
try_exploit_neighbors.2959:
	slli	%g3, %g5, 2
	ld	%g3, %g16, %g3
	addi	%g4, %g0, 4
	jlt	%g4, %g24, jle_else.8020
	sti	%g3, %g1, 0
	mov	%g4, %g24
	subi	%g1, %g1, 8
	call	get_surface_id.2950
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jlt	%g4, %g0, jge_else.8021
	sti	%g5, %g1, 4
	mov	%g4, %g24
	mov	%g7, %g15
	mov	%g8, %g16
	mov	%g6, %g14
	subi	%g1, %g1, 12
	call	neighbors_are_available.2953
	addi	%g1, %g1, 12
	mov	%g4, %g3
	jne	%g4, %g0, jeq_else.8022
	ldi	%g5, %g1, 4
	slli	%g3, %g5, 2
	ld	%g3, %g16, %g3
	jmp	do_without_neighbors.2943
jeq_else.8022:
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 12
	call	p_calc_diffuse.2679
	addi	%g1, %g1, 12
	slli	%g4, %g24, 2
	ld	%g3, %g3, %g4
	jne	%g3, %g0, jeq_else.8023
	jmp	jeq_cont.8024
jeq_else.8023:
	ldi	%g5, %g1, 4
	mov	%g6, %g24
	mov	%g4, %g15
	mov	%g7, %g16
	mov	%g3, %g14
	subi	%g1, %g1, 12
	call	calc_diffuse_using_5points.2937
	addi	%g1, %g1, 12
jeq_cont.8024:
	addi	%g24, %g24, 1
	ldi	%g5, %g1, 4
	jmp	try_exploit_neighbors.2959
jge_else.8021:
	return
jle_else.8020:
	return

!==============================
! args = []
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g11, %g10, %f15, %dummy]
! ret type = Unit
!================================
write_ppm_header.2966:
	addi	%g3, %g0, 80
	output	%g3
	addi	%g3, %g0, 54
	output	%g3
	addi	%g3, %g0, 10
	output	%g3
	ldi	%g8, %g31, 600
	subi	%g1, %g1, 4
	call	print_int.2545
	addi	%g3, %g0, 32
	output	%g3
	ldi	%g8, %g31, 596
	call	print_int.2545
	addi	%g3, %g0, 32
	output	%g3
	addi	%g8, %g0, 255
	call	print_int.2545
	addi	%g1, %g1, 4
	addi	%g3, %g0, 10
	output	%g3
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g5, %g4, %g3, %g27, %f4, %f3, %f2, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
write_rgb_element.2968:
	subi	%g1, %g1, 4
	call	min_caml_int_of_float
	addi	%g1, %g1, 4
	mov	%g4, %g3
	addi	%g3, %g0, 255
	jlt	%g3, %g4, jle_else.8027
	jlt	%g4, %g0, jge_else.8029
	mov	%g3, %g4
	jmp	jge_cont.8030
jge_else.8029:
	addi	%g3, %g0, 0
jge_cont.8030:
	jmp	jle_cont.8028
jle_else.8027:
	addi	%g3, %g0, 255
jle_cont.8028:
	output	%g3
	return

!==============================
! args = []
! fargs = []
! use_regs = [%g5, %g4, %g3, %g27, %f4, %f3, %f2, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
write_rgb.2970:
	fldi	%f0, %g31, 592
	subi	%g1, %g1, 4
	call	write_rgb_element.2968
	fldi	%f0, %g31, 588
	call	write_rgb_element.2968
	addi	%g1, %g1, 4
	fldi	%f0, %g31, 584
	jmp	write_rgb_element.2968

!==============================
! args = [%g23, %g24]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
pretrace_diffuse_rays.2972:
	addi	%g3, %g0, 4
	jlt	%g3, %g24, jle_else.8031
	mov	%g4, %g24
	mov	%g3, %g23
	subi	%g1, %g1, 4
	call	get_surface_id.2950
	addi	%g1, %g1, 4
	jlt	%g3, %g0, jge_else.8032
	mov	%g3, %g23
	subi	%g1, %g1, 4
	call	p_calc_diffuse.2679
	addi	%g1, %g1, 4
	slli	%g4, %g24, 2
	ld	%g3, %g3, %g4
	jne	%g3, %g0, jeq_else.8033
	jmp	jeq_cont.8034
jeq_else.8033:
	mov	%g3, %g23
	subi	%g1, %g1, 4
	call	p_group_id.2685
	mov	%g5, %g3
	subi	%g3, %g31, 580
	call	vecbzero.2593
	mov	%g3, %g23
	call	p_nvectors.2690
	addi	%g1, %g1, 4
	sti	%g3, %g1, 0
	mov	%g3, %g23
	subi	%g1, %g1, 8
	call	p_intersection_points.2675
	addi	%g1, %g1, 8
	mov	%g4, %g3
	slli	%g5, %g5, 2
	add	%g5, %g31, %g5
	ldi	%g22, %g5, 716
	slli	%g5, %g24, 2
	ldi	%g3, %g1, 0
	ld	%g21, %g3, %g5
	slli	%g3, %g24, 2
	ld	%g20, %g4, %g3
	subi	%g1, %g1, 8
	call	trace_diffuse_rays.2926
	mov	%g3, %g23
	call	p_received_ray_20percent.2683
	slli	%g4, %g24, 2
	ld	%g4, %g3, %g4
	subi	%g3, %g31, 580
	call	veccpy.2595
	addi	%g1, %g1, 8
jeq_cont.8034:
	addi	%g24, %g24, 1
	jmp	pretrace_diffuse_rays.2972
jge_else.8032:
	return
jle_else.8031:
	return

!==============================
! args = [%g25, %g30, %g26]
! fargs = [%f3, %f14, %f13]
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f22, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
pretrace_pixels.2975:
	jlt	%g30, %g0, jge_else.8037
	fldi	%f4, %g31, 612
	ldi	%g3, %g31, 608
	sub	%g3, %g30, %g3
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmul	%f0, %f4, %f0
	fldi	%f1, %g31, 648
	fmul	%f1, %f0, %f1
	fadd	%f1, %f1, %f3
	fsti	%f1, %g31, 684
	fldi	%f1, %g31, 644
	fmul	%f1, %f0, %f1
	fadd	%f1, %f1, %f14
	fsti	%f1, %g31, 680
	fldi	%f1, %g31, 640
	fmul	%f0, %f0, %f1
	fadd	%f0, %f0, %f13
	fsti	%f0, %g31, 676
	addi	%g5, %g0, 0
	subi	%g4, %g31, 684
	call	vecunit_sgn.2603
	subi	%g3, %g31, 592
	call	vecbzero.2593
	subi	%g3, %g31, 296
	subi	%g4, %g31, 624
	call	veccpy.2595
	addi	%g1, %g1, 4
	addi	%g23, %g0, 0
	slli	%g3, %g30, 2
	ld	%g24, %g25, %g3
	subi	%g21, %g31, 684
	fsti	%f13, %g1, 0
	fsti	%f14, %g1, 4
	fsti	%f3, %g1, 8
	sti	%g26, %g1, 12
	sti	%g25, %g1, 16
	fmov	%f11, %f16
	fmov	%f14, %f17
	subi	%g1, %g1, 24
	call	trace_ray.2912
	addi	%g1, %g1, 24
	slli	%g3, %g30, 2
	ldi	%g25, %g1, 16
	ld	%g3, %g25, %g3
	subi	%g1, %g1, 24
	call	p_rgb.2673
	mov	%g4, %g3
	subi	%g3, %g31, 592
	call	veccpy.2595
	addi	%g1, %g1, 24
	slli	%g3, %g30, 2
	ld	%g3, %g25, %g3
	ldi	%g26, %g1, 12
	mov	%g4, %g26
	subi	%g1, %g1, 24
	call	p_set_group_id.2687
	slli	%g3, %g30, 2
	ld	%g23, %g25, %g3
	addi	%g24, %g0, 0
	call	pretrace_diffuse_rays.2972
	subi	%g30, %g30, 1
	addi	%g3, %g0, 1
	mov	%g4, %g26
	call	add_mod5.2582
	addi	%g1, %g1, 24
	fldi	%f3, %g1, 8
	fldi	%f14, %g1, 4
	fldi	%f13, %g1, 0
	mov	%g26, %g3
	jmp	pretrace_pixels.2975
jge_else.8037:
	return

!==============================
! args = [%g25, %g3, %g26]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f22, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
pretrace_line.2982:
	fldi	%f3, %g31, 612
	ldi	%g4, %g31, 604
	sub	%g3, %g3, %g4
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fmul	%f0, %f3, %f0
	fldi	%f1, %g31, 660
	fmul	%f2, %f0, %f1
	fldi	%f1, %g31, 672
	fadd	%f3, %f2, %f1
	fldi	%f1, %g31, 656
	fmul	%f2, %f0, %f1
	fldi	%f1, %g31, 668
	fadd	%f14, %f2, %f1
	fldi	%f1, %g31, 652
	fmul	%f1, %f0, %f1
	fldi	%f0, %g31, 664
	fadd	%f13, %f1, %f0
	ldi	%g3, %g31, 600
	subi	%g30, %g3, 1
	jmp	pretrace_pixels.2975

!==============================
! args = [%g30, %g26, %g14, %g16, %g15]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
scan_pixel.2986:
	ldi	%g3, %g31, 600
	jlt	%g30, %g3, jle_else.8039
	return
jle_else.8039:
	slli	%g3, %g30, 2
	ld	%g3, %g16, %g3
	subi	%g1, %g1, 4
	call	p_rgb.2673
	subi	%g4, %g31, 592
	call	veccpy.2595
	mov	%g3, %g15
	mov	%g4, %g26
	mov	%g5, %g30
	call	neighbors_exist.2946
	addi	%g1, %g1, 4
	sti	%g15, %g1, 0
	sti	%g16, %g1, 4
	sti	%g14, %g1, 8
	jne	%g3, %g0, jeq_else.8041
	slli	%g3, %g30, 2
	ld	%g3, %g16, %g3
	addi	%g24, %g0, 0
	subi	%g1, %g1, 16
	call	do_without_neighbors.2943
	addi	%g1, %g1, 16
	jmp	jeq_cont.8042
jeq_else.8041:
	addi	%g24, %g0, 0
	mov	%g13, %g26
	mov	%g5, %g30
	subi	%g1, %g1, 16
	call	try_exploit_neighbors.2959
	addi	%g1, %g1, 16
jeq_cont.8042:
	subi	%g1, %g1, 16
	call	write_rgb.2970
	addi	%g1, %g1, 16
	addi	%g30, %g30, 1
	ldi	%g14, %g1, 8
	ldi	%g16, %g1, 4
	ldi	%g15, %g1, 0
	jmp	scan_pixel.2986

!==============================
! args = [%g26, %g14, %g16, %g15, %g4]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f22, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
scan_line.2992:
	ldi	%g3, %g31, 596
	jlt	%g26, %g3, jle_else.8043
	return
jle_else.8043:
	subi	%g3, %g3, 1
	sti	%g4, %g1, 0
	sti	%g15, %g1, 4
	sti	%g16, %g1, 8
	sti	%g14, %g1, 12
	sti	%g26, %g1, 16
	jlt	%g26, %g3, jle_else.8045
	jmp	jle_cont.8046
jle_else.8045:
	addi	%g3, %g26, 1
	mov	%g26, %g4
	mov	%g25, %g15
	subi	%g1, %g1, 24
	call	pretrace_line.2982
	addi	%g1, %g1, 24
jle_cont.8046:
	addi	%g30, %g0, 0
	ldi	%g26, %g1, 16
	ldi	%g14, %g1, 12
	ldi	%g16, %g1, 8
	ldi	%g15, %g1, 4
	subi	%g1, %g1, 24
	call	scan_pixel.2986
	addi	%g1, %g1, 24
	ldi	%g26, %g1, 16
	addi	%g26, %g26, 1
	addi	%g3, %g0, 2
	ldi	%g4, %g1, 0
	subi	%g1, %g1, 24
	call	add_mod5.2582
	addi	%g1, %g1, 24
	ldi	%g16, %g1, 8
	ldi	%g15, %g1, 4
	ldi	%g14, %g1, 12
	mov	%g4, %g3
	mov	%g27, %g15
	mov	%g15, %g14
	mov	%g14, %g16
	mov	%g16, %g27
	jmp	scan_line.2992

!==============================
! args = []
! fargs = []
! use_regs = [%g5, %g4, %g3, %g27, %f16, %f15, %f0, %dummy]
! ret type = Array(Array(Float))
!================================
create_float5x3array.2998:
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

!==============================
! args = []
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g2, %g12, %g11, %g10, %f16, %f15, %f0, %dummy]
! ret type = (Array(Float) * Array(Array(Float)) * Array(Int) * Array(Bool) * Array(Array(Float)) * Array(Array(Float)) * Array(Int) * Array(Array(Float)))
!================================
create_pixel.3000:
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	mov	%g7, %g3
	call	create_float5x3array.2998
	mov	%g9, %g3
	addi	%g3, %g0, 5
	addi	%g4, %g0, 0
	call	min_caml_create_array
	mov	%g6, %g3
	addi	%g3, %g0, 5
	addi	%g4, %g0, 0
	call	min_caml_create_array
	mov	%g12, %g3
	call	create_float5x3array.2998
	mov	%g11, %g3
	call	create_float5x3array.2998
	mov	%g8, %g3
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	call	min_caml_create_array
	mov	%g10, %g3
	call	create_float5x3array.2998
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

!==============================
! args = [%g13, %g14]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g2, %g14, %g13, %g12, %g11, %g10, %f16, %f15, %f0, %dummy]
! ret type = Array((Array(Float) * Array(Array(Float)) * Array(Int) * Array(Bool) * Array(Array(Float)) * Array(Array(Float)) * Array(Int) * Array(Array(Float))))
!================================
init_line_elements.3002:
	jlt	%g14, %g0, jge_else.8047
	subi	%g1, %g1, 4
	call	create_pixel.3000
	addi	%g1, %g1, 4
	slli	%g4, %g14, 2
	st	%g3, %g13, %g4
	subi	%g14, %g14, 1
	jmp	init_line_elements.3002
jge_else.8047:
	mov	%g3, %g13
	return

!==============================
! args = []
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g2, %g14, %g13, %g12, %g11, %g10, %f16, %f15, %f0, %dummy]
! ret type = Array((Array(Float) * Array(Array(Float)) * Array(Int) * Array(Bool) * Array(Array(Float)) * Array(Array(Float)) * Array(Int) * Array(Array(Float))))
!================================
create_pixelline.3005:
	ldi	%g3, %g31, 600
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	create_pixel.3000
	addi	%g1, %g1, 8
	mov	%g4, %g3
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	min_caml_create_array
	addi	%g1, %g1, 8
	mov	%g13, %g3
	ldi	%g3, %g31, 600
	subi	%g14, %g3, 2
	jmp	init_line_elements.3002

!==============================
! args = []
! fargs = [%f0, %f6]
! use_regs = [%g4, %g3, %g27, %f7, %f6, %f5, %f4, %f3, %f26, %f22, %f21, %f20, %f2, %f19, %f17, %f16, %f15, %f1, %f0]
! ret type = Float
!================================
adjust_position.3007:
	fmul	%f0, %f0, %f0
	fadd	%f0, %f0, %f22
	fsqrt	%f7, %f0
	fdiv	%f0, %f17, %f7
	subi	%g1, %g1, 4
	call	atan.2514
	fmul	%f0, %f0, %f6
	call	tan.2516
	addi	%g1, %g1, 4
	fmul	%f0, %f0, %f7
	return

!==============================
! args = [%g5, %g7, %g6]
! fargs = [%f1, %f8, %f10, %f9]
! use_regs = [%g7, %g6, %g5, %g4, %g3, %g27, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f26, %f22, %f21, %f20, %f2, %f19, %f17, %f16, %f15, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
calc_dirvec.3010:
	addi	%g3, %g0, 5
	jlt	%g5, %g3, jle_else.8048
	fmov	%f0, %f1
	subi	%g1, %g1, 4
	call	fsqr.2505
	fmov	%f2, %f0
	fmov	%f0, %f8
	call	fsqr.2505
	fadd	%f0, %f2, %f0
	fadd	%f0, %f0, %f17
	fsqrt	%f0, %f0
	fdiv	%f5, %f1, %f0
	fdiv	%f4, %f8, %f0
	fdiv	%f3, %f17, %f0
	slli	%g3, %g7, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 716
	slli	%g3, %g6, 2
	ld	%g3, %g4, %g3
	call	d_vec.2692
	fmov	%f0, %f3
	fmov	%f1, %f4
	fmov	%f2, %f5
	call	vecset.2585
	addi	%g3, %g6, 40
	slli	%g3, %g3, 2
	ld	%g3, %g4, %g3
	call	d_vec.2692
	fmov	%f0, %f4
	call	fneg.2501
	fmov	%f7, %f0
	fmov	%f0, %f7
	fmov	%f1, %f3
	fmov	%f2, %f5
	call	vecset.2585
	addi	%g3, %g6, 80
	slli	%g3, %g3, 2
	ld	%g3, %g4, %g3
	call	d_vec.2692
	fmov	%f0, %f5
	call	fneg.2501
	fmov	%f6, %f0
	fmov	%f0, %f7
	fmov	%f1, %f6
	fmov	%f2, %f3
	call	vecset.2585
	addi	%g3, %g6, 1
	slli	%g3, %g3, 2
	ld	%g3, %g4, %g3
	call	d_vec.2692
	fmov	%f0, %f3
	call	fneg.2501
	fmov	%f3, %f0
	fmov	%f0, %f3
	fmov	%f1, %f7
	fmov	%f2, %f6
	call	vecset.2585
	addi	%g3, %g6, 41
	slli	%g3, %g3, 2
	ld	%g3, %g4, %g3
	call	d_vec.2692
	fmov	%f0, %f4
	fmov	%f1, %f3
	fmov	%f2, %f6
	call	vecset.2585
	addi	%g3, %g6, 81
	slli	%g3, %g3, 2
	ld	%g3, %g4, %g3
	call	d_vec.2692
	addi	%g1, %g1, 4
	fmov	%f0, %f4
	fmov	%f1, %f5
	fmov	%f2, %f3
	jmp	vecset.2585
jle_else.8048:
	fmov	%f6, %f10
	fmov	%f0, %f8
	subi	%g1, %g1, 4
	call	adjust_position.3007
	addi	%g1, %g1, 4
	addi	%g5, %g5, 1
	fsti	%f0, %g1, 0
	fmov	%f6, %f9
	subi	%g1, %g1, 8
	call	adjust_position.3007
	addi	%g1, %g1, 8
	fmov	%f8, %f0
	fldi	%f0, %g1, 0
	fmov	%f1, %f0
	jmp	calc_dirvec.3010

!==============================
! args = [%g9, %g7, %g8]
! fargs = [%f9]
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f29, %f28, %f26, %f22, %f21, %f20, %f2, %f19, %f17, %f16, %f15, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
calc_dirvecs.3018:
	jlt	%g9, %g0, jge_else.8049
	mov	%g3, %g9
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fmul	%f11, %f0, %f29
	fsub	%f10, %f11, %f28
	addi	%g5, %g0, 0
	fsti	%f9, %g1, 0
	sti	%g7, %g1, 4
	mov	%g6, %g8
	fmov	%f8, %f16
	fmov	%f1, %f16
	subi	%g1, %g1, 12
	call	calc_dirvec.3010
	addi	%g1, %g1, 12
	fadd	%f10, %f11, %f22
	addi	%g5, %g0, 0
	addi	%g6, %g8, 2
	fldi	%f9, %g1, 0
	ldi	%g7, %g1, 4
	fmov	%f8, %f16
	fmov	%f1, %f16
	subi	%g1, %g1, 12
	call	calc_dirvec.3010
	addi	%g1, %g1, 12
	subi	%g9, %g9, 1
	addi	%g3, %g0, 1
	ldi	%g7, %g1, 4
	mov	%g4, %g7
	subi	%g1, %g1, 12
	call	add_mod5.2582
	addi	%g1, %g1, 12
	fldi	%f9, %g1, 0
	mov	%g7, %g3
	jmp	calc_dirvecs.3018
jge_else.8049:
	return

!==============================
! args = [%g10, %g7, %g8]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f29, %f28, %f26, %f22, %f21, %f20, %f2, %f19, %f17, %f16, %f15, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
calc_dirvec_rows.3023:
	jlt	%g10, %g0, jge_else.8051
	mov	%g3, %g10
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fmul	%f0, %f0, %f29
	fsub	%f9, %f0, %f28
	addi	%g9, %g0, 4
	sti	%g8, %g1, 0
	sti	%g7, %g1, 4
	subi	%g1, %g1, 12
	call	calc_dirvecs.3018
	addi	%g1, %g1, 12
	subi	%g10, %g10, 1
	addi	%g3, %g0, 2
	ldi	%g7, %g1, 4
	mov	%g4, %g7
	subi	%g1, %g1, 12
	call	add_mod5.2582
	addi	%g1, %g1, 12
	ldi	%g8, %g1, 0
	addi	%g8, %g8, 4
	mov	%g7, %g3
	jmp	calc_dirvec_rows.3023
jge_else.8051:
	return

!==============================
! args = []
! fargs = []
! use_regs = [%g5, %g4, %g3, %g27, %g2, %f16, %f15, %f0, %dummy]
! ret type = (Array(Float) * Array(Array(Float)))
!================================
create_dirvec.3027:
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	mov	%g4, %g3
	ldi	%g3, %g31, 28
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

!==============================
! args = [%g7, %g6]
! fargs = []
! use_regs = [%g7, %g6, %g5, %g4, %g3, %g27, %g2, %f16, %f15, %f0, %dummy]
! ret type = Unit
!================================
create_dirvec_elements.3029:
	jlt	%g6, %g0, jge_else.8053
	subi	%g1, %g1, 4
	call	create_dirvec.3027
	addi	%g1, %g1, 4
	slli	%g4, %g6, 2
	st	%g3, %g7, %g4
	subi	%g6, %g6, 1
	jmp	create_dirvec_elements.3029
jge_else.8053:
	return

!==============================
! args = [%g8]
! fargs = []
! use_regs = [%g8, %g7, %g6, %g5, %g4, %g3, %g27, %g2, %f16, %f15, %f0, %dummy]
! ret type = Unit
!================================
create_dirvecs.3032:
	jlt	%g8, %g0, jge_else.8055
	addi	%g3, %g0, 120
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	create_dirvec.3027
	addi	%g1, %g1, 8
	mov	%g4, %g3
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	min_caml_create_array
	slli	%g4, %g8, 2
	add	%g4, %g31, %g4
	sti	%g3, %g4, 716
	slli	%g3, %g8, 2
	add	%g3, %g31, %g3
	ldi	%g7, %g3, 716
	addi	%g6, %g0, 118
	call	create_dirvec_elements.3029
	addi	%g1, %g1, 8
	subi	%g8, %g8, 1
	jmp	create_dirvecs.3032
jge_else.8055:
	return

!==============================
! args = [%g12, %g11]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g12, %g11, %g10, %f8, %f7, %f6, %f5, %f4, %f3, %f21, %f2, %f19, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
init_dirvec_constants.3034:
	jlt	%g11, %g0, jge_else.8057
	slli	%g3, %g11, 2
	ld	%g9, %g12, %g3
	subi	%g1, %g1, 4
	call	setup_dirvec_constants.2821
	addi	%g1, %g1, 4
	subi	%g11, %g11, 1
	jmp	init_dirvec_constants.3034
jge_else.8057:
	return

!==============================
! args = [%g13]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g13, %g12, %g11, %g10, %f8, %f7, %f6, %f5, %f4, %f3, %f21, %f2, %f19, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
init_vecset_constants.3037:
	jlt	%g13, %g0, jge_else.8059
	slli	%g3, %g13, 2
	add	%g3, %g31, %g3
	ldi	%g12, %g3, 716
	addi	%g11, %g0, 119
	subi	%g1, %g1, 4
	call	init_dirvec_constants.3034
	addi	%g1, %g1, 4
	subi	%g13, %g13, 1
	jmp	init_vecset_constants.3037
jge_else.8059:
	return

!==============================
! args = []
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g2, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f29, %f28, %f26, %f22, %f21, %f20, %f2, %f19, %f17, %f16, %f15, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
init_dirvecs.3039:
	addi	%g8, %g0, 4
	subi	%g1, %g1, 4
	call	create_dirvecs.3032
	addi	%g10, %g0, 9
	addi	%g7, %g0, 0
	addi	%g8, %g0, 0
	call	calc_dirvec_rows.3023
	addi	%g1, %g1, 4
	addi	%g13, %g0, 4
	jmp	init_vecset_constants.3037

!==============================
! args = [%g12, %g11]
! fargs = [%f9, %f2, %f1, %f0]
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g2, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f21, %f2, %f19, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
add_reflection.3041:
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	create_dirvec.3027
	mov	%g9, %g3
	mov	%g3, %g9
	call	d_vec.2692
	addi	%g1, %g1, 8
	fldi	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	vecset.2585
	addi	%g1, %g1, 8
	sti	%g9, %g1, 4
	subi	%g1, %g1, 12
	call	setup_dirvec_constants.2821
	addi	%g1, %g1, 12
	mov	%g3, %g2
	addi	%g2, %g2, 12
	fsti	%f9, %g3, -8
	ldi	%g9, %g1, 4
	sti	%g9, %g3, -4
	sti	%g11, %g3, 0
	slli	%g4, %g12, 2
	add	%g4, %g31, %g4
	sti	%g3, %g4, 1716
	return

!==============================
! args = [%g3, %g4]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g2, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f21, %f2, %f19, %f17, %f16, %f15, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
setup_rect_reflection.3048:
	slli	%g14, %g3, 2
	ldi	%g13, %g31, 1720
	mov	%g3, %g4
	subi	%g1, %g1, 4
	call	o_diffuse.2655
	fsub	%f9, %f17, %f0
	fldi	%f2, %g31, 308
	fmov	%f0, %f2
	call	fneg.2501
	fmov	%f11, %f0
	fldi	%f0, %g31, 304
	call	fneg.2501
	fmov	%f10, %f0
	fldi	%f0, %g31, 300
	call	fneg.2501
	addi	%g1, %g1, 4
	addi	%g11, %g14, 1
	fsti	%f0, %g1, 0
	fsti	%f9, %g1, 4
	mov	%g12, %g13
	fmov	%f1, %f10
	subi	%g1, %g1, 12
	call	add_reflection.3041
	addi	%g1, %g1, 12
	addi	%g12, %g13, 1
	addi	%g11, %g14, 2
	fldi	%f1, %g31, 304
	fldi	%f9, %g1, 4
	fldi	%f0, %g1, 0
	fmov	%f2, %f11
	subi	%g1, %g1, 12
	call	add_reflection.3041
	addi	%g1, %g1, 12
	addi	%g12, %g13, 2
	addi	%g11, %g14, 3
	fldi	%f0, %g31, 300
	fldi	%f9, %g1, 4
	fmov	%f1, %f10
	fmov	%f2, %f11
	subi	%g1, %g1, 12
	call	add_reflection.3041
	addi	%g1, %g1, 12
	addi	%g3, %g13, 3
	sti	%g3, %g31, 1720
	return

!==============================
! args = [%g3, %g5]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g2, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f21, %f20, %f2, %f19, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
setup_surface_reflection.3051:
	slli	%g3, %g3, 2
	addi	%g11, %g3, 1
	ldi	%g12, %g31, 1720
	mov	%g3, %g5
	subi	%g1, %g1, 4
	call	o_diffuse.2655
	fsub	%f9, %f17, %f0
	mov	%g3, %g5
	call	o_param_abc.2647
	subi	%g4, %g31, 308
	call	veciprod.2606
	fmov	%f3, %f0
	mov	%g3, %g5
	call	o_param_a.2641
	fmul	%f0, %f20, %f0
	fmul	%f1, %f0, %f3
	fldi	%f0, %g31, 308
	fsub	%f2, %f1, %f0
	mov	%g3, %g5
	call	o_param_b.2643
	fmul	%f0, %f20, %f0
	fmul	%f1, %f0, %f3
	fldi	%f0, %g31, 304
	fsub	%f1, %f1, %f0
	mov	%g3, %g5
	call	o_param_c.2645
	addi	%g1, %g1, 4
	fmul	%f0, %f20, %f0
	fmul	%f3, %f0, %f3
	fldi	%f0, %g31, 300
	fsub	%f0, %f3, %f0
	sti	%g12, %g1, 0
	subi	%g1, %g1, 8
	call	add_reflection.3041
	addi	%g1, %g1, 8
	ldi	%g12, %g1, 0
	addi	%g3, %g12, 1
	sti	%g3, %g31, 1720
	return

!==============================
! args = [%g15]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g2, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f21, %f20, %f2, %f19, %f17, %f16, %f15, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
setup_reflections.3054:
	jlt	%g15, %g0, jge_else.8064
	slli	%g3, %g15, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 272
	mov	%g3, %g4
	subi	%g1, %g1, 4
	call	o_reflectiontype.2635
	addi	%g1, %g1, 4
	addi	%g5, %g0, 2
	jne	%g3, %g5, jeq_else.8065
	mov	%g3, %g4
	subi	%g1, %g1, 4
	call	o_diffuse.2655
	fmov	%f1, %f0
	fmov	%f0, %f17
	call	fless.2485
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.8066
	return
jeq_else.8066:
	mov	%g3, %g4
	subi	%g1, %g1, 4
	call	o_form.2633
	addi	%g1, %g1, 4
	jne	%g3, %g28, jeq_else.8068
	mov	%g3, %g15
	jmp	setup_rect_reflection.3048
jeq_else.8068:
	addi	%g5, %g0, 2
	jne	%g3, %g5, jeq_else.8069
	mov	%g5, %g4
	mov	%g3, %g15
	jmp	setup_surface_reflection.3051
jeq_else.8069:
	return
jeq_else.8065:
	return
jge_else.8064:
	return

!==============================
! args = [%g6, %g3]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g2, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f29, %f28, %f27, %f26, %f25, %f24, %f23, %f22, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
rt.3056:
	sti	%g6, %g31, 600
	sti	%g3, %g31, 596
	srli	%g4, %g6, 1
	sti	%g4, %g31, 608
	srli	%g3, %g3, 1
	sti	%g3, %g31, 604
	setL %g3, l.7379
	fldi	%f3, %g3, 0
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fdiv	%f0, %f3, %f0
	fsti	%f0, %g31, 612
	call	create_pixelline.3005
	mov	%g16, %g3
	call	create_pixelline.3005
	mov	%g25, %g3
	call	create_pixelline.3005
	addi	%g1, %g1, 4
	mov	%g17, %g3
	sti	%g17, %g1, 0
	sti	%g16, %g1, 4
	sti	%g25, %g1, 8
	subi	%g1, %g1, 16
	call	read_parameter.2723
	call	write_ppm_header.2966
	call	init_dirvecs.3039
	subi	%g3, %g31, 980
	call	d_vec.2692
	mov	%g4, %g3
	subi	%g3, %g31, 308
	call	veccpy.2595
	subi	%g9, %g31, 980
	call	setup_dirvec_constants.2821
	ldi	%g3, %g31, 28
	subi	%g15, %g3, 1
	call	setup_reflections.3054
	addi	%g1, %g1, 16
	addi	%g3, %g0, 0
	addi	%g26, %g0, 0
	ldi	%g25, %g1, 8
	subi	%g1, %g1, 16
	call	pretrace_line.2982
	addi	%g1, %g1, 16
	addi	%g26, %g0, 0
	addi	%g4, %g0, 2
	ldi	%g16, %g1, 4
	ldi	%g25, %g1, 8
	ldi	%g17, %g1, 0
	mov	%g15, %g17
	mov	%g14, %g16
	mov	%g16, %g25
	jmp	scan_line.2992
