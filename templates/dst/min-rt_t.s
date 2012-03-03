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
l.7510:	! 128.000000
	.long	0x43000000
l.7452:	! 0.900000
	.long	0x3f66665e
l.7450:	! 0.200000
	.long	0x3e4cccc4
l.7255:	! 150.000000
	.long	0x43160000
l.7251:	! -150.000000
	.long	0xc3160000
l.7216:	! 0.100000
	.long	0x3dccccc4
l.7204:	! -2.000000
	.long	0xc0000000
l.7199:	! 0.003906
	.long	0x3b800000
l.7148:	! 20.000000
	.long	0x41a00000
l.7146:	! 0.050000
	.long	0x3d4cccc4
l.7138:	! 0.250000
	.long	0x3e800000
l.7129:	! 10.000000
	.long	0x41200000
l.7122:	! 0.300000
	.long	0x3e999999
l.7117:	! 0.150000
	.long	0x3e199999
l.7110:	! 3.141593
	.long	0x40490fda
l.7108:	! 30.000000
	.long	0x41f00000
l.7106:	! 15.000000
	.long	0x41700000
l.7104:	! 0.000100
	.long	0x38d1b70f
l.7027:	! 100000000.000000
	.long	0x4cbebc20
l.6978:	! -0.100000
	.long	0xbdccccc4
l.6950:	! 0.010000
	.long	0x3c23d70a
l.6948:	! -0.200000
	.long	0xbe4cccc4
l.6612:	! -200.000000
	.long	0xc3480000
l.6609:	! 200.000000
	.long	0x43480000
l.6604:	! 0.017453
	.long	0x3c8efa2d
l.6409:	! 3.141593
	.long	0x40490fda
l.6406:	! 6.283185
	.long	0x40c90fda
l.6403:	! 9.000000
	.long	0x41100000
l.6400:	! 2.000000
	.long	0x40000000
l.6398:	! 2.500000
	.long	0x40200000
l.6396:	! -1.570796
	.long	0xbfc90fda
l.6394:	! 1.570796
	.long	0x3fc90fda
l.6391:	! 11.000000
	.long	0x41300000
l.6389:	! -1.000000
	.long	0xbf800000
l.6386:	! 1.000000
	.long	0x3f800000
l.6383:	! 0.500000
	.long	0x3f000000
l.6314:	! 1000000000.000000
	.long	0x4e6e6b28
l.6310:	! 255.000000
	.long	0x437f0000
l.6296:	! 0.000000
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
	setL %g27, l.6296
	fldi	%f16, %g27, 0
	setL %g27, l.6386
	fldi	%f17, %g27, 0
	setL %g27, l.6310
	fldi	%f18, %g27, 0
	setL %g27, l.6383
	fldi	%f19, %g27, 0
	setL %g27, l.6400
	fldi	%f20, %g27, 0
	setL %g27, l.6389
	fldi	%f21, %g27, 0
	setL %g27, l.7216
	fldi	%f22, %g27, 0
	setL %g27, l.7110
	fldi	%f23, %g27, 0
	setL %g27, l.6978
	fldi	%f24, %g27, 0
	setL %g27, l.6950
	fldi	%f25, %g27, 0
	setL %g27, l.6394
	fldi	%f26, %g27, 0
	setL %g27, l.6314
	fldi	%f27, %g27, 0
	setL %g27, l.7452
	fldi	%f28, %g27, 0
	setL %g27, l.7450
	fldi	%f29, %g27, 0
	setL %g27, l.7129
	fldi	%f30, %g27, 0
	setL %g27, l.7108
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
	call	rt.3098
	addi	%g1, %g1, 4
	addi	%g0, %g0, 0
	halt

!==============================
! args = []
! fargs = [%f1, %f0]
! use_regs = [%g3, %g27, %f15, %f1, %f0]
! ret type = Bool
!================================
fless.2523:
	fjlt	%f1, %f0, fjge_else.7753
	addi	%g3, %g0, 0
	return
fjge_else.7753:
	addi	%g3, %g0, 1
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g3, %g27, %f16, %f15, %f0]
! ret type = Bool
!================================
fispos.2526:
	fjlt	%f16, %f0, fjge_else.7754
	addi	%g3, %g0, 0
	return
fjge_else.7754:
	addi	%g3, %g0, 1
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g3, %g27, %f16, %f15, %f0]
! ret type = Bool
!================================
fisneg.2528:
	fjlt	%f0, %f16, fjge_else.7755
	addi	%g3, %g0, 0
	return
fjge_else.7755:
	addi	%g3, %g0, 1
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g3, %g27, %f16, %f15, %f0]
! ret type = Bool
!================================
fiszero.2530:
	fjeq	%f0, %f16, fjne_else.7756
	addi	%g3, %g0, 0
	return
fjne_else.7756:
	addi	%g3, %g0, 1
	return

!==============================
! args = [%g4, %g3]
! fargs = []
! use_regs = [%g4, %g3, %g27, %f15]
! ret type = Bool
!================================
xor.2532:
	jne	%g4, %g3, jeq_else.7757
	addi	%g3, %g0, 0
	return
jeq_else.7757:
	addi	%g3, %g0, 1
	return

!==============================
! args = []
! fargs = [%f1]
! use_regs = [%g27, %f16, %f15, %f1, %f0]
! ret type = Float
!================================
fabs.2535:
	fjlt	%f1, %f16, fjge_else.7758
	fmov	%f0, %f1
	return
fjge_else.7758:
	fneg	%f0, %f1
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g27, %f15, %f0]
! ret type = Float
!================================
fneg.2539:
	fneg	%f0, %f0
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g27, %f19, %f15, %f0]
! ret type = Float
!================================
fhalf.2541:
	fmul	%f0, %f0, %f19
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g27, %f15, %f0]
! ret type = Float
!================================
fsqr.2543:
	fmul	%f0, %f0, %f0
	return

!==============================
! args = []
! fargs = [%f2, %f3, %f1]
! use_regs = [%g27, %f4, %f3, %f2, %f19, %f17, %f15, %f1, %f0]
! ret type = Float
!================================
atan_sub.2548:
	fjlt	%f2, %f19, fjge_else.7759
	fsub	%f0, %f2, %f17
	fmul	%f4, %f2, %f2
	fmul	%f4, %f4, %f3
	fadd	%f2, %f2, %f2
	fadd	%f2, %f2, %f17
	fadd	%f1, %f2, %f1
	fdiv	%f1, %f4, %f1
	fmov	%f2, %f0
	jmp	atan_sub.2548
fjge_else.7759:
	fmov	%f0, %f1
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g4, %g3, %g27, %f5, %f4, %f3, %f26, %f21, %f2, %f19, %f17, %f16, %f15, %f1, %f0]
! ret type = Float
!================================
atan.2552:
	fjlt	%f17, %f0, fjge_else.7760
	fjlt	%f0, %f21, fjge_else.7762
	addi	%g3, %g0, 0
	jmp	fjge_cont.7763
fjge_else.7762:
	addi	%g3, %g0, -1
fjge_cont.7763:
	jmp	fjge_cont.7761
fjge_else.7760:
	addi	%g3, %g0, 1
fjge_cont.7761:
	jne	%g3, %g0, jeq_else.7764
	fmov	%f5, %f0
	jmp	jeq_cont.7765
jeq_else.7764:
	fdiv	%f5, %f17, %f0
jeq_cont.7765:
	setL %g4, l.6391
	fldi	%f2, %g4, 0
	fmul	%f3, %f5, %f5
	fmov	%f1, %f16
	subi	%g1, %g1, 4
	call	atan_sub.2548
	addi	%g1, %g1, 4
	fadd	%f0, %f17, %f0
	fdiv	%f1, %f5, %f0
	jlt	%g0, %g3, jle_else.7766
	jlt	%g3, %g0, jge_else.7767
	fmov	%f0, %f1
	return
jge_else.7767:
	setL %g3, l.6396
	fldi	%f0, %g3, 0
	fsub	%f0, %f0, %f1
	return
jle_else.7766:
	fsub	%f0, %f26, %f1
	return

!==============================
! args = []
! fargs = [%f2, %f3, %f1]
! use_regs = [%g3, %g27, %f3, %f20, %f2, %f15, %f1, %f0]
! ret type = Float
!================================
tan_sub.6247:
	setL %g3, l.6398
	fldi	%f0, %g3, 0
	fjlt	%f2, %f0, fjge_else.7768
	fsub	%f0, %f2, %f20
	fsub	%f1, %f2, %f1
	fdiv	%f1, %f3, %f1
	fmov	%f2, %f0
	jmp	tan_sub.6247
fjge_else.7768:
	fmov	%f0, %f1
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g3, %g27, %f3, %f20, %f2, %f17, %f16, %f15, %f1, %f0]
! ret type = Float
!================================
tan.2554:
	setL %g3, l.6403
	fldi	%f2, %g3, 0
	fmul	%f3, %f0, %f0
	fsti	%f0, %g1, 0
	fmov	%f1, %f16
	subi	%g1, %g1, 8
	call	tan_sub.6247
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
sin_sub.2556:
	setL %g3, l.6406
	fldi	%f2, %g3, 0
	fjlt	%f2, %f1, fjge_else.7769
	fjlt	%f1, %f16, fjge_else.7770
	fmov	%f0, %f1
	return
fjge_else.7770:
	fadd	%f1, %f1, %f2
	jmp	sin_sub.2556
fjge_else.7769:
	fsub	%f1, %f1, %f2
	jmp	sin_sub.2556

!==============================
! args = []
! fargs = [%f3]
! use_regs = [%g4, %g3, %g27, %f5, %f4, %f3, %f26, %f20, %f2, %f19, %f17, %f16, %f15, %f1, %f0]
! ret type = Float
!================================
sin.2558:
	setL %g3, l.6409
	fldi	%f5, %g3, 0
	setL %g3, l.6406
	fldi	%f4, %g3, 0
	fmov	%f1, %f3
	subi	%g1, %g1, 4
	call	fabs.2535
	fmov	%f1, %f0
	call	sin_sub.2556
	addi	%g1, %g1, 4
	fjlt	%f5, %f0, fjge_else.7771
	fjlt	%f16, %f3, fjge_else.7773
	addi	%g4, %g0, 0
	jmp	fjge_cont.7774
fjge_else.7773:
	addi	%g4, %g0, 1
fjge_cont.7774:
	jmp	fjge_cont.7772
fjge_else.7771:
	fjlt	%f16, %f3, fjge_else.7775
	addi	%g4, %g0, 1
	jmp	fjge_cont.7776
fjge_else.7775:
	addi	%g4, %g0, 0
fjge_cont.7776:
fjge_cont.7772:
	fjlt	%f5, %f0, fjge_else.7777
	fmov	%f1, %f0
	jmp	fjge_cont.7778
fjge_else.7777:
	fsub	%f1, %f4, %f0
fjge_cont.7778:
	fjlt	%f26, %f1, fjge_else.7779
	fmov	%f0, %f1
	jmp	fjge_cont.7780
fjge_else.7779:
	fsub	%f0, %f5, %f1
fjge_cont.7780:
	fmul	%f0, %f0, %f19
	subi	%g1, %g1, 4
	call	tan.2554
	addi	%g1, %g1, 4
	fmul	%f1, %f20, %f0
	fmul	%f0, %f0, %f0
	fadd	%f0, %f17, %f0
	fdiv	%f1, %f1, %f0
	jne	%g4, %g0, jeq_else.7781
	fmov	%f0, %f1
	jmp	fneg.2539
jeq_else.7781:
	fmov	%f0, %f1
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g4, %g3, %g27, %f5, %f4, %f3, %f26, %f20, %f2, %f19, %f17, %f16, %f15, %f1, %f0]
! ret type = Float
!================================
cos.2560:
	fsub	%f3, %f26, %f0
	jmp	sin.2558

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g4, %g3, %g27, %f15]
! ret type = Int
!================================
mul10.2562:
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	return

!==============================
! args = [%g5, %g4]
! fargs = []
! use_regs = [%g6, %g5, %g4, %g3, %g27, %f15, %dummy]
! ret type = Int
!================================
read_int_token.2566:
	input	%g6
	addi	%g3, %g0, 48
	jlt	%g6, %g3, jle_else.7782
	addi	%g3, %g0, 57
	jlt	%g3, %g6, jle_else.7784
	addi	%g3, %g0, 0
	jmp	jle_cont.7785
jle_else.7784:
	addi	%g3, %g0, 1
jle_cont.7785:
	jmp	jle_cont.7783
jle_else.7782:
	addi	%g3, %g0, 1
jle_cont.7783:
	jne	%g3, %g0, jeq_else.7786
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.7787
	addi	%g3, %g0, 45
	jne	%g4, %g3, jeq_else.7789
	addi	%g3, %g0, -1
	sti	%g3, %g31, 8
	jmp	jeq_cont.7790
jeq_else.7789:
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
jeq_cont.7790:
	jmp	jeq_cont.7788
jeq_else.7787:
jeq_cont.7788:
	ldi	%g3, %g31, 4
	subi	%g1, %g1, 4
	call	mul10.2562
	addi	%g1, %g1, 4
	subi	%g4, %g6, 48
	add	%g3, %g3, %g4
	sti	%g3, %g31, 4
	addi	%g5, %g0, 1
	mov	%g4, %g6
	jmp	read_int_token.2566
jeq_else.7786:
	jne	%g5, %g0, jeq_else.7791
	addi	%g5, %g0, 0
	mov	%g4, %g6
	jmp	read_int_token.2566
jeq_else.7791:
	ldi	%g3, %g31, 8
	jne	%g3, %g28, jeq_else.7792
	ldi	%g3, %g31, 4
	return
jeq_else.7792:
	ldi	%g3, %g31, 4
	sub	%g3, %g0, %g3
	return

!==============================
! args = []
! fargs = []
! use_regs = [%g6, %g5, %g4, %g3, %g27, %f15, %dummy]
! ret type = Int
!================================
read_int.2569:
	addi	%g3, %g0, 0
	sti	%g3, %g31, 4
	addi	%g3, %g0, 0
	sti	%g3, %g31, 8
	addi	%g5, %g0, 0
	addi	%g4, %g0, 32
	jmp	read_int_token.2566

!==============================
! args = [%g6, %g4]
! fargs = []
! use_regs = [%g6, %g5, %g4, %g3, %g27, %f15, %dummy]
! ret type = Int
!================================
read_float_token1.2575:
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.7793
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.7795
	addi	%g3, %g0, 0
	jmp	jle_cont.7796
jle_else.7795:
	addi	%g3, %g0, 1
jle_cont.7796:
	jmp	jle_cont.7794
jle_else.7793:
	addi	%g3, %g0, 1
jle_cont.7794:
	jne	%g3, %g0, jeq_else.7797
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.7798
	addi	%g3, %g0, 45
	jne	%g4, %g3, jeq_else.7800
	addi	%g3, %g0, -1
	sti	%g3, %g31, 24
	jmp	jeq_cont.7801
jeq_else.7800:
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
jeq_cont.7801:
	jmp	jeq_cont.7799
jeq_else.7798:
jeq_cont.7799:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	mul10.2562
	addi	%g1, %g1, 4
	subi	%g4, %g5, 48
	add	%g3, %g3, %g4
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	mov	%g4, %g5
	jmp	read_float_token1.2575
jeq_else.7797:
	jne	%g6, %g0, jeq_else.7802
	addi	%g6, %g0, 0
	mov	%g4, %g5
	jmp	read_float_token1.2575
jeq_else.7802:
	mov	%g3, %g5
	return

!==============================
! args = [%g4]
! fargs = []
! use_regs = [%g5, %g4, %g3, %g27, %f15, %dummy]
! ret type = Unit
!================================
read_float_token2.2578:
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.7803
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.7805
	addi	%g3, %g0, 0
	jmp	jle_cont.7806
jle_else.7805:
	addi	%g3, %g0, 1
jle_cont.7806:
	jmp	jle_cont.7804
jle_else.7803:
	addi	%g3, %g0, 1
jle_cont.7804:
	jne	%g3, %g0, jeq_else.7807
	ldi	%g3, %g31, 16
	subi	%g1, %g1, 4
	call	mul10.2562
	subi	%g4, %g5, 48
	add	%g3, %g3, %g4
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	call	mul10.2562
	addi	%g1, %g1, 4
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	jmp	read_float_token2.2578
jeq_else.7807:
	jne	%g4, %g0, jeq_else.7808
	addi	%g4, %g0, 0
	jmp	read_float_token2.2578
jeq_else.7808:
	return

!==============================
! args = []
! fargs = []
! use_regs = [%g6, %g5, %g4, %g3, %g27, %f4, %f3, %f2, %f15, %f1, %f0, %dummy]
! ret type = Float
!================================
read_float.2580:
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	addi	%g6, %g0, 0
	addi	%g4, %g0, 32
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.7810
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	ldi	%g3, %g31, 12
	call	min_caml_float_of_int
	fmov	%f4, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f3, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f1, %f3, %f0
	fadd	%f1, %f4, %f1
	jmp	jeq_cont.7811
jeq_else.7810:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fmov	%f1, %f0
jeq_cont.7811:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.7812
	fmov	%f0, %f1
	return
jeq_else.7812:
	fneg	%f0, %f1
	return

!==============================
! args = [%g8, %g7, %g5, %g6]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %f15]
! ret type = Int
!================================
div_binary_search.2582:
	add	%g3, %g5, %g6
	srli	%g4, %g3, 1
	mul	%g9, %g4, %g7
	sub	%g3, %g6, %g5
	jlt	%g28, %g3, jle_else.7813
	mov	%g3, %g5
	return
jle_else.7813:
	jlt	%g9, %g8, jle_else.7814
	jne	%g9, %g8, jeq_else.7815
	mov	%g3, %g4
	return
jeq_else.7815:
	mov	%g6, %g4
	jmp	div_binary_search.2582
jle_else.7814:
	mov	%g5, %g4
	jmp	div_binary_search.2582

!==============================
! args = [%g8]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g11, %g10, %f15, %dummy]
! ret type = Unit
!================================
print_int.2587:
	jlt	%g8, %g0, jge_else.7816
	mvhi	%g7, 1525
	mvlo	%g7, 57600
	addi	%g5, %g0, 0
	addi	%g6, %g0, 3
	sti	%g8, %g1, 0
	subi	%g1, %g1, 8
	call	div_binary_search.2582
	addi	%g1, %g1, 8
	mvhi	%g4, 1525
	mvlo	%g4, 57600
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 0
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.7817
	addi	%g10, %g0, 0
	jmp	jle_cont.7818
jle_else.7817:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jle_cont.7818:
	mvhi	%g7, 152
	mvlo	%g7, 38528
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 4
	subi	%g1, %g1, 12
	call	div_binary_search.2582
	addi	%g1, %g1, 12
	mvhi	%g4, 152
	mvlo	%g4, 38528
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 4
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.7819
	jne	%g10, %g0, jeq_else.7821
	addi	%g11, %g0, 0
	jmp	jeq_cont.7822
jeq_else.7821:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jeq_cont.7822:
	jmp	jle_cont.7820
jle_else.7819:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jle_cont.7820:
	mvhi	%g7, 15
	mvlo	%g7, 16960
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 8
	subi	%g1, %g1, 16
	call	div_binary_search.2582
	addi	%g1, %g1, 16
	mvhi	%g4, 15
	mvlo	%g4, 16960
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 8
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.7823
	jne	%g11, %g0, jeq_else.7825
	addi	%g10, %g0, 0
	jmp	jeq_cont.7826
jeq_else.7825:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jeq_cont.7826:
	jmp	jle_cont.7824
jle_else.7823:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jle_cont.7824:
	mvhi	%g7, 1
	mvlo	%g7, 34464
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 12
	subi	%g1, %g1, 20
	call	div_binary_search.2582
	addi	%g1, %g1, 20
	mvhi	%g4, 1
	mvlo	%g4, 34464
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 12
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.7827
	jne	%g10, %g0, jeq_else.7829
	addi	%g11, %g0, 0
	jmp	jeq_cont.7830
jeq_else.7829:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jeq_cont.7830:
	jmp	jle_cont.7828
jle_else.7827:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jle_cont.7828:
	addi	%g7, %g0, 10000
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 16
	subi	%g1, %g1, 24
	call	div_binary_search.2582
	addi	%g1, %g1, 24
	addi	%g4, %g0, 10000
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 16
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.7831
	jne	%g11, %g0, jeq_else.7833
	addi	%g10, %g0, 0
	jmp	jeq_cont.7834
jeq_else.7833:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jeq_cont.7834:
	jmp	jle_cont.7832
jle_else.7831:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jle_cont.7832:
	addi	%g7, %g0, 1000
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 20
	subi	%g1, %g1, 28
	call	div_binary_search.2582
	addi	%g1, %g1, 28
	muli	%g4, %g3, 1000
	ldi	%g8, %g1, 20
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.7835
	jne	%g10, %g0, jeq_else.7837
	addi	%g11, %g0, 0
	jmp	jeq_cont.7838
jeq_else.7837:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jeq_cont.7838:
	jmp	jle_cont.7836
jle_else.7835:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jle_cont.7836:
	addi	%g7, %g0, 100
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 24
	subi	%g1, %g1, 32
	call	div_binary_search.2582
	addi	%g1, %g1, 32
	muli	%g4, %g3, 100
	ldi	%g8, %g1, 24
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.7839
	jne	%g11, %g0, jeq_else.7841
	addi	%g10, %g0, 0
	jmp	jeq_cont.7842
jeq_else.7841:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jeq_cont.7842:
	jmp	jle_cont.7840
jle_else.7839:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jle_cont.7840:
	addi	%g7, %g0, 10
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 28
	subi	%g1, %g1, 36
	call	div_binary_search.2582
	addi	%g1, %g1, 36
	muli	%g4, %g3, 10
	ldi	%g8, %g1, 28
	sub	%g4, %g8, %g4
	jlt	%g0, %g3, jle_else.7843
	jne	%g10, %g0, jeq_else.7845
	addi	%g5, %g0, 0
	jmp	jeq_cont.7846
jeq_else.7845:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g5, %g0, 1
jeq_cont.7846:
	jmp	jle_cont.7844
jle_else.7843:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g5, %g0, 1
jle_cont.7844:
	addi	%g3, %g0, 48
	add	%g3, %g3, %g4
	output	%g3
	return
jge_else.7816:
	addi	%g3, %g0, 45
	output	%g3
	sub	%g8, %g0, %g8
	jmp	print_int.2587

!==============================
! args = []
! fargs = [%f1]
! use_regs = [%g3, %g27, %f16, %f15, %f1, %f0]
! ret type = Float
!================================
sgn.2619:
	fmov	%f0, %f1
	subi	%g1, %g1, 4
	call	fiszero.2530
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7847
	fmov	%f0, %f1
	subi	%g1, %g1, 4
	call	fispos.2526
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7848
	setL %g3, l.6389
	fldi	%f0, %g3, 0
	return
jeq_else.7848:
	setL %g3, l.6386
	fldi	%f0, %g3, 0
	return
jeq_else.7847:
	setL %g3, l.6296
	fldi	%f0, %g3, 0
	return

!==============================
! args = [%g3]
! fargs = [%f1]
! use_regs = [%g3, %g27, %f15, %f1, %f0]
! ret type = Float
!================================
fneg_cond.2621:
	jne	%g3, %g0, jeq_else.7849
	fmov	%f0, %f1
	jmp	fneg.2539
jeq_else.7849:
	fmov	%f0, %f1
	return

!==============================
! args = [%g4, %g3]
! fargs = []
! use_regs = [%g4, %g3, %g27, %f15]
! ret type = Int
!================================
add_mod5.2624:
	add	%g4, %g4, %g3
	addi	%g3, %g0, 5
	jlt	%g4, %g3, jle_else.7850
	subi	%g3, %g4, 5
	return
jle_else.7850:
	mov	%g3, %g4
	return

!==============================
! args = [%g3]
! fargs = [%f2, %f1, %f0]
! use_regs = [%g3, %g27, %f2, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
vecset.2627:
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
vecfill.2632:
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
vecbzero.2635:
	fmov	%f0, %f16
	jmp	vecfill.2632

!==============================
! args = [%g4, %g3]
! fargs = []
! use_regs = [%g4, %g3, %g27, %f15, %f0, %dummy]
! ret type = Unit
!================================
veccpy.2637:
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
vecunit_sgn.2645:
	fldi	%f1, %g4, 0
	fmov	%f0, %f1
	subi	%g1, %g1, 4
	call	fsqr.2543
	fmov	%f2, %f0
	fldi	%f0, %g4, -4
	call	fsqr.2543
	fadd	%f2, %f2, %f0
	fldi	%f0, %g4, -8
	call	fsqr.2543
	addi	%g1, %g1, 4
	fadd	%f0, %f2, %f0
	fsqrt	%f0, %f0
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fiszero.2530
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7854
	jne	%g5, %g0, jeq_else.7856
	fldi	%f0, %g1, 0
	fdiv	%f2, %f17, %f0
	jmp	jeq_cont.7857
jeq_else.7856:
	fldi	%f0, %g1, 0
	fdiv	%f2, %f21, %f0
jeq_cont.7857:
	jmp	jeq_cont.7855
jeq_else.7854:
	setL %g3, l.6386
	fldi	%f2, %g3, 0
jeq_cont.7855:
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
veciprod.2648:
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
veciprod2.2651:
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
vecaccum.2656:
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
vecadd.2660:
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
vecscale.2666:
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
vecaccumv.2669:
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
o_texturetype.2673:
	ldi	%g3, %g3, 0
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Int
!================================
o_form.2675:
	ldi	%g3, %g3, -4
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Int
!================================
o_reflectiontype.2677:
	ldi	%g3, %g3, -8
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Bool
!================================
o_isinvert.2679:
	ldi	%g3, %g3, -24
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Int
!================================
o_isrot.2681:
	ldi	%g3, %g3, -12
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_param_a.2683:
	ldi	%g3, %g3, -16
	fldi	%f0, %g3, 0
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_param_b.2685:
	ldi	%g3, %g3, -16
	fldi	%f0, %g3, -4
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_param_c.2687:
	ldi	%g3, %g3, -16
	fldi	%f0, %g3, -8
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Array(Float)
!================================
o_param_abc.2689:
	ldi	%g3, %g3, -16
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_param_x.2691:
	ldi	%g3, %g3, -20
	fldi	%f0, %g3, 0
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_param_y.2693:
	ldi	%g3, %g3, -20
	fldi	%f0, %g3, -4
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_param_z.2695:
	ldi	%g3, %g3, -20
	fldi	%f0, %g3, -8
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_diffuse.2697:
	ldi	%g3, %g3, -28
	fldi	%f0, %g3, 0
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_hilight.2699:
	ldi	%g3, %g3, -28
	fldi	%f0, %g3, -4
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_color_red.2701:
	ldi	%g3, %g3, -32
	fldi	%f0, %g3, 0
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_color_green.2703:
	ldi	%g3, %g3, -32
	fldi	%f0, %g3, -4
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_color_blue.2705:
	ldi	%g3, %g3, -32
	fldi	%f0, %g3, -8
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_param_r1.2707:
	ldi	%g3, %g3, -36
	fldi	%f0, %g3, 0
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_param_r2.2709:
	ldi	%g3, %g3, -36
	fldi	%f0, %g3, -4
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
o_param_r3.2711:
	ldi	%g3, %g3, -36
	fldi	%f0, %g3, -8
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Array(Float)
!================================
o_param_ctbl.2713:
	ldi	%g3, %g3, -40
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Array(Float)
!================================
p_rgb.2715:
	ldi	%g3, %g3, 0
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Array(Array(Float))
!================================
p_intersection_points.2717:
	ldi	%g3, %g3, -4
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Array(Int)
!================================
p_surface_ids.2719:
	ldi	%g3, %g3, -8
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Array(Bool)
!================================
p_calc_diffuse.2721:
	ldi	%g3, %g3, -12
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Array(Array(Float))
!================================
p_energy.2723:
	ldi	%g3, %g3, -16
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Array(Array(Float))
!================================
p_received_ray_20percent.2725:
	ldi	%g3, %g3, -20
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Int
!================================
p_group_id.2727:
	ldi	%g3, %g3, -24
	ldi	%g3, %g3, 0
	return

!==============================
! args = [%g3, %g4]
! fargs = []
! use_regs = [%g4, %g3, %g27, %f15, %dummy]
! ret type = Unit
!================================
p_set_group_id.2729:
	ldi	%g3, %g3, -24
	sti	%g4, %g3, 0
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Array(Array(Float))
!================================
p_nvectors.2732:
	ldi	%g3, %g3, -28
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Array(Float)
!================================
d_vec.2734:
	ldi	%g3, %g3, 0
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Array(Array(Float))
!================================
d_const.2736:
	ldi	%g3, %g3, -4
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = Int
!================================
r_surface_id.2738:
	ldi	%g3, %g3, 0
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15]
! ret type = (Array(Float) * Array(Array(Float)))
!================================
r_dvec.2740:
	ldi	%g3, %g3, -4
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g3, %g27, %f15, %f0]
! ret type = Float
!================================
r_bright.2742:
	fldi	%f0, %g3, -8
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g3, %g27, %f15, %f1, %f0]
! ret type = Float
!================================
rad.2744:
	setL %g3, l.6604
	fldi	%f1, %g3, 0
	fmul	%f0, %f0, %f1
	return

!==============================
! args = []
! fargs = []
! use_regs = [%g6, %g5, %g4, %g3, %g27, %f8, %f7, %f6, %f5, %f4, %f3, %f26, %f20, %f2, %f19, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
read_screen_settings.2746:
	subi	%g1, %g1, 4
	call	read_float.2580
	fsti	%f0, %g31, 284
	call	read_float.2580
	fsti	%f0, %g31, 280
	call	read_float.2580
	fsti	%f0, %g31, 276
	call	read_float.2580
	call	rad.2744
	addi	%g1, %g1, 4
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	cos.2560
	addi	%g1, %g1, 8
	fmov	%f7, %f0
	fldi	%f0, %g1, 0
	fmov	%f3, %f0
	subi	%g1, %g1, 8
	call	sin.2558
	fmov	%f8, %f0
	call	read_float.2580
	call	rad.2744
	addi	%g1, %g1, 8
	fsti	%f0, %g1, 4
	subi	%g1, %g1, 12
	call	cos.2560
	addi	%g1, %g1, 12
	fmov	%f6, %f0
	fldi	%f0, %g1, 4
	fmov	%f3, %f0
	subi	%g1, %g1, 12
	call	sin.2558
	addi	%g1, %g1, 12
	fmul	%f1, %f7, %f0
	setL %g3, l.6609
	fldi	%f2, %g3, 0
	fmul	%f1, %f1, %f2
	fsti	%f1, %g31, 672
	setL %g3, l.6612
	fldi	%f1, %g3, 0
	fmul	%f1, %f8, %f1
	fsti	%f1, %g31, 668
	fmul	%f1, %f7, %f6
	fmul	%f1, %f1, %f2
	fsti	%f1, %g31, 664
	fsti	%f6, %g31, 648
	fsti	%f16, %g31, 644
	fsti	%f0, %g1, 8
	subi	%g1, %g1, 16
	call	fneg.2539
	fmov	%f1, %f0
	fsti	%f1, %g31, 640
	fmov	%f0, %f8
	call	fneg.2539
	addi	%g1, %g1, 16
	fmov	%f1, %f0
	fldi	%f0, %g1, 8
	fmul	%f0, %f1, %f0
	fsti	%f0, %g31, 660
	fmov	%f0, %f7
	subi	%g1, %g1, 16
	call	fneg.2539
	addi	%g1, %g1, 16
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
! use_regs = [%g6, %g5, %g4, %g3, %g27, %f7, %f6, %f5, %f4, %f3, %f26, %f20, %f2, %f19, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
read_light.2748:
	subi	%g1, %g1, 4
	call	read_int.2569
	call	read_float.2580
	call	rad.2744
	fmov	%f7, %f0
	fmov	%f3, %f7
	call	sin.2558
	call	fneg.2539
	fsti	%f0, %g31, 304
	call	read_float.2580
	call	rad.2744
	fmov	%f6, %f0
	fmov	%f0, %f7
	call	cos.2560
	fmov	%f7, %f0
	fmov	%f3, %f6
	call	sin.2558
	fmul	%f0, %f7, %f0
	fsti	%f0, %g31, 308
	fmov	%f0, %f6
	call	cos.2560
	fmul	%f0, %f7, %f0
	fsti	%f0, %g31, 300
	call	read_float.2580
	addi	%g1, %g1, 4
	fsti	%f0, %g31, 312
	return

!==============================
! args = [%g6, %g5]
! fargs = []
! use_regs = [%g6, %g5, %g4, %g3, %g27, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f26, %f20, %f2, %f19, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
rotate_quadratic_matrix.2750:
	fldi	%f6, %g5, 0
	fmov	%f0, %f6
	subi	%g1, %g1, 4
	call	cos.2560
	fmov	%f9, %f0
	fmov	%f3, %f6
	call	sin.2558
	fmov	%f7, %f0
	fldi	%f6, %g5, -4
	fmov	%f0, %f6
	call	cos.2560
	fmov	%f8, %f0
	fmov	%f3, %f6
	call	sin.2558
	fmov	%f10, %f0
	fldi	%f11, %g5, -8
	fmov	%f0, %f11
	call	cos.2560
	fmov	%f6, %f0
	fmov	%f3, %f11
	call	sin.2558
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
	call	fneg.2539
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
	call	fsqr.2543
	fmul	%f7, %f1, %f0
	fmov	%f0, %f14
	call	fsqr.2543
	fmul	%f0, %f2, %f0
	fadd	%f7, %f7, %f0
	fmov	%f0, %f10
	call	fsqr.2543
	fmul	%f0, %f3, %f0
	fadd	%f0, %f7, %f0
	fsti	%f0, %g6, 0
	fmov	%f0, %f13
	call	fsqr.2543
	fmul	%f7, %f1, %f0
	fmov	%f0, %f12
	call	fsqr.2543
	fmul	%f0, %f2, %f0
	fadd	%f7, %f7, %f0
	fmov	%f0, %f6
	call	fsqr.2543
	fmul	%f0, %f3, %f0
	fadd	%f0, %f7, %f0
	fsti	%f0, %g6, -4
	fmov	%f0, %f11
	call	fsqr.2543
	fmul	%f7, %f1, %f0
	fmov	%f0, %f5
	call	fsqr.2543
	fmul	%f0, %f2, %f0
	fadd	%f7, %f7, %f0
	fmov	%f0, %f4
	call	fsqr.2543
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
! args = [%g11]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g2, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f26, %f21, %f20, %f2, %f19, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Bool
!================================
read_nth_object.2753:
	subi	%g1, %g1, 4
	call	read_int.2569
	addi	%g1, %g1, 4
	mov	%g13, %g3
	jne	%g13, %g29, jeq_else.7867
	addi	%g3, %g0, 0
	return
jeq_else.7867:
	subi	%g1, %g1, 4
	call	read_int.2569
	mov	%g8, %g3
	call	read_int.2569
	mov	%g15, %g3
	call	read_int.2569
	mov	%g9, %g3
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g7, %g3
	call	read_float.2580
	fsti	%f0, %g7, 0
	call	read_float.2580
	fsti	%f0, %g7, -4
	call	read_float.2580
	fsti	%f0, %g7, -8
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g12, %g3
	call	read_float.2580
	fsti	%f0, %g12, 0
	call	read_float.2580
	fsti	%f0, %g12, -4
	call	read_float.2580
	fsti	%f0, %g12, -8
	call	read_float.2580
	call	fisneg.2528
	mov	%g10, %g3
	addi	%g3, %g0, 2
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g16, %g3
	call	read_float.2580
	fsti	%f0, %g16, 0
	call	read_float.2580
	fsti	%f0, %g16, -4
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g17, %g3
	call	read_float.2580
	fsti	%f0, %g17, 0
	call	read_float.2580
	fsti	%f0, %g17, -4
	call	read_float.2580
	fsti	%f0, %g17, -8
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	mov	%g14, %g3
	jne	%g9, %g0, jeq_else.7868
	jmp	jeq_cont.7869
jeq_else.7868:
	subi	%g1, %g1, 4
	call	read_float.2580
	call	rad.2744
	fsti	%f0, %g14, 0
	call	read_float.2580
	call	rad.2744
	fsti	%f0, %g14, -4
	call	read_float.2580
	call	rad.2744
	addi	%g1, %g1, 4
	fsti	%f0, %g14, -8
jeq_cont.7869:
	addi	%g5, %g0, 2
	jne	%g8, %g5, jeq_else.7870
	addi	%g5, %g0, 1
	jmp	jeq_cont.7871
jeq_else.7870:
	mov	%g5, %g10
jeq_cont.7871:
	addi	%g3, %g0, 4
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	mov	%g4, %g3
	mov	%g3, %g2
	addi	%g2, %g2, 44
	sti	%g4, %g3, -40
	sti	%g14, %g3, -36
	sti	%g17, %g3, -32
	sti	%g16, %g3, -28
	sti	%g5, %g3, -24
	sti	%g12, %g3, -20
	sti	%g7, %g3, -16
	sti	%g9, %g3, -12
	sti	%g15, %g3, -8
	sti	%g8, %g3, -4
	sti	%g13, %g3, 0
	slli	%g4, %g11, 2
	add	%g4, %g31, %g4
	sti	%g3, %g4, 272
	addi	%g3, %g0, 3
	jne	%g8, %g3, jeq_else.7872
	fldi	%f1, %g7, 0
	fmov	%f0, %f1
	subi	%g1, %g1, 4
	call	fiszero.2530
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7874
	fsti	%f1, %g1, 0
	subi	%g1, %g1, 8
	call	sgn.2619
	addi	%g1, %g1, 8
	fmov	%f2, %f0
	fldi	%f1, %g1, 0
	fmov	%f0, %f1
	subi	%g1, %g1, 8
	call	fsqr.2543
	addi	%g1, %g1, 8
	fdiv	%f0, %f2, %f0
	jmp	jeq_cont.7875
jeq_else.7874:
	fmov	%f0, %f16
jeq_cont.7875:
	fsti	%f0, %g7, 0
	fldi	%f1, %g7, -4
	fmov	%f0, %f1
	subi	%g1, %g1, 8
	call	fiszero.2530
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7876
	fsti	%f1, %g1, 4
	subi	%g1, %g1, 12
	call	sgn.2619
	addi	%g1, %g1, 12
	fmov	%f2, %f0
	fldi	%f1, %g1, 4
	fmov	%f0, %f1
	subi	%g1, %g1, 12
	call	fsqr.2543
	addi	%g1, %g1, 12
	fdiv	%f0, %f2, %f0
	jmp	jeq_cont.7877
jeq_else.7876:
	fmov	%f0, %f16
jeq_cont.7877:
	fsti	%f0, %g7, -4
	fldi	%f1, %g7, -8
	fmov	%f0, %f1
	subi	%g1, %g1, 12
	call	fiszero.2530
	addi	%g1, %g1, 12
	jne	%g3, %g0, jeq_else.7878
	fsti	%f1, %g1, 8
	subi	%g1, %g1, 16
	call	sgn.2619
	addi	%g1, %g1, 16
	fmov	%f2, %f0
	fldi	%f1, %g1, 8
	fmov	%f0, %f1
	subi	%g1, %g1, 16
	call	fsqr.2543
	addi	%g1, %g1, 16
	fdiv	%f0, %f2, %f0
	jmp	jeq_cont.7879
jeq_else.7878:
	fmov	%f0, %f16
jeq_cont.7879:
	fsti	%f0, %g7, -8
	jmp	jeq_cont.7873
jeq_else.7872:
	addi	%g3, %g0, 2
	jne	%g8, %g3, jeq_else.7880
	jne	%g10, %g0, jeq_else.7882
	addi	%g5, %g0, 1
	jmp	jeq_cont.7883
jeq_else.7882:
	addi	%g5, %g0, 0
jeq_cont.7883:
	mov	%g4, %g7
	subi	%g1, %g1, 16
	call	vecunit_sgn.2645
	addi	%g1, %g1, 16
	jmp	jeq_cont.7881
jeq_else.7880:
jeq_cont.7881:
jeq_cont.7873:
	jne	%g9, %g0, jeq_else.7884
	jmp	jeq_cont.7885
jeq_else.7884:
	mov	%g5, %g14
	mov	%g6, %g7
	subi	%g1, %g1, 16
	call	rotate_quadratic_matrix.2750
	addi	%g1, %g1, 16
jeq_cont.7885:
	addi	%g3, %g0, 1
	return

!==============================
! args = [%g11]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g2, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f26, %f21, %f20, %f2, %f19, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
read_object.2755:
	addi	%g3, %g0, 60
	jlt	%g11, %g3, jle_else.7886
	return
jle_else.7886:
	sti	%g11, %g1, 0
	subi	%g1, %g1, 8
	call	read_nth_object.2753
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7888
	ldi	%g11, %g1, 0
	sti	%g11, %g31, 28
	return
jeq_else.7888:
	ldi	%g11, %g1, 0
	addi	%g11, %g11, 1
	jmp	read_object.2755

!==============================
! args = []
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g2, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f26, %f21, %f20, %f2, %f19, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
read_all_object.2757:
	addi	%g11, %g0, 0
	jmp	read_object.2755

!==============================
! args = [%g7]
! fargs = []
! use_regs = [%g7, %g6, %g5, %g4, %g3, %g27, %f15, %dummy]
! ret type = Array(Int)
!================================
read_net_item.2759:
	subi	%g1, %g1, 4
	call	read_int.2569
	addi	%g1, %g1, 4
	mov	%g4, %g3
	jne	%g4, %g29, jeq_else.7890
	addi	%g3, %g7, 1
	addi	%g4, %g0, -1
	jmp	min_caml_create_array
jeq_else.7890:
	addi	%g3, %g7, 1
	sti	%g4, %g1, 0
	sti	%g7, %g1, 4
	mov	%g7, %g3
	subi	%g1, %g1, 12
	call	read_net_item.2759
	addi	%g1, %g1, 12
	ldi	%g7, %g1, 4
	slli	%g5, %g7, 2
	ldi	%g4, %g1, 0
	st	%g4, %g3, %g5
	return

!==============================
! args = [%g8]
! fargs = []
! use_regs = [%g8, %g7, %g6, %g5, %g4, %g3, %g27, %f15, %dummy]
! ret type = Array(Array(Int))
!================================
read_or_network.2761:
	addi	%g7, %g0, 0
	subi	%g1, %g1, 4
	call	read_net_item.2759
	addi	%g1, %g1, 4
	mov	%g4, %g3
	ldi	%g3, %g4, 0
	jne	%g3, %g29, jeq_else.7891
	addi	%g3, %g8, 1
	jmp	min_caml_create_array
jeq_else.7891:
	addi	%g3, %g8, 1
	sti	%g4, %g1, 0
	sti	%g8, %g1, 4
	mov	%g8, %g3
	subi	%g1, %g1, 12
	call	read_or_network.2761
	addi	%g1, %g1, 12
	ldi	%g8, %g1, 4
	slli	%g5, %g8, 2
	ldi	%g4, %g1, 0
	st	%g4, %g3, %g5
	return

!==============================
! args = [%g8]
! fargs = []
! use_regs = [%g8, %g7, %g6, %g5, %g4, %g3, %g27, %f15, %dummy]
! ret type = Unit
!================================
read_and_network.2763:
	addi	%g7, %g0, 0
	subi	%g1, %g1, 4
	call	read_net_item.2759
	addi	%g1, %g1, 4
	ldi	%g4, %g3, 0
	jne	%g4, %g29, jeq_else.7892
	return
jeq_else.7892:
	slli	%g4, %g8, 2
	add	%g4, %g31, %g4
	sti	%g3, %g4, 512
	addi	%g8, %g8, 1
	jmp	read_and_network.2763

!==============================
! args = []
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g2, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f26, %f21, %f20, %f2, %f19, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
read_parameter.2765:
	subi	%g1, %g1, 4
	call	read_screen_settings.2746
	call	read_light.2748
	call	read_all_object.2757
	addi	%g8, %g0, 0
	call	read_and_network.2763
	addi	%g8, %g0, 0
	call	read_or_network.2761
	addi	%g1, %g1, 4
	sti	%g3, %g31, 516
	return

!==============================
! args = [%g4, %g8, %g7, %g6, %g5]
! fargs = [%f4, %f3, %f2]
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %f5, %f4, %f3, %f2, %f16, %f15, %f1, %f0, %dummy]
! ret type = Bool
!================================
solver_rect_surface.2767:
	slli	%g3, %g7, 2
	fld	%f5, %g8, %g3
	fmov	%f0, %f5
	subi	%g1, %g1, 4
	call	fiszero.2530
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7895
	mov	%g3, %g4
	subi	%g1, %g1, 4
	call	o_param_abc.2689
	mov	%g9, %g3
	mov	%g3, %g4
	call	o_isinvert.2679
	mov	%g4, %g3
	fmov	%f0, %f5
	call	fisneg.2528
	call	xor.2532
	slli	%g4, %g7, 2
	fld	%f1, %g9, %g4
	call	fneg_cond.2621
	fsub	%f0, %f0, %f4
	fdiv	%f4, %f0, %f5
	slli	%g3, %g6, 2
	fld	%f0, %g8, %g3
	fmul	%f0, %f4, %f0
	fadd	%f1, %f0, %f3
	call	fabs.2535
	fmov	%f1, %f0
	slli	%g3, %g6, 2
	fld	%f0, %g9, %g3
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7896
	addi	%g3, %g0, 0
	return
jeq_else.7896:
	slli	%g3, %g5, 2
	fld	%f0, %g8, %g3
	fmul	%f0, %f4, %f0
	fadd	%f1, %f0, %f2
	subi	%g1, %g1, 4
	call	fabs.2535
	fmov	%f1, %f0
	slli	%g3, %g5, 2
	fld	%f0, %g9, %g3
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7897
	addi	%g3, %g0, 0
	return
jeq_else.7897:
	fsti	%f4, %g31, 520
	addi	%g3, %g0, 1
	return
jeq_else.7895:
	addi	%g3, %g0, 0
	return

!==============================
! args = [%g4, %g8]
! fargs = [%f8, %f7, %f6]
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f16, %f15, %f1, %f0, %dummy]
! ret type = Int
!================================
solver_rect.2776:
	addi	%g7, %g0, 0
	addi	%g6, %g0, 1
	addi	%g5, %g0, 2
	sti	%g8, %g1, 0
	sti	%g4, %g1, 4
	fmov	%f2, %f6
	fmov	%f3, %f7
	fmov	%f4, %f8
	subi	%g1, %g1, 12
	call	solver_rect_surface.2767
	addi	%g1, %g1, 12
	jne	%g3, %g0, jeq_else.7898
	addi	%g7, %g0, 1
	addi	%g6, %g0, 2
	addi	%g5, %g0, 0
	ldi	%g4, %g1, 4
	ldi	%g8, %g1, 0
	fmov	%f2, %f8
	fmov	%f3, %f6
	fmov	%f4, %f7
	subi	%g1, %g1, 12
	call	solver_rect_surface.2767
	addi	%g1, %g1, 12
	jne	%g3, %g0, jeq_else.7899
	addi	%g7, %g0, 2
	addi	%g6, %g0, 0
	addi	%g5, %g0, 1
	ldi	%g4, %g1, 4
	ldi	%g8, %g1, 0
	fmov	%f2, %f7
	fmov	%f3, %f8
	fmov	%f4, %f6
	subi	%g1, %g1, 12
	call	solver_rect_surface.2767
	addi	%g1, %g1, 12
	jne	%g3, %g0, jeq_else.7900
	addi	%g3, %g0, 0
	return
jeq_else.7900:
	addi	%g3, %g0, 3
	return
jeq_else.7899:
	addi	%g3, %g0, 2
	return
jeq_else.7898:
	addi	%g3, %g0, 1
	return

!==============================
! args = [%g3, %g4]
! fargs = [%f2, %f1, %f4]
! use_regs = [%g5, %g4, %g3, %g27, %f5, %f4, %f3, %f2, %f16, %f15, %f1, %f0, %dummy]
! ret type = Int
!================================
solver_surface.2782:
	subi	%g1, %g1, 4
	call	o_param_abc.2689
	addi	%g1, %g1, 4
	mov	%g5, %g3
	fsti	%f1, %g1, 0
	fsti	%f2, %g1, 4
	mov	%g3, %g5
	subi	%g1, %g1, 12
	call	veciprod.2648
	fmov	%f5, %f0
	fmov	%f0, %f5
	call	fispos.2526
	addi	%g1, %g1, 12
	jne	%g3, %g0, jeq_else.7901
	addi	%g3, %g0, 0
	return
jeq_else.7901:
	fldi	%f2, %g1, 4
	fldi	%f1, %g1, 0
	mov	%g3, %g5
	fmov	%f0, %f4
	subi	%g1, %g1, 12
	call	veciprod2.2651
	call	fneg.2539
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
quadratic.2788:
	fmov	%f0, %f3
	subi	%g1, %g1, 4
	call	fsqr.2543
	addi	%g1, %g1, 4
	fmov	%f4, %f0
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_a.2683
	fmul	%f5, %f4, %f0
	fmov	%f0, %f2
	call	fsqr.2543
	addi	%g1, %g1, 8
	fmov	%f4, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_b.2685
	fmul	%f0, %f4, %f0
	fadd	%f5, %f5, %f0
	fmov	%f0, %f1
	call	fsqr.2543
	addi	%g1, %g1, 8
	fmov	%f4, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_c.2687
	addi	%g1, %g1, 8
	fmul	%f0, %f4, %f0
	fadd	%f4, %f5, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_isrot.2681
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jne	%g4, %g0, jeq_else.7902
	fmov	%f0, %f4
	return
jeq_else.7902:
	fmul	%f5, %f2, %f1
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r1.2707
	addi	%g1, %g1, 8
	fmul	%f0, %f5, %f0
	fadd	%f4, %f4, %f0
	fmul	%f1, %f1, %f3
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r2.2709
	addi	%g1, %g1, 8
	fmul	%f0, %f1, %f0
	fadd	%f4, %f4, %f0
	fmul	%f1, %f3, %f2
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r3.2711
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
bilinear.2793:
	fmul	%f3, %f5, %f6
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_a.2683
	addi	%g1, %g1, 8
	fmul	%f8, %f3, %f0
	fmul	%f3, %f7, %f4
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_b.2685
	addi	%g1, %g1, 8
	fmul	%f0, %f3, %f0
	fadd	%f8, %f8, %f0
	fmul	%f3, %f2, %f1
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_c.2687
	addi	%g1, %g1, 8
	fmul	%f0, %f3, %f0
	fadd	%f3, %f8, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_isrot.2681
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jne	%g4, %g0, jeq_else.7903
	fmov	%f0, %f3
	return
jeq_else.7903:
	fmul	%f8, %f2, %f4
	fmul	%f0, %f7, %f1
	fadd	%f8, %f8, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r1.2707
	addi	%g1, %g1, 8
	fmul	%f8, %f8, %f0
	fmul	%f1, %f5, %f1
	fmul	%f0, %f2, %f6
	fadd	%f1, %f1, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r2.2709
	addi	%g1, %g1, 8
	fmul	%f0, %f1, %f0
	fadd	%f2, %f8, %f0
	fmul	%f1, %f5, %f4
	fmul	%f0, %f7, %f6
	fadd	%f1, %f1, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r3.2711
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	call	fhalf.2541
	addi	%g1, %g1, 8
	fadd	%f0, %f3, %f0
	return

!==============================
! args = [%g5, %g3]
! fargs = [%f6, %f10, %f1]
! use_regs = [%g5, %g4, %g3, %g27, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f19, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Int
!================================
solver_second.2801:
	fldi	%f12, %g3, 0
	fldi	%f7, %g3, -4
	fldi	%f11, %g3, -8
	fsti	%f1, %g1, 0
	mov	%g3, %g5
	fmov	%f1, %f11
	fmov	%f2, %f7
	fmov	%f3, %f12
	subi	%g1, %g1, 8
	call	quadratic.2788
	fmov	%f9, %f0
	fmov	%f0, %f9
	call	fiszero.2530
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7904
	fldi	%f1, %g1, 0
	fsti	%f6, %g1, 4
	mov	%g3, %g5
	fmov	%f4, %f10
	fmov	%f2, %f11
	fmov	%f5, %f12
	subi	%g1, %g1, 12
	call	bilinear.2793
	addi	%g1, %g1, 12
	fmov	%f7, %f0
	fldi	%f6, %g1, 4
	fldi	%f1, %g1, 0
	mov	%g3, %g5
	fmov	%f2, %f10
	fmov	%f3, %f6
	subi	%g1, %g1, 12
	call	quadratic.2788
	mov	%g3, %g5
	call	o_form.2675
	addi	%g1, %g1, 12
	addi	%g4, %g0, 3
	jne	%g3, %g4, jeq_else.7905
	fsub	%f1, %f0, %f17
	jmp	jeq_cont.7906
jeq_else.7905:
	fmov	%f1, %f0
jeq_cont.7906:
	fmov	%f0, %f7
	subi	%g1, %g1, 12
	call	fsqr.2543
	addi	%g1, %g1, 12
	fmul	%f1, %f9, %f1
	fsub	%f0, %f0, %f1
	fsti	%f0, %g1, 8
	subi	%g1, %g1, 16
	call	fispos.2526
	addi	%g1, %g1, 16
	jne	%g3, %g0, jeq_else.7907
	addi	%g3, %g0, 0
	return
jeq_else.7907:
	fldi	%f0, %g1, 8
	fsqrt	%f1, %f0
	mov	%g3, %g5
	subi	%g1, %g1, 16
	call	o_isinvert.2679
	addi	%g1, %g1, 16
	jne	%g3, %g0, jeq_else.7908
	fmov	%f0, %f1
	subi	%g1, %g1, 16
	call	fneg.2539
	addi	%g1, %g1, 16
	jmp	jeq_cont.7909
jeq_else.7908:
	fmov	%f0, %f1
jeq_cont.7909:
	fsub	%f0, %f0, %f7
	fdiv	%f0, %f0, %f9
	fsti	%f0, %g31, 520
	addi	%g3, %g0, 1
	return
jeq_else.7904:
	addi	%g3, %g0, 0
	return

!==============================
! args = [%g3, %g8, %g4]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f19, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Int
!================================
solver.2807:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g10, %g3, 272
	fldi	%f1, %g4, 0
	mov	%g3, %g10
	subi	%g1, %g1, 4
	call	o_param_x.2691
	fsub	%f8, %f1, %f0
	fldi	%f1, %g4, -4
	mov	%g3, %g10
	call	o_param_y.2693
	fsub	%f10, %f1, %f0
	fldi	%f1, %g4, -8
	mov	%g3, %g10
	call	o_param_z.2695
	fsub	%f6, %f1, %f0
	mov	%g3, %g10
	call	o_form.2675
	addi	%g1, %g1, 4
	mov	%g4, %g3
	jne	%g4, %g28, jeq_else.7910
	mov	%g4, %g10
	fmov	%f7, %f10
	jmp	solver_rect.2776
jeq_else.7910:
	addi	%g3, %g0, 2
	jne	%g4, %g3, jeq_else.7911
	mov	%g4, %g8
	mov	%g3, %g10
	fmov	%f4, %f6
	fmov	%f1, %f10
	fmov	%f2, %f8
	jmp	solver_surface.2782
jeq_else.7911:
	mov	%g3, %g8
	mov	%g5, %g10
	fmov	%f1, %f6
	fmov	%f6, %f8
	jmp	solver_second.2801

!==============================
! args = [%g6, %g4, %g5]
! fargs = [%f4, %f6, %f3]
! use_regs = [%g6, %g5, %g4, %g3, %g27, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f16, %f15, %f1, %f0, %dummy]
! ret type = Int
!================================
solver_rect_fast.2811:
	fldi	%f0, %g5, 0
	fsub	%f0, %f0, %f4
	fldi	%f2, %g5, -4
	fmul	%f7, %f0, %f2
	fldi	%f0, %g4, -4
	fmul	%f0, %f7, %f0
	fadd	%f1, %f0, %f6
	subi	%g1, %g1, 4
	call	fabs.2535
	fmov	%f1, %f0
	mov	%g3, %g6
	call	o_param_b.2685
	fmov	%f5, %f0
	fmov	%f0, %f5
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7912
	addi	%g3, %g0, 0
	jmp	jeq_cont.7913
jeq_else.7912:
	fldi	%f0, %g4, -8
	fmul	%f0, %f7, %f0
	fadd	%f1, %f0, %f3
	subi	%g1, %g1, 4
	call	fabs.2535
	fmov	%f1, %f0
	mov	%g3, %g6
	call	o_param_c.2687
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7914
	addi	%g3, %g0, 0
	jmp	jeq_cont.7915
jeq_else.7914:
	fmov	%f0, %f2
	subi	%g1, %g1, 4
	call	fiszero.2530
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7916
	addi	%g3, %g0, 1
	jmp	jeq_cont.7917
jeq_else.7916:
	addi	%g3, %g0, 0
jeq_cont.7917:
jeq_cont.7915:
jeq_cont.7913:
	jne	%g3, %g0, jeq_else.7918
	fldi	%f0, %g5, -8
	fsub	%f0, %f0, %f6
	fldi	%f7, %g5, -12
	fmul	%f8, %f0, %f7
	fldi	%f0, %g4, 0
	fmul	%f0, %f8, %f0
	fadd	%f1, %f0, %f4
	subi	%g1, %g1, 4
	call	fabs.2535
	fmov	%f1, %f0
	mov	%g3, %g6
	call	o_param_a.2683
	fmov	%f2, %f0
	fmov	%f0, %f2
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7919
	addi	%g3, %g0, 0
	jmp	jeq_cont.7920
jeq_else.7919:
	fldi	%f0, %g4, -8
	fmul	%f0, %f8, %f0
	fadd	%f1, %f0, %f3
	subi	%g1, %g1, 4
	call	fabs.2535
	fmov	%f1, %f0
	mov	%g3, %g6
	call	o_param_c.2687
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7921
	addi	%g3, %g0, 0
	jmp	jeq_cont.7922
jeq_else.7921:
	fmov	%f0, %f7
	subi	%g1, %g1, 4
	call	fiszero.2530
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7923
	addi	%g3, %g0, 1
	jmp	jeq_cont.7924
jeq_else.7923:
	addi	%g3, %g0, 0
jeq_cont.7924:
jeq_cont.7922:
jeq_cont.7920:
	jne	%g3, %g0, jeq_else.7925
	fldi	%f0, %g5, -16
	fsub	%f0, %f0, %f3
	fldi	%f3, %g5, -20
	fmul	%f7, %f0, %f3
	fldi	%f0, %g4, 0
	fmul	%f0, %f7, %f0
	fadd	%f1, %f0, %f4
	subi	%g1, %g1, 4
	call	fabs.2535
	fmov	%f1, %f0
	fmov	%f0, %f2
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7926
	addi	%g3, %g0, 0
	jmp	jeq_cont.7927
jeq_else.7926:
	fldi	%f0, %g4, -4
	fmul	%f0, %f7, %f0
	fadd	%f1, %f0, %f6
	subi	%g1, %g1, 4
	call	fabs.2535
	fmov	%f1, %f0
	fmov	%f0, %f5
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7928
	addi	%g3, %g0, 0
	jmp	jeq_cont.7929
jeq_else.7928:
	fmov	%f0, %f3
	subi	%g1, %g1, 4
	call	fiszero.2530
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7930
	addi	%g3, %g0, 1
	jmp	jeq_cont.7931
jeq_else.7930:
	addi	%g3, %g0, 0
jeq_cont.7931:
jeq_cont.7929:
jeq_cont.7927:
	jne	%g3, %g0, jeq_else.7932
	addi	%g3, %g0, 0
	return
jeq_else.7932:
	fsti	%f7, %g31, 520
	addi	%g3, %g0, 3
	return
jeq_else.7925:
	fsti	%f8, %g31, 520
	addi	%g3, %g0, 2
	return
jeq_else.7918:
	fsti	%f7, %g31, 520
	addi	%g3, %g0, 1
	return

!==============================
! args = [%g3, %g4]
! fargs = [%f3, %f2, %f1]
! use_regs = [%g4, %g3, %g27, %f3, %f2, %f16, %f15, %f1, %f0, %dummy]
! ret type = Int
!================================
solver_surface_fast.2818:
	fldi	%f0, %g4, 0
	subi	%g1, %g1, 4
	call	fisneg.2528
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7933
	addi	%g3, %g0, 0
	return
jeq_else.7933:
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
solver_second_fast.2824:
	fldi	%f7, %g5, 0
	fmov	%f0, %f7
	subi	%g1, %g1, 4
	call	fiszero.2530
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7934
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
	call	quadratic.2788
	mov	%g3, %g6
	call	o_form.2675
	addi	%g1, %g1, 4
	addi	%g4, %g0, 3
	jne	%g3, %g4, jeq_else.7935
	fsub	%f1, %f0, %f17
	jmp	jeq_cont.7936
jeq_else.7935:
	fmov	%f1, %f0
jeq_cont.7936:
	fmov	%f0, %f6
	subi	%g1, %g1, 4
	call	fsqr.2543
	addi	%g1, %g1, 4
	fmul	%f1, %f7, %f1
	fsub	%f0, %f0, %f1
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fispos.2526
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7937
	addi	%g3, %g0, 0
	return
jeq_else.7937:
	mov	%g3, %g6
	subi	%g1, %g1, 8
	call	o_isinvert.2679
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7938
	fldi	%f0, %g1, 0
	fsqrt	%f0, %f0
	fsub	%f1, %f6, %f0
	fldi	%f0, %g5, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g31, 520
	jmp	jeq_cont.7939
jeq_else.7938:
	fldi	%f0, %g1, 0
	fsqrt	%f0, %f0
	fadd	%f1, %f6, %f0
	fldi	%f0, %g5, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g31, 520
jeq_cont.7939:
	addi	%g3, %g0, 1
	return
jeq_else.7934:
	addi	%g3, %g0, 0
	return

!==============================
! args = [%g5, %g7, %g4]
! fargs = []
! use_regs = [%g7, %g6, %g5, %g4, %g3, %g27, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Int
!================================
solver_fast.2830:
	slli	%g3, %g5, 2
	add	%g3, %g31, %g3
	ldi	%g6, %g3, 272
	fldi	%f1, %g4, 0
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	o_param_x.2691
	fsub	%f3, %f1, %f0
	fldi	%f1, %g4, -4
	mov	%g3, %g6
	call	o_param_y.2693
	fsub	%f2, %f1, %f0
	fldi	%f1, %g4, -8
	mov	%g3, %g6
	call	o_param_z.2695
	fsub	%f1, %f1, %f0
	mov	%g3, %g7
	call	d_const.2736
	slli	%g4, %g5, 2
	ld	%g5, %g3, %g4
	mov	%g3, %g6
	call	o_form.2675
	addi	%g1, %g1, 4
	mov	%g4, %g3
	jne	%g4, %g28, jeq_else.7940
	mov	%g3, %g7
	subi	%g1, %g1, 4
	call	d_vec.2734
	addi	%g1, %g1, 4
	mov	%g4, %g3
	fmov	%f6, %f2
	fmov	%f4, %f3
	fmov	%f3, %f1
	jmp	solver_rect_fast.2811
jeq_else.7940:
	addi	%g3, %g0, 2
	jne	%g4, %g3, jeq_else.7941
	mov	%g4, %g5
	mov	%g3, %g6
	jmp	solver_surface_fast.2818
jeq_else.7941:
	jmp	solver_second_fast.2824

!==============================
! args = [%g3, %g5, %g4]
! fargs = [%f2, %f1, %f0]
! use_regs = [%g5, %g4, %g3, %g27, %f2, %f16, %f15, %f1, %f0, %dummy]
! ret type = Int
!================================
solver_surface_fast2.2834:
	fldi	%f0, %g5, 0
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fisneg.2528
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7942
	addi	%g3, %g0, 0
	return
jeq_else.7942:
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
solver_second_fast2.2841:
	fldi	%f4, %g5, 0
	fmov	%f0, %f4
	subi	%g1, %g1, 4
	call	fiszero.2530
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7943
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
	call	fsqr.2543
	addi	%g1, %g1, 4
	fmul	%f2, %f4, %f2
	fsub	%f0, %f0, %f2
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fispos.2526
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7944
	addi	%g3, %g0, 0
	return
jeq_else.7944:
	mov	%g3, %g6
	subi	%g1, %g1, 8
	call	o_isinvert.2679
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7945
	fldi	%f0, %g1, 0
	fsqrt	%f0, %f0
	fsub	%f1, %f1, %f0
	fldi	%f0, %g5, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g31, 520
	jmp	jeq_cont.7946
jeq_else.7945:
	fldi	%f0, %g1, 0
	fsqrt	%f0, %f0
	fadd	%f1, %f1, %f0
	fldi	%f0, %g5, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g31, 520
jeq_cont.7946:
	addi	%g3, %g0, 1
	return
jeq_else.7943:
	addi	%g3, %g0, 0
	return

!==============================
! args = [%g4, %g5]
! fargs = []
! use_regs = [%g8, %g7, %g6, %g5, %g4, %g3, %g27, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f16, %f15, %f1, %f0, %dummy]
! ret type = Int
!================================
solver_fast2.2848:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g6, %g3, 272
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	o_param_ctbl.2713
	mov	%g8, %g3
	fldi	%f4, %g8, 0
	fldi	%f6, %g8, -4
	fldi	%f3, %g8, -8
	mov	%g3, %g5
	call	d_const.2736
	slli	%g4, %g4, 2
	ld	%g7, %g3, %g4
	mov	%g3, %g6
	call	o_form.2675
	addi	%g1, %g1, 4
	mov	%g4, %g3
	jne	%g4, %g28, jeq_else.7947
	mov	%g3, %g5
	subi	%g1, %g1, 4
	call	d_vec.2734
	addi	%g1, %g1, 4
	mov	%g4, %g3
	mov	%g5, %g7
	jmp	solver_rect_fast.2811
jeq_else.7947:
	addi	%g3, %g0, 2
	jne	%g4, %g3, jeq_else.7948
	mov	%g4, %g8
	mov	%g5, %g7
	mov	%g3, %g6
	fmov	%f0, %f3
	fmov	%f1, %f6
	fmov	%f2, %f4
	jmp	solver_surface_fast2.2834
jeq_else.7948:
	mov	%g4, %g8
	mov	%g5, %g7
	fmov	%f1, %f3
	fmov	%f2, %f6
	fmov	%f3, %f4
	jmp	solver_second_fast2.2841

!==============================
! args = [%g5, %g6]
! fargs = []
! use_regs = [%g7, %g6, %g5, %g4, %g3, %g27, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Array(Float)
!================================
setup_rect_table.2851:
	addi	%g3, %g0, 6
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	fldi	%f0, %g5, 0
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	fiszero.2530
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jne	%g4, %g0, jeq_else.7949
	mov	%g3, %g6
	subi	%g1, %g1, 8
	call	o_isinvert.2679
	mov	%g4, %g3
	fldi	%f0, %g5, 0
	call	fisneg.2528
	mov	%g7, %g3
	mov	%g3, %g7
	call	xor.2532
	mov	%g4, %g3
	mov	%g3, %g6
	call	o_param_a.2683
	fmov	%f1, %f0
	mov	%g3, %g4
	call	fneg_cond.2621
	addi	%g1, %g1, 8
	ldi	%g3, %g1, 0
	fsti	%f0, %g3, 0
	fldi	%f0, %g5, 0
	fdiv	%f0, %f17, %f0
	fsti	%f0, %g3, -4
	jmp	jeq_cont.7950
jeq_else.7949:
	ldi	%g3, %g1, 0
	fsti	%f16, %g3, -4
jeq_cont.7950:
	fldi	%f0, %g5, -4
	subi	%g1, %g1, 8
	call	fiszero.2530
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jne	%g4, %g0, jeq_else.7951
	mov	%g3, %g6
	subi	%g1, %g1, 8
	call	o_isinvert.2679
	mov	%g4, %g3
	fldi	%f0, %g5, -4
	call	fisneg.2528
	mov	%g7, %g3
	mov	%g3, %g7
	call	xor.2532
	mov	%g4, %g3
	mov	%g3, %g6
	call	o_param_b.2685
	fmov	%f1, %f0
	mov	%g3, %g4
	call	fneg_cond.2621
	addi	%g1, %g1, 8
	ldi	%g3, %g1, 0
	fsti	%f0, %g3, -8
	fldi	%f0, %g5, -4
	fdiv	%f0, %f17, %f0
	fsti	%f0, %g3, -12
	jmp	jeq_cont.7952
jeq_else.7951:
	ldi	%g3, %g1, 0
	fsti	%f16, %g3, -12
jeq_cont.7952:
	fldi	%f0, %g5, -8
	subi	%g1, %g1, 8
	call	fiszero.2530
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jne	%g4, %g0, jeq_else.7953
	mov	%g3, %g6
	subi	%g1, %g1, 8
	call	o_isinvert.2679
	mov	%g4, %g3
	fldi	%f0, %g5, -8
	call	fisneg.2528
	mov	%g7, %g3
	mov	%g3, %g7
	call	xor.2532
	mov	%g4, %g3
	mov	%g3, %g6
	call	o_param_c.2687
	fmov	%f1, %f0
	mov	%g3, %g4
	call	fneg_cond.2621
	addi	%g1, %g1, 8
	ldi	%g3, %g1, 0
	fsti	%f0, %g3, -16
	fldi	%f0, %g5, -8
	fdiv	%f0, %f17, %f0
	fsti	%f0, %g3, -20
	jmp	jeq_cont.7954
jeq_else.7953:
	ldi	%g3, %g1, 0
	fsti	%f16, %g3, -20
jeq_cont.7954:
	return

!==============================
! args = [%g5, %g6]
! fargs = []
! use_regs = [%g6, %g5, %g4, %g3, %g27, %f5, %f4, %f3, %f21, %f2, %f16, %f15, %f1, %f0, %dummy]
! ret type = Array(Float)
!================================
setup_surface_table.2854:
	addi	%g3, %g0, 4
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	fldi	%f1, %g5, 0
	sti	%g3, %g1, 0
	mov	%g3, %g6
	subi	%g1, %g1, 8
	call	o_param_a.2683
	fmov	%f4, %f0
	fmul	%f2, %f1, %f4
	fldi	%f1, %g5, -4
	mov	%g3, %g6
	call	o_param_b.2685
	fmov	%f3, %f0
	fmul	%f0, %f1, %f3
	fadd	%f5, %f2, %f0
	fldi	%f1, %g5, -8
	mov	%g3, %g6
	call	o_param_c.2687
	fmov	%f2, %f0
	fmul	%f0, %f1, %f2
	fadd	%f1, %f5, %f0
	fmov	%f0, %f1
	call	fispos.2526
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jne	%g4, %g0, jeq_else.7955
	ldi	%g3, %g1, 0
	fsti	%f16, %g3, 0
	jmp	jeq_cont.7956
jeq_else.7955:
	fdiv	%f0, %f21, %f1
	ldi	%g3, %g1, 0
	fsti	%f0, %g3, 0
	fdiv	%f0, %f4, %f1
	subi	%g1, %g1, 8
	call	fneg.2539
	fsti	%f0, %g3, -4
	fdiv	%f0, %f3, %f1
	call	fneg.2539
	fsti	%f0, %g3, -8
	fdiv	%f0, %f2, %f1
	call	fneg.2539
	addi	%g1, %g1, 8
	fsti	%f0, %g3, -12
jeq_cont.7956:
	return

!==============================
! args = [%g5, %g6]
! fargs = []
! use_regs = [%g6, %g5, %g4, %g3, %g27, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f19, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Array(Float)
!================================
setup_second_table.2857:
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
	call	quadratic.2788
	fmov	%f5, %f0
	mov	%g3, %g6
	call	o_param_a.2683
	addi	%g1, %g1, 16
	fldi	%f3, %g1, 8
	fmul	%f0, %f3, %f0
	subi	%g1, %g1, 16
	call	fneg.2539
	fmov	%f1, %f0
	mov	%g3, %g6
	call	o_param_b.2685
	addi	%g1, %g1, 16
	fldi	%f2, %g1, 4
	fmul	%f0, %f2, %f0
	subi	%g1, %g1, 16
	call	fneg.2539
	fmov	%f2, %f0
	mov	%g3, %g6
	call	o_param_c.2687
	fmul	%f0, %f6, %f0
	call	fneg.2539
	addi	%g1, %g1, 16
	fmov	%f4, %f0
	ldi	%g3, %g1, 0
	fsti	%f5, %g3, 0
	mov	%g3, %g6
	subi	%g1, %g1, 16
	call	o_isrot.2681
	addi	%g1, %g1, 16
	mov	%g4, %g3
	jne	%g4, %g0, jeq_else.7957
	ldi	%g3, %g1, 0
	fsti	%f1, %g3, -4
	fsti	%f2, %g3, -8
	fsti	%f4, %g3, -12
	jmp	jeq_cont.7958
jeq_else.7957:
	fldi	%f6, %g5, -8
	mov	%g3, %g6
	subi	%g1, %g1, 16
	call	o_param_r2.2709
	fmov	%f3, %f0
	fmul	%f8, %f6, %f3
	fldi	%f7, %g5, -4
	mov	%g3, %g6
	call	o_param_r3.2711
	fmov	%f6, %f0
	fmul	%f0, %f7, %f6
	fadd	%f0, %f8, %f0
	call	fhalf.2541
	addi	%g1, %g1, 16
	fsub	%f0, %f1, %f0
	ldi	%g3, %g1, 0
	fsti	%f0, %g3, -4
	fldi	%f7, %g5, -8
	mov	%g3, %g6
	subi	%g1, %g1, 16
	call	o_param_r1.2707
	fmov	%f1, %f0
	fmul	%f7, %f7, %f1
	fldi	%f0, %g5, 0
	fmul	%f0, %f0, %f6
	fadd	%f0, %f7, %f0
	call	fhalf.2541
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
	call	fhalf.2541
	addi	%g1, %g1, 16
	fsub	%f0, %f4, %f0
	fsti	%f0, %g3, -12
jeq_cont.7958:
	fmov	%f0, %f5
	subi	%g1, %g1, 16
	call	fiszero.2530
	addi	%g1, %g1, 16
	mov	%g4, %g3
	jne	%g4, %g0, jeq_else.7959
	fdiv	%f0, %f17, %f5
	ldi	%g3, %g1, 0
	fsti	%f0, %g3, -16
	jmp	jeq_cont.7960
jeq_else.7959:
jeq_cont.7960:
	ldi	%g3, %g1, 0
	return

!==============================
! args = [%g9, %g8]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g10, %f8, %f7, %f6, %f5, %f4, %f3, %f21, %f2, %f19, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
iter_setup_dirvec_constants.2860:
	jlt	%g8, %g0, jge_else.7961
	slli	%g3, %g8, 2
	add	%g3, %g31, %g3
	ldi	%g6, %g3, 272
	mov	%g3, %g9
	subi	%g1, %g1, 4
	call	d_const.2736
	mov	%g10, %g3
	mov	%g3, %g9
	call	d_vec.2734
	mov	%g5, %g3
	mov	%g3, %g6
	call	o_form.2675
	addi	%g1, %g1, 4
	jne	%g3, %g28, jeq_else.7962
	subi	%g1, %g1, 4
	call	setup_rect_table.2851
	addi	%g1, %g1, 4
	slli	%g4, %g8, 2
	st	%g3, %g10, %g4
	jmp	jeq_cont.7963
jeq_else.7962:
	addi	%g4, %g0, 2
	jne	%g3, %g4, jeq_else.7964
	subi	%g1, %g1, 4
	call	setup_surface_table.2854
	addi	%g1, %g1, 4
	slli	%g4, %g8, 2
	st	%g3, %g10, %g4
	jmp	jeq_cont.7965
jeq_else.7964:
	subi	%g1, %g1, 4
	call	setup_second_table.2857
	addi	%g1, %g1, 4
	slli	%g4, %g8, 2
	st	%g3, %g10, %g4
jeq_cont.7965:
jeq_cont.7963:
	subi	%g8, %g8, 1
	jmp	iter_setup_dirvec_constants.2860
jge_else.7961:
	return

!==============================
! args = [%g9]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g10, %f8, %f7, %f6, %f5, %f4, %f3, %f21, %f2, %f19, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
setup_dirvec_constants.2863:
	ldi	%g3, %g31, 28
	subi	%g8, %g3, 1
	jmp	iter_setup_dirvec_constants.2860

!==============================
! args = [%g6, %g5]
! fargs = []
! use_regs = [%g8, %g7, %g6, %g5, %g4, %g3, %g27, %f5, %f4, %f3, %f2, %f17, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
setup_startp_constants.2865:
	jlt	%g5, %g0, jge_else.7967
	slli	%g3, %g5, 2
	add	%g3, %g31, %g3
	ldi	%g3, %g3, 272
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_ctbl.2713
	addi	%g1, %g1, 8
	mov	%g7, %g3
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_form.2675
	addi	%g1, %g1, 8
	mov	%g8, %g3
	fldi	%f1, %g6, 0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_x.2691
	addi	%g1, %g1, 8
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, 0
	fldi	%f1, %g6, -4
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_y.2693
	addi	%g1, %g1, 8
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, -4
	fldi	%f1, %g6, -8
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_z.2695
	addi	%g1, %g1, 8
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, -8
	addi	%g4, %g0, 2
	jne	%g8, %g4, jeq_else.7968
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_abc.2689
	fldi	%f2, %g7, 0
	fldi	%f1, %g7, -4
	fldi	%f0, %g7, -8
	call	veciprod2.2651
	addi	%g1, %g1, 8
	fsti	%f0, %g7, -12
	jmp	jeq_cont.7969
jeq_else.7968:
	addi	%g4, %g0, 2
	jlt	%g4, %g8, jle_else.7970
	jmp	jle_cont.7971
jle_else.7970:
	fldi	%f3, %g7, 0
	fldi	%f2, %g7, -4
	fldi	%f1, %g7, -8
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	quadratic.2788
	addi	%g1, %g1, 8
	addi	%g3, %g0, 3
	jne	%g8, %g3, jeq_else.7972
	fsub	%f1, %f0, %f17
	jmp	jeq_cont.7973
jeq_else.7972:
	fmov	%f1, %f0
jeq_cont.7973:
	fsti	%f1, %g7, -12
jle_cont.7971:
jeq_cont.7969:
	subi	%g5, %g5, 1
	jmp	setup_startp_constants.2865
jge_else.7967:
	return

!==============================
! args = [%g6]
! fargs = []
! use_regs = [%g8, %g7, %g6, %g5, %g4, %g3, %g27, %f5, %f4, %f3, %f2, %f17, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
setup_startp.2868:
	subi	%g4, %g31, 636
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	veccpy.2637
	addi	%g1, %g1, 4
	ldi	%g3, %g31, 28
	subi	%g5, %g3, 1
	jmp	setup_startp_constants.2865

!==============================
! args = [%g4]
! fargs = [%f1, %f3, %f2]
! use_regs = [%g4, %g3, %g27, %f3, %f2, %f16, %f15, %f1, %f0]
! ret type = Bool
!================================
is_rect_outside.2870:
	subi	%g1, %g1, 4
	call	fabs.2535
	fmov	%f1, %f0
	mov	%g3, %g4
	call	o_param_a.2683
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7975
	addi	%g3, %g0, 0
	jmp	jeq_cont.7976
jeq_else.7975:
	fmov	%f1, %f3
	subi	%g1, %g1, 4
	call	fabs.2535
	fmov	%f1, %f0
	mov	%g3, %g4
	call	o_param_b.2685
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7977
	addi	%g3, %g0, 0
	jmp	jeq_cont.7978
jeq_else.7977:
	fmov	%f1, %f2
	subi	%g1, %g1, 4
	call	fabs.2535
	fmov	%f1, %f0
	mov	%g3, %g4
	call	o_param_c.2687
	call	fless.2523
	addi	%g1, %g1, 4
jeq_cont.7978:
jeq_cont.7976:
	jne	%g3, %g0, jeq_else.7979
	mov	%g3, %g4
	subi	%g1, %g1, 4
	call	o_isinvert.2679
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7980
	addi	%g3, %g0, 1
	return
jeq_else.7980:
	addi	%g3, %g0, 0
	return
jeq_else.7979:
	mov	%g3, %g4
	jmp	o_isinvert.2679

!==============================
! args = [%g3]
! fargs = [%f2, %f1, %f0]
! use_regs = [%g4, %g3, %g27, %f3, %f2, %f16, %f15, %f1, %f0]
! ret type = Bool
!================================
is_plane_outside.2875:
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_abc.2689
	mov	%g4, %g3
	mov	%g3, %g4
	call	veciprod2.2651
	addi	%g1, %g1, 8
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_isinvert.2679
	mov	%g4, %g3
	call	fisneg.2528
	call	xor.2532
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7981
	addi	%g3, %g0, 1
	return
jeq_else.7981:
	addi	%g3, %g0, 0
	return

!==============================
! args = [%g3]
! fargs = [%f3, %f2, %f1]
! use_regs = [%g5, %g4, %g3, %g27, %f5, %f4, %f3, %f2, %f17, %f16, %f15, %f1, %f0]
! ret type = Bool
!================================
is_second_outside.2880:
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	quadratic.2788
	addi	%g1, %g1, 8
	fmov	%f1, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_form.2675
	addi	%g1, %g1, 8
	mov	%g4, %g3
	addi	%g5, %g0, 3
	jne	%g4, %g5, jeq_else.7982
	fsub	%f0, %f1, %f17
	jmp	jeq_cont.7983
jeq_else.7982:
	fmov	%f0, %f1
jeq_cont.7983:
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_isinvert.2679
	mov	%g4, %g3
	call	fisneg.2528
	call	xor.2532
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.7984
	addi	%g3, %g0, 1
	return
jeq_else.7984:
	addi	%g3, %g0, 0
	return

!==============================
! args = [%g6]
! fargs = [%f3, %f2, %f1]
! use_regs = [%g6, %g5, %g4, %g3, %g27, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f17, %f16, %f15, %f1, %f0]
! ret type = Bool
!================================
is_outside.2885:
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	o_param_x.2691
	fsub	%f8, %f3, %f0
	mov	%g3, %g6
	call	o_param_y.2693
	fsub	%f7, %f2, %f0
	mov	%g3, %g6
	call	o_param_z.2695
	fsub	%f6, %f1, %f0
	mov	%g3, %g6
	call	o_form.2675
	addi	%g1, %g1, 4
	mov	%g4, %g3
	jne	%g4, %g28, jeq_else.7985
	mov	%g4, %g6
	fmov	%f2, %f6
	fmov	%f3, %f7
	fmov	%f1, %f8
	jmp	is_rect_outside.2870
jeq_else.7985:
	addi	%g3, %g0, 2
	jne	%g4, %g3, jeq_else.7986
	mov	%g3, %g6
	fmov	%f0, %f6
	fmov	%f1, %f7
	fmov	%f2, %f8
	jmp	is_plane_outside.2875
jeq_else.7986:
	mov	%g3, %g6
	fmov	%f1, %f6
	fmov	%f2, %f7
	fmov	%f3, %f8
	jmp	is_second_outside.2880

!==============================
! args = [%g7, %g8]
! fargs = [%f3, %f2, %f1]
! use_regs = [%g8, %g7, %g6, %g5, %g4, %g3, %g27, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f17, %f16, %f15, %f1, %f0]
! ret type = Bool
!================================
check_all_inside.2890:
	slli	%g3, %g7, 2
	ld	%g4, %g8, %g3
	jne	%g4, %g29, jeq_else.7987
	addi	%g3, %g0, 1
	return
jeq_else.7987:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g6, %g3, 272
	fsti	%f1, %g1, 0
	fsti	%f2, %g1, 4
	fsti	%f3, %g1, 8
	subi	%g1, %g1, 16
	call	is_outside.2885
	addi	%g1, %g1, 16
	jne	%g3, %g0, jeq_else.7988
	addi	%g7, %g7, 1
	fldi	%f3, %g1, 8
	fldi	%f2, %g1, 4
	fldi	%f1, %g1, 0
	jmp	check_all_inside.2890
jeq_else.7988:
	addi	%g3, %g0, 0
	return

!==============================
! args = [%g9, %g8]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %f8, %f7, %f6, %f5, %f4, %f3, %f25, %f2, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Bool
!================================
shadow_check_and_group.2896:
	slli	%g3, %g9, 2
	ld	%g5, %g8, %g3
	jne	%g5, %g29, jeq_else.7989
	addi	%g3, %g0, 0
	return
jeq_else.7989:
	subi	%g4, %g31, 540
	subi	%g7, %g31, 980
	sti	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	solver_fast.2830
	addi	%g1, %g1, 8
	fldi	%f1, %g31, 520
	fsti	%f1, %g1, 4
	jne	%g3, %g0, jeq_else.7990
	addi	%g3, %g0, 0
	jmp	jeq_cont.7991
jeq_else.7990:
	setL %g3, l.6948
	fldi	%f0, %g3, 0
	subi	%g1, %g1, 12
	call	fless.2523
	addi	%g1, %g1, 12
jeq_cont.7991:
	jne	%g3, %g0, jeq_else.7992
	ldi	%g5, %g1, 0
	slli	%g3, %g5, 2
	add	%g3, %g31, %g3
	ldi	%g3, %g3, 272
	subi	%g1, %g1, 12
	call	o_isinvert.2679
	addi	%g1, %g1, 12
	jne	%g3, %g0, jeq_else.7993
	addi	%g3, %g0, 0
	return
jeq_else.7993:
	addi	%g9, %g9, 1
	jmp	shadow_check_and_group.2896
jeq_else.7992:
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
	call	check_all_inside.2890
	addi	%g1, %g1, 16
	jne	%g3, %g0, jeq_else.7994
	addi	%g9, %g9, 1
	ldi	%g8, %g1, 8
	jmp	shadow_check_and_group.2896
jeq_else.7994:
	addi	%g3, %g0, 1
	return

!==============================
! args = [%g10, %g11]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g11, %g10, %f8, %f7, %f6, %f5, %f4, %f3, %f25, %f2, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Bool
!================================
shadow_check_one_or_group.2899:
	slli	%g3, %g10, 2
	ld	%g4, %g11, %g3
	jne	%g4, %g29, jeq_else.7995
	addi	%g3, %g0, 0
	return
jeq_else.7995:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g8, %g3, 512
	addi	%g9, %g0, 0
	subi	%g1, %g1, 4
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.7996
	addi	%g10, %g10, 1
	jmp	shadow_check_one_or_group.2899
jeq_else.7996:
	addi	%g3, %g0, 1
	return

!==============================
! args = [%g12, %g13]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g13, %g12, %g11, %g10, %f8, %f7, %f6, %f5, %f4, %f3, %f25, %f24, %f2, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Bool
!================================
shadow_check_one_or_matrix.2902:
	slli	%g3, %g12, 2
	ld	%g11, %g13, %g3
	ldi	%g5, %g11, 0
	jne	%g5, %g29, jeq_else.7997
	addi	%g3, %g0, 0
	return
jeq_else.7997:
	addi	%g3, %g0, 99
	sti	%g11, %g1, 0
	jne	%g5, %g3, jeq_else.7998
	addi	%g3, %g0, 1
	jmp	jeq_cont.7999
jeq_else.7998:
	subi	%g4, %g31, 540
	subi	%g7, %g31, 980
	subi	%g1, %g1, 8
	call	solver_fast.2830
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.8000
	addi	%g3, %g0, 0
	jmp	jeq_cont.8001
jeq_else.8000:
	fldi	%f1, %g31, 520
	fmov	%f0, %f24
	subi	%g1, %g1, 8
	call	fless.2523
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.8002
	addi	%g3, %g0, 0
	jmp	jeq_cont.8003
jeq_else.8002:
	addi	%g10, %g0, 1
	subi	%g1, %g1, 8
	call	shadow_check_one_or_group.2899
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.8004
	addi	%g3, %g0, 0
	jmp	jeq_cont.8005
jeq_else.8004:
	addi	%g3, %g0, 1
jeq_cont.8005:
jeq_cont.8003:
jeq_cont.8001:
jeq_cont.7999:
	jne	%g3, %g0, jeq_else.8006
	addi	%g12, %g12, 1
	jmp	shadow_check_one_or_matrix.2902
jeq_else.8006:
	addi	%g10, %g0, 1
	ldi	%g11, %g1, 0
	subi	%g1, %g1, 8
	call	shadow_check_one_or_group.2899
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.8007
	addi	%g12, %g12, 1
	jmp	shadow_check_one_or_matrix.2902
jeq_else.8007:
	addi	%g3, %g0, 1
	return

!==============================
! args = [%g11, %g14, %g13]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f25, %f2, %f19, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
solve_each_element.2905:
	slli	%g3, %g11, 2
	ld	%g12, %g14, %g3
	jne	%g12, %g29, jeq_else.8008
	return
jeq_else.8008:
	subi	%g4, %g31, 624
	mov	%g8, %g13
	mov	%g3, %g12
	subi	%g1, %g1, 4
	call	solver.2807
	addi	%g1, %g1, 4
	mov	%g9, %g3
	jne	%g9, %g0, jeq_else.8010
	slli	%g3, %g12, 2
	add	%g3, %g31, %g3
	ldi	%g3, %g3, 272
	subi	%g1, %g1, 4
	call	o_isinvert.2679
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.8011
	return
jeq_else.8011:
	addi	%g11, %g11, 1
	jmp	solve_each_element.2905
jeq_else.8010:
	fldi	%f2, %g31, 520
	fmov	%f0, %f2
	fmov	%f1, %f16
	subi	%g1, %g1, 4
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.8013
	jmp	jeq_cont.8014
jeq_else.8013:
	fldi	%f0, %g31, 528
	fmov	%f1, %f2
	subi	%g1, %g1, 4
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.8015
	jmp	jeq_cont.8016
jeq_else.8015:
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
	call	check_all_inside.2890
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.8017
	jmp	jeq_cont.8018
jeq_else.8017:
	fsti	%f11, %g31, 528
	subi	%g3, %g31, 540
	fldi	%f3, %g1, 0
	fmov	%f0, %f9
	fmov	%f1, %f10
	fmov	%f2, %f3
	subi	%g1, %g1, 8
	call	vecset.2627
	addi	%g1, %g1, 8
	sti	%g12, %g31, 544
	sti	%g9, %g31, 524
jeq_cont.8018:
jeq_cont.8016:
jeq_cont.8014:
	addi	%g11, %g11, 1
	jmp	solve_each_element.2905

!==============================
! args = [%g15, %g16, %g13]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f25, %f2, %f19, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
solve_one_or_network.2909:
	slli	%g3, %g15, 2
	ld	%g3, %g16, %g3
	jne	%g3, %g29, jeq_else.8019
	return
jeq_else.8019:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g14, %g3, 512
	addi	%g11, %g0, 0
	sti	%g13, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	addi	%g15, %g15, 1
	ldi	%g13, %g1, 0
	jmp	solve_one_or_network.2909

!==============================
! args = [%g17, %g18, %g13]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f25, %f2, %f19, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
trace_or_matrix.2913:
	slli	%g3, %g17, 2
	ld	%g16, %g18, %g3
	ldi	%g3, %g16, 0
	jne	%g3, %g29, jeq_else.8021
	return
jeq_else.8021:
	addi	%g4, %g0, 99
	sti	%g13, %g1, 0
	jne	%g3, %g4, jeq_else.8023
	addi	%g15, %g0, 1
	subi	%g1, %g1, 8
	call	solve_one_or_network.2909
	addi	%g1, %g1, 8
	jmp	jeq_cont.8024
jeq_else.8023:
	subi	%g4, %g31, 624
	mov	%g8, %g13
	subi	%g1, %g1, 8
	call	solver.2807
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.8025
	jmp	jeq_cont.8026
jeq_else.8025:
	fldi	%f1, %g31, 520
	fldi	%f0, %g31, 528
	subi	%g1, %g1, 8
	call	fless.2523
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.8027
	jmp	jeq_cont.8028
jeq_else.8027:
	addi	%g15, %g0, 1
	subi	%g1, %g1, 8
	call	solve_one_or_network.2909
	addi	%g1, %g1, 8
jeq_cont.8028:
jeq_cont.8026:
jeq_cont.8024:
	addi	%g17, %g17, 1
	ldi	%g13, %g1, 0
	jmp	trace_or_matrix.2913

!==============================
! args = [%g13]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f27, %f25, %f24, %f2, %f19, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Bool
!================================
judge_intersection.2917:
	fsti	%f27, %g31, 528
	addi	%g17, %g0, 0
	ldi	%g18, %g31, 516
	subi	%g1, %g1, 4
	call	trace_or_matrix.2913
	fldi	%f2, %g31, 528
	fmov	%f0, %f2
	fmov	%f1, %f24
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.8029
	addi	%g3, %g0, 0
	return
jeq_else.8029:
	setL %g3, l.7027
	fldi	%f0, %g3, 0
	fmov	%f1, %f2
	jmp	fless.2523

!==============================
! args = [%g9, %g12, %g11]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f25, %f2, %f17, %f16, %f15, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
solve_each_element_fast.2919:
	mov	%g3, %g11
	subi	%g1, %g1, 4
	call	d_vec.2734
	addi	%g1, %g1, 4
	mov	%g13, %g3
	slli	%g3, %g9, 2
	ld	%g10, %g12, %g3
	jne	%g10, %g29, jeq_else.8030
	return
jeq_else.8030:
	mov	%g5, %g11
	mov	%g4, %g10
	subi	%g1, %g1, 4
	call	solver_fast2.2848
	addi	%g1, %g1, 4
	mov	%g14, %g3
	jne	%g14, %g0, jeq_else.8032
	slli	%g3, %g10, 2
	add	%g3, %g31, %g3
	ldi	%g3, %g3, 272
	subi	%g1, %g1, 4
	call	o_isinvert.2679
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.8033
	return
jeq_else.8033:
	addi	%g9, %g9, 1
	jmp	solve_each_element_fast.2919
jeq_else.8032:
	fldi	%f2, %g31, 520
	fmov	%f0, %f2
	fmov	%f1, %f16
	subi	%g1, %g1, 4
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.8035
	jmp	jeq_cont.8036
jeq_else.8035:
	fldi	%f0, %g31, 528
	fmov	%f1, %f2
	subi	%g1, %g1, 4
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.8037
	jmp	jeq_cont.8038
jeq_else.8037:
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
	call	check_all_inside.2890
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.8039
	jmp	jeq_cont.8040
jeq_else.8039:
	fsti	%f11, %g31, 528
	subi	%g3, %g31, 540
	fldi	%f3, %g1, 0
	fmov	%f0, %f9
	fmov	%f1, %f10
	fmov	%f2, %f3
	subi	%g1, %g1, 8
	call	vecset.2627
	addi	%g1, %g1, 8
	sti	%g10, %g31, 544
	sti	%g14, %g31, 524
jeq_cont.8040:
jeq_cont.8038:
jeq_cont.8036:
	addi	%g9, %g9, 1
	jmp	solve_each_element_fast.2919

!==============================
! args = [%g15, %g16, %g11]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f25, %f2, %f17, %f16, %f15, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
solve_one_or_network_fast.2923:
	slli	%g3, %g15, 2
	ld	%g3, %g16, %g3
	jne	%g3, %g29, jeq_else.8041
	return
jeq_else.8041:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g12, %g3, 512
	addi	%g9, %g0, 0
	sti	%g11, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element_fast.2919
	addi	%g1, %g1, 8
	addi	%g15, %g15, 1
	ldi	%g11, %g1, 0
	jmp	solve_one_or_network_fast.2923

!==============================
! args = [%g17, %g18, %g11]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f25, %f2, %f17, %f16, %f15, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
trace_or_matrix_fast.2927:
	slli	%g3, %g17, 2
	ld	%g16, %g18, %g3
	ldi	%g4, %g16, 0
	jne	%g4, %g29, jeq_else.8043
	return
jeq_else.8043:
	addi	%g3, %g0, 99
	sti	%g11, %g1, 0
	jne	%g4, %g3, jeq_else.8045
	addi	%g15, %g0, 1
	subi	%g1, %g1, 8
	call	solve_one_or_network_fast.2923
	addi	%g1, %g1, 8
	jmp	jeq_cont.8046
jeq_else.8045:
	mov	%g5, %g11
	subi	%g1, %g1, 8
	call	solver_fast2.2848
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.8047
	jmp	jeq_cont.8048
jeq_else.8047:
	fldi	%f1, %g31, 520
	fldi	%f0, %g31, 528
	subi	%g1, %g1, 8
	call	fless.2523
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.8049
	jmp	jeq_cont.8050
jeq_else.8049:
	addi	%g15, %g0, 1
	subi	%g1, %g1, 8
	call	solve_one_or_network_fast.2923
	addi	%g1, %g1, 8
jeq_cont.8050:
jeq_cont.8048:
jeq_cont.8046:
	addi	%g17, %g17, 1
	ldi	%g11, %g1, 0
	jmp	trace_or_matrix_fast.2927

!==============================
! args = [%g11]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f27, %f25, %f24, %f2, %f17, %f16, %f15, %f11, %f10, %f1, %f0, %dummy]
! ret type = Bool
!================================
judge_intersection_fast.2931:
	fsti	%f27, %g31, 528
	addi	%g17, %g0, 0
	ldi	%g18, %g31, 516
	subi	%g1, %g1, 4
	call	trace_or_matrix_fast.2927
	fldi	%f2, %g31, 528
	fmov	%f0, %f2
	fmov	%f1, %f24
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.8051
	addi	%g3, %g0, 0
	return
jeq_else.8051:
	setL %g3, l.7027
	fldi	%f0, %g3, 0
	fmov	%f1, %f2
	jmp	fless.2523

!==============================
! args = [%g4]
! fargs = []
! use_regs = [%g5, %g4, %g3, %g27, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
get_nvector_rect.2933:
	ldi	%g5, %g31, 524
	subi	%g3, %g31, 556
	subi	%g1, %g1, 4
	call	vecbzero.2635
	subi	%g5, %g5, 1
	slli	%g3, %g5, 2
	fld	%f1, %g4, %g3
	call	sgn.2619
	call	fneg.2539
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
get_nvector_plane.2935:
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_a.2683
	call	fneg.2539
	addi	%g1, %g1, 8
	fsti	%f0, %g31, 556
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_b.2685
	call	fneg.2539
	addi	%g1, %g1, 8
	fsti	%f0, %g31, 552
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_c.2687
	call	fneg.2539
	addi	%g1, %g1, 8
	fsti	%f0, %g31, 548
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g5, %g4, %g3, %g27, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f21, %f2, %f19, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
get_nvector_second.2937:
	fldi	%f1, %g31, 540
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_x.2691
	addi	%g1, %g1, 8
	fsub	%f5, %f1, %f0
	fldi	%f1, %g31, 536
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_y.2693
	addi	%g1, %g1, 8
	fsub	%f2, %f1, %f0
	fldi	%f1, %g31, 532
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_z.2695
	addi	%g1, %g1, 8
	fsub	%f1, %f1, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_a.2683
	addi	%g1, %g1, 8
	fmul	%f8, %f5, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_b.2685
	addi	%g1, %g1, 8
	fmul	%f3, %f2, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_c.2687
	addi	%g1, %g1, 8
	fmul	%f6, %f1, %f0
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_isrot.2681
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jne	%g4, %g0, jeq_else.8054
	fsti	%f8, %g31, 556
	fsti	%f3, %g31, 552
	fsti	%f6, %g31, 548
	jmp	jeq_cont.8055
jeq_else.8054:
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r3.2711
	addi	%g1, %g1, 8
	fmov	%f7, %f0
	fmul	%f9, %f2, %f7
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r2.2709
	fmov	%f4, %f0
	fmul	%f0, %f1, %f4
	fadd	%f0, %f9, %f0
	call	fhalf.2541
	addi	%g1, %g1, 8
	fadd	%f0, %f8, %f0
	fsti	%f0, %g31, 556
	fmul	%f8, %f5, %f7
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r1.2707
	fmov	%f7, %f0
	fmul	%f0, %f1, %f7
	fadd	%f0, %f8, %f0
	call	fhalf.2541
	fadd	%f0, %f3, %f0
	fsti	%f0, %g31, 552
	fmul	%f1, %f5, %f4
	fmul	%f0, %f2, %f7
	fadd	%f0, %f1, %f0
	call	fhalf.2541
	addi	%g1, %g1, 8
	fadd	%f0, %f6, %f0
	fsti	%f0, %g31, 548
jeq_cont.8055:
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_isinvert.2679
	addi	%g1, %g1, 8
	mov	%g5, %g3
	subi	%g4, %g31, 556
	jmp	vecunit_sgn.2645

!==============================
! args = [%g3, %g4]
! fargs = []
! use_regs = [%g5, %g4, %g3, %g27, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f21, %f2, %f19, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
get_nvector.2939:
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	o_form.2675
	addi	%g1, %g1, 8
	mov	%g5, %g3
	jne	%g5, %g28, jeq_else.8056
	jmp	get_nvector_rect.2933
jeq_else.8056:
	addi	%g4, %g0, 2
	jne	%g5, %g4, jeq_else.8057
	ldi	%g3, %g1, 0
	jmp	get_nvector_plane.2935
jeq_else.8057:
	ldi	%g3, %g1, 0
	jmp	get_nvector_second.2937

!==============================
! args = [%g6, %g5]
! fargs = []
! use_regs = [%g7, %g6, %g5, %g4, %g3, %g27, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f26, %f23, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
utexture.2942:
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	o_texturetype.2673
	mov	%g4, %g3
	mov	%g3, %g6
	call	o_color_red.2701
	fsti	%f0, %g31, 568
	mov	%g3, %g6
	call	o_color_green.2703
	fsti	%f0, %g31, 564
	mov	%g3, %g6
	call	o_color_blue.2705
	addi	%g1, %g1, 4
	fsti	%f0, %g31, 560
	jne	%g4, %g28, jeq_else.8058
	fldi	%f1, %g5, 0
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	o_param_x.2691
	fsub	%f5, %f1, %f0
	setL %g3, l.7146
	fldi	%f7, %g3, 0
	fmul	%f0, %f5, %f7
	call	min_caml_floor
	setL %g3, l.7148
	fldi	%f6, %g3, 0
	fmul	%f0, %f0, %f6
	fsub	%f1, %f5, %f0
	fmov	%f0, %f30
	call	fless.2523
	mov	%g7, %g3
	fldi	%f1, %g5, -8
	mov	%g3, %g6
	call	o_param_z.2695
	fsub	%f5, %f1, %f0
	fmul	%f0, %f5, %f7
	call	min_caml_floor
	fmul	%f0, %f0, %f6
	fsub	%f1, %f5, %f0
	fmov	%f0, %f30
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g7, %g0, jeq_else.8059
	jne	%g3, %g0, jeq_else.8061
	setL %g3, l.6310
	fldi	%f0, %g3, 0
	jmp	jeq_cont.8062
jeq_else.8061:
	setL %g3, l.6296
	fldi	%f0, %g3, 0
jeq_cont.8062:
	jmp	jeq_cont.8060
jeq_else.8059:
	jne	%g3, %g0, jeq_else.8063
	setL %g3, l.6296
	fldi	%f0, %g3, 0
	jmp	jeq_cont.8064
jeq_else.8063:
	setL %g3, l.6310
	fldi	%f0, %g3, 0
jeq_cont.8064:
jeq_cont.8060:
	fsti	%f0, %g31, 564
	return
jeq_else.8058:
	addi	%g3, %g0, 2
	jne	%g4, %g3, jeq_else.8066
	fldi	%f1, %g5, -4
	setL %g3, l.7138
	fldi	%f0, %g3, 0
	fmul	%f3, %f1, %f0
	subi	%g1, %g1, 4
	call	sin.2558
	call	fsqr.2543
	addi	%g1, %g1, 4
	fmul	%f1, %f18, %f0
	fsti	%f1, %g31, 568
	fsub	%f0, %f17, %f0
	fmul	%f0, %f18, %f0
	fsti	%f0, %g31, 564
	return
jeq_else.8066:
	addi	%g3, %g0, 3
	jne	%g4, %g3, jeq_else.8068
	fldi	%f1, %g5, 0
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	o_param_x.2691
	fsub	%f1, %f1, %f0
	fldi	%f2, %g5, -8
	mov	%g3, %g6
	call	o_param_z.2695
	addi	%g1, %g1, 4
	fsub	%f0, %f2, %f0
	fsti	%f0, %g1, 0
	fmov	%f0, %f1
	subi	%g1, %g1, 8
	call	fsqr.2543
	addi	%g1, %g1, 8
	fmov	%f1, %f0
	fldi	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fsqr.2543
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
	call	cos.2560
	call	fsqr.2543
	addi	%g1, %g1, 12
	fmul	%f1, %f0, %f18
	fsti	%f1, %g31, 564
	fsub	%f0, %f17, %f0
	fmul	%f0, %f0, %f18
	fsti	%f0, %g31, 560
	return
jeq_else.8068:
	addi	%g3, %g0, 4
	jne	%g4, %g3, jeq_else.8070
	fldi	%f1, %g5, 0
	mov	%g3, %g6
	subi	%g1, %g1, 12
	call	o_param_x.2691
	fsub	%f1, %f1, %f0
	mov	%g3, %g6
	call	o_param_a.2683
	fsqrt	%f0, %f0
	fmul	%f3, %f1, %f0
	fldi	%f1, %g5, -8
	mov	%g3, %g6
	call	o_param_z.2695
	fsub	%f1, %f1, %f0
	mov	%g3, %g6
	call	o_param_c.2687
	fsqrt	%f0, %f0
	fmul	%f2, %f1, %f0
	fmov	%f0, %f3
	call	fsqr.2543
	fmov	%f1, %f0
	fmov	%f0, %f2
	call	fsqr.2543
	fadd	%f7, %f1, %f0
	fmov	%f1, %f3
	call	fabs.2535
	fmov	%f1, %f0
	setL %g3, l.7104
	fldi	%f6, %g3, 0
	fmov	%f0, %f6
	call	fless.2523
	addi	%g1, %g1, 12
	jne	%g3, %g0, jeq_else.8071
	fdiv	%f1, %f2, %f3
	subi	%g1, %g1, 12
	call	fabs.2535
	call	atan.2552
	addi	%g1, %g1, 12
	fmul	%f0, %f0, %f31
	fdiv	%f0, %f0, %f23
	jmp	jeq_cont.8072
jeq_else.8071:
	setL %g3, l.7106
	fldi	%f0, %g3, 0
jeq_cont.8072:
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
	call	o_param_y.2693
	fsub	%f1, %f1, %f0
	mov	%g3, %g6
	call	o_param_b.2685
	fsqrt	%f0, %f0
	fmul	%f2, %f1, %f0
	fmov	%f1, %f7
	call	fabs.2535
	fmov	%f1, %f0
	fmov	%f0, %f6
	call	fless.2523
	addi	%g1, %g1, 16
	jne	%g3, %g0, jeq_else.8073
	fdiv	%f1, %f2, %f7
	subi	%g1, %g1, 16
	call	fabs.2535
	call	atan.2552
	addi	%g1, %g1, 16
	fmul	%f0, %f0, %f31
	fdiv	%f0, %f0, %f23
	jmp	jeq_cont.8074
jeq_else.8073:
	setL %g3, l.7106
	fldi	%f0, %g3, 0
jeq_cont.8074:
	fsti	%f0, %g1, 12
	subi	%g1, %g1, 20
	call	min_caml_floor
	addi	%g1, %g1, 20
	fmov	%f1, %f0
	fldi	%f0, %g1, 12
	fsub	%f1, %f0, %f1
	setL %g3, l.7117
	fldi	%f2, %g3, 0
	fsub	%f0, %f19, %f8
	subi	%g1, %g1, 20
	call	fsqr.2543
	fsub	%f2, %f2, %f0
	fsub	%f0, %f19, %f1
	call	fsqr.2543
	addi	%g1, %g1, 20
	fsub	%f0, %f2, %f0
	fsti	%f0, %g1, 16
	subi	%g1, %g1, 24
	call	fisneg.2528
	addi	%g1, %g1, 24
	jne	%g3, %g0, jeq_else.8075
	fldi	%f0, %g1, 16
	fmov	%f1, %f0
	jmp	jeq_cont.8076
jeq_else.8075:
	setL %g3, l.6296
	fldi	%f1, %g3, 0
jeq_cont.8076:
	fmul	%f1, %f18, %f1
	setL %g3, l.7122
	fldi	%f0, %g3, 0
	fdiv	%f0, %f1, %f0
	fsti	%f0, %g31, 560
	return
jeq_else.8070:
	return

!==============================
! args = []
! fargs = [%f0, %f4, %f3]
! use_regs = [%g4, %g3, %g27, %f4, %f3, %f2, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
add_light.2945:
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fispos.2526
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.8079
	jmp	jeq_cont.8080
jeq_else.8079:
	subi	%g3, %g31, 568
	subi	%g4, %g31, 592
	fldi	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	vecaccum.2656
	addi	%g1, %g1, 8
jeq_cont.8080:
	fmov	%f0, %f4
	subi	%g1, %g1, 8
	call	fispos.2526
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.8081
	return
jeq_else.8081:
	fmov	%f0, %f4
	subi	%g1, %g1, 8
	call	fsqr.2543
	call	fsqr.2543
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
trace_reflections.2949:
	jlt	%g19, %g0, jge_else.8084
	slli	%g3, %g19, 2
	add	%g3, %g31, %g3
	ldi	%g20, %g3, 1716
	mov	%g3, %g20
	subi	%g1, %g1, 4
	call	r_dvec.2740
	mov	%g22, %g3
	mov	%g11, %g22
	call	judge_intersection_fast.2931
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.8085
	jmp	jeq_cont.8086
jeq_else.8085:
	ldi	%g3, %g31, 544
	slli	%g4, %g3, 2
	ldi	%g3, %g31, 524
	add	%g4, %g4, %g3
	mov	%g3, %g20
	subi	%g1, %g1, 4
	call	r_surface_id.2738
	addi	%g1, %g1, 4
	jne	%g4, %g3, jeq_else.8087
	addi	%g12, %g0, 0
	ldi	%g13, %g31, 516
	subi	%g1, %g1, 4
	call	shadow_check_one_or_matrix.2902
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.8089
	mov	%g3, %g22
	subi	%g1, %g1, 4
	call	d_vec.2734
	addi	%g1, %g1, 4
	subi	%g4, %g31, 556
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	veciprod.2648
	addi	%g1, %g1, 8
	fsti	%f0, %g1, 4
	mov	%g3, %g20
	subi	%g1, %g1, 12
	call	r_bright.2742
	addi	%g1, %g1, 12
	fmov	%f3, %f0
	fmul	%f1, %f3, %f13
	fldi	%f0, %g1, 4
	fmul	%f0, %f1, %f0
	ldi	%g3, %g1, 0
	fsti	%f0, %g1, 8
	mov	%g4, %g21
	subi	%g1, %g1, 16
	call	veciprod.2648
	addi	%g1, %g1, 16
	fmov	%f1, %f0
	fmul	%f4, %f3, %f1
	fldi	%f0, %g1, 8
	fmov	%f3, %f12
	subi	%g1, %g1, 16
	call	add_light.2945
	addi	%g1, %g1, 16
	jmp	jeq_cont.8090
jeq_else.8089:
jeq_cont.8090:
	jmp	jeq_cont.8088
jeq_else.8087:
jeq_cont.8088:
jeq_cont.8086:
	subi	%g19, %g19, 1
	jmp	trace_reflections.2949
jge_else.8084:
	return

!==============================
! args = [%g23, %g21, %g24]
! fargs = [%f14, %f11]
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f22, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
trace_ray.2954:
	addi	%g3, %g0, 4
	jlt	%g3, %g23, jle_else.8092
	mov	%g3, %g24
	subi	%g1, %g1, 4
	call	p_surface_ids.2719
	addi	%g1, %g1, 4
	mov	%g25, %g3
	fsti	%f11, %g1, 0
	mov	%g13, %g21
	subi	%g1, %g1, 8
	call	judge_intersection.2917
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.8093
	addi	%g4, %g0, -1
	slli	%g3, %g23, 2
	st	%g4, %g25, %g3
	jne	%g23, %g0, jeq_else.8094
	return
jeq_else.8094:
	subi	%g3, %g31, 308
	mov	%g4, %g21
	subi	%g1, %g1, 8
	call	veciprod.2648
	call	fneg.2539
	addi	%g1, %g1, 8
	fsti	%f0, %g1, 4
	subi	%g1, %g1, 12
	call	fispos.2526
	addi	%g1, %g1, 12
	jne	%g3, %g0, jeq_else.8096
	return
jeq_else.8096:
	fldi	%f0, %g1, 4
	subi	%g1, %g1, 12
	call	fsqr.2543
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
jeq_else.8093:
	ldi	%g8, %g31, 544
	slli	%g3, %g8, 2
	add	%g3, %g31, %g3
	ldi	%g6, %g3, 272
	mov	%g3, %g6
	subi	%g1, %g1, 12
	call	o_reflectiontype.2677
	mov	%g26, %g3
	mov	%g3, %g6
	call	o_diffuse.2697
	fmov	%f10, %f0
	fmul	%f13, %f10, %f14
	mov	%g4, %g21
	mov	%g3, %g6
	call	get_nvector.2939
	subi	%g3, %g31, 540
	subi	%g4, %g31, 624
	call	veccpy.2637
	addi	%g1, %g1, 12
	subi	%g5, %g31, 540
	sti	%g6, %g1, 8
	subi	%g1, %g1, 16
	call	utexture.2942
	slli	%g4, %g8, 2
	ldi	%g3, %g31, 524
	add	%g4, %g4, %g3
	slli	%g3, %g23, 2
	st	%g4, %g25, %g3
	mov	%g3, %g24
	call	p_intersection_points.2717
	slli	%g4, %g23, 2
	ld	%g4, %g3, %g4
	subi	%g3, %g31, 540
	call	veccpy.2637
	mov	%g3, %g24
	call	p_calc_diffuse.2721
	addi	%g1, %g1, 16
	sti	%g3, %g1, 12
	fmov	%f0, %f19
	fmov	%f1, %f10
	subi	%g1, %g1, 20
	call	fless.2523
	addi	%g1, %g1, 20
	mov	%g4, %g3
	jne	%g4, %g0, jeq_else.8099
	addi	%g5, %g0, 1
	slli	%g4, %g23, 2
	ldi	%g3, %g1, 12
	st	%g5, %g3, %g4
	mov	%g3, %g24
	subi	%g1, %g1, 20
	call	p_energy.2723
	mov	%g5, %g3
	slli	%g3, %g23, 2
	ld	%g4, %g5, %g3
	subi	%g3, %g31, 568
	call	veccpy.2637
	slli	%g3, %g23, 2
	ld	%g3, %g5, %g3
	setL %g4, l.7199
	fldi	%f0, %g4, 0
	fmul	%f0, %f0, %f13
	call	vecscale.2666
	mov	%g3, %g24
	call	p_nvectors.2732
	slli	%g4, %g23, 2
	ld	%g4, %g3, %g4
	subi	%g3, %g31, 556
	call	veccpy.2637
	addi	%g1, %g1, 20
	jmp	jeq_cont.8100
jeq_else.8099:
	addi	%g5, %g0, 0
	slli	%g4, %g23, 2
	ldi	%g3, %g1, 12
	st	%g5, %g3, %g4
jeq_cont.8100:
	setL %g3, l.7204
	fldi	%f3, %g3, 0
	subi	%g3, %g31, 556
	mov	%g4, %g21
	subi	%g1, %g1, 20
	call	veciprod.2648
	fmul	%f0, %f3, %f0
	subi	%g3, %g31, 556
	mov	%g4, %g21
	call	vecaccum.2656
	addi	%g1, %g1, 20
	ldi	%g6, %g1, 8
	mov	%g3, %g6
	subi	%g1, %g1, 20
	call	o_hilight.2699
	fmul	%f12, %f14, %f0
	addi	%g12, %g0, 0
	ldi	%g13, %g31, 516
	call	shadow_check_one_or_matrix.2902
	addi	%g1, %g1, 20
	jne	%g3, %g0, jeq_else.8101
	subi	%g3, %g31, 308
	subi	%g4, %g31, 556
	subi	%g1, %g1, 20
	call	veciprod.2648
	call	fneg.2539
	fmul	%f5, %f0, %f13
	subi	%g3, %g31, 308
	mov	%g4, %g21
	call	veciprod.2648
	call	fneg.2539
	fmov	%f4, %f0
	fmov	%f3, %f12
	fmov	%f0, %f5
	call	add_light.2945
	addi	%g1, %g1, 20
	jmp	jeq_cont.8102
jeq_else.8101:
jeq_cont.8102:
	subi	%g6, %g31, 540
	subi	%g1, %g1, 20
	call	setup_startp.2868
	addi	%g1, %g1, 20
	ldi	%g3, %g31, 1720
	subi	%g19, %g3, 1
	sti	%g21, %g1, 16
	fsti	%f10, %g1, 20
	subi	%g1, %g1, 28
	call	trace_reflections.2949
	fmov	%f0, %f14
	fmov	%f1, %f22
	call	fless.2523
	addi	%g1, %g1, 28
	jne	%g3, %g0, jeq_else.8103
	return
jeq_else.8103:
	addi	%g3, %g0, 4
	jlt	%g23, %g3, jle_else.8105
	jmp	jle_cont.8106
jle_else.8105:
	addi	%g3, %g23, 1
	addi	%g4, %g0, -1
	slli	%g3, %g3, 2
	st	%g4, %g25, %g3
jle_cont.8106:
	addi	%g3, %g0, 2
	jne	%g26, %g3, jeq_else.8107
	fldi	%f10, %g1, 20
	fsub	%f0, %f17, %f10
	fmul	%f14, %f14, %f0
	addi	%g23, %g23, 1
	fldi	%f0, %g31, 528
	fldi	%f11, %g1, 0
	fadd	%f11, %f11, %f0
	ldi	%g21, %g1, 16
	jmp	trace_ray.2954
jeq_else.8107:
	return
jle_else.8092:
	return

!==============================
! args = [%g11]
! fargs = [%f12]
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
trace_diffuse_ray.2960:
	sti	%g11, %g1, 0
	subi	%g1, %g1, 8
	call	judge_intersection_fast.2931
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.8110
	return
jeq_else.8110:
	ldi	%g3, %g31, 544
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g14, %g3, 272
	ldi	%g11, %g1, 0
	mov	%g3, %g11
	subi	%g1, %g1, 8
	call	d_vec.2734
	mov	%g4, %g3
	mov	%g3, %g14
	call	get_nvector.2939
	subi	%g5, %g31, 540
	mov	%g6, %g14
	call	utexture.2942
	addi	%g12, %g0, 0
	ldi	%g13, %g31, 516
	call	shadow_check_one_or_matrix.2902
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.8112
	subi	%g3, %g31, 308
	subi	%g4, %g31, 556
	subi	%g1, %g1, 8
	call	veciprod.2648
	call	fneg.2539
	addi	%g1, %g1, 8
	fsti	%f0, %g1, 4
	subi	%g1, %g1, 12
	call	fispos.2526
	addi	%g1, %g1, 12
	jne	%g3, %g0, jeq_else.8113
	setL %g3, l.6296
	fldi	%f1, %g3, 0
	jmp	jeq_cont.8114
jeq_else.8113:
	fldi	%f0, %g1, 4
	fmov	%f1, %f0
jeq_cont.8114:
	fmul	%f1, %f12, %f1
	mov	%g3, %g14
	subi	%g1, %g1, 12
	call	o_diffuse.2697
	addi	%g1, %g1, 12
	fmul	%f0, %f1, %f0
	subi	%g3, %g31, 568
	subi	%g4, %g31, 580
	jmp	vecaccum.2656
jeq_else.8112:
	return

!==============================
! args = [%g22, %g21, %g20, %g19]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
iter_trace_diffuse_rays.2963:
	jlt	%g19, %g0, jge_else.8116
	slli	%g3, %g19, 2
	ld	%g3, %g22, %g3
	subi	%g1, %g1, 4
	call	d_vec.2734
	mov	%g4, %g3
	mov	%g3, %g21
	call	veciprod.2648
	addi	%g1, %g1, 4
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fisneg.2528
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.8117
	slli	%g3, %g19, 2
	ld	%g11, %g22, %g3
	setL %g3, l.7255
	fldi	%f1, %g3, 0
	fldi	%f0, %g1, 0
	fdiv	%f12, %f0, %f1
	subi	%g1, %g1, 8
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 8
	jmp	jeq_cont.8118
jeq_else.8117:
	addi	%g3, %g19, 1
	slli	%g3, %g3, 2
	ld	%g11, %g22, %g3
	setL %g3, l.7251
	fldi	%f1, %g3, 0
	fldi	%f0, %g1, 0
	fdiv	%f12, %f0, %f1
	subi	%g1, %g1, 8
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 8
jeq_cont.8118:
	subi	%g19, %g19, 2
	jmp	iter_trace_diffuse_rays.2963
jge_else.8116:
	return

!==============================
! args = [%g22, %g21, %g20]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
trace_diffuse_rays.2968:
	mov	%g6, %g20
	subi	%g1, %g1, 4
	call	setup_startp.2868
	addi	%g1, %g1, 4
	addi	%g19, %g0, 118
	jmp	iter_trace_diffuse_rays.2963

!==============================
! args = [%g23, %g21, %g20]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
trace_diffuse_ray_80percent.2972:
	sti	%g20, %g1, 0
	sti	%g21, %g1, 4
	jne	%g23, %g0, jeq_else.8120
	jmp	jeq_cont.8121
jeq_else.8120:
	ldi	%g22, %g31, 716
	subi	%g1, %g1, 12
	call	trace_diffuse_rays.2968
	addi	%g1, %g1, 12
jeq_cont.8121:
	jne	%g23, %g28, jeq_else.8122
	jmp	jeq_cont.8123
jeq_else.8122:
	ldi	%g22, %g31, 712
	ldi	%g21, %g1, 4
	ldi	%g20, %g1, 0
	subi	%g1, %g1, 12
	call	trace_diffuse_rays.2968
	addi	%g1, %g1, 12
jeq_cont.8123:
	addi	%g3, %g0, 2
	jne	%g23, %g3, jeq_else.8124
	jmp	jeq_cont.8125
jeq_else.8124:
	ldi	%g22, %g31, 708
	ldi	%g21, %g1, 4
	ldi	%g20, %g1, 0
	subi	%g1, %g1, 12
	call	trace_diffuse_rays.2968
	addi	%g1, %g1, 12
jeq_cont.8125:
	addi	%g3, %g0, 3
	jne	%g23, %g3, jeq_else.8126
	jmp	jeq_cont.8127
jeq_else.8126:
	ldi	%g22, %g31, 704
	ldi	%g21, %g1, 4
	ldi	%g20, %g1, 0
	subi	%g1, %g1, 12
	call	trace_diffuse_rays.2968
	addi	%g1, %g1, 12
jeq_cont.8127:
	addi	%g3, %g0, 4
	jne	%g23, %g3, jeq_else.8128
	return
jeq_else.8128:
	ldi	%g22, %g31, 700
	ldi	%g21, %g1, 4
	ldi	%g20, %g1, 0
	jmp	trace_diffuse_rays.2968

!==============================
! args = [%g3, %g24]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
calc_diffuse_using_1point.2976:
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	p_received_ray_20percent.2725
	addi	%g1, %g1, 8
	mov	%g4, %g3
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	p_nvectors.2732
	addi	%g1, %g1, 8
	mov	%g6, %g3
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	p_intersection_points.2717
	addi	%g1, %g1, 8
	mov	%g7, %g3
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	p_energy.2723
	mov	%g25, %g3
	slli	%g5, %g24, 2
	ld	%g5, %g4, %g5
	subi	%g4, %g31, 580
	mov	%g3, %g5
	call	veccpy.2637
	addi	%g1, %g1, 8
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	p_group_id.2727
	mov	%g23, %g3
	slli	%g3, %g24, 2
	ld	%g21, %g6, %g3
	slli	%g3, %g24, 2
	ld	%g20, %g7, %g3
	call	trace_diffuse_ray_80percent.2972
	addi	%g1, %g1, 8
	slli	%g3, %g24, 2
	ld	%g4, %g25, %g3
	subi	%g3, %g31, 580
	subi	%g5, %g31, 592
	jmp	vecaccumv.2669

!==============================
! args = [%g5, %g3, %g7, %g4, %g6]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g12, %g11, %g10, %f2, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
calc_diffuse_using_5points.2979:
	slli	%g8, %g5, 2
	ld	%g3, %g3, %g8
	subi	%g1, %g1, 4
	call	p_received_ray_20percent.2725
	mov	%g8, %g3
	subi	%g3, %g5, 1
	slli	%g3, %g3, 2
	ld	%g3, %g7, %g3
	call	p_received_ray_20percent.2725
	mov	%g10, %g3
	slli	%g3, %g5, 2
	ld	%g3, %g7, %g3
	call	p_received_ray_20percent.2725
	mov	%g12, %g3
	addi	%g3, %g5, 1
	slli	%g3, %g3, 2
	ld	%g3, %g7, %g3
	call	p_received_ray_20percent.2725
	mov	%g9, %g3
	slli	%g3, %g5, 2
	ld	%g3, %g4, %g3
	call	p_received_ray_20percent.2725
	mov	%g11, %g3
	slli	%g3, %g6, 2
	ld	%g3, %g8, %g3
	subi	%g4, %g31, 580
	call	veccpy.2637
	slli	%g3, %g6, 2
	ld	%g3, %g10, %g3
	subi	%g4, %g31, 580
	call	vecadd.2660
	slli	%g3, %g6, 2
	ld	%g3, %g12, %g3
	subi	%g4, %g31, 580
	call	vecadd.2660
	slli	%g3, %g6, 2
	ld	%g3, %g9, %g3
	subi	%g4, %g31, 580
	call	vecadd.2660
	slli	%g3, %g6, 2
	ld	%g3, %g11, %g3
	subi	%g4, %g31, 580
	call	vecadd.2660
	slli	%g3, %g5, 2
	ld	%g3, %g7, %g3
	call	p_energy.2723
	addi	%g1, %g1, 4
	slli	%g4, %g6, 2
	ld	%g4, %g3, %g4
	subi	%g3, %g31, 580
	subi	%g5, %g31, 592
	jmp	vecaccumv.2669

!==============================
! args = [%g3, %g24]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
do_without_neighbors.2985:
	addi	%g4, %g0, 4
	jlt	%g4, %g24, jle_else.8130
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	p_surface_ids.2719
	addi	%g1, %g1, 8
	mov	%g4, %g3
	slli	%g5, %g24, 2
	ld	%g4, %g4, %g5
	jlt	%g4, %g0, jge_else.8131
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	p_calc_diffuse.2721
	addi	%g1, %g1, 8
	mov	%g4, %g3
	slli	%g5, %g24, 2
	ld	%g4, %g4, %g5
	sti	%g24, %g1, 4
	jne	%g4, %g0, jeq_else.8132
	jmp	jeq_cont.8133
jeq_else.8132:
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 12
	call	calc_diffuse_using_1point.2976
	addi	%g1, %g1, 12
jeq_cont.8133:
	ldi	%g24, %g1, 4
	addi	%g24, %g24, 1
	ldi	%g3, %g1, 0
	jmp	do_without_neighbors.2985
jge_else.8131:
	return
jle_else.8130:
	return

!==============================
! args = [%g5, %g4, %g3]
! fargs = []
! use_regs = [%g6, %g5, %g4, %g3, %g27, %f15]
! ret type = Bool
!================================
neighbors_exist.2988:
	ldi	%g6, %g31, 596
	addi	%g3, %g4, 1
	jlt	%g3, %g6, jle_else.8136
	addi	%g3, %g0, 0
	return
jle_else.8136:
	jlt	%g0, %g4, jle_else.8137
	addi	%g3, %g0, 0
	return
jle_else.8137:
	ldi	%g4, %g31, 600
	addi	%g3, %g5, 1
	jlt	%g3, %g4, jle_else.8138
	addi	%g3, %g0, 0
	return
jle_else.8138:
	jlt	%g0, %g5, jle_else.8139
	addi	%g3, %g0, 0
	return
jle_else.8139:
	addi	%g3, %g0, 1
	return

!==============================
! args = [%g3, %g4]
! fargs = []
! use_regs = [%g4, %g3, %g27, %f15]
! ret type = Int
!================================
get_surface_id.2992:
	subi	%g1, %g1, 4
	call	p_surface_ids.2719
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
neighbors_are_available.2995:
	slli	%g3, %g5, 2
	ld	%g3, %g8, %g3
	sti	%g4, %g1, 0
	subi	%g1, %g1, 8
	call	get_surface_id.2992
	addi	%g1, %g1, 8
	mov	%g9, %g3
	slli	%g3, %g5, 2
	ld	%g3, %g6, %g3
	ldi	%g4, %g1, 0
	subi	%g1, %g1, 8
	call	get_surface_id.2992
	addi	%g1, %g1, 8
	jne	%g3, %g9, jeq_else.8140
	slli	%g3, %g5, 2
	ld	%g3, %g7, %g3
	ldi	%g4, %g1, 0
	subi	%g1, %g1, 8
	call	get_surface_id.2992
	addi	%g1, %g1, 8
	jne	%g3, %g9, jeq_else.8141
	subi	%g3, %g5, 1
	slli	%g3, %g3, 2
	ld	%g3, %g8, %g3
	ldi	%g4, %g1, 0
	subi	%g1, %g1, 8
	call	get_surface_id.2992
	addi	%g1, %g1, 8
	jne	%g3, %g9, jeq_else.8142
	addi	%g3, %g5, 1
	slli	%g3, %g3, 2
	ld	%g3, %g8, %g3
	ldi	%g4, %g1, 0
	subi	%g1, %g1, 8
	call	get_surface_id.2992
	addi	%g1, %g1, 8
	jne	%g3, %g9, jeq_else.8143
	addi	%g3, %g0, 1
	return
jeq_else.8143:
	addi	%g3, %g0, 0
	return
jeq_else.8142:
	addi	%g3, %g0, 0
	return
jeq_else.8141:
	addi	%g3, %g0, 0
	return
jeq_else.8140:
	addi	%g3, %g0, 0
	return

!==============================
! args = [%g5, %g13, %g14, %g16, %g15, %g24]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
try_exploit_neighbors.3001:
	slli	%g3, %g5, 2
	ld	%g3, %g16, %g3
	addi	%g4, %g0, 4
	jlt	%g4, %g24, jle_else.8144
	sti	%g3, %g1, 0
	mov	%g4, %g24
	subi	%g1, %g1, 8
	call	get_surface_id.2992
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jlt	%g4, %g0, jge_else.8145
	sti	%g5, %g1, 4
	mov	%g4, %g24
	mov	%g7, %g15
	mov	%g8, %g16
	mov	%g6, %g14
	subi	%g1, %g1, 12
	call	neighbors_are_available.2995
	addi	%g1, %g1, 12
	mov	%g4, %g3
	jne	%g4, %g0, jeq_else.8146
	ldi	%g5, %g1, 4
	slli	%g3, %g5, 2
	ld	%g3, %g16, %g3
	jmp	do_without_neighbors.2985
jeq_else.8146:
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 12
	call	p_calc_diffuse.2721
	addi	%g1, %g1, 12
	slli	%g4, %g24, 2
	ld	%g3, %g3, %g4
	jne	%g3, %g0, jeq_else.8147
	jmp	jeq_cont.8148
jeq_else.8147:
	ldi	%g5, %g1, 4
	mov	%g6, %g24
	mov	%g4, %g15
	mov	%g7, %g16
	mov	%g3, %g14
	subi	%g1, %g1, 12
	call	calc_diffuse_using_5points.2979
	addi	%g1, %g1, 12
jeq_cont.8148:
	addi	%g24, %g24, 1
	ldi	%g5, %g1, 4
	jmp	try_exploit_neighbors.3001
jge_else.8145:
	return
jle_else.8144:
	return

!==============================
! args = []
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g11, %g10, %f15, %dummy]
! ret type = Unit
!================================
write_ppm_header.3008:
	addi	%g3, %g0, 80
	output	%g3
	addi	%g3, %g0, 51
	output	%g3
	addi	%g3, %g0, 10
	output	%g3
	ldi	%g8, %g31, 600
	subi	%g1, %g1, 4
	call	print_int.2587
	addi	%g3, %g0, 32
	output	%g3
	ldi	%g8, %g31, 596
	call	print_int.2587
	addi	%g3, %g0, 32
	output	%g3
	addi	%g8, %g0, 255
	call	print_int.2587
	addi	%g1, %g1, 4
	addi	%g3, %g0, 10
	output	%g3
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g11, %g10, %f4, %f3, %f2, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
write_rgb_element.3010:
	subi	%g1, %g1, 4
	call	min_caml_int_of_float
	addi	%g1, %g1, 4
	addi	%g8, %g0, 255
	jlt	%g8, %g3, jle_else.8151
	jlt	%g3, %g0, jge_else.8153
	mov	%g8, %g3
	jmp	jge_cont.8154
jge_else.8153:
	addi	%g8, %g0, 0
jge_cont.8154:
	jmp	jle_cont.8152
jle_else.8151:
	addi	%g8, %g0, 255
jle_cont.8152:
	jmp	print_int.2587

!==============================
! args = []
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g11, %g10, %f4, %f3, %f2, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
write_rgb.3012:
	fldi	%f0, %g31, 592
	subi	%g1, %g1, 4
	call	write_rgb_element.3010
	addi	%g3, %g0, 32
	output	%g3
	fldi	%f0, %g31, 588
	call	write_rgb_element.3010
	addi	%g3, %g0, 32
	output	%g3
	fldi	%f0, %g31, 584
	call	write_rgb_element.3010
	addi	%g1, %g1, 4
	addi	%g3, %g0, 10
	output	%g3
	return

!==============================
! args = [%g23, %g24]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
pretrace_diffuse_rays.3014:
	addi	%g3, %g0, 4
	jlt	%g3, %g24, jle_else.8155
	mov	%g4, %g24
	mov	%g3, %g23
	subi	%g1, %g1, 4
	call	get_surface_id.2992
	addi	%g1, %g1, 4
	jlt	%g3, %g0, jge_else.8156
	mov	%g3, %g23
	subi	%g1, %g1, 4
	call	p_calc_diffuse.2721
	addi	%g1, %g1, 4
	slli	%g4, %g24, 2
	ld	%g3, %g3, %g4
	jne	%g3, %g0, jeq_else.8157
	jmp	jeq_cont.8158
jeq_else.8157:
	mov	%g3, %g23
	subi	%g1, %g1, 4
	call	p_group_id.2727
	mov	%g5, %g3
	subi	%g3, %g31, 580
	call	vecbzero.2635
	mov	%g3, %g23
	call	p_nvectors.2732
	addi	%g1, %g1, 4
	sti	%g3, %g1, 0
	mov	%g3, %g23
	subi	%g1, %g1, 8
	call	p_intersection_points.2717
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
	call	trace_diffuse_rays.2968
	mov	%g3, %g23
	call	p_received_ray_20percent.2725
	slli	%g4, %g24, 2
	ld	%g4, %g3, %g4
	subi	%g3, %g31, 580
	call	veccpy.2637
	addi	%g1, %g1, 8
jeq_cont.8158:
	addi	%g24, %g24, 1
	jmp	pretrace_diffuse_rays.3014
jge_else.8156:
	return
jle_else.8155:
	return

!==============================
! args = [%g25, %g30, %g26]
! fargs = [%f3, %f14, %f13]
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f22, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
pretrace_pixels.3017:
	jlt	%g30, %g0, jge_else.8161
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
	call	vecunit_sgn.2645
	subi	%g3, %g31, 592
	call	vecbzero.2635
	subi	%g3, %g31, 296
	subi	%g4, %g31, 624
	call	veccpy.2637
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
	call	trace_ray.2954
	addi	%g1, %g1, 24
	slli	%g3, %g30, 2
	ldi	%g25, %g1, 16
	ld	%g3, %g25, %g3
	subi	%g1, %g1, 24
	call	p_rgb.2715
	mov	%g4, %g3
	subi	%g3, %g31, 592
	call	veccpy.2637
	addi	%g1, %g1, 24
	slli	%g3, %g30, 2
	ld	%g3, %g25, %g3
	ldi	%g26, %g1, 12
	mov	%g4, %g26
	subi	%g1, %g1, 24
	call	p_set_group_id.2729
	slli	%g3, %g30, 2
	ld	%g23, %g25, %g3
	addi	%g24, %g0, 0
	call	pretrace_diffuse_rays.3014
	subi	%g30, %g30, 1
	addi	%g3, %g0, 1
	mov	%g4, %g26
	call	add_mod5.2624
	addi	%g1, %g1, 24
	fldi	%f3, %g1, 8
	fldi	%f14, %g1, 4
	fldi	%f13, %g1, 0
	mov	%g26, %g3
	jmp	pretrace_pixels.3017
jge_else.8161:
	return

!==============================
! args = [%g25, %g3, %g26]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f22, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
pretrace_line.3024:
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
	jmp	pretrace_pixels.3017

!==============================
! args = [%g30, %g26, %g14, %g16, %g15]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
scan_pixel.3028:
	ldi	%g3, %g31, 600
	jlt	%g30, %g3, jle_else.8163
	return
jle_else.8163:
	slli	%g3, %g30, 2
	ld	%g3, %g16, %g3
	subi	%g1, %g1, 4
	call	p_rgb.2715
	subi	%g4, %g31, 592
	call	veccpy.2637
	mov	%g3, %g15
	mov	%g4, %g26
	mov	%g5, %g30
	call	neighbors_exist.2988
	addi	%g1, %g1, 4
	sti	%g15, %g1, 0
	sti	%g16, %g1, 4
	sti	%g14, %g1, 8
	jne	%g3, %g0, jeq_else.8165
	slli	%g3, %g30, 2
	ld	%g3, %g16, %g3
	addi	%g24, %g0, 0
	subi	%g1, %g1, 16
	call	do_without_neighbors.2985
	addi	%g1, %g1, 16
	jmp	jeq_cont.8166
jeq_else.8165:
	addi	%g24, %g0, 0
	mov	%g13, %g26
	mov	%g5, %g30
	subi	%g1, %g1, 16
	call	try_exploit_neighbors.3001
	addi	%g1, %g1, 16
jeq_cont.8166:
	subi	%g1, %g1, 16
	call	write_rgb.3012
	addi	%g1, %g1, 16
	addi	%g30, %g30, 1
	ldi	%g14, %g1, 8
	ldi	%g16, %g1, 4
	ldi	%g15, %g1, 0
	jmp	scan_pixel.3028

!==============================
! args = [%g26, %g14, %g16, %g15, %g4]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f27, %f26, %f25, %f24, %f23, %f22, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
scan_line.3034:
	ldi	%g3, %g31, 596
	jlt	%g26, %g3, jle_else.8167
	return
jle_else.8167:
	subi	%g3, %g3, 1
	sti	%g4, %g1, 0
	sti	%g15, %g1, 4
	sti	%g16, %g1, 8
	sti	%g14, %g1, 12
	sti	%g26, %g1, 16
	jlt	%g26, %g3, jle_else.8169
	jmp	jle_cont.8170
jle_else.8169:
	addi	%g3, %g26, 1
	mov	%g26, %g4
	mov	%g25, %g15
	subi	%g1, %g1, 24
	call	pretrace_line.3024
	addi	%g1, %g1, 24
jle_cont.8170:
	addi	%g30, %g0, 0
	ldi	%g26, %g1, 16
	ldi	%g14, %g1, 12
	ldi	%g16, %g1, 8
	ldi	%g15, %g1, 4
	subi	%g1, %g1, 24
	call	scan_pixel.3028
	addi	%g1, %g1, 24
	ldi	%g26, %g1, 16
	addi	%g26, %g26, 1
	addi	%g3, %g0, 2
	ldi	%g4, %g1, 0
	subi	%g1, %g1, 24
	call	add_mod5.2624
	addi	%g1, %g1, 24
	ldi	%g16, %g1, 8
	ldi	%g15, %g1, 4
	ldi	%g14, %g1, 12
	mov	%g4, %g3
	mov	%g27, %g15
	mov	%g15, %g14
	mov	%g14, %g16
	mov	%g16, %g27
	jmp	scan_line.3034

!==============================
! args = []
! fargs = []
! use_regs = [%g5, %g4, %g3, %g27, %f16, %f15, %f0, %dummy]
! ret type = Array(Array(Float))
!================================
create_float5x3array.3040:
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
create_pixel.3042:
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	mov	%g7, %g3
	call	create_float5x3array.3040
	mov	%g9, %g3
	addi	%g3, %g0, 5
	addi	%g4, %g0, 0
	call	min_caml_create_array
	mov	%g6, %g3
	addi	%g3, %g0, 5
	addi	%g4, %g0, 0
	call	min_caml_create_array
	mov	%g12, %g3
	call	create_float5x3array.3040
	mov	%g11, %g3
	call	create_float5x3array.3040
	mov	%g8, %g3
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	call	min_caml_create_array
	mov	%g10, %g3
	call	create_float5x3array.3040
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
init_line_elements.3044:
	jlt	%g14, %g0, jge_else.8171
	subi	%g1, %g1, 4
	call	create_pixel.3042
	addi	%g1, %g1, 4
	slli	%g4, %g14, 2
	st	%g3, %g13, %g4
	subi	%g14, %g14, 1
	jmp	init_line_elements.3044
jge_else.8171:
	mov	%g3, %g13
	return

!==============================
! args = []
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g2, %g14, %g13, %g12, %g11, %g10, %f16, %f15, %f0, %dummy]
! ret type = Array((Array(Float) * Array(Array(Float)) * Array(Int) * Array(Bool) * Array(Array(Float)) * Array(Array(Float)) * Array(Int) * Array(Array(Float))))
!================================
create_pixelline.3047:
	ldi	%g3, %g31, 600
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	create_pixel.3042
	addi	%g1, %g1, 8
	mov	%g4, %g3
	ldi	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	min_caml_create_array
	addi	%g1, %g1, 8
	mov	%g13, %g3
	ldi	%g3, %g31, 600
	subi	%g14, %g3, 2
	jmp	init_line_elements.3044

!==============================
! args = []
! fargs = [%f0, %f6]
! use_regs = [%g4, %g3, %g27, %f7, %f6, %f5, %f4, %f3, %f26, %f22, %f21, %f20, %f2, %f19, %f17, %f16, %f15, %f1, %f0]
! ret type = Float
!================================
adjust_position.3049:
	fmul	%f0, %f0, %f0
	fadd	%f0, %f0, %f22
	fsqrt	%f7, %f0
	fdiv	%f0, %f17, %f7
	subi	%g1, %g1, 4
	call	atan.2552
	fmul	%f0, %f0, %f6
	call	tan.2554
	addi	%g1, %g1, 4
	fmul	%f0, %f0, %f7
	return

!==============================
! args = [%g5, %g7, %g6]
! fargs = [%f1, %f8, %f10, %f9]
! use_regs = [%g7, %g6, %g5, %g4, %g3, %g27, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f26, %f22, %f21, %f20, %f2, %f19, %f17, %f16, %f15, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
calc_dirvec.3052:
	addi	%g3, %g0, 5
	jlt	%g5, %g3, jle_else.8172
	fmov	%f0, %f1
	subi	%g1, %g1, 4
	call	fsqr.2543
	fmov	%f2, %f0
	fmov	%f0, %f8
	call	fsqr.2543
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
	call	d_vec.2734
	fmov	%f0, %f3
	fmov	%f1, %f4
	fmov	%f2, %f5
	call	vecset.2627
	addi	%g3, %g6, 40
	slli	%g3, %g3, 2
	ld	%g3, %g4, %g3
	call	d_vec.2734
	fmov	%f0, %f4
	call	fneg.2539
	fmov	%f7, %f0
	fmov	%f0, %f7
	fmov	%f1, %f3
	fmov	%f2, %f5
	call	vecset.2627
	addi	%g3, %g6, 80
	slli	%g3, %g3, 2
	ld	%g3, %g4, %g3
	call	d_vec.2734
	fmov	%f0, %f5
	call	fneg.2539
	fmov	%f6, %f0
	fmov	%f0, %f7
	fmov	%f1, %f6
	fmov	%f2, %f3
	call	vecset.2627
	addi	%g3, %g6, 1
	slli	%g3, %g3, 2
	ld	%g3, %g4, %g3
	call	d_vec.2734
	fmov	%f0, %f3
	call	fneg.2539
	fmov	%f3, %f0
	fmov	%f0, %f3
	fmov	%f1, %f7
	fmov	%f2, %f6
	call	vecset.2627
	addi	%g3, %g6, 41
	slli	%g3, %g3, 2
	ld	%g3, %g4, %g3
	call	d_vec.2734
	fmov	%f0, %f4
	fmov	%f1, %f3
	fmov	%f2, %f6
	call	vecset.2627
	addi	%g3, %g6, 81
	slli	%g3, %g3, 2
	ld	%g3, %g4, %g3
	call	d_vec.2734
	addi	%g1, %g1, 4
	fmov	%f0, %f4
	fmov	%f1, %f5
	fmov	%f2, %f3
	jmp	vecset.2627
jle_else.8172:
	fmov	%f6, %f10
	fmov	%f0, %f8
	subi	%g1, %g1, 4
	call	adjust_position.3049
	addi	%g1, %g1, 4
	addi	%g5, %g5, 1
	fsti	%f0, %g1, 0
	fmov	%f6, %f9
	subi	%g1, %g1, 8
	call	adjust_position.3049
	addi	%g1, %g1, 8
	fmov	%f8, %f0
	fldi	%f0, %g1, 0
	fmov	%f1, %f0
	jmp	calc_dirvec.3052

!==============================
! args = [%g9, %g7, %g8]
! fargs = [%f9]
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f29, %f28, %f26, %f22, %f21, %f20, %f2, %f19, %f17, %f16, %f15, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
calc_dirvecs.3060:
	jlt	%g9, %g0, jge_else.8173
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
	call	calc_dirvec.3052
	addi	%g1, %g1, 12
	fadd	%f10, %f11, %f22
	addi	%g5, %g0, 0
	addi	%g6, %g8, 2
	fldi	%f9, %g1, 0
	ldi	%g7, %g1, 4
	fmov	%f8, %f16
	fmov	%f1, %f16
	subi	%g1, %g1, 12
	call	calc_dirvec.3052
	addi	%g1, %g1, 12
	subi	%g9, %g9, 1
	addi	%g3, %g0, 1
	ldi	%g7, %g1, 4
	mov	%g4, %g7
	subi	%g1, %g1, 12
	call	add_mod5.2624
	addi	%g1, %g1, 12
	fldi	%f9, %g1, 0
	mov	%g7, %g3
	jmp	calc_dirvecs.3060
jge_else.8173:
	return

!==============================
! args = [%g10, %g7, %g8]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f29, %f28, %f26, %f22, %f21, %f20, %f2, %f19, %f17, %f16, %f15, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
calc_dirvec_rows.3065:
	jlt	%g10, %g0, jge_else.8175
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
	call	calc_dirvecs.3060
	addi	%g1, %g1, 12
	subi	%g10, %g10, 1
	addi	%g3, %g0, 2
	ldi	%g7, %g1, 4
	mov	%g4, %g7
	subi	%g1, %g1, 12
	call	add_mod5.2624
	addi	%g1, %g1, 12
	ldi	%g8, %g1, 0
	addi	%g8, %g8, 4
	mov	%g7, %g3
	jmp	calc_dirvec_rows.3065
jge_else.8175:
	return

!==============================
! args = []
! fargs = []
! use_regs = [%g5, %g4, %g3, %g27, %g2, %f16, %f15, %f0, %dummy]
! ret type = (Array(Float) * Array(Array(Float)))
!================================
create_dirvec.3069:
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
create_dirvec_elements.3071:
	jlt	%g6, %g0, jge_else.8177
	subi	%g1, %g1, 4
	call	create_dirvec.3069
	addi	%g1, %g1, 4
	slli	%g4, %g6, 2
	st	%g3, %g7, %g4
	subi	%g6, %g6, 1
	jmp	create_dirvec_elements.3071
jge_else.8177:
	return

!==============================
! args = [%g8]
! fargs = []
! use_regs = [%g8, %g7, %g6, %g5, %g4, %g3, %g27, %g2, %f16, %f15, %f0, %dummy]
! ret type = Unit
!================================
create_dirvecs.3074:
	jlt	%g8, %g0, jge_else.8179
	addi	%g3, %g0, 120
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	create_dirvec.3069
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
	call	create_dirvec_elements.3071
	addi	%g1, %g1, 8
	subi	%g8, %g8, 1
	jmp	create_dirvecs.3074
jge_else.8179:
	return

!==============================
! args = [%g12, %g11]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g12, %g11, %g10, %f8, %f7, %f6, %f5, %f4, %f3, %f21, %f2, %f19, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
init_dirvec_constants.3076:
	jlt	%g11, %g0, jge_else.8181
	slli	%g3, %g11, 2
	ld	%g9, %g12, %g3
	subi	%g1, %g1, 4
	call	setup_dirvec_constants.2863
	addi	%g1, %g1, 4
	subi	%g11, %g11, 1
	jmp	init_dirvec_constants.3076
jge_else.8181:
	return

!==============================
! args = [%g13]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g13, %g12, %g11, %g10, %f8, %f7, %f6, %f5, %f4, %f3, %f21, %f2, %f19, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
init_vecset_constants.3079:
	jlt	%g13, %g0, jge_else.8183
	slli	%g3, %g13, 2
	add	%g3, %g31, %g3
	ldi	%g12, %g3, 716
	addi	%g11, %g0, 119
	subi	%g1, %g1, 4
	call	init_dirvec_constants.3076
	addi	%g1, %g1, 4
	subi	%g13, %g13, 1
	jmp	init_vecset_constants.3079
jge_else.8183:
	return

!==============================
! args = []
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g2, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f29, %f28, %f26, %f22, %f21, %f20, %f2, %f19, %f17, %f16, %f15, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
init_dirvecs.3081:
	addi	%g8, %g0, 4
	subi	%g1, %g1, 4
	call	create_dirvecs.3074
	addi	%g10, %g0, 9
	addi	%g7, %g0, 0
	addi	%g8, %g0, 0
	call	calc_dirvec_rows.3065
	addi	%g1, %g1, 4
	addi	%g13, %g0, 4
	jmp	init_vecset_constants.3079

!==============================
! args = [%g12, %g11]
! fargs = [%f9, %f2, %f1, %f0]
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g2, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f21, %f2, %f19, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
add_reflection.3083:
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	create_dirvec.3069
	mov	%g9, %g3
	mov	%g3, %g9
	call	d_vec.2734
	addi	%g1, %g1, 8
	fldi	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	vecset.2627
	addi	%g1, %g1, 8
	sti	%g9, %g1, 4
	subi	%g1, %g1, 12
	call	setup_dirvec_constants.2863
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
setup_rect_reflection.3090:
	slli	%g14, %g3, 2
	ldi	%g13, %g31, 1720
	mov	%g3, %g4
	subi	%g1, %g1, 4
	call	o_diffuse.2697
	fsub	%f9, %f17, %f0
	fldi	%f2, %g31, 308
	fmov	%f0, %f2
	call	fneg.2539
	fmov	%f11, %f0
	fldi	%f0, %g31, 304
	call	fneg.2539
	fmov	%f10, %f0
	fldi	%f0, %g31, 300
	call	fneg.2539
	addi	%g1, %g1, 4
	addi	%g11, %g14, 1
	fsti	%f0, %g1, 0
	fsti	%f9, %g1, 4
	mov	%g12, %g13
	fmov	%f1, %f10
	subi	%g1, %g1, 12
	call	add_reflection.3083
	addi	%g1, %g1, 12
	addi	%g12, %g13, 1
	addi	%g11, %g14, 2
	fldi	%f1, %g31, 304
	fldi	%f9, %g1, 4
	fldi	%f0, %g1, 0
	fmov	%f2, %f11
	subi	%g1, %g1, 12
	call	add_reflection.3083
	addi	%g1, %g1, 12
	addi	%g12, %g13, 2
	addi	%g11, %g14, 3
	fldi	%f0, %g31, 300
	fldi	%f9, %g1, 4
	fmov	%f1, %f10
	fmov	%f2, %f11
	subi	%g1, %g1, 12
	call	add_reflection.3083
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
setup_surface_reflection.3093:
	slli	%g3, %g3, 2
	addi	%g11, %g3, 1
	ldi	%g12, %g31, 1720
	mov	%g3, %g5
	subi	%g1, %g1, 4
	call	o_diffuse.2697
	fsub	%f9, %f17, %f0
	mov	%g3, %g5
	call	o_param_abc.2689
	subi	%g4, %g31, 308
	call	veciprod.2648
	fmov	%f3, %f0
	mov	%g3, %g5
	call	o_param_a.2683
	fmul	%f0, %f20, %f0
	fmul	%f1, %f0, %f3
	fldi	%f0, %g31, 308
	fsub	%f2, %f1, %f0
	mov	%g3, %g5
	call	o_param_b.2685
	fmul	%f0, %f20, %f0
	fmul	%f1, %f0, %f3
	fldi	%f0, %g31, 304
	fsub	%f1, %f1, %f0
	mov	%g3, %g5
	call	o_param_c.2687
	addi	%g1, %g1, 4
	fmul	%f0, %f20, %f0
	fmul	%f3, %f0, %f3
	fldi	%f0, %g31, 300
	fsub	%f0, %f3, %f0
	sti	%g12, %g1, 0
	subi	%g1, %g1, 8
	call	add_reflection.3083
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
setup_reflections.3096:
	jlt	%g15, %g0, jge_else.8188
	slli	%g3, %g15, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 272
	mov	%g3, %g4
	subi	%g1, %g1, 4
	call	o_reflectiontype.2677
	addi	%g1, %g1, 4
	addi	%g5, %g0, 2
	jne	%g3, %g5, jeq_else.8189
	mov	%g3, %g4
	subi	%g1, %g1, 4
	call	o_diffuse.2697
	fmov	%f1, %f0
	fmov	%f0, %f17
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.8190
	return
jeq_else.8190:
	mov	%g3, %g4
	subi	%g1, %g1, 4
	call	o_form.2675
	addi	%g1, %g1, 4
	jne	%g3, %g28, jeq_else.8192
	mov	%g3, %g15
	jmp	setup_rect_reflection.3090
jeq_else.8192:
	addi	%g5, %g0, 2
	jne	%g3, %g5, jeq_else.8193
	mov	%g5, %g4
	mov	%g3, %g15
	jmp	setup_surface_reflection.3093
jeq_else.8193:
	return
jeq_else.8189:
	return
jge_else.8188:
	return

!==============================
! args = [%g6, %g3]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g2, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f29, %f28, %f27, %f26, %f25, %f24, %f23, %f22, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
rt.3098:
	sti	%g6, %g31, 600
	sti	%g3, %g31, 596
	srli	%g4, %g6, 1
	sti	%g4, %g31, 608
	srli	%g3, %g3, 1
	sti	%g3, %g31, 604
	setL %g3, l.7510
	fldi	%f3, %g3, 0
	mov	%g3, %g6
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fdiv	%f0, %f3, %f0
	fsti	%f0, %g31, 612
	call	create_pixelline.3047
	mov	%g18, %g3
	call	create_pixelline.3047
	mov	%g25, %g3
	call	create_pixelline.3047
	mov	%g19, %g3
	call	read_parameter.2765
	call	write_ppm_header.3008
	call	init_dirvecs.3081
	subi	%g3, %g31, 980
	call	d_vec.2734
	mov	%g4, %g3
	subi	%g3, %g31, 308
	call	veccpy.2637
	subi	%g9, %g31, 980
	call	setup_dirvec_constants.2863
	ldi	%g3, %g31, 28
	subi	%g15, %g3, 1
	call	setup_reflections.3096
	addi	%g1, %g1, 4
	addi	%g3, %g0, 0
	addi	%g26, %g0, 0
	sti	%g19, %g1, 0
	sti	%g25, %g1, 4
	sti	%g18, %g1, 8
	subi	%g1, %g1, 16
	call	pretrace_line.3024
	addi	%g1, %g1, 16
	addi	%g26, %g0, 0
	addi	%g4, %g0, 2
	ldi	%g18, %g1, 8
	ldi	%g25, %g1, 4
	ldi	%g19, %g1, 0
	mov	%g15, %g19
	mov	%g16, %g25
	mov	%g14, %g18
	jmp	scan_line.3034
