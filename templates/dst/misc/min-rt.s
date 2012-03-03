.init_heap_size	1952
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
l.46193:	! 150.000000
	.long	0x43160000
l.46189:	! -150.000000
	.long	0xc3160000
l.45741:	! -2.000000
	.long	0xc0000000
l.45719:	! 0.003906
	.long	0x3b800000
l.45675:	! 20.000000
	.long	0x41a00000
l.45673:	! 0.050000
	.long	0x3d4cccc4
l.45653:	! 0.250000
	.long	0x3e800000
l.45634:	! 10.000000
	.long	0x41200000
l.45623:	! 0.300000
	.long	0x3e999999
l.45619:	! 0.150000
	.long	0x3e199999
l.45584:	! 3.141593
	.long	0x40490fda
l.45582:	! 30.000000
	.long	0x41f00000
l.45580:	! -1.570796
	.long	0xbfc90fda
l.45575:	! 4.000000
	.long	0x40800000
l.45571:	! 16.000000
	.long	0x41800000
l.45569:	! 11.000000
	.long	0x41300000
l.45567:	! 25.000000
	.long	0x41c80000
l.45565:	! 13.000000
	.long	0x41500000
l.45563:	! 36.000000
	.long	0x42100000
l.45560:	! 49.000000
	.long	0x42440000
l.45558:	! 17.000000
	.long	0x41880000
l.45556:	! 64.000000
	.long	0x42800000
l.45554:	! 19.000000
	.long	0x41980000
l.45552:	! 81.000000
	.long	0x42a20000
l.45550:	! 21.000000
	.long	0x41a80000
l.45548:	! 100.000000
	.long	0x42c80000
l.45546:	! 23.000000
	.long	0x41b80000
l.45544:	! 121.000000
	.long	0x42f20000
l.45540:	! 15.000000
	.long	0x41700000
l.45538:	! 0.000100
	.long	0x38d1b70f
l.45368:	! 100000000.000000
	.long	0x4cbebc20
l.44633:	! -0.100000
	.long	0xbdccccc4
l.44447:	! 0.010000
	.long	0x3c23d70a
l.44445:	! -0.200000
	.long	0xbe4cccc4
l.43888:	! -1.000000
	.long	0xbf800000
l.43078:	! 0.100000
	.long	0x3dccccc4
l.43076:	! 0.900000
	.long	0x3f66665e
l.43074:	! 0.200000
	.long	0x3e4cccc4
l.42900:	! -200.000000
	.long	0xc3480000
l.42897:	! 200.000000
	.long	0x43480000
l.42869:	! 3.000000
	.long	0x40400000
l.42867:	! 5.000000
	.long	0x40a00000
l.42865:	! 9.000000
	.long	0x41100000
l.42863:	! 7.000000
	.long	0x40e00000
l.42861:	! 1.000000
	.long	0x3f800000
l.42859:	! 0.017453
	.long	0x3c8efa2d
l.42650:	! 128.000000
	.long	0x43000000
l.42627:	! 1000000000.000000
	.long	0x4e6e6b28
l.42623:	! 255.000000
	.long	0x437f0000
l.42609:	! 0.000000
	.long	0x0
l.42607:	! 1.570796
	.long	0x3fc90fda
l.42605:	! 0.500000
	.long	0x3f000000
l.42603:	! 6.283185
	.long	0x40c90fda
l.42601:	! 2.000000
	.long	0x40000000
l.42599:	! 3.141593
	.long	0x40490fda
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
	subi	%g1, %g1, 2376
	addi	%g28, %g0, 1
	addi	%g29, %g0, -1
	setL %g27, l.42609
	fldi	%f16, %g27, 0
	setL %g27, l.42861
	fldi	%f17, %g27, 0
	setL %g27, l.46193
	fldi	%f18, %g27, 0
	setL %g27, l.46189
	fldi	%f19, %g27, 0
	setL %g27, l.43888
	fldi	%f20, %g27, 0
	setL %g27, l.42605
	fldi	%f21, %g27, 0
	setL %g27, l.42607
	fldi	%f22, %g27, 0
	setL %g27, l.42869
	fldi	%f23, %g27, 0
	setL %g27, l.42867
	fldi	%f24, %g27, 0
	setL %g27, l.42865
	fldi	%f25, %g27, 0
	setL %g27, l.42863
	fldi	%f26, %g27, 0
	setL %g27, l.42623
	fldi	%f27, %g27, 0
	setL %g27, l.45540
	fldi	%f28, %g27, 0
	setL %g27, l.42603
	fldi	%f29, %g27, 0
	setL %g27, l.45584
	fldi	%f30, %g27, 0
	setL %g27, l.45580
	fldi	%f31, %g27, 0
	setL %g3, l.42599
	fldi	%f5, %g3, 0
	setL %g3, l.42601
	fldi	%f10, %g3, 0
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 4
	subi	%g1, %g1, 4
	call	min_caml_create_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 8
	call	min_caml_create_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 12
	call	min_caml_create_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 16
	call	min_caml_create_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 1
	addi	%g4, %g0, 1
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 20
	call	min_caml_create_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 24
	call	min_caml_create_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 28
	call	min_caml_create_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 32
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g4, %g3
	ldi	%g2, %g31, 2372
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
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 272
	mov	%g4, %g3
	mov	%g3, %g6
	call	min_caml_create_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 284
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 296
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 308
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 1
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 312
	fmov	%f0, %f27
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g6, %g0, 50
	addi	%g3, %g0, 1
	addi	%g4, %g0, -1
	call	min_caml_create_array
	mov	%g4, %g3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 512
	mov	%g3, %g6
	call	min_caml_create_array
	ldi	%g2, %g31, 2372
	addi	%g6, %g0, 1
	addi	%g3, %g0, 1
	ldi	%g4, %g31, 512
	call	min_caml_create_array
	mov	%g4, %g3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 516
	mov	%g3, %g6
	call	min_caml_create_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 1
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 520
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 524
	call	min_caml_create_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 1
	setL %g4, l.42627
	fldi	%f0, %g4, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 528
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 540
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 544
	call	min_caml_create_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 556
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 568
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 580
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 592
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 2
	addi	%g4, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 600
	call	min_caml_create_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 2
	addi	%g4, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 608
	call	min_caml_create_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 1
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 612
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 624
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 636
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 648
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 660
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 672
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 684
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 688
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g7, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 692
	subi	%g4, %g31, 688
	call	min_caml_create_array
	mov	%g4, %g3
	ldi	%g2, %g31, 2372
	addi	%g6, %g0, 0
	mov	%g3, %g2
	addi	%g2, %g2, 8
	sti	%g4, %g3, -4
	sti	%g7, %g3, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 696
	mov	%g4, %g3
	mov	%g3, %g6
	call	min_caml_create_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 5
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 716
	subi	%g4, %g31, 696
	call	min_caml_create_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 720
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 732
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g6, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 60
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 972
	subi	%g4, %g31, 720
	call	min_caml_create_array
	mov	%g4, %g3
	ldi	%g2, %g31, 2372
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 980
	mov	%g3, %g2
	addi	%g2, %g2, 8
	sti	%g4, %g3, -4
	sti	%g6, %g3, 0
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 984
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g6, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 988
	subi	%g4, %g31, 984
	call	min_caml_create_array
	ldi	%g2, %g31, 2372
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 996
	mov	%g4, %g2
	addi	%g2, %g2, 8
	sti	%g3, %g4, -4
	sti	%g6, %g4, 0
	ldi	%g2, %g31, 2372
	addi	%g6, %g0, 180
	addi	%g5, %g0, 0
	mov	%g3, %g2
	addi	%g2, %g2, 12
	fsti	%f16, %g3, -8
	sti	%g4, %g3, -4
	sti	%g5, %g3, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 1716
	mov	%g4, %g3
	mov	%g3, %g6
	call	min_caml_create_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 1720
	call	min_caml_create_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 128
	addi	%g4, %g0, 128
	sti	%g3, %g31, 600
	sti	%g4, %g31, 596
	addi	%g4, %g0, 64
	sti	%g4, %g31, 608
	addi	%g4, %g0, 64
	sti	%g4, %g31, 604
	setL %g4, l.42650
	fldi	%f3, %g4, 0
	call	min_caml_float_of_int
	fdiv	%f0, %f3, %f0
	fsti	%f0, %g31, 612
	ldi	%g12, %g31, 600
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 1732
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g11, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 1744
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 5
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 1764
	subi	%g4, %g31, 1744
	call	min_caml_create_array
	mov	%g10, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 1760
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 1756
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 1752
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 1748
	addi	%g3, %g0, 5
	addi	%g4, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 1784
	call	min_caml_create_array
	mov	%g9, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 5
	addi	%g4, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 1804
	call	min_caml_create_array
	mov	%g8, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 1816
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 5
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 1836
	subi	%g4, %g31, 1816
	call	min_caml_create_array
	mov	%g7, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 1832
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 1828
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 1824
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 1820
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 1848
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 5
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 1868
	subi	%g4, %g31, 1848
	call	min_caml_create_array
	mov	%g6, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 1864
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 1860
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 1856
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 1852
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 1872
	call	min_caml_create_array
	mov	%g13, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 1884
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 5
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 1904
	subi	%g4, %g31, 1884
	call	min_caml_create_array
	mov	%g5, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 1900
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 1896
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 1892
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 1888
	mov	%g3, %g2
	addi	%g2, %g2, 32
	sti	%g5, %g3, -28
	sti	%g13, %g3, -24
	sti	%g6, %g3, -20
	sti	%g7, %g3, -16
	sti	%g8, %g3, -12
	sti	%g9, %g3, -8
	sti	%g10, %g3, -4
	sti	%g11, %g3, 0
	mov	%g4, %g3
	mov	%g3, %g12
	call	min_caml_create_array
	mov	%g10, %g3
	sti	%g10, %g31, 1908
	ldi	%g3, %g31, 600
	subi	%g9, %g3, 2
	call	init_line_elements.3044
	mov	%g19, %g3
	sti	%g19, %g31, 1912
	ldi	%g12, %g31, 600
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 1924
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g11, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 1936
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 5
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 1956
	subi	%g4, %g31, 1936
	call	min_caml_create_array
	mov	%g10, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 1952
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 1948
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 1944
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 1940
	addi	%g3, %g0, 5
	addi	%g4, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 1976
	call	min_caml_create_array
	mov	%g9, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 5
	addi	%g4, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 1996
	call	min_caml_create_array
	mov	%g8, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 2008
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 5
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 2028
	subi	%g4, %g31, 2008
	call	min_caml_create_array
	mov	%g7, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2024
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2020
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2016
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2012
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 2040
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 5
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 2060
	subi	%g4, %g31, 2040
	call	min_caml_create_array
	mov	%g6, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2056
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2052
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2048
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2044
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 2064
	call	min_caml_create_array
	mov	%g13, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 2076
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 5
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 2096
	subi	%g4, %g31, 2076
	call	min_caml_create_array
	mov	%g5, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2092
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2088
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2084
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2080
	mov	%g3, %g2
	addi	%g2, %g2, 32
	sti	%g5, %g3, -28
	sti	%g13, %g3, -24
	sti	%g6, %g3, -20
	sti	%g7, %g3, -16
	sti	%g8, %g3, -12
	sti	%g9, %g3, -8
	sti	%g10, %g3, -4
	sti	%g11, %g3, 0
	mov	%g4, %g3
	mov	%g3, %g12
	call	min_caml_create_array
	mov	%g10, %g3
	sti	%g10, %g31, 2100
	ldi	%g3, %g31, 600
	subi	%g9, %g3, 2
	call	init_line_elements.3044
	mov	%g17, %g3
	sti	%g17, %g31, 2104
	ldi	%g12, %g31, 600
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 2116
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g11, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 2128
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 5
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 2148
	subi	%g4, %g31, 2128
	call	min_caml_create_array
	mov	%g10, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2144
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2140
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2136
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2132
	addi	%g3, %g0, 5
	addi	%g4, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 2168
	call	min_caml_create_array
	mov	%g9, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 5
	addi	%g4, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 2188
	call	min_caml_create_array
	mov	%g8, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 2200
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 5
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 2220
	subi	%g4, %g31, 2200
	call	min_caml_create_array
	mov	%g7, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2216
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2212
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2208
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2204
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 2232
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 5
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 2252
	subi	%g4, %g31, 2232
	call	min_caml_create_array
	mov	%g6, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2248
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2244
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2240
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2236
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 2256
	call	min_caml_create_array
	mov	%g13, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 2268
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 5
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 2288
	subi	%g4, %g31, 2268
	call	min_caml_create_array
	mov	%g5, %g3
	ldi	%g2, %g31, 2372
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2284
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2280
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2276
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g31, 2272
	mov	%g3, %g2
	addi	%g2, %g2, 32
	sti	%g5, %g3, -28
	sti	%g13, %g3, -24
	sti	%g6, %g3, -20
	sti	%g7, %g3, -16
	sti	%g8, %g3, -12
	sti	%g9, %g3, -8
	sti	%g10, %g3, -4
	sti	%g11, %g3, 0
	mov	%g4, %g3
	mov	%g3, %g12
	call	min_caml_create_array
	mov	%g10, %g3
	sti	%g10, %g31, 2292
	ldi	%g3, %g31, 600
	subi	%g9, %g3, 2
	call	init_line_elements.3044
	addi	%g1, %g1, 4
	mov	%g18, %g3
	sti	%g18, %g31, 2296
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.49644
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.49646
	addi	%g3, %g0, 0
	jmp	jle_cont.49647
jle_else.49646:
	addi	%g3, %g0, 1
jle_cont.49647:
	jmp	jle_cont.49645
jle_else.49644:
	addi	%g3, %g0, 1
jle_cont.49645:
	jne	%g3, %g0, jeq_else.49648
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.49650
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
	jmp	jeq_cont.49651
jeq_else.49650:
jeq_cont.49651:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	jmp	jeq_cont.49649
jeq_else.49648:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
jeq_cont.49649:
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.49652
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.49654
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.49656
	addi	%g4, %g0, 0
	jmp	jle_cont.49657
jle_else.49656:
	addi	%g4, %g0, 1
jle_cont.49657:
	jmp	jle_cont.49655
jle_else.49654:
	addi	%g4, %g0, 1
jle_cont.49655:
	jne	%g4, %g0, jeq_else.49658
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
	jmp	jeq_cont.49659
jeq_else.49658:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
jeq_cont.49659:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmov	%f4, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f3, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f0, %f3, %f0
	fadd	%f0, %f4, %f0
	jmp	jeq_cont.49653
jeq_else.49652:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
jeq_cont.49653:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.49660
	fmov	%f1, %f0
	jmp	jeq_cont.49661
jeq_else.49660:
	fneg	%f1, %f0
jeq_cont.49661:
	fsti	%f1, %g31, 284
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.49662
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.49664
	addi	%g3, %g0, 0
	jmp	jle_cont.49665
jle_else.49664:
	addi	%g3, %g0, 1
jle_cont.49665:
	jmp	jle_cont.49663
jle_else.49662:
	addi	%g3, %g0, 1
jle_cont.49663:
	jne	%g3, %g0, jeq_else.49666
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.49668
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
	jmp	jeq_cont.49669
jeq_else.49668:
jeq_cont.49669:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	jmp	jeq_cont.49667
jeq_else.49666:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
jeq_cont.49667:
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.49670
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.49672
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.49674
	addi	%g4, %g0, 0
	jmp	jle_cont.49675
jle_else.49674:
	addi	%g4, %g0, 1
jle_cont.49675:
	jmp	jle_cont.49673
jle_else.49672:
	addi	%g4, %g0, 1
jle_cont.49673:
	jne	%g4, %g0, jeq_else.49676
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
	jmp	jeq_cont.49677
jeq_else.49676:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
jeq_cont.49677:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmov	%f4, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f3, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f0, %f3, %f0
	fadd	%f0, %f4, %f0
	jmp	jeq_cont.49671
jeq_else.49670:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
jeq_cont.49671:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.49678
	fmov	%f1, %f0
	jmp	jeq_cont.49679
jeq_else.49678:
	fneg	%f1, %f0
jeq_cont.49679:
	fsti	%f1, %g31, 280
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.49680
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.49682
	addi	%g3, %g0, 0
	jmp	jle_cont.49683
jle_else.49682:
	addi	%g3, %g0, 1
jle_cont.49683:
	jmp	jle_cont.49681
jle_else.49680:
	addi	%g3, %g0, 1
jle_cont.49681:
	jne	%g3, %g0, jeq_else.49684
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.49686
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
	jmp	jeq_cont.49687
jeq_else.49686:
jeq_cont.49687:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	jmp	jeq_cont.49685
jeq_else.49684:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
jeq_cont.49685:
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.49688
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.49690
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.49692
	addi	%g4, %g0, 0
	jmp	jle_cont.49693
jle_else.49692:
	addi	%g4, %g0, 1
jle_cont.49693:
	jmp	jle_cont.49691
jle_else.49690:
	addi	%g4, %g0, 1
jle_cont.49691:
	jne	%g4, %g0, jeq_else.49694
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
	jmp	jeq_cont.49695
jeq_else.49694:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
jeq_cont.49695:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmov	%f4, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f3, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f0, %f3, %f0
	fadd	%f0, %f4, %f0
	jmp	jeq_cont.49689
jeq_else.49688:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
jeq_cont.49689:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.49696
	fmov	%f1, %f0
	jmp	jeq_cont.49697
jeq_else.49696:
	fneg	%f1, %f0
jeq_cont.49697:
	fsti	%f1, %g31, 276
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.49698
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.49700
	addi	%g3, %g0, 0
	jmp	jle_cont.49701
jle_else.49700:
	addi	%g3, %g0, 1
jle_cont.49701:
	jmp	jle_cont.49699
jle_else.49698:
	addi	%g3, %g0, 1
jle_cont.49699:
	jne	%g3, %g0, jeq_else.49702
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.49704
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
	jmp	jeq_cont.49705
jeq_else.49704:
jeq_cont.49705:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	jmp	jeq_cont.49703
jeq_else.49702:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
jeq_cont.49703:
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.49706
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.49708
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.49710
	addi	%g4, %g0, 0
	jmp	jle_cont.49711
jle_else.49710:
	addi	%g4, %g0, 1
jle_cont.49711:
	jmp	jle_cont.49709
jle_else.49708:
	addi	%g4, %g0, 1
jle_cont.49709:
	jne	%g4, %g0, jeq_else.49712
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
	jmp	jeq_cont.49713
jeq_else.49712:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
jeq_cont.49713:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmov	%f4, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f3, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f0, %f3, %f0
	fadd	%f0, %f4, %f0
	jmp	jeq_cont.49707
jeq_else.49706:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
jeq_cont.49707:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.49714
	fmov	%f1, %f0
	jmp	jeq_cont.49715
jeq_else.49714:
	fneg	%f1, %f0
jeq_cont.49715:
	setL %g3, l.42859
	fldi	%f8, %g3, 0
	fmul	%f3, %f1, %f8
	fsub	%f2, %f22, %f3
	fjlt	%f2, %f16, fjge_else.49716
	fmov	%f1, %f2
	jmp	fjge_cont.49717
fjge_else.49716:
	fneg	%f1, %f2
fjge_cont.49717:
	fjlt	%f29, %f1, fjge_else.49718
	fjlt	%f1, %f16, fjge_else.49720
	fmov	%f0, %f1
	jmp	fjge_cont.49721
fjge_else.49720:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49722
	fjlt	%f1, %f16, fjge_else.49724
	fmov	%f0, %f1
	jmp	fjge_cont.49725
fjge_else.49724:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49726
	fjlt	%f1, %f16, fjge_else.49728
	fmov	%f0, %f1
	jmp	fjge_cont.49729
fjge_else.49728:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49729:
	jmp	fjge_cont.49727
fjge_else.49726:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49727:
fjge_cont.49725:
	jmp	fjge_cont.49723
fjge_else.49722:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49730
	fjlt	%f1, %f16, fjge_else.49732
	fmov	%f0, %f1
	jmp	fjge_cont.49733
fjge_else.49732:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49733:
	jmp	fjge_cont.49731
fjge_else.49730:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49731:
fjge_cont.49723:
fjge_cont.49721:
	jmp	fjge_cont.49719
fjge_else.49718:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49734
	fjlt	%f1, %f16, fjge_else.49736
	fmov	%f0, %f1
	jmp	fjge_cont.49737
fjge_else.49736:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49738
	fjlt	%f1, %f16, fjge_else.49740
	fmov	%f0, %f1
	jmp	fjge_cont.49741
fjge_else.49740:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49741:
	jmp	fjge_cont.49739
fjge_else.49738:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49739:
fjge_cont.49737:
	jmp	fjge_cont.49735
fjge_else.49734:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49742
	fjlt	%f1, %f16, fjge_else.49744
	fmov	%f0, %f1
	jmp	fjge_cont.49745
fjge_else.49744:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49745:
	jmp	fjge_cont.49743
fjge_else.49742:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49743:
fjge_cont.49735:
fjge_cont.49719:
	fjlt	%f5, %f0, fjge_else.49746
	fjlt	%f16, %f2, fjge_else.49748
	addi	%g3, %g0, 0
	jmp	fjge_cont.49749
fjge_else.49748:
	addi	%g3, %g0, 1
fjge_cont.49749:
	jmp	fjge_cont.49747
fjge_else.49746:
	fjlt	%f16, %f2, fjge_else.49750
	addi	%g3, %g0, 1
	jmp	fjge_cont.49751
fjge_else.49750:
	addi	%g3, %g0, 0
fjge_cont.49751:
fjge_cont.49747:
	fjlt	%f5, %f0, fjge_else.49752
	fmov	%f1, %f0
	jmp	fjge_cont.49753
fjge_else.49752:
	fsub	%f1, %f29, %f0
fjge_cont.49753:
	fjlt	%f22, %f1, fjge_else.49754
	fmov	%f0, %f1
	jmp	fjge_cont.49755
fjge_else.49754:
	fsub	%f0, %f5, %f1
fjge_cont.49755:
	fmul	%f1, %f0, %f21
	fmul	%f0, %f1, %f1
	fdiv	%f2, %f0, %f25
	fsub	%f2, %f26, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f24, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f23, %f2
	fdiv	%f0, %f0, %f2
	fsub	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	fmul	%f1, %f10, %f0
	fmul	%f0, %f0, %f0
	fadd	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	jne	%g3, %g0, jeq_else.49756
	fneg	%f7, %f0
	jmp	jeq_cont.49757
jeq_else.49756:
	fmov	%f7, %f0
jeq_cont.49757:
	fjlt	%f3, %f16, fjge_else.49758
	fmov	%f1, %f3
	jmp	fjge_cont.49759
fjge_else.49758:
	fneg	%f1, %f3
fjge_cont.49759:
	fjlt	%f29, %f1, fjge_else.49760
	fjlt	%f1, %f16, fjge_else.49762
	fmov	%f0, %f1
	jmp	fjge_cont.49763
fjge_else.49762:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49764
	fjlt	%f1, %f16, fjge_else.49766
	fmov	%f0, %f1
	jmp	fjge_cont.49767
fjge_else.49766:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49768
	fjlt	%f1, %f16, fjge_else.49770
	fmov	%f0, %f1
	jmp	fjge_cont.49771
fjge_else.49770:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49771:
	jmp	fjge_cont.49769
fjge_else.49768:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49769:
fjge_cont.49767:
	jmp	fjge_cont.49765
fjge_else.49764:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49772
	fjlt	%f1, %f16, fjge_else.49774
	fmov	%f0, %f1
	jmp	fjge_cont.49775
fjge_else.49774:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49775:
	jmp	fjge_cont.49773
fjge_else.49772:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49773:
fjge_cont.49765:
fjge_cont.49763:
	jmp	fjge_cont.49761
fjge_else.49760:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49776
	fjlt	%f1, %f16, fjge_else.49778
	fmov	%f0, %f1
	jmp	fjge_cont.49779
fjge_else.49778:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49780
	fjlt	%f1, %f16, fjge_else.49782
	fmov	%f0, %f1
	jmp	fjge_cont.49783
fjge_else.49782:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49783:
	jmp	fjge_cont.49781
fjge_else.49780:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49781:
fjge_cont.49779:
	jmp	fjge_cont.49777
fjge_else.49776:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49784
	fjlt	%f1, %f16, fjge_else.49786
	fmov	%f0, %f1
	jmp	fjge_cont.49787
fjge_else.49786:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49787:
	jmp	fjge_cont.49785
fjge_else.49784:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49785:
fjge_cont.49777:
fjge_cont.49761:
	fjlt	%f5, %f0, fjge_else.49788
	fjlt	%f16, %f3, fjge_else.49790
	addi	%g3, %g0, 0
	jmp	fjge_cont.49791
fjge_else.49790:
	addi	%g3, %g0, 1
fjge_cont.49791:
	jmp	fjge_cont.49789
fjge_else.49788:
	fjlt	%f16, %f3, fjge_else.49792
	addi	%g3, %g0, 1
	jmp	fjge_cont.49793
fjge_else.49792:
	addi	%g3, %g0, 0
fjge_cont.49793:
fjge_cont.49789:
	fjlt	%f5, %f0, fjge_else.49794
	fmov	%f1, %f0
	jmp	fjge_cont.49795
fjge_else.49794:
	fsub	%f1, %f29, %f0
fjge_cont.49795:
	fjlt	%f22, %f1, fjge_else.49796
	fmov	%f0, %f1
	jmp	fjge_cont.49797
fjge_else.49796:
	fsub	%f0, %f5, %f1
fjge_cont.49797:
	fmul	%f1, %f0, %f21
	fmul	%f0, %f1, %f1
	fdiv	%f2, %f0, %f25
	fsub	%f2, %f26, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f24, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f23, %f2
	fdiv	%f0, %f0, %f2
	fsub	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	fmul	%f1, %f10, %f0
	fmul	%f0, %f0, %f0
	fadd	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	jne	%g3, %g0, jeq_else.49798
	fneg	%f6, %f0
	jmp	jeq_cont.49799
jeq_else.49798:
	fmov	%f6, %f0
jeq_cont.49799:
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.49800
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.49802
	addi	%g3, %g0, 0
	jmp	jle_cont.49803
jle_else.49802:
	addi	%g3, %g0, 1
jle_cont.49803:
	jmp	jle_cont.49801
jle_else.49800:
	addi	%g3, %g0, 1
jle_cont.49801:
	jne	%g3, %g0, jeq_else.49804
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.49806
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
	jmp	jeq_cont.49807
jeq_else.49806:
jeq_cont.49807:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	jmp	jeq_cont.49805
jeq_else.49804:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
jeq_cont.49805:
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.49808
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.49810
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.49812
	addi	%g4, %g0, 0
	jmp	jle_cont.49813
jle_else.49812:
	addi	%g4, %g0, 1
jle_cont.49813:
	jmp	jle_cont.49811
jle_else.49810:
	addi	%g4, %g0, 1
jle_cont.49811:
	jne	%g4, %g0, jeq_else.49814
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
	jmp	jeq_cont.49815
jeq_else.49814:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
jeq_cont.49815:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmov	%f4, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f3, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f0, %f3, %f0
	fadd	%f0, %f4, %f0
	jmp	jeq_cont.49809
jeq_else.49808:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
jeq_cont.49809:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.49816
	fmov	%f1, %f0
	jmp	jeq_cont.49817
jeq_else.49816:
	fneg	%f1, %f0
jeq_cont.49817:
	fmul	%f3, %f1, %f8
	fsub	%f2, %f22, %f3
	fjlt	%f2, %f16, fjge_else.49818
	fmov	%f1, %f2
	jmp	fjge_cont.49819
fjge_else.49818:
	fneg	%f1, %f2
fjge_cont.49819:
	fjlt	%f29, %f1, fjge_else.49820
	fjlt	%f1, %f16, fjge_else.49822
	fmov	%f0, %f1
	jmp	fjge_cont.49823
fjge_else.49822:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49824
	fjlt	%f1, %f16, fjge_else.49826
	fmov	%f0, %f1
	jmp	fjge_cont.49827
fjge_else.49826:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49828
	fjlt	%f1, %f16, fjge_else.49830
	fmov	%f0, %f1
	jmp	fjge_cont.49831
fjge_else.49830:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49831:
	jmp	fjge_cont.49829
fjge_else.49828:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49829:
fjge_cont.49827:
	jmp	fjge_cont.49825
fjge_else.49824:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49832
	fjlt	%f1, %f16, fjge_else.49834
	fmov	%f0, %f1
	jmp	fjge_cont.49835
fjge_else.49834:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49835:
	jmp	fjge_cont.49833
fjge_else.49832:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49833:
fjge_cont.49825:
fjge_cont.49823:
	jmp	fjge_cont.49821
fjge_else.49820:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49836
	fjlt	%f1, %f16, fjge_else.49838
	fmov	%f0, %f1
	jmp	fjge_cont.49839
fjge_else.49838:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49840
	fjlt	%f1, %f16, fjge_else.49842
	fmov	%f0, %f1
	jmp	fjge_cont.49843
fjge_else.49842:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49843:
	jmp	fjge_cont.49841
fjge_else.49840:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49841:
fjge_cont.49839:
	jmp	fjge_cont.49837
fjge_else.49836:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49844
	fjlt	%f1, %f16, fjge_else.49846
	fmov	%f0, %f1
	jmp	fjge_cont.49847
fjge_else.49846:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49847:
	jmp	fjge_cont.49845
fjge_else.49844:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49845:
fjge_cont.49837:
fjge_cont.49821:
	fjlt	%f5, %f0, fjge_else.49848
	fjlt	%f16, %f2, fjge_else.49850
	addi	%g3, %g0, 0
	jmp	fjge_cont.49851
fjge_else.49850:
	addi	%g3, %g0, 1
fjge_cont.49851:
	jmp	fjge_cont.49849
fjge_else.49848:
	fjlt	%f16, %f2, fjge_else.49852
	addi	%g3, %g0, 1
	jmp	fjge_cont.49853
fjge_else.49852:
	addi	%g3, %g0, 0
fjge_cont.49853:
fjge_cont.49849:
	fjlt	%f5, %f0, fjge_else.49854
	fmov	%f1, %f0
	jmp	fjge_cont.49855
fjge_else.49854:
	fsub	%f1, %f29, %f0
fjge_cont.49855:
	fjlt	%f22, %f1, fjge_else.49856
	fmov	%f0, %f1
	jmp	fjge_cont.49857
fjge_else.49856:
	fsub	%f0, %f5, %f1
fjge_cont.49857:
	fmul	%f1, %f0, %f21
	fmul	%f0, %f1, %f1
	fdiv	%f2, %f0, %f25
	fsub	%f2, %f26, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f24, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f23, %f2
	fdiv	%f0, %f0, %f2
	fsub	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	fmul	%f1, %f10, %f0
	fmul	%f0, %f0, %f0
	fadd	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	jne	%g3, %g0, jeq_else.49858
	fneg	%f2, %f0
	jmp	jeq_cont.49859
jeq_else.49858:
	fmov	%f2, %f0
jeq_cont.49859:
	fjlt	%f3, %f16, fjge_else.49860
	fmov	%f1, %f3
	jmp	fjge_cont.49861
fjge_else.49860:
	fneg	%f1, %f3
fjge_cont.49861:
	fjlt	%f29, %f1, fjge_else.49862
	fjlt	%f1, %f16, fjge_else.49864
	fmov	%f0, %f1
	jmp	fjge_cont.49865
fjge_else.49864:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49866
	fjlt	%f1, %f16, fjge_else.49868
	fmov	%f0, %f1
	jmp	fjge_cont.49869
fjge_else.49868:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49870
	fjlt	%f1, %f16, fjge_else.49872
	fmov	%f0, %f1
	jmp	fjge_cont.49873
fjge_else.49872:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49873:
	jmp	fjge_cont.49871
fjge_else.49870:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49871:
fjge_cont.49869:
	jmp	fjge_cont.49867
fjge_else.49866:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49874
	fjlt	%f1, %f16, fjge_else.49876
	fmov	%f0, %f1
	jmp	fjge_cont.49877
fjge_else.49876:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49877:
	jmp	fjge_cont.49875
fjge_else.49874:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49875:
fjge_cont.49867:
fjge_cont.49865:
	jmp	fjge_cont.49863
fjge_else.49862:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49878
	fjlt	%f1, %f16, fjge_else.49880
	fmov	%f0, %f1
	jmp	fjge_cont.49881
fjge_else.49880:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49882
	fjlt	%f1, %f16, fjge_else.49884
	fmov	%f0, %f1
	jmp	fjge_cont.49885
fjge_else.49884:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49885:
	jmp	fjge_cont.49883
fjge_else.49882:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49883:
fjge_cont.49881:
	jmp	fjge_cont.49879
fjge_else.49878:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49886
	fjlt	%f1, %f16, fjge_else.49888
	fmov	%f0, %f1
	jmp	fjge_cont.49889
fjge_else.49888:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49889:
	jmp	fjge_cont.49887
fjge_else.49886:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49887:
fjge_cont.49879:
fjge_cont.49863:
	fjlt	%f5, %f0, fjge_else.49890
	fjlt	%f16, %f3, fjge_else.49892
	addi	%g3, %g0, 0
	jmp	fjge_cont.49893
fjge_else.49892:
	addi	%g3, %g0, 1
fjge_cont.49893:
	jmp	fjge_cont.49891
fjge_else.49890:
	fjlt	%f16, %f3, fjge_else.49894
	addi	%g3, %g0, 1
	jmp	fjge_cont.49895
fjge_else.49894:
	addi	%g3, %g0, 0
fjge_cont.49895:
fjge_cont.49891:
	fjlt	%f5, %f0, fjge_else.49896
	fmov	%f1, %f0
	jmp	fjge_cont.49897
fjge_else.49896:
	fsub	%f1, %f29, %f0
fjge_cont.49897:
	fjlt	%f22, %f1, fjge_else.49898
	fmov	%f0, %f1
	jmp	fjge_cont.49899
fjge_else.49898:
	fsub	%f0, %f5, %f1
fjge_cont.49899:
	fmul	%f1, %f0, %f21
	fmul	%f0, %f1, %f1
	fdiv	%f3, %f0, %f25
	fsub	%f3, %f26, %f3
	fdiv	%f3, %f0, %f3
	fsub	%f3, %f24, %f3
	fdiv	%f3, %f0, %f3
	fsub	%f3, %f23, %f3
	fdiv	%f0, %f0, %f3
	fsub	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	fmul	%f1, %f10, %f0
	fmul	%f0, %f0, %f0
	fadd	%f0, %f17, %f0
	fdiv	%f1, %f1, %f0
	jne	%g3, %g0, jeq_else.49900
	fneg	%f0, %f1
	jmp	jeq_cont.49901
jeq_else.49900:
	fmov	%f0, %f1
jeq_cont.49901:
	fmul	%f3, %f7, %f0
	setL %g3, l.42897
	fldi	%f1, %g3, 0
	fmul	%f3, %f3, %f1
	fsti	%f3, %g31, 672
	setL %g3, l.42900
	fldi	%f3, %g3, 0
	fmul	%f3, %f6, %f3
	fsti	%f3, %g31, 668
	fmul	%f3, %f7, %f2
	fmul	%f1, %f3, %f1
	fsti	%f1, %g31, 664
	fsti	%f2, %g31, 648
	fsti	%f16, %g31, 644
	fneg	%f1, %f0
	fsti	%f1, %g31, 640
	fneg	%f1, %f6
	fmul	%f0, %f1, %f0
	fsti	%f0, %g31, 660
	fneg	%f7, %f7
	fsti	%f7, %g31, 656
	fmul	%f0, %f1, %f2
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
	addi	%g3, %g0, 0
	sti	%g3, %g31, 4
	addi	%g3, %g0, 0
	sti	%g3, %g31, 8
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.49902
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.49904
	addi	%g3, %g0, 0
	jmp	jle_cont.49905
jle_else.49904:
	addi	%g3, %g0, 1
jle_cont.49905:
	jmp	jle_cont.49903
jle_else.49902:
	addi	%g3, %g0, 1
jle_cont.49903:
	jne	%g3, %g0, jeq_else.49906
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.49908
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
	jmp	jeq_cont.49909
jeq_else.49908:
jeq_cont.49909:
	ldi	%g3, %g31, 4
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 4
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
	jmp	jeq_cont.49907
jeq_else.49906:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
jeq_cont.49907:
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.49910
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.49912
	addi	%g3, %g0, 0
	jmp	jle_cont.49913
jle_else.49912:
	addi	%g3, %g0, 1
jle_cont.49913:
	jmp	jle_cont.49911
jle_else.49910:
	addi	%g3, %g0, 1
jle_cont.49911:
	jne	%g3, %g0, jeq_else.49914
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.49916
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
	jmp	jeq_cont.49917
jeq_else.49916:
jeq_cont.49917:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	jmp	jeq_cont.49915
jeq_else.49914:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
jeq_cont.49915:
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.49918
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.49920
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.49922
	addi	%g4, %g0, 0
	jmp	jle_cont.49923
jle_else.49922:
	addi	%g4, %g0, 1
jle_cont.49923:
	jmp	jle_cont.49921
jle_else.49920:
	addi	%g4, %g0, 1
jle_cont.49921:
	jne	%g4, %g0, jeq_else.49924
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
	jmp	jeq_cont.49925
jeq_else.49924:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
jeq_cont.49925:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmov	%f4, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f3, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f0, %f3, %f0
	fadd	%f0, %f4, %f0
	jmp	jeq_cont.49919
jeq_else.49918:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
jeq_cont.49919:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.49926
	fmov	%f1, %f0
	jmp	jeq_cont.49927
jeq_else.49926:
	fneg	%f1, %f0
jeq_cont.49927:
	fmul	%f3, %f1, %f8
	fjlt	%f3, %f16, fjge_else.49928
	fmov	%f1, %f3
	jmp	fjge_cont.49929
fjge_else.49928:
	fneg	%f1, %f3
fjge_cont.49929:
	fjlt	%f29, %f1, fjge_else.49930
	fjlt	%f1, %f16, fjge_else.49932
	fmov	%f0, %f1
	jmp	fjge_cont.49933
fjge_else.49932:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49934
	fjlt	%f1, %f16, fjge_else.49936
	fmov	%f0, %f1
	jmp	fjge_cont.49937
fjge_else.49936:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49938
	fjlt	%f1, %f16, fjge_else.49940
	fmov	%f0, %f1
	jmp	fjge_cont.49941
fjge_else.49940:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49941:
	jmp	fjge_cont.49939
fjge_else.49938:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49939:
fjge_cont.49937:
	jmp	fjge_cont.49935
fjge_else.49934:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49942
	fjlt	%f1, %f16, fjge_else.49944
	fmov	%f0, %f1
	jmp	fjge_cont.49945
fjge_else.49944:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49945:
	jmp	fjge_cont.49943
fjge_else.49942:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49943:
fjge_cont.49935:
fjge_cont.49933:
	jmp	fjge_cont.49931
fjge_else.49930:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49946
	fjlt	%f1, %f16, fjge_else.49948
	fmov	%f0, %f1
	jmp	fjge_cont.49949
fjge_else.49948:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49950
	fjlt	%f1, %f16, fjge_else.49952
	fmov	%f0, %f1
	jmp	fjge_cont.49953
fjge_else.49952:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49953:
	jmp	fjge_cont.49951
fjge_else.49950:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49951:
fjge_cont.49949:
	jmp	fjge_cont.49947
fjge_else.49946:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49954
	fjlt	%f1, %f16, fjge_else.49956
	fmov	%f0, %f1
	jmp	fjge_cont.49957
fjge_else.49956:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49957:
	jmp	fjge_cont.49955
fjge_else.49954:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49955:
fjge_cont.49947:
fjge_cont.49931:
	fjlt	%f5, %f0, fjge_else.49958
	fjlt	%f16, %f3, fjge_else.49960
	addi	%g3, %g0, 0
	jmp	fjge_cont.49961
fjge_else.49960:
	addi	%g3, %g0, 1
fjge_cont.49961:
	jmp	fjge_cont.49959
fjge_else.49958:
	fjlt	%f16, %f3, fjge_else.49962
	addi	%g3, %g0, 1
	jmp	fjge_cont.49963
fjge_else.49962:
	addi	%g3, %g0, 0
fjge_cont.49963:
fjge_cont.49959:
	fjlt	%f5, %f0, fjge_else.49964
	fmov	%f1, %f0
	jmp	fjge_cont.49965
fjge_else.49964:
	fsub	%f1, %f29, %f0
fjge_cont.49965:
	fjlt	%f22, %f1, fjge_else.49966
	fmov	%f0, %f1
	jmp	fjge_cont.49967
fjge_else.49966:
	fsub	%f0, %f5, %f1
fjge_cont.49967:
	fmul	%f1, %f0, %f21
	fmul	%f0, %f1, %f1
	fdiv	%f2, %f0, %f25
	fsub	%f2, %f26, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f24, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f23, %f2
	fdiv	%f0, %f0, %f2
	fsub	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	fmul	%f1, %f10, %f0
	fmul	%f0, %f0, %f0
	fadd	%f0, %f17, %f0
	fdiv	%f1, %f1, %f0
	jne	%g3, %g0, jeq_else.49968
	fneg	%f0, %f1
	jmp	jeq_cont.49969
jeq_else.49968:
	fmov	%f0, %f1
jeq_cont.49969:
	fneg	%f0, %f0
	fsti	%f0, %g31, 304
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.49970
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.49972
	addi	%g3, %g0, 0
	jmp	jle_cont.49973
jle_else.49972:
	addi	%g3, %g0, 1
jle_cont.49973:
	jmp	jle_cont.49971
jle_else.49970:
	addi	%g3, %g0, 1
jle_cont.49971:
	jne	%g3, %g0, jeq_else.49974
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.49976
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
	jmp	jeq_cont.49977
jeq_else.49976:
jeq_cont.49977:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	jmp	jeq_cont.49975
jeq_else.49974:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
jeq_cont.49975:
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.49978
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.49980
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.49982
	addi	%g4, %g0, 0
	jmp	jle_cont.49983
jle_else.49982:
	addi	%g4, %g0, 1
jle_cont.49983:
	jmp	jle_cont.49981
jle_else.49980:
	addi	%g4, %g0, 1
jle_cont.49981:
	jne	%g4, %g0, jeq_else.49984
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
	jmp	jeq_cont.49985
jeq_else.49984:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
jeq_cont.49985:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmov	%f6, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f4, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f0, %f4, %f0
	fadd	%f0, %f6, %f0
	jmp	jeq_cont.49979
jeq_else.49978:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
jeq_cont.49979:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.49986
	fmov	%f1, %f0
	jmp	jeq_cont.49987
jeq_else.49986:
	fneg	%f1, %f0
jeq_cont.49987:
	fmul	%f4, %f1, %f8
	fsub	%f2, %f22, %f3
	fjlt	%f2, %f16, fjge_else.49988
	fmov	%f1, %f2
	jmp	fjge_cont.49989
fjge_else.49988:
	fneg	%f1, %f2
fjge_cont.49989:
	fjlt	%f29, %f1, fjge_else.49990
	fjlt	%f1, %f16, fjge_else.49992
	fmov	%f0, %f1
	jmp	fjge_cont.49993
fjge_else.49992:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49994
	fjlt	%f1, %f16, fjge_else.49996
	fmov	%f0, %f1
	jmp	fjge_cont.49997
fjge_else.49996:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.49998
	fjlt	%f1, %f16, fjge_else.50000
	fmov	%f0, %f1
	jmp	fjge_cont.50001
fjge_else.50000:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50001:
	jmp	fjge_cont.49999
fjge_else.49998:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.49999:
fjge_cont.49997:
	jmp	fjge_cont.49995
fjge_else.49994:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50002
	fjlt	%f1, %f16, fjge_else.50004
	fmov	%f0, %f1
	jmp	fjge_cont.50005
fjge_else.50004:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50005:
	jmp	fjge_cont.50003
fjge_else.50002:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50003:
fjge_cont.49995:
fjge_cont.49993:
	jmp	fjge_cont.49991
fjge_else.49990:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50006
	fjlt	%f1, %f16, fjge_else.50008
	fmov	%f0, %f1
	jmp	fjge_cont.50009
fjge_else.50008:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50010
	fjlt	%f1, %f16, fjge_else.50012
	fmov	%f0, %f1
	jmp	fjge_cont.50013
fjge_else.50012:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50013:
	jmp	fjge_cont.50011
fjge_else.50010:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50011:
fjge_cont.50009:
	jmp	fjge_cont.50007
fjge_else.50006:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50014
	fjlt	%f1, %f16, fjge_else.50016
	fmov	%f0, %f1
	jmp	fjge_cont.50017
fjge_else.50016:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50017:
	jmp	fjge_cont.50015
fjge_else.50014:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50015:
fjge_cont.50007:
fjge_cont.49991:
	fjlt	%f5, %f0, fjge_else.50018
	fjlt	%f16, %f2, fjge_else.50020
	addi	%g3, %g0, 0
	jmp	fjge_cont.50021
fjge_else.50020:
	addi	%g3, %g0, 1
fjge_cont.50021:
	jmp	fjge_cont.50019
fjge_else.50018:
	fjlt	%f16, %f2, fjge_else.50022
	addi	%g3, %g0, 1
	jmp	fjge_cont.50023
fjge_else.50022:
	addi	%g3, %g0, 0
fjge_cont.50023:
fjge_cont.50019:
	fjlt	%f5, %f0, fjge_else.50024
	fmov	%f1, %f0
	jmp	fjge_cont.50025
fjge_else.50024:
	fsub	%f1, %f29, %f0
fjge_cont.50025:
	fjlt	%f22, %f1, fjge_else.50026
	fmov	%f0, %f1
	jmp	fjge_cont.50027
fjge_else.50026:
	fsub	%f0, %f5, %f1
fjge_cont.50027:
	fmul	%f1, %f0, %f21
	fmul	%f0, %f1, %f1
	fdiv	%f2, %f0, %f25
	fsub	%f2, %f26, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f24, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f23, %f2
	fdiv	%f0, %f0, %f2
	fsub	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	fmul	%f1, %f10, %f0
	fmul	%f0, %f0, %f0
	fadd	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	jne	%g3, %g0, jeq_else.50028
	fneg	%f3, %f0
	jmp	jeq_cont.50029
jeq_else.50028:
	fmov	%f3, %f0
jeq_cont.50029:
	fjlt	%f4, %f16, fjge_else.50030
	fmov	%f1, %f4
	jmp	fjge_cont.50031
fjge_else.50030:
	fneg	%f1, %f4
fjge_cont.50031:
	fjlt	%f29, %f1, fjge_else.50032
	fjlt	%f1, %f16, fjge_else.50034
	fmov	%f0, %f1
	jmp	fjge_cont.50035
fjge_else.50034:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50036
	fjlt	%f1, %f16, fjge_else.50038
	fmov	%f0, %f1
	jmp	fjge_cont.50039
fjge_else.50038:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50040
	fjlt	%f1, %f16, fjge_else.50042
	fmov	%f0, %f1
	jmp	fjge_cont.50043
fjge_else.50042:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50043:
	jmp	fjge_cont.50041
fjge_else.50040:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50041:
fjge_cont.50039:
	jmp	fjge_cont.50037
fjge_else.50036:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50044
	fjlt	%f1, %f16, fjge_else.50046
	fmov	%f0, %f1
	jmp	fjge_cont.50047
fjge_else.50046:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50047:
	jmp	fjge_cont.50045
fjge_else.50044:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50045:
fjge_cont.50037:
fjge_cont.50035:
	jmp	fjge_cont.50033
fjge_else.50032:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50048
	fjlt	%f1, %f16, fjge_else.50050
	fmov	%f0, %f1
	jmp	fjge_cont.50051
fjge_else.50050:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50052
	fjlt	%f1, %f16, fjge_else.50054
	fmov	%f0, %f1
	jmp	fjge_cont.50055
fjge_else.50054:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50055:
	jmp	fjge_cont.50053
fjge_else.50052:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50053:
fjge_cont.50051:
	jmp	fjge_cont.50049
fjge_else.50048:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50056
	fjlt	%f1, %f16, fjge_else.50058
	fmov	%f0, %f1
	jmp	fjge_cont.50059
fjge_else.50058:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50059:
	jmp	fjge_cont.50057
fjge_else.50056:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50057:
fjge_cont.50049:
fjge_cont.50033:
	fjlt	%f5, %f0, fjge_else.50060
	fjlt	%f16, %f4, fjge_else.50062
	addi	%g3, %g0, 0
	jmp	fjge_cont.50063
fjge_else.50062:
	addi	%g3, %g0, 1
fjge_cont.50063:
	jmp	fjge_cont.50061
fjge_else.50060:
	fjlt	%f16, %f4, fjge_else.50064
	addi	%g3, %g0, 1
	jmp	fjge_cont.50065
fjge_else.50064:
	addi	%g3, %g0, 0
fjge_cont.50065:
fjge_cont.50061:
	fjlt	%f5, %f0, fjge_else.50066
	fmov	%f1, %f0
	jmp	fjge_cont.50067
fjge_else.50066:
	fsub	%f1, %f29, %f0
fjge_cont.50067:
	fjlt	%f22, %f1, fjge_else.50068
	fmov	%f0, %f1
	jmp	fjge_cont.50069
fjge_else.50068:
	fsub	%f0, %f5, %f1
fjge_cont.50069:
	fmul	%f1, %f0, %f21
	fmul	%f0, %f1, %f1
	fdiv	%f2, %f0, %f25
	fsub	%f2, %f26, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f24, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f23, %f2
	fdiv	%f0, %f0, %f2
	fsub	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	fmul	%f1, %f10, %f0
	fmul	%f0, %f0, %f0
	fadd	%f0, %f17, %f0
	fdiv	%f1, %f1, %f0
	jne	%g3, %g0, jeq_else.50070
	fneg	%f0, %f1
	jmp	jeq_cont.50071
jeq_else.50070:
	fmov	%f0, %f1
jeq_cont.50071:
	fmul	%f0, %f3, %f0
	fsti	%f0, %g31, 308
	fsub	%f2, %f22, %f4
	fjlt	%f2, %f16, fjge_else.50072
	fmov	%f1, %f2
	jmp	fjge_cont.50073
fjge_else.50072:
	fneg	%f1, %f2
fjge_cont.50073:
	fjlt	%f29, %f1, fjge_else.50074
	fjlt	%f1, %f16, fjge_else.50076
	fmov	%f0, %f1
	jmp	fjge_cont.50077
fjge_else.50076:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50078
	fjlt	%f1, %f16, fjge_else.50080
	fmov	%f0, %f1
	jmp	fjge_cont.50081
fjge_else.50080:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50082
	fjlt	%f1, %f16, fjge_else.50084
	fmov	%f0, %f1
	jmp	fjge_cont.50085
fjge_else.50084:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50085:
	jmp	fjge_cont.50083
fjge_else.50082:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50083:
fjge_cont.50081:
	jmp	fjge_cont.50079
fjge_else.50078:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50086
	fjlt	%f1, %f16, fjge_else.50088
	fmov	%f0, %f1
	jmp	fjge_cont.50089
fjge_else.50088:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50089:
	jmp	fjge_cont.50087
fjge_else.50086:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50087:
fjge_cont.50079:
fjge_cont.50077:
	jmp	fjge_cont.50075
fjge_else.50074:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50090
	fjlt	%f1, %f16, fjge_else.50092
	fmov	%f0, %f1
	jmp	fjge_cont.50093
fjge_else.50092:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50094
	fjlt	%f1, %f16, fjge_else.50096
	fmov	%f0, %f1
	jmp	fjge_cont.50097
fjge_else.50096:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50097:
	jmp	fjge_cont.50095
fjge_else.50094:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50095:
fjge_cont.50093:
	jmp	fjge_cont.50091
fjge_else.50090:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50098
	fjlt	%f1, %f16, fjge_else.50100
	fmov	%f0, %f1
	jmp	fjge_cont.50101
fjge_else.50100:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50101:
	jmp	fjge_cont.50099
fjge_else.50098:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50099:
fjge_cont.50091:
fjge_cont.50075:
	fjlt	%f5, %f0, fjge_else.50102
	fjlt	%f16, %f2, fjge_else.50104
	addi	%g3, %g0, 0
	jmp	fjge_cont.50105
fjge_else.50104:
	addi	%g3, %g0, 1
fjge_cont.50105:
	jmp	fjge_cont.50103
fjge_else.50102:
	fjlt	%f16, %f2, fjge_else.50106
	addi	%g3, %g0, 1
	jmp	fjge_cont.50107
fjge_else.50106:
	addi	%g3, %g0, 0
fjge_cont.50107:
fjge_cont.50103:
	fjlt	%f5, %f0, fjge_else.50108
	fmov	%f1, %f0
	jmp	fjge_cont.50109
fjge_else.50108:
	fsub	%f1, %f29, %f0
fjge_cont.50109:
	fjlt	%f22, %f1, fjge_else.50110
	fmov	%f0, %f1
	jmp	fjge_cont.50111
fjge_else.50110:
	fsub	%f0, %f5, %f1
fjge_cont.50111:
	fmul	%f0, %f0, %f21
	fmul	%f2, %f0, %f0
	fdiv	%f1, %f2, %f25
	fsub	%f1, %f26, %f1
	fdiv	%f1, %f2, %f1
	fsub	%f1, %f24, %f1
	fdiv	%f1, %f2, %f1
	fsub	%f1, %f23, %f1
	fdiv	%f1, %f2, %f1
	fsub	%f1, %f17, %f1
	fdiv	%f0, %f0, %f1
	fmul	%f1, %f10, %f0
	fmul	%f0, %f0, %f0
	fadd	%f0, %f17, %f0
	fdiv	%f1, %f1, %f0
	jne	%g3, %g0, jeq_else.50112
	fneg	%f0, %f1
	jmp	jeq_cont.50113
jeq_else.50112:
	fmov	%f0, %f1
jeq_cont.50113:
	fmul	%f0, %f3, %f0
	fsti	%f0, %g31, 300
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.50114
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.50116
	addi	%g3, %g0, 0
	jmp	jle_cont.50117
jle_else.50116:
	addi	%g3, %g0, 1
jle_cont.50117:
	jmp	jle_cont.50115
jle_else.50114:
	addi	%g3, %g0, 1
jle_cont.50115:
	jne	%g3, %g0, jeq_else.50118
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.50120
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
	jmp	jeq_cont.50121
jeq_else.50120:
jeq_cont.50121:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	jmp	jeq_cont.50119
jeq_else.50118:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
jeq_cont.50119:
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.50122
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.50124
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.50126
	addi	%g4, %g0, 0
	jmp	jle_cont.50127
jle_else.50126:
	addi	%g4, %g0, 1
jle_cont.50127:
	jmp	jle_cont.50125
jle_else.50124:
	addi	%g4, %g0, 1
jle_cont.50125:
	jne	%g4, %g0, jeq_else.50128
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
	jmp	jeq_cont.50129
jeq_else.50128:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
jeq_cont.50129:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmov	%f4, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f3, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f0, %f3, %f0
	fadd	%f0, %f4, %f0
	jmp	jeq_cont.50123
jeq_else.50122:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
jeq_cont.50123:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.50130
	fmov	%f1, %f0
	jmp	jeq_cont.50131
jeq_else.50130:
	fneg	%f1, %f0
jeq_cont.50131:
	fsti	%f1, %g31, 312
	addi	%g16, %g0, 0
	fsti	%f10, %g1, 0
	subi	%g1, %g1, 8
	call	read_object.2755
	addi	%g1, %g1, 8
	addi	%g3, %g0, 0
	sti	%g3, %g31, 4
	addi	%g3, %g0, 0
	sti	%g3, %g31, 8
	input	%g5
	addi	%g10, %g0, 48
	jlt	%g5, %g10, jle_else.50132
	addi	%g10, %g0, 57
	jlt	%g10, %g5, jle_else.50134
	addi	%g10, %g0, 0
	jmp	jle_cont.50135
jle_else.50134:
	addi	%g10, %g0, 1
jle_cont.50135:
	jmp	jle_cont.50133
jle_else.50132:
	addi	%g10, %g0, 1
jle_cont.50133:
	jne	%g10, %g0, jeq_else.50136
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.50138
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
	jmp	jeq_cont.50139
jeq_else.50138:
jeq_cont.50139:
	ldi	%g3, %g31, 4
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 4
	addi	%g6, %g0, 1
	subi	%g1, %g1, 8
	call	read_int_token.2566
	addi	%g1, %g1, 8
	mov	%g10, %g3
	jmp	jeq_cont.50137
jeq_else.50136:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 8
	call	read_int_token.2566
	addi	%g1, %g1, 8
	mov	%g10, %g3
jeq_cont.50137:
	jne	%g10, %g29, jeq_else.50140
	addi	%g3, %g0, 1
	addi	%g4, %g0, -1
	subi	%g1, %g1, 8
	call	min_caml_create_array
	addi	%g1, %g1, 8
	jmp	jeq_cont.50141
jeq_else.50140:
	addi	%g8, %g0, 1
	subi	%g1, %g1, 8
	call	read_net_item.2759
	addi	%g1, %g1, 8
	sti	%g10, %g3, 0
jeq_cont.50141:
	sti	%g3, %g31, 2300
	ldi	%g4, %g3, 0
	jne	%g4, %g29, jeq_else.50142
	jmp	jeq_cont.50143
jeq_else.50142:
	sti	%g3, %g31, 512
	addi	%g11, %g0, 1
	subi	%g1, %g1, 8
	call	read_and_network.2763
	addi	%g1, %g1, 8
jeq_cont.50143:
	addi	%g3, %g0, 0
	sti	%g3, %g31, 4
	addi	%g3, %g0, 0
	sti	%g3, %g31, 8
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.50144
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.50146
	addi	%g3, %g0, 0
	jmp	jle_cont.50147
jle_else.50146:
	addi	%g3, %g0, 1
jle_cont.50147:
	jmp	jle_cont.50145
jle_else.50144:
	addi	%g3, %g0, 1
jle_cont.50145:
	jne	%g3, %g0, jeq_else.50148
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.50150
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
	jmp	jeq_cont.50151
jeq_else.50150:
jeq_cont.50151:
	ldi	%g3, %g31, 4
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 4
	addi	%g6, %g0, 1
	subi	%g1, %g1, 8
	call	read_int_token.2566
	addi	%g1, %g1, 8
	jmp	jeq_cont.50149
jeq_else.50148:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 8
	call	read_int_token.2566
	addi	%g1, %g1, 8
jeq_cont.50149:
	jne	%g3, %g29, jeq_else.50152
	addi	%g3, %g0, 1
	addi	%g4, %g0, -1
	subi	%g1, %g1, 8
	call	min_caml_create_array
	addi	%g1, %g1, 8
	mov	%g4, %g3
	jmp	jeq_cont.50153
jeq_else.50152:
	addi	%g8, %g0, 1
	sti	%g3, %g1, 4
	subi	%g1, %g1, 12
	call	read_net_item.2759
	addi	%g1, %g1, 12
	mov	%g4, %g3
	ldi	%g3, %g1, 4
	sti	%g3, %g4, 0
jeq_cont.50153:
	sti	%g4, %g31, 2304
	ldi	%g3, %g4, 0
	jne	%g3, %g29, jeq_else.50154
	addi	%g3, %g0, 1
	subi	%g1, %g1, 12
	call	min_caml_create_array
	addi	%g1, %g1, 12
	jmp	jeq_cont.50155
jeq_else.50154:
	addi	%g11, %g0, 1
	sti	%g4, %g1, 8
	subi	%g1, %g1, 16
	call	read_or_network.2761
	addi	%g1, %g1, 16
	ldi	%g4, %g1, 8
	sti	%g4, %g3, 0
jeq_cont.50155:
	sti	%g3, %g31, 516
	addi	%g3, %g0, 80
	output	%g3
	addi	%g3, %g0, 51
	output	%g3
	addi	%g3, %g0, 10
	output	%g3
	ldi	%g4, %g31, 600
	subi	%g1, %g1, 16
	call	print_int.2587
	addi	%g3, %g0, 32
	output	%g3
	ldi	%g4, %g31, 596
	call	print_int.2587
	addi	%g3, %g0, 32
	output	%g3
	addi	%g4, %g0, 255
	call	print_int.2587
	addi	%g3, %g0, 10
	output	%g3
	addi	%g6, %g0, 120
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 2316
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g7, %g3
	ldi	%g2, %g31, 2372
	ldi	%g3, %g31, 28
	subi	%g4, %g31, 2316
	call	min_caml_create_array
	mov	%g4, %g3
	sti	%g4, %g31, 2320
	mov	%g3, %g2
	addi	%g2, %g2, 8
	sti	%g4, %g3, -4
	sti	%g7, %g3, 0
	mov	%g4, %g3
	mov	%g3, %g6
	call	min_caml_create_array
	sti	%g3, %g31, 700
	ldi	%g6, %g31, 700
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 2332
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g7, %g3
	ldi	%g2, %g31, 2372
	ldi	%g3, %g31, 28
	subi	%g4, %g31, 2332
	call	min_caml_create_array
	mov	%g4, %g3
	sti	%g4, %g31, 2336
	mov	%g3, %g2
	addi	%g2, %g2, 8
	sti	%g4, %g3, -4
	sti	%g7, %g3, 0
	sti	%g3, %g6, -472
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 2348
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g7, %g3
	ldi	%g2, %g31, 2372
	ldi	%g3, %g31, 28
	subi	%g4, %g31, 2348
	call	min_caml_create_array
	mov	%g4, %g3
	sti	%g4, %g31, 2352
	mov	%g3, %g2
	addi	%g2, %g2, 8
	sti	%g4, %g3, -4
	sti	%g7, %g3, 0
	sti	%g3, %g6, -468
	addi	%g3, %g0, 3
	sti	%g2, %g31, 2372
	subi	%g2, %g31, 2364
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g7, %g3
	ldi	%g2, %g31, 2372
	ldi	%g3, %g31, 28
	subi	%g4, %g31, 2364
	call	min_caml_create_array
	mov	%g4, %g3
	sti	%g4, %g31, 2368
	mov	%g3, %g2
	addi	%g2, %g2, 8
	sti	%g4, %g3, -4
	sti	%g7, %g3, 0
	sti	%g3, %g6, -464
	addi	%g7, %g0, 115
	call	create_dirvec_elements.3071
	addi	%g8, %g0, 3
	call	create_dirvecs.3074
	addi	%g3, %g0, 9
	addi	%g8, %g0, 0
	addi	%g12, %g0, 0
	call	min_caml_float_of_int
	addi	%g1, %g1, 16
	setL %g3, l.43074
	fldi	%f4, %g3, 0
	fmul	%f0, %f0, %f4
	setL %g3, l.43076
	fldi	%f3, %g3, 0
	fsub	%f0, %f0, %f3
	addi	%g3, %g0, 4
	fsti	%f0, %g1, 12
	subi	%g1, %g1, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 20
	fmov	%f1, %f0
	fmul	%f1, %f1, %f4
	fsub	%f2, %f1, %f3
	addi	%g4, %g0, 0
	fldi	%f0, %g1, 12
	fsti	%f3, %g1, 16
	fsti	%f4, %g1, 20
	fsti	%f1, %g1, 24
	mov	%g3, %g12
	mov	%g5, %g8
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 32
	call	calc_dirvec.3052
	addi	%g1, %g1, 32
	setL %g3, l.43078
	fldi	%f5, %g3, 0
	fldi	%f1, %g1, 24
	fadd	%f2, %f1, %f5
	addi	%g4, %g0, 0
	addi	%g3, %g0, 2
	fldi	%f0, %g1, 12
	fsti	%f5, %g1, 28
	mov	%g5, %g8
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 36
	call	calc_dirvec.3052
	addi	%g1, %g1, 36
	addi	%g3, %g0, 3
	addi	%g5, %g0, 1
	sti	%g5, %g1, 32
	subi	%g1, %g1, 40
	call	min_caml_float_of_int
	addi	%g1, %g1, 40
	fmov	%f1, %f0
	fldi	%f4, %g1, 20
	fmul	%f1, %f1, %f4
	fldi	%f3, %g1, 16
	fsub	%f2, %f1, %f3
	addi	%g4, %g0, 0
	fldi	%f0, %g1, 12
	ldi	%g5, %g1, 32
	fsti	%f1, %g1, 36
	mov	%g3, %g12
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 44
	call	calc_dirvec.3052
	addi	%g1, %g1, 44
	fldi	%f5, %g1, 28
	fldi	%f1, %g1, 36
	fadd	%f2, %f1, %f5
	addi	%g4, %g0, 0
	addi	%g8, %g0, 2
	fldi	%f0, %g1, 12
	ldi	%g5, %g1, 32
	mov	%g3, %g8
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 44
	call	calc_dirvec.3052
	addi	%g1, %g1, 44
	addi	%g3, %g0, 2
	addi	%g5, %g0, 2
	sti	%g5, %g1, 40
	subi	%g1, %g1, 48
	call	min_caml_float_of_int
	addi	%g1, %g1, 48
	fmov	%f1, %f0
	fldi	%f4, %g1, 20
	fmul	%f1, %f1, %f4
	fldi	%f3, %g1, 16
	fsub	%f2, %f1, %f3
	addi	%g4, %g0, 0
	fldi	%f0, %g1, 12
	ldi	%g5, %g1, 40
	fsti	%f1, %g1, 44
	mov	%g3, %g12
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 52
	call	calc_dirvec.3052
	addi	%g1, %g1, 52
	fldi	%f5, %g1, 28
	fldi	%f1, %g1, 44
	fadd	%f2, %f1, %f5
	addi	%g4, %g0, 0
	fldi	%f0, %g1, 12
	ldi	%g5, %g1, 40
	mov	%g3, %g8
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 52
	call	calc_dirvec.3052
	addi	%g1, %g1, 52
	addi	%g10, %g0, 1
	addi	%g9, %g0, 3
	fldi	%f0, %g1, 12
	mov	%g8, %g12
	subi	%g1, %g1, 52
	call	calc_dirvecs.3060
	addi	%g13, %g0, 8
	addi	%g12, %g0, 2
	addi	%g8, %g0, 4
	call	calc_dirvec_rows.3065
	ldi	%g11, %g31, 700
	ldi	%g3, %g11, -476
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	call	iter_setup_dirvec_constants.2860
	ldi	%g3, %g11, -472
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	call	iter_setup_dirvec_constants.2860
	ldi	%g3, %g11, -468
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	call	iter_setup_dirvec_constants.2860
	ldi	%g3, %g11, -464
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	call	iter_setup_dirvec_constants.2860
	ldi	%g3, %g11, -460
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	call	iter_setup_dirvec_constants.2860
	ldi	%g3, %g11, -456
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	call	iter_setup_dirvec_constants.2860
	ldi	%g3, %g11, -452
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	call	iter_setup_dirvec_constants.2860
	addi	%g12, %g0, 112
	call	init_dirvec_constants.3076
	addi	%g1, %g1, 52
	addi	%g13, %g0, 3
	sti	%g19, %g1, 48
	sti	%g18, %g1, 52
	sti	%g17, %g1, 56
	subi	%g1, %g1, 64
	call	init_vecset_constants.3079
	fldi	%f0, %g31, 308
	fsti	%f0, %g31, 732
	fldi	%f0, %g31, 304
	fsti	%f0, %g31, 728
	fldi	%f0, %g31, 300
	fsti	%f0, %g31, 724
	ldi	%g3, %g31, 28
	subi	%g5, %g3, 1
	subi	%g7, %g31, 732
	subi	%g6, %g31, 972
	call	iter_setup_dirvec_constants.2860
	addi	%g1, %g1, 64
	ldi	%g3, %g31, 28
	subi	%g6, %g3, 1
	jlt	%g6, %g0, jge_else.50156
	slli	%g3, %g6, 2
	add	%g3, %g31, %g3
	ldi	%g3, %g3, 272
	ldi	%g4, %g3, -8
	addi	%g5, %g0, 2
	jne	%g4, %g5, jeq_else.50158
	ldi	%g4, %g3, -28
	fldi	%f0, %g4, 0
	fjlt	%f0, %f17, fjge_else.50160
	jmp	fjge_cont.50161
fjge_else.50160:
	ldi	%g5, %g3, -4
	jne	%g5, %g28, jeq_else.50162
	slli	%g11, %g6, 2
	ldi	%g12, %g31, 1720
	fldi	%f0, %g4, 0
	fsub	%f12, %f17, %f0
	fldi	%f1, %g31, 308
	fneg	%f11, %f1
	fldi	%f10, %g31, 304
	fneg	%f10, %f10
	fldi	%f9, %g31, 300
	fneg	%f9, %f9
	addi	%g14, %g11, 1
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 64
	call	min_caml_create_float_array
	addi	%g1, %g1, 64
	mov	%g4, %g3
	ldi	%g3, %g31, 28
	sti	%g4, %g1, 60
	subi	%g1, %g1, 68
	call	min_caml_create_array
	addi	%g1, %g1, 68
	mov	%g5, %g2
	addi	%g2, %g2, 8
	sti	%g3, %g5, -4
	ldi	%g4, %g1, 60
	sti	%g4, %g5, 0
	fsti	%f1, %g4, 0
	fsti	%f10, %g4, -4
	fsti	%f9, %g4, -8
	ldi	%g6, %g31, 28
	subi	%g13, %g6, 1
	sti	%g5, %g1, 64
	mov	%g5, %g13
	mov	%g6, %g3
	mov	%g7, %g4
	subi	%g1, %g1, 72
	call	iter_setup_dirvec_constants.2860
	addi	%g1, %g1, 72
	mov	%g3, %g2
	addi	%g2, %g2, 12
	fsti	%f12, %g3, -8
	ldi	%g5, %g1, 64
	sti	%g5, %g3, -4
	sti	%g14, %g3, 0
	slli	%g4, %g12, 2
	add	%g4, %g31, %g4
	sti	%g3, %g4, 1716
	addi	%g15, %g12, 1
	addi	%g14, %g11, 2
	fldi	%f1, %g31, 304
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 72
	call	min_caml_create_float_array
	addi	%g1, %g1, 72
	mov	%g4, %g3
	ldi	%g3, %g31, 28
	sti	%g4, %g1, 68
	subi	%g1, %g1, 76
	call	min_caml_create_array
	addi	%g1, %g1, 76
	mov	%g5, %g2
	addi	%g2, %g2, 8
	sti	%g3, %g5, -4
	ldi	%g4, %g1, 68
	sti	%g4, %g5, 0
	fsti	%f11, %g4, 0
	fsti	%f1, %g4, -4
	fsti	%f9, %g4, -8
	ldi	%g6, %g31, 28
	subi	%g13, %g6, 1
	sti	%g5, %g1, 72
	mov	%g5, %g13
	mov	%g6, %g3
	mov	%g7, %g4
	subi	%g1, %g1, 80
	call	iter_setup_dirvec_constants.2860
	addi	%g1, %g1, 80
	mov	%g3, %g2
	addi	%g2, %g2, 12
	fsti	%f12, %g3, -8
	ldi	%g5, %g1, 72
	sti	%g5, %g3, -4
	sti	%g14, %g3, 0
	slli	%g4, %g15, 2
	add	%g4, %g31, %g4
	sti	%g3, %g4, 1716
	addi	%g14, %g12, 2
	addi	%g13, %g11, 3
	fldi	%f1, %g31, 300
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 80
	call	min_caml_create_float_array
	addi	%g1, %g1, 80
	mov	%g4, %g3
	ldi	%g3, %g31, 28
	sti	%g4, %g1, 76
	subi	%g1, %g1, 84
	call	min_caml_create_array
	addi	%g1, %g1, 84
	mov	%g5, %g2
	addi	%g2, %g2, 8
	sti	%g3, %g5, -4
	ldi	%g4, %g1, 76
	sti	%g4, %g5, 0
	fsti	%f11, %g4, 0
	fsti	%f10, %g4, -4
	fsti	%f1, %g4, -8
	ldi	%g6, %g31, 28
	subi	%g11, %g6, 1
	sti	%g5, %g1, 80
	mov	%g5, %g11
	mov	%g6, %g3
	mov	%g7, %g4
	subi	%g1, %g1, 88
	call	iter_setup_dirvec_constants.2860
	addi	%g1, %g1, 88
	mov	%g3, %g2
	addi	%g2, %g2, 12
	fsti	%f12, %g3, -8
	ldi	%g5, %g1, 80
	sti	%g5, %g3, -4
	sti	%g13, %g3, 0
	slli	%g4, %g14, 2
	add	%g4, %g31, %g4
	sti	%g3, %g4, 1716
	addi	%g3, %g12, 3
	sti	%g3, %g31, 1720
	jmp	jeq_cont.50163
jeq_else.50162:
	addi	%g4, %g0, 2
	jne	%g5, %g4, jeq_else.50164
	slli	%g4, %g6, 2
	addi	%g12, %g4, 1
	ldi	%g13, %g31, 1720
	fsub	%f9, %f17, %f0
	ldi	%g3, %g3, -16
	fldi	%f7, %g31, 308
	fldi	%f5, %g3, 0
	fmul	%f2, %f7, %f5
	fldi	%f1, %g31, 304
	fldi	%f6, %g3, -4
	fmul	%f0, %f1, %f6
	fadd	%f4, %f2, %f0
	fldi	%f2, %g31, 300
	fldi	%f0, %g3, -8
	fmul	%f3, %f2, %f0
	fadd	%f3, %f4, %f3
	fldi	%f10, %g1, 0
	fmul	%f4, %f10, %f5
	fmul	%f4, %f4, %f3
	fsub	%f5, %f4, %f7
	fmul	%f4, %f10, %f6
	fmul	%f4, %f4, %f3
	fsub	%f4, %f4, %f1
	fmul	%f0, %f10, %f0
	fmul	%f0, %f0, %f3
	fsub	%f1, %f0, %f2
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 88
	call	min_caml_create_float_array
	addi	%g1, %g1, 88
	mov	%g4, %g3
	ldi	%g3, %g31, 28
	sti	%g4, %g1, 84
	subi	%g1, %g1, 92
	call	min_caml_create_array
	addi	%g1, %g1, 92
	mov	%g5, %g2
	addi	%g2, %g2, 8
	sti	%g3, %g5, -4
	ldi	%g4, %g1, 84
	sti	%g4, %g5, 0
	fsti	%f5, %g4, 0
	fsti	%f4, %g4, -4
	fsti	%f1, %g4, -8
	ldi	%g6, %g31, 28
	subi	%g11, %g6, 1
	sti	%g5, %g1, 88
	mov	%g5, %g11
	mov	%g6, %g3
	mov	%g7, %g4
	subi	%g1, %g1, 96
	call	iter_setup_dirvec_constants.2860
	addi	%g1, %g1, 96
	mov	%g3, %g2
	addi	%g2, %g2, 12
	fsti	%f9, %g3, -8
	ldi	%g5, %g1, 88
	sti	%g5, %g3, -4
	sti	%g12, %g3, 0
	slli	%g4, %g13, 2
	add	%g4, %g31, %g4
	sti	%g3, %g4, 1716
	addi	%g3, %g13, 1
	sti	%g3, %g31, 1720
	jmp	jeq_cont.50165
jeq_else.50164:
jeq_cont.50165:
jeq_cont.50163:
fjge_cont.50161:
	jmp	jeq_cont.50159
jeq_else.50158:
jeq_cont.50159:
	jmp	jge_cont.50157
jge_else.50156:
jge_cont.50157:
	addi	%g8, %g0, 0
	fldi	%f3, %g31, 612
	ldi	%g3, %g31, 604
	sub	%g3, %g0, %g3
	subi	%g1, %g1, 96
	call	min_caml_float_of_int
	addi	%g1, %g1, 96
	fmul	%f0, %f3, %f0
	fldi	%f1, %g31, 660
	fmul	%f2, %f0, %f1
	fldi	%f1, %g31, 672
	fadd	%f13, %f2, %f1
	fldi	%f1, %g31, 656
	fmul	%f2, %f0, %f1
	fldi	%f1, %g31, 668
	fadd	%f12, %f2, %f1
	fldi	%f1, %g31, 652
	fmul	%f1, %f0, %f1
	fldi	%f0, %g31, 664
	fadd	%f11, %f1, %f0
	ldi	%g3, %g31, 600
	subi	%g6, %g3, 1
	ldi	%g17, %g1, 56
	mov	%g7, %g17
	subi	%g1, %g1, 96
	call	pretrace_pixels.3017
	addi	%g1, %g1, 96
	addi	%g16, %g0, 0
	addi	%g8, %g0, 2
	ldi	%g3, %g31, 596
	jlt	%g16, %g3, jle_else.50166
	jmp	jle_cont.50167
jle_else.50166:
	subi	%g3, %g3, 1
	sti	%g16, %g1, 92
	jlt	%g16, %g3, jle_else.50168
	jmp	jle_cont.50169
jle_else.50168:
	addi	%g4, %g0, 1
	fldi	%f3, %g31, 612
	ldi	%g3, %g31, 604
	sub	%g3, %g4, %g3
	subi	%g1, %g1, 100
	call	min_caml_float_of_int
	addi	%g1, %g1, 100
	fmul	%f0, %f3, %f0
	fldi	%f1, %g31, 660
	fmul	%f2, %f0, %f1
	fldi	%f1, %g31, 672
	fadd	%f13, %f2, %f1
	fldi	%f1, %g31, 656
	fmul	%f2, %f0, %f1
	fldi	%f1, %g31, 668
	fadd	%f12, %f2, %f1
	fldi	%f1, %g31, 652
	fmul	%f1, %f0, %f1
	fldi	%f0, %g31, 664
	fadd	%f11, %f1, %f0
	ldi	%g3, %g31, 600
	subi	%g6, %g3, 1
	ldi	%g18, %g1, 52
	mov	%g7, %g18
	subi	%g1, %g1, 100
	call	pretrace_pixels.3017
	addi	%g1, %g1, 100
jle_cont.50169:
	addi	%g15, %g0, 0
	ldi	%g16, %g1, 92
	ldi	%g19, %g1, 48
	ldi	%g17, %g1, 56
	ldi	%g18, %g1, 52
	mov	%g27, %g19
	mov	%g19, %g18
	mov	%g18, %g27
	subi	%g1, %g1, 100
	call	scan_pixel.3028
	addi	%g1, %g1, 100
	addi	%g16, %g0, 1
	addi	%g8, %g0, 4
	ldi	%g17, %g1, 56
	ldi	%g18, %g1, 52
	ldi	%g19, %g1, 48
	mov	%g7, %g17
	mov	%g17, %g19
	subi	%g1, %g1, 100
	call	scan_line.3034
	addi	%g1, %g1, 100
jle_cont.50167:
	addi	%g0, %g0, 0
	halt

!==============================
! args = []
! fargs = [%f1]
! use_regs = [%g27, %f29, %f16, %f15, %f1, %f0]
! ret type = Float
!================================
sin_sub.2556:
	fjlt	%f29, %f1, fjge_else.50170
	fjlt	%f1, %f16, fjge_else.50171
	fmov	%f0, %f1
	return
fjge_else.50171:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50172
	fjlt	%f1, %f16, fjge_else.50173
	fmov	%f0, %f1
	return
fjge_else.50173:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50174
	fjlt	%f1, %f16, fjge_else.50175
	fmov	%f0, %f1
	return
fjge_else.50175:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50176
	fjlt	%f1, %f16, fjge_else.50177
	fmov	%f0, %f1
	return
fjge_else.50177:
	fadd	%f1, %f1, %f29
	jmp	sin_sub.2556
fjge_else.50176:
	fsub	%f1, %f1, %f29
	jmp	sin_sub.2556
fjge_else.50174:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50178
	fjlt	%f1, %f16, fjge_else.50179
	fmov	%f0, %f1
	return
fjge_else.50179:
	fadd	%f1, %f1, %f29
	jmp	sin_sub.2556
fjge_else.50178:
	fsub	%f1, %f1, %f29
	jmp	sin_sub.2556
fjge_else.50172:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50180
	fjlt	%f1, %f16, fjge_else.50181
	fmov	%f0, %f1
	return
fjge_else.50181:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50182
	fjlt	%f1, %f16, fjge_else.50183
	fmov	%f0, %f1
	return
fjge_else.50183:
	fadd	%f1, %f1, %f29
	jmp	sin_sub.2556
fjge_else.50182:
	fsub	%f1, %f1, %f29
	jmp	sin_sub.2556
fjge_else.50180:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50184
	fjlt	%f1, %f16, fjge_else.50185
	fmov	%f0, %f1
	return
fjge_else.50185:
	fadd	%f1, %f1, %f29
	jmp	sin_sub.2556
fjge_else.50184:
	fsub	%f1, %f1, %f29
	jmp	sin_sub.2556
fjge_else.50170:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50186
	fjlt	%f1, %f16, fjge_else.50187
	fmov	%f0, %f1
	return
fjge_else.50187:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50188
	fjlt	%f1, %f16, fjge_else.50189
	fmov	%f0, %f1
	return
fjge_else.50189:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50190
	fjlt	%f1, %f16, fjge_else.50191
	fmov	%f0, %f1
	return
fjge_else.50191:
	fadd	%f1, %f1, %f29
	jmp	sin_sub.2556
fjge_else.50190:
	fsub	%f1, %f1, %f29
	jmp	sin_sub.2556
fjge_else.50188:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50192
	fjlt	%f1, %f16, fjge_else.50193
	fmov	%f0, %f1
	return
fjge_else.50193:
	fadd	%f1, %f1, %f29
	jmp	sin_sub.2556
fjge_else.50192:
	fsub	%f1, %f1, %f29
	jmp	sin_sub.2556
fjge_else.50186:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50194
	fjlt	%f1, %f16, fjge_else.50195
	fmov	%f0, %f1
	return
fjge_else.50195:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50196
	fjlt	%f1, %f16, fjge_else.50197
	fmov	%f0, %f1
	return
fjge_else.50197:
	fadd	%f1, %f1, %f29
	jmp	sin_sub.2556
fjge_else.50196:
	fsub	%f1, %f1, %f29
	jmp	sin_sub.2556
fjge_else.50194:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50198
	fjlt	%f1, %f16, fjge_else.50199
	fmov	%f0, %f1
	return
fjge_else.50199:
	fadd	%f1, %f1, %f29
	jmp	sin_sub.2556
fjge_else.50198:
	fsub	%f1, %f1, %f29
	jmp	sin_sub.2556

!==============================
! args = [%g6, %g5]
! fargs = []
! use_regs = [%g6, %g5, %g4, %g3, %g27, %f15, %dummy]
! ret type = Int
!================================
read_int_token.2566:
	input	%g4
	addi	%g3, %g0, 48
	jlt	%g4, %g3, jle_else.50200
	addi	%g3, %g0, 57
	jlt	%g3, %g4, jle_else.50202
	addi	%g3, %g0, 0
	jmp	jle_cont.50203
jle_else.50202:
	addi	%g3, %g0, 1
jle_cont.50203:
	jmp	jle_cont.50201
jle_else.50200:
	addi	%g3, %g0, 1
jle_cont.50201:
	jne	%g3, %g0, jeq_else.50204
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.50205
	addi	%g3, %g0, 45
	jne	%g5, %g3, jeq_else.50207
	addi	%g3, %g0, -1
	sti	%g3, %g31, 8
	jmp	jeq_cont.50208
jeq_else.50207:
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
jeq_cont.50208:
	jmp	jeq_cont.50206
jeq_else.50205:
jeq_cont.50206:
	ldi	%g3, %g31, 4
	slli	%g5, %g3, 3
	slli	%g3, %g3, 1
	add	%g5, %g5, %g3
	subi	%g3, %g4, 48
	add	%g3, %g5, %g3
	sti	%g3, %g31, 4
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.50209
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.50211
	addi	%g3, %g0, 0
	jmp	jle_cont.50212
jle_else.50211:
	addi	%g3, %g0, 1
jle_cont.50212:
	jmp	jle_cont.50210
jle_else.50209:
	addi	%g3, %g0, 1
jle_cont.50210:
	jne	%g3, %g0, jeq_else.50213
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.50214
	addi	%g3, %g0, 45
	jne	%g4, %g3, jeq_else.50216
	addi	%g3, %g0, -1
	sti	%g3, %g31, 8
	jmp	jeq_cont.50217
jeq_else.50216:
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
jeq_cont.50217:
	jmp	jeq_cont.50215
jeq_else.50214:
jeq_cont.50215:
	ldi	%g3, %g31, 4
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 4
	addi	%g6, %g0, 1
	jmp	read_int_token.2566
jeq_else.50213:
	ldi	%g3, %g31, 8
	jne	%g3, %g28, jeq_else.50218
	ldi	%g3, %g31, 4
	return
jeq_else.50218:
	ldi	%g3, %g31, 4
	sub	%g3, %g0, %g3
	return
jeq_else.50204:
	jne	%g6, %g0, jeq_else.50219
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.50220
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.50222
	addi	%g3, %g0, 0
	jmp	jle_cont.50223
jle_else.50222:
	addi	%g3, %g0, 1
jle_cont.50223:
	jmp	jle_cont.50221
jle_else.50220:
	addi	%g3, %g0, 1
jle_cont.50221:
	jne	%g3, %g0, jeq_else.50224
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.50225
	addi	%g3, %g0, 45
	jne	%g4, %g3, jeq_else.50227
	addi	%g3, %g0, -1
	sti	%g3, %g31, 8
	jmp	jeq_cont.50228
jeq_else.50227:
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
jeq_cont.50228:
	jmp	jeq_cont.50226
jeq_else.50225:
jeq_cont.50226:
	ldi	%g3, %g31, 4
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 4
	addi	%g6, %g0, 1
	jmp	read_int_token.2566
jeq_else.50224:
	addi	%g6, %g0, 0
	jmp	read_int_token.2566
jeq_else.50219:
	ldi	%g3, %g31, 8
	jne	%g3, %g28, jeq_else.50229
	ldi	%g3, %g31, 4
	return
jeq_else.50229:
	ldi	%g3, %g31, 4
	sub	%g3, %g0, %g3
	return

!==============================
! args = [%g6, %g5]
! fargs = []
! use_regs = [%g6, %g5, %g4, %g3, %g27, %f15, %dummy]
! ret type = Int
!================================
read_float_token1.2575:
	input	%g4
	addi	%g3, %g0, 48
	jlt	%g4, %g3, jle_else.50230
	addi	%g3, %g0, 57
	jlt	%g3, %g4, jle_else.50232
	addi	%g3, %g0, 0
	jmp	jle_cont.50233
jle_else.50232:
	addi	%g3, %g0, 1
jle_cont.50233:
	jmp	jle_cont.50231
jle_else.50230:
	addi	%g3, %g0, 1
jle_cont.50231:
	jne	%g3, %g0, jeq_else.50234
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.50235
	addi	%g3, %g0, 45
	jne	%g5, %g3, jeq_else.50237
	addi	%g3, %g0, -1
	sti	%g3, %g31, 24
	jmp	jeq_cont.50238
jeq_else.50237:
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
jeq_cont.50238:
	jmp	jeq_cont.50236
jeq_else.50235:
jeq_cont.50236:
	ldi	%g3, %g31, 12
	slli	%g5, %g3, 3
	slli	%g3, %g3, 1
	add	%g5, %g5, %g3
	subi	%g3, %g4, 48
	add	%g3, %g5, %g3
	sti	%g3, %g31, 12
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.50239
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.50241
	addi	%g3, %g0, 0
	jmp	jle_cont.50242
jle_else.50241:
	addi	%g3, %g0, 1
jle_cont.50242:
	jmp	jle_cont.50240
jle_else.50239:
	addi	%g3, %g0, 1
jle_cont.50240:
	jne	%g3, %g0, jeq_else.50243
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.50244
	addi	%g3, %g0, 45
	jne	%g4, %g3, jeq_else.50246
	addi	%g3, %g0, -1
	sti	%g3, %g31, 24
	jmp	jeq_cont.50247
jeq_else.50246:
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
jeq_cont.50247:
	jmp	jeq_cont.50245
jeq_else.50244:
jeq_cont.50245:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	jmp	read_float_token1.2575
jeq_else.50243:
	mov	%g3, %g5
	return
jeq_else.50234:
	jne	%g6, %g0, jeq_else.50248
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.50249
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.50251
	addi	%g3, %g0, 0
	jmp	jle_cont.50252
jle_else.50251:
	addi	%g3, %g0, 1
jle_cont.50252:
	jmp	jle_cont.50250
jle_else.50249:
	addi	%g3, %g0, 1
jle_cont.50250:
	jne	%g3, %g0, jeq_else.50253
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.50254
	addi	%g3, %g0, 45
	jne	%g4, %g3, jeq_else.50256
	addi	%g3, %g0, -1
	sti	%g3, %g31, 24
	jmp	jeq_cont.50257
jeq_else.50256:
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
jeq_cont.50257:
	jmp	jeq_cont.50255
jeq_else.50254:
jeq_cont.50255:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	jmp	read_float_token1.2575
jeq_else.50253:
	addi	%g6, %g0, 0
	jmp	read_float_token1.2575
jeq_else.50248:
	mov	%g3, %g4
	return

!==============================
! args = [%g4]
! fargs = []
! use_regs = [%g5, %g4, %g3, %g27, %f15, %dummy]
! ret type = Unit
!================================
read_float_token2.2578:
	input	%g3
	addi	%g5, %g0, 48
	jlt	%g3, %g5, jle_else.50258
	addi	%g5, %g0, 57
	jlt	%g5, %g3, jle_else.50260
	addi	%g5, %g0, 0
	jmp	jle_cont.50261
jle_else.50260:
	addi	%g5, %g0, 1
jle_cont.50261:
	jmp	jle_cont.50259
jle_else.50258:
	addi	%g5, %g0, 1
jle_cont.50259:
	jne	%g5, %g0, jeq_else.50262
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.50263
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.50265
	addi	%g4, %g0, 0
	jmp	jle_cont.50266
jle_else.50265:
	addi	%g4, %g0, 1
jle_cont.50266:
	jmp	jle_cont.50264
jle_else.50263:
	addi	%g4, %g0, 1
jle_cont.50264:
	jne	%g4, %g0, jeq_else.50267
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	jmp	read_float_token2.2578
jeq_else.50267:
	return
jeq_else.50262:
	jne	%g4, %g0, jeq_else.50269
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.50270
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.50272
	addi	%g4, %g0, 0
	jmp	jle_cont.50273
jle_else.50272:
	addi	%g4, %g0, 1
jle_cont.50273:
	jmp	jle_cont.50271
jle_else.50270:
	addi	%g4, %g0, 1
jle_cont.50271:
	jne	%g4, %g0, jeq_else.50274
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	jmp	read_float_token2.2578
jeq_else.50274:
	addi	%g4, %g0, 0
	jmp	read_float_token2.2578
jeq_else.50269:
	return

!==============================
! args = [%g4, %g6, %g9, %g10]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g10, %f15]
! ret type = Int
!================================
div_binary_search.2582:
	add	%g3, %g9, %g10
	srli	%g5, %g3, 1
	mul	%g7, %g5, %g6
	sub	%g3, %g10, %g9
	jlt	%g28, %g3, jle_else.50276
	mov	%g3, %g9
	return
jle_else.50276:
	jlt	%g7, %g4, jle_else.50277
	jne	%g7, %g4, jeq_else.50278
	mov	%g3, %g5
	return
jeq_else.50278:
	add	%g3, %g9, %g5
	srli	%g7, %g3, 1
	mul	%g8, %g7, %g6
	sub	%g3, %g5, %g9
	jlt	%g28, %g3, jle_else.50279
	mov	%g3, %g9
	return
jle_else.50279:
	jlt	%g8, %g4, jle_else.50280
	jne	%g8, %g4, jeq_else.50281
	mov	%g3, %g7
	return
jeq_else.50281:
	add	%g3, %g9, %g7
	srli	%g8, %g3, 1
	mul	%g5, %g8, %g6
	sub	%g3, %g7, %g9
	jlt	%g28, %g3, jle_else.50282
	mov	%g3, %g9
	return
jle_else.50282:
	jlt	%g5, %g4, jle_else.50283
	jne	%g5, %g4, jeq_else.50284
	mov	%g3, %g8
	return
jeq_else.50284:
	add	%g3, %g9, %g8
	srli	%g5, %g3, 1
	mul	%g7, %g5, %g6
	sub	%g3, %g8, %g9
	jlt	%g28, %g3, jle_else.50285
	mov	%g3, %g9
	return
jle_else.50285:
	jlt	%g7, %g4, jle_else.50286
	jne	%g7, %g4, jeq_else.50287
	mov	%g3, %g5
	return
jeq_else.50287:
	mov	%g10, %g5
	jmp	div_binary_search.2582
jle_else.50286:
	mov	%g10, %g8
	mov	%g9, %g5
	jmp	div_binary_search.2582
jle_else.50283:
	add	%g3, %g8, %g7
	srli	%g5, %g3, 1
	mul	%g9, %g5, %g6
	sub	%g3, %g7, %g8
	jlt	%g28, %g3, jle_else.50288
	mov	%g3, %g8
	return
jle_else.50288:
	jlt	%g9, %g4, jle_else.50289
	jne	%g9, %g4, jeq_else.50290
	mov	%g3, %g5
	return
jeq_else.50290:
	mov	%g10, %g5
	mov	%g9, %g8
	jmp	div_binary_search.2582
jle_else.50289:
	mov	%g10, %g7
	mov	%g9, %g5
	jmp	div_binary_search.2582
jle_else.50280:
	add	%g3, %g7, %g5
	srli	%g8, %g3, 1
	mul	%g9, %g8, %g6
	sub	%g3, %g5, %g7
	jlt	%g28, %g3, jle_else.50291
	mov	%g3, %g7
	return
jle_else.50291:
	jlt	%g9, %g4, jle_else.50292
	jne	%g9, %g4, jeq_else.50293
	mov	%g3, %g8
	return
jeq_else.50293:
	add	%g3, %g7, %g8
	srli	%g5, %g3, 1
	mul	%g9, %g5, %g6
	sub	%g3, %g8, %g7
	jlt	%g28, %g3, jle_else.50294
	mov	%g3, %g7
	return
jle_else.50294:
	jlt	%g9, %g4, jle_else.50295
	jne	%g9, %g4, jeq_else.50296
	mov	%g3, %g5
	return
jeq_else.50296:
	mov	%g10, %g5
	mov	%g9, %g7
	jmp	div_binary_search.2582
jle_else.50295:
	mov	%g10, %g8
	mov	%g9, %g5
	jmp	div_binary_search.2582
jle_else.50292:
	add	%g3, %g8, %g5
	srli	%g7, %g3, 1
	mul	%g9, %g7, %g6
	sub	%g3, %g5, %g8
	jlt	%g28, %g3, jle_else.50297
	mov	%g3, %g8
	return
jle_else.50297:
	jlt	%g9, %g4, jle_else.50298
	jne	%g9, %g4, jeq_else.50299
	mov	%g3, %g7
	return
jeq_else.50299:
	mov	%g10, %g7
	mov	%g9, %g8
	jmp	div_binary_search.2582
jle_else.50298:
	mov	%g10, %g5
	mov	%g9, %g7
	jmp	div_binary_search.2582
jle_else.50277:
	add	%g3, %g5, %g10
	srli	%g8, %g3, 1
	mul	%g7, %g8, %g6
	sub	%g3, %g10, %g5
	jlt	%g28, %g3, jle_else.50300
	mov	%g3, %g5
	return
jle_else.50300:
	jlt	%g7, %g4, jle_else.50301
	jne	%g7, %g4, jeq_else.50302
	mov	%g3, %g8
	return
jeq_else.50302:
	add	%g3, %g5, %g8
	srli	%g7, %g3, 1
	mul	%g9, %g7, %g6
	sub	%g3, %g8, %g5
	jlt	%g28, %g3, jle_else.50303
	mov	%g3, %g5
	return
jle_else.50303:
	jlt	%g9, %g4, jle_else.50304
	jne	%g9, %g4, jeq_else.50305
	mov	%g3, %g7
	return
jeq_else.50305:
	add	%g3, %g5, %g7
	srli	%g8, %g3, 1
	mul	%g9, %g8, %g6
	sub	%g3, %g7, %g5
	jlt	%g28, %g3, jle_else.50306
	mov	%g3, %g5
	return
jle_else.50306:
	jlt	%g9, %g4, jle_else.50307
	jne	%g9, %g4, jeq_else.50308
	mov	%g3, %g8
	return
jeq_else.50308:
	mov	%g10, %g8
	mov	%g9, %g5
	jmp	div_binary_search.2582
jle_else.50307:
	mov	%g10, %g7
	mov	%g9, %g8
	jmp	div_binary_search.2582
jle_else.50304:
	add	%g3, %g7, %g8
	srli	%g5, %g3, 1
	mul	%g9, %g5, %g6
	sub	%g3, %g8, %g7
	jlt	%g28, %g3, jle_else.50309
	mov	%g3, %g7
	return
jle_else.50309:
	jlt	%g9, %g4, jle_else.50310
	jne	%g9, %g4, jeq_else.50311
	mov	%g3, %g5
	return
jeq_else.50311:
	mov	%g10, %g5
	mov	%g9, %g7
	jmp	div_binary_search.2582
jle_else.50310:
	mov	%g10, %g8
	mov	%g9, %g5
	jmp	div_binary_search.2582
jle_else.50301:
	add	%g3, %g8, %g10
	srli	%g7, %g3, 1
	mul	%g5, %g7, %g6
	sub	%g3, %g10, %g8
	jlt	%g28, %g3, jle_else.50312
	mov	%g3, %g8
	return
jle_else.50312:
	jlt	%g5, %g4, jle_else.50313
	jne	%g5, %g4, jeq_else.50314
	mov	%g3, %g7
	return
jeq_else.50314:
	add	%g3, %g8, %g7
	srli	%g5, %g3, 1
	mul	%g9, %g5, %g6
	sub	%g3, %g7, %g8
	jlt	%g28, %g3, jle_else.50315
	mov	%g3, %g8
	return
jle_else.50315:
	jlt	%g9, %g4, jle_else.50316
	jne	%g9, %g4, jeq_else.50317
	mov	%g3, %g5
	return
jeq_else.50317:
	mov	%g10, %g5
	mov	%g9, %g8
	jmp	div_binary_search.2582
jle_else.50316:
	mov	%g10, %g7
	mov	%g9, %g5
	jmp	div_binary_search.2582
jle_else.50313:
	add	%g3, %g7, %g10
	srli	%g5, %g3, 1
	mul	%g8, %g5, %g6
	sub	%g3, %g10, %g7
	jlt	%g28, %g3, jle_else.50318
	mov	%g3, %g7
	return
jle_else.50318:
	jlt	%g8, %g4, jle_else.50319
	jne	%g8, %g4, jeq_else.50320
	mov	%g3, %g5
	return
jeq_else.50320:
	mov	%g10, %g5
	mov	%g9, %g7
	jmp	div_binary_search.2582
jle_else.50319:
	mov	%g9, %g5
	jmp	div_binary_search.2582

!==============================
! args = [%g4]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g14, %g13, %g12, %g11, %g10, %f15, %dummy]
! ret type = Unit
!================================
print_int.2587:
	jlt	%g4, %g0, jge_else.50321
	mvhi	%g3, 1525
	mvlo	%g3, 57600
	jlt	%g3, %g4, jle_else.50322
	jne	%g3, %g4, jeq_else.50324
	addi	%g5, %g0, 1
	jmp	jeq_cont.50325
jeq_else.50324:
	addi	%g5, %g0, 0
jeq_cont.50325:
	jmp	jle_cont.50323
jle_else.50322:
	mvhi	%g3, 3051
	mvlo	%g3, 49664
	jlt	%g3, %g4, jle_else.50326
	jne	%g3, %g4, jeq_else.50328
	addi	%g5, %g0, 2
	jmp	jeq_cont.50329
jeq_else.50328:
	addi	%g5, %g0, 1
jeq_cont.50329:
	jmp	jle_cont.50327
jle_else.50326:
	addi	%g5, %g0, 2
jle_cont.50327:
jle_cont.50323:
	mvhi	%g3, 1525
	mvlo	%g3, 57600
	mul	%g3, %g5, %g3
	sub	%g4, %g4, %g3
	jlt	%g0, %g5, jle_else.50330
	addi	%g13, %g0, 0
	jmp	jle_cont.50331
jle_else.50330:
	addi	%g3, %g0, 48
	add	%g3, %g3, %g5
	output	%g3
	addi	%g13, %g0, 1
jle_cont.50331:
	mvhi	%g6, 152
	mvlo	%g6, 38528
	addi	%g12, %g0, 0
	addi	%g10, %g0, 10
	addi	%g9, %g0, 5
	mvhi	%g5, 762
	mvlo	%g5, 61568
	sti	%g4, %g1, 0
	jlt	%g5, %g4, jle_else.50332
	jne	%g5, %g4, jeq_else.50334
	addi	%g3, %g0, 5
	jmp	jeq_cont.50335
jeq_else.50334:
	addi	%g11, %g0, 2
	mvhi	%g5, 305
	mvlo	%g5, 11520
	jlt	%g5, %g4, jle_else.50336
	jne	%g5, %g4, jeq_else.50338
	addi	%g3, %g0, 2
	jmp	jeq_cont.50339
jeq_else.50338:
	addi	%g9, %g0, 1
	mvhi	%g5, 152
	mvlo	%g5, 38528
	jlt	%g5, %g4, jle_else.50340
	jne	%g5, %g4, jeq_else.50342
	addi	%g3, %g0, 1
	jmp	jeq_cont.50343
jeq_else.50342:
	mov	%g10, %g9
	mov	%g9, %g12
	subi	%g1, %g1, 8
	call	div_binary_search.2582
	addi	%g1, %g1, 8
jeq_cont.50343:
	jmp	jle_cont.50341
jle_else.50340:
	mov	%g10, %g11
	subi	%g1, %g1, 8
	call	div_binary_search.2582
	addi	%g1, %g1, 8
jle_cont.50341:
jeq_cont.50339:
	jmp	jle_cont.50337
jle_else.50336:
	addi	%g10, %g0, 3
	mvhi	%g5, 457
	mvlo	%g5, 50048
	jlt	%g5, %g4, jle_else.50344
	jne	%g5, %g4, jeq_else.50346
	addi	%g3, %g0, 3
	jmp	jeq_cont.50347
jeq_else.50346:
	mov	%g9, %g11
	subi	%g1, %g1, 8
	call	div_binary_search.2582
	addi	%g1, %g1, 8
jeq_cont.50347:
	jmp	jle_cont.50345
jle_else.50344:
	mov	%g27, %g10
	mov	%g10, %g9
	mov	%g9, %g27
	subi	%g1, %g1, 8
	call	div_binary_search.2582
	addi	%g1, %g1, 8
jle_cont.50345:
jle_cont.50337:
jeq_cont.50335:
	jmp	jle_cont.50333
jle_else.50332:
	addi	%g11, %g0, 7
	mvhi	%g5, 1068
	mvlo	%g5, 7552
	jlt	%g5, %g4, jle_else.50348
	jne	%g5, %g4, jeq_else.50350
	addi	%g3, %g0, 7
	jmp	jeq_cont.50351
jeq_else.50350:
	addi	%g10, %g0, 6
	mvhi	%g5, 915
	mvlo	%g5, 34560
	jlt	%g5, %g4, jle_else.50352
	jne	%g5, %g4, jeq_else.50354
	addi	%g3, %g0, 6
	jmp	jeq_cont.50355
jeq_else.50354:
	subi	%g1, %g1, 8
	call	div_binary_search.2582
	addi	%g1, %g1, 8
jeq_cont.50355:
	jmp	jle_cont.50353
jle_else.50352:
	mov	%g9, %g10
	mov	%g10, %g11
	subi	%g1, %g1, 8
	call	div_binary_search.2582
	addi	%g1, %g1, 8
jle_cont.50353:
jeq_cont.50351:
	jmp	jle_cont.50349
jle_else.50348:
	addi	%g9, %g0, 8
	mvhi	%g5, 1220
	mvlo	%g5, 46080
	jlt	%g5, %g4, jle_else.50356
	jne	%g5, %g4, jeq_else.50358
	addi	%g3, %g0, 8
	jmp	jeq_cont.50359
jeq_else.50358:
	mov	%g10, %g9
	mov	%g9, %g11
	subi	%g1, %g1, 8
	call	div_binary_search.2582
	addi	%g1, %g1, 8
jeq_cont.50359:
	jmp	jle_cont.50357
jle_else.50356:
	subi	%g1, %g1, 8
	call	div_binary_search.2582
	addi	%g1, %g1, 8
jle_cont.50357:
jle_cont.50349:
jle_cont.50333:
	mvhi	%g5, 152
	mvlo	%g5, 38528
	mul	%g5, %g3, %g5
	ldi	%g4, %g1, 0
	sub	%g4, %g4, %g5
	jlt	%g0, %g3, jle_else.50360
	jne	%g13, %g0, jeq_else.50362
	addi	%g14, %g0, 0
	jmp	jeq_cont.50363
jeq_else.50362:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g14, %g0, 1
jeq_cont.50363:
	jmp	jle_cont.50361
jle_else.50360:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g14, %g0, 1
jle_cont.50361:
	mvhi	%g6, 15
	mvlo	%g6, 16960
	addi	%g12, %g0, 0
	addi	%g10, %g0, 10
	addi	%g9, %g0, 5
	mvhi	%g5, 76
	mvlo	%g5, 19264
	sti	%g4, %g1, 4
	jlt	%g5, %g4, jle_else.50364
	jne	%g5, %g4, jeq_else.50366
	addi	%g3, %g0, 5
	jmp	jeq_cont.50367
jeq_else.50366:
	addi	%g11, %g0, 2
	mvhi	%g5, 30
	mvlo	%g5, 33920
	jlt	%g5, %g4, jle_else.50368
	jne	%g5, %g4, jeq_else.50370
	addi	%g3, %g0, 2
	jmp	jeq_cont.50371
jeq_else.50370:
	addi	%g9, %g0, 1
	mvhi	%g5, 15
	mvlo	%g5, 16960
	jlt	%g5, %g4, jle_else.50372
	jne	%g5, %g4, jeq_else.50374
	addi	%g3, %g0, 1
	jmp	jeq_cont.50375
jeq_else.50374:
	mov	%g10, %g9
	mov	%g9, %g12
	subi	%g1, %g1, 12
	call	div_binary_search.2582
	addi	%g1, %g1, 12
jeq_cont.50375:
	jmp	jle_cont.50373
jle_else.50372:
	mov	%g10, %g11
	subi	%g1, %g1, 12
	call	div_binary_search.2582
	addi	%g1, %g1, 12
jle_cont.50373:
jeq_cont.50371:
	jmp	jle_cont.50369
jle_else.50368:
	addi	%g10, %g0, 3
	mvhi	%g5, 45
	mvlo	%g5, 50880
	jlt	%g5, %g4, jle_else.50376
	jne	%g5, %g4, jeq_else.50378
	addi	%g3, %g0, 3
	jmp	jeq_cont.50379
jeq_else.50378:
	mov	%g9, %g11
	subi	%g1, %g1, 12
	call	div_binary_search.2582
	addi	%g1, %g1, 12
jeq_cont.50379:
	jmp	jle_cont.50377
jle_else.50376:
	mov	%g27, %g10
	mov	%g10, %g9
	mov	%g9, %g27
	subi	%g1, %g1, 12
	call	div_binary_search.2582
	addi	%g1, %g1, 12
jle_cont.50377:
jle_cont.50369:
jeq_cont.50367:
	jmp	jle_cont.50365
jle_else.50364:
	addi	%g11, %g0, 7
	mvhi	%g5, 106
	mvlo	%g5, 53184
	jlt	%g5, %g4, jle_else.50380
	jne	%g5, %g4, jeq_else.50382
	addi	%g3, %g0, 7
	jmp	jeq_cont.50383
jeq_else.50382:
	addi	%g10, %g0, 6
	mvhi	%g5, 91
	mvlo	%g5, 36224
	jlt	%g5, %g4, jle_else.50384
	jne	%g5, %g4, jeq_else.50386
	addi	%g3, %g0, 6
	jmp	jeq_cont.50387
jeq_else.50386:
	subi	%g1, %g1, 12
	call	div_binary_search.2582
	addi	%g1, %g1, 12
jeq_cont.50387:
	jmp	jle_cont.50385
jle_else.50384:
	mov	%g9, %g10
	mov	%g10, %g11
	subi	%g1, %g1, 12
	call	div_binary_search.2582
	addi	%g1, %g1, 12
jle_cont.50385:
jeq_cont.50383:
	jmp	jle_cont.50381
jle_else.50380:
	addi	%g9, %g0, 8
	mvhi	%g5, 122
	mvlo	%g5, 4608
	jlt	%g5, %g4, jle_else.50388
	jne	%g5, %g4, jeq_else.50390
	addi	%g3, %g0, 8
	jmp	jeq_cont.50391
jeq_else.50390:
	mov	%g10, %g9
	mov	%g9, %g11
	subi	%g1, %g1, 12
	call	div_binary_search.2582
	addi	%g1, %g1, 12
jeq_cont.50391:
	jmp	jle_cont.50389
jle_else.50388:
	subi	%g1, %g1, 12
	call	div_binary_search.2582
	addi	%g1, %g1, 12
jle_cont.50389:
jle_cont.50381:
jle_cont.50365:
	mvhi	%g5, 15
	mvlo	%g5, 16960
	mul	%g5, %g3, %g5
	ldi	%g4, %g1, 4
	sub	%g4, %g4, %g5
	jlt	%g0, %g3, jle_else.50392
	jne	%g14, %g0, jeq_else.50394
	addi	%g13, %g0, 0
	jmp	jeq_cont.50395
jeq_else.50394:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g13, %g0, 1
jeq_cont.50395:
	jmp	jle_cont.50393
jle_else.50392:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g13, %g0, 1
jle_cont.50393:
	mvhi	%g6, 1
	mvlo	%g6, 34464
	addi	%g12, %g0, 0
	addi	%g10, %g0, 10
	addi	%g9, %g0, 5
	mvhi	%g5, 7
	mvlo	%g5, 41248
	sti	%g4, %g1, 8
	jlt	%g5, %g4, jle_else.50396
	jne	%g5, %g4, jeq_else.50398
	addi	%g3, %g0, 5
	jmp	jeq_cont.50399
jeq_else.50398:
	addi	%g11, %g0, 2
	mvhi	%g5, 3
	mvlo	%g5, 3392
	jlt	%g5, %g4, jle_else.50400
	jne	%g5, %g4, jeq_else.50402
	addi	%g3, %g0, 2
	jmp	jeq_cont.50403
jeq_else.50402:
	addi	%g9, %g0, 1
	mvhi	%g5, 1
	mvlo	%g5, 34464
	jlt	%g5, %g4, jle_else.50404
	jne	%g5, %g4, jeq_else.50406
	addi	%g3, %g0, 1
	jmp	jeq_cont.50407
jeq_else.50406:
	mov	%g10, %g9
	mov	%g9, %g12
	subi	%g1, %g1, 16
	call	div_binary_search.2582
	addi	%g1, %g1, 16
jeq_cont.50407:
	jmp	jle_cont.50405
jle_else.50404:
	mov	%g10, %g11
	subi	%g1, %g1, 16
	call	div_binary_search.2582
	addi	%g1, %g1, 16
jle_cont.50405:
jeq_cont.50403:
	jmp	jle_cont.50401
jle_else.50400:
	addi	%g10, %g0, 3
	mvhi	%g5, 4
	mvlo	%g5, 37856
	jlt	%g5, %g4, jle_else.50408
	jne	%g5, %g4, jeq_else.50410
	addi	%g3, %g0, 3
	jmp	jeq_cont.50411
jeq_else.50410:
	mov	%g9, %g11
	subi	%g1, %g1, 16
	call	div_binary_search.2582
	addi	%g1, %g1, 16
jeq_cont.50411:
	jmp	jle_cont.50409
jle_else.50408:
	mov	%g27, %g10
	mov	%g10, %g9
	mov	%g9, %g27
	subi	%g1, %g1, 16
	call	div_binary_search.2582
	addi	%g1, %g1, 16
jle_cont.50409:
jle_cont.50401:
jeq_cont.50399:
	jmp	jle_cont.50397
jle_else.50396:
	addi	%g11, %g0, 7
	mvhi	%g5, 10
	mvlo	%g5, 44640
	jlt	%g5, %g4, jle_else.50412
	jne	%g5, %g4, jeq_else.50414
	addi	%g3, %g0, 7
	jmp	jeq_cont.50415
jeq_else.50414:
	addi	%g10, %g0, 6
	mvhi	%g5, 9
	mvlo	%g5, 10176
	jlt	%g5, %g4, jle_else.50416
	jne	%g5, %g4, jeq_else.50418
	addi	%g3, %g0, 6
	jmp	jeq_cont.50419
jeq_else.50418:
	subi	%g1, %g1, 16
	call	div_binary_search.2582
	addi	%g1, %g1, 16
jeq_cont.50419:
	jmp	jle_cont.50417
jle_else.50416:
	mov	%g9, %g10
	mov	%g10, %g11
	subi	%g1, %g1, 16
	call	div_binary_search.2582
	addi	%g1, %g1, 16
jle_cont.50417:
jeq_cont.50415:
	jmp	jle_cont.50413
jle_else.50412:
	addi	%g9, %g0, 8
	mvhi	%g5, 12
	mvlo	%g5, 13568
	jlt	%g5, %g4, jle_else.50420
	jne	%g5, %g4, jeq_else.50422
	addi	%g3, %g0, 8
	jmp	jeq_cont.50423
jeq_else.50422:
	mov	%g10, %g9
	mov	%g9, %g11
	subi	%g1, %g1, 16
	call	div_binary_search.2582
	addi	%g1, %g1, 16
jeq_cont.50423:
	jmp	jle_cont.50421
jle_else.50420:
	subi	%g1, %g1, 16
	call	div_binary_search.2582
	addi	%g1, %g1, 16
jle_cont.50421:
jle_cont.50413:
jle_cont.50397:
	mvhi	%g5, 1
	mvlo	%g5, 34464
	mul	%g5, %g3, %g5
	ldi	%g4, %g1, 8
	sub	%g4, %g4, %g5
	jlt	%g0, %g3, jle_else.50424
	jne	%g13, %g0, jeq_else.50426
	addi	%g14, %g0, 0
	jmp	jeq_cont.50427
jeq_else.50426:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g14, %g0, 1
jeq_cont.50427:
	jmp	jle_cont.50425
jle_else.50424:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g14, %g0, 1
jle_cont.50425:
	addi	%g6, %g0, 10000
	addi	%g12, %g0, 0
	addi	%g10, %g0, 10
	addi	%g9, %g0, 5
	mvhi	%g5, 0
	mvlo	%g5, 50000
	sti	%g4, %g1, 12
	jlt	%g5, %g4, jle_else.50428
	jne	%g5, %g4, jeq_else.50430
	addi	%g3, %g0, 5
	jmp	jeq_cont.50431
jeq_else.50430:
	addi	%g11, %g0, 2
	addi	%g5, %g0, 20000
	jlt	%g5, %g4, jle_else.50432
	jne	%g5, %g4, jeq_else.50434
	addi	%g3, %g0, 2
	jmp	jeq_cont.50435
jeq_else.50434:
	addi	%g9, %g0, 1
	addi	%g5, %g0, 10000
	jlt	%g5, %g4, jle_else.50436
	jne	%g5, %g4, jeq_else.50438
	addi	%g3, %g0, 1
	jmp	jeq_cont.50439
jeq_else.50438:
	mov	%g10, %g9
	mov	%g9, %g12
	subi	%g1, %g1, 20
	call	div_binary_search.2582
	addi	%g1, %g1, 20
jeq_cont.50439:
	jmp	jle_cont.50437
jle_else.50436:
	mov	%g10, %g11
	subi	%g1, %g1, 20
	call	div_binary_search.2582
	addi	%g1, %g1, 20
jle_cont.50437:
jeq_cont.50435:
	jmp	jle_cont.50433
jle_else.50432:
	addi	%g10, %g0, 3
	addi	%g5, %g0, 30000
	jlt	%g5, %g4, jle_else.50440
	jne	%g5, %g4, jeq_else.50442
	addi	%g3, %g0, 3
	jmp	jeq_cont.50443
jeq_else.50442:
	mov	%g9, %g11
	subi	%g1, %g1, 20
	call	div_binary_search.2582
	addi	%g1, %g1, 20
jeq_cont.50443:
	jmp	jle_cont.50441
jle_else.50440:
	mov	%g27, %g10
	mov	%g10, %g9
	mov	%g9, %g27
	subi	%g1, %g1, 20
	call	div_binary_search.2582
	addi	%g1, %g1, 20
jle_cont.50441:
jle_cont.50433:
jeq_cont.50431:
	jmp	jle_cont.50429
jle_else.50428:
	addi	%g11, %g0, 7
	mvhi	%g5, 1
	mvlo	%g5, 4464
	jlt	%g5, %g4, jle_else.50444
	jne	%g5, %g4, jeq_else.50446
	addi	%g3, %g0, 7
	jmp	jeq_cont.50447
jeq_else.50446:
	addi	%g10, %g0, 6
	mvhi	%g5, 0
	mvlo	%g5, 60000
	jlt	%g5, %g4, jle_else.50448
	jne	%g5, %g4, jeq_else.50450
	addi	%g3, %g0, 6
	jmp	jeq_cont.50451
jeq_else.50450:
	subi	%g1, %g1, 20
	call	div_binary_search.2582
	addi	%g1, %g1, 20
jeq_cont.50451:
	jmp	jle_cont.50449
jle_else.50448:
	mov	%g9, %g10
	mov	%g10, %g11
	subi	%g1, %g1, 20
	call	div_binary_search.2582
	addi	%g1, %g1, 20
jle_cont.50449:
jeq_cont.50447:
	jmp	jle_cont.50445
jle_else.50444:
	addi	%g9, %g0, 8
	mvhi	%g5, 1
	mvlo	%g5, 14464
	jlt	%g5, %g4, jle_else.50452
	jne	%g5, %g4, jeq_else.50454
	addi	%g3, %g0, 8
	jmp	jeq_cont.50455
jeq_else.50454:
	mov	%g10, %g9
	mov	%g9, %g11
	subi	%g1, %g1, 20
	call	div_binary_search.2582
	addi	%g1, %g1, 20
jeq_cont.50455:
	jmp	jle_cont.50453
jle_else.50452:
	subi	%g1, %g1, 20
	call	div_binary_search.2582
	addi	%g1, %g1, 20
jle_cont.50453:
jle_cont.50445:
jle_cont.50429:
	addi	%g5, %g0, 10000
	mul	%g5, %g3, %g5
	ldi	%g4, %g1, 12
	sub	%g4, %g4, %g5
	jlt	%g0, %g3, jle_else.50456
	jne	%g14, %g0, jeq_else.50458
	addi	%g13, %g0, 0
	jmp	jeq_cont.50459
jeq_else.50458:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g13, %g0, 1
jeq_cont.50459:
	jmp	jle_cont.50457
jle_else.50456:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g13, %g0, 1
jle_cont.50457:
	addi	%g6, %g0, 1000
	addi	%g12, %g0, 0
	addi	%g10, %g0, 10
	addi	%g9, %g0, 5
	addi	%g5, %g0, 5000
	sti	%g4, %g1, 16
	jlt	%g5, %g4, jle_else.50460
	jne	%g5, %g4, jeq_else.50462
	addi	%g3, %g0, 5
	jmp	jeq_cont.50463
jeq_else.50462:
	addi	%g11, %g0, 2
	addi	%g5, %g0, 2000
	jlt	%g5, %g4, jle_else.50464
	jne	%g5, %g4, jeq_else.50466
	addi	%g3, %g0, 2
	jmp	jeq_cont.50467
jeq_else.50466:
	addi	%g9, %g0, 1
	addi	%g5, %g0, 1000
	jlt	%g5, %g4, jle_else.50468
	jne	%g5, %g4, jeq_else.50470
	addi	%g3, %g0, 1
	jmp	jeq_cont.50471
jeq_else.50470:
	mov	%g10, %g9
	mov	%g9, %g12
	subi	%g1, %g1, 24
	call	div_binary_search.2582
	addi	%g1, %g1, 24
jeq_cont.50471:
	jmp	jle_cont.50469
jle_else.50468:
	mov	%g10, %g11
	subi	%g1, %g1, 24
	call	div_binary_search.2582
	addi	%g1, %g1, 24
jle_cont.50469:
jeq_cont.50467:
	jmp	jle_cont.50465
jle_else.50464:
	addi	%g10, %g0, 3
	addi	%g5, %g0, 3000
	jlt	%g5, %g4, jle_else.50472
	jne	%g5, %g4, jeq_else.50474
	addi	%g3, %g0, 3
	jmp	jeq_cont.50475
jeq_else.50474:
	mov	%g9, %g11
	subi	%g1, %g1, 24
	call	div_binary_search.2582
	addi	%g1, %g1, 24
jeq_cont.50475:
	jmp	jle_cont.50473
jle_else.50472:
	mov	%g27, %g10
	mov	%g10, %g9
	mov	%g9, %g27
	subi	%g1, %g1, 24
	call	div_binary_search.2582
	addi	%g1, %g1, 24
jle_cont.50473:
jle_cont.50465:
jeq_cont.50463:
	jmp	jle_cont.50461
jle_else.50460:
	addi	%g11, %g0, 7
	addi	%g5, %g0, 7000
	jlt	%g5, %g4, jle_else.50476
	jne	%g5, %g4, jeq_else.50478
	addi	%g3, %g0, 7
	jmp	jeq_cont.50479
jeq_else.50478:
	addi	%g10, %g0, 6
	addi	%g5, %g0, 6000
	jlt	%g5, %g4, jle_else.50480
	jne	%g5, %g4, jeq_else.50482
	addi	%g3, %g0, 6
	jmp	jeq_cont.50483
jeq_else.50482:
	subi	%g1, %g1, 24
	call	div_binary_search.2582
	addi	%g1, %g1, 24
jeq_cont.50483:
	jmp	jle_cont.50481
jle_else.50480:
	mov	%g9, %g10
	mov	%g10, %g11
	subi	%g1, %g1, 24
	call	div_binary_search.2582
	addi	%g1, %g1, 24
jle_cont.50481:
jeq_cont.50479:
	jmp	jle_cont.50477
jle_else.50476:
	addi	%g9, %g0, 8
	addi	%g5, %g0, 8000
	jlt	%g5, %g4, jle_else.50484
	jne	%g5, %g4, jeq_else.50486
	addi	%g3, %g0, 8
	jmp	jeq_cont.50487
jeq_else.50486:
	mov	%g10, %g9
	mov	%g9, %g11
	subi	%g1, %g1, 24
	call	div_binary_search.2582
	addi	%g1, %g1, 24
jeq_cont.50487:
	jmp	jle_cont.50485
jle_else.50484:
	subi	%g1, %g1, 24
	call	div_binary_search.2582
	addi	%g1, %g1, 24
jle_cont.50485:
jle_cont.50477:
jle_cont.50461:
	muli	%g5, %g3, 1000
	ldi	%g4, %g1, 16
	sub	%g4, %g4, %g5
	jlt	%g0, %g3, jle_else.50488
	jne	%g13, %g0, jeq_else.50490
	addi	%g14, %g0, 0
	jmp	jeq_cont.50491
jeq_else.50490:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g14, %g0, 1
jeq_cont.50491:
	jmp	jle_cont.50489
jle_else.50488:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g14, %g0, 1
jle_cont.50489:
	addi	%g6, %g0, 100
	addi	%g12, %g0, 0
	addi	%g10, %g0, 10
	addi	%g9, %g0, 5
	addi	%g5, %g0, 500
	sti	%g4, %g1, 20
	jlt	%g5, %g4, jle_else.50492
	jne	%g5, %g4, jeq_else.50494
	addi	%g3, %g0, 5
	jmp	jeq_cont.50495
jeq_else.50494:
	addi	%g11, %g0, 2
	addi	%g5, %g0, 200
	jlt	%g5, %g4, jle_else.50496
	jne	%g5, %g4, jeq_else.50498
	addi	%g3, %g0, 2
	jmp	jeq_cont.50499
jeq_else.50498:
	addi	%g9, %g0, 1
	addi	%g5, %g0, 100
	jlt	%g5, %g4, jle_else.50500
	jne	%g5, %g4, jeq_else.50502
	addi	%g3, %g0, 1
	jmp	jeq_cont.50503
jeq_else.50502:
	mov	%g10, %g9
	mov	%g9, %g12
	subi	%g1, %g1, 28
	call	div_binary_search.2582
	addi	%g1, %g1, 28
jeq_cont.50503:
	jmp	jle_cont.50501
jle_else.50500:
	mov	%g10, %g11
	subi	%g1, %g1, 28
	call	div_binary_search.2582
	addi	%g1, %g1, 28
jle_cont.50501:
jeq_cont.50499:
	jmp	jle_cont.50497
jle_else.50496:
	addi	%g10, %g0, 3
	addi	%g5, %g0, 300
	jlt	%g5, %g4, jle_else.50504
	jne	%g5, %g4, jeq_else.50506
	addi	%g3, %g0, 3
	jmp	jeq_cont.50507
jeq_else.50506:
	mov	%g9, %g11
	subi	%g1, %g1, 28
	call	div_binary_search.2582
	addi	%g1, %g1, 28
jeq_cont.50507:
	jmp	jle_cont.50505
jle_else.50504:
	mov	%g27, %g10
	mov	%g10, %g9
	mov	%g9, %g27
	subi	%g1, %g1, 28
	call	div_binary_search.2582
	addi	%g1, %g1, 28
jle_cont.50505:
jle_cont.50497:
jeq_cont.50495:
	jmp	jle_cont.50493
jle_else.50492:
	addi	%g11, %g0, 7
	addi	%g5, %g0, 700
	jlt	%g5, %g4, jle_else.50508
	jne	%g5, %g4, jeq_else.50510
	addi	%g3, %g0, 7
	jmp	jeq_cont.50511
jeq_else.50510:
	addi	%g10, %g0, 6
	addi	%g5, %g0, 600
	jlt	%g5, %g4, jle_else.50512
	jne	%g5, %g4, jeq_else.50514
	addi	%g3, %g0, 6
	jmp	jeq_cont.50515
jeq_else.50514:
	subi	%g1, %g1, 28
	call	div_binary_search.2582
	addi	%g1, %g1, 28
jeq_cont.50515:
	jmp	jle_cont.50513
jle_else.50512:
	mov	%g9, %g10
	mov	%g10, %g11
	subi	%g1, %g1, 28
	call	div_binary_search.2582
	addi	%g1, %g1, 28
jle_cont.50513:
jeq_cont.50511:
	jmp	jle_cont.50509
jle_else.50508:
	addi	%g9, %g0, 8
	addi	%g5, %g0, 800
	jlt	%g5, %g4, jle_else.50516
	jne	%g5, %g4, jeq_else.50518
	addi	%g3, %g0, 8
	jmp	jeq_cont.50519
jeq_else.50518:
	mov	%g10, %g9
	mov	%g9, %g11
	subi	%g1, %g1, 28
	call	div_binary_search.2582
	addi	%g1, %g1, 28
jeq_cont.50519:
	jmp	jle_cont.50517
jle_else.50516:
	subi	%g1, %g1, 28
	call	div_binary_search.2582
	addi	%g1, %g1, 28
jle_cont.50517:
jle_cont.50509:
jle_cont.50493:
	muli	%g5, %g3, 100
	ldi	%g4, %g1, 20
	sub	%g4, %g4, %g5
	jlt	%g0, %g3, jle_else.50520
	jne	%g14, %g0, jeq_else.50522
	addi	%g13, %g0, 0
	jmp	jeq_cont.50523
jeq_else.50522:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g13, %g0, 1
jeq_cont.50523:
	jmp	jle_cont.50521
jle_else.50520:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g13, %g0, 1
jle_cont.50521:
	addi	%g6, %g0, 10
	addi	%g12, %g0, 0
	addi	%g10, %g0, 10
	addi	%g9, %g0, 5
	addi	%g5, %g0, 50
	sti	%g4, %g1, 24
	jlt	%g5, %g4, jle_else.50524
	jne	%g5, %g4, jeq_else.50526
	addi	%g3, %g0, 5
	jmp	jeq_cont.50527
jeq_else.50526:
	addi	%g11, %g0, 2
	addi	%g5, %g0, 20
	jlt	%g5, %g4, jle_else.50528
	jne	%g5, %g4, jeq_else.50530
	addi	%g3, %g0, 2
	jmp	jeq_cont.50531
jeq_else.50530:
	addi	%g9, %g0, 1
	addi	%g5, %g0, 10
	jlt	%g5, %g4, jle_else.50532
	jne	%g5, %g4, jeq_else.50534
	addi	%g3, %g0, 1
	jmp	jeq_cont.50535
jeq_else.50534:
	mov	%g10, %g9
	mov	%g9, %g12
	subi	%g1, %g1, 32
	call	div_binary_search.2582
	addi	%g1, %g1, 32
jeq_cont.50535:
	jmp	jle_cont.50533
jle_else.50532:
	mov	%g10, %g11
	subi	%g1, %g1, 32
	call	div_binary_search.2582
	addi	%g1, %g1, 32
jle_cont.50533:
jeq_cont.50531:
	jmp	jle_cont.50529
jle_else.50528:
	addi	%g10, %g0, 3
	addi	%g5, %g0, 30
	jlt	%g5, %g4, jle_else.50536
	jne	%g5, %g4, jeq_else.50538
	addi	%g3, %g0, 3
	jmp	jeq_cont.50539
jeq_else.50538:
	mov	%g9, %g11
	subi	%g1, %g1, 32
	call	div_binary_search.2582
	addi	%g1, %g1, 32
jeq_cont.50539:
	jmp	jle_cont.50537
jle_else.50536:
	mov	%g27, %g10
	mov	%g10, %g9
	mov	%g9, %g27
	subi	%g1, %g1, 32
	call	div_binary_search.2582
	addi	%g1, %g1, 32
jle_cont.50537:
jle_cont.50529:
jeq_cont.50527:
	jmp	jle_cont.50525
jle_else.50524:
	addi	%g11, %g0, 7
	addi	%g5, %g0, 70
	jlt	%g5, %g4, jle_else.50540
	jne	%g5, %g4, jeq_else.50542
	addi	%g3, %g0, 7
	jmp	jeq_cont.50543
jeq_else.50542:
	addi	%g10, %g0, 6
	addi	%g5, %g0, 60
	jlt	%g5, %g4, jle_else.50544
	jne	%g5, %g4, jeq_else.50546
	addi	%g3, %g0, 6
	jmp	jeq_cont.50547
jeq_else.50546:
	subi	%g1, %g1, 32
	call	div_binary_search.2582
	addi	%g1, %g1, 32
jeq_cont.50547:
	jmp	jle_cont.50545
jle_else.50544:
	mov	%g9, %g10
	mov	%g10, %g11
	subi	%g1, %g1, 32
	call	div_binary_search.2582
	addi	%g1, %g1, 32
jle_cont.50545:
jeq_cont.50543:
	jmp	jle_cont.50541
jle_else.50540:
	addi	%g9, %g0, 8
	addi	%g5, %g0, 80
	jlt	%g5, %g4, jle_else.50548
	jne	%g5, %g4, jeq_else.50550
	addi	%g3, %g0, 8
	jmp	jeq_cont.50551
jeq_else.50550:
	mov	%g10, %g9
	mov	%g9, %g11
	subi	%g1, %g1, 32
	call	div_binary_search.2582
	addi	%g1, %g1, 32
jeq_cont.50551:
	jmp	jle_cont.50549
jle_else.50548:
	subi	%g1, %g1, 32
	call	div_binary_search.2582
	addi	%g1, %g1, 32
jle_cont.50549:
jle_cont.50541:
jle_cont.50525:
	muli	%g5, %g3, 10
	ldi	%g4, %g1, 24
	sub	%g4, %g4, %g5
	jlt	%g0, %g3, jle_else.50552
	jne	%g13, %g0, jeq_else.50554
	addi	%g5, %g0, 0
	jmp	jeq_cont.50555
jeq_else.50554:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g5, %g0, 1
jeq_cont.50555:
	jmp	jle_cont.50553
jle_else.50552:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g5, %g0, 1
jle_cont.50553:
	addi	%g3, %g0, 48
	add	%g3, %g3, %g4
	output	%g3
	return
jge_else.50321:
	addi	%g3, %g0, 45
	output	%g3
	sub	%g4, %g0, %g4
	jmp	print_int.2587

!==============================
! args = [%g16]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g2, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f29, %f26, %f25, %f24, %f23, %f22, %f21, %f20, %f2, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
read_object.2755:
	addi	%g3, %g0, 60
	jlt	%g16, %g3, jle_else.50556
	return
jle_else.50556:
	addi	%g3, %g0, 0
	sti	%g3, %g31, 4
	addi	%g3, %g0, 0
	sti	%g3, %g31, 8
	input	%g5
	addi	%g14, %g0, 48
	jlt	%g5, %g14, jle_else.50558
	addi	%g14, %g0, 57
	jlt	%g14, %g5, jle_else.50560
	addi	%g14, %g0, 0
	jmp	jle_cont.50561
jle_else.50560:
	addi	%g14, %g0, 1
jle_cont.50561:
	jmp	jle_cont.50559
jle_else.50558:
	addi	%g14, %g0, 1
jle_cont.50559:
	jne	%g14, %g0, jeq_else.50562
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.50564
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
	jmp	jeq_cont.50565
jeq_else.50564:
jeq_cont.50565:
	ldi	%g3, %g31, 4
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 4
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
	mov	%g14, %g3
	jmp	jeq_cont.50563
jeq_else.50562:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
	mov	%g14, %g3
jeq_cont.50563:
	jne	%g14, %g29, jeq_else.50566
	addi	%g3, %g0, 0
	jmp	jeq_cont.50567
jeq_else.50566:
	addi	%g3, %g0, 0
	sti	%g3, %g31, 4
	addi	%g3, %g0, 0
	sti	%g3, %g31, 8
	input	%g5
	addi	%g11, %g0, 48
	jlt	%g5, %g11, jle_else.50568
	addi	%g11, %g0, 57
	jlt	%g11, %g5, jle_else.50570
	addi	%g11, %g0, 0
	jmp	jle_cont.50571
jle_else.50570:
	addi	%g11, %g0, 1
jle_cont.50571:
	jmp	jle_cont.50569
jle_else.50568:
	addi	%g11, %g0, 1
jle_cont.50569:
	jne	%g11, %g0, jeq_else.50572
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.50574
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
	jmp	jeq_cont.50575
jeq_else.50574:
jeq_cont.50575:
	ldi	%g3, %g31, 4
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 4
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
	mov	%g11, %g3
	jmp	jeq_cont.50573
jeq_else.50572:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
	mov	%g11, %g3
jeq_cont.50573:
	addi	%g3, %g0, 0
	sti	%g3, %g31, 4
	addi	%g3, %g0, 0
	sti	%g3, %g31, 8
	input	%g5
	addi	%g15, %g0, 48
	jlt	%g5, %g15, jle_else.50576
	addi	%g15, %g0, 57
	jlt	%g15, %g5, jle_else.50578
	addi	%g15, %g0, 0
	jmp	jle_cont.50579
jle_else.50578:
	addi	%g15, %g0, 1
jle_cont.50579:
	jmp	jle_cont.50577
jle_else.50576:
	addi	%g15, %g0, 1
jle_cont.50577:
	jne	%g15, %g0, jeq_else.50580
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.50582
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
	jmp	jeq_cont.50583
jeq_else.50582:
jeq_cont.50583:
	ldi	%g3, %g31, 4
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 4
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
	mov	%g15, %g3
	jmp	jeq_cont.50581
jeq_else.50580:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
	mov	%g15, %g3
jeq_cont.50581:
	addi	%g3, %g0, 0
	sti	%g3, %g31, 4
	addi	%g3, %g0, 0
	sti	%g3, %g31, 8
	input	%g5
	addi	%g13, %g0, 48
	jlt	%g5, %g13, jle_else.50584
	addi	%g13, %g0, 57
	jlt	%g13, %g5, jle_else.50586
	addi	%g13, %g0, 0
	jmp	jle_cont.50587
jle_else.50586:
	addi	%g13, %g0, 1
jle_cont.50587:
	jmp	jle_cont.50585
jle_else.50584:
	addi	%g13, %g0, 1
jle_cont.50585:
	jne	%g13, %g0, jeq_else.50588
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.50590
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
	jmp	jeq_cont.50591
jeq_else.50590:
jeq_cont.50591:
	ldi	%g3, %g31, 4
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 4
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
	mov	%g13, %g3
	jmp	jeq_cont.50589
jeq_else.50588:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
	mov	%g13, %g3
jeq_cont.50589:
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	mov	%g8, %g3
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.50592
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.50594
	addi	%g3, %g0, 0
	jmp	jle_cont.50595
jle_else.50594:
	addi	%g3, %g0, 1
jle_cont.50595:
	jmp	jle_cont.50593
jle_else.50592:
	addi	%g3, %g0, 1
jle_cont.50593:
	jne	%g3, %g0, jeq_else.50596
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.50598
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
	jmp	jeq_cont.50599
jeq_else.50598:
jeq_cont.50599:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	jmp	jeq_cont.50597
jeq_else.50596:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
jeq_cont.50597:
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.50600
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.50602
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.50604
	addi	%g4, %g0, 0
	jmp	jle_cont.50605
jle_else.50604:
	addi	%g4, %g0, 1
jle_cont.50605:
	jmp	jle_cont.50603
jle_else.50602:
	addi	%g4, %g0, 1
jle_cont.50603:
	jne	%g4, %g0, jeq_else.50606
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
	jmp	jeq_cont.50607
jeq_else.50606:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
jeq_cont.50607:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmov	%f4, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f3, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f0, %f3, %f0
	fadd	%f0, %f4, %f0
	jmp	jeq_cont.50601
jeq_else.50600:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
jeq_cont.50601:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.50608
	fmov	%f1, %f0
	jmp	jeq_cont.50609
jeq_else.50608:
	fneg	%f1, %f0
jeq_cont.50609:
	fsti	%f1, %g8, 0
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.50610
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.50612
	addi	%g3, %g0, 0
	jmp	jle_cont.50613
jle_else.50612:
	addi	%g3, %g0, 1
jle_cont.50613:
	jmp	jle_cont.50611
jle_else.50610:
	addi	%g3, %g0, 1
jle_cont.50611:
	jne	%g3, %g0, jeq_else.50614
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.50616
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
	jmp	jeq_cont.50617
jeq_else.50616:
jeq_cont.50617:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	jmp	jeq_cont.50615
jeq_else.50614:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
jeq_cont.50615:
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.50618
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.50620
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.50622
	addi	%g4, %g0, 0
	jmp	jle_cont.50623
jle_else.50622:
	addi	%g4, %g0, 1
jle_cont.50623:
	jmp	jle_cont.50621
jle_else.50620:
	addi	%g4, %g0, 1
jle_cont.50621:
	jne	%g4, %g0, jeq_else.50624
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
	jmp	jeq_cont.50625
jeq_else.50624:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
jeq_cont.50625:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmov	%f4, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f3, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f0, %f3, %f0
	fadd	%f0, %f4, %f0
	jmp	jeq_cont.50619
jeq_else.50618:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
jeq_cont.50619:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.50626
	fmov	%f1, %f0
	jmp	jeq_cont.50627
jeq_else.50626:
	fneg	%f1, %f0
jeq_cont.50627:
	fsti	%f1, %g8, -4
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.50628
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.50630
	addi	%g3, %g0, 0
	jmp	jle_cont.50631
jle_else.50630:
	addi	%g3, %g0, 1
jle_cont.50631:
	jmp	jle_cont.50629
jle_else.50628:
	addi	%g3, %g0, 1
jle_cont.50629:
	jne	%g3, %g0, jeq_else.50632
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.50634
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
	jmp	jeq_cont.50635
jeq_else.50634:
jeq_cont.50635:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	jmp	jeq_cont.50633
jeq_else.50632:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
jeq_cont.50633:
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.50636
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.50638
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.50640
	addi	%g4, %g0, 0
	jmp	jle_cont.50641
jle_else.50640:
	addi	%g4, %g0, 1
jle_cont.50641:
	jmp	jle_cont.50639
jle_else.50638:
	addi	%g4, %g0, 1
jle_cont.50639:
	jne	%g4, %g0, jeq_else.50642
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
	jmp	jeq_cont.50643
jeq_else.50642:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
jeq_cont.50643:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmov	%f4, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f3, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f0, %f3, %f0
	fadd	%f0, %f4, %f0
	jmp	jeq_cont.50637
jeq_else.50636:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
jeq_cont.50637:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.50644
	fmov	%f1, %f0
	jmp	jeq_cont.50645
jeq_else.50644:
	fneg	%f1, %f0
jeq_cont.50645:
	fsti	%f1, %g8, -8
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	mov	%g12, %g3
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.50646
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.50648
	addi	%g3, %g0, 0
	jmp	jle_cont.50649
jle_else.50648:
	addi	%g3, %g0, 1
jle_cont.50649:
	jmp	jle_cont.50647
jle_else.50646:
	addi	%g3, %g0, 1
jle_cont.50647:
	jne	%g3, %g0, jeq_else.50650
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.50652
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
	jmp	jeq_cont.50653
jeq_else.50652:
jeq_cont.50653:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	jmp	jeq_cont.50651
jeq_else.50650:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
jeq_cont.50651:
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.50654
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.50656
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.50658
	addi	%g4, %g0, 0
	jmp	jle_cont.50659
jle_else.50658:
	addi	%g4, %g0, 1
jle_cont.50659:
	jmp	jle_cont.50657
jle_else.50656:
	addi	%g4, %g0, 1
jle_cont.50657:
	jne	%g4, %g0, jeq_else.50660
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
	jmp	jeq_cont.50661
jeq_else.50660:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
jeq_cont.50661:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmov	%f4, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f3, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f0, %f3, %f0
	fadd	%f0, %f4, %f0
	jmp	jeq_cont.50655
jeq_else.50654:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
jeq_cont.50655:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.50662
	fmov	%f1, %f0
	jmp	jeq_cont.50663
jeq_else.50662:
	fneg	%f1, %f0
jeq_cont.50663:
	fsti	%f1, %g12, 0
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.50664
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.50666
	addi	%g3, %g0, 0
	jmp	jle_cont.50667
jle_else.50666:
	addi	%g3, %g0, 1
jle_cont.50667:
	jmp	jle_cont.50665
jle_else.50664:
	addi	%g3, %g0, 1
jle_cont.50665:
	jne	%g3, %g0, jeq_else.50668
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.50670
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
	jmp	jeq_cont.50671
jeq_else.50670:
jeq_cont.50671:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	jmp	jeq_cont.50669
jeq_else.50668:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
jeq_cont.50669:
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.50672
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.50674
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.50676
	addi	%g4, %g0, 0
	jmp	jle_cont.50677
jle_else.50676:
	addi	%g4, %g0, 1
jle_cont.50677:
	jmp	jle_cont.50675
jle_else.50674:
	addi	%g4, %g0, 1
jle_cont.50675:
	jne	%g4, %g0, jeq_else.50678
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
	jmp	jeq_cont.50679
jeq_else.50678:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
jeq_cont.50679:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmov	%f4, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f3, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f0, %f3, %f0
	fadd	%f0, %f4, %f0
	jmp	jeq_cont.50673
jeq_else.50672:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
jeq_cont.50673:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.50680
	fmov	%f1, %f0
	jmp	jeq_cont.50681
jeq_else.50680:
	fneg	%f1, %f0
jeq_cont.50681:
	fsti	%f1, %g12, -4
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.50682
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.50684
	addi	%g3, %g0, 0
	jmp	jle_cont.50685
jle_else.50684:
	addi	%g3, %g0, 1
jle_cont.50685:
	jmp	jle_cont.50683
jle_else.50682:
	addi	%g3, %g0, 1
jle_cont.50683:
	jne	%g3, %g0, jeq_else.50686
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.50688
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
	jmp	jeq_cont.50689
jeq_else.50688:
jeq_cont.50689:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	jmp	jeq_cont.50687
jeq_else.50686:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
jeq_cont.50687:
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.50690
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.50692
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.50694
	addi	%g4, %g0, 0
	jmp	jle_cont.50695
jle_else.50694:
	addi	%g4, %g0, 1
jle_cont.50695:
	jmp	jle_cont.50693
jle_else.50692:
	addi	%g4, %g0, 1
jle_cont.50693:
	jne	%g4, %g0, jeq_else.50696
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
	jmp	jeq_cont.50697
jeq_else.50696:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
jeq_cont.50697:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmov	%f4, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f3, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f0, %f3, %f0
	fadd	%f0, %f4, %f0
	jmp	jeq_cont.50691
jeq_else.50690:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
jeq_cont.50691:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.50698
	fmov	%f1, %f0
	jmp	jeq_cont.50699
jeq_else.50698:
	fneg	%f1, %f0
jeq_cont.50699:
	fsti	%f1, %g12, -8
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.50700
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.50702
	addi	%g3, %g0, 0
	jmp	jle_cont.50703
jle_else.50702:
	addi	%g3, %g0, 1
jle_cont.50703:
	jmp	jle_cont.50701
jle_else.50700:
	addi	%g3, %g0, 1
jle_cont.50701:
	jne	%g3, %g0, jeq_else.50704
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.50706
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
	jmp	jeq_cont.50707
jeq_else.50706:
jeq_cont.50707:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	jmp	jeq_cont.50705
jeq_else.50704:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
jeq_cont.50705:
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.50708
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.50710
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.50712
	addi	%g4, %g0, 0
	jmp	jle_cont.50713
jle_else.50712:
	addi	%g4, %g0, 1
jle_cont.50713:
	jmp	jle_cont.50711
jle_else.50710:
	addi	%g4, %g0, 1
jle_cont.50711:
	jne	%g4, %g0, jeq_else.50714
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
	jmp	jeq_cont.50715
jeq_else.50714:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
jeq_cont.50715:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmov	%f4, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f3, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f0, %f3, %f0
	fadd	%f0, %f4, %f0
	jmp	jeq_cont.50709
jeq_else.50708:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
jeq_cont.50709:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.50716
	fmov	%f4, %f0
	jmp	jeq_cont.50717
jeq_else.50716:
	fneg	%f4, %f0
jeq_cont.50717:
	addi	%g3, %g0, 2
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	mov	%g10, %g3
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.50718
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.50720
	addi	%g3, %g0, 0
	jmp	jle_cont.50721
jle_else.50720:
	addi	%g3, %g0, 1
jle_cont.50721:
	jmp	jle_cont.50719
jle_else.50718:
	addi	%g3, %g0, 1
jle_cont.50719:
	jne	%g3, %g0, jeq_else.50722
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.50724
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
	jmp	jeq_cont.50725
jeq_else.50724:
jeq_cont.50725:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	jmp	jeq_cont.50723
jeq_else.50722:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
jeq_cont.50723:
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.50726
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.50728
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.50730
	addi	%g4, %g0, 0
	jmp	jle_cont.50731
jle_else.50730:
	addi	%g4, %g0, 1
jle_cont.50731:
	jmp	jle_cont.50729
jle_else.50728:
	addi	%g4, %g0, 1
jle_cont.50729:
	jne	%g4, %g0, jeq_else.50732
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
	jmp	jeq_cont.50733
jeq_else.50732:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
jeq_cont.50733:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmov	%f5, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f3, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f0, %f3, %f0
	fadd	%f0, %f5, %f0
	jmp	jeq_cont.50727
jeq_else.50726:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
jeq_cont.50727:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.50734
	fmov	%f1, %f0
	jmp	jeq_cont.50735
jeq_else.50734:
	fneg	%f1, %f0
jeq_cont.50735:
	fsti	%f1, %g10, 0
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.50736
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.50738
	addi	%g3, %g0, 0
	jmp	jle_cont.50739
jle_else.50738:
	addi	%g3, %g0, 1
jle_cont.50739:
	jmp	jle_cont.50737
jle_else.50736:
	addi	%g3, %g0, 1
jle_cont.50737:
	jne	%g3, %g0, jeq_else.50740
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.50742
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
	jmp	jeq_cont.50743
jeq_else.50742:
jeq_cont.50743:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	jmp	jeq_cont.50741
jeq_else.50740:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
jeq_cont.50741:
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.50744
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.50746
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.50748
	addi	%g4, %g0, 0
	jmp	jle_cont.50749
jle_else.50748:
	addi	%g4, %g0, 1
jle_cont.50749:
	jmp	jle_cont.50747
jle_else.50746:
	addi	%g4, %g0, 1
jle_cont.50747:
	jne	%g4, %g0, jeq_else.50750
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
	jmp	jeq_cont.50751
jeq_else.50750:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
jeq_cont.50751:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmov	%f5, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f3, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f0, %f3, %f0
	fadd	%f0, %f5, %f0
	jmp	jeq_cont.50745
jeq_else.50744:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
jeq_cont.50745:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.50752
	fmov	%f1, %f0
	jmp	jeq_cont.50753
jeq_else.50752:
	fneg	%f1, %f0
jeq_cont.50753:
	fsti	%f1, %g10, -4
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	mov	%g9, %g3
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.50754
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.50756
	addi	%g3, %g0, 0
	jmp	jle_cont.50757
jle_else.50756:
	addi	%g3, %g0, 1
jle_cont.50757:
	jmp	jle_cont.50755
jle_else.50754:
	addi	%g3, %g0, 1
jle_cont.50755:
	jne	%g3, %g0, jeq_else.50758
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.50760
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
	jmp	jeq_cont.50761
jeq_else.50760:
jeq_cont.50761:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	jmp	jeq_cont.50759
jeq_else.50758:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
jeq_cont.50759:
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.50762
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.50764
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.50766
	addi	%g4, %g0, 0
	jmp	jle_cont.50767
jle_else.50766:
	addi	%g4, %g0, 1
jle_cont.50767:
	jmp	jle_cont.50765
jle_else.50764:
	addi	%g4, %g0, 1
jle_cont.50765:
	jne	%g4, %g0, jeq_else.50768
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
	jmp	jeq_cont.50769
jeq_else.50768:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
jeq_cont.50769:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmov	%f5, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f3, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f0, %f3, %f0
	fadd	%f0, %f5, %f0
	jmp	jeq_cont.50763
jeq_else.50762:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
jeq_cont.50763:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.50770
	fmov	%f1, %f0
	jmp	jeq_cont.50771
jeq_else.50770:
	fneg	%f1, %f0
jeq_cont.50771:
	fsti	%f1, %g9, 0
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.50772
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.50774
	addi	%g3, %g0, 0
	jmp	jle_cont.50775
jle_else.50774:
	addi	%g3, %g0, 1
jle_cont.50775:
	jmp	jle_cont.50773
jle_else.50772:
	addi	%g3, %g0, 1
jle_cont.50773:
	jne	%g3, %g0, jeq_else.50776
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.50778
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
	jmp	jeq_cont.50779
jeq_else.50778:
jeq_cont.50779:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	jmp	jeq_cont.50777
jeq_else.50776:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
jeq_cont.50777:
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.50780
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.50782
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.50784
	addi	%g4, %g0, 0
	jmp	jle_cont.50785
jle_else.50784:
	addi	%g4, %g0, 1
jle_cont.50785:
	jmp	jle_cont.50783
jle_else.50782:
	addi	%g4, %g0, 1
jle_cont.50783:
	jne	%g4, %g0, jeq_else.50786
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
	jmp	jeq_cont.50787
jeq_else.50786:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
jeq_cont.50787:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmov	%f5, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f3, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f0, %f3, %f0
	fadd	%f0, %f5, %f0
	jmp	jeq_cont.50781
jeq_else.50780:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
jeq_cont.50781:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.50788
	fmov	%f1, %f0
	jmp	jeq_cont.50789
jeq_else.50788:
	fneg	%f1, %f0
jeq_cont.50789:
	fsti	%f1, %g9, -4
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.50790
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.50792
	addi	%g3, %g0, 0
	jmp	jle_cont.50793
jle_else.50792:
	addi	%g3, %g0, 1
jle_cont.50793:
	jmp	jle_cont.50791
jle_else.50790:
	addi	%g3, %g0, 1
jle_cont.50791:
	jne	%g3, %g0, jeq_else.50794
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.50796
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
	jmp	jeq_cont.50797
jeq_else.50796:
jeq_cont.50797:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	jmp	jeq_cont.50795
jeq_else.50794:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
jeq_cont.50795:
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.50798
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.50800
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.50802
	addi	%g4, %g0, 0
	jmp	jle_cont.50803
jle_else.50802:
	addi	%g4, %g0, 1
jle_cont.50803:
	jmp	jle_cont.50801
jle_else.50800:
	addi	%g4, %g0, 1
jle_cont.50801:
	jne	%g4, %g0, jeq_else.50804
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
	jmp	jeq_cont.50805
jeq_else.50804:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
jeq_cont.50805:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmov	%f5, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f3, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f0, %f3, %f0
	fadd	%f0, %f5, %f0
	jmp	jeq_cont.50799
jeq_else.50798:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
jeq_cont.50799:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.50806
	fmov	%f1, %f0
	jmp	jeq_cont.50807
jeq_else.50806:
	fneg	%f1, %f0
jeq_cont.50807:
	fsti	%f1, %g9, -8
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	mov	%g7, %g3
	jne	%g13, %g0, jeq_else.50808
	jmp	jeq_cont.50809
jeq_else.50808:
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.50810
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.50812
	addi	%g3, %g0, 0
	jmp	jle_cont.50813
jle_else.50812:
	addi	%g3, %g0, 1
jle_cont.50813:
	jmp	jle_cont.50811
jle_else.50810:
	addi	%g3, %g0, 1
jle_cont.50811:
	jne	%g3, %g0, jeq_else.50814
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.50816
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
	jmp	jeq_cont.50817
jeq_else.50816:
jeq_cont.50817:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	jmp	jeq_cont.50815
jeq_else.50814:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
jeq_cont.50815:
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.50818
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.50820
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.50822
	addi	%g4, %g0, 0
	jmp	jle_cont.50823
jle_else.50822:
	addi	%g4, %g0, 1
jle_cont.50823:
	jmp	jle_cont.50821
jle_else.50820:
	addi	%g4, %g0, 1
jle_cont.50821:
	jne	%g4, %g0, jeq_else.50824
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
	jmp	jeq_cont.50825
jeq_else.50824:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
jeq_cont.50825:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmov	%f5, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f3, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f0, %f3, %f0
	fadd	%f0, %f5, %f0
	jmp	jeq_cont.50819
jeq_else.50818:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
jeq_cont.50819:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.50826
	fmov	%f1, %f0
	jmp	jeq_cont.50827
jeq_else.50826:
	fneg	%f1, %f0
jeq_cont.50827:
	setL %g3, l.42859
	fldi	%f3, %g3, 0
	fmul	%f0, %f1, %f3
	fsti	%f0, %g7, 0
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.50828
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.50830
	addi	%g3, %g0, 0
	jmp	jle_cont.50831
jle_else.50830:
	addi	%g3, %g0, 1
jle_cont.50831:
	jmp	jle_cont.50829
jle_else.50828:
	addi	%g3, %g0, 1
jle_cont.50829:
	jne	%g3, %g0, jeq_else.50832
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.50834
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
	jmp	jeq_cont.50835
jeq_else.50834:
jeq_cont.50835:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	jmp	jeq_cont.50833
jeq_else.50832:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
jeq_cont.50833:
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.50836
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.50838
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.50840
	addi	%g4, %g0, 0
	jmp	jle_cont.50841
jle_else.50840:
	addi	%g4, %g0, 1
jle_cont.50841:
	jmp	jle_cont.50839
jle_else.50838:
	addi	%g4, %g0, 1
jle_cont.50839:
	jne	%g4, %g0, jeq_else.50842
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
	jmp	jeq_cont.50843
jeq_else.50842:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
jeq_cont.50843:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmov	%f6, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f5, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f0, %f5, %f0
	fadd	%f0, %f6, %f0
	jmp	jeq_cont.50837
jeq_else.50836:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
jeq_cont.50837:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.50844
	fmov	%f1, %f0
	jmp	jeq_cont.50845
jeq_else.50844:
	fneg	%f1, %f0
jeq_cont.50845:
	fmul	%f0, %f1, %f3
	fsti	%f0, %g7, -4
	addi	%g3, %g0, 0
	sti	%g3, %g31, 12
	addi	%g3, %g0, 0
	sti	%g3, %g31, 16
	addi	%g3, %g0, 1
	sti	%g3, %g31, 20
	addi	%g3, %g0, 0
	sti	%g3, %g31, 24
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.50846
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.50848
	addi	%g3, %g0, 0
	jmp	jle_cont.50849
jle_else.50848:
	addi	%g3, %g0, 1
jle_cont.50849:
	jmp	jle_cont.50847
jle_else.50846:
	addi	%g3, %g0, 1
jle_cont.50847:
	jne	%g3, %g0, jeq_else.50850
	ldi	%g3, %g31, 24
	jne	%g3, %g0, jeq_else.50852
	addi	%g3, %g0, 1
	sti	%g3, %g31, 24
	jmp	jeq_cont.50853
jeq_else.50852:
jeq_cont.50853:
	ldi	%g3, %g31, 12
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 12
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	jmp	jeq_cont.50851
jeq_else.50850:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
jeq_cont.50851:
	addi	%g4, %g0, 46
	jne	%g3, %g4, jeq_else.50854
	input	%g3
	addi	%g4, %g0, 48
	jlt	%g3, %g4, jle_else.50856
	addi	%g4, %g0, 57
	jlt	%g4, %g3, jle_else.50858
	addi	%g4, %g0, 0
	jmp	jle_cont.50859
jle_else.50858:
	addi	%g4, %g0, 1
jle_cont.50859:
	jmp	jle_cont.50857
jle_else.50856:
	addi	%g4, %g0, 1
jle_cont.50857:
	jne	%g4, %g0, jeq_else.50860
	ldi	%g4, %g31, 16
	slli	%g5, %g4, 3
	slli	%g4, %g4, 1
	add	%g4, %g5, %g4
	subi	%g3, %g3, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 16
	ldi	%g3, %g31, 20
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g3, %g4, %g3
	sti	%g3, %g31, 20
	addi	%g4, %g0, 1
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
	jmp	jeq_cont.50861
jeq_else.50860:
	addi	%g4, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	addi	%g1, %g1, 4
jeq_cont.50861:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmov	%f6, %f0
	ldi	%g3, %g31, 16
	call	min_caml_float_of_int
	fmov	%f5, %f0
	ldi	%g3, %g31, 20
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f0, %f5, %f0
	fadd	%f0, %f6, %f0
	jmp	jeq_cont.50855
jeq_else.50854:
	ldi	%g3, %g31, 12
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
jeq_cont.50855:
	ldi	%g3, %g31, 24
	jne	%g3, %g28, jeq_else.50862
	fmov	%f1, %f0
	jmp	jeq_cont.50863
jeq_else.50862:
	fneg	%f1, %f0
jeq_cont.50863:
	fmul	%f0, %f1, %f3
	fsti	%f0, %g7, -8
jeq_cont.50809:
	addi	%g5, %g0, 2
	jne	%g11, %g5, jeq_else.50864
	addi	%g5, %g0, 1
	jmp	jeq_cont.50865
jeq_else.50864:
	fjlt	%f4, %f16, fjge_else.50866
	addi	%g5, %g0, 0
	jmp	fjge_cont.50867
fjge_else.50866:
	addi	%g5, %g0, 1
fjge_cont.50867:
jeq_cont.50865:
	addi	%g3, %g0, 4
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	mov	%g4, %g3
	mov	%g3, %g2
	addi	%g2, %g2, 44
	sti	%g4, %g3, -40
	sti	%g7, %g3, -36
	sti	%g9, %g3, -32
	sti	%g10, %g3, -28
	sti	%g5, %g3, -24
	sti	%g12, %g3, -20
	sti	%g8, %g3, -16
	sti	%g13, %g3, -12
	sti	%g15, %g3, -8
	sti	%g11, %g3, -4
	sti	%g14, %g3, 0
	slli	%g4, %g16, 2
	add	%g4, %g31, %g4
	sti	%g3, %g4, 272
	addi	%g3, %g0, 3
	jne	%g11, %g3, jeq_else.50868
	fldi	%f1, %g8, 0
	fjeq	%f1, %f16, fjne_else.50870
	fjeq	%f1, %f16, fjne_else.50872
	fjlt	%f16, %f1, fjge_else.50874
	setL %g3, l.43888
	fldi	%f0, %g3, 0
	jmp	fjge_cont.50875
fjge_else.50874:
	setL %g3, l.42861
	fldi	%f0, %g3, 0
fjge_cont.50875:
	jmp	fjne_cont.50873
fjne_else.50872:
	fmov	%f0, %f16
fjne_cont.50873:
	fmul	%f1, %f1, %f1
	fdiv	%f0, %f0, %f1
	jmp	fjne_cont.50871
fjne_else.50870:
	fmov	%f0, %f16
fjne_cont.50871:
	fsti	%f0, %g8, 0
	fldi	%f1, %g8, -4
	fjeq	%f1, %f16, fjne_else.50876
	fjeq	%f1, %f16, fjne_else.50878
	fjlt	%f16, %f1, fjge_else.50880
	setL %g3, l.43888
	fldi	%f0, %g3, 0
	jmp	fjge_cont.50881
fjge_else.50880:
	setL %g3, l.42861
	fldi	%f0, %g3, 0
fjge_cont.50881:
	jmp	fjne_cont.50879
fjne_else.50878:
	fmov	%f0, %f16
fjne_cont.50879:
	fmul	%f1, %f1, %f1
	fdiv	%f0, %f0, %f1
	jmp	fjne_cont.50877
fjne_else.50876:
	fmov	%f0, %f16
fjne_cont.50877:
	fsti	%f0, %g8, -4
	fldi	%f1, %g8, -8
	fjeq	%f1, %f16, fjne_else.50882
	fjeq	%f1, %f16, fjne_else.50884
	fjlt	%f16, %f1, fjge_else.50886
	setL %g3, l.43888
	fldi	%f0, %g3, 0
	jmp	fjge_cont.50887
fjge_else.50886:
	setL %g3, l.42861
	fldi	%f0, %g3, 0
fjge_cont.50887:
	jmp	fjne_cont.50885
fjne_else.50884:
	fmov	%f0, %f16
fjne_cont.50885:
	fmul	%f1, %f1, %f1
	fdiv	%f0, %f0, %f1
	jmp	fjne_cont.50883
fjne_else.50882:
	fmov	%f0, %f16
fjne_cont.50883:
	fsti	%f0, %g8, -8
	jmp	jeq_cont.50869
jeq_else.50868:
	addi	%g3, %g0, 2
	jne	%g11, %g3, jeq_else.50888
	fldi	%f1, %g8, 0
	fmul	%f2, %f1, %f1
	fldi	%f0, %g8, -4
	fmul	%f0, %f0, %f0
	fadd	%f2, %f2, %f0
	fldi	%f0, %g8, -8
	fmul	%f0, %f0, %f0
	fadd	%f0, %f2, %f0
	fsqrt	%f2, %f0
	fjeq	%f2, %f16, fjne_else.50890
	fjlt	%f4, %f16, fjge_else.50892
	fdiv	%f0, %f20, %f2
	jmp	fjge_cont.50893
fjge_else.50892:
	fdiv	%f0, %f17, %f2
fjge_cont.50893:
	jmp	fjne_cont.50891
fjne_else.50890:
	setL %g3, l.42861
	fldi	%f0, %g3, 0
fjne_cont.50891:
	fmul	%f1, %f1, %f0
	fsti	%f1, %g8, 0
	fldi	%f1, %g8, -4
	fmul	%f1, %f1, %f0
	fsti	%f1, %g8, -4
	fldi	%f1, %g8, -8
	fmul	%f0, %f1, %f0
	fsti	%f0, %g8, -8
	jmp	jeq_cont.50889
jeq_else.50888:
jeq_cont.50889:
jeq_cont.50869:
	jne	%g13, %g0, jeq_else.50894
	jmp	jeq_cont.50895
jeq_else.50894:
	fldi	%f3, %g7, 0
	fsub	%f2, %f22, %f3
	setL %g3, l.42599
	fldi	%f4, %g3, 0
	setL %g3, l.42601
	fldi	%f14, %g3, 0
	fjlt	%f2, %f16, fjge_else.50896
	fmov	%f1, %f2
	jmp	fjge_cont.50897
fjge_else.50896:
	fneg	%f1, %f2
fjge_cont.50897:
	fjlt	%f29, %f1, fjge_else.50898
	fjlt	%f1, %f16, fjge_else.50900
	fmov	%f0, %f1
	jmp	fjge_cont.50901
fjge_else.50900:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50902
	fjlt	%f1, %f16, fjge_else.50904
	fmov	%f0, %f1
	jmp	fjge_cont.50905
fjge_else.50904:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50906
	fjlt	%f1, %f16, fjge_else.50908
	fmov	%f0, %f1
	jmp	fjge_cont.50909
fjge_else.50908:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50909:
	jmp	fjge_cont.50907
fjge_else.50906:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50907:
fjge_cont.50905:
	jmp	fjge_cont.50903
fjge_else.50902:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50910
	fjlt	%f1, %f16, fjge_else.50912
	fmov	%f0, %f1
	jmp	fjge_cont.50913
fjge_else.50912:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50913:
	jmp	fjge_cont.50911
fjge_else.50910:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50911:
fjge_cont.50903:
fjge_cont.50901:
	jmp	fjge_cont.50899
fjge_else.50898:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50914
	fjlt	%f1, %f16, fjge_else.50916
	fmov	%f0, %f1
	jmp	fjge_cont.50917
fjge_else.50916:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50918
	fjlt	%f1, %f16, fjge_else.50920
	fmov	%f0, %f1
	jmp	fjge_cont.50921
fjge_else.50920:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50921:
	jmp	fjge_cont.50919
fjge_else.50918:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50919:
fjge_cont.50917:
	jmp	fjge_cont.50915
fjge_else.50914:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50922
	fjlt	%f1, %f16, fjge_else.50924
	fmov	%f0, %f1
	jmp	fjge_cont.50925
fjge_else.50924:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50925:
	jmp	fjge_cont.50923
fjge_else.50922:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.50923:
fjge_cont.50915:
fjge_cont.50899:
	fjlt	%f4, %f0, fjge_else.50926
	fjlt	%f16, %f2, fjge_else.50928
	addi	%g3, %g0, 0
	jmp	fjge_cont.50929
fjge_else.50928:
	addi	%g3, %g0, 1
fjge_cont.50929:
	jmp	fjge_cont.50927
fjge_else.50926:
	fjlt	%f16, %f2, fjge_else.50930
	addi	%g3, %g0, 1
	jmp	fjge_cont.50931
fjge_else.50930:
	addi	%g3, %g0, 0
fjge_cont.50931:
fjge_cont.50927:
	fjlt	%f4, %f0, fjge_else.50932
	fmov	%f1, %f0
	jmp	fjge_cont.50933
fjge_else.50932:
	fsub	%f1, %f29, %f0
fjge_cont.50933:
	fjlt	%f22, %f1, fjge_else.50934
	fmov	%f0, %f1
	jmp	fjge_cont.50935
fjge_else.50934:
	fsub	%f0, %f4, %f1
fjge_cont.50935:
	fmul	%f1, %f0, %f21
	fmul	%f0, %f1, %f1
	fdiv	%f2, %f0, %f25
	fsub	%f2, %f26, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f24, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f23, %f2
	fdiv	%f0, %f0, %f2
	fsub	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	fmul	%f1, %f14, %f0
	fmul	%f0, %f0, %f0
	fadd	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	jne	%g3, %g0, jeq_else.50936
	fneg	%f15, %f0
	jmp	jeq_cont.50937
jeq_else.50936:
	fmov	%f15, %f0
jeq_cont.50937:
	fjlt	%f3, %f16, fjge_else.50938
	fmov	%f1, %f3
	jmp	fjge_cont.50939
fjge_else.50938:
	fneg	%f1, %f3
fjge_cont.50939:
	fsti	%f15, %g1, 0
	fjlt	%f29, %f1, fjge_else.50940
	fjlt	%f1, %f16, fjge_else.50942
	fmov	%f0, %f1
	jmp	fjge_cont.50943
fjge_else.50942:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50944
	fjlt	%f1, %f16, fjge_else.50946
	fmov	%f0, %f1
	jmp	fjge_cont.50947
fjge_else.50946:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50948
	fjlt	%f1, %f16, fjge_else.50950
	fmov	%f0, %f1
	jmp	fjge_cont.50951
fjge_else.50950:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.50951:
	jmp	fjge_cont.50949
fjge_else.50948:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.50949:
fjge_cont.50947:
	jmp	fjge_cont.50945
fjge_else.50944:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50952
	fjlt	%f1, %f16, fjge_else.50954
	fmov	%f0, %f1
	jmp	fjge_cont.50955
fjge_else.50954:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.50955:
	jmp	fjge_cont.50953
fjge_else.50952:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.50953:
fjge_cont.50945:
fjge_cont.50943:
	jmp	fjge_cont.50941
fjge_else.50940:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50956
	fjlt	%f1, %f16, fjge_else.50958
	fmov	%f0, %f1
	jmp	fjge_cont.50959
fjge_else.50958:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50960
	fjlt	%f1, %f16, fjge_else.50962
	fmov	%f0, %f1
	jmp	fjge_cont.50963
fjge_else.50962:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.50963:
	jmp	fjge_cont.50961
fjge_else.50960:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.50961:
fjge_cont.50959:
	jmp	fjge_cont.50957
fjge_else.50956:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50964
	fjlt	%f1, %f16, fjge_else.50966
	fmov	%f0, %f1
	jmp	fjge_cont.50967
fjge_else.50966:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.50967:
	jmp	fjge_cont.50965
fjge_else.50964:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.50965:
fjge_cont.50957:
fjge_cont.50941:
	fjlt	%f4, %f0, fjge_else.50968
	fjlt	%f16, %f3, fjge_else.50970
	addi	%g3, %g0, 0
	jmp	fjge_cont.50971
fjge_else.50970:
	addi	%g3, %g0, 1
fjge_cont.50971:
	jmp	fjge_cont.50969
fjge_else.50968:
	fjlt	%f16, %f3, fjge_else.50972
	addi	%g3, %g0, 1
	jmp	fjge_cont.50973
fjge_else.50972:
	addi	%g3, %g0, 0
fjge_cont.50973:
fjge_cont.50969:
	fjlt	%f4, %f0, fjge_else.50974
	fmov	%f1, %f0
	jmp	fjge_cont.50975
fjge_else.50974:
	fsub	%f1, %f29, %f0
fjge_cont.50975:
	fjlt	%f22, %f1, fjge_else.50976
	fmov	%f0, %f1
	jmp	fjge_cont.50977
fjge_else.50976:
	fsub	%f0, %f4, %f1
fjge_cont.50977:
	fmul	%f1, %f0, %f21
	fmul	%f0, %f1, %f1
	fdiv	%f2, %f0, %f25
	fsub	%f2, %f26, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f24, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f23, %f2
	fdiv	%f0, %f0, %f2
	fsub	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	fmul	%f1, %f14, %f0
	fmul	%f0, %f0, %f0
	fadd	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	jne	%g3, %g0, jeq_else.50978
	fneg	%f7, %f0
	jmp	jeq_cont.50979
jeq_else.50978:
	fmov	%f7, %f0
jeq_cont.50979:
	fldi	%f3, %g7, -4
	fsub	%f2, %f22, %f3
	fjlt	%f2, %f16, fjge_else.50980
	fmov	%f1, %f2
	jmp	fjge_cont.50981
fjge_else.50980:
	fneg	%f1, %f2
fjge_cont.50981:
	fjlt	%f29, %f1, fjge_else.50982
	fjlt	%f1, %f16, fjge_else.50984
	fmov	%f0, %f1
	jmp	fjge_cont.50985
fjge_else.50984:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50986
	fjlt	%f1, %f16, fjge_else.50988
	fmov	%f0, %f1
	jmp	fjge_cont.50989
fjge_else.50988:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50990
	fjlt	%f1, %f16, fjge_else.50992
	fmov	%f0, %f1
	jmp	fjge_cont.50993
fjge_else.50992:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.50993:
	jmp	fjge_cont.50991
fjge_else.50990:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.50991:
fjge_cont.50989:
	jmp	fjge_cont.50987
fjge_else.50986:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50994
	fjlt	%f1, %f16, fjge_else.50996
	fmov	%f0, %f1
	jmp	fjge_cont.50997
fjge_else.50996:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.50997:
	jmp	fjge_cont.50995
fjge_else.50994:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.50995:
fjge_cont.50987:
fjge_cont.50985:
	jmp	fjge_cont.50983
fjge_else.50982:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.50998
	fjlt	%f1, %f16, fjge_else.51000
	fmov	%f0, %f1
	jmp	fjge_cont.51001
fjge_else.51000:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.51002
	fjlt	%f1, %f16, fjge_else.51004
	fmov	%f0, %f1
	jmp	fjge_cont.51005
fjge_else.51004:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51005:
	jmp	fjge_cont.51003
fjge_else.51002:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51003:
fjge_cont.51001:
	jmp	fjge_cont.50999
fjge_else.50998:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.51006
	fjlt	%f1, %f16, fjge_else.51008
	fmov	%f0, %f1
	jmp	fjge_cont.51009
fjge_else.51008:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51009:
	jmp	fjge_cont.51007
fjge_else.51006:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51007:
fjge_cont.50999:
fjge_cont.50983:
	fjlt	%f4, %f0, fjge_else.51010
	fjlt	%f16, %f2, fjge_else.51012
	addi	%g3, %g0, 0
	jmp	fjge_cont.51013
fjge_else.51012:
	addi	%g3, %g0, 1
fjge_cont.51013:
	jmp	fjge_cont.51011
fjge_else.51010:
	fjlt	%f16, %f2, fjge_else.51014
	addi	%g3, %g0, 1
	jmp	fjge_cont.51015
fjge_else.51014:
	addi	%g3, %g0, 0
fjge_cont.51015:
fjge_cont.51011:
	fjlt	%f4, %f0, fjge_else.51016
	fmov	%f1, %f0
	jmp	fjge_cont.51017
fjge_else.51016:
	fsub	%f1, %f29, %f0
fjge_cont.51017:
	fjlt	%f22, %f1, fjge_else.51018
	fmov	%f0, %f1
	jmp	fjge_cont.51019
fjge_else.51018:
	fsub	%f0, %f4, %f1
fjge_cont.51019:
	fmul	%f1, %f0, %f21
	fmul	%f0, %f1, %f1
	fdiv	%f2, %f0, %f25
	fsub	%f2, %f26, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f24, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f23, %f2
	fdiv	%f0, %f0, %f2
	fsub	%f0, %f17, %f0
	fdiv	%f1, %f1, %f0
	fmul	%f0, %f14, %f1
	fmul	%f1, %f1, %f1
	fadd	%f1, %f17, %f1
	fdiv	%f0, %f0, %f1
	jne	%g3, %g0, jeq_else.51020
	fneg	%f13, %f0
	jmp	jeq_cont.51021
jeq_else.51020:
	fmov	%f13, %f0
jeq_cont.51021:
	fjlt	%f3, %f16, fjge_else.51022
	fmov	%f1, %f3
	jmp	fjge_cont.51023
fjge_else.51022:
	fneg	%f1, %f3
fjge_cont.51023:
	fjlt	%f29, %f1, fjge_else.51024
	fjlt	%f1, %f16, fjge_else.51026
	fmov	%f0, %f1
	jmp	fjge_cont.51027
fjge_else.51026:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.51028
	fjlt	%f1, %f16, fjge_else.51030
	fmov	%f0, %f1
	jmp	fjge_cont.51031
fjge_else.51030:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.51032
	fjlt	%f1, %f16, fjge_else.51034
	fmov	%f0, %f1
	jmp	fjge_cont.51035
fjge_else.51034:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51035:
	jmp	fjge_cont.51033
fjge_else.51032:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51033:
fjge_cont.51031:
	jmp	fjge_cont.51029
fjge_else.51028:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.51036
	fjlt	%f1, %f16, fjge_else.51038
	fmov	%f0, %f1
	jmp	fjge_cont.51039
fjge_else.51038:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51039:
	jmp	fjge_cont.51037
fjge_else.51036:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51037:
fjge_cont.51029:
fjge_cont.51027:
	jmp	fjge_cont.51025
fjge_else.51024:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.51040
	fjlt	%f1, %f16, fjge_else.51042
	fmov	%f0, %f1
	jmp	fjge_cont.51043
fjge_else.51042:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.51044
	fjlt	%f1, %f16, fjge_else.51046
	fmov	%f0, %f1
	jmp	fjge_cont.51047
fjge_else.51046:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51047:
	jmp	fjge_cont.51045
fjge_else.51044:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51045:
fjge_cont.51043:
	jmp	fjge_cont.51041
fjge_else.51040:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.51048
	fjlt	%f1, %f16, fjge_else.51050
	fmov	%f0, %f1
	jmp	fjge_cont.51051
fjge_else.51050:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51051:
	jmp	fjge_cont.51049
fjge_else.51048:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51049:
fjge_cont.51041:
fjge_cont.51025:
	fjlt	%f4, %f0, fjge_else.51052
	fjlt	%f16, %f3, fjge_else.51054
	addi	%g3, %g0, 0
	jmp	fjge_cont.51055
fjge_else.51054:
	addi	%g3, %g0, 1
fjge_cont.51055:
	jmp	fjge_cont.51053
fjge_else.51052:
	fjlt	%f16, %f3, fjge_else.51056
	addi	%g3, %g0, 1
	jmp	fjge_cont.51057
fjge_else.51056:
	addi	%g3, %g0, 0
fjge_cont.51057:
fjge_cont.51053:
	fjlt	%f4, %f0, fjge_else.51058
	fmov	%f1, %f0
	jmp	fjge_cont.51059
fjge_else.51058:
	fsub	%f1, %f29, %f0
fjge_cont.51059:
	fjlt	%f22, %f1, fjge_else.51060
	fmov	%f0, %f1
	jmp	fjge_cont.51061
fjge_else.51060:
	fsub	%f0, %f4, %f1
fjge_cont.51061:
	fmul	%f1, %f0, %f21
	fmul	%f0, %f1, %f1
	fdiv	%f2, %f0, %f25
	fsub	%f2, %f26, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f24, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f23, %f2
	fdiv	%f0, %f0, %f2
	fsub	%f0, %f17, %f0
	fdiv	%f1, %f1, %f0
	fmul	%f0, %f14, %f1
	fmul	%f1, %f1, %f1
	fadd	%f1, %f17, %f1
	fdiv	%f0, %f0, %f1
	jne	%g3, %g0, jeq_else.51062
	fneg	%f9, %f0
	jmp	jeq_cont.51063
jeq_else.51062:
	fmov	%f9, %f0
jeq_cont.51063:
	fldi	%f3, %g7, -8
	fsub	%f2, %f22, %f3
	fjlt	%f2, %f16, fjge_else.51064
	fmov	%f1, %f2
	jmp	fjge_cont.51065
fjge_else.51064:
	fneg	%f1, %f2
fjge_cont.51065:
	fjlt	%f29, %f1, fjge_else.51066
	fjlt	%f1, %f16, fjge_else.51068
	fmov	%f0, %f1
	jmp	fjge_cont.51069
fjge_else.51068:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.51070
	fjlt	%f1, %f16, fjge_else.51072
	fmov	%f0, %f1
	jmp	fjge_cont.51073
fjge_else.51072:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.51074
	fjlt	%f1, %f16, fjge_else.51076
	fmov	%f0, %f1
	jmp	fjge_cont.51077
fjge_else.51076:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51077:
	jmp	fjge_cont.51075
fjge_else.51074:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51075:
fjge_cont.51073:
	jmp	fjge_cont.51071
fjge_else.51070:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.51078
	fjlt	%f1, %f16, fjge_else.51080
	fmov	%f0, %f1
	jmp	fjge_cont.51081
fjge_else.51080:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51081:
	jmp	fjge_cont.51079
fjge_else.51078:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51079:
fjge_cont.51071:
fjge_cont.51069:
	jmp	fjge_cont.51067
fjge_else.51066:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.51082
	fjlt	%f1, %f16, fjge_else.51084
	fmov	%f0, %f1
	jmp	fjge_cont.51085
fjge_else.51084:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.51086
	fjlt	%f1, %f16, fjge_else.51088
	fmov	%f0, %f1
	jmp	fjge_cont.51089
fjge_else.51088:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51089:
	jmp	fjge_cont.51087
fjge_else.51086:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51087:
fjge_cont.51085:
	jmp	fjge_cont.51083
fjge_else.51082:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.51090
	fjlt	%f1, %f16, fjge_else.51092
	fmov	%f0, %f1
	jmp	fjge_cont.51093
fjge_else.51092:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51093:
	jmp	fjge_cont.51091
fjge_else.51090:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51091:
fjge_cont.51083:
fjge_cont.51067:
	fjlt	%f4, %f0, fjge_else.51094
	fjlt	%f16, %f2, fjge_else.51096
	addi	%g3, %g0, 0
	jmp	fjge_cont.51097
fjge_else.51096:
	addi	%g3, %g0, 1
fjge_cont.51097:
	jmp	fjge_cont.51095
fjge_else.51094:
	fjlt	%f16, %f2, fjge_else.51098
	addi	%g3, %g0, 1
	jmp	fjge_cont.51099
fjge_else.51098:
	addi	%g3, %g0, 0
fjge_cont.51099:
fjge_cont.51095:
	fjlt	%f4, %f0, fjge_else.51100
	fmov	%f1, %f0
	jmp	fjge_cont.51101
fjge_else.51100:
	fsub	%f1, %f29, %f0
fjge_cont.51101:
	fjlt	%f22, %f1, fjge_else.51102
	fmov	%f0, %f1
	jmp	fjge_cont.51103
fjge_else.51102:
	fsub	%f0, %f4, %f1
fjge_cont.51103:
	fmul	%f1, %f0, %f21
	fmul	%f0, %f1, %f1
	fdiv	%f2, %f0, %f25
	fsub	%f2, %f26, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f24, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f23, %f2
	fdiv	%f0, %f0, %f2
	fsub	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	fmul	%f1, %f14, %f0
	fmul	%f0, %f0, %f0
	fadd	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	jne	%g3, %g0, jeq_else.51104
	fneg	%f2, %f0
	jmp	jeq_cont.51105
jeq_else.51104:
	fmov	%f2, %f0
jeq_cont.51105:
	fjlt	%f3, %f16, fjge_else.51106
	fmov	%f1, %f3
	jmp	fjge_cont.51107
fjge_else.51106:
	fneg	%f1, %f3
fjge_cont.51107:
	fjlt	%f29, %f1, fjge_else.51108
	fjlt	%f1, %f16, fjge_else.51110
	fmov	%f0, %f1
	jmp	fjge_cont.51111
fjge_else.51110:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.51112
	fjlt	%f1, %f16, fjge_else.51114
	fmov	%f0, %f1
	jmp	fjge_cont.51115
fjge_else.51114:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.51116
	fjlt	%f1, %f16, fjge_else.51118
	fmov	%f0, %f1
	jmp	fjge_cont.51119
fjge_else.51118:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51119:
	jmp	fjge_cont.51117
fjge_else.51116:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51117:
fjge_cont.51115:
	jmp	fjge_cont.51113
fjge_else.51112:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.51120
	fjlt	%f1, %f16, fjge_else.51122
	fmov	%f0, %f1
	jmp	fjge_cont.51123
fjge_else.51122:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51123:
	jmp	fjge_cont.51121
fjge_else.51120:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51121:
fjge_cont.51113:
fjge_cont.51111:
	jmp	fjge_cont.51109
fjge_else.51108:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.51124
	fjlt	%f1, %f16, fjge_else.51126
	fmov	%f0, %f1
	jmp	fjge_cont.51127
fjge_else.51126:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.51128
	fjlt	%f1, %f16, fjge_else.51130
	fmov	%f0, %f1
	jmp	fjge_cont.51131
fjge_else.51130:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51131:
	jmp	fjge_cont.51129
fjge_else.51128:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51129:
fjge_cont.51127:
	jmp	fjge_cont.51125
fjge_else.51124:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.51132
	fjlt	%f1, %f16, fjge_else.51134
	fmov	%f0, %f1
	jmp	fjge_cont.51135
fjge_else.51134:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51135:
	jmp	fjge_cont.51133
fjge_else.51132:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.51133:
fjge_cont.51125:
fjge_cont.51109:
	fjlt	%f4, %f0, fjge_else.51136
	fjlt	%f16, %f3, fjge_else.51138
	addi	%g3, %g0, 0
	jmp	fjge_cont.51139
fjge_else.51138:
	addi	%g3, %g0, 1
fjge_cont.51139:
	jmp	fjge_cont.51137
fjge_else.51136:
	fjlt	%f16, %f3, fjge_else.51140
	addi	%g3, %g0, 1
	jmp	fjge_cont.51141
fjge_else.51140:
	addi	%g3, %g0, 0
fjge_cont.51141:
fjge_cont.51137:
	fjlt	%f4, %f0, fjge_else.51142
	fmov	%f1, %f0
	jmp	fjge_cont.51143
fjge_else.51142:
	fsub	%f1, %f29, %f0
fjge_cont.51143:
	fjlt	%f22, %f1, fjge_else.51144
	fmov	%f0, %f1
	jmp	fjge_cont.51145
fjge_else.51144:
	fsub	%f0, %f4, %f1
fjge_cont.51145:
	fmul	%f1, %f0, %f21
	fmul	%f0, %f1, %f1
	fdiv	%f3, %f0, %f25
	fsub	%f3, %f26, %f3
	fdiv	%f3, %f0, %f3
	fsub	%f3, %f24, %f3
	fdiv	%f3, %f0, %f3
	fsub	%f3, %f23, %f3
	fdiv	%f0, %f0, %f3
	fsub	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	fmul	%f1, %f14, %f0
	fmul	%f0, %f0, %f0
	fadd	%f0, %f17, %f0
	fdiv	%f1, %f1, %f0
	jne	%g3, %g0, jeq_else.51146
	fneg	%f0, %f1
	jmp	jeq_cont.51147
jeq_else.51146:
	fmov	%f0, %f1
jeq_cont.51147:
	fmul	%f12, %f13, %f2
	fmul	%f5, %f7, %f9
	fmul	%f3, %f5, %f2
	fldi	%f15, %g1, 0
	fmul	%f1, %f15, %f0
	fsub	%f10, %f3, %f1
	fmul	%f1, %f15, %f9
	fmul	%f4, %f1, %f2
	fmul	%f3, %f7, %f0
	fadd	%f6, %f4, %f3
	fmul	%f11, %f13, %f0
	fmul	%f4, %f5, %f0
	fmul	%f3, %f15, %f2
	fadd	%f8, %f4, %f3
	fmul	%f1, %f1, %f0
	fmul	%f0, %f7, %f2
	fsub	%f5, %f1, %f0
	fneg	%f9, %f9
	fmul	%f7, %f7, %f13
	fmul	%f4, %f15, %f13
	fldi	%f0, %g8, 0
	fldi	%f2, %g8, -4
	fldi	%f3, %g8, -8
	fmul	%f1, %f12, %f12
	fmul	%f13, %f0, %f1
	fmul	%f1, %f11, %f11
	fmul	%f1, %f2, %f1
	fadd	%f13, %f13, %f1
	fmul	%f1, %f9, %f9
	fmul	%f1, %f3, %f1
	fadd	%f1, %f13, %f1
	fsti	%f1, %g8, 0
	fmul	%f1, %f10, %f10
	fmul	%f13, %f0, %f1
	fmul	%f1, %f8, %f8
	fmul	%f1, %f2, %f1
	fadd	%f13, %f13, %f1
	fmul	%f1, %f7, %f7
	fmul	%f1, %f3, %f1
	fadd	%f1, %f13, %f1
	fsti	%f1, %g8, -4
	fmul	%f1, %f6, %f6
	fmul	%f13, %f0, %f1
	fmul	%f1, %f5, %f5
	fmul	%f1, %f2, %f1
	fadd	%f13, %f13, %f1
	fmul	%f1, %f4, %f4
	fmul	%f1, %f3, %f1
	fadd	%f1, %f13, %f1
	fsti	%f1, %g8, -8
	fmul	%f1, %f0, %f10
	fmul	%f13, %f1, %f6
	fmul	%f1, %f2, %f8
	fmul	%f1, %f1, %f5
	fadd	%f13, %f13, %f1
	fmul	%f1, %f3, %f7
	fmul	%f1, %f1, %f4
	fadd	%f1, %f13, %f1
	fmul	%f1, %f14, %f1
	fsti	%f1, %g7, 0
	fmul	%f1, %f0, %f12
	fmul	%f6, %f1, %f6
	fmul	%f0, %f2, %f11
	fmul	%f2, %f0, %f5
	fadd	%f5, %f6, %f2
	fmul	%f3, %f3, %f9
	fmul	%f2, %f3, %f4
	fadd	%f2, %f5, %f2
	fmul	%f2, %f14, %f2
	fsti	%f2, %g7, -4
	fmul	%f1, %f1, %f10
	fmul	%f0, %f0, %f8
	fadd	%f1, %f1, %f0
	fmul	%f0, %f3, %f7
	fadd	%f0, %f1, %f0
	fmul	%f0, %f14, %f0
	fsti	%f0, %g7, -8
jeq_cont.50895:
	addi	%g3, %g0, 1
jeq_cont.50567:
	jne	%g3, %g0, jeq_else.51148
	sti	%g16, %g31, 28
	return
jeq_else.51148:
	addi	%g16, %g16, 1
	jmp	read_object.2755

!==============================
! args = [%g8]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %f15, %dummy]
! ret type = Array(Int)
!================================
read_net_item.2759:
	addi	%g3, %g0, 0
	sti	%g3, %g31, 4
	addi	%g3, %g0, 0
	sti	%g3, %g31, 8
	input	%g4
	addi	%g7, %g0, 48
	jlt	%g4, %g7, jle_else.51150
	addi	%g7, %g0, 57
	jlt	%g7, %g4, jle_else.51152
	addi	%g7, %g0, 0
	jmp	jle_cont.51153
jle_else.51152:
	addi	%g7, %g0, 1
jle_cont.51153:
	jmp	jle_cont.51151
jle_else.51150:
	addi	%g7, %g0, 1
jle_cont.51151:
	jne	%g7, %g0, jeq_else.51154
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.51156
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
	jmp	jeq_cont.51157
jeq_else.51156:
jeq_cont.51157:
	ldi	%g3, %g31, 4
	slli	%g5, %g3, 3
	slli	%g3, %g3, 1
	add	%g5, %g5, %g3
	subi	%g3, %g4, 48
	add	%g3, %g5, %g3
	sti	%g3, %g31, 4
	input	%g5
	addi	%g7, %g0, 48
	jlt	%g5, %g7, jle_else.51158
	addi	%g7, %g0, 57
	jlt	%g7, %g5, jle_else.51160
	addi	%g7, %g0, 0
	jmp	jle_cont.51161
jle_else.51160:
	addi	%g7, %g0, 1
jle_cont.51161:
	jmp	jle_cont.51159
jle_else.51158:
	addi	%g7, %g0, 1
jle_cont.51159:
	jne	%g7, %g0, jeq_else.51162
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.51164
	addi	%g3, %g0, 45
	jne	%g4, %g3, jeq_else.51166
	addi	%g3, %g0, -1
	sti	%g3, %g31, 8
	jmp	jeq_cont.51167
jeq_else.51166:
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
jeq_cont.51167:
	jmp	jeq_cont.51165
jeq_else.51164:
jeq_cont.51165:
	ldi	%g3, %g31, 4
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 4
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
	mov	%g7, %g3
	jmp	jeq_cont.51163
jeq_else.51162:
	ldi	%g7, %g31, 8
	jne	%g7, %g28, jeq_else.51168
	ldi	%g7, %g31, 4
	jmp	jeq_cont.51169
jeq_else.51168:
	ldi	%g7, %g31, 4
	sub	%g7, %g0, %g7
jeq_cont.51169:
jeq_cont.51163:
	jmp	jeq_cont.51155
jeq_else.51154:
	input	%g5
	addi	%g7, %g0, 48
	jlt	%g5, %g7, jle_else.51170
	addi	%g7, %g0, 57
	jlt	%g7, %g5, jle_else.51172
	addi	%g7, %g0, 0
	jmp	jle_cont.51173
jle_else.51172:
	addi	%g7, %g0, 1
jle_cont.51173:
	jmp	jle_cont.51171
jle_else.51170:
	addi	%g7, %g0, 1
jle_cont.51171:
	jne	%g7, %g0, jeq_else.51174
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.51176
	addi	%g3, %g0, 45
	jne	%g4, %g3, jeq_else.51178
	addi	%g3, %g0, -1
	sti	%g3, %g31, 8
	jmp	jeq_cont.51179
jeq_else.51178:
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
jeq_cont.51179:
	jmp	jeq_cont.51177
jeq_else.51176:
jeq_cont.51177:
	ldi	%g3, %g31, 4
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 4
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
	mov	%g7, %g3
	jmp	jeq_cont.51175
jeq_else.51174:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
	mov	%g7, %g3
jeq_cont.51175:
jeq_cont.51155:
	jne	%g7, %g29, jeq_else.51180
	addi	%g3, %g8, 1
	addi	%g4, %g0, -1
	jmp	min_caml_create_array
jeq_else.51180:
	addi	%g9, %g8, 1
	addi	%g3, %g0, 0
	sti	%g3, %g31, 4
	addi	%g3, %g0, 0
	sti	%g3, %g31, 8
	input	%g5
	addi	%g4, %g0, 48
	jlt	%g5, %g4, jle_else.51181
	addi	%g4, %g0, 57
	jlt	%g4, %g5, jle_else.51183
	addi	%g4, %g0, 0
	jmp	jle_cont.51184
jle_else.51183:
	addi	%g4, %g0, 1
jle_cont.51184:
	jmp	jle_cont.51182
jle_else.51181:
	addi	%g4, %g0, 1
jle_cont.51182:
	jne	%g4, %g0, jeq_else.51185
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.51187
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
	jmp	jeq_cont.51188
jeq_else.51187:
jeq_cont.51188:
	ldi	%g3, %g31, 4
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 4
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
	mov	%g4, %g3
	jmp	jeq_cont.51186
jeq_else.51185:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
	mov	%g4, %g3
jeq_cont.51186:
	sti	%g7, %g1, 0
	sti	%g8, %g1, 4
	jne	%g4, %g29, jeq_else.51189
	addi	%g3, %g9, 1
	addi	%g4, %g0, -1
	subi	%g1, %g1, 12
	call	min_caml_create_array
	addi	%g1, %g1, 12
	jmp	jeq_cont.51190
jeq_else.51189:
	addi	%g3, %g9, 1
	sti	%g4, %g1, 8
	sti	%g9, %g1, 12
	mov	%g8, %g3
	subi	%g1, %g1, 20
	call	read_net_item.2759
	addi	%g1, %g1, 20
	ldi	%g9, %g1, 12
	slli	%g5, %g9, 2
	ldi	%g4, %g1, 8
	st	%g4, %g3, %g5
jeq_cont.51190:
	ldi	%g8, %g1, 4
	slli	%g4, %g8, 2
	ldi	%g7, %g1, 0
	st	%g7, %g3, %g4
	return

!==============================
! args = [%g11]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g11, %g10, %f15, %dummy]
! ret type = Array(Array(Int))
!================================
read_or_network.2761:
	addi	%g3, %g0, 0
	sti	%g3, %g31, 4
	addi	%g3, %g0, 0
	sti	%g3, %g31, 8
	input	%g5
	addi	%g3, %g0, 48
	jlt	%g5, %g3, jle_else.51191
	addi	%g3, %g0, 57
	jlt	%g3, %g5, jle_else.51193
	addi	%g3, %g0, 0
	jmp	jle_cont.51194
jle_else.51193:
	addi	%g3, %g0, 1
jle_cont.51194:
	jmp	jle_cont.51192
jle_else.51191:
	addi	%g3, %g0, 1
jle_cont.51192:
	jne	%g3, %g0, jeq_else.51195
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.51197
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
	jmp	jeq_cont.51198
jeq_else.51197:
jeq_cont.51198:
	ldi	%g3, %g31, 4
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 4
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
	jmp	jeq_cont.51196
jeq_else.51195:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
jeq_cont.51196:
	jne	%g3, %g29, jeq_else.51199
	addi	%g3, %g0, 1
	addi	%g4, %g0, -1
	subi	%g1, %g1, 4
	call	min_caml_create_array
	addi	%g1, %g1, 4
	mov	%g5, %g3
	jmp	jeq_cont.51200
jeq_else.51199:
	addi	%g8, %g0, 1
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	read_net_item.2759
	addi	%g1, %g1, 8
	mov	%g5, %g3
	ldi	%g3, %g1, 0
	sti	%g3, %g5, 0
jeq_cont.51200:
	ldi	%g3, %g5, 0
	jne	%g3, %g29, jeq_else.51201
	addi	%g3, %g11, 1
	mov	%g4, %g5
	jmp	min_caml_create_array
jeq_else.51201:
	addi	%g10, %g11, 1
	addi	%g3, %g0, 0
	sti	%g3, %g31, 4
	addi	%g3, %g0, 0
	sti	%g3, %g31, 8
	input	%g7
	addi	%g3, %g0, 48
	jlt	%g7, %g3, jle_else.51202
	addi	%g3, %g0, 57
	jlt	%g3, %g7, jle_else.51204
	addi	%g3, %g0, 0
	jmp	jle_cont.51205
jle_else.51204:
	addi	%g3, %g0, 1
jle_cont.51205:
	jmp	jle_cont.51203
jle_else.51202:
	addi	%g3, %g0, 1
jle_cont.51203:
	sti	%g5, %g1, 4
	jne	%g3, %g0, jeq_else.51206
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.51208
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
	jmp	jeq_cont.51209
jeq_else.51208:
jeq_cont.51209:
	ldi	%g3, %g31, 4
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g7, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 4
	addi	%g6, %g0, 1
	mov	%g5, %g7
	subi	%g1, %g1, 12
	call	read_int_token.2566
	addi	%g1, %g1, 12
	jmp	jeq_cont.51207
jeq_else.51206:
	addi	%g6, %g0, 0
	mov	%g5, %g7
	subi	%g1, %g1, 12
	call	read_int_token.2566
	addi	%g1, %g1, 12
jeq_cont.51207:
	jne	%g3, %g29, jeq_else.51210
	addi	%g3, %g0, 1
	addi	%g4, %g0, -1
	subi	%g1, %g1, 12
	call	min_caml_create_array
	addi	%g1, %g1, 12
	mov	%g4, %g3
	jmp	jeq_cont.51211
jeq_else.51210:
	addi	%g8, %g0, 1
	sti	%g3, %g1, 8
	subi	%g1, %g1, 16
	call	read_net_item.2759
	addi	%g1, %g1, 16
	mov	%g4, %g3
	ldi	%g3, %g1, 8
	sti	%g3, %g4, 0
jeq_cont.51211:
	ldi	%g3, %g4, 0
	sti	%g11, %g1, 12
	jne	%g3, %g29, jeq_else.51212
	addi	%g3, %g10, 1
	subi	%g1, %g1, 20
	call	min_caml_create_array
	addi	%g1, %g1, 20
	jmp	jeq_cont.51213
jeq_else.51212:
	addi	%g3, %g10, 1
	sti	%g4, %g1, 16
	sti	%g10, %g1, 20
	mov	%g11, %g3
	subi	%g1, %g1, 28
	call	read_or_network.2761
	addi	%g1, %g1, 28
	ldi	%g10, %g1, 20
	slli	%g6, %g10, 2
	ldi	%g4, %g1, 16
	st	%g4, %g3, %g6
jeq_cont.51213:
	ldi	%g11, %g1, 12
	slli	%g4, %g11, 2
	ldi	%g5, %g1, 4
	st	%g5, %g3, %g4
	return

!==============================
! args = [%g11]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g12, %g11, %g10, %f15, %dummy]
! ret type = Unit
!================================
read_and_network.2763:
	addi	%g3, %g0, 0
	sti	%g3, %g31, 4
	addi	%g3, %g0, 0
	sti	%g3, %g31, 8
	input	%g4
	addi	%g10, %g0, 48
	jlt	%g4, %g10, jle_else.51214
	addi	%g10, %g0, 57
	jlt	%g10, %g4, jle_else.51216
	addi	%g10, %g0, 0
	jmp	jle_cont.51217
jle_else.51216:
	addi	%g10, %g0, 1
jle_cont.51217:
	jmp	jle_cont.51215
jle_else.51214:
	addi	%g10, %g0, 1
jle_cont.51215:
	jne	%g10, %g0, jeq_else.51218
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.51220
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
	jmp	jeq_cont.51221
jeq_else.51220:
jeq_cont.51221:
	ldi	%g3, %g31, 4
	slli	%g5, %g3, 3
	slli	%g3, %g3, 1
	add	%g5, %g5, %g3
	subi	%g3, %g4, 48
	add	%g3, %g5, %g3
	sti	%g3, %g31, 4
	input	%g5
	addi	%g10, %g0, 48
	jlt	%g5, %g10, jle_else.51222
	addi	%g10, %g0, 57
	jlt	%g10, %g5, jle_else.51224
	addi	%g10, %g0, 0
	jmp	jle_cont.51225
jle_else.51224:
	addi	%g10, %g0, 1
jle_cont.51225:
	jmp	jle_cont.51223
jle_else.51222:
	addi	%g10, %g0, 1
jle_cont.51223:
	jne	%g10, %g0, jeq_else.51226
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.51228
	addi	%g3, %g0, 45
	jne	%g4, %g3, jeq_else.51230
	addi	%g3, %g0, -1
	sti	%g3, %g31, 8
	jmp	jeq_cont.51231
jeq_else.51230:
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
jeq_cont.51231:
	jmp	jeq_cont.51229
jeq_else.51228:
jeq_cont.51229:
	ldi	%g3, %g31, 4
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 4
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
	mov	%g10, %g3
	jmp	jeq_cont.51227
jeq_else.51226:
	ldi	%g10, %g31, 8
	jne	%g10, %g28, jeq_else.51232
	ldi	%g10, %g31, 4
	jmp	jeq_cont.51233
jeq_else.51232:
	ldi	%g10, %g31, 4
	sub	%g10, %g0, %g10
jeq_cont.51233:
jeq_cont.51227:
	jmp	jeq_cont.51219
jeq_else.51218:
	input	%g5
	addi	%g10, %g0, 48
	jlt	%g5, %g10, jle_else.51234
	addi	%g10, %g0, 57
	jlt	%g10, %g5, jle_else.51236
	addi	%g10, %g0, 0
	jmp	jle_cont.51237
jle_else.51236:
	addi	%g10, %g0, 1
jle_cont.51237:
	jmp	jle_cont.51235
jle_else.51234:
	addi	%g10, %g0, 1
jle_cont.51235:
	jne	%g10, %g0, jeq_else.51238
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.51240
	addi	%g3, %g0, 45
	jne	%g4, %g3, jeq_else.51242
	addi	%g3, %g0, -1
	sti	%g3, %g31, 8
	jmp	jeq_cont.51243
jeq_else.51242:
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
jeq_cont.51243:
	jmp	jeq_cont.51241
jeq_else.51240:
jeq_cont.51241:
	ldi	%g3, %g31, 4
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 4
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
	mov	%g10, %g3
	jmp	jeq_cont.51239
jeq_else.51238:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
	mov	%g10, %g3
jeq_cont.51239:
jeq_cont.51219:
	jne	%g10, %g29, jeq_else.51244
	addi	%g3, %g0, 1
	addi	%g4, %g0, -1
	subi	%g1, %g1, 4
	call	min_caml_create_array
	addi	%g1, %g1, 4
	jmp	jeq_cont.51245
jeq_else.51244:
	addi	%g3, %g0, 0
	sti	%g3, %g31, 4
	addi	%g3, %g0, 0
	sti	%g3, %g31, 8
	input	%g5
	addi	%g12, %g0, 48
	jlt	%g5, %g12, jle_else.51246
	addi	%g12, %g0, 57
	jlt	%g12, %g5, jle_else.51248
	addi	%g12, %g0, 0
	jmp	jle_cont.51249
jle_else.51248:
	addi	%g12, %g0, 1
jle_cont.51249:
	jmp	jle_cont.51247
jle_else.51246:
	addi	%g12, %g0, 1
jle_cont.51247:
	jne	%g12, %g0, jeq_else.51250
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.51252
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
	jmp	jeq_cont.51253
jeq_else.51252:
jeq_cont.51253:
	ldi	%g3, %g31, 4
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 4
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
	mov	%g12, %g3
	jmp	jeq_cont.51251
jeq_else.51250:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
	mov	%g12, %g3
jeq_cont.51251:
	jne	%g12, %g29, jeq_else.51254
	addi	%g3, %g0, 2
	addi	%g4, %g0, -1
	subi	%g1, %g1, 4
	call	min_caml_create_array
	addi	%g1, %g1, 4
	jmp	jeq_cont.51255
jeq_else.51254:
	addi	%g8, %g0, 2
	subi	%g1, %g1, 4
	call	read_net_item.2759
	addi	%g1, %g1, 4
	sti	%g12, %g3, -4
jeq_cont.51255:
	sti	%g10, %g3, 0
jeq_cont.51245:
	ldi	%g4, %g3, 0
	jne	%g4, %g29, jeq_else.51256
	return
jeq_else.51256:
	slli	%g4, %g11, 2
	add	%g4, %g31, %g4
	sti	%g3, %g4, 512
	addi	%g11, %g11, 1
	addi	%g3, %g0, 0
	sti	%g3, %g31, 4
	addi	%g3, %g0, 0
	sti	%g3, %g31, 8
	input	%g5
	addi	%g10, %g0, 48
	jlt	%g5, %g10, jle_else.51258
	addi	%g10, %g0, 57
	jlt	%g10, %g5, jle_else.51260
	addi	%g10, %g0, 0
	jmp	jle_cont.51261
jle_else.51260:
	addi	%g10, %g0, 1
jle_cont.51261:
	jmp	jle_cont.51259
jle_else.51258:
	addi	%g10, %g0, 1
jle_cont.51259:
	jne	%g10, %g0, jeq_else.51262
	ldi	%g3, %g31, 8
	jne	%g3, %g0, jeq_else.51264
	addi	%g3, %g0, 1
	sti	%g3, %g31, 8
	jmp	jeq_cont.51265
jeq_else.51264:
jeq_cont.51265:
	ldi	%g3, %g31, 4
	slli	%g4, %g3, 3
	slli	%g3, %g3, 1
	add	%g4, %g4, %g3
	subi	%g3, %g5, 48
	add	%g3, %g4, %g3
	sti	%g3, %g31, 4
	addi	%g6, %g0, 1
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
	mov	%g10, %g3
	jmp	jeq_cont.51263
jeq_else.51262:
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_int_token.2566
	addi	%g1, %g1, 4
	mov	%g10, %g3
jeq_cont.51263:
	jne	%g10, %g29, jeq_else.51266
	addi	%g3, %g0, 1
	addi	%g4, %g0, -1
	subi	%g1, %g1, 4
	call	min_caml_create_array
	addi	%g1, %g1, 4
	jmp	jeq_cont.51267
jeq_else.51266:
	addi	%g8, %g0, 1
	subi	%g1, %g1, 4
	call	read_net_item.2759
	addi	%g1, %g1, 4
	sti	%g10, %g3, 0
jeq_cont.51267:
	ldi	%g4, %g3, 0
	jne	%g4, %g29, jeq_else.51268
	return
jeq_else.51268:
	slli	%g4, %g11, 2
	add	%g4, %g31, %g4
	sti	%g3, %g4, 512
	addi	%g11, %g11, 1
	jmp	read_and_network.2763

!==============================
! args = [%g7, %g6, %g5]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g10, %f8, %f7, %f6, %f5, %f4, %f3, %f21, %f20, %f2, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
iter_setup_dirvec_constants.2860:
	jlt	%g5, %g0, jge_else.51270
	slli	%g3, %g5, 2
	add	%g3, %g31, %g3
	ldi	%g9, %g3, 272
	ldi	%g3, %g9, -4
	jne	%g3, %g28, jeq_else.51271
	addi	%g3, %g0, 6
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	fldi	%f0, %g7, 0
	fjeq	%f0, %f16, fjne_else.51273
	ldi	%g4, %g9, -24
	fjlt	%f0, %f16, fjge_else.51275
	addi	%g10, %g0, 0
	jmp	fjge_cont.51276
fjge_else.51275:
	addi	%g10, %g0, 1
fjge_cont.51276:
	ldi	%g8, %g9, -16
	fldi	%f1, %g8, 0
	jne	%g4, %g10, jeq_else.51277
	fneg	%f0, %f1
	jmp	jeq_cont.51278
jeq_else.51277:
	fmov	%f0, %f1
jeq_cont.51278:
	fsti	%f0, %g3, 0
	fldi	%f0, %g7, 0
	fdiv	%f0, %f17, %f0
	fsti	%f0, %g3, -4
	jmp	fjne_cont.51274
fjne_else.51273:
	fsti	%f16, %g3, -4
fjne_cont.51274:
	fldi	%f0, %g7, -4
	fjeq	%f0, %f16, fjne_else.51279
	ldi	%g4, %g9, -24
	fjlt	%f0, %f16, fjge_else.51281
	addi	%g10, %g0, 0
	jmp	fjge_cont.51282
fjge_else.51281:
	addi	%g10, %g0, 1
fjge_cont.51282:
	ldi	%g8, %g9, -16
	fldi	%f1, %g8, -4
	jne	%g4, %g10, jeq_else.51283
	fneg	%f0, %f1
	jmp	jeq_cont.51284
jeq_else.51283:
	fmov	%f0, %f1
jeq_cont.51284:
	fsti	%f0, %g3, -8
	fldi	%f0, %g7, -4
	fdiv	%f0, %f17, %f0
	fsti	%f0, %g3, -12
	jmp	fjne_cont.51280
fjne_else.51279:
	fsti	%f16, %g3, -12
fjne_cont.51280:
	fldi	%f0, %g7, -8
	fjeq	%f0, %f16, fjne_else.51285
	ldi	%g4, %g9, -24
	fjlt	%f0, %f16, fjge_else.51287
	addi	%g10, %g0, 0
	jmp	fjge_cont.51288
fjge_else.51287:
	addi	%g10, %g0, 1
fjge_cont.51288:
	ldi	%g8, %g9, -16
	fldi	%f1, %g8, -8
	jne	%g4, %g10, jeq_else.51289
	fneg	%f0, %f1
	jmp	jeq_cont.51290
jeq_else.51289:
	fmov	%f0, %f1
jeq_cont.51290:
	fsti	%f0, %g3, -16
	fldi	%f0, %g7, -8
	fdiv	%f0, %f17, %f0
	fsti	%f0, %g3, -20
	jmp	fjne_cont.51286
fjne_else.51285:
	fsti	%f16, %g3, -20
fjne_cont.51286:
	slli	%g4, %g5, 2
	st	%g3, %g6, %g4
	jmp	jeq_cont.51272
jeq_else.51271:
	addi	%g4, %g0, 2
	jne	%g3, %g4, jeq_else.51291
	addi	%g3, %g0, 4
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	fldi	%f1, %g7, 0
	ldi	%g4, %g9, -16
	fldi	%f0, %g4, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g7, -4
	fldi	%f0, %g4, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g7, -8
	fldi	%f0, %g4, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fjlt	%f16, %f0, fjge_else.51293
	fsti	%f16, %g3, 0
	jmp	fjge_cont.51294
fjge_else.51293:
	fdiv	%f1, %f20, %f0
	fsti	%f1, %g3, 0
	fldi	%f1, %g4, 0
	fdiv	%f1, %f1, %f0
	fneg	%f1, %f1
	fsti	%f1, %g3, -4
	fldi	%f1, %g4, -4
	fdiv	%f1, %f1, %f0
	fneg	%f1, %f1
	fsti	%f1, %g3, -8
	fldi	%f1, %g4, -8
	fdiv	%f0, %f1, %f0
	fneg	%f0, %f0
	fsti	%f0, %g3, -12
fjge_cont.51294:
	slli	%g4, %g5, 2
	st	%g3, %g6, %g4
	jmp	jeq_cont.51292
jeq_else.51291:
	addi	%g3, %g0, 5
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	fldi	%f0, %g7, 0
	fldi	%f1, %g7, -4
	fldi	%f2, %g7, -8
	fmul	%f3, %f0, %f0
	ldi	%g4, %g9, -16
	fldi	%f5, %g4, 0
	fmul	%f4, %f3, %f5
	fmul	%f3, %f1, %f1
	fldi	%f6, %g4, -4
	fmul	%f3, %f3, %f6
	fadd	%f7, %f4, %f3
	fmul	%f3, %f2, %f2
	fldi	%f4, %g4, -8
	fmul	%f3, %f3, %f4
	fadd	%f7, %f7, %f3
	ldi	%g8, %g9, -12
	jne	%g8, %g0, jeq_else.51295
	fmov	%f3, %f7
	jmp	jeq_cont.51296
jeq_else.51295:
	fmul	%f8, %f1, %f2
	ldi	%g4, %g9, -36
	fldi	%f3, %g4, 0
	fmul	%f3, %f8, %f3
	fadd	%f8, %f7, %f3
	fmul	%f7, %f2, %f0
	fldi	%f3, %g4, -4
	fmul	%f3, %f7, %f3
	fadd	%f8, %f8, %f3
	fmul	%f7, %f0, %f1
	fldi	%f3, %g4, -8
	fmul	%f3, %f7, %f3
	fadd	%f3, %f8, %f3
jeq_cont.51296:
	fmul	%f0, %f0, %f5
	fneg	%f0, %f0
	fmul	%f1, %f1, %f6
	fneg	%f1, %f1
	fmul	%f2, %f2, %f4
	fneg	%f2, %f2
	fsti	%f3, %g3, 0
	jne	%g8, %g0, jeq_else.51297
	fsti	%f0, %g3, -4
	fsti	%f1, %g3, -8
	fsti	%f2, %g3, -12
	jmp	jeq_cont.51298
jeq_else.51297:
	fldi	%f5, %g7, -8
	ldi	%g4, %g9, -36
	fldi	%f4, %g4, -4
	fmul	%f6, %f5, %f4
	fldi	%f5, %g7, -4
	fldi	%f4, %g4, -8
	fmul	%f4, %f5, %f4
	fadd	%f4, %f6, %f4
	fmul	%f4, %f4, %f21
	fsub	%f0, %f0, %f4
	fsti	%f0, %g3, -4
	fldi	%f4, %g7, -8
	fldi	%f0, %g4, 0
	fmul	%f5, %f4, %f0
	fldi	%f4, %g7, 0
	fldi	%f0, %g4, -8
	fmul	%f0, %f4, %f0
	fadd	%f0, %f5, %f0
	fmul	%f0, %f0, %f21
	fsub	%f0, %f1, %f0
	fsti	%f0, %g3, -8
	fldi	%f1, %g7, -4
	fldi	%f0, %g4, 0
	fmul	%f4, %f1, %f0
	fldi	%f1, %g7, 0
	fldi	%f0, %g4, -4
	fmul	%f0, %f1, %f0
	fadd	%f0, %f4, %f0
	fmul	%f0, %f0, %f21
	fsub	%f0, %f2, %f0
	fsti	%f0, %g3, -12
jeq_cont.51298:
	fjeq	%f3, %f16, fjne_else.51299
	fdiv	%f0, %f17, %f3
	fsti	%f0, %g3, -16
	jmp	fjne_cont.51300
fjne_else.51299:
fjne_cont.51300:
	slli	%g4, %g5, 2
	st	%g3, %g6, %g4
jeq_cont.51292:
jeq_cont.51272:
	subi	%g5, %g5, 1
	jmp	iter_setup_dirvec_constants.2860
jge_else.51270:
	return

!==============================
! args = [%g3, %g4]
! fargs = []
! use_regs = [%g8, %g7, %g6, %g5, %g4, %g3, %g27, %f5, %f4, %f3, %f2, %f17, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
setup_startp_constants.2865:
	jlt	%g4, %g0, jge_else.51302
	slli	%g5, %g4, 2
	add	%g5, %g31, %g5
	ldi	%g5, %g5, 272
	ldi	%g8, %g5, -40
	ldi	%g7, %g5, -4
	fldi	%f1, %g3, 0
	ldi	%g6, %g5, -20
	fldi	%f0, %g6, 0
	fsub	%f0, %f1, %f0
	fsti	%f0, %g8, 0
	fldi	%f1, %g3, -4
	fldi	%f0, %g6, -4
	fsub	%f0, %f1, %f0
	fsti	%f0, %g8, -4
	fldi	%f1, %g3, -8
	fldi	%f0, %g6, -8
	fsub	%f0, %f1, %f0
	fsti	%f0, %g8, -8
	addi	%g6, %g0, 2
	jne	%g7, %g6, jeq_else.51303
	ldi	%g5, %g5, -16
	fldi	%f1, %g8, 0
	fldi	%f3, %g8, -4
	fldi	%f2, %g8, -8
	fldi	%f0, %g5, 0
	fmul	%f1, %f0, %f1
	fldi	%f0, %g5, -4
	fmul	%f0, %f0, %f3
	fadd	%f1, %f1, %f0
	fldi	%f0, %g5, -8
	fmul	%f0, %f0, %f2
	fadd	%f0, %f1, %f0
	fsti	%f0, %g8, -12
	jmp	jeq_cont.51304
jeq_else.51303:
	addi	%g6, %g0, 2
	jlt	%g6, %g7, jle_else.51305
	jmp	jle_cont.51306
jle_else.51305:
	fldi	%f2, %g8, 0
	fldi	%f1, %g8, -4
	fldi	%f0, %g8, -8
	fmul	%f4, %f2, %f2
	ldi	%g6, %g5, -16
	fldi	%f3, %g6, 0
	fmul	%f5, %f4, %f3
	fmul	%f4, %f1, %f1
	fldi	%f3, %g6, -4
	fmul	%f3, %f4, %f3
	fadd	%f5, %f5, %f3
	fmul	%f4, %f0, %f0
	fldi	%f3, %g6, -8
	fmul	%f3, %f4, %f3
	fadd	%f4, %f5, %f3
	ldi	%g6, %g5, -12
	jne	%g6, %g0, jeq_else.51307
	fmov	%f3, %f4
	jmp	jeq_cont.51308
jeq_else.51307:
	fmul	%f5, %f1, %f0
	ldi	%g5, %g5, -36
	fldi	%f3, %g5, 0
	fmul	%f3, %f5, %f3
	fadd	%f4, %f4, %f3
	fmul	%f3, %f0, %f2
	fldi	%f0, %g5, -4
	fmul	%f0, %f3, %f0
	fadd	%f4, %f4, %f0
	fmul	%f1, %f2, %f1
	fldi	%f0, %g5, -8
	fmul	%f3, %f1, %f0
	fadd	%f3, %f4, %f3
jeq_cont.51308:
	addi	%g5, %g0, 3
	jne	%g7, %g5, jeq_else.51309
	fsub	%f0, %f3, %f17
	jmp	jeq_cont.51310
jeq_else.51309:
	fmov	%f0, %f3
jeq_cont.51310:
	fsti	%f0, %g8, -12
jle_cont.51306:
jeq_cont.51304:
	subi	%g8, %g4, 1
	jlt	%g8, %g0, jge_else.51311
	slli	%g4, %g8, 2
	add	%g4, %g31, %g4
	ldi	%g4, %g4, 272
	ldi	%g7, %g4, -40
	ldi	%g6, %g4, -4
	fldi	%f1, %g3, 0
	ldi	%g5, %g4, -20
	fldi	%f0, %g5, 0
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, 0
	fldi	%f1, %g3, -4
	fldi	%f0, %g5, -4
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, -4
	fldi	%f1, %g3, -8
	fldi	%f0, %g5, -8
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, -8
	addi	%g5, %g0, 2
	jne	%g6, %g5, jeq_else.51312
	ldi	%g4, %g4, -16
	fldi	%f1, %g7, 0
	fldi	%f3, %g7, -4
	fldi	%f2, %g7, -8
	fldi	%f0, %g4, 0
	fmul	%f1, %f0, %f1
	fldi	%f0, %g4, -4
	fmul	%f0, %f0, %f3
	fadd	%f1, %f1, %f0
	fldi	%f0, %g4, -8
	fmul	%f0, %f0, %f2
	fadd	%f0, %f1, %f0
	fsti	%f0, %g7, -12
	jmp	jeq_cont.51313
jeq_else.51312:
	addi	%g5, %g0, 2
	jlt	%g5, %g6, jle_else.51314
	jmp	jle_cont.51315
jle_else.51314:
	fldi	%f2, %g7, 0
	fldi	%f1, %g7, -4
	fldi	%f0, %g7, -8
	fmul	%f4, %f2, %f2
	ldi	%g5, %g4, -16
	fldi	%f3, %g5, 0
	fmul	%f5, %f4, %f3
	fmul	%f4, %f1, %f1
	fldi	%f3, %g5, -4
	fmul	%f3, %f4, %f3
	fadd	%f5, %f5, %f3
	fmul	%f4, %f0, %f0
	fldi	%f3, %g5, -8
	fmul	%f3, %f4, %f3
	fadd	%f4, %f5, %f3
	ldi	%g5, %g4, -12
	jne	%g5, %g0, jeq_else.51316
	fmov	%f3, %f4
	jmp	jeq_cont.51317
jeq_else.51316:
	fmul	%f5, %f1, %f0
	ldi	%g4, %g4, -36
	fldi	%f3, %g4, 0
	fmul	%f3, %f5, %f3
	fadd	%f4, %f4, %f3
	fmul	%f3, %f0, %f2
	fldi	%f0, %g4, -4
	fmul	%f0, %f3, %f0
	fadd	%f4, %f4, %f0
	fmul	%f1, %f2, %f1
	fldi	%f0, %g4, -8
	fmul	%f3, %f1, %f0
	fadd	%f3, %f4, %f3
jeq_cont.51317:
	addi	%g4, %g0, 3
	jne	%g6, %g4, jeq_else.51318
	fsub	%f0, %f3, %f17
	jmp	jeq_cont.51319
jeq_else.51318:
	fmov	%f0, %f3
jeq_cont.51319:
	fsti	%f0, %g7, -12
jle_cont.51315:
jeq_cont.51313:
	subi	%g4, %g8, 1
	jmp	setup_startp_constants.2865
jge_else.51311:
	return
jge_else.51302:
	return

!==============================
! args = [%g5, %g4]
! fargs = [%f5, %f4, %f3]
! use_regs = [%g7, %g6, %g5, %g4, %g3, %g27, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f17, %f16, %f15, %f1, %f0]
! ret type = Bool
!================================
check_all_inside.2890:
	slli	%g3, %g5, 2
	ld	%g6, %g4, %g3
	jne	%g6, %g29, jeq_else.51322
	addi	%g3, %g0, 1
	return
jeq_else.51322:
	slli	%g3, %g6, 2
	add	%g3, %g31, %g3
	ldi	%g7, %g3, 272
	ldi	%g3, %g7, -20
	fldi	%f0, %g3, 0
	fsub	%f0, %f5, %f0
	fldi	%f1, %g3, -4
	fsub	%f2, %f4, %f1
	fldi	%f1, %g3, -8
	fsub	%f1, %f3, %f1
	ldi	%g6, %g7, -4
	jne	%g6, %g28, jeq_else.51323
	fjlt	%f0, %f16, fjge_else.51325
	fmov	%f6, %f0
	jmp	fjge_cont.51326
fjge_else.51325:
	fneg	%f6, %f0
fjge_cont.51326:
	ldi	%g3, %g7, -16
	fldi	%f0, %g3, 0
	fjlt	%f6, %f0, fjge_else.51327
	addi	%g6, %g0, 0
	jmp	fjge_cont.51328
fjge_else.51327:
	fjlt	%f2, %f16, fjge_else.51329
	fmov	%f0, %f2
	jmp	fjge_cont.51330
fjge_else.51329:
	fneg	%f0, %f2
fjge_cont.51330:
	fldi	%f2, %g3, -4
	fjlt	%f0, %f2, fjge_else.51331
	addi	%g6, %g0, 0
	jmp	fjge_cont.51332
fjge_else.51331:
	fjlt	%f1, %f16, fjge_else.51333
	fmov	%f0, %f1
	jmp	fjge_cont.51334
fjge_else.51333:
	fneg	%f0, %f1
fjge_cont.51334:
	fldi	%f1, %g3, -8
	fjlt	%f0, %f1, fjge_else.51335
	addi	%g6, %g0, 0
	jmp	fjge_cont.51336
fjge_else.51335:
	addi	%g6, %g0, 1
fjge_cont.51336:
fjge_cont.51332:
fjge_cont.51328:
	jne	%g6, %g0, jeq_else.51337
	ldi	%g3, %g7, -24
	jne	%g3, %g0, jeq_else.51339
	addi	%g3, %g0, 1
	jmp	jeq_cont.51340
jeq_else.51339:
	addi	%g3, %g0, 0
jeq_cont.51340:
	jmp	jeq_cont.51338
jeq_else.51337:
	ldi	%g3, %g7, -24
jeq_cont.51338:
	jmp	jeq_cont.51324
jeq_else.51323:
	addi	%g3, %g0, 2
	jne	%g6, %g3, jeq_else.51341
	ldi	%g3, %g7, -16
	fldi	%f6, %g3, 0
	fmul	%f6, %f6, %f0
	fldi	%f0, %g3, -4
	fmul	%f0, %f0, %f2
	fadd	%f2, %f6, %f0
	fldi	%f0, %g3, -8
	fmul	%f0, %f0, %f1
	fadd	%f0, %f2, %f0
	ldi	%g3, %g7, -24
	fjlt	%f0, %f16, fjge_else.51343
	addi	%g6, %g0, 0
	jmp	fjge_cont.51344
fjge_else.51343:
	addi	%g6, %g0, 1
fjge_cont.51344:
	jne	%g3, %g6, jeq_else.51345
	addi	%g3, %g0, 1
	jmp	jeq_cont.51346
jeq_else.51345:
	addi	%g3, %g0, 0
jeq_cont.51346:
	jmp	jeq_cont.51342
jeq_else.51341:
	fmul	%f7, %f0, %f0
	ldi	%g3, %g7, -16
	fldi	%f6, %g3, 0
	fmul	%f8, %f7, %f6
	fmul	%f7, %f2, %f2
	fldi	%f6, %g3, -4
	fmul	%f6, %f7, %f6
	fadd	%f8, %f8, %f6
	fmul	%f7, %f1, %f1
	fldi	%f6, %g3, -8
	fmul	%f6, %f7, %f6
	fadd	%f7, %f8, %f6
	ldi	%g3, %g7, -12
	jne	%g3, %g0, jeq_else.51347
	fmov	%f6, %f7
	jmp	jeq_cont.51348
jeq_else.51347:
	fmul	%f8, %f2, %f1
	ldi	%g3, %g7, -36
	fldi	%f6, %g3, 0
	fmul	%f6, %f8, %f6
	fadd	%f7, %f7, %f6
	fmul	%f6, %f1, %f0
	fldi	%f1, %g3, -4
	fmul	%f1, %f6, %f1
	fadd	%f7, %f7, %f1
	fmul	%f1, %f0, %f2
	fldi	%f0, %g3, -8
	fmul	%f6, %f1, %f0
	fadd	%f6, %f7, %f6
jeq_cont.51348:
	addi	%g3, %g0, 3
	jne	%g6, %g3, jeq_else.51349
	fsub	%f0, %f6, %f17
	jmp	jeq_cont.51350
jeq_else.51349:
	fmov	%f0, %f6
jeq_cont.51350:
	ldi	%g3, %g7, -24
	fjlt	%f0, %f16, fjge_else.51351
	addi	%g6, %g0, 0
	jmp	fjge_cont.51352
fjge_else.51351:
	addi	%g6, %g0, 1
fjge_cont.51352:
	jne	%g3, %g6, jeq_else.51353
	addi	%g3, %g0, 1
	jmp	jeq_cont.51354
jeq_else.51353:
	addi	%g3, %g0, 0
jeq_cont.51354:
jeq_cont.51342:
jeq_cont.51324:
	jne	%g3, %g0, jeq_else.51355
	addi	%g7, %g5, 1
	slli	%g3, %g7, 2
	ld	%g5, %g4, %g3
	jne	%g5, %g29, jeq_else.51356
	addi	%g3, %g0, 1
	return
jeq_else.51356:
	slli	%g3, %g5, 2
	add	%g3, %g31, %g3
	ldi	%g6, %g3, 272
	ldi	%g3, %g6, -20
	fldi	%f0, %g3, 0
	fsub	%f0, %f5, %f0
	fldi	%f1, %g3, -4
	fsub	%f2, %f4, %f1
	fldi	%f1, %g3, -8
	fsub	%f1, %f3, %f1
	ldi	%g5, %g6, -4
	jne	%g5, %g28, jeq_else.51357
	fjlt	%f0, %f16, fjge_else.51359
	fmov	%f6, %f0
	jmp	fjge_cont.51360
fjge_else.51359:
	fneg	%f6, %f0
fjge_cont.51360:
	ldi	%g3, %g6, -16
	fldi	%f0, %g3, 0
	fjlt	%f6, %f0, fjge_else.51361
	addi	%g5, %g0, 0
	jmp	fjge_cont.51362
fjge_else.51361:
	fjlt	%f2, %f16, fjge_else.51363
	fmov	%f0, %f2
	jmp	fjge_cont.51364
fjge_else.51363:
	fneg	%f0, %f2
fjge_cont.51364:
	fldi	%f2, %g3, -4
	fjlt	%f0, %f2, fjge_else.51365
	addi	%g5, %g0, 0
	jmp	fjge_cont.51366
fjge_else.51365:
	fjlt	%f1, %f16, fjge_else.51367
	fmov	%f0, %f1
	jmp	fjge_cont.51368
fjge_else.51367:
	fneg	%f0, %f1
fjge_cont.51368:
	fldi	%f1, %g3, -8
	fjlt	%f0, %f1, fjge_else.51369
	addi	%g5, %g0, 0
	jmp	fjge_cont.51370
fjge_else.51369:
	addi	%g5, %g0, 1
fjge_cont.51370:
fjge_cont.51366:
fjge_cont.51362:
	jne	%g5, %g0, jeq_else.51371
	ldi	%g3, %g6, -24
	jne	%g3, %g0, jeq_else.51373
	addi	%g3, %g0, 1
	jmp	jeq_cont.51374
jeq_else.51373:
	addi	%g3, %g0, 0
jeq_cont.51374:
	jmp	jeq_cont.51372
jeq_else.51371:
	ldi	%g3, %g6, -24
jeq_cont.51372:
	jmp	jeq_cont.51358
jeq_else.51357:
	addi	%g3, %g0, 2
	jne	%g5, %g3, jeq_else.51375
	ldi	%g3, %g6, -16
	fldi	%f6, %g3, 0
	fmul	%f6, %f6, %f0
	fldi	%f0, %g3, -4
	fmul	%f0, %f0, %f2
	fadd	%f2, %f6, %f0
	fldi	%f0, %g3, -8
	fmul	%f0, %f0, %f1
	fadd	%f0, %f2, %f0
	ldi	%g3, %g6, -24
	fjlt	%f0, %f16, fjge_else.51377
	addi	%g5, %g0, 0
	jmp	fjge_cont.51378
fjge_else.51377:
	addi	%g5, %g0, 1
fjge_cont.51378:
	jne	%g3, %g5, jeq_else.51379
	addi	%g3, %g0, 1
	jmp	jeq_cont.51380
jeq_else.51379:
	addi	%g3, %g0, 0
jeq_cont.51380:
	jmp	jeq_cont.51376
jeq_else.51375:
	fmul	%f7, %f0, %f0
	ldi	%g3, %g6, -16
	fldi	%f6, %g3, 0
	fmul	%f8, %f7, %f6
	fmul	%f7, %f2, %f2
	fldi	%f6, %g3, -4
	fmul	%f6, %f7, %f6
	fadd	%f8, %f8, %f6
	fmul	%f7, %f1, %f1
	fldi	%f6, %g3, -8
	fmul	%f6, %f7, %f6
	fadd	%f7, %f8, %f6
	ldi	%g3, %g6, -12
	jne	%g3, %g0, jeq_else.51381
	fmov	%f6, %f7
	jmp	jeq_cont.51382
jeq_else.51381:
	fmul	%f8, %f2, %f1
	ldi	%g3, %g6, -36
	fldi	%f6, %g3, 0
	fmul	%f6, %f8, %f6
	fadd	%f7, %f7, %f6
	fmul	%f6, %f1, %f0
	fldi	%f1, %g3, -4
	fmul	%f1, %f6, %f1
	fadd	%f7, %f7, %f1
	fmul	%f1, %f0, %f2
	fldi	%f0, %g3, -8
	fmul	%f6, %f1, %f0
	fadd	%f6, %f7, %f6
jeq_cont.51382:
	addi	%g3, %g0, 3
	jne	%g5, %g3, jeq_else.51383
	fsub	%f0, %f6, %f17
	jmp	jeq_cont.51384
jeq_else.51383:
	fmov	%f0, %f6
jeq_cont.51384:
	ldi	%g3, %g6, -24
	fjlt	%f0, %f16, fjge_else.51385
	addi	%g5, %g0, 0
	jmp	fjge_cont.51386
fjge_else.51385:
	addi	%g5, %g0, 1
fjge_cont.51386:
	jne	%g3, %g5, jeq_else.51387
	addi	%g3, %g0, 1
	jmp	jeq_cont.51388
jeq_else.51387:
	addi	%g3, %g0, 0
jeq_cont.51388:
jeq_cont.51376:
jeq_cont.51358:
	jne	%g3, %g0, jeq_else.51389
	addi	%g5, %g7, 1
	jmp	check_all_inside.2890
jeq_else.51389:
	addi	%g3, %g0, 0
	return
jeq_else.51355:
	addi	%g3, %g0, 0
	return

!==============================
! args = [%g8, %g4]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Bool
!================================
shadow_check_and_group.2896:
	slli	%g3, %g8, 2
	ld	%g9, %g4, %g3
	jne	%g9, %g29, jeq_else.51390
	addi	%g3, %g0, 0
	return
jeq_else.51390:
	slli	%g3, %g9, 2
	add	%g3, %g31, %g3
	ldi	%g6, %g3, 272
	fldi	%f1, %g31, 540
	ldi	%g3, %g6, -20
	fldi	%f0, %g3, 0
	fsub	%f3, %f1, %f0
	fldi	%f1, %g31, 536
	fldi	%f0, %g3, -4
	fsub	%f4, %f1, %f0
	fldi	%f1, %g31, 532
	fldi	%f0, %g3, -8
	fsub	%f2, %f1, %f0
	slli	%g3, %g9, 2
	add	%g3, %g31, %g3
	ldi	%g7, %g3, 972
	ldi	%g5, %g6, -4
	jne	%g5, %g28, jeq_else.51391
	fldi	%f0, %g7, 0
	fsub	%f0, %f0, %f3
	fldi	%f1, %g7, -4
	fmul	%f0, %f0, %f1
	fldi	%f5, %g31, 728
	fmul	%f5, %f0, %f5
	fadd	%f6, %f5, %f4
	fjlt	%f6, %f16, fjge_else.51393
	fmov	%f5, %f6
	jmp	fjge_cont.51394
fjge_else.51393:
	fneg	%f5, %f6
fjge_cont.51394:
	ldi	%g5, %g6, -16
	fldi	%f6, %g5, -4
	fjlt	%f5, %f6, fjge_else.51395
	addi	%g3, %g0, 0
	jmp	fjge_cont.51396
fjge_else.51395:
	fldi	%f5, %g31, 724
	fmul	%f5, %f0, %f5
	fadd	%f6, %f5, %f2
	fjlt	%f6, %f16, fjge_else.51397
	fmov	%f5, %f6
	jmp	fjge_cont.51398
fjge_else.51397:
	fneg	%f5, %f6
fjge_cont.51398:
	fldi	%f6, %g5, -8
	fjlt	%f5, %f6, fjge_else.51399
	addi	%g3, %g0, 0
	jmp	fjge_cont.51400
fjge_else.51399:
	fjeq	%f1, %f16, fjne_else.51401
	addi	%g3, %g0, 1
	jmp	fjne_cont.51402
fjne_else.51401:
	addi	%g3, %g0, 0
fjne_cont.51402:
fjge_cont.51400:
fjge_cont.51396:
	jne	%g3, %g0, jeq_else.51403
	fldi	%f0, %g7, -8
	fsub	%f0, %f0, %f4
	fldi	%f1, %g7, -12
	fmul	%f0, %f0, %f1
	fldi	%f5, %g31, 732
	fmul	%f5, %f0, %f5
	fadd	%f6, %f5, %f3
	fjlt	%f6, %f16, fjge_else.51405
	fmov	%f5, %f6
	jmp	fjge_cont.51406
fjge_else.51405:
	fneg	%f5, %f6
fjge_cont.51406:
	fldi	%f6, %g5, 0
	fjlt	%f5, %f6, fjge_else.51407
	addi	%g3, %g0, 0
	jmp	fjge_cont.51408
fjge_else.51407:
	fldi	%f5, %g31, 724
	fmul	%f5, %f0, %f5
	fadd	%f6, %f5, %f2
	fjlt	%f6, %f16, fjge_else.51409
	fmov	%f5, %f6
	jmp	fjge_cont.51410
fjge_else.51409:
	fneg	%f5, %f6
fjge_cont.51410:
	fldi	%f6, %g5, -8
	fjlt	%f5, %f6, fjge_else.51411
	addi	%g3, %g0, 0
	jmp	fjge_cont.51412
fjge_else.51411:
	fjeq	%f1, %f16, fjne_else.51413
	addi	%g3, %g0, 1
	jmp	fjne_cont.51414
fjne_else.51413:
	addi	%g3, %g0, 0
fjne_cont.51414:
fjge_cont.51412:
fjge_cont.51408:
	jne	%g3, %g0, jeq_else.51415
	fldi	%f0, %g7, -16
	fsub	%f1, %f0, %f2
	fldi	%f0, %g7, -20
	fmul	%f5, %f1, %f0
	fldi	%f1, %g31, 732
	fmul	%f1, %f5, %f1
	fadd	%f2, %f1, %f3
	fjlt	%f2, %f16, fjge_else.51417
	fmov	%f1, %f2
	jmp	fjge_cont.51418
fjge_else.51417:
	fneg	%f1, %f2
fjge_cont.51418:
	fldi	%f2, %g5, 0
	fjlt	%f1, %f2, fjge_else.51419
	addi	%g3, %g0, 0
	jmp	fjge_cont.51420
fjge_else.51419:
	fldi	%f1, %g31, 728
	fmul	%f1, %f5, %f1
	fadd	%f2, %f1, %f4
	fjlt	%f2, %f16, fjge_else.51421
	fmov	%f1, %f2
	jmp	fjge_cont.51422
fjge_else.51421:
	fneg	%f1, %f2
fjge_cont.51422:
	fldi	%f2, %g5, -4
	fjlt	%f1, %f2, fjge_else.51423
	addi	%g3, %g0, 0
	jmp	fjge_cont.51424
fjge_else.51423:
	fjeq	%f0, %f16, fjne_else.51425
	addi	%g3, %g0, 1
	jmp	fjne_cont.51426
fjne_else.51425:
	addi	%g3, %g0, 0
fjne_cont.51426:
fjge_cont.51424:
fjge_cont.51420:
	jne	%g3, %g0, jeq_else.51427
	addi	%g3, %g0, 0
	jmp	jeq_cont.51428
jeq_else.51427:
	fsti	%f5, %g31, 520
	addi	%g3, %g0, 3
jeq_cont.51428:
	jmp	jeq_cont.51416
jeq_else.51415:
	fsti	%f0, %g31, 520
	addi	%g3, %g0, 2
jeq_cont.51416:
	jmp	jeq_cont.51404
jeq_else.51403:
	fsti	%f0, %g31, 520
	addi	%g3, %g0, 1
jeq_cont.51404:
	jmp	jeq_cont.51392
jeq_else.51391:
	addi	%g3, %g0, 2
	jne	%g5, %g3, jeq_else.51429
	fldi	%f0, %g7, 0
	fjlt	%f0, %f16, fjge_else.51431
	addi	%g3, %g0, 0
	jmp	fjge_cont.51432
fjge_else.51431:
	fldi	%f0, %g7, -4
	fmul	%f1, %f0, %f3
	fldi	%f0, %g7, -8
	fmul	%f0, %f0, %f4
	fadd	%f1, %f1, %f0
	fldi	%f0, %g7, -12
	fmul	%f0, %f0, %f2
	fadd	%f0, %f1, %f0
	fsti	%f0, %g31, 520
	addi	%g3, %g0, 1
fjge_cont.51432:
	jmp	jeq_cont.51430
jeq_else.51429:
	fldi	%f0, %g7, 0
	fjeq	%f0, %f16, fjne_else.51433
	fldi	%f1, %g7, -4
	fmul	%f5, %f1, %f3
	fldi	%f1, %g7, -8
	fmul	%f1, %f1, %f4
	fadd	%f5, %f5, %f1
	fldi	%f1, %g7, -12
	fmul	%f1, %f1, %f2
	fadd	%f1, %f5, %f1
	fmul	%f6, %f3, %f3
	ldi	%g3, %g6, -16
	fldi	%f5, %g3, 0
	fmul	%f7, %f6, %f5
	fmul	%f6, %f4, %f4
	fldi	%f5, %g3, -4
	fmul	%f5, %f6, %f5
	fadd	%f7, %f7, %f5
	fmul	%f6, %f2, %f2
	fldi	%f5, %g3, -8
	fmul	%f5, %f6, %f5
	fadd	%f6, %f7, %f5
	ldi	%g3, %g6, -12
	jne	%g3, %g0, jeq_else.51435
	fmov	%f5, %f6
	jmp	jeq_cont.51436
jeq_else.51435:
	fmul	%f7, %f4, %f2
	ldi	%g3, %g6, -36
	fldi	%f5, %g3, 0
	fmul	%f5, %f7, %f5
	fadd	%f6, %f6, %f5
	fmul	%f5, %f2, %f3
	fldi	%f2, %g3, -4
	fmul	%f2, %f5, %f2
	fadd	%f6, %f6, %f2
	fmul	%f3, %f3, %f4
	fldi	%f2, %g3, -8
	fmul	%f5, %f3, %f2
	fadd	%f5, %f6, %f5
jeq_cont.51436:
	addi	%g3, %g0, 3
	jne	%g5, %g3, jeq_else.51437
	fsub	%f2, %f5, %f17
	jmp	jeq_cont.51438
jeq_else.51437:
	fmov	%f2, %f5
jeq_cont.51438:
	fmul	%f3, %f1, %f1
	fmul	%f0, %f0, %f2
	fsub	%f0, %f3, %f0
	fjlt	%f16, %f0, fjge_else.51439
	addi	%g3, %g0, 0
	jmp	fjge_cont.51440
fjge_else.51439:
	ldi	%g3, %g6, -24
	jne	%g3, %g0, jeq_else.51441
	fsqrt	%f0, %f0
	fsub	%f1, %f1, %f0
	fldi	%f0, %g7, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g31, 520
	jmp	jeq_cont.51442
jeq_else.51441:
	fsqrt	%f0, %f0
	fadd	%f1, %f1, %f0
	fldi	%f0, %g7, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g31, 520
jeq_cont.51442:
	addi	%g3, %g0, 1
fjge_cont.51440:
	jmp	fjne_cont.51434
fjne_else.51433:
	addi	%g3, %g0, 0
fjne_cont.51434:
jeq_cont.51430:
jeq_cont.51392:
	fldi	%f0, %g31, 520
	jne	%g3, %g0, jeq_else.51443
	addi	%g3, %g0, 0
	jmp	jeq_cont.51444
jeq_else.51443:
	setL %g3, l.44445
	fldi	%f1, %g3, 0
	fjlt	%f0, %f1, fjge_else.51445
	addi	%g3, %g0, 0
	jmp	fjge_cont.51446
fjge_else.51445:
	addi	%g3, %g0, 1
fjge_cont.51446:
jeq_cont.51444:
	jne	%g3, %g0, jeq_else.51447
	slli	%g3, %g9, 2
	add	%g3, %g31, %g3
	ldi	%g3, %g3, 272
	ldi	%g3, %g3, -24
	jne	%g3, %g0, jeq_else.51448
	addi	%g3, %g0, 0
	return
jeq_else.51448:
	addi	%g8, %g8, 1
	jmp	shadow_check_and_group.2896
jeq_else.51447:
	setL %g3, l.44447
	fldi	%f1, %g3, 0
	fadd	%f0, %f0, %f1
	fldi	%f1, %g31, 308
	fmul	%f2, %f1, %f0
	fldi	%f1, %g31, 540
	fadd	%f5, %f2, %f1
	fldi	%f1, %g31, 304
	fmul	%f2, %f1, %f0
	fldi	%f1, %g31, 536
	fadd	%f4, %f2, %f1
	fldi	%f1, %g31, 300
	fmul	%f1, %f1, %f0
	fldi	%f0, %g31, 532
	fadd	%f3, %f1, %f0
	ldi	%g5, %g4, 0
	sti	%g4, %g1, 0
	jne	%g5, %g29, jeq_else.51449
	addi	%g3, %g0, 1
	jmp	jeq_cont.51450
jeq_else.51449:
	slli	%g3, %g5, 2
	add	%g3, %g31, %g3
	ldi	%g6, %g3, 272
	ldi	%g3, %g6, -20
	fldi	%f0, %g3, 0
	fsub	%f0, %f5, %f0
	fldi	%f1, %g3, -4
	fsub	%f2, %f4, %f1
	fldi	%f1, %g3, -8
	fsub	%f1, %f3, %f1
	ldi	%g5, %g6, -4
	jne	%g5, %g28, jeq_else.51451
	fjlt	%f0, %f16, fjge_else.51453
	fmov	%f6, %f0
	jmp	fjge_cont.51454
fjge_else.51453:
	fneg	%f6, %f0
fjge_cont.51454:
	ldi	%g3, %g6, -16
	fldi	%f0, %g3, 0
	fjlt	%f6, %f0, fjge_else.51455
	addi	%g5, %g0, 0
	jmp	fjge_cont.51456
fjge_else.51455:
	fjlt	%f2, %f16, fjge_else.51457
	fmov	%f0, %f2
	jmp	fjge_cont.51458
fjge_else.51457:
	fneg	%f0, %f2
fjge_cont.51458:
	fldi	%f2, %g3, -4
	fjlt	%f0, %f2, fjge_else.51459
	addi	%g5, %g0, 0
	jmp	fjge_cont.51460
fjge_else.51459:
	fjlt	%f1, %f16, fjge_else.51461
	fmov	%f0, %f1
	jmp	fjge_cont.51462
fjge_else.51461:
	fneg	%f0, %f1
fjge_cont.51462:
	fldi	%f1, %g3, -8
	fjlt	%f0, %f1, fjge_else.51463
	addi	%g5, %g0, 0
	jmp	fjge_cont.51464
fjge_else.51463:
	addi	%g5, %g0, 1
fjge_cont.51464:
fjge_cont.51460:
fjge_cont.51456:
	jne	%g5, %g0, jeq_else.51465
	ldi	%g3, %g6, -24
	jne	%g3, %g0, jeq_else.51467
	addi	%g3, %g0, 1
	jmp	jeq_cont.51468
jeq_else.51467:
	addi	%g3, %g0, 0
jeq_cont.51468:
	jmp	jeq_cont.51466
jeq_else.51465:
	ldi	%g3, %g6, -24
jeq_cont.51466:
	jmp	jeq_cont.51452
jeq_else.51451:
	addi	%g3, %g0, 2
	jne	%g5, %g3, jeq_else.51469
	ldi	%g3, %g6, -16
	fldi	%f6, %g3, 0
	fmul	%f6, %f6, %f0
	fldi	%f0, %g3, -4
	fmul	%f0, %f0, %f2
	fadd	%f2, %f6, %f0
	fldi	%f0, %g3, -8
	fmul	%f0, %f0, %f1
	fadd	%f0, %f2, %f0
	ldi	%g3, %g6, -24
	fjlt	%f0, %f16, fjge_else.51471
	addi	%g5, %g0, 0
	jmp	fjge_cont.51472
fjge_else.51471:
	addi	%g5, %g0, 1
fjge_cont.51472:
	jne	%g3, %g5, jeq_else.51473
	addi	%g3, %g0, 1
	jmp	jeq_cont.51474
jeq_else.51473:
	addi	%g3, %g0, 0
jeq_cont.51474:
	jmp	jeq_cont.51470
jeq_else.51469:
	fmul	%f7, %f0, %f0
	ldi	%g3, %g6, -16
	fldi	%f6, %g3, 0
	fmul	%f8, %f7, %f6
	fmul	%f7, %f2, %f2
	fldi	%f6, %g3, -4
	fmul	%f6, %f7, %f6
	fadd	%f8, %f8, %f6
	fmul	%f7, %f1, %f1
	fldi	%f6, %g3, -8
	fmul	%f6, %f7, %f6
	fadd	%f7, %f8, %f6
	ldi	%g3, %g6, -12
	jne	%g3, %g0, jeq_else.51475
	fmov	%f6, %f7
	jmp	jeq_cont.51476
jeq_else.51475:
	fmul	%f8, %f2, %f1
	ldi	%g3, %g6, -36
	fldi	%f6, %g3, 0
	fmul	%f6, %f8, %f6
	fadd	%f7, %f7, %f6
	fmul	%f6, %f1, %f0
	fldi	%f1, %g3, -4
	fmul	%f1, %f6, %f1
	fadd	%f7, %f7, %f1
	fmul	%f1, %f0, %f2
	fldi	%f0, %g3, -8
	fmul	%f6, %f1, %f0
	fadd	%f6, %f7, %f6
jeq_cont.51476:
	addi	%g3, %g0, 3
	jne	%g5, %g3, jeq_else.51477
	fsub	%f0, %f6, %f17
	jmp	jeq_cont.51478
jeq_else.51477:
	fmov	%f0, %f6
jeq_cont.51478:
	ldi	%g3, %g6, -24
	fjlt	%f0, %f16, fjge_else.51479
	addi	%g5, %g0, 0
	jmp	fjge_cont.51480
fjge_else.51479:
	addi	%g5, %g0, 1
fjge_cont.51480:
	jne	%g3, %g5, jeq_else.51481
	addi	%g3, %g0, 1
	jmp	jeq_cont.51482
jeq_else.51481:
	addi	%g3, %g0, 0
jeq_cont.51482:
jeq_cont.51470:
jeq_cont.51452:
	jne	%g3, %g0, jeq_else.51483
	addi	%g5, %g0, 1
	subi	%g1, %g1, 8
	call	check_all_inside.2890
	addi	%g1, %g1, 8
	jmp	jeq_cont.51484
jeq_else.51483:
	addi	%g3, %g0, 0
jeq_cont.51484:
jeq_cont.51450:
	jne	%g3, %g0, jeq_else.51485
	addi	%g8, %g8, 1
	ldi	%g4, %g1, 0
	jmp	shadow_check_and_group.2896
jeq_else.51485:
	addi	%g3, %g0, 1
	return

!==============================
! args = [%g11, %g10]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g11, %g10, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Bool
!================================
shadow_check_one_or_group.2899:
	slli	%g3, %g11, 2
	ld	%g4, %g10, %g3
	jne	%g4, %g29, jeq_else.51486
	addi	%g3, %g0, 0
	return
jeq_else.51486:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g8, %g0, 0
	subi	%g1, %g1, 4
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.51487
	addi	%g11, %g11, 1
	slli	%g3, %g11, 2
	ld	%g4, %g10, %g3
	jne	%g4, %g29, jeq_else.51488
	addi	%g3, %g0, 0
	return
jeq_else.51488:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g8, %g0, 0
	subi	%g1, %g1, 4
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.51489
	addi	%g11, %g11, 1
	slli	%g3, %g11, 2
	ld	%g4, %g10, %g3
	jne	%g4, %g29, jeq_else.51490
	addi	%g3, %g0, 0
	return
jeq_else.51490:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g8, %g0, 0
	subi	%g1, %g1, 4
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.51491
	addi	%g11, %g11, 1
	slli	%g3, %g11, 2
	ld	%g4, %g10, %g3
	jne	%g4, %g29, jeq_else.51492
	addi	%g3, %g0, 0
	return
jeq_else.51492:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g8, %g0, 0
	subi	%g1, %g1, 4
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.51493
	addi	%g11, %g11, 1
	slli	%g3, %g11, 2
	ld	%g4, %g10, %g3
	jne	%g4, %g29, jeq_else.51494
	addi	%g3, %g0, 0
	return
jeq_else.51494:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g8, %g0, 0
	subi	%g1, %g1, 4
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.51495
	addi	%g11, %g11, 1
	slli	%g3, %g11, 2
	ld	%g4, %g10, %g3
	jne	%g4, %g29, jeq_else.51496
	addi	%g3, %g0, 0
	return
jeq_else.51496:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g8, %g0, 0
	subi	%g1, %g1, 4
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.51497
	addi	%g11, %g11, 1
	slli	%g3, %g11, 2
	ld	%g4, %g10, %g3
	jne	%g4, %g29, jeq_else.51498
	addi	%g3, %g0, 0
	return
jeq_else.51498:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g8, %g0, 0
	subi	%g1, %g1, 4
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.51499
	addi	%g11, %g11, 1
	slli	%g3, %g11, 2
	ld	%g4, %g10, %g3
	jne	%g4, %g29, jeq_else.51500
	addi	%g3, %g0, 0
	return
jeq_else.51500:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g8, %g0, 0
	subi	%g1, %g1, 4
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.51501
	addi	%g11, %g11, 1
	jmp	shadow_check_one_or_group.2899
jeq_else.51501:
	addi	%g3, %g0, 1
	return
jeq_else.51499:
	addi	%g3, %g0, 1
	return
jeq_else.51497:
	addi	%g3, %g0, 1
	return
jeq_else.51495:
	addi	%g3, %g0, 1
	return
jeq_else.51493:
	addi	%g3, %g0, 1
	return
jeq_else.51491:
	addi	%g3, %g0, 1
	return
jeq_else.51489:
	addi	%g3, %g0, 1
	return
jeq_else.51487:
	addi	%g3, %g0, 1
	return

!==============================
! args = [%g12, %g13]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g13, %g12, %g11, %g10, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Bool
!================================
shadow_check_one_or_matrix.2902:
	slli	%g3, %g12, 2
	ld	%g10, %g13, %g3
	ldi	%g4, %g10, 0
	jne	%g4, %g29, jeq_else.51502
	addi	%g3, %g0, 0
	return
jeq_else.51502:
	addi	%g3, %g0, 99
	sti	%g10, %g1, 0
	jne	%g4, %g3, jeq_else.51503
	addi	%g3, %g0, 1
	jmp	jeq_cont.51504
jeq_else.51503:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g5, %g3, 272
	fldi	%f1, %g31, 540
	ldi	%g3, %g5, -20
	fldi	%f0, %g3, 0
	fsub	%f3, %f1, %f0
	fldi	%f1, %g31, 536
	fldi	%f0, %g3, -4
	fsub	%f4, %f1, %f0
	fldi	%f1, %g31, 532
	fldi	%f0, %g3, -8
	fsub	%f1, %f1, %f0
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g6, %g3, 972
	ldi	%g4, %g5, -4
	jne	%g4, %g28, jeq_else.51505
	fldi	%f0, %g6, 0
	fsub	%f2, %f0, %f3
	fldi	%f0, %g6, -4
	fmul	%f6, %f2, %f0
	fldi	%f2, %g31, 728
	fmul	%f2, %f6, %f2
	fadd	%f5, %f2, %f4
	fjlt	%f5, %f16, fjge_else.51507
	fmov	%f2, %f5
	jmp	fjge_cont.51508
fjge_else.51507:
	fneg	%f2, %f5
fjge_cont.51508:
	ldi	%g4, %g5, -16
	fldi	%f5, %g4, -4
	fjlt	%f2, %f5, fjge_else.51509
	addi	%g3, %g0, 0
	jmp	fjge_cont.51510
fjge_else.51509:
	fldi	%f2, %g31, 724
	fmul	%f2, %f6, %f2
	fadd	%f5, %f2, %f1
	fjlt	%f5, %f16, fjge_else.51511
	fmov	%f2, %f5
	jmp	fjge_cont.51512
fjge_else.51511:
	fneg	%f2, %f5
fjge_cont.51512:
	fldi	%f5, %g4, -8
	fjlt	%f2, %f5, fjge_else.51513
	addi	%g3, %g0, 0
	jmp	fjge_cont.51514
fjge_else.51513:
	fjeq	%f0, %f16, fjne_else.51515
	addi	%g3, %g0, 1
	jmp	fjne_cont.51516
fjne_else.51515:
	addi	%g3, %g0, 0
fjne_cont.51516:
fjge_cont.51514:
fjge_cont.51510:
	jne	%g3, %g0, jeq_else.51517
	fldi	%f0, %g6, -8
	fsub	%f0, %f0, %f4
	fldi	%f6, %g6, -12
	fmul	%f5, %f0, %f6
	fldi	%f0, %g31, 732
	fmul	%f0, %f5, %f0
	fadd	%f2, %f0, %f3
	fjlt	%f2, %f16, fjge_else.51519
	fmov	%f0, %f2
	jmp	fjge_cont.51520
fjge_else.51519:
	fneg	%f0, %f2
fjge_cont.51520:
	fldi	%f2, %g4, 0
	fjlt	%f0, %f2, fjge_else.51521
	addi	%g3, %g0, 0
	jmp	fjge_cont.51522
fjge_else.51521:
	fldi	%f0, %g31, 724
	fmul	%f0, %f5, %f0
	fadd	%f2, %f0, %f1
	fjlt	%f2, %f16, fjge_else.51523
	fmov	%f0, %f2
	jmp	fjge_cont.51524
fjge_else.51523:
	fneg	%f0, %f2
fjge_cont.51524:
	fldi	%f2, %g4, -8
	fjlt	%f0, %f2, fjge_else.51525
	addi	%g3, %g0, 0
	jmp	fjge_cont.51526
fjge_else.51525:
	fjeq	%f6, %f16, fjne_else.51527
	addi	%g3, %g0, 1
	jmp	fjne_cont.51528
fjne_else.51527:
	addi	%g3, %g0, 0
fjne_cont.51528:
fjge_cont.51526:
fjge_cont.51522:
	jne	%g3, %g0, jeq_else.51529
	fldi	%f0, %g6, -16
	fsub	%f0, %f0, %f1
	fldi	%f5, %g6, -20
	fmul	%f2, %f0, %f5
	fldi	%f0, %g31, 732
	fmul	%f0, %f2, %f0
	fadd	%f1, %f0, %f3
	fjlt	%f1, %f16, fjge_else.51531
	fmov	%f0, %f1
	jmp	fjge_cont.51532
fjge_else.51531:
	fneg	%f0, %f1
fjge_cont.51532:
	fldi	%f1, %g4, 0
	fjlt	%f0, %f1, fjge_else.51533
	addi	%g3, %g0, 0
	jmp	fjge_cont.51534
fjge_else.51533:
	fldi	%f0, %g31, 728
	fmul	%f0, %f2, %f0
	fadd	%f1, %f0, %f4
	fjlt	%f1, %f16, fjge_else.51535
	fmov	%f0, %f1
	jmp	fjge_cont.51536
fjge_else.51535:
	fneg	%f0, %f1
fjge_cont.51536:
	fldi	%f1, %g4, -4
	fjlt	%f0, %f1, fjge_else.51537
	addi	%g3, %g0, 0
	jmp	fjge_cont.51538
fjge_else.51537:
	fjeq	%f5, %f16, fjne_else.51539
	addi	%g3, %g0, 1
	jmp	fjne_cont.51540
fjne_else.51539:
	addi	%g3, %g0, 0
fjne_cont.51540:
fjge_cont.51538:
fjge_cont.51534:
	jne	%g3, %g0, jeq_else.51541
	addi	%g3, %g0, 0
	jmp	jeq_cont.51542
jeq_else.51541:
	fsti	%f2, %g31, 520
	addi	%g3, %g0, 3
jeq_cont.51542:
	jmp	jeq_cont.51530
jeq_else.51529:
	fsti	%f5, %g31, 520
	addi	%g3, %g0, 2
jeq_cont.51530:
	jmp	jeq_cont.51518
jeq_else.51517:
	fsti	%f6, %g31, 520
	addi	%g3, %g0, 1
jeq_cont.51518:
	jmp	jeq_cont.51506
jeq_else.51505:
	addi	%g3, %g0, 2
	jne	%g4, %g3, jeq_else.51543
	fldi	%f0, %g6, 0
	fjlt	%f0, %f16, fjge_else.51545
	addi	%g3, %g0, 0
	jmp	fjge_cont.51546
fjge_else.51545:
	fldi	%f0, %g6, -4
	fmul	%f2, %f0, %f3
	fldi	%f0, %g6, -8
	fmul	%f0, %f0, %f4
	fadd	%f2, %f2, %f0
	fldi	%f0, %g6, -12
	fmul	%f0, %f0, %f1
	fadd	%f0, %f2, %f0
	fsti	%f0, %g31, 520
	addi	%g3, %g0, 1
fjge_cont.51546:
	jmp	jeq_cont.51544
jeq_else.51543:
	fldi	%f0, %g6, 0
	fjeq	%f0, %f16, fjne_else.51547
	fldi	%f2, %g6, -4
	fmul	%f5, %f2, %f3
	fldi	%f2, %g6, -8
	fmul	%f2, %f2, %f4
	fadd	%f5, %f5, %f2
	fldi	%f2, %g6, -12
	fmul	%f2, %f2, %f1
	fadd	%f2, %f5, %f2
	fmul	%f6, %f3, %f3
	ldi	%g3, %g5, -16
	fldi	%f5, %g3, 0
	fmul	%f7, %f6, %f5
	fmul	%f6, %f4, %f4
	fldi	%f5, %g3, -4
	fmul	%f5, %f6, %f5
	fadd	%f7, %f7, %f5
	fmul	%f6, %f1, %f1
	fldi	%f5, %g3, -8
	fmul	%f5, %f6, %f5
	fadd	%f6, %f7, %f5
	ldi	%g3, %g5, -12
	jne	%g3, %g0, jeq_else.51549
	fmov	%f5, %f6
	jmp	jeq_cont.51550
jeq_else.51549:
	fmul	%f7, %f4, %f1
	ldi	%g3, %g5, -36
	fldi	%f5, %g3, 0
	fmul	%f5, %f7, %f5
	fadd	%f6, %f6, %f5
	fmul	%f5, %f1, %f3
	fldi	%f1, %g3, -4
	fmul	%f1, %f5, %f1
	fadd	%f6, %f6, %f1
	fmul	%f3, %f3, %f4
	fldi	%f1, %g3, -8
	fmul	%f5, %f3, %f1
	fadd	%f5, %f6, %f5
jeq_cont.51550:
	addi	%g3, %g0, 3
	jne	%g4, %g3, jeq_else.51551
	fsub	%f1, %f5, %f17
	jmp	jeq_cont.51552
jeq_else.51551:
	fmov	%f1, %f5
jeq_cont.51552:
	fmul	%f3, %f2, %f2
	fmul	%f0, %f0, %f1
	fsub	%f0, %f3, %f0
	fjlt	%f16, %f0, fjge_else.51553
	addi	%g3, %g0, 0
	jmp	fjge_cont.51554
fjge_else.51553:
	ldi	%g3, %g5, -24
	jne	%g3, %g0, jeq_else.51555
	fsqrt	%f0, %f0
	fsub	%f1, %f2, %f0
	fldi	%f0, %g6, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g31, 520
	jmp	jeq_cont.51556
jeq_else.51555:
	fsqrt	%f0, %f0
	fadd	%f1, %f2, %f0
	fldi	%f0, %g6, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g31, 520
jeq_cont.51556:
	addi	%g3, %g0, 1
fjge_cont.51554:
	jmp	fjne_cont.51548
fjne_else.51547:
	addi	%g3, %g0, 0
fjne_cont.51548:
jeq_cont.51544:
jeq_cont.51506:
	jne	%g3, %g0, jeq_else.51557
	addi	%g3, %g0, 0
	jmp	jeq_cont.51558
jeq_else.51557:
	fldi	%f1, %g31, 520
	setL %g3, l.44633
	fldi	%f0, %g3, 0
	fjlt	%f1, %f0, fjge_else.51559
	addi	%g3, %g0, 0
	jmp	fjge_cont.51560
fjge_else.51559:
	ldi	%g4, %g10, -4
	jne	%g4, %g29, jeq_else.51561
	addi	%g3, %g0, 0
	jmp	jeq_cont.51562
jeq_else.51561:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g8, %g0, 0
	subi	%g1, %g1, 8
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.51563
	ldi	%g4, %g10, -8
	jne	%g4, %g29, jeq_else.51565
	addi	%g3, %g0, 0
	jmp	jeq_cont.51566
jeq_else.51565:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g8, %g0, 0
	subi	%g1, %g1, 8
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.51567
	ldi	%g4, %g10, -12
	jne	%g4, %g29, jeq_else.51569
	addi	%g3, %g0, 0
	jmp	jeq_cont.51570
jeq_else.51569:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g8, %g0, 0
	subi	%g1, %g1, 8
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.51571
	ldi	%g4, %g10, -16
	jne	%g4, %g29, jeq_else.51573
	addi	%g3, %g0, 0
	jmp	jeq_cont.51574
jeq_else.51573:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g8, %g0, 0
	subi	%g1, %g1, 8
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.51575
	ldi	%g4, %g10, -20
	jne	%g4, %g29, jeq_else.51577
	addi	%g3, %g0, 0
	jmp	jeq_cont.51578
jeq_else.51577:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g8, %g0, 0
	subi	%g1, %g1, 8
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.51579
	ldi	%g4, %g10, -24
	jne	%g4, %g29, jeq_else.51581
	addi	%g3, %g0, 0
	jmp	jeq_cont.51582
jeq_else.51581:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g8, %g0, 0
	subi	%g1, %g1, 8
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.51583
	ldi	%g4, %g10, -28
	jne	%g4, %g29, jeq_else.51585
	addi	%g3, %g0, 0
	jmp	jeq_cont.51586
jeq_else.51585:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g8, %g0, 0
	subi	%g1, %g1, 8
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.51587
	addi	%g11, %g0, 8
	subi	%g1, %g1, 8
	call	shadow_check_one_or_group.2899
	addi	%g1, %g1, 8
	jmp	jeq_cont.51588
jeq_else.51587:
	addi	%g3, %g0, 1
jeq_cont.51588:
jeq_cont.51586:
	jmp	jeq_cont.51584
jeq_else.51583:
	addi	%g3, %g0, 1
jeq_cont.51584:
jeq_cont.51582:
	jmp	jeq_cont.51580
jeq_else.51579:
	addi	%g3, %g0, 1
jeq_cont.51580:
jeq_cont.51578:
	jmp	jeq_cont.51576
jeq_else.51575:
	addi	%g3, %g0, 1
jeq_cont.51576:
jeq_cont.51574:
	jmp	jeq_cont.51572
jeq_else.51571:
	addi	%g3, %g0, 1
jeq_cont.51572:
jeq_cont.51570:
	jmp	jeq_cont.51568
jeq_else.51567:
	addi	%g3, %g0, 1
jeq_cont.51568:
jeq_cont.51566:
	jmp	jeq_cont.51564
jeq_else.51563:
	addi	%g3, %g0, 1
jeq_cont.51564:
jeq_cont.51562:
	jne	%g3, %g0, jeq_else.51589
	addi	%g3, %g0, 0
	jmp	jeq_cont.51590
jeq_else.51589:
	addi	%g3, %g0, 1
jeq_cont.51590:
fjge_cont.51560:
jeq_cont.51558:
jeq_cont.51504:
	jne	%g3, %g0, jeq_else.51591
	addi	%g12, %g12, 1
	jmp	shadow_check_one_or_matrix.2902
jeq_else.51591:
	ldi	%g10, %g1, 0
	ldi	%g4, %g10, -4
	jne	%g4, %g29, jeq_else.51592
	addi	%g3, %g0, 0
	jmp	jeq_cont.51593
jeq_else.51592:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g8, %g0, 0
	subi	%g1, %g1, 8
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.51594
	ldi	%g4, %g10, -8
	jne	%g4, %g29, jeq_else.51596
	addi	%g3, %g0, 0
	jmp	jeq_cont.51597
jeq_else.51596:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g8, %g0, 0
	subi	%g1, %g1, 8
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.51598
	ldi	%g4, %g10, -12
	jne	%g4, %g29, jeq_else.51600
	addi	%g3, %g0, 0
	jmp	jeq_cont.51601
jeq_else.51600:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g8, %g0, 0
	subi	%g1, %g1, 8
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.51602
	ldi	%g4, %g10, -16
	jne	%g4, %g29, jeq_else.51604
	addi	%g3, %g0, 0
	jmp	jeq_cont.51605
jeq_else.51604:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g8, %g0, 0
	subi	%g1, %g1, 8
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.51606
	ldi	%g4, %g10, -20
	jne	%g4, %g29, jeq_else.51608
	addi	%g3, %g0, 0
	jmp	jeq_cont.51609
jeq_else.51608:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g8, %g0, 0
	subi	%g1, %g1, 8
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.51610
	ldi	%g4, %g10, -24
	jne	%g4, %g29, jeq_else.51612
	addi	%g3, %g0, 0
	jmp	jeq_cont.51613
jeq_else.51612:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g8, %g0, 0
	subi	%g1, %g1, 8
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.51614
	ldi	%g4, %g10, -28
	jne	%g4, %g29, jeq_else.51616
	addi	%g3, %g0, 0
	jmp	jeq_cont.51617
jeq_else.51616:
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g8, %g0, 0
	subi	%g1, %g1, 8
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 8
	jne	%g3, %g0, jeq_else.51618
	addi	%g11, %g0, 8
	subi	%g1, %g1, 8
	call	shadow_check_one_or_group.2899
	addi	%g1, %g1, 8
	jmp	jeq_cont.51619
jeq_else.51618:
	addi	%g3, %g0, 1
jeq_cont.51619:
jeq_cont.51617:
	jmp	jeq_cont.51615
jeq_else.51614:
	addi	%g3, %g0, 1
jeq_cont.51615:
jeq_cont.51613:
	jmp	jeq_cont.51611
jeq_else.51610:
	addi	%g3, %g0, 1
jeq_cont.51611:
jeq_cont.51609:
	jmp	jeq_cont.51607
jeq_else.51606:
	addi	%g3, %g0, 1
jeq_cont.51607:
jeq_cont.51605:
	jmp	jeq_cont.51603
jeq_else.51602:
	addi	%g3, %g0, 1
jeq_cont.51603:
jeq_cont.51601:
	jmp	jeq_cont.51599
jeq_else.51598:
	addi	%g3, %g0, 1
jeq_cont.51599:
jeq_cont.51597:
	jmp	jeq_cont.51595
jeq_else.51594:
	addi	%g3, %g0, 1
jeq_cont.51595:
jeq_cont.51593:
	jne	%g3, %g0, jeq_else.51620
	addi	%g12, %g12, 1
	jmp	shadow_check_one_or_matrix.2902
jeq_else.51620:
	addi	%g3, %g0, 1
	return

!==============================
! args = [%g11, %g4, %g9]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f21, %f2, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
solve_each_element.2905:
	slli	%g3, %g11, 2
	ld	%g10, %g4, %g3
	jne	%g10, %g29, jeq_else.51621
	return
jeq_else.51621:
	slli	%g3, %g10, 2
	add	%g3, %g31, %g3
	ldi	%g7, %g3, 272
	fldi	%f1, %g31, 624
	ldi	%g3, %g7, -20
	fldi	%f0, %g3, 0
	fsub	%f6, %f1, %f0
	fldi	%f1, %g31, 620
	fldi	%f0, %g3, -4
	fsub	%f7, %f1, %f0
	fldi	%f1, %g31, 616
	fldi	%f0, %g3, -8
	fsub	%f5, %f1, %f0
	ldi	%g3, %g7, -4
	jne	%g3, %g28, jeq_else.51623
	fldi	%f2, %g9, 0
	fjeq	%f2, %f16, fjne_else.51625
	ldi	%g5, %g7, -16
	ldi	%g3, %g7, -24
	fjlt	%f2, %f16, fjge_else.51627
	addi	%g6, %g0, 0
	jmp	fjge_cont.51628
fjge_else.51627:
	addi	%g6, %g0, 1
fjge_cont.51628:
	fldi	%f1, %g5, 0
	jne	%g3, %g6, jeq_else.51629
	fneg	%f0, %f1
	jmp	jeq_cont.51630
jeq_else.51629:
	fmov	%f0, %f1
jeq_cont.51630:
	fsub	%f0, %f0, %f6
	fdiv	%f2, %f0, %f2
	fldi	%f0, %g9, -4
	fmul	%f0, %f2, %f0
	fadd	%f1, %f0, %f7
	fjlt	%f1, %f16, fjge_else.51631
	fmov	%f0, %f1
	jmp	fjge_cont.51632
fjge_else.51631:
	fneg	%f0, %f1
fjge_cont.51632:
	fldi	%f1, %g5, -4
	fjlt	%f0, %f1, fjge_else.51633
	addi	%g8, %g0, 0
	jmp	fjge_cont.51634
fjge_else.51633:
	fldi	%f0, %g9, -8
	fmul	%f0, %f2, %f0
	fadd	%f1, %f0, %f5
	fjlt	%f1, %f16, fjge_else.51635
	fmov	%f0, %f1
	jmp	fjge_cont.51636
fjge_else.51635:
	fneg	%f0, %f1
fjge_cont.51636:
	fldi	%f1, %g5, -8
	fjlt	%f0, %f1, fjge_else.51637
	addi	%g8, %g0, 0
	jmp	fjge_cont.51638
fjge_else.51637:
	fsti	%f2, %g31, 520
	addi	%g8, %g0, 1
fjge_cont.51638:
fjge_cont.51634:
	jmp	fjne_cont.51626
fjne_else.51625:
	addi	%g8, %g0, 0
fjne_cont.51626:
	jne	%g8, %g0, jeq_else.51639
	fldi	%f2, %g9, -4
	fjeq	%f2, %f16, fjne_else.51641
	ldi	%g5, %g7, -16
	ldi	%g3, %g7, -24
	fjlt	%f2, %f16, fjge_else.51643
	addi	%g6, %g0, 0
	jmp	fjge_cont.51644
fjge_else.51643:
	addi	%g6, %g0, 1
fjge_cont.51644:
	fldi	%f1, %g5, -4
	jne	%g3, %g6, jeq_else.51645
	fneg	%f0, %f1
	jmp	jeq_cont.51646
jeq_else.51645:
	fmov	%f0, %f1
jeq_cont.51646:
	fsub	%f0, %f0, %f7
	fdiv	%f2, %f0, %f2
	fldi	%f0, %g9, -8
	fmul	%f0, %f2, %f0
	fadd	%f1, %f0, %f5
	fjlt	%f1, %f16, fjge_else.51647
	fmov	%f0, %f1
	jmp	fjge_cont.51648
fjge_else.51647:
	fneg	%f0, %f1
fjge_cont.51648:
	fldi	%f1, %g5, -8
	fjlt	%f0, %f1, fjge_else.51649
	addi	%g8, %g0, 0
	jmp	fjge_cont.51650
fjge_else.51649:
	fldi	%f0, %g9, 0
	fmul	%f0, %f2, %f0
	fadd	%f1, %f0, %f6
	fjlt	%f1, %f16, fjge_else.51651
	fmov	%f0, %f1
	jmp	fjge_cont.51652
fjge_else.51651:
	fneg	%f0, %f1
fjge_cont.51652:
	fldi	%f1, %g5, 0
	fjlt	%f0, %f1, fjge_else.51653
	addi	%g8, %g0, 0
	jmp	fjge_cont.51654
fjge_else.51653:
	fsti	%f2, %g31, 520
	addi	%g8, %g0, 1
fjge_cont.51654:
fjge_cont.51650:
	jmp	fjne_cont.51642
fjne_else.51641:
	addi	%g8, %g0, 0
fjne_cont.51642:
	jne	%g8, %g0, jeq_else.51655
	fldi	%f2, %g9, -8
	fjeq	%f2, %f16, fjne_else.51657
	ldi	%g5, %g7, -16
	ldi	%g3, %g7, -24
	fjlt	%f2, %f16, fjge_else.51659
	addi	%g6, %g0, 0
	jmp	fjge_cont.51660
fjge_else.51659:
	addi	%g6, %g0, 1
fjge_cont.51660:
	fldi	%f1, %g5, -8
	jne	%g3, %g6, jeq_else.51661
	fneg	%f0, %f1
	jmp	jeq_cont.51662
jeq_else.51661:
	fmov	%f0, %f1
jeq_cont.51662:
	fsub	%f0, %f0, %f5
	fdiv	%f2, %f0, %f2
	fldi	%f0, %g9, 0
	fmul	%f0, %f2, %f0
	fadd	%f1, %f0, %f6
	fjlt	%f1, %f16, fjge_else.51663
	fmov	%f0, %f1
	jmp	fjge_cont.51664
fjge_else.51663:
	fneg	%f0, %f1
fjge_cont.51664:
	fldi	%f1, %g5, 0
	fjlt	%f0, %f1, fjge_else.51665
	addi	%g8, %g0, 0
	jmp	fjge_cont.51666
fjge_else.51665:
	fldi	%f0, %g9, -4
	fmul	%f0, %f2, %f0
	fadd	%f1, %f0, %f7
	fjlt	%f1, %f16, fjge_else.51667
	fmov	%f0, %f1
	jmp	fjge_cont.51668
fjge_else.51667:
	fneg	%f0, %f1
fjge_cont.51668:
	fldi	%f1, %g5, -4
	fjlt	%f0, %f1, fjge_else.51669
	addi	%g8, %g0, 0
	jmp	fjge_cont.51670
fjge_else.51669:
	fsti	%f2, %g31, 520
	addi	%g8, %g0, 1
fjge_cont.51670:
fjge_cont.51666:
	jmp	fjne_cont.51658
fjne_else.51657:
	addi	%g8, %g0, 0
fjne_cont.51658:
	jne	%g8, %g0, jeq_else.51671
	addi	%g8, %g0, 0
	jmp	jeq_cont.51672
jeq_else.51671:
	addi	%g8, %g0, 3
jeq_cont.51672:
	jmp	jeq_cont.51656
jeq_else.51655:
	addi	%g8, %g0, 2
jeq_cont.51656:
	jmp	jeq_cont.51640
jeq_else.51639:
	addi	%g8, %g0, 1
jeq_cont.51640:
	jmp	jeq_cont.51624
jeq_else.51623:
	addi	%g8, %g0, 2
	jne	%g3, %g8, jeq_else.51673
	ldi	%g3, %g7, -16
	fldi	%f0, %g9, 0
	fldi	%f4, %g3, 0
	fmul	%f1, %f0, %f4
	fldi	%f0, %g9, -4
	fldi	%f3, %g3, -4
	fmul	%f0, %f0, %f3
	fadd	%f2, %f1, %f0
	fldi	%f0, %g9, -8
	fldi	%f1, %g3, -8
	fmul	%f0, %f0, %f1
	fadd	%f0, %f2, %f0
	fjlt	%f16, %f0, fjge_else.51675
	addi	%g8, %g0, 0
	jmp	fjge_cont.51676
fjge_else.51675:
	fmul	%f4, %f4, %f6
	fmul	%f2, %f3, %f7
	fadd	%f2, %f4, %f2
	fmul	%f1, %f1, %f5
	fadd	%f1, %f2, %f1
	fneg	%f1, %f1
	fdiv	%f0, %f1, %f0
	fsti	%f0, %g31, 520
	addi	%g8, %g0, 1
fjge_cont.51676:
	jmp	jeq_cont.51674
jeq_else.51673:
	fldi	%f1, %g9, 0
	fldi	%f2, %g9, -4
	fldi	%f0, %g9, -8
	fmul	%f3, %f1, %f1
	ldi	%g5, %g7, -16
	fldi	%f10, %g5, 0
	fmul	%f4, %f3, %f10
	fmul	%f3, %f2, %f2
	fldi	%f12, %g5, -4
	fmul	%f3, %f3, %f12
	fadd	%f4, %f4, %f3
	fmul	%f3, %f0, %f0
	fldi	%f11, %g5, -8
	fmul	%f3, %f3, %f11
	fadd	%f3, %f4, %f3
	ldi	%g6, %g7, -12
	jne	%g6, %g0, jeq_else.51677
	fmov	%f9, %f3
	jmp	jeq_cont.51678
jeq_else.51677:
	fmul	%f8, %f2, %f0
	ldi	%g5, %g7, -36
	fldi	%f4, %g5, 0
	fmul	%f4, %f8, %f4
	fadd	%f8, %f3, %f4
	fmul	%f4, %f0, %f1
	fldi	%f3, %g5, -4
	fmul	%f3, %f4, %f3
	fadd	%f8, %f8, %f3
	fmul	%f4, %f1, %f2
	fldi	%f3, %g5, -8
	fmul	%f9, %f4, %f3
	fadd	%f9, %f8, %f9
jeq_cont.51678:
	fjeq	%f9, %f16, fjne_else.51679
	fmul	%f3, %f1, %f6
	fmul	%f4, %f3, %f10
	fmul	%f3, %f2, %f7
	fmul	%f3, %f3, %f12
	fadd	%f4, %f4, %f3
	fmul	%f3, %f0, %f5
	fmul	%f3, %f3, %f11
	fadd	%f8, %f4, %f3
	jne	%g6, %g0, jeq_else.51681
	fmov	%f3, %f8
	jmp	jeq_cont.51682
jeq_else.51681:
	fmul	%f4, %f0, %f7
	fmul	%f3, %f2, %f5
	fadd	%f4, %f4, %f3
	ldi	%g5, %g7, -36
	fldi	%f3, %g5, 0
	fmul	%f4, %f4, %f3
	fmul	%f3, %f1, %f5
	fmul	%f0, %f0, %f6
	fadd	%f3, %f3, %f0
	fldi	%f0, %g5, -4
	fmul	%f0, %f3, %f0
	fadd	%f0, %f4, %f0
	fmul	%f3, %f1, %f7
	fmul	%f1, %f2, %f6
	fadd	%f2, %f3, %f1
	fldi	%f1, %g5, -8
	fmul	%f1, %f2, %f1
	fadd	%f0, %f0, %f1
	fmul	%f3, %f0, %f21
	fadd	%f3, %f8, %f3
jeq_cont.51682:
	fmul	%f0, %f6, %f6
	fmul	%f1, %f0, %f10
	fmul	%f0, %f7, %f7
	fmul	%f0, %f0, %f12
	fadd	%f1, %f1, %f0
	fmul	%f0, %f5, %f5
	fmul	%f0, %f0, %f11
	fadd	%f1, %f1, %f0
	jne	%g6, %g0, jeq_else.51683
	fmov	%f0, %f1
	jmp	jeq_cont.51684
jeq_else.51683:
	fmul	%f2, %f7, %f5
	ldi	%g5, %g7, -36
	fldi	%f0, %g5, 0
	fmul	%f0, %f2, %f0
	fadd	%f2, %f1, %f0
	fmul	%f1, %f5, %f6
	fldi	%f0, %g5, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fmul	%f1, %f6, %f7
	fldi	%f0, %g5, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
jeq_cont.51684:
	addi	%g5, %g0, 3
	jne	%g3, %g5, jeq_else.51685
	fsub	%f1, %f0, %f17
	jmp	jeq_cont.51686
jeq_else.51685:
	fmov	%f1, %f0
jeq_cont.51686:
	fmul	%f2, %f3, %f3
	fmul	%f0, %f9, %f1
	fsub	%f0, %f2, %f0
	fjlt	%f16, %f0, fjge_else.51687
	addi	%g8, %g0, 0
	jmp	fjge_cont.51688
fjge_else.51687:
	fsqrt	%f0, %f0
	ldi	%g3, %g7, -24
	jne	%g3, %g0, jeq_else.51689
	fneg	%f1, %f0
	jmp	jeq_cont.51690
jeq_else.51689:
	fmov	%f1, %f0
jeq_cont.51690:
	fsub	%f0, %f1, %f3
	fdiv	%f0, %f0, %f9
	fsti	%f0, %g31, 520
	addi	%g8, %g0, 1
fjge_cont.51688:
	jmp	fjne_cont.51680
fjne_else.51679:
	addi	%g8, %g0, 0
fjne_cont.51680:
jeq_cont.51674:
jeq_cont.51624:
	jne	%g8, %g0, jeq_else.51691
	slli	%g3, %g10, 2
	add	%g3, %g31, %g3
	ldi	%g3, %g3, 272
	ldi	%g3, %g3, -24
	jne	%g3, %g0, jeq_else.51692
	return
jeq_else.51692:
	addi	%g11, %g11, 1
	jmp	solve_each_element.2905
jeq_else.51691:
	fldi	%f0, %g31, 520
	sti	%g4, %g1, 0
	fjlt	%f16, %f0, fjge_else.51694
	jmp	fjge_cont.51695
fjge_else.51694:
	fldi	%f1, %g31, 528
	fjlt	%f0, %f1, fjge_else.51696
	jmp	fjge_cont.51697
fjge_else.51696:
	setL %g3, l.44447
	fldi	%f1, %g3, 0
	fadd	%f9, %f0, %f1
	fldi	%f0, %g9, 0
	fmul	%f1, %f0, %f9
	fldi	%f0, %g31, 624
	fadd	%f5, %f1, %f0
	fldi	%f0, %g9, -4
	fmul	%f1, %f0, %f9
	fldi	%f0, %g31, 620
	fadd	%f4, %f1, %f0
	fldi	%f0, %g9, -8
	fmul	%f1, %f0, %f9
	fldi	%f0, %g31, 616
	fadd	%f3, %f1, %f0
	ldi	%g5, %g4, 0
	fsti	%f3, %g1, 4
	fsti	%f4, %g1, 8
	fsti	%f5, %g1, 12
	jne	%g5, %g29, jeq_else.51698
	addi	%g3, %g0, 1
	jmp	jeq_cont.51699
jeq_else.51698:
	slli	%g3, %g5, 2
	add	%g3, %g31, %g3
	ldi	%g6, %g3, 272
	ldi	%g3, %g6, -20
	fldi	%f0, %g3, 0
	fsub	%f0, %f5, %f0
	fldi	%f1, %g3, -4
	fsub	%f2, %f4, %f1
	fldi	%f1, %g3, -8
	fsub	%f1, %f3, %f1
	ldi	%g5, %g6, -4
	jne	%g5, %g28, jeq_else.51700
	fjlt	%f0, %f16, fjge_else.51702
	fmov	%f6, %f0
	jmp	fjge_cont.51703
fjge_else.51702:
	fneg	%f6, %f0
fjge_cont.51703:
	ldi	%g3, %g6, -16
	fldi	%f0, %g3, 0
	fjlt	%f6, %f0, fjge_else.51704
	addi	%g5, %g0, 0
	jmp	fjge_cont.51705
fjge_else.51704:
	fjlt	%f2, %f16, fjge_else.51706
	fmov	%f0, %f2
	jmp	fjge_cont.51707
fjge_else.51706:
	fneg	%f0, %f2
fjge_cont.51707:
	fldi	%f2, %g3, -4
	fjlt	%f0, %f2, fjge_else.51708
	addi	%g5, %g0, 0
	jmp	fjge_cont.51709
fjge_else.51708:
	fjlt	%f1, %f16, fjge_else.51710
	fmov	%f0, %f1
	jmp	fjge_cont.51711
fjge_else.51710:
	fneg	%f0, %f1
fjge_cont.51711:
	fldi	%f1, %g3, -8
	fjlt	%f0, %f1, fjge_else.51712
	addi	%g5, %g0, 0
	jmp	fjge_cont.51713
fjge_else.51712:
	addi	%g5, %g0, 1
fjge_cont.51713:
fjge_cont.51709:
fjge_cont.51705:
	jne	%g5, %g0, jeq_else.51714
	ldi	%g3, %g6, -24
	jne	%g3, %g0, jeq_else.51716
	addi	%g3, %g0, 1
	jmp	jeq_cont.51717
jeq_else.51716:
	addi	%g3, %g0, 0
jeq_cont.51717:
	jmp	jeq_cont.51715
jeq_else.51714:
	ldi	%g3, %g6, -24
jeq_cont.51715:
	jmp	jeq_cont.51701
jeq_else.51700:
	addi	%g3, %g0, 2
	jne	%g5, %g3, jeq_else.51718
	ldi	%g3, %g6, -16
	fldi	%f6, %g3, 0
	fmul	%f6, %f6, %f0
	fldi	%f0, %g3, -4
	fmul	%f0, %f0, %f2
	fadd	%f2, %f6, %f0
	fldi	%f0, %g3, -8
	fmul	%f0, %f0, %f1
	fadd	%f0, %f2, %f0
	ldi	%g3, %g6, -24
	fjlt	%f0, %f16, fjge_else.51720
	addi	%g5, %g0, 0
	jmp	fjge_cont.51721
fjge_else.51720:
	addi	%g5, %g0, 1
fjge_cont.51721:
	jne	%g3, %g5, jeq_else.51722
	addi	%g3, %g0, 1
	jmp	jeq_cont.51723
jeq_else.51722:
	addi	%g3, %g0, 0
jeq_cont.51723:
	jmp	jeq_cont.51719
jeq_else.51718:
	fmul	%f7, %f0, %f0
	ldi	%g3, %g6, -16
	fldi	%f6, %g3, 0
	fmul	%f8, %f7, %f6
	fmul	%f7, %f2, %f2
	fldi	%f6, %g3, -4
	fmul	%f6, %f7, %f6
	fadd	%f8, %f8, %f6
	fmul	%f7, %f1, %f1
	fldi	%f6, %g3, -8
	fmul	%f6, %f7, %f6
	fadd	%f7, %f8, %f6
	ldi	%g3, %g6, -12
	jne	%g3, %g0, jeq_else.51724
	fmov	%f6, %f7
	jmp	jeq_cont.51725
jeq_else.51724:
	fmul	%f8, %f2, %f1
	ldi	%g3, %g6, -36
	fldi	%f6, %g3, 0
	fmul	%f6, %f8, %f6
	fadd	%f7, %f7, %f6
	fmul	%f6, %f1, %f0
	fldi	%f1, %g3, -4
	fmul	%f1, %f6, %f1
	fadd	%f7, %f7, %f1
	fmul	%f1, %f0, %f2
	fldi	%f0, %g3, -8
	fmul	%f6, %f1, %f0
	fadd	%f6, %f7, %f6
jeq_cont.51725:
	addi	%g3, %g0, 3
	jne	%g5, %g3, jeq_else.51726
	fsub	%f0, %f6, %f17
	jmp	jeq_cont.51727
jeq_else.51726:
	fmov	%f0, %f6
jeq_cont.51727:
	ldi	%g3, %g6, -24
	fjlt	%f0, %f16, fjge_else.51728
	addi	%g5, %g0, 0
	jmp	fjge_cont.51729
fjge_else.51728:
	addi	%g5, %g0, 1
fjge_cont.51729:
	jne	%g3, %g5, jeq_else.51730
	addi	%g3, %g0, 1
	jmp	jeq_cont.51731
jeq_else.51730:
	addi	%g3, %g0, 0
jeq_cont.51731:
jeq_cont.51719:
jeq_cont.51701:
	jne	%g3, %g0, jeq_else.51732
	addi	%g5, %g0, 1
	subi	%g1, %g1, 20
	call	check_all_inside.2890
	addi	%g1, %g1, 20
	jmp	jeq_cont.51733
jeq_else.51732:
	addi	%g3, %g0, 0
jeq_cont.51733:
jeq_cont.51699:
	jne	%g3, %g0, jeq_else.51734
	jmp	jeq_cont.51735
jeq_else.51734:
	fsti	%f9, %g31, 528
	fldi	%f5, %g1, 12
	fsti	%f5, %g31, 540
	fldi	%f4, %g1, 8
	fsti	%f4, %g31, 536
	fldi	%f3, %g1, 4
	fsti	%f3, %g31, 532
	sti	%g10, %g31, 544
	sti	%g8, %g31, 524
jeq_cont.51735:
fjge_cont.51697:
fjge_cont.51695:
	addi	%g11, %g11, 1
	ldi	%g4, %g1, 0
	jmp	solve_each_element.2905

!==============================
! args = [%g13, %g12, %g9]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f21, %f2, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
solve_one_or_network.2909:
	slli	%g3, %g13, 2
	ld	%g3, %g12, %g3
	jne	%g3, %g29, jeq_else.51736
	return
jeq_else.51736:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g11, %g0, 0
	sti	%g9, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	addi	%g13, %g13, 1
	slli	%g3, %g13, 2
	ld	%g3, %g12, %g3
	jne	%g3, %g29, jeq_else.51738
	return
jeq_else.51738:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g11, %g0, 0
	ldi	%g9, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	addi	%g13, %g13, 1
	slli	%g3, %g13, 2
	ld	%g3, %g12, %g3
	jne	%g3, %g29, jeq_else.51740
	return
jeq_else.51740:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g11, %g0, 0
	ldi	%g9, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	addi	%g13, %g13, 1
	slli	%g3, %g13, 2
	ld	%g3, %g12, %g3
	jne	%g3, %g29, jeq_else.51742
	return
jeq_else.51742:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g11, %g0, 0
	ldi	%g9, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	addi	%g13, %g13, 1
	slli	%g3, %g13, 2
	ld	%g3, %g12, %g3
	jne	%g3, %g29, jeq_else.51744
	return
jeq_else.51744:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g11, %g0, 0
	ldi	%g9, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	addi	%g13, %g13, 1
	slli	%g3, %g13, 2
	ld	%g3, %g12, %g3
	jne	%g3, %g29, jeq_else.51746
	return
jeq_else.51746:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g11, %g0, 0
	ldi	%g9, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	addi	%g13, %g13, 1
	slli	%g3, %g13, 2
	ld	%g3, %g12, %g3
	jne	%g3, %g29, jeq_else.51748
	return
jeq_else.51748:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g11, %g0, 0
	ldi	%g9, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	addi	%g13, %g13, 1
	slli	%g3, %g13, 2
	ld	%g3, %g12, %g3
	jne	%g3, %g29, jeq_else.51750
	return
jeq_else.51750:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g11, %g0, 0
	ldi	%g9, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	addi	%g13, %g13, 1
	ldi	%g9, %g1, 0
	jmp	solve_one_or_network.2909

!==============================
! args = [%g14, %g15, %g9]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f21, %f2, %f17, %f16, %f15, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
trace_or_matrix.2913:
	slli	%g3, %g14, 2
	ld	%g12, %g15, %g3
	ldi	%g3, %g12, 0
	jne	%g3, %g29, jeq_else.51752
	return
jeq_else.51752:
	addi	%g4, %g0, 99
	sti	%g9, %g1, 0
	jne	%g3, %g4, jeq_else.51754
	ldi	%g3, %g12, -4
	jne	%g3, %g29, jeq_else.51756
	jmp	jeq_cont.51757
jeq_else.51756:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g11, %g0, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	ldi	%g3, %g12, -8
	jne	%g3, %g29, jeq_else.51758
	jmp	jeq_cont.51759
jeq_else.51758:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g11, %g0, 0
	ldi	%g9, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	ldi	%g3, %g12, -12
	jne	%g3, %g29, jeq_else.51760
	jmp	jeq_cont.51761
jeq_else.51760:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g11, %g0, 0
	ldi	%g9, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	ldi	%g3, %g12, -16
	jne	%g3, %g29, jeq_else.51762
	jmp	jeq_cont.51763
jeq_else.51762:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g11, %g0, 0
	ldi	%g9, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	ldi	%g3, %g12, -20
	jne	%g3, %g29, jeq_else.51764
	jmp	jeq_cont.51765
jeq_else.51764:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g11, %g0, 0
	ldi	%g9, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	ldi	%g3, %g12, -24
	jne	%g3, %g29, jeq_else.51766
	jmp	jeq_cont.51767
jeq_else.51766:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g11, %g0, 0
	ldi	%g9, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	ldi	%g3, %g12, -28
	jne	%g3, %g29, jeq_else.51768
	jmp	jeq_cont.51769
jeq_else.51768:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g11, %g0, 0
	ldi	%g9, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	addi	%g13, %g0, 8
	ldi	%g9, %g1, 0
	subi	%g1, %g1, 8
	call	solve_one_or_network.2909
	addi	%g1, %g1, 8
jeq_cont.51769:
jeq_cont.51767:
jeq_cont.51765:
jeq_cont.51763:
jeq_cont.51761:
jeq_cont.51759:
jeq_cont.51757:
	jmp	jeq_cont.51755
jeq_else.51754:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g6, %g3, 272
	fldi	%f1, %g31, 624
	ldi	%g3, %g6, -20
	fldi	%f0, %g3, 0
	fsub	%f5, %f1, %f0
	fldi	%f1, %g31, 620
	fldi	%f0, %g3, -4
	fsub	%f6, %f1, %f0
	fldi	%f1, %g31, 616
	fldi	%f0, %g3, -8
	fsub	%f4, %f1, %f0
	ldi	%g4, %g6, -4
	jne	%g4, %g28, jeq_else.51770
	fldi	%f2, %g9, 0
	fjeq	%f2, %f16, fjne_else.51772
	ldi	%g4, %g6, -16
	ldi	%g3, %g6, -24
	fjlt	%f2, %f16, fjge_else.51774
	addi	%g5, %g0, 0
	jmp	fjge_cont.51775
fjge_else.51774:
	addi	%g5, %g0, 1
fjge_cont.51775:
	fldi	%f1, %g4, 0
	jne	%g3, %g5, jeq_else.51776
	fneg	%f0, %f1
	jmp	jeq_cont.51777
jeq_else.51776:
	fmov	%f0, %f1
jeq_cont.51777:
	fsub	%f0, %f0, %f5
	fdiv	%f2, %f0, %f2
	fldi	%f0, %g9, -4
	fmul	%f0, %f2, %f0
	fadd	%f1, %f0, %f6
	fjlt	%f1, %f16, fjge_else.51778
	fmov	%f0, %f1
	jmp	fjge_cont.51779
fjge_else.51778:
	fneg	%f0, %f1
fjge_cont.51779:
	fldi	%f1, %g4, -4
	fjlt	%f0, %f1, fjge_else.51780
	addi	%g3, %g0, 0
	jmp	fjge_cont.51781
fjge_else.51780:
	fldi	%f0, %g9, -8
	fmul	%f0, %f2, %f0
	fadd	%f1, %f0, %f4
	fjlt	%f1, %f16, fjge_else.51782
	fmov	%f0, %f1
	jmp	fjge_cont.51783
fjge_else.51782:
	fneg	%f0, %f1
fjge_cont.51783:
	fldi	%f1, %g4, -8
	fjlt	%f0, %f1, fjge_else.51784
	addi	%g3, %g0, 0
	jmp	fjge_cont.51785
fjge_else.51784:
	fsti	%f2, %g31, 520
	addi	%g3, %g0, 1
fjge_cont.51785:
fjge_cont.51781:
	jmp	fjne_cont.51773
fjne_else.51772:
	addi	%g3, %g0, 0
fjne_cont.51773:
	jne	%g3, %g0, jeq_else.51786
	fldi	%f2, %g9, -4
	fjeq	%f2, %f16, fjne_else.51788
	ldi	%g4, %g6, -16
	ldi	%g3, %g6, -24
	fjlt	%f2, %f16, fjge_else.51790
	addi	%g5, %g0, 0
	jmp	fjge_cont.51791
fjge_else.51790:
	addi	%g5, %g0, 1
fjge_cont.51791:
	fldi	%f1, %g4, -4
	jne	%g3, %g5, jeq_else.51792
	fneg	%f0, %f1
	jmp	jeq_cont.51793
jeq_else.51792:
	fmov	%f0, %f1
jeq_cont.51793:
	fsub	%f0, %f0, %f6
	fdiv	%f2, %f0, %f2
	fldi	%f0, %g9, -8
	fmul	%f0, %f2, %f0
	fadd	%f1, %f0, %f4
	fjlt	%f1, %f16, fjge_else.51794
	fmov	%f0, %f1
	jmp	fjge_cont.51795
fjge_else.51794:
	fneg	%f0, %f1
fjge_cont.51795:
	fldi	%f1, %g4, -8
	fjlt	%f0, %f1, fjge_else.51796
	addi	%g3, %g0, 0
	jmp	fjge_cont.51797
fjge_else.51796:
	fldi	%f0, %g9, 0
	fmul	%f0, %f2, %f0
	fadd	%f1, %f0, %f5
	fjlt	%f1, %f16, fjge_else.51798
	fmov	%f0, %f1
	jmp	fjge_cont.51799
fjge_else.51798:
	fneg	%f0, %f1
fjge_cont.51799:
	fldi	%f1, %g4, 0
	fjlt	%f0, %f1, fjge_else.51800
	addi	%g3, %g0, 0
	jmp	fjge_cont.51801
fjge_else.51800:
	fsti	%f2, %g31, 520
	addi	%g3, %g0, 1
fjge_cont.51801:
fjge_cont.51797:
	jmp	fjne_cont.51789
fjne_else.51788:
	addi	%g3, %g0, 0
fjne_cont.51789:
	jne	%g3, %g0, jeq_else.51802
	fldi	%f2, %g9, -8
	fjeq	%f2, %f16, fjne_else.51804
	ldi	%g4, %g6, -16
	ldi	%g3, %g6, -24
	fjlt	%f2, %f16, fjge_else.51806
	addi	%g5, %g0, 0
	jmp	fjge_cont.51807
fjge_else.51806:
	addi	%g5, %g0, 1
fjge_cont.51807:
	fldi	%f1, %g4, -8
	jne	%g3, %g5, jeq_else.51808
	fneg	%f0, %f1
	jmp	jeq_cont.51809
jeq_else.51808:
	fmov	%f0, %f1
jeq_cont.51809:
	fsub	%f0, %f0, %f4
	fdiv	%f2, %f0, %f2
	fldi	%f0, %g9, 0
	fmul	%f0, %f2, %f0
	fadd	%f1, %f0, %f5
	fjlt	%f1, %f16, fjge_else.51810
	fmov	%f0, %f1
	jmp	fjge_cont.51811
fjge_else.51810:
	fneg	%f0, %f1
fjge_cont.51811:
	fldi	%f1, %g4, 0
	fjlt	%f0, %f1, fjge_else.51812
	addi	%g3, %g0, 0
	jmp	fjge_cont.51813
fjge_else.51812:
	fldi	%f0, %g9, -4
	fmul	%f0, %f2, %f0
	fadd	%f1, %f0, %f6
	fjlt	%f1, %f16, fjge_else.51814
	fmov	%f0, %f1
	jmp	fjge_cont.51815
fjge_else.51814:
	fneg	%f0, %f1
fjge_cont.51815:
	fldi	%f1, %g4, -4
	fjlt	%f0, %f1, fjge_else.51816
	addi	%g3, %g0, 0
	jmp	fjge_cont.51817
fjge_else.51816:
	fsti	%f2, %g31, 520
	addi	%g3, %g0, 1
fjge_cont.51817:
fjge_cont.51813:
	jmp	fjne_cont.51805
fjne_else.51804:
	addi	%g3, %g0, 0
fjne_cont.51805:
	jne	%g3, %g0, jeq_else.51818
	addi	%g3, %g0, 0
	jmp	jeq_cont.51819
jeq_else.51818:
	addi	%g3, %g0, 3
jeq_cont.51819:
	jmp	jeq_cont.51803
jeq_else.51802:
	addi	%g3, %g0, 2
jeq_cont.51803:
	jmp	jeq_cont.51787
jeq_else.51786:
	addi	%g3, %g0, 1
jeq_cont.51787:
	jmp	jeq_cont.51771
jeq_else.51770:
	addi	%g3, %g0, 2
	jne	%g4, %g3, jeq_else.51820
	ldi	%g3, %g6, -16
	fldi	%f0, %g9, 0
	fldi	%f7, %g3, 0
	fmul	%f1, %f0, %f7
	fldi	%f0, %g9, -4
	fldi	%f3, %g3, -4
	fmul	%f0, %f0, %f3
	fadd	%f2, %f1, %f0
	fldi	%f0, %g9, -8
	fldi	%f1, %g3, -8
	fmul	%f0, %f0, %f1
	fadd	%f0, %f2, %f0
	fjlt	%f16, %f0, fjge_else.51822
	addi	%g3, %g0, 0
	jmp	fjge_cont.51823
fjge_else.51822:
	fmul	%f5, %f7, %f5
	fmul	%f2, %f3, %f6
	fadd	%f2, %f5, %f2
	fmul	%f1, %f1, %f4
	fadd	%f1, %f2, %f1
	fneg	%f1, %f1
	fdiv	%f0, %f1, %f0
	fsti	%f0, %g31, 520
	addi	%g3, %g0, 1
fjge_cont.51823:
	jmp	jeq_cont.51821
jeq_else.51820:
	fldi	%f1, %g9, 0
	fldi	%f2, %g9, -4
	fldi	%f0, %g9, -8
	fmul	%f3, %f1, %f1
	ldi	%g3, %g6, -16
	fldi	%f9, %g3, 0
	fmul	%f7, %f3, %f9
	fmul	%f3, %f2, %f2
	fldi	%f11, %g3, -4
	fmul	%f3, %f3, %f11
	fadd	%f7, %f7, %f3
	fmul	%f3, %f0, %f0
	fldi	%f10, %g3, -8
	fmul	%f3, %f3, %f10
	fadd	%f3, %f7, %f3
	ldi	%g5, %g6, -12
	jne	%g5, %g0, jeq_else.51824
	fmov	%f8, %f3
	jmp	jeq_cont.51825
jeq_else.51824:
	fmul	%f8, %f2, %f0
	ldi	%g3, %g6, -36
	fldi	%f7, %g3, 0
	fmul	%f7, %f8, %f7
	fadd	%f8, %f3, %f7
	fmul	%f7, %f0, %f1
	fldi	%f3, %g3, -4
	fmul	%f3, %f7, %f3
	fadd	%f12, %f8, %f3
	fmul	%f7, %f1, %f2
	fldi	%f3, %g3, -8
	fmul	%f8, %f7, %f3
	fadd	%f8, %f12, %f8
jeq_cont.51825:
	fjeq	%f8, %f16, fjne_else.51826
	fmul	%f3, %f1, %f5
	fmul	%f7, %f3, %f9
	fmul	%f3, %f2, %f6
	fmul	%f3, %f3, %f11
	fadd	%f7, %f7, %f3
	fmul	%f3, %f0, %f4
	fmul	%f3, %f3, %f10
	fadd	%f7, %f7, %f3
	jne	%g5, %g0, jeq_else.51828
	fmov	%f3, %f7
	jmp	jeq_cont.51829
jeq_else.51828:
	fmul	%f12, %f0, %f6
	fmul	%f3, %f2, %f4
	fadd	%f12, %f12, %f3
	ldi	%g3, %g6, -36
	fldi	%f3, %g3, 0
	fmul	%f3, %f12, %f3
	fmul	%f12, %f1, %f4
	fmul	%f0, %f0, %f5
	fadd	%f12, %f12, %f0
	fldi	%f0, %g3, -4
	fmul	%f0, %f12, %f0
	fadd	%f0, %f3, %f0
	fmul	%f3, %f1, %f6
	fmul	%f1, %f2, %f5
	fadd	%f2, %f3, %f1
	fldi	%f1, %g3, -8
	fmul	%f1, %f2, %f1
	fadd	%f0, %f0, %f1
	fmul	%f3, %f0, %f21
	fadd	%f3, %f7, %f3
jeq_cont.51829:
	fmul	%f0, %f5, %f5
	fmul	%f1, %f0, %f9
	fmul	%f0, %f6, %f6
	fmul	%f0, %f0, %f11
	fadd	%f1, %f1, %f0
	fmul	%f0, %f4, %f4
	fmul	%f0, %f0, %f10
	fadd	%f1, %f1, %f0
	jne	%g5, %g0, jeq_else.51830
	fmov	%f0, %f1
	jmp	jeq_cont.51831
jeq_else.51830:
	fmul	%f2, %f6, %f4
	ldi	%g3, %g6, -36
	fldi	%f0, %g3, 0
	fmul	%f0, %f2, %f0
	fadd	%f2, %f1, %f0
	fmul	%f1, %f4, %f5
	fldi	%f0, %g3, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fmul	%f1, %f5, %f6
	fldi	%f0, %g3, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
jeq_cont.51831:
	addi	%g3, %g0, 3
	jne	%g4, %g3, jeq_else.51832
	fsub	%f1, %f0, %f17
	jmp	jeq_cont.51833
jeq_else.51832:
	fmov	%f1, %f0
jeq_cont.51833:
	fmul	%f2, %f3, %f3
	fmul	%f0, %f8, %f1
	fsub	%f0, %f2, %f0
	fjlt	%f16, %f0, fjge_else.51834
	addi	%g3, %g0, 0
	jmp	fjge_cont.51835
fjge_else.51834:
	fsqrt	%f0, %f0
	ldi	%g3, %g6, -24
	jne	%g3, %g0, jeq_else.51836
	fneg	%f1, %f0
	jmp	jeq_cont.51837
jeq_else.51836:
	fmov	%f1, %f0
jeq_cont.51837:
	fsub	%f0, %f1, %f3
	fdiv	%f0, %f0, %f8
	fsti	%f0, %g31, 520
	addi	%g3, %g0, 1
fjge_cont.51835:
	jmp	fjne_cont.51827
fjne_else.51826:
	addi	%g3, %g0, 0
fjne_cont.51827:
jeq_cont.51821:
jeq_cont.51771:
	jne	%g3, %g0, jeq_else.51838
	jmp	jeq_cont.51839
jeq_else.51838:
	fldi	%f0, %g31, 520
	fldi	%f1, %g31, 528
	fjlt	%f0, %f1, fjge_else.51840
	jmp	fjge_cont.51841
fjge_else.51840:
	ldi	%g3, %g12, -4
	jne	%g3, %g29, jeq_else.51842
	jmp	jeq_cont.51843
jeq_else.51842:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g11, %g0, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	ldi	%g3, %g12, -8
	jne	%g3, %g29, jeq_else.51844
	jmp	jeq_cont.51845
jeq_else.51844:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g11, %g0, 0
	ldi	%g9, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	ldi	%g3, %g12, -12
	jne	%g3, %g29, jeq_else.51846
	jmp	jeq_cont.51847
jeq_else.51846:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g11, %g0, 0
	ldi	%g9, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	ldi	%g3, %g12, -16
	jne	%g3, %g29, jeq_else.51848
	jmp	jeq_cont.51849
jeq_else.51848:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g11, %g0, 0
	ldi	%g9, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	ldi	%g3, %g12, -20
	jne	%g3, %g29, jeq_else.51850
	jmp	jeq_cont.51851
jeq_else.51850:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g11, %g0, 0
	ldi	%g9, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	ldi	%g3, %g12, -24
	jne	%g3, %g29, jeq_else.51852
	jmp	jeq_cont.51853
jeq_else.51852:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g11, %g0, 0
	ldi	%g9, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	ldi	%g3, %g12, -28
	jne	%g3, %g29, jeq_else.51854
	jmp	jeq_cont.51855
jeq_else.51854:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g11, %g0, 0
	ldi	%g9, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	addi	%g13, %g0, 8
	ldi	%g9, %g1, 0
	subi	%g1, %g1, 8
	call	solve_one_or_network.2909
	addi	%g1, %g1, 8
jeq_cont.51855:
jeq_cont.51853:
jeq_cont.51851:
jeq_cont.51849:
jeq_cont.51847:
jeq_cont.51845:
jeq_cont.51843:
fjge_cont.51841:
jeq_cont.51839:
jeq_cont.51755:
	addi	%g14, %g14, 1
	ldi	%g9, %g1, 0
	jmp	trace_or_matrix.2913

!==============================
! args = [%g10, %g4, %g12, %g11]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
solve_each_element_fast.2919:
	slli	%g3, %g10, 2
	ld	%g9, %g4, %g3
	jne	%g9, %g29, jeq_else.51856
	return
jeq_else.51856:
	slli	%g3, %g9, 2
	add	%g3, %g31, %g3
	ldi	%g6, %g3, 272
	ldi	%g5, %g6, -40
	fldi	%f3, %g5, 0
	fldi	%f4, %g5, -4
	fldi	%f2, %g5, -8
	slli	%g3, %g9, 2
	ld	%g7, %g11, %g3
	ldi	%g3, %g6, -4
	jne	%g3, %g28, jeq_else.51858
	fldi	%f0, %g7, 0
	fsub	%f0, %f0, %f3
	fldi	%f1, %g7, -4
	fmul	%f0, %f0, %f1
	fldi	%f5, %g12, -4
	fmul	%f5, %f0, %f5
	fadd	%f6, %f5, %f4
	fjlt	%f6, %f16, fjge_else.51860
	fmov	%f5, %f6
	jmp	fjge_cont.51861
fjge_else.51860:
	fneg	%f5, %f6
fjge_cont.51861:
	ldi	%g3, %g6, -16
	fldi	%f6, %g3, -4
	fjlt	%f5, %f6, fjge_else.51862
	addi	%g8, %g0, 0
	jmp	fjge_cont.51863
fjge_else.51862:
	fldi	%f5, %g12, -8
	fmul	%f5, %f0, %f5
	fadd	%f6, %f5, %f2
	fjlt	%f6, %f16, fjge_else.51864
	fmov	%f5, %f6
	jmp	fjge_cont.51865
fjge_else.51864:
	fneg	%f5, %f6
fjge_cont.51865:
	fldi	%f6, %g3, -8
	fjlt	%f5, %f6, fjge_else.51866
	addi	%g8, %g0, 0
	jmp	fjge_cont.51867
fjge_else.51866:
	fjeq	%f1, %f16, fjne_else.51868
	addi	%g8, %g0, 1
	jmp	fjne_cont.51869
fjne_else.51868:
	addi	%g8, %g0, 0
fjne_cont.51869:
fjge_cont.51867:
fjge_cont.51863:
	jne	%g8, %g0, jeq_else.51870
	fldi	%f0, %g7, -8
	fsub	%f0, %f0, %f4
	fldi	%f1, %g7, -12
	fmul	%f0, %f0, %f1
	fldi	%f5, %g12, 0
	fmul	%f5, %f0, %f5
	fadd	%f6, %f5, %f3
	fjlt	%f6, %f16, fjge_else.51872
	fmov	%f5, %f6
	jmp	fjge_cont.51873
fjge_else.51872:
	fneg	%f5, %f6
fjge_cont.51873:
	fldi	%f6, %g3, 0
	fjlt	%f5, %f6, fjge_else.51874
	addi	%g8, %g0, 0
	jmp	fjge_cont.51875
fjge_else.51874:
	fldi	%f5, %g12, -8
	fmul	%f5, %f0, %f5
	fadd	%f6, %f5, %f2
	fjlt	%f6, %f16, fjge_else.51876
	fmov	%f5, %f6
	jmp	fjge_cont.51877
fjge_else.51876:
	fneg	%f5, %f6
fjge_cont.51877:
	fldi	%f6, %g3, -8
	fjlt	%f5, %f6, fjge_else.51878
	addi	%g8, %g0, 0
	jmp	fjge_cont.51879
fjge_else.51878:
	fjeq	%f1, %f16, fjne_else.51880
	addi	%g8, %g0, 1
	jmp	fjne_cont.51881
fjne_else.51880:
	addi	%g8, %g0, 0
fjne_cont.51881:
fjge_cont.51879:
fjge_cont.51875:
	jne	%g8, %g0, jeq_else.51882
	fldi	%f0, %g7, -16
	fsub	%f1, %f0, %f2
	fldi	%f0, %g7, -20
	fmul	%f5, %f1, %f0
	fldi	%f1, %g12, 0
	fmul	%f1, %f5, %f1
	fadd	%f2, %f1, %f3
	fjlt	%f2, %f16, fjge_else.51884
	fmov	%f1, %f2
	jmp	fjge_cont.51885
fjge_else.51884:
	fneg	%f1, %f2
fjge_cont.51885:
	fldi	%f2, %g3, 0
	fjlt	%f1, %f2, fjge_else.51886
	addi	%g8, %g0, 0
	jmp	fjge_cont.51887
fjge_else.51886:
	fldi	%f1, %g12, -4
	fmul	%f1, %f5, %f1
	fadd	%f2, %f1, %f4
	fjlt	%f2, %f16, fjge_else.51888
	fmov	%f1, %f2
	jmp	fjge_cont.51889
fjge_else.51888:
	fneg	%f1, %f2
fjge_cont.51889:
	fldi	%f2, %g3, -4
	fjlt	%f1, %f2, fjge_else.51890
	addi	%g8, %g0, 0
	jmp	fjge_cont.51891
fjge_else.51890:
	fjeq	%f0, %f16, fjne_else.51892
	addi	%g8, %g0, 1
	jmp	fjne_cont.51893
fjne_else.51892:
	addi	%g8, %g0, 0
fjne_cont.51893:
fjge_cont.51891:
fjge_cont.51887:
	jne	%g8, %g0, jeq_else.51894
	addi	%g8, %g0, 0
	jmp	jeq_cont.51895
jeq_else.51894:
	fsti	%f5, %g31, 520
	addi	%g8, %g0, 3
jeq_cont.51895:
	jmp	jeq_cont.51883
jeq_else.51882:
	fsti	%f0, %g31, 520
	addi	%g8, %g0, 2
jeq_cont.51883:
	jmp	jeq_cont.51871
jeq_else.51870:
	fsti	%f0, %g31, 520
	addi	%g8, %g0, 1
jeq_cont.51871:
	jmp	jeq_cont.51859
jeq_else.51858:
	addi	%g8, %g0, 2
	jne	%g3, %g8, jeq_else.51896
	fldi	%f1, %g7, 0
	fjlt	%f1, %f16, fjge_else.51898
	addi	%g8, %g0, 0
	jmp	fjge_cont.51899
fjge_else.51898:
	fldi	%f0, %g5, -12
	fmul	%f0, %f1, %f0
	fsti	%f0, %g31, 520
	addi	%g8, %g0, 1
fjge_cont.51899:
	jmp	jeq_cont.51897
jeq_else.51896:
	fldi	%f5, %g7, 0
	fjeq	%f5, %f16, fjne_else.51900
	fldi	%f0, %g7, -4
	fmul	%f1, %f0, %f3
	fldi	%f0, %g7, -8
	fmul	%f0, %f0, %f4
	fadd	%f1, %f1, %f0
	fldi	%f0, %g7, -12
	fmul	%f0, %f0, %f2
	fadd	%f1, %f1, %f0
	fldi	%f0, %g5, -12
	fmul	%f2, %f1, %f1
	fmul	%f0, %f5, %f0
	fsub	%f0, %f2, %f0
	fjlt	%f16, %f0, fjge_else.51902
	addi	%g8, %g0, 0
	jmp	fjge_cont.51903
fjge_else.51902:
	ldi	%g3, %g6, -24
	jne	%g3, %g0, jeq_else.51904
	fsqrt	%f0, %f0
	fsub	%f1, %f1, %f0
	fldi	%f0, %g7, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g31, 520
	jmp	jeq_cont.51905
jeq_else.51904:
	fsqrt	%f0, %f0
	fadd	%f1, %f1, %f0
	fldi	%f0, %g7, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g31, 520
jeq_cont.51905:
	addi	%g8, %g0, 1
fjge_cont.51903:
	jmp	fjne_cont.51901
fjne_else.51900:
	addi	%g8, %g0, 0
fjne_cont.51901:
jeq_cont.51897:
jeq_cont.51859:
	jne	%g8, %g0, jeq_else.51906
	slli	%g3, %g9, 2
	add	%g3, %g31, %g3
	ldi	%g3, %g3, 272
	ldi	%g3, %g3, -24
	jne	%g3, %g0, jeq_else.51907
	return
jeq_else.51907:
	addi	%g10, %g10, 1
	jmp	solve_each_element_fast.2919
jeq_else.51906:
	fldi	%f0, %g31, 520
	sti	%g4, %g1, 0
	fjlt	%f16, %f0, fjge_else.51909
	jmp	fjge_cont.51910
fjge_else.51909:
	fldi	%f1, %g31, 528
	fjlt	%f0, %f1, fjge_else.51911
	jmp	fjge_cont.51912
fjge_else.51911:
	setL %g3, l.44447
	fldi	%f1, %g3, 0
	fadd	%f9, %f0, %f1
	fldi	%f0, %g12, 0
	fmul	%f1, %f0, %f9
	fldi	%f0, %g31, 636
	fadd	%f5, %f1, %f0
	fldi	%f0, %g12, -4
	fmul	%f1, %f0, %f9
	fldi	%f0, %g31, 632
	fadd	%f4, %f1, %f0
	fldi	%f0, %g12, -8
	fmul	%f1, %f0, %f9
	fldi	%f0, %g31, 628
	fadd	%f3, %f1, %f0
	ldi	%g5, %g4, 0
	fsti	%f3, %g1, 4
	fsti	%f4, %g1, 8
	fsti	%f5, %g1, 12
	jne	%g5, %g29, jeq_else.51913
	addi	%g3, %g0, 1
	jmp	jeq_cont.51914
jeq_else.51913:
	slli	%g3, %g5, 2
	add	%g3, %g31, %g3
	ldi	%g6, %g3, 272
	ldi	%g3, %g6, -20
	fldi	%f0, %g3, 0
	fsub	%f0, %f5, %f0
	fldi	%f1, %g3, -4
	fsub	%f2, %f4, %f1
	fldi	%f1, %g3, -8
	fsub	%f1, %f3, %f1
	ldi	%g5, %g6, -4
	jne	%g5, %g28, jeq_else.51915
	fjlt	%f0, %f16, fjge_else.51917
	fmov	%f6, %f0
	jmp	fjge_cont.51918
fjge_else.51917:
	fneg	%f6, %f0
fjge_cont.51918:
	ldi	%g3, %g6, -16
	fldi	%f0, %g3, 0
	fjlt	%f6, %f0, fjge_else.51919
	addi	%g5, %g0, 0
	jmp	fjge_cont.51920
fjge_else.51919:
	fjlt	%f2, %f16, fjge_else.51921
	fmov	%f0, %f2
	jmp	fjge_cont.51922
fjge_else.51921:
	fneg	%f0, %f2
fjge_cont.51922:
	fldi	%f2, %g3, -4
	fjlt	%f0, %f2, fjge_else.51923
	addi	%g5, %g0, 0
	jmp	fjge_cont.51924
fjge_else.51923:
	fjlt	%f1, %f16, fjge_else.51925
	fmov	%f0, %f1
	jmp	fjge_cont.51926
fjge_else.51925:
	fneg	%f0, %f1
fjge_cont.51926:
	fldi	%f1, %g3, -8
	fjlt	%f0, %f1, fjge_else.51927
	addi	%g5, %g0, 0
	jmp	fjge_cont.51928
fjge_else.51927:
	addi	%g5, %g0, 1
fjge_cont.51928:
fjge_cont.51924:
fjge_cont.51920:
	jne	%g5, %g0, jeq_else.51929
	ldi	%g3, %g6, -24
	jne	%g3, %g0, jeq_else.51931
	addi	%g3, %g0, 1
	jmp	jeq_cont.51932
jeq_else.51931:
	addi	%g3, %g0, 0
jeq_cont.51932:
	jmp	jeq_cont.51930
jeq_else.51929:
	ldi	%g3, %g6, -24
jeq_cont.51930:
	jmp	jeq_cont.51916
jeq_else.51915:
	addi	%g3, %g0, 2
	jne	%g5, %g3, jeq_else.51933
	ldi	%g3, %g6, -16
	fldi	%f6, %g3, 0
	fmul	%f6, %f6, %f0
	fldi	%f0, %g3, -4
	fmul	%f0, %f0, %f2
	fadd	%f2, %f6, %f0
	fldi	%f0, %g3, -8
	fmul	%f0, %f0, %f1
	fadd	%f0, %f2, %f0
	ldi	%g3, %g6, -24
	fjlt	%f0, %f16, fjge_else.51935
	addi	%g5, %g0, 0
	jmp	fjge_cont.51936
fjge_else.51935:
	addi	%g5, %g0, 1
fjge_cont.51936:
	jne	%g3, %g5, jeq_else.51937
	addi	%g3, %g0, 1
	jmp	jeq_cont.51938
jeq_else.51937:
	addi	%g3, %g0, 0
jeq_cont.51938:
	jmp	jeq_cont.51934
jeq_else.51933:
	fmul	%f7, %f0, %f0
	ldi	%g3, %g6, -16
	fldi	%f6, %g3, 0
	fmul	%f8, %f7, %f6
	fmul	%f7, %f2, %f2
	fldi	%f6, %g3, -4
	fmul	%f6, %f7, %f6
	fadd	%f8, %f8, %f6
	fmul	%f7, %f1, %f1
	fldi	%f6, %g3, -8
	fmul	%f6, %f7, %f6
	fadd	%f7, %f8, %f6
	ldi	%g3, %g6, -12
	jne	%g3, %g0, jeq_else.51939
	fmov	%f6, %f7
	jmp	jeq_cont.51940
jeq_else.51939:
	fmul	%f8, %f2, %f1
	ldi	%g3, %g6, -36
	fldi	%f6, %g3, 0
	fmul	%f6, %f8, %f6
	fadd	%f7, %f7, %f6
	fmul	%f6, %f1, %f0
	fldi	%f1, %g3, -4
	fmul	%f1, %f6, %f1
	fadd	%f7, %f7, %f1
	fmul	%f1, %f0, %f2
	fldi	%f0, %g3, -8
	fmul	%f6, %f1, %f0
	fadd	%f6, %f7, %f6
jeq_cont.51940:
	addi	%g3, %g0, 3
	jne	%g5, %g3, jeq_else.51941
	fsub	%f0, %f6, %f17
	jmp	jeq_cont.51942
jeq_else.51941:
	fmov	%f0, %f6
jeq_cont.51942:
	ldi	%g3, %g6, -24
	fjlt	%f0, %f16, fjge_else.51943
	addi	%g5, %g0, 0
	jmp	fjge_cont.51944
fjge_else.51943:
	addi	%g5, %g0, 1
fjge_cont.51944:
	jne	%g3, %g5, jeq_else.51945
	addi	%g3, %g0, 1
	jmp	jeq_cont.51946
jeq_else.51945:
	addi	%g3, %g0, 0
jeq_cont.51946:
jeq_cont.51934:
jeq_cont.51916:
	jne	%g3, %g0, jeq_else.51947
	addi	%g5, %g0, 1
	subi	%g1, %g1, 20
	call	check_all_inside.2890
	addi	%g1, %g1, 20
	jmp	jeq_cont.51948
jeq_else.51947:
	addi	%g3, %g0, 0
jeq_cont.51948:
jeq_cont.51914:
	jne	%g3, %g0, jeq_else.51949
	jmp	jeq_cont.51950
jeq_else.51949:
	fsti	%f9, %g31, 528
	fldi	%f5, %g1, 12
	fsti	%f5, %g31, 540
	fldi	%f4, %g1, 8
	fsti	%f4, %g31, 536
	fldi	%f3, %g1, 4
	fsti	%f3, %g31, 532
	sti	%g9, %g31, 544
	sti	%g8, %g31, 524
jeq_cont.51950:
fjge_cont.51912:
fjge_cont.51910:
	addi	%g10, %g10, 1
	ldi	%g4, %g1, 0
	jmp	solve_each_element_fast.2919

!==============================
! args = [%g16, %g15, %g14, %g13]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
solve_one_or_network_fast.2923:
	slli	%g3, %g16, 2
	ld	%g3, %g15, %g3
	jne	%g3, %g29, jeq_else.51951
	return
jeq_else.51951:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g10, %g0, 0
	mov	%g11, %g13
	mov	%g12, %g14
	subi	%g1, %g1, 4
	call	solve_each_element_fast.2919
	addi	%g1, %g1, 4
	addi	%g16, %g16, 1
	slli	%g3, %g16, 2
	ld	%g3, %g15, %g3
	jne	%g3, %g29, jeq_else.51953
	return
jeq_else.51953:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g10, %g0, 0
	mov	%g11, %g13
	mov	%g12, %g14
	subi	%g1, %g1, 4
	call	solve_each_element_fast.2919
	addi	%g1, %g1, 4
	addi	%g16, %g16, 1
	slli	%g3, %g16, 2
	ld	%g3, %g15, %g3
	jne	%g3, %g29, jeq_else.51955
	return
jeq_else.51955:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g10, %g0, 0
	mov	%g11, %g13
	mov	%g12, %g14
	subi	%g1, %g1, 4
	call	solve_each_element_fast.2919
	addi	%g1, %g1, 4
	addi	%g16, %g16, 1
	slli	%g3, %g16, 2
	ld	%g3, %g15, %g3
	jne	%g3, %g29, jeq_else.51957
	return
jeq_else.51957:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g10, %g0, 0
	mov	%g11, %g13
	mov	%g12, %g14
	subi	%g1, %g1, 4
	call	solve_each_element_fast.2919
	addi	%g1, %g1, 4
	addi	%g16, %g16, 1
	slli	%g3, %g16, 2
	ld	%g3, %g15, %g3
	jne	%g3, %g29, jeq_else.51959
	return
jeq_else.51959:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g10, %g0, 0
	mov	%g11, %g13
	mov	%g12, %g14
	subi	%g1, %g1, 4
	call	solve_each_element_fast.2919
	addi	%g1, %g1, 4
	addi	%g16, %g16, 1
	slli	%g3, %g16, 2
	ld	%g3, %g15, %g3
	jne	%g3, %g29, jeq_else.51961
	return
jeq_else.51961:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g10, %g0, 0
	mov	%g11, %g13
	mov	%g12, %g14
	subi	%g1, %g1, 4
	call	solve_each_element_fast.2919
	addi	%g1, %g1, 4
	addi	%g16, %g16, 1
	slli	%g3, %g16, 2
	ld	%g3, %g15, %g3
	jne	%g3, %g29, jeq_else.51963
	return
jeq_else.51963:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g10, %g0, 0
	mov	%g11, %g13
	mov	%g12, %g14
	subi	%g1, %g1, 4
	call	solve_each_element_fast.2919
	addi	%g1, %g1, 4
	addi	%g16, %g16, 1
	slli	%g3, %g16, 2
	ld	%g3, %g15, %g3
	jne	%g3, %g29, jeq_else.51965
	return
jeq_else.51965:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g10, %g0, 0
	mov	%g11, %g13
	mov	%g12, %g14
	subi	%g1, %g1, 4
	call	solve_each_element_fast.2919
	addi	%g1, %g1, 4
	addi	%g16, %g16, 1
	jmp	solve_one_or_network_fast.2923

!==============================
! args = [%g19, %g20, %g18, %g17]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
trace_or_matrix_fast.2927:
	slli	%g3, %g19, 2
	ld	%g15, %g20, %g3
	ldi	%g3, %g15, 0
	jne	%g3, %g29, jeq_else.51967
	return
jeq_else.51967:
	addi	%g4, %g0, 99
	jne	%g3, %g4, jeq_else.51969
	ldi	%g3, %g15, -4
	jne	%g3, %g29, jeq_else.51971
	jmp	jeq_cont.51972
jeq_else.51971:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g10, %g0, 0
	mov	%g11, %g17
	mov	%g12, %g18
	subi	%g1, %g1, 4
	call	solve_each_element_fast.2919
	addi	%g1, %g1, 4
	ldi	%g3, %g15, -8
	jne	%g3, %g29, jeq_else.51973
	jmp	jeq_cont.51974
jeq_else.51973:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g10, %g0, 0
	mov	%g11, %g17
	mov	%g12, %g18
	subi	%g1, %g1, 4
	call	solve_each_element_fast.2919
	addi	%g1, %g1, 4
	ldi	%g3, %g15, -12
	jne	%g3, %g29, jeq_else.51975
	jmp	jeq_cont.51976
jeq_else.51975:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g10, %g0, 0
	mov	%g11, %g17
	mov	%g12, %g18
	subi	%g1, %g1, 4
	call	solve_each_element_fast.2919
	addi	%g1, %g1, 4
	ldi	%g3, %g15, -16
	jne	%g3, %g29, jeq_else.51977
	jmp	jeq_cont.51978
jeq_else.51977:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g10, %g0, 0
	mov	%g11, %g17
	mov	%g12, %g18
	subi	%g1, %g1, 4
	call	solve_each_element_fast.2919
	addi	%g1, %g1, 4
	ldi	%g3, %g15, -20
	jne	%g3, %g29, jeq_else.51979
	jmp	jeq_cont.51980
jeq_else.51979:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g10, %g0, 0
	mov	%g11, %g17
	mov	%g12, %g18
	subi	%g1, %g1, 4
	call	solve_each_element_fast.2919
	addi	%g1, %g1, 4
	ldi	%g3, %g15, -24
	jne	%g3, %g29, jeq_else.51981
	jmp	jeq_cont.51982
jeq_else.51981:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g10, %g0, 0
	mov	%g11, %g17
	mov	%g12, %g18
	subi	%g1, %g1, 4
	call	solve_each_element_fast.2919
	addi	%g1, %g1, 4
	ldi	%g3, %g15, -28
	jne	%g3, %g29, jeq_else.51983
	jmp	jeq_cont.51984
jeq_else.51983:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g10, %g0, 0
	mov	%g11, %g17
	mov	%g12, %g18
	subi	%g1, %g1, 4
	call	solve_each_element_fast.2919
	addi	%g16, %g0, 8
	mov	%g13, %g17
	mov	%g14, %g18
	call	solve_one_or_network_fast.2923
	addi	%g1, %g1, 4
jeq_cont.51984:
jeq_cont.51982:
jeq_cont.51980:
jeq_cont.51978:
jeq_cont.51976:
jeq_cont.51974:
jeq_cont.51972:
	jmp	jeq_cont.51970
jeq_else.51969:
	slli	%g4, %g3, 2
	add	%g4, %g31, %g4
	ldi	%g6, %g4, 272
	ldi	%g5, %g6, -40
	fldi	%f2, %g5, 0
	fldi	%f3, %g5, -4
	fldi	%f1, %g5, -8
	slli	%g3, %g3, 2
	ld	%g7, %g17, %g3
	ldi	%g4, %g6, -4
	jne	%g4, %g28, jeq_else.51985
	fldi	%f0, %g7, 0
	fsub	%f4, %f0, %f2
	fldi	%f0, %g7, -4
	fmul	%f6, %f4, %f0
	fldi	%f4, %g18, -4
	fmul	%f4, %f6, %f4
	fadd	%f5, %f4, %f3
	fjlt	%f5, %f16, fjge_else.51987
	fmov	%f4, %f5
	jmp	fjge_cont.51988
fjge_else.51987:
	fneg	%f4, %f5
fjge_cont.51988:
	ldi	%g4, %g6, -16
	fldi	%f5, %g4, -4
	fjlt	%f4, %f5, fjge_else.51989
	addi	%g3, %g0, 0
	jmp	fjge_cont.51990
fjge_else.51989:
	fldi	%f4, %g18, -8
	fmul	%f4, %f6, %f4
	fadd	%f5, %f4, %f1
	fjlt	%f5, %f16, fjge_else.51991
	fmov	%f4, %f5
	jmp	fjge_cont.51992
fjge_else.51991:
	fneg	%f4, %f5
fjge_cont.51992:
	fldi	%f5, %g4, -8
	fjlt	%f4, %f5, fjge_else.51993
	addi	%g3, %g0, 0
	jmp	fjge_cont.51994
fjge_else.51993:
	fjeq	%f0, %f16, fjne_else.51995
	addi	%g3, %g0, 1
	jmp	fjne_cont.51996
fjne_else.51995:
	addi	%g3, %g0, 0
fjne_cont.51996:
fjge_cont.51994:
fjge_cont.51990:
	jne	%g3, %g0, jeq_else.51997
	fldi	%f0, %g7, -8
	fsub	%f0, %f0, %f3
	fldi	%f6, %g7, -12
	fmul	%f5, %f0, %f6
	fldi	%f0, %g18, 0
	fmul	%f0, %f5, %f0
	fadd	%f4, %f0, %f2
	fjlt	%f4, %f16, fjge_else.51999
	fmov	%f0, %f4
	jmp	fjge_cont.52000
fjge_else.51999:
	fneg	%f0, %f4
fjge_cont.52000:
	fldi	%f4, %g4, 0
	fjlt	%f0, %f4, fjge_else.52001
	addi	%g3, %g0, 0
	jmp	fjge_cont.52002
fjge_else.52001:
	fldi	%f0, %g18, -8
	fmul	%f0, %f5, %f0
	fadd	%f4, %f0, %f1
	fjlt	%f4, %f16, fjge_else.52003
	fmov	%f0, %f4
	jmp	fjge_cont.52004
fjge_else.52003:
	fneg	%f0, %f4
fjge_cont.52004:
	fldi	%f4, %g4, -8
	fjlt	%f0, %f4, fjge_else.52005
	addi	%g3, %g0, 0
	jmp	fjge_cont.52006
fjge_else.52005:
	fjeq	%f6, %f16, fjne_else.52007
	addi	%g3, %g0, 1
	jmp	fjne_cont.52008
fjne_else.52007:
	addi	%g3, %g0, 0
fjne_cont.52008:
fjge_cont.52006:
fjge_cont.52002:
	jne	%g3, %g0, jeq_else.52009
	fldi	%f0, %g7, -16
	fsub	%f0, %f0, %f1
	fldi	%f5, %g7, -20
	fmul	%f4, %f0, %f5
	fldi	%f0, %g18, 0
	fmul	%f0, %f4, %f0
	fadd	%f1, %f0, %f2
	fjlt	%f1, %f16, fjge_else.52011
	fmov	%f0, %f1
	jmp	fjge_cont.52012
fjge_else.52011:
	fneg	%f0, %f1
fjge_cont.52012:
	fldi	%f1, %g4, 0
	fjlt	%f0, %f1, fjge_else.52013
	addi	%g3, %g0, 0
	jmp	fjge_cont.52014
fjge_else.52013:
	fldi	%f0, %g18, -4
	fmul	%f0, %f4, %f0
	fadd	%f1, %f0, %f3
	fjlt	%f1, %f16, fjge_else.52015
	fmov	%f0, %f1
	jmp	fjge_cont.52016
fjge_else.52015:
	fneg	%f0, %f1
fjge_cont.52016:
	fldi	%f1, %g4, -4
	fjlt	%f0, %f1, fjge_else.52017
	addi	%g3, %g0, 0
	jmp	fjge_cont.52018
fjge_else.52017:
	fjeq	%f5, %f16, fjne_else.52019
	addi	%g3, %g0, 1
	jmp	fjne_cont.52020
fjne_else.52019:
	addi	%g3, %g0, 0
fjne_cont.52020:
fjge_cont.52018:
fjge_cont.52014:
	jne	%g3, %g0, jeq_else.52021
	addi	%g3, %g0, 0
	jmp	jeq_cont.52022
jeq_else.52021:
	fsti	%f4, %g31, 520
	addi	%g3, %g0, 3
jeq_cont.52022:
	jmp	jeq_cont.52010
jeq_else.52009:
	fsti	%f5, %g31, 520
	addi	%g3, %g0, 2
jeq_cont.52010:
	jmp	jeq_cont.51998
jeq_else.51997:
	fsti	%f6, %g31, 520
	addi	%g3, %g0, 1
jeq_cont.51998:
	jmp	jeq_cont.51986
jeq_else.51985:
	addi	%g3, %g0, 2
	jne	%g4, %g3, jeq_else.52023
	fldi	%f1, %g7, 0
	fjlt	%f1, %f16, fjge_else.52025
	addi	%g3, %g0, 0
	jmp	fjge_cont.52026
fjge_else.52025:
	fldi	%f0, %g5, -12
	fmul	%f0, %f1, %f0
	fsti	%f0, %g31, 520
	addi	%g3, %g0, 1
fjge_cont.52026:
	jmp	jeq_cont.52024
jeq_else.52023:
	fldi	%f4, %g7, 0
	fjeq	%f4, %f16, fjne_else.52027
	fldi	%f0, %g7, -4
	fmul	%f2, %f0, %f2
	fldi	%f0, %g7, -8
	fmul	%f0, %f0, %f3
	fadd	%f2, %f2, %f0
	fldi	%f0, %g7, -12
	fmul	%f0, %f0, %f1
	fadd	%f1, %f2, %f0
	fldi	%f0, %g5, -12
	fmul	%f2, %f1, %f1
	fmul	%f0, %f4, %f0
	fsub	%f0, %f2, %f0
	fjlt	%f16, %f0, fjge_else.52029
	addi	%g3, %g0, 0
	jmp	fjge_cont.52030
fjge_else.52029:
	ldi	%g3, %g6, -24
	jne	%g3, %g0, jeq_else.52031
	fsqrt	%f0, %f0
	fsub	%f1, %f1, %f0
	fldi	%f0, %g7, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g31, 520
	jmp	jeq_cont.52032
jeq_else.52031:
	fsqrt	%f0, %f0
	fadd	%f1, %f1, %f0
	fldi	%f0, %g7, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g31, 520
jeq_cont.52032:
	addi	%g3, %g0, 1
fjge_cont.52030:
	jmp	fjne_cont.52028
fjne_else.52027:
	addi	%g3, %g0, 0
fjne_cont.52028:
jeq_cont.52024:
jeq_cont.51986:
	jne	%g3, %g0, jeq_else.52033
	jmp	jeq_cont.52034
jeq_else.52033:
	fldi	%f0, %g31, 520
	fldi	%f1, %g31, 528
	fjlt	%f0, %f1, fjge_else.52035
	jmp	fjge_cont.52036
fjge_else.52035:
	ldi	%g3, %g15, -4
	jne	%g3, %g29, jeq_else.52037
	jmp	jeq_cont.52038
jeq_else.52037:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g10, %g0, 0
	mov	%g11, %g17
	mov	%g12, %g18
	subi	%g1, %g1, 4
	call	solve_each_element_fast.2919
	addi	%g1, %g1, 4
	ldi	%g3, %g15, -8
	jne	%g3, %g29, jeq_else.52039
	jmp	jeq_cont.52040
jeq_else.52039:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g10, %g0, 0
	mov	%g11, %g17
	mov	%g12, %g18
	subi	%g1, %g1, 4
	call	solve_each_element_fast.2919
	addi	%g1, %g1, 4
	ldi	%g3, %g15, -12
	jne	%g3, %g29, jeq_else.52041
	jmp	jeq_cont.52042
jeq_else.52041:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g10, %g0, 0
	mov	%g11, %g17
	mov	%g12, %g18
	subi	%g1, %g1, 4
	call	solve_each_element_fast.2919
	addi	%g1, %g1, 4
	ldi	%g3, %g15, -16
	jne	%g3, %g29, jeq_else.52043
	jmp	jeq_cont.52044
jeq_else.52043:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g10, %g0, 0
	mov	%g11, %g17
	mov	%g12, %g18
	subi	%g1, %g1, 4
	call	solve_each_element_fast.2919
	addi	%g1, %g1, 4
	ldi	%g3, %g15, -20
	jne	%g3, %g29, jeq_else.52045
	jmp	jeq_cont.52046
jeq_else.52045:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g10, %g0, 0
	mov	%g11, %g17
	mov	%g12, %g18
	subi	%g1, %g1, 4
	call	solve_each_element_fast.2919
	addi	%g1, %g1, 4
	ldi	%g3, %g15, -24
	jne	%g3, %g29, jeq_else.52047
	jmp	jeq_cont.52048
jeq_else.52047:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g10, %g0, 0
	mov	%g11, %g17
	mov	%g12, %g18
	subi	%g1, %g1, 4
	call	solve_each_element_fast.2919
	addi	%g1, %g1, 4
	ldi	%g3, %g15, -28
	jne	%g3, %g29, jeq_else.52049
	jmp	jeq_cont.52050
jeq_else.52049:
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g4, %g3, 512
	addi	%g10, %g0, 0
	mov	%g11, %g17
	mov	%g12, %g18
	subi	%g1, %g1, 4
	call	solve_each_element_fast.2919
	addi	%g16, %g0, 8
	mov	%g13, %g17
	mov	%g14, %g18
	call	solve_one_or_network_fast.2923
	addi	%g1, %g1, 4
jeq_cont.52050:
jeq_cont.52048:
jeq_cont.52046:
jeq_cont.52044:
jeq_cont.52042:
jeq_cont.52040:
jeq_cont.52038:
fjge_cont.52036:
jeq_cont.52034:
jeq_cont.51970:
	addi	%g19, %g19, 1
	jmp	trace_or_matrix_fast.2927

!==============================
! args = [%g21, %g22]
! fargs = [%f11, %f10]
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f17, %f16, %f15, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
trace_reflections.2949:
	jlt	%g21, %g0, jge_else.52051
	slli	%g3, %g21, 2
	add	%g3, %g31, %g3
	ldi	%g23, %g3, 1716
	ldi	%g24, %g23, -4
	setL %g3, l.42627
	fldi	%f0, %g3, 0
	fsti	%f0, %g31, 528
	addi	%g19, %g0, 0
	ldi	%g20, %g31, 516
	ldi	%g17, %g24, -4
	ldi	%g18, %g24, 0
	subi	%g1, %g1, 4
	call	trace_or_matrix_fast.2927
	addi	%g1, %g1, 4
	fldi	%f0, %g31, 528
	setL %g3, l.44633
	fldi	%f1, %g3, 0
	fjlt	%f1, %f0, fjge_else.52052
	addi	%g3, %g0, 0
	jmp	fjge_cont.52053
fjge_else.52052:
	setL %g3, l.45368
	fldi	%f1, %g3, 0
	fjlt	%f0, %f1, fjge_else.52054
	addi	%g3, %g0, 0
	jmp	fjge_cont.52055
fjge_else.52054:
	addi	%g3, %g0, 1
fjge_cont.52055:
fjge_cont.52053:
	jne	%g3, %g0, jeq_else.52056
	jmp	jeq_cont.52057
jeq_else.52056:
	ldi	%g3, %g31, 544
	slli	%g4, %g3, 2
	ldi	%g3, %g31, 524
	add	%g3, %g4, %g3
	ldi	%g4, %g23, 0
	jne	%g3, %g4, jeq_else.52058
	addi	%g12, %g0, 0
	ldi	%g13, %g31, 516
	subi	%g1, %g1, 4
	call	shadow_check_one_or_matrix.2902
	addi	%g1, %g1, 4
	jne	%g3, %g0, jeq_else.52060
	ldi	%g3, %g24, 0
	fldi	%f0, %g31, 556
	fldi	%f2, %g3, 0
	fmul	%f1, %f0, %f2
	fldi	%f0, %g31, 552
	fldi	%f4, %g3, -4
	fmul	%f0, %f0, %f4
	fadd	%f1, %f1, %f0
	fldi	%f0, %g31, 548
	fldi	%f3, %g3, -8
	fmul	%f0, %f0, %f3
	fadd	%f1, %f1, %f0
	fldi	%f0, %g23, -8
	fmul	%f5, %f0, %f11
	fmul	%f1, %f5, %f1
	fldi	%f5, %g22, 0
	fmul	%f5, %f5, %f2
	fldi	%f2, %g22, -4
	fmul	%f2, %f2, %f4
	fadd	%f4, %f5, %f2
	fldi	%f2, %g22, -8
	fmul	%f2, %f2, %f3
	fadd	%f2, %f4, %f2
	fmul	%f0, %f0, %f2
	fjlt	%f16, %f1, fjge_else.52062
	jmp	fjge_cont.52063
fjge_else.52062:
	fldi	%f3, %g31, 592
	fldi	%f2, %g31, 568
	fmul	%f2, %f1, %f2
	fadd	%f2, %f3, %f2
	fsti	%f2, %g31, 592
	fldi	%f3, %g31, 588
	fldi	%f2, %g31, 564
	fmul	%f2, %f1, %f2
	fadd	%f2, %f3, %f2
	fsti	%f2, %g31, 588
	fldi	%f3, %g31, 584
	fldi	%f2, %g31, 560
	fmul	%f1, %f1, %f2
	fadd	%f1, %f3, %f1
	fsti	%f1, %g31, 584
fjge_cont.52063:
	fjlt	%f16, %f0, fjge_else.52064
	jmp	fjge_cont.52065
fjge_else.52064:
	fmul	%f0, %f0, %f0
	fmul	%f0, %f0, %f0
	fmul	%f0, %f0, %f10
	fldi	%f1, %g31, 592
	fadd	%f1, %f1, %f0
	fsti	%f1, %g31, 592
	fldi	%f1, %g31, 588
	fadd	%f1, %f1, %f0
	fsti	%f1, %g31, 588
	fldi	%f1, %g31, 584
	fadd	%f0, %f1, %f0
	fsti	%f0, %g31, 584
fjge_cont.52065:
	jmp	jeq_cont.52061
jeq_else.52060:
jeq_cont.52061:
	jmp	jeq_cont.52059
jeq_else.52058:
jeq_cont.52059:
jeq_cont.52057:
	subi	%g21, %g21, 1
	jmp	trace_reflections.2949
jge_else.52051:
	return

!==============================
! args = [%g25, %g22, %g24, %g20, %g19, %g18, %g17, %g23, %g21, %g16]
! fargs = [%f13, %f14]
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f29, %f28, %f27, %f26, %f25, %f24, %f23, %f22, %f21, %f20, %f2, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
trace_ray.2954:
	addi	%g3, %g0, 4
	jlt	%g3, %g25, jle_else.52067
	setL %g3, l.42627
	fldi	%f0, %g3, 0
	fsti	%f0, %g31, 528
	addi	%g14, %g0, 0
	ldi	%g15, %g31, 516
	mov	%g9, %g22
	subi	%g1, %g1, 4
	call	trace_or_matrix.2913
	addi	%g1, %g1, 4
	fldi	%f0, %g31, 528
	setL %g3, l.44633
	fldi	%f1, %g3, 0
	fjlt	%f1, %f0, fjge_else.52068
	addi	%g3, %g0, 0
	jmp	fjge_cont.52069
fjge_else.52068:
	setL %g3, l.45368
	fldi	%f1, %g3, 0
	fjlt	%f0, %f1, fjge_else.52070
	addi	%g3, %g0, 0
	jmp	fjge_cont.52071
fjge_else.52070:
	addi	%g3, %g0, 1
fjge_cont.52071:
fjge_cont.52069:
	jne	%g3, %g0, jeq_else.52072
	addi	%g4, %g0, -1
	slli	%g3, %g25, 2
	st	%g4, %g19, %g3
	jne	%g25, %g0, jeq_else.52073
	return
jeq_else.52073:
	fldi	%f1, %g22, 0
	fldi	%f0, %g31, 308
	fmul	%f2, %f1, %f0
	fldi	%f1, %g22, -4
	fldi	%f0, %g31, 304
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g22, -8
	fldi	%f0, %g31, 300
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fneg	%f0, %f0
	fjlt	%f16, %f0, fjge_else.52075
	return
fjge_else.52075:
	fmul	%f1, %f0, %f0
	fmul	%f0, %f1, %f0
	fmul	%f1, %f0, %f13
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
jeq_else.52072:
	ldi	%g7, %g31, 544
	slli	%g3, %g7, 2
	add	%g3, %g31, %g3
	ldi	%g3, %g3, 272
	ldi	%g30, %g3, -8
	ldi	%g26, %g3, -28
	fldi	%f0, %g26, 0
	fmul	%f11, %f0, %f13
	ldi	%g4, %g3, -4
	jne	%g4, %g28, jeq_else.52078
	ldi	%g4, %g31, 524
	fsti	%f16, %g31, 556
	fsti	%f16, %g31, 552
	fsti	%f16, %g31, 548
	subi	%g5, %g4, 1
	slli	%g4, %g5, 2
	fld	%f1, %g22, %g4
	fjeq	%f1, %f16, fjne_else.52080
	fjlt	%f16, %f1, fjge_else.52082
	setL %g4, l.43888
	fldi	%f0, %g4, 0
	jmp	fjge_cont.52083
fjge_else.52082:
	setL %g4, l.42861
	fldi	%f0, %g4, 0
fjge_cont.52083:
	jmp	fjne_cont.52081
fjne_else.52080:
	fmov	%f0, %f16
fjne_cont.52081:
	fneg	%f0, %f0
	slli	%g4, %g5, 2
	add	%g4, %g31, %g4
	fsti	%f0, %g4, 556
	jmp	jeq_cont.52079
jeq_else.52078:
	addi	%g5, %g0, 2
	jne	%g4, %g5, jeq_else.52084
	ldi	%g4, %g3, -16
	fldi	%f0, %g4, 0
	fneg	%f0, %f0
	fsti	%f0, %g31, 556
	fldi	%f0, %g4, -4
	fneg	%f0, %f0
	fsti	%f0, %g31, 552
	fldi	%f0, %g4, -8
	fneg	%f0, %f0
	fsti	%f0, %g31, 548
	jmp	jeq_cont.52085
jeq_else.52084:
	fldi	%f1, %g31, 540
	ldi	%g4, %g3, -20
	fldi	%f0, %g4, 0
	fsub	%f4, %f1, %f0
	fldi	%f1, %g31, 536
	fldi	%f0, %g4, -4
	fsub	%f3, %f1, %f0
	fldi	%f1, %g31, 532
	fldi	%f0, %g4, -8
	fsub	%f0, %f1, %f0
	ldi	%g4, %g3, -16
	fldi	%f1, %g4, 0
	fmul	%f1, %f4, %f1
	fldi	%f2, %g4, -4
	fmul	%f5, %f3, %f2
	fldi	%f2, %g4, -8
	fmul	%f7, %f0, %f2
	ldi	%g4, %g3, -12
	jne	%g4, %g0, jeq_else.52086
	fsti	%f1, %g31, 556
	fsti	%f5, %g31, 552
	fsti	%f7, %g31, 548
	jmp	jeq_cont.52087
jeq_else.52086:
	ldi	%g4, %g3, -36
	fldi	%f2, %g4, -8
	fmul	%f6, %f3, %f2
	fldi	%f2, %g4, -4
	fmul	%f2, %f0, %f2
	fadd	%f2, %f6, %f2
	fmul	%f2, %f2, %f21
	fadd	%f1, %f1, %f2
	fsti	%f1, %g31, 556
	fldi	%f1, %g4, -8
	fmul	%f2, %f4, %f1
	fldi	%f1, %g4, 0
	fmul	%f0, %f0, %f1
	fadd	%f0, %f2, %f0
	fmul	%f0, %f0, %f21
	fadd	%f0, %f5, %f0
	fsti	%f0, %g31, 552
	fldi	%f0, %g4, -4
	fmul	%f1, %f4, %f0
	fldi	%f0, %g4, 0
	fmul	%f0, %f3, %f0
	fadd	%f0, %f1, %f0
	fmul	%f0, %f0, %f21
	fadd	%f0, %f7, %f0
	fsti	%f0, %g31, 548
jeq_cont.52087:
	ldi	%g4, %g3, -24
	fldi	%f2, %g31, 556
	fmul	%f1, %f2, %f2
	fldi	%f0, %g31, 552
	fmul	%f0, %f0, %f0
	fadd	%f1, %f1, %f0
	fldi	%f0, %g31, 548
	fmul	%f0, %f0, %f0
	fadd	%f0, %f1, %f0
	fsqrt	%f1, %f0
	fjeq	%f1, %f16, fjne_else.52088
	jne	%g4, %g0, jeq_else.52090
	fdiv	%f0, %f17, %f1
	jmp	jeq_cont.52091
jeq_else.52090:
	fdiv	%f0, %f20, %f1
jeq_cont.52091:
	jmp	fjne_cont.52089
fjne_else.52088:
	setL %g4, l.42861
	fldi	%f0, %g4, 0
fjne_cont.52089:
	fmul	%f1, %f2, %f0
	fsti	%f1, %g31, 556
	fldi	%f1, %g31, 552
	fmul	%f1, %f1, %f0
	fsti	%f1, %g31, 552
	fldi	%f1, %g31, 548
	fmul	%f0, %f1, %f0
	fsti	%f0, %g31, 548
jeq_cont.52085:
jeq_cont.52079:
	fldi	%f0, %g31, 540
	fsti	%f0, %g31, 624
	fldi	%f0, %g31, 536
	fsti	%f0, %g31, 620
	fldi	%f0, %g31, 532
	fsti	%f0, %g31, 616
	ldi	%g4, %g3, 0
	ldi	%g5, %g3, -32
	fldi	%f0, %g5, 0
	fsti	%f0, %g31, 568
	fldi	%f0, %g5, -4
	fsti	%f0, %g31, 564
	fldi	%f0, %g5, -8
	fsti	%f0, %g31, 560
	jne	%g4, %g28, jeq_else.52092
	fldi	%f1, %g31, 540
	ldi	%g5, %g3, -20
	fldi	%f0, %g5, 0
	fsub	%f5, %f1, %f0
	setL %g3, l.45673
	fldi	%f9, %g3, 0
	fmul	%f0, %f5, %f9
	subi	%g1, %g1, 4
	call	min_caml_floor
	setL %g3, l.45675
	fldi	%f6, %g3, 0
	fmul	%f0, %f0, %f6
	fsub	%f8, %f5, %f0
	setL %g3, l.45634
	fldi	%f5, %g3, 0
	fldi	%f1, %g31, 532
	fldi	%f0, %g5, -8
	fsub	%f7, %f1, %f0
	fmul	%f0, %f7, %f9
	call	min_caml_floor
	addi	%g1, %g1, 4
	fmul	%f0, %f0, %f6
	fsub	%f1, %f7, %f0
	fjlt	%f8, %f5, fjge_else.52094
	fjlt	%f1, %f5, fjge_else.52096
	setL %g3, l.42623
	fldi	%f0, %g3, 0
	jmp	fjge_cont.52097
fjge_else.52096:
	setL %g3, l.42609
	fldi	%f0, %g3, 0
fjge_cont.52097:
	jmp	fjge_cont.52095
fjge_else.52094:
	fjlt	%f1, %f5, fjge_else.52098
	setL %g3, l.42609
	fldi	%f0, %g3, 0
	jmp	fjge_cont.52099
fjge_else.52098:
	setL %g3, l.42623
	fldi	%f0, %g3, 0
fjge_cont.52099:
fjge_cont.52095:
	fsti	%f0, %g31, 564
	jmp	jeq_cont.52093
jeq_else.52092:
	addi	%g5, %g0, 2
	jne	%g4, %g5, jeq_else.52100
	fldi	%f1, %g31, 536
	setL %g3, l.45653
	fldi	%f0, %g3, 0
	fmul	%f2, %f1, %f0
	setL %g3, l.42599
	fldi	%f3, %g3, 0
	setL %g3, l.42601
	fldi	%f4, %g3, 0
	fjlt	%f2, %f16, fjge_else.52102
	fmov	%f1, %f2
	jmp	fjge_cont.52103
fjge_else.52102:
	fneg	%f1, %f2
fjge_cont.52103:
	fjlt	%f29, %f1, fjge_else.52104
	fjlt	%f1, %f16, fjge_else.52106
	fmov	%f0, %f1
	jmp	fjge_cont.52107
fjge_else.52106:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52108
	fjlt	%f1, %f16, fjge_else.52110
	fmov	%f0, %f1
	jmp	fjge_cont.52111
fjge_else.52110:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52112
	fjlt	%f1, %f16, fjge_else.52114
	fmov	%f0, %f1
	jmp	fjge_cont.52115
fjge_else.52114:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.52115:
	jmp	fjge_cont.52113
fjge_else.52112:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.52113:
fjge_cont.52111:
	jmp	fjge_cont.52109
fjge_else.52108:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52116
	fjlt	%f1, %f16, fjge_else.52118
	fmov	%f0, %f1
	jmp	fjge_cont.52119
fjge_else.52118:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.52119:
	jmp	fjge_cont.52117
fjge_else.52116:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.52117:
fjge_cont.52109:
fjge_cont.52107:
	jmp	fjge_cont.52105
fjge_else.52104:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52120
	fjlt	%f1, %f16, fjge_else.52122
	fmov	%f0, %f1
	jmp	fjge_cont.52123
fjge_else.52122:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52124
	fjlt	%f1, %f16, fjge_else.52126
	fmov	%f0, %f1
	jmp	fjge_cont.52127
fjge_else.52126:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.52127:
	jmp	fjge_cont.52125
fjge_else.52124:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.52125:
fjge_cont.52123:
	jmp	fjge_cont.52121
fjge_else.52120:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52128
	fjlt	%f1, %f16, fjge_else.52130
	fmov	%f0, %f1
	jmp	fjge_cont.52131
fjge_else.52130:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.52131:
	jmp	fjge_cont.52129
fjge_else.52128:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.52129:
fjge_cont.52121:
fjge_cont.52105:
	fjlt	%f3, %f0, fjge_else.52132
	fjlt	%f16, %f2, fjge_else.52134
	addi	%g3, %g0, 0
	jmp	fjge_cont.52135
fjge_else.52134:
	addi	%g3, %g0, 1
fjge_cont.52135:
	jmp	fjge_cont.52133
fjge_else.52132:
	fjlt	%f16, %f2, fjge_else.52136
	addi	%g3, %g0, 1
	jmp	fjge_cont.52137
fjge_else.52136:
	addi	%g3, %g0, 0
fjge_cont.52137:
fjge_cont.52133:
	fjlt	%f3, %f0, fjge_else.52138
	fmov	%f1, %f0
	jmp	fjge_cont.52139
fjge_else.52138:
	fsub	%f1, %f29, %f0
fjge_cont.52139:
	fjlt	%f22, %f1, fjge_else.52140
	fmov	%f0, %f1
	jmp	fjge_cont.52141
fjge_else.52140:
	fsub	%f0, %f3, %f1
fjge_cont.52141:
	fmul	%f1, %f0, %f21
	fmul	%f0, %f1, %f1
	fdiv	%f2, %f0, %f25
	fsub	%f2, %f26, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f24, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f23, %f2
	fdiv	%f0, %f0, %f2
	fsub	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	fmul	%f1, %f4, %f0
	fmul	%f0, %f0, %f0
	fadd	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	jne	%g3, %g0, jeq_else.52142
	fneg	%f1, %f0
	jmp	jeq_cont.52143
jeq_else.52142:
	fmov	%f1, %f0
jeq_cont.52143:
	fmul	%f0, %f1, %f1
	fmul	%f1, %f27, %f0
	fsti	%f1, %g31, 568
	fsub	%f0, %f17, %f0
	fmul	%f0, %f27, %f0
	fsti	%f0, %g31, 564
	jmp	jeq_cont.52101
jeq_else.52100:
	addi	%g5, %g0, 3
	jne	%g4, %g5, jeq_else.52144
	fldi	%f1, %g31, 540
	ldi	%g3, %g3, -20
	fldi	%f0, %g3, 0
	fsub	%f0, %f1, %f0
	fldi	%f2, %g31, 532
	fldi	%f1, %g3, -8
	fsub	%f1, %f2, %f1
	fmul	%f0, %f0, %f0
	fmul	%f1, %f1, %f1
	fadd	%f0, %f0, %f1
	fsqrt	%f0, %f0
	setL %g3, l.45634
	fldi	%f1, %g3, 0
	fdiv	%f0, %f0, %f1
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	min_caml_floor
	addi	%g1, %g1, 8
	fmov	%f1, %f0
	fldi	%f0, %g1, 0
	fsub	%f0, %f0, %f1
	fmul	%f0, %f0, %f30
	fsub	%f2, %f22, %f0
	setL %g3, l.42599
	fldi	%f3, %g3, 0
	setL %g3, l.42601
	fldi	%f4, %g3, 0
	fjlt	%f2, %f16, fjge_else.52146
	fmov	%f1, %f2
	jmp	fjge_cont.52147
fjge_else.52146:
	fneg	%f1, %f2
fjge_cont.52147:
	fjlt	%f29, %f1, fjge_else.52148
	fjlt	%f1, %f16, fjge_else.52150
	fmov	%f0, %f1
	jmp	fjge_cont.52151
fjge_else.52150:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52152
	fjlt	%f1, %f16, fjge_else.52154
	fmov	%f0, %f1
	jmp	fjge_cont.52155
fjge_else.52154:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52156
	fjlt	%f1, %f16, fjge_else.52158
	fmov	%f0, %f1
	jmp	fjge_cont.52159
fjge_else.52158:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.52159:
	jmp	fjge_cont.52157
fjge_else.52156:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.52157:
fjge_cont.52155:
	jmp	fjge_cont.52153
fjge_else.52152:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52160
	fjlt	%f1, %f16, fjge_else.52162
	fmov	%f0, %f1
	jmp	fjge_cont.52163
fjge_else.52162:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.52163:
	jmp	fjge_cont.52161
fjge_else.52160:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.52161:
fjge_cont.52153:
fjge_cont.52151:
	jmp	fjge_cont.52149
fjge_else.52148:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52164
	fjlt	%f1, %f16, fjge_else.52166
	fmov	%f0, %f1
	jmp	fjge_cont.52167
fjge_else.52166:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52168
	fjlt	%f1, %f16, fjge_else.52170
	fmov	%f0, %f1
	jmp	fjge_cont.52171
fjge_else.52170:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.52171:
	jmp	fjge_cont.52169
fjge_else.52168:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.52169:
fjge_cont.52167:
	jmp	fjge_cont.52165
fjge_else.52164:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52172
	fjlt	%f1, %f16, fjge_else.52174
	fmov	%f0, %f1
	jmp	fjge_cont.52175
fjge_else.52174:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.52175:
	jmp	fjge_cont.52173
fjge_else.52172:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.52173:
fjge_cont.52165:
fjge_cont.52149:
	fjlt	%f3, %f0, fjge_else.52176
	fjlt	%f16, %f2, fjge_else.52178
	addi	%g3, %g0, 0
	jmp	fjge_cont.52179
fjge_else.52178:
	addi	%g3, %g0, 1
fjge_cont.52179:
	jmp	fjge_cont.52177
fjge_else.52176:
	fjlt	%f16, %f2, fjge_else.52180
	addi	%g3, %g0, 1
	jmp	fjge_cont.52181
fjge_else.52180:
	addi	%g3, %g0, 0
fjge_cont.52181:
fjge_cont.52177:
	fjlt	%f3, %f0, fjge_else.52182
	fmov	%f1, %f0
	jmp	fjge_cont.52183
fjge_else.52182:
	fsub	%f1, %f29, %f0
fjge_cont.52183:
	fjlt	%f22, %f1, fjge_else.52184
	fmov	%f0, %f1
	jmp	fjge_cont.52185
fjge_else.52184:
	fsub	%f0, %f3, %f1
fjge_cont.52185:
	fmul	%f1, %f0, %f21
	fmul	%f0, %f1, %f1
	fdiv	%f2, %f0, %f25
	fsub	%f2, %f26, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f24, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f23, %f2
	fdiv	%f0, %f0, %f2
	fsub	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	fmul	%f1, %f4, %f0
	fmul	%f0, %f0, %f0
	fadd	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	jne	%g3, %g0, jeq_else.52186
	fneg	%f1, %f0
	jmp	jeq_cont.52187
jeq_else.52186:
	fmov	%f1, %f0
jeq_cont.52187:
	fmul	%f0, %f1, %f1
	fmul	%f1, %f0, %f27
	fsti	%f1, %g31, 564
	fsub	%f0, %f17, %f0
	fmul	%f0, %f0, %f27
	fsti	%f0, %g31, 560
	jmp	jeq_cont.52145
jeq_else.52144:
	addi	%g5, %g0, 4
	jne	%g4, %g5, jeq_else.52188
	fldi	%f1, %g31, 540
	ldi	%g6, %g3, -20
	fldi	%f0, %g6, 0
	fsub	%f1, %f1, %f0
	ldi	%g5, %g3, -16
	fldi	%f0, %g5, 0
	fsqrt	%f0, %f0
	fmul	%f1, %f1, %f0
	fldi	%f2, %g31, 532
	fldi	%f0, %g6, -8
	fsub	%f2, %f2, %f0
	fldi	%f0, %g5, -8
	fsqrt	%f0, %f0
	fmul	%f2, %f2, %f0
	fmul	%f3, %f1, %f1
	fmul	%f0, %f2, %f2
	fadd	%f5, %f3, %f0
	fjlt	%f1, %f16, fjge_else.52190
	fmov	%f0, %f1
	jmp	fjge_cont.52191
fjge_else.52190:
	fneg	%f0, %f1
fjge_cont.52191:
	setL %g3, l.45538
	fldi	%f6, %g3, 0
	fjlt	%f0, %f6, fjge_else.52192
	fdiv	%f1, %f2, %f1
	fjlt	%f1, %f16, fjge_else.52194
	fmov	%f0, %f1
	jmp	fjge_cont.52195
fjge_else.52194:
	fneg	%f0, %f1
fjge_cont.52195:
	fjlt	%f17, %f0, fjge_else.52196
	fjlt	%f0, %f20, fjge_else.52198
	addi	%g3, %g0, 0
	jmp	fjge_cont.52199
fjge_else.52198:
	addi	%g3, %g0, -1
fjge_cont.52199:
	jmp	fjge_cont.52197
fjge_else.52196:
	addi	%g3, %g0, 1
fjge_cont.52197:
	jne	%g3, %g0, jeq_else.52200
	fmov	%f3, %f0
	jmp	jeq_cont.52201
jeq_else.52200:
	fdiv	%f3, %f17, %f0
jeq_cont.52201:
	fmul	%f0, %f3, %f3
	setL %g4, l.45544
	fldi	%f1, %g4, 0
	fmul	%f2, %f1, %f0
	setL %g4, l.45546
	fldi	%f1, %g4, 0
	fdiv	%f2, %f2, %f1
	setL %g4, l.45548
	fldi	%f1, %g4, 0
	fmul	%f4, %f1, %f0
	setL %g4, l.45550
	fldi	%f1, %g4, 0
	fadd	%f1, %f1, %f2
	fdiv	%f2, %f4, %f1
	setL %g4, l.45552
	fldi	%f1, %g4, 0
	fmul	%f4, %f1, %f0
	setL %g4, l.45554
	fldi	%f1, %g4, 0
	fadd	%f1, %f1, %f2
	fdiv	%f2, %f4, %f1
	setL %g4, l.45556
	fldi	%f1, %g4, 0
	fmul	%f4, %f1, %f0
	setL %g4, l.45558
	fldi	%f1, %g4, 0
	fadd	%f1, %f1, %f2
	fdiv	%f2, %f4, %f1
	setL %g4, l.45560
	fldi	%f1, %g4, 0
	fmul	%f4, %f1, %f0
	fadd	%f1, %f28, %f2
	fdiv	%f2, %f4, %f1
	setL %g4, l.45563
	fldi	%f1, %g4, 0
	fmul	%f4, %f1, %f0
	setL %g4, l.45565
	fldi	%f1, %g4, 0
	fadd	%f1, %f1, %f2
	fdiv	%f2, %f4, %f1
	setL %g4, l.45567
	fldi	%f1, %g4, 0
	fmul	%f4, %f1, %f0
	setL %g4, l.45569
	fldi	%f1, %g4, 0
	fadd	%f1, %f1, %f2
	fdiv	%f2, %f4, %f1
	setL %g4, l.45571
	fldi	%f1, %g4, 0
	fmul	%f4, %f1, %f0
	fadd	%f1, %f25, %f2
	fdiv	%f1, %f4, %f1
	fmul	%f2, %f25, %f0
	fadd	%f1, %f26, %f1
	fdiv	%f2, %f2, %f1
	setL %g4, l.45575
	fldi	%f1, %g4, 0
	fmul	%f4, %f1, %f0
	fadd	%f1, %f24, %f2
	fdiv	%f1, %f4, %f1
	fadd	%f1, %f23, %f1
	fdiv	%f0, %f0, %f1
	fadd	%f0, %f17, %f0
	fdiv	%f1, %f3, %f0
	jlt	%g0, %g3, jle_else.52202
	jlt	%g3, %g0, jge_else.52204
	fmov	%f0, %f1
	jmp	jge_cont.52205
jge_else.52204:
	fsub	%f0, %f31, %f1
jge_cont.52205:
	jmp	jle_cont.52203
jle_else.52202:
	fsub	%f0, %f22, %f1
jle_cont.52203:
	setL %g3, l.45582
	fldi	%f1, %g3, 0
	fmul	%f0, %f0, %f1
	fdiv	%f0, %f0, %f30
	jmp	fjge_cont.52193
fjge_else.52192:
	setL %g3, l.45540
	fldi	%f0, %g3, 0
fjge_cont.52193:
	fsti	%f0, %g1, 4
	subi	%g1, %g1, 12
	call	min_caml_floor
	addi	%g1, %g1, 12
	fmov	%f1, %f0
	fldi	%f0, %g1, 4
	fsub	%f7, %f0, %f1
	fldi	%f1, %g31, 536
	fldi	%f0, %g6, -4
	fsub	%f1, %f1, %f0
	fldi	%f0, %g5, -4
	fsqrt	%f0, %f0
	fmul	%f1, %f1, %f0
	fjlt	%f5, %f16, fjge_else.52206
	fmov	%f0, %f5
	jmp	fjge_cont.52207
fjge_else.52206:
	fneg	%f0, %f5
fjge_cont.52207:
	fjlt	%f0, %f6, fjge_else.52208
	fdiv	%f1, %f1, %f5
	fjlt	%f1, %f16, fjge_else.52210
	fmov	%f0, %f1
	jmp	fjge_cont.52211
fjge_else.52210:
	fneg	%f0, %f1
fjge_cont.52211:
	fjlt	%f17, %f0, fjge_else.52212
	fjlt	%f0, %f20, fjge_else.52214
	addi	%g3, %g0, 0
	jmp	fjge_cont.52215
fjge_else.52214:
	addi	%g3, %g0, -1
fjge_cont.52215:
	jmp	fjge_cont.52213
fjge_else.52212:
	addi	%g3, %g0, 1
fjge_cont.52213:
	jne	%g3, %g0, jeq_else.52216
	fmov	%f4, %f0
	jmp	jeq_cont.52217
jeq_else.52216:
	fdiv	%f4, %f17, %f0
jeq_cont.52217:
	fmul	%f0, %f4, %f4
	setL %g4, l.45544
	fldi	%f1, %g4, 0
	fmul	%f2, %f1, %f0
	setL %g4, l.45546
	fldi	%f1, %g4, 0
	fdiv	%f2, %f2, %f1
	setL %g4, l.45548
	fldi	%f1, %g4, 0
	fmul	%f3, %f1, %f0
	setL %g4, l.45550
	fldi	%f1, %g4, 0
	fadd	%f1, %f1, %f2
	fdiv	%f2, %f3, %f1
	setL %g4, l.45552
	fldi	%f1, %g4, 0
	fmul	%f3, %f1, %f0
	setL %g4, l.45554
	fldi	%f1, %g4, 0
	fadd	%f1, %f1, %f2
	fdiv	%f2, %f3, %f1
	setL %g4, l.45556
	fldi	%f1, %g4, 0
	fmul	%f3, %f1, %f0
	setL %g4, l.45558
	fldi	%f1, %g4, 0
	fadd	%f1, %f1, %f2
	fdiv	%f2, %f3, %f1
	setL %g4, l.45560
	fldi	%f1, %g4, 0
	fmul	%f3, %f1, %f0
	fadd	%f1, %f28, %f2
	fdiv	%f2, %f3, %f1
	setL %g4, l.45563
	fldi	%f1, %g4, 0
	fmul	%f3, %f1, %f0
	setL %g4, l.45565
	fldi	%f1, %g4, 0
	fadd	%f1, %f1, %f2
	fdiv	%f2, %f3, %f1
	setL %g4, l.45567
	fldi	%f1, %g4, 0
	fmul	%f3, %f1, %f0
	setL %g4, l.45569
	fldi	%f1, %g4, 0
	fadd	%f1, %f1, %f2
	fdiv	%f2, %f3, %f1
	setL %g4, l.45571
	fldi	%f1, %g4, 0
	fmul	%f3, %f1, %f0
	fadd	%f1, %f25, %f2
	fdiv	%f1, %f3, %f1
	fmul	%f2, %f25, %f0
	fadd	%f1, %f26, %f1
	fdiv	%f2, %f2, %f1
	setL %g4, l.45575
	fldi	%f1, %g4, 0
	fmul	%f3, %f1, %f0
	fadd	%f1, %f24, %f2
	fdiv	%f1, %f3, %f1
	fadd	%f1, %f23, %f1
	fdiv	%f0, %f0, %f1
	fadd	%f0, %f17, %f0
	fdiv	%f0, %f4, %f0
	jlt	%g0, %g3, jle_else.52218
	jlt	%g3, %g0, jge_else.52220
	fmov	%f1, %f0
	jmp	jge_cont.52221
jge_else.52220:
	fsub	%f1, %f31, %f0
jge_cont.52221:
	jmp	jle_cont.52219
jle_else.52218:
	fsub	%f1, %f22, %f0
jle_cont.52219:
	setL %g3, l.45582
	fldi	%f0, %g3, 0
	fmul	%f0, %f1, %f0
	fdiv	%f0, %f0, %f30
	jmp	fjge_cont.52209
fjge_else.52208:
	setL %g3, l.45540
	fldi	%f0, %g3, 0
fjge_cont.52209:
	fsti	%f0, %g1, 8
	subi	%g1, %g1, 16
	call	min_caml_floor
	addi	%g1, %g1, 16
	fmov	%f1, %f0
	fldi	%f0, %g1, 8
	fsub	%f0, %f0, %f1
	setL %g3, l.45619
	fldi	%f2, %g3, 0
	fsub	%f1, %f21, %f7
	fmul	%f1, %f1, %f1
	fsub	%f1, %f2, %f1
	fsub	%f0, %f21, %f0
	fmul	%f0, %f0, %f0
	fsub	%f1, %f1, %f0
	fjlt	%f1, %f16, fjge_else.52222
	fmov	%f0, %f1
	jmp	fjge_cont.52223
fjge_else.52222:
	fmov	%f0, %f16
fjge_cont.52223:
	fmul	%f1, %f27, %f0
	setL %g3, l.45623
	fldi	%f0, %g3, 0
	fdiv	%f0, %f1, %f0
	fsti	%f0, %g31, 560
	jmp	jeq_cont.52189
jeq_else.52188:
jeq_cont.52189:
jeq_cont.52145:
jeq_cont.52101:
jeq_cont.52093:
	slli	%g4, %g7, 2
	ldi	%g3, %g31, 524
	add	%g4, %g4, %g3
	slli	%g3, %g25, 2
	st	%g4, %g19, %g3
	slli	%g3, %g25, 2
	ld	%g3, %g20, %g3
	fldi	%f0, %g31, 540
	fsti	%f0, %g3, 0
	fldi	%f0, %g31, 536
	fsti	%f0, %g3, -4
	fldi	%f0, %g31, 532
	fsti	%f0, %g3, -8
	fldi	%f0, %g26, 0
	fjlt	%f0, %f21, fjge_else.52224
	addi	%g4, %g0, 1
	slli	%g3, %g25, 2
	st	%g4, %g18, %g3
	slli	%g3, %g25, 2
	ld	%g3, %g17, %g3
	fldi	%f0, %g31, 568
	fsti	%f0, %g3, 0
	fldi	%f0, %g31, 564
	fsti	%f0, %g3, -4
	fldi	%f0, %g31, 560
	fsti	%f0, %g3, -8
	slli	%g3, %g25, 2
	ld	%g4, %g17, %g3
	setL %g3, l.45719
	fldi	%f0, %g3, 0
	fmul	%f0, %f0, %f11
	fldi	%f1, %g4, 0
	fmul	%f1, %f1, %f0
	fsti	%f1, %g4, 0
	fldi	%f1, %g4, -4
	fmul	%f1, %f1, %f0
	fsti	%f1, %g4, -4
	fldi	%f1, %g4, -8
	fmul	%f0, %f1, %f0
	fsti	%f0, %g4, -8
	slli	%g3, %g25, 2
	ld	%g3, %g16, %g3
	fldi	%f0, %g31, 556
	fsti	%f0, %g3, 0
	fldi	%f0, %g31, 552
	fsti	%f0, %g3, -4
	fldi	%f0, %g31, 548
	fsti	%f0, %g3, -8
	jmp	fjge_cont.52225
fjge_else.52224:
	addi	%g4, %g0, 0
	slli	%g3, %g25, 2
	st	%g4, %g18, %g3
fjge_cont.52225:
	setL %g3, l.45741
	fldi	%f3, %g3, 0
	fldi	%f1, %g22, 0
	fldi	%f0, %g31, 556
	fmul	%f5, %f1, %f0
	fldi	%f4, %g22, -4
	fldi	%f2, %g31, 552
	fmul	%f2, %f4, %f2
	fadd	%f5, %f5, %f2
	fldi	%f4, %g22, -8
	fldi	%f2, %g31, 548
	fmul	%f2, %f4, %f2
	fadd	%f2, %f5, %f2
	fmul	%f2, %f3, %f2
	fmul	%f0, %f2, %f0
	fadd	%f0, %f1, %f0
	fsti	%f0, %g22, 0
	fldi	%f1, %g22, -4
	fldi	%f0, %g31, 552
	fmul	%f0, %f2, %f0
	fadd	%f0, %f1, %f0
	fsti	%f0, %g22, -4
	fldi	%f1, %g22, -8
	fldi	%f0, %g31, 548
	fmul	%f0, %f2, %f0
	fadd	%f0, %f1, %f0
	fsti	%f0, %g22, -8
	fldi	%f0, %g26, -4
	fmul	%f10, %f13, %f0
	addi	%g12, %g0, 0
	ldi	%g13, %g31, 516
	subi	%g1, %g1, 16
	call	shadow_check_one_or_matrix.2902
	addi	%g1, %g1, 16
	jne	%g3, %g0, jeq_else.52226
	fldi	%f1, %g31, 556
	fldi	%f0, %g31, 308
	fmul	%f2, %f1, %f0
	fldi	%f1, %g31, 552
	fldi	%f3, %g31, 304
	fmul	%f1, %f1, %f3
	fadd	%f4, %f2, %f1
	fldi	%f1, %g31, 548
	fldi	%f2, %g31, 300
	fmul	%f1, %f1, %f2
	fadd	%f1, %f4, %f1
	fneg	%f1, %f1
	fmul	%f1, %f1, %f11
	fldi	%f4, %g22, 0
	fmul	%f4, %f4, %f0
	fldi	%f0, %g22, -4
	fmul	%f0, %f0, %f3
	fadd	%f3, %f4, %f0
	fldi	%f0, %g22, -8
	fmul	%f0, %f0, %f2
	fadd	%f0, %f3, %f0
	fneg	%f0, %f0
	fjlt	%f16, %f1, fjge_else.52228
	jmp	fjge_cont.52229
fjge_else.52228:
	fldi	%f3, %g31, 592
	fldi	%f2, %g31, 568
	fmul	%f2, %f1, %f2
	fadd	%f2, %f3, %f2
	fsti	%f2, %g31, 592
	fldi	%f3, %g31, 588
	fldi	%f2, %g31, 564
	fmul	%f2, %f1, %f2
	fadd	%f2, %f3, %f2
	fsti	%f2, %g31, 588
	fldi	%f3, %g31, 584
	fldi	%f2, %g31, 560
	fmul	%f1, %f1, %f2
	fadd	%f1, %f3, %f1
	fsti	%f1, %g31, 584
fjge_cont.52229:
	fjlt	%f16, %f0, fjge_else.52230
	jmp	fjge_cont.52231
fjge_else.52230:
	fmul	%f0, %f0, %f0
	fmul	%f0, %f0, %f0
	fmul	%f0, %f0, %f10
	fldi	%f1, %g31, 592
	fadd	%f1, %f1, %f0
	fsti	%f1, %g31, 592
	fldi	%f1, %g31, 588
	fadd	%f1, %f1, %f0
	fsti	%f1, %g31, 588
	fldi	%f1, %g31, 584
	fadd	%f0, %f1, %f0
	fsti	%f0, %g31, 584
fjge_cont.52231:
	jmp	jeq_cont.52227
jeq_else.52226:
jeq_cont.52227:
	fldi	%f0, %g31, 540
	fsti	%f0, %g31, 636
	fldi	%f0, %g31, 536
	fsti	%f0, %g31, 632
	fldi	%f0, %g31, 532
	fsti	%f0, %g31, 628
	ldi	%g3, %g31, 28
	subi	%g3, %g3, 1
	jlt	%g3, %g0, jge_else.52232
	slli	%g4, %g3, 2
	add	%g4, %g31, %g4
	ldi	%g4, %g4, 272
	ldi	%g7, %g4, -40
	ldi	%g6, %g4, -4
	fldi	%f1, %g31, 540
	ldi	%g5, %g4, -20
	fldi	%f0, %g5, 0
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, 0
	fldi	%f1, %g31, 536
	fldi	%f0, %g5, -4
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, -4
	fldi	%f1, %g31, 532
	fldi	%f0, %g5, -8
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, -8
	addi	%g5, %g0, 2
	jne	%g6, %g5, jeq_else.52234
	ldi	%g4, %g4, -16
	fldi	%f1, %g7, 0
	fldi	%f3, %g7, -4
	fldi	%f2, %g7, -8
	fldi	%f0, %g4, 0
	fmul	%f1, %f0, %f1
	fldi	%f0, %g4, -4
	fmul	%f0, %f0, %f3
	fadd	%f1, %f1, %f0
	fldi	%f0, %g4, -8
	fmul	%f0, %f0, %f2
	fadd	%f0, %f1, %f0
	fsti	%f0, %g7, -12
	jmp	jeq_cont.52235
jeq_else.52234:
	addi	%g5, %g0, 2
	jlt	%g5, %g6, jle_else.52236
	jmp	jle_cont.52237
jle_else.52236:
	fldi	%f2, %g7, 0
	fldi	%f1, %g7, -4
	fldi	%f0, %g7, -8
	fmul	%f4, %f2, %f2
	ldi	%g5, %g4, -16
	fldi	%f3, %g5, 0
	fmul	%f5, %f4, %f3
	fmul	%f4, %f1, %f1
	fldi	%f3, %g5, -4
	fmul	%f3, %f4, %f3
	fadd	%f5, %f5, %f3
	fmul	%f4, %f0, %f0
	fldi	%f3, %g5, -8
	fmul	%f3, %f4, %f3
	fadd	%f4, %f5, %f3
	ldi	%g5, %g4, -12
	jne	%g5, %g0, jeq_else.52238
	fmov	%f3, %f4
	jmp	jeq_cont.52239
jeq_else.52238:
	fmul	%f5, %f1, %f0
	ldi	%g4, %g4, -36
	fldi	%f3, %g4, 0
	fmul	%f3, %f5, %f3
	fadd	%f4, %f4, %f3
	fmul	%f3, %f0, %f2
	fldi	%f0, %g4, -4
	fmul	%f0, %f3, %f0
	fadd	%f4, %f4, %f0
	fmul	%f1, %f2, %f1
	fldi	%f0, %g4, -8
	fmul	%f3, %f1, %f0
	fadd	%f3, %f4, %f3
jeq_cont.52239:
	addi	%g4, %g0, 3
	jne	%g6, %g4, jeq_else.52240
	fsub	%f0, %f3, %f17
	jmp	jeq_cont.52241
jeq_else.52240:
	fmov	%f0, %f3
jeq_cont.52241:
	fsti	%f0, %g7, -12
jle_cont.52237:
jeq_cont.52235:
	subi	%g4, %g3, 1
	subi	%g3, %g31, 540
	subi	%g1, %g1, 16
	call	setup_startp_constants.2865
	addi	%g1, %g1, 16
	jmp	jge_cont.52233
jge_else.52232:
jge_cont.52233:
	ldi	%g3, %g31, 1720
	subi	%g3, %g3, 1
	sti	%g22, %g1, 12
	sti	%g16, %g1, 16
	sti	%g21, %g1, 20
	sti	%g23, %g1, 24
	sti	%g17, %g1, 28
	sti	%g18, %g1, 32
	sti	%g19, %g1, 36
	sti	%g20, %g1, 40
	sti	%g24, %g1, 44
	sti	%g19, %g1, 48
	mov	%g21, %g3
	subi	%g1, %g1, 56
	call	trace_reflections.2949
	addi	%g1, %g1, 56
	setL %g3, l.43078
	fldi	%f0, %g3, 0
	fjlt	%f0, %f13, fjge_else.52242
	return
fjge_else.52242:
	addi	%g3, %g0, 4
	jlt	%g25, %g3, jle_else.52244
	jmp	jle_cont.52245
jle_else.52244:
	addi	%g3, %g25, 1
	addi	%g4, %g0, -1
	slli	%g3, %g3, 2
	ldi	%g19, %g1, 48
	st	%g4, %g19, %g3
jle_cont.52245:
	addi	%g3, %g0, 2
	jne	%g30, %g3, jeq_else.52246
	fldi	%f0, %g26, 0
	fsub	%f0, %f17, %f0
	fmul	%f13, %f13, %f0
	addi	%g25, %g25, 1
	fldi	%f0, %g31, 528
	fadd	%f14, %f14, %f0
	ldi	%g24, %g1, 44
	ldi	%g20, %g1, 40
	ldi	%g19, %g1, 36
	ldi	%g18, %g1, 32
	ldi	%g17, %g1, 28
	ldi	%g23, %g1, 24
	ldi	%g21, %g1, 20
	ldi	%g16, %g1, 16
	ldi	%g22, %g1, 12
	jmp	trace_ray.2954
jeq_else.52246:
	return
jle_else.52067:
	return

!==============================
! args = [%g21, %g3]
! fargs = [%f10]
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f29, %f28, %f27, %f26, %f25, %f24, %f23, %f22, %f21, %f20, %f2, %f17, %f16, %f15, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
trace_diffuse_ray.2960:
	setL %g4, l.42627
	fldi	%f0, %g4, 0
	fsti	%f0, %g31, 528
	addi	%g19, %g0, 0
	ldi	%g20, %g31, 516
	mov	%g17, %g3
	mov	%g18, %g21
	subi	%g1, %g1, 4
	call	trace_or_matrix_fast.2927
	addi	%g1, %g1, 4
	fldi	%f0, %g31, 528
	setL %g3, l.44633
	fldi	%f1, %g3, 0
	fjlt	%f1, %f0, fjge_else.52249
	addi	%g3, %g0, 0
	jmp	fjge_cont.52250
fjge_else.52249:
	setL %g3, l.45368
	fldi	%f1, %g3, 0
	fjlt	%f0, %f1, fjge_else.52251
	addi	%g3, %g0, 0
	jmp	fjge_cont.52252
fjge_else.52251:
	addi	%g3, %g0, 1
fjge_cont.52252:
fjge_cont.52250:
	jne	%g3, %g0, jeq_else.52253
	return
jeq_else.52253:
	ldi	%g3, %g31, 544
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g14, %g3, 272
	ldi	%g3, %g14, -4
	jne	%g3, %g28, jeq_else.52255
	ldi	%g3, %g31, 524
	fsti	%f16, %g31, 556
	fsti	%f16, %g31, 552
	fsti	%f16, %g31, 548
	subi	%g4, %g3, 1
	slli	%g3, %g4, 2
	fld	%f1, %g21, %g3
	fjeq	%f1, %f16, fjne_else.52257
	fjlt	%f16, %f1, fjge_else.52259
	setL %g3, l.43888
	fldi	%f0, %g3, 0
	jmp	fjge_cont.52260
fjge_else.52259:
	setL %g3, l.42861
	fldi	%f0, %g3, 0
fjge_cont.52260:
	jmp	fjne_cont.52258
fjne_else.52257:
	fmov	%f0, %f16
fjne_cont.52258:
	fneg	%f0, %f0
	slli	%g3, %g4, 2
	add	%g3, %g31, %g3
	fsti	%f0, %g3, 556
	jmp	jeq_cont.52256
jeq_else.52255:
	addi	%g4, %g0, 2
	jne	%g3, %g4, jeq_else.52261
	ldi	%g3, %g14, -16
	fldi	%f0, %g3, 0
	fneg	%f0, %f0
	fsti	%f0, %g31, 556
	fldi	%f0, %g3, -4
	fneg	%f0, %f0
	fsti	%f0, %g31, 552
	fldi	%f0, %g3, -8
	fneg	%f0, %f0
	fsti	%f0, %g31, 548
	jmp	jeq_cont.52262
jeq_else.52261:
	fldi	%f1, %g31, 540
	ldi	%g3, %g14, -20
	fldi	%f0, %g3, 0
	fsub	%f4, %f1, %f0
	fldi	%f1, %g31, 536
	fldi	%f0, %g3, -4
	fsub	%f3, %f1, %f0
	fldi	%f1, %g31, 532
	fldi	%f0, %g3, -8
	fsub	%f0, %f1, %f0
	ldi	%g3, %g14, -16
	fldi	%f1, %g3, 0
	fmul	%f2, %f4, %f1
	fldi	%f1, %g3, -4
	fmul	%f6, %f3, %f1
	fldi	%f1, %g3, -8
	fmul	%f7, %f0, %f1
	ldi	%g3, %g14, -12
	jne	%g3, %g0, jeq_else.52263
	fsti	%f2, %g31, 556
	fsti	%f6, %g31, 552
	fsti	%f7, %g31, 548
	jmp	jeq_cont.52264
jeq_else.52263:
	ldi	%g3, %g14, -36
	fldi	%f1, %g3, -8
	fmul	%f5, %f3, %f1
	fldi	%f1, %g3, -4
	fmul	%f1, %f0, %f1
	fadd	%f1, %f5, %f1
	fmul	%f1, %f1, %f21
	fadd	%f1, %f2, %f1
	fsti	%f1, %g31, 556
	fldi	%f1, %g3, -8
	fmul	%f2, %f4, %f1
	fldi	%f1, %g3, 0
	fmul	%f0, %f0, %f1
	fadd	%f0, %f2, %f0
	fmul	%f0, %f0, %f21
	fadd	%f0, %f6, %f0
	fsti	%f0, %g31, 552
	fldi	%f0, %g3, -4
	fmul	%f1, %f4, %f0
	fldi	%f0, %g3, 0
	fmul	%f0, %f3, %f0
	fadd	%f0, %f1, %f0
	fmul	%f0, %f0, %f21
	fadd	%f0, %f7, %f0
	fsti	%f0, %g31, 548
jeq_cont.52264:
	ldi	%g3, %g14, -24
	fldi	%f2, %g31, 556
	fmul	%f1, %f2, %f2
	fldi	%f0, %g31, 552
	fmul	%f0, %f0, %f0
	fadd	%f1, %f1, %f0
	fldi	%f0, %g31, 548
	fmul	%f0, %f0, %f0
	fadd	%f0, %f1, %f0
	fsqrt	%f1, %f0
	fjeq	%f1, %f16, fjne_else.52265
	jne	%g3, %g0, jeq_else.52267
	fdiv	%f0, %f17, %f1
	jmp	jeq_cont.52268
jeq_else.52267:
	fdiv	%f0, %f20, %f1
jeq_cont.52268:
	jmp	fjne_cont.52266
fjne_else.52265:
	setL %g3, l.42861
	fldi	%f0, %g3, 0
fjne_cont.52266:
	fmul	%f1, %f2, %f0
	fsti	%f1, %g31, 556
	fldi	%f1, %g31, 552
	fmul	%f1, %f1, %f0
	fsti	%f1, %g31, 552
	fldi	%f1, %g31, 548
	fmul	%f0, %f1, %f0
	fsti	%f0, %g31, 548
jeq_cont.52262:
jeq_cont.52256:
	ldi	%g3, %g14, 0
	ldi	%g4, %g14, -32
	fldi	%f0, %g4, 0
	fsti	%f0, %g31, 568
	fldi	%f0, %g4, -4
	fsti	%f0, %g31, 564
	fldi	%f0, %g4, -8
	fsti	%f0, %g31, 560
	jne	%g3, %g28, jeq_else.52269
	fldi	%f1, %g31, 540
	ldi	%g5, %g14, -20
	fldi	%f0, %g5, 0
	fsub	%f5, %f1, %f0
	setL %g3, l.45673
	fldi	%f9, %g3, 0
	fmul	%f0, %f5, %f9
	subi	%g1, %g1, 4
	call	min_caml_floor
	setL %g3, l.45675
	fldi	%f8, %g3, 0
	fmul	%f0, %f0, %f8
	fsub	%f7, %f5, %f0
	setL %g3, l.45634
	fldi	%f6, %g3, 0
	fldi	%f1, %g31, 532
	fldi	%f0, %g5, -8
	fsub	%f5, %f1, %f0
	fmul	%f0, %f5, %f9
	call	min_caml_floor
	addi	%g1, %g1, 4
	fmul	%f0, %f0, %f8
	fsub	%f1, %f5, %f0
	fjlt	%f7, %f6, fjge_else.52271
	fjlt	%f1, %f6, fjge_else.52273
	setL %g3, l.42623
	fldi	%f0, %g3, 0
	jmp	fjge_cont.52274
fjge_else.52273:
	setL %g3, l.42609
	fldi	%f0, %g3, 0
fjge_cont.52274:
	jmp	fjge_cont.52272
fjge_else.52271:
	fjlt	%f1, %f6, fjge_else.52275
	setL %g3, l.42609
	fldi	%f0, %g3, 0
	jmp	fjge_cont.52276
fjge_else.52275:
	setL %g3, l.42623
	fldi	%f0, %g3, 0
fjge_cont.52276:
fjge_cont.52272:
	fsti	%f0, %g31, 564
	jmp	jeq_cont.52270
jeq_else.52269:
	addi	%g4, %g0, 2
	jne	%g3, %g4, jeq_else.52277
	fldi	%f1, %g31, 536
	setL %g3, l.45653
	fldi	%f0, %g3, 0
	fmul	%f2, %f1, %f0
	setL %g3, l.42599
	fldi	%f3, %g3, 0
	setL %g3, l.42601
	fldi	%f4, %g3, 0
	fjlt	%f2, %f16, fjge_else.52279
	fmov	%f1, %f2
	jmp	fjge_cont.52280
fjge_else.52279:
	fneg	%f1, %f2
fjge_cont.52280:
	fjlt	%f29, %f1, fjge_else.52281
	fjlt	%f1, %f16, fjge_else.52283
	fmov	%f0, %f1
	jmp	fjge_cont.52284
fjge_else.52283:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52285
	fjlt	%f1, %f16, fjge_else.52287
	fmov	%f0, %f1
	jmp	fjge_cont.52288
fjge_else.52287:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52289
	fjlt	%f1, %f16, fjge_else.52291
	fmov	%f0, %f1
	jmp	fjge_cont.52292
fjge_else.52291:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.52292:
	jmp	fjge_cont.52290
fjge_else.52289:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.52290:
fjge_cont.52288:
	jmp	fjge_cont.52286
fjge_else.52285:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52293
	fjlt	%f1, %f16, fjge_else.52295
	fmov	%f0, %f1
	jmp	fjge_cont.52296
fjge_else.52295:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.52296:
	jmp	fjge_cont.52294
fjge_else.52293:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.52294:
fjge_cont.52286:
fjge_cont.52284:
	jmp	fjge_cont.52282
fjge_else.52281:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52297
	fjlt	%f1, %f16, fjge_else.52299
	fmov	%f0, %f1
	jmp	fjge_cont.52300
fjge_else.52299:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52301
	fjlt	%f1, %f16, fjge_else.52303
	fmov	%f0, %f1
	jmp	fjge_cont.52304
fjge_else.52303:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.52304:
	jmp	fjge_cont.52302
fjge_else.52301:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.52302:
fjge_cont.52300:
	jmp	fjge_cont.52298
fjge_else.52297:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52305
	fjlt	%f1, %f16, fjge_else.52307
	fmov	%f0, %f1
	jmp	fjge_cont.52308
fjge_else.52307:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.52308:
	jmp	fjge_cont.52306
fjge_else.52305:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 4
	call	sin_sub.2556
	addi	%g1, %g1, 4
fjge_cont.52306:
fjge_cont.52298:
fjge_cont.52282:
	fjlt	%f3, %f0, fjge_else.52309
	fjlt	%f16, %f2, fjge_else.52311
	addi	%g3, %g0, 0
	jmp	fjge_cont.52312
fjge_else.52311:
	addi	%g3, %g0, 1
fjge_cont.52312:
	jmp	fjge_cont.52310
fjge_else.52309:
	fjlt	%f16, %f2, fjge_else.52313
	addi	%g3, %g0, 1
	jmp	fjge_cont.52314
fjge_else.52313:
	addi	%g3, %g0, 0
fjge_cont.52314:
fjge_cont.52310:
	fjlt	%f3, %f0, fjge_else.52315
	fmov	%f1, %f0
	jmp	fjge_cont.52316
fjge_else.52315:
	fsub	%f1, %f29, %f0
fjge_cont.52316:
	fjlt	%f22, %f1, fjge_else.52317
	fmov	%f0, %f1
	jmp	fjge_cont.52318
fjge_else.52317:
	fsub	%f0, %f3, %f1
fjge_cont.52318:
	fmul	%f1, %f0, %f21
	fmul	%f0, %f1, %f1
	fdiv	%f2, %f0, %f25
	fsub	%f2, %f26, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f24, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f23, %f2
	fdiv	%f0, %f0, %f2
	fsub	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	fmul	%f1, %f4, %f0
	fmul	%f0, %f0, %f0
	fadd	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	jne	%g3, %g0, jeq_else.52319
	fneg	%f1, %f0
	jmp	jeq_cont.52320
jeq_else.52319:
	fmov	%f1, %f0
jeq_cont.52320:
	fmul	%f0, %f1, %f1
	fmul	%f1, %f27, %f0
	fsti	%f1, %g31, 568
	fsub	%f0, %f17, %f0
	fmul	%f0, %f27, %f0
	fsti	%f0, %g31, 564
	jmp	jeq_cont.52278
jeq_else.52277:
	addi	%g4, %g0, 3
	jne	%g3, %g4, jeq_else.52321
	fldi	%f1, %g31, 540
	ldi	%g3, %g14, -20
	fldi	%f0, %g3, 0
	fsub	%f1, %f1, %f0
	fldi	%f2, %g31, 532
	fldi	%f0, %g3, -8
	fsub	%f0, %f2, %f0
	fmul	%f1, %f1, %f1
	fmul	%f0, %f0, %f0
	fadd	%f0, %f1, %f0
	fsqrt	%f0, %f0
	setL %g3, l.45634
	fldi	%f1, %g3, 0
	fdiv	%f0, %f0, %f1
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	min_caml_floor
	addi	%g1, %g1, 8
	fmov	%f1, %f0
	fldi	%f0, %g1, 0
	fsub	%f0, %f0, %f1
	fmul	%f0, %f0, %f30
	fsub	%f2, %f22, %f0
	setL %g3, l.42599
	fldi	%f3, %g3, 0
	setL %g3, l.42601
	fldi	%f4, %g3, 0
	fjlt	%f2, %f16, fjge_else.52323
	fmov	%f1, %f2
	jmp	fjge_cont.52324
fjge_else.52323:
	fneg	%f1, %f2
fjge_cont.52324:
	fjlt	%f29, %f1, fjge_else.52325
	fjlt	%f1, %f16, fjge_else.52327
	fmov	%f0, %f1
	jmp	fjge_cont.52328
fjge_else.52327:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52329
	fjlt	%f1, %f16, fjge_else.52331
	fmov	%f0, %f1
	jmp	fjge_cont.52332
fjge_else.52331:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52333
	fjlt	%f1, %f16, fjge_else.52335
	fmov	%f0, %f1
	jmp	fjge_cont.52336
fjge_else.52335:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.52336:
	jmp	fjge_cont.52334
fjge_else.52333:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.52334:
fjge_cont.52332:
	jmp	fjge_cont.52330
fjge_else.52329:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52337
	fjlt	%f1, %f16, fjge_else.52339
	fmov	%f0, %f1
	jmp	fjge_cont.52340
fjge_else.52339:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.52340:
	jmp	fjge_cont.52338
fjge_else.52337:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.52338:
fjge_cont.52330:
fjge_cont.52328:
	jmp	fjge_cont.52326
fjge_else.52325:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52341
	fjlt	%f1, %f16, fjge_else.52343
	fmov	%f0, %f1
	jmp	fjge_cont.52344
fjge_else.52343:
	fadd	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52345
	fjlt	%f1, %f16, fjge_else.52347
	fmov	%f0, %f1
	jmp	fjge_cont.52348
fjge_else.52347:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.52348:
	jmp	fjge_cont.52346
fjge_else.52345:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.52346:
fjge_cont.52344:
	jmp	fjge_cont.52342
fjge_else.52341:
	fsub	%f1, %f1, %f29
	fjlt	%f29, %f1, fjge_else.52349
	fjlt	%f1, %f16, fjge_else.52351
	fmov	%f0, %f1
	jmp	fjge_cont.52352
fjge_else.52351:
	fadd	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.52352:
	jmp	fjge_cont.52350
fjge_else.52349:
	fsub	%f1, %f1, %f29
	subi	%g1, %g1, 8
	call	sin_sub.2556
	addi	%g1, %g1, 8
fjge_cont.52350:
fjge_cont.52342:
fjge_cont.52326:
	fjlt	%f3, %f0, fjge_else.52353
	fjlt	%f16, %f2, fjge_else.52355
	addi	%g3, %g0, 0
	jmp	fjge_cont.52356
fjge_else.52355:
	addi	%g3, %g0, 1
fjge_cont.52356:
	jmp	fjge_cont.52354
fjge_else.52353:
	fjlt	%f16, %f2, fjge_else.52357
	addi	%g3, %g0, 1
	jmp	fjge_cont.52358
fjge_else.52357:
	addi	%g3, %g0, 0
fjge_cont.52358:
fjge_cont.52354:
	fjlt	%f3, %f0, fjge_else.52359
	fmov	%f1, %f0
	jmp	fjge_cont.52360
fjge_else.52359:
	fsub	%f1, %f29, %f0
fjge_cont.52360:
	fjlt	%f22, %f1, fjge_else.52361
	fmov	%f0, %f1
	jmp	fjge_cont.52362
fjge_else.52361:
	fsub	%f0, %f3, %f1
fjge_cont.52362:
	fmul	%f1, %f0, %f21
	fmul	%f0, %f1, %f1
	fdiv	%f2, %f0, %f25
	fsub	%f2, %f26, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f24, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f23, %f2
	fdiv	%f0, %f0, %f2
	fsub	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	fmul	%f1, %f4, %f0
	fmul	%f0, %f0, %f0
	fadd	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	jne	%g3, %g0, jeq_else.52363
	fneg	%f1, %f0
	jmp	jeq_cont.52364
jeq_else.52363:
	fmov	%f1, %f0
jeq_cont.52364:
	fmul	%f0, %f1, %f1
	fmul	%f1, %f0, %f27
	fsti	%f1, %g31, 564
	fsub	%f0, %f17, %f0
	fmul	%f0, %f0, %f27
	fsti	%f0, %g31, 560
	jmp	jeq_cont.52322
jeq_else.52321:
	addi	%g4, %g0, 4
	jne	%g3, %g4, jeq_else.52365
	fldi	%f1, %g31, 540
	ldi	%g5, %g14, -20
	fldi	%f0, %g5, 0
	fsub	%f1, %f1, %f0
	ldi	%g6, %g14, -16
	fldi	%f0, %g6, 0
	fsqrt	%f0, %f0
	fmul	%f1, %f1, %f0
	fldi	%f2, %g31, 532
	fldi	%f0, %g5, -8
	fsub	%f2, %f2, %f0
	fldi	%f0, %g6, -8
	fsqrt	%f0, %f0
	fmul	%f2, %f2, %f0
	fmul	%f3, %f1, %f1
	fmul	%f0, %f2, %f2
	fadd	%f5, %f3, %f0
	fjlt	%f1, %f16, fjge_else.52367
	fmov	%f0, %f1
	jmp	fjge_cont.52368
fjge_else.52367:
	fneg	%f0, %f1
fjge_cont.52368:
	setL %g3, l.45538
	fldi	%f6, %g3, 0
	fjlt	%f0, %f6, fjge_else.52369
	fdiv	%f1, %f2, %f1
	fjlt	%f1, %f16, fjge_else.52371
	fmov	%f0, %f1
	jmp	fjge_cont.52372
fjge_else.52371:
	fneg	%f0, %f1
fjge_cont.52372:
	fjlt	%f17, %f0, fjge_else.52373
	fjlt	%f0, %f20, fjge_else.52375
	addi	%g3, %g0, 0
	jmp	fjge_cont.52376
fjge_else.52375:
	addi	%g3, %g0, -1
fjge_cont.52376:
	jmp	fjge_cont.52374
fjge_else.52373:
	addi	%g3, %g0, 1
fjge_cont.52374:
	jne	%g3, %g0, jeq_else.52377
	fmov	%f4, %f0
	jmp	jeq_cont.52378
jeq_else.52377:
	fdiv	%f4, %f17, %f0
jeq_cont.52378:
	fmul	%f0, %f4, %f4
	setL %g4, l.45544
	fldi	%f1, %g4, 0
	fmul	%f2, %f1, %f0
	setL %g4, l.45546
	fldi	%f1, %g4, 0
	fdiv	%f2, %f2, %f1
	setL %g4, l.45548
	fldi	%f1, %g4, 0
	fmul	%f3, %f1, %f0
	setL %g4, l.45550
	fldi	%f1, %g4, 0
	fadd	%f1, %f1, %f2
	fdiv	%f2, %f3, %f1
	setL %g4, l.45552
	fldi	%f1, %g4, 0
	fmul	%f3, %f1, %f0
	setL %g4, l.45554
	fldi	%f1, %g4, 0
	fadd	%f1, %f1, %f2
	fdiv	%f2, %f3, %f1
	setL %g4, l.45556
	fldi	%f1, %g4, 0
	fmul	%f3, %f1, %f0
	setL %g4, l.45558
	fldi	%f1, %g4, 0
	fadd	%f1, %f1, %f2
	fdiv	%f2, %f3, %f1
	setL %g4, l.45560
	fldi	%f1, %g4, 0
	fmul	%f3, %f1, %f0
	fadd	%f1, %f28, %f2
	fdiv	%f2, %f3, %f1
	setL %g4, l.45563
	fldi	%f1, %g4, 0
	fmul	%f3, %f1, %f0
	setL %g4, l.45565
	fldi	%f1, %g4, 0
	fadd	%f1, %f1, %f2
	fdiv	%f2, %f3, %f1
	setL %g4, l.45567
	fldi	%f1, %g4, 0
	fmul	%f3, %f1, %f0
	setL %g4, l.45569
	fldi	%f1, %g4, 0
	fadd	%f1, %f1, %f2
	fdiv	%f2, %f3, %f1
	setL %g4, l.45571
	fldi	%f1, %g4, 0
	fmul	%f3, %f1, %f0
	fadd	%f1, %f25, %f2
	fdiv	%f1, %f3, %f1
	fmul	%f2, %f25, %f0
	fadd	%f1, %f26, %f1
	fdiv	%f2, %f2, %f1
	setL %g4, l.45575
	fldi	%f1, %g4, 0
	fmul	%f3, %f1, %f0
	fadd	%f1, %f24, %f2
	fdiv	%f1, %f3, %f1
	fadd	%f1, %f23, %f1
	fdiv	%f0, %f0, %f1
	fadd	%f0, %f17, %f0
	fdiv	%f1, %f4, %f0
	jlt	%g0, %g3, jle_else.52379
	jlt	%g3, %g0, jge_else.52381
	fmov	%f0, %f1
	jmp	jge_cont.52382
jge_else.52381:
	fsub	%f0, %f31, %f1
jge_cont.52382:
	jmp	jle_cont.52380
jle_else.52379:
	fsub	%f0, %f22, %f1
jle_cont.52380:
	setL %g3, l.45582
	fldi	%f1, %g3, 0
	fmul	%f0, %f0, %f1
	fdiv	%f0, %f0, %f30
	jmp	fjge_cont.52370
fjge_else.52369:
	setL %g3, l.45540
	fldi	%f0, %g3, 0
fjge_cont.52370:
	fsti	%f0, %g1, 4
	subi	%g1, %g1, 12
	call	min_caml_floor
	addi	%g1, %g1, 12
	fmov	%f1, %f0
	fldi	%f0, %g1, 4
	fsub	%f7, %f0, %f1
	fldi	%f1, %g31, 536
	fldi	%f0, %g5, -4
	fsub	%f1, %f1, %f0
	fldi	%f0, %g6, -4
	fsqrt	%f0, %f0
	fmul	%f1, %f1, %f0
	fjlt	%f5, %f16, fjge_else.52383
	fmov	%f0, %f5
	jmp	fjge_cont.52384
fjge_else.52383:
	fneg	%f0, %f5
fjge_cont.52384:
	fjlt	%f0, %f6, fjge_else.52385
	fdiv	%f1, %f1, %f5
	fjlt	%f1, %f16, fjge_else.52387
	fmov	%f0, %f1
	jmp	fjge_cont.52388
fjge_else.52387:
	fneg	%f0, %f1
fjge_cont.52388:
	fjlt	%f17, %f0, fjge_else.52389
	fjlt	%f0, %f20, fjge_else.52391
	addi	%g3, %g0, 0
	jmp	fjge_cont.52392
fjge_else.52391:
	addi	%g3, %g0, -1
fjge_cont.52392:
	jmp	fjge_cont.52390
fjge_else.52389:
	addi	%g3, %g0, 1
fjge_cont.52390:
	jne	%g3, %g0, jeq_else.52393
	fmov	%f4, %f0
	jmp	jeq_cont.52394
jeq_else.52393:
	fdiv	%f4, %f17, %f0
jeq_cont.52394:
	fmul	%f0, %f4, %f4
	setL %g4, l.45544
	fldi	%f1, %g4, 0
	fmul	%f2, %f1, %f0
	setL %g4, l.45546
	fldi	%f1, %g4, 0
	fdiv	%f2, %f2, %f1
	setL %g4, l.45548
	fldi	%f1, %g4, 0
	fmul	%f3, %f1, %f0
	setL %g4, l.45550
	fldi	%f1, %g4, 0
	fadd	%f1, %f1, %f2
	fdiv	%f2, %f3, %f1
	setL %g4, l.45552
	fldi	%f1, %g4, 0
	fmul	%f3, %f1, %f0
	setL %g4, l.45554
	fldi	%f1, %g4, 0
	fadd	%f1, %f1, %f2
	fdiv	%f2, %f3, %f1
	setL %g4, l.45556
	fldi	%f1, %g4, 0
	fmul	%f3, %f1, %f0
	setL %g4, l.45558
	fldi	%f1, %g4, 0
	fadd	%f1, %f1, %f2
	fdiv	%f2, %f3, %f1
	setL %g4, l.45560
	fldi	%f1, %g4, 0
	fmul	%f3, %f1, %f0
	fadd	%f1, %f28, %f2
	fdiv	%f2, %f3, %f1
	setL %g4, l.45563
	fldi	%f1, %g4, 0
	fmul	%f3, %f1, %f0
	setL %g4, l.45565
	fldi	%f1, %g4, 0
	fadd	%f1, %f1, %f2
	fdiv	%f2, %f3, %f1
	setL %g4, l.45567
	fldi	%f1, %g4, 0
	fmul	%f3, %f1, %f0
	setL %g4, l.45569
	fldi	%f1, %g4, 0
	fadd	%f1, %f1, %f2
	fdiv	%f2, %f3, %f1
	setL %g4, l.45571
	fldi	%f1, %g4, 0
	fmul	%f3, %f1, %f0
	fadd	%f1, %f25, %f2
	fdiv	%f2, %f3, %f1
	fmul	%f1, %f25, %f0
	fadd	%f2, %f26, %f2
	fdiv	%f1, %f1, %f2
	setL %g4, l.45575
	fldi	%f2, %g4, 0
	fmul	%f2, %f2, %f0
	fadd	%f1, %f24, %f1
	fdiv	%f1, %f2, %f1
	fadd	%f1, %f23, %f1
	fdiv	%f0, %f0, %f1
	fadd	%f0, %f17, %f0
	fdiv	%f0, %f4, %f0
	jlt	%g0, %g3, jle_else.52395
	jlt	%g3, %g0, jge_else.52397
	fmov	%f1, %f0
	jmp	jge_cont.52398
jge_else.52397:
	fsub	%f1, %f31, %f0
jge_cont.52398:
	jmp	jle_cont.52396
jle_else.52395:
	fsub	%f1, %f22, %f0
jle_cont.52396:
	setL %g3, l.45582
	fldi	%f0, %g3, 0
	fmul	%f0, %f1, %f0
	fdiv	%f0, %f0, %f30
	jmp	fjge_cont.52386
fjge_else.52385:
	setL %g3, l.45540
	fldi	%f0, %g3, 0
fjge_cont.52386:
	fsti	%f0, %g1, 8
	subi	%g1, %g1, 16
	call	min_caml_floor
	addi	%g1, %g1, 16
	fmov	%f1, %f0
	fldi	%f0, %g1, 8
	fsub	%f0, %f0, %f1
	setL %g3, l.45619
	fldi	%f2, %g3, 0
	fsub	%f1, %f21, %f7
	fmul	%f1, %f1, %f1
	fsub	%f1, %f2, %f1
	fsub	%f0, %f21, %f0
	fmul	%f0, %f0, %f0
	fsub	%f1, %f1, %f0
	fjlt	%f1, %f16, fjge_else.52399
	fmov	%f0, %f1
	jmp	fjge_cont.52400
fjge_else.52399:
	fmov	%f0, %f16
fjge_cont.52400:
	fmul	%f1, %f27, %f0
	setL %g3, l.45623
	fldi	%f0, %g3, 0
	fdiv	%f0, %f1, %f0
	fsti	%f0, %g31, 560
	jmp	jeq_cont.52366
jeq_else.52365:
jeq_cont.52366:
jeq_cont.52322:
jeq_cont.52278:
jeq_cont.52270:
	addi	%g12, %g0, 0
	ldi	%g13, %g31, 516
	subi	%g1, %g1, 16
	call	shadow_check_one_or_matrix.2902
	addi	%g1, %g1, 16
	jne	%g3, %g0, jeq_else.52401
	fldi	%f1, %g31, 556
	fldi	%f0, %g31, 308
	fmul	%f2, %f1, %f0
	fldi	%f1, %g31, 552
	fldi	%f0, %g31, 304
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g31, 548
	fldi	%f0, %g31, 300
	fmul	%f0, %f1, %f0
	fadd	%f1, %f2, %f0
	fneg	%f1, %f1
	fjlt	%f16, %f1, fjge_else.52402
	fmov	%f0, %f16
	jmp	fjge_cont.52403
fjge_else.52402:
	fmov	%f0, %f1
fjge_cont.52403:
	fmul	%f1, %f10, %f0
	ldi	%g3, %g14, -28
	fldi	%f0, %g3, 0
	fmul	%f0, %f1, %f0
	fldi	%f2, %g31, 580
	fldi	%f1, %g31, 568
	fmul	%f1, %f0, %f1
	fadd	%f1, %f2, %f1
	fsti	%f1, %g31, 580
	fldi	%f2, %g31, 576
	fldi	%f1, %g31, 564
	fmul	%f1, %f0, %f1
	fadd	%f1, %f2, %f1
	fsti	%f1, %g31, 576
	fldi	%f2, %g31, 572
	fldi	%f1, %g31, 560
	fmul	%f0, %f0, %f1
	fadd	%f0, %f2, %f0
	fsti	%f0, %g31, 572
	return
jeq_else.52401:
	return

!==============================
! args = [%g23, %g22, %g24, %g25]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f29, %f28, %f27, %f26, %f25, %f24, %f23, %f22, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
iter_trace_diffuse_rays.2963:
	jlt	%g25, %g0, jge_else.52406
	slli	%g3, %g25, 2
	ld	%g3, %g23, %g3
	ldi	%g3, %g3, 0
	fldi	%f1, %g3, 0
	fldi	%f0, %g22, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g3, -4
	fldi	%f0, %g22, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g3, -8
	fldi	%f0, %g22, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fjlt	%f0, %f16, fjge_else.52407
	slli	%g3, %g25, 2
	ld	%g4, %g23, %g3
	fdiv	%f10, %f0, %f18
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 4
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 4
	jmp	fjge_cont.52408
fjge_else.52407:
	addi	%g3, %g25, 1
	slli	%g3, %g3, 2
	ld	%g4, %g23, %g3
	fdiv	%f10, %f0, %f19
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 4
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 4
fjge_cont.52408:
	subi	%g25, %g25, 2
	jlt	%g25, %g0, jge_else.52409
	slli	%g3, %g25, 2
	ld	%g3, %g23, %g3
	ldi	%g3, %g3, 0
	fldi	%f1, %g3, 0
	fldi	%f0, %g22, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g3, -4
	fldi	%f0, %g22, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g3, -8
	fldi	%f0, %g22, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fjlt	%f0, %f16, fjge_else.52410
	slli	%g3, %g25, 2
	ld	%g4, %g23, %g3
	fdiv	%f10, %f0, %f18
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 4
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 4
	jmp	fjge_cont.52411
fjge_else.52410:
	addi	%g3, %g25, 1
	slli	%g3, %g3, 2
	ld	%g4, %g23, %g3
	fdiv	%f10, %f0, %f19
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 4
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 4
fjge_cont.52411:
	subi	%g25, %g25, 2
	jlt	%g25, %g0, jge_else.52412
	slli	%g3, %g25, 2
	ld	%g3, %g23, %g3
	ldi	%g3, %g3, 0
	fldi	%f1, %g3, 0
	fldi	%f0, %g22, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g3, -4
	fldi	%f0, %g22, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g3, -8
	fldi	%f0, %g22, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fjlt	%f0, %f16, fjge_else.52413
	slli	%g3, %g25, 2
	ld	%g4, %g23, %g3
	fdiv	%f10, %f0, %f18
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 4
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 4
	jmp	fjge_cont.52414
fjge_else.52413:
	addi	%g3, %g25, 1
	slli	%g3, %g3, 2
	ld	%g4, %g23, %g3
	fdiv	%f10, %f0, %f19
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 4
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 4
fjge_cont.52414:
	subi	%g25, %g25, 2
	jlt	%g25, %g0, jge_else.52415
	slli	%g3, %g25, 2
	ld	%g3, %g23, %g3
	ldi	%g3, %g3, 0
	fldi	%f1, %g3, 0
	fldi	%f0, %g22, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g3, -4
	fldi	%f0, %g22, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g3, -8
	fldi	%f0, %g22, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fjlt	%f0, %f16, fjge_else.52416
	slli	%g3, %g25, 2
	ld	%g4, %g23, %g3
	fdiv	%f10, %f0, %f18
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 4
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 4
	jmp	fjge_cont.52417
fjge_else.52416:
	addi	%g3, %g25, 1
	slli	%g3, %g3, 2
	ld	%g4, %g23, %g3
	fdiv	%f10, %f0, %f19
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 4
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 4
fjge_cont.52417:
	subi	%g25, %g25, 2
	jmp	iter_trace_diffuse_rays.2963
jge_else.52415:
	return
jge_else.52412:
	return
jge_else.52409:
	return
jge_else.52406:
	return

!==============================
! args = [%g15, %g14, %g13, %g12, %g11, %g10, %g9, %g25, %g26]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f29, %f28, %f27, %f26, %f25, %f24, %f23, %f22, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
do_without_neighbors.2985:
	addi	%g3, %g0, 4
	jlt	%g3, %g26, jle_else.52422
	slli	%g3, %g26, 2
	ld	%g3, %g13, %g3
	jlt	%g3, %g0, jge_else.52423
	slli	%g3, %g26, 2
	ld	%g3, %g12, %g3
	sti	%g25, %g1, 0
	sti	%g9, %g1, 4
	sti	%g10, %g1, 8
	sti	%g11, %g1, 12
	sti	%g12, %g1, 16
	sti	%g13, %g1, 20
	sti	%g14, %g1, 24
	sti	%g15, %g1, 28
	jne	%g3, %g0, jeq_else.52424
	jmp	jeq_cont.52425
jeq_else.52424:
	slli	%g3, %g26, 2
	ld	%g3, %g10, %g3
	fldi	%f0, %g3, 0
	fsti	%f0, %g31, 580
	fldi	%f0, %g3, -4
	fsti	%f0, %g31, 576
	fldi	%f0, %g3, -8
	fsti	%f0, %g31, 572
	ldi	%g30, %g9, 0
	slli	%g3, %g26, 2
	ld	%g22, %g25, %g3
	slli	%g3, %g26, 2
	ld	%g24, %g14, %g3
	sti	%g11, %g1, 32
	sti	%g22, %g1, 36
	sti	%g24, %g1, 40
	jne	%g30, %g0, jeq_else.52426
	jmp	jeq_cont.52427
jeq_else.52426:
	ldi	%g23, %g31, 716
	fldi	%f0, %g24, 0
	fsti	%f0, %g31, 636
	fldi	%f0, %g24, -4
	fsti	%f0, %g31, 632
	fldi	%f0, %g24, -8
	fsti	%f0, %g31, 628
	ldi	%g3, %g31, 28
	subi	%g3, %g3, 1
	jlt	%g3, %g0, jge_else.52428
	slli	%g4, %g3, 2
	add	%g4, %g31, %g4
	ldi	%g4, %g4, 272
	ldi	%g7, %g4, -40
	ldi	%g6, %g4, -4
	fldi	%f1, %g24, 0
	ldi	%g5, %g4, -20
	fldi	%f0, %g5, 0
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, 0
	fldi	%f1, %g24, -4
	fldi	%f0, %g5, -4
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, -4
	fldi	%f1, %g24, -8
	fldi	%f0, %g5, -8
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, -8
	addi	%g5, %g0, 2
	jne	%g6, %g5, jeq_else.52430
	ldi	%g4, %g4, -16
	fldi	%f1, %g7, 0
	fldi	%f3, %g7, -4
	fldi	%f2, %g7, -8
	fldi	%f0, %g4, 0
	fmul	%f1, %f0, %f1
	fldi	%f0, %g4, -4
	fmul	%f0, %f0, %f3
	fadd	%f1, %f1, %f0
	fldi	%f0, %g4, -8
	fmul	%f0, %f0, %f2
	fadd	%f0, %f1, %f0
	fsti	%f0, %g7, -12
	jmp	jeq_cont.52431
jeq_else.52430:
	addi	%g5, %g0, 2
	jlt	%g5, %g6, jle_else.52432
	jmp	jle_cont.52433
jle_else.52432:
	fldi	%f2, %g7, 0
	fldi	%f1, %g7, -4
	fldi	%f0, %g7, -8
	fmul	%f4, %f2, %f2
	ldi	%g5, %g4, -16
	fldi	%f3, %g5, 0
	fmul	%f5, %f4, %f3
	fmul	%f4, %f1, %f1
	fldi	%f3, %g5, -4
	fmul	%f3, %f4, %f3
	fadd	%f5, %f5, %f3
	fmul	%f4, %f0, %f0
	fldi	%f3, %g5, -8
	fmul	%f3, %f4, %f3
	fadd	%f4, %f5, %f3
	ldi	%g5, %g4, -12
	jne	%g5, %g0, jeq_else.52434
	fmov	%f3, %f4
	jmp	jeq_cont.52435
jeq_else.52434:
	fmul	%f5, %f1, %f0
	ldi	%g4, %g4, -36
	fldi	%f3, %g4, 0
	fmul	%f3, %f5, %f3
	fadd	%f4, %f4, %f3
	fmul	%f3, %f0, %f2
	fldi	%f0, %g4, -4
	fmul	%f0, %f3, %f0
	fadd	%f4, %f4, %f0
	fmul	%f1, %f2, %f1
	fldi	%f0, %g4, -8
	fmul	%f3, %f1, %f0
	fadd	%f3, %f4, %f3
jeq_cont.52435:
	addi	%g4, %g0, 3
	jne	%g6, %g4, jeq_else.52436
	fsub	%f0, %f3, %f17
	jmp	jeq_cont.52437
jeq_else.52436:
	fmov	%f0, %f3
jeq_cont.52437:
	fsti	%f0, %g7, -12
jle_cont.52433:
jeq_cont.52431:
	subi	%g4, %g3, 1
	mov	%g3, %g24
	subi	%g1, %g1, 48
	call	setup_startp_constants.2865
	addi	%g1, %g1, 48
	jmp	jge_cont.52429
jge_else.52428:
jge_cont.52429:
	ldi	%g3, %g23, -472
	ldi	%g3, %g3, 0
	fldi	%f1, %g3, 0
	fldi	%f0, %g22, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g3, -4
	fldi	%f0, %g22, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g3, -8
	fldi	%f0, %g22, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fjlt	%f0, %f16, fjge_else.52438
	ldi	%g4, %g23, -472
	fdiv	%f10, %f0, %f18
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
	jmp	fjge_cont.52439
fjge_else.52438:
	ldi	%g4, %g23, -476
	fdiv	%f10, %f0, %f19
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
fjge_cont.52439:
	ldi	%g3, %g23, -464
	ldi	%g3, %g3, 0
	fldi	%f1, %g3, 0
	fldi	%f0, %g22, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g3, -4
	fldi	%f0, %g22, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g3, -8
	fldi	%f0, %g22, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fjlt	%f0, %f16, fjge_else.52440
	ldi	%g4, %g23, -464
	fdiv	%f10, %f0, %f18
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
	jmp	fjge_cont.52441
fjge_else.52440:
	ldi	%g4, %g23, -468
	fdiv	%f10, %f0, %f19
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
fjge_cont.52441:
	ldi	%g3, %g23, -456
	ldi	%g3, %g3, 0
	fldi	%f1, %g3, 0
	fldi	%f0, %g22, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g3, -4
	fldi	%f0, %g22, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g3, -8
	fldi	%f0, %g22, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fjlt	%f0, %f16, fjge_else.52442
	ldi	%g4, %g23, -456
	fdiv	%f10, %f0, %f18
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
	jmp	fjge_cont.52443
fjge_else.52442:
	ldi	%g4, %g23, -460
	fdiv	%f10, %f0, %f19
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
fjge_cont.52443:
	addi	%g3, %g0, 112
	mov	%g25, %g3
	subi	%g1, %g1, 48
	call	iter_trace_diffuse_rays.2963
	addi	%g1, %g1, 48
jeq_cont.52427:
	jne	%g30, %g28, jeq_else.52444
	jmp	jeq_cont.52445
jeq_else.52444:
	ldi	%g23, %g31, 712
	ldi	%g24, %g1, 40
	fldi	%f0, %g24, 0
	fsti	%f0, %g31, 636
	fldi	%f0, %g24, -4
	fsti	%f0, %g31, 632
	fldi	%f0, %g24, -8
	fsti	%f0, %g31, 628
	ldi	%g3, %g31, 28
	subi	%g3, %g3, 1
	jlt	%g3, %g0, jge_else.52446
	slli	%g4, %g3, 2
	add	%g4, %g31, %g4
	ldi	%g4, %g4, 272
	ldi	%g7, %g4, -40
	ldi	%g6, %g4, -4
	fldi	%f1, %g24, 0
	ldi	%g5, %g4, -20
	fldi	%f0, %g5, 0
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, 0
	fldi	%f1, %g24, -4
	fldi	%f0, %g5, -4
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, -4
	fldi	%f1, %g24, -8
	fldi	%f0, %g5, -8
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, -8
	addi	%g5, %g0, 2
	jne	%g6, %g5, jeq_else.52448
	ldi	%g4, %g4, -16
	fldi	%f1, %g7, 0
	fldi	%f3, %g7, -4
	fldi	%f2, %g7, -8
	fldi	%f0, %g4, 0
	fmul	%f1, %f0, %f1
	fldi	%f0, %g4, -4
	fmul	%f0, %f0, %f3
	fadd	%f1, %f1, %f0
	fldi	%f0, %g4, -8
	fmul	%f0, %f0, %f2
	fadd	%f0, %f1, %f0
	fsti	%f0, %g7, -12
	jmp	jeq_cont.52449
jeq_else.52448:
	addi	%g5, %g0, 2
	jlt	%g5, %g6, jle_else.52450
	jmp	jle_cont.52451
jle_else.52450:
	fldi	%f2, %g7, 0
	fldi	%f1, %g7, -4
	fldi	%f0, %g7, -8
	fmul	%f4, %f2, %f2
	ldi	%g5, %g4, -16
	fldi	%f3, %g5, 0
	fmul	%f5, %f4, %f3
	fmul	%f4, %f1, %f1
	fldi	%f3, %g5, -4
	fmul	%f3, %f4, %f3
	fadd	%f5, %f5, %f3
	fmul	%f4, %f0, %f0
	fldi	%f3, %g5, -8
	fmul	%f3, %f4, %f3
	fadd	%f4, %f5, %f3
	ldi	%g5, %g4, -12
	jne	%g5, %g0, jeq_else.52452
	fmov	%f3, %f4
	jmp	jeq_cont.52453
jeq_else.52452:
	fmul	%f5, %f1, %f0
	ldi	%g4, %g4, -36
	fldi	%f3, %g4, 0
	fmul	%f3, %f5, %f3
	fadd	%f4, %f4, %f3
	fmul	%f3, %f0, %f2
	fldi	%f0, %g4, -4
	fmul	%f0, %f3, %f0
	fadd	%f4, %f4, %f0
	fmul	%f1, %f2, %f1
	fldi	%f0, %g4, -8
	fmul	%f3, %f1, %f0
	fadd	%f3, %f4, %f3
jeq_cont.52453:
	addi	%g4, %g0, 3
	jne	%g6, %g4, jeq_else.52454
	fsub	%f0, %f3, %f17
	jmp	jeq_cont.52455
jeq_else.52454:
	fmov	%f0, %f3
jeq_cont.52455:
	fsti	%f0, %g7, -12
jle_cont.52451:
jeq_cont.52449:
	subi	%g4, %g3, 1
	mov	%g3, %g24
	subi	%g1, %g1, 48
	call	setup_startp_constants.2865
	addi	%g1, %g1, 48
	jmp	jge_cont.52447
jge_else.52446:
jge_cont.52447:
	ldi	%g3, %g23, -472
	ldi	%g3, %g3, 0
	fldi	%f1, %g3, 0
	ldi	%g22, %g1, 36
	fldi	%f0, %g22, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g3, -4
	fldi	%f0, %g22, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g3, -8
	fldi	%f0, %g22, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fjlt	%f0, %f16, fjge_else.52456
	ldi	%g4, %g23, -472
	fdiv	%f10, %f0, %f18
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
	jmp	fjge_cont.52457
fjge_else.52456:
	ldi	%g4, %g23, -476
	fdiv	%f10, %f0, %f19
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
fjge_cont.52457:
	ldi	%g3, %g23, -464
	ldi	%g3, %g3, 0
	fldi	%f1, %g3, 0
	fldi	%f0, %g22, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g3, -4
	fldi	%f0, %g22, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g3, -8
	fldi	%f0, %g22, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fjlt	%f0, %f16, fjge_else.52458
	ldi	%g4, %g23, -464
	fdiv	%f10, %f0, %f18
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
	jmp	fjge_cont.52459
fjge_else.52458:
	ldi	%g4, %g23, -468
	fdiv	%f10, %f0, %f19
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
fjge_cont.52459:
	ldi	%g3, %g23, -456
	ldi	%g3, %g3, 0
	fldi	%f1, %g3, 0
	fldi	%f0, %g22, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g3, -4
	fldi	%f0, %g22, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g3, -8
	fldi	%f0, %g22, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fjlt	%f0, %f16, fjge_else.52460
	ldi	%g4, %g23, -456
	fdiv	%f10, %f0, %f18
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
	jmp	fjge_cont.52461
fjge_else.52460:
	ldi	%g4, %g23, -460
	fdiv	%f10, %f0, %f19
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
fjge_cont.52461:
	addi	%g3, %g0, 112
	mov	%g25, %g3
	subi	%g1, %g1, 48
	call	iter_trace_diffuse_rays.2963
	addi	%g1, %g1, 48
jeq_cont.52445:
	addi	%g3, %g0, 2
	jne	%g30, %g3, jeq_else.52462
	jmp	jeq_cont.52463
jeq_else.52462:
	ldi	%g23, %g31, 708
	ldi	%g24, %g1, 40
	fldi	%f0, %g24, 0
	fsti	%f0, %g31, 636
	fldi	%f0, %g24, -4
	fsti	%f0, %g31, 632
	fldi	%f0, %g24, -8
	fsti	%f0, %g31, 628
	ldi	%g3, %g31, 28
	subi	%g3, %g3, 1
	jlt	%g3, %g0, jge_else.52464
	slli	%g4, %g3, 2
	add	%g4, %g31, %g4
	ldi	%g4, %g4, 272
	ldi	%g7, %g4, -40
	ldi	%g6, %g4, -4
	fldi	%f1, %g24, 0
	ldi	%g5, %g4, -20
	fldi	%f0, %g5, 0
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, 0
	fldi	%f1, %g24, -4
	fldi	%f0, %g5, -4
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, -4
	fldi	%f1, %g24, -8
	fldi	%f0, %g5, -8
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, -8
	addi	%g5, %g0, 2
	jne	%g6, %g5, jeq_else.52466
	ldi	%g4, %g4, -16
	fldi	%f1, %g7, 0
	fldi	%f3, %g7, -4
	fldi	%f2, %g7, -8
	fldi	%f0, %g4, 0
	fmul	%f1, %f0, %f1
	fldi	%f0, %g4, -4
	fmul	%f0, %f0, %f3
	fadd	%f1, %f1, %f0
	fldi	%f0, %g4, -8
	fmul	%f0, %f0, %f2
	fadd	%f0, %f1, %f0
	fsti	%f0, %g7, -12
	jmp	jeq_cont.52467
jeq_else.52466:
	addi	%g5, %g0, 2
	jlt	%g5, %g6, jle_else.52468
	jmp	jle_cont.52469
jle_else.52468:
	fldi	%f2, %g7, 0
	fldi	%f1, %g7, -4
	fldi	%f0, %g7, -8
	fmul	%f4, %f2, %f2
	ldi	%g5, %g4, -16
	fldi	%f3, %g5, 0
	fmul	%f5, %f4, %f3
	fmul	%f4, %f1, %f1
	fldi	%f3, %g5, -4
	fmul	%f3, %f4, %f3
	fadd	%f5, %f5, %f3
	fmul	%f4, %f0, %f0
	fldi	%f3, %g5, -8
	fmul	%f3, %f4, %f3
	fadd	%f4, %f5, %f3
	ldi	%g5, %g4, -12
	jne	%g5, %g0, jeq_else.52470
	fmov	%f3, %f4
	jmp	jeq_cont.52471
jeq_else.52470:
	fmul	%f5, %f1, %f0
	ldi	%g4, %g4, -36
	fldi	%f3, %g4, 0
	fmul	%f3, %f5, %f3
	fadd	%f4, %f4, %f3
	fmul	%f3, %f0, %f2
	fldi	%f0, %g4, -4
	fmul	%f0, %f3, %f0
	fadd	%f4, %f4, %f0
	fmul	%f1, %f2, %f1
	fldi	%f0, %g4, -8
	fmul	%f3, %f1, %f0
	fadd	%f3, %f4, %f3
jeq_cont.52471:
	addi	%g4, %g0, 3
	jne	%g6, %g4, jeq_else.52472
	fsub	%f0, %f3, %f17
	jmp	jeq_cont.52473
jeq_else.52472:
	fmov	%f0, %f3
jeq_cont.52473:
	fsti	%f0, %g7, -12
jle_cont.52469:
jeq_cont.52467:
	subi	%g4, %g3, 1
	mov	%g3, %g24
	subi	%g1, %g1, 48
	call	setup_startp_constants.2865
	addi	%g1, %g1, 48
	jmp	jge_cont.52465
jge_else.52464:
jge_cont.52465:
	ldi	%g3, %g23, -472
	ldi	%g3, %g3, 0
	fldi	%f1, %g3, 0
	ldi	%g22, %g1, 36
	fldi	%f0, %g22, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g3, -4
	fldi	%f0, %g22, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g3, -8
	fldi	%f0, %g22, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fjlt	%f0, %f16, fjge_else.52474
	ldi	%g4, %g23, -472
	fdiv	%f10, %f0, %f18
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
	jmp	fjge_cont.52475
fjge_else.52474:
	ldi	%g4, %g23, -476
	fdiv	%f10, %f0, %f19
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
fjge_cont.52475:
	ldi	%g3, %g23, -464
	ldi	%g3, %g3, 0
	fldi	%f1, %g3, 0
	fldi	%f0, %g22, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g3, -4
	fldi	%f0, %g22, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g3, -8
	fldi	%f0, %g22, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fjlt	%f0, %f16, fjge_else.52476
	ldi	%g4, %g23, -464
	fdiv	%f10, %f0, %f18
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
	jmp	fjge_cont.52477
fjge_else.52476:
	ldi	%g4, %g23, -468
	fdiv	%f10, %f0, %f19
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
fjge_cont.52477:
	ldi	%g3, %g23, -456
	ldi	%g3, %g3, 0
	fldi	%f1, %g3, 0
	fldi	%f0, %g22, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g3, -4
	fldi	%f0, %g22, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g3, -8
	fldi	%f0, %g22, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fjlt	%f0, %f16, fjge_else.52478
	ldi	%g4, %g23, -456
	fdiv	%f10, %f0, %f18
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
	jmp	fjge_cont.52479
fjge_else.52478:
	ldi	%g4, %g23, -460
	fdiv	%f10, %f0, %f19
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
fjge_cont.52479:
	addi	%g3, %g0, 112
	mov	%g25, %g3
	subi	%g1, %g1, 48
	call	iter_trace_diffuse_rays.2963
	addi	%g1, %g1, 48
jeq_cont.52463:
	addi	%g3, %g0, 3
	jne	%g30, %g3, jeq_else.52480
	jmp	jeq_cont.52481
jeq_else.52480:
	ldi	%g23, %g31, 704
	ldi	%g24, %g1, 40
	fldi	%f0, %g24, 0
	fsti	%f0, %g31, 636
	fldi	%f0, %g24, -4
	fsti	%f0, %g31, 632
	fldi	%f0, %g24, -8
	fsti	%f0, %g31, 628
	ldi	%g3, %g31, 28
	subi	%g3, %g3, 1
	jlt	%g3, %g0, jge_else.52482
	slli	%g4, %g3, 2
	add	%g4, %g31, %g4
	ldi	%g4, %g4, 272
	ldi	%g7, %g4, -40
	ldi	%g6, %g4, -4
	fldi	%f1, %g24, 0
	ldi	%g5, %g4, -20
	fldi	%f0, %g5, 0
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, 0
	fldi	%f1, %g24, -4
	fldi	%f0, %g5, -4
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, -4
	fldi	%f1, %g24, -8
	fldi	%f0, %g5, -8
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, -8
	addi	%g5, %g0, 2
	jne	%g6, %g5, jeq_else.52484
	ldi	%g4, %g4, -16
	fldi	%f1, %g7, 0
	fldi	%f3, %g7, -4
	fldi	%f2, %g7, -8
	fldi	%f0, %g4, 0
	fmul	%f1, %f0, %f1
	fldi	%f0, %g4, -4
	fmul	%f0, %f0, %f3
	fadd	%f1, %f1, %f0
	fldi	%f0, %g4, -8
	fmul	%f0, %f0, %f2
	fadd	%f0, %f1, %f0
	fsti	%f0, %g7, -12
	jmp	jeq_cont.52485
jeq_else.52484:
	addi	%g5, %g0, 2
	jlt	%g5, %g6, jle_else.52486
	jmp	jle_cont.52487
jle_else.52486:
	fldi	%f2, %g7, 0
	fldi	%f1, %g7, -4
	fldi	%f0, %g7, -8
	fmul	%f4, %f2, %f2
	ldi	%g5, %g4, -16
	fldi	%f3, %g5, 0
	fmul	%f5, %f4, %f3
	fmul	%f4, %f1, %f1
	fldi	%f3, %g5, -4
	fmul	%f3, %f4, %f3
	fadd	%f5, %f5, %f3
	fmul	%f4, %f0, %f0
	fldi	%f3, %g5, -8
	fmul	%f3, %f4, %f3
	fadd	%f4, %f5, %f3
	ldi	%g5, %g4, -12
	jne	%g5, %g0, jeq_else.52488
	fmov	%f3, %f4
	jmp	jeq_cont.52489
jeq_else.52488:
	fmul	%f5, %f1, %f0
	ldi	%g4, %g4, -36
	fldi	%f3, %g4, 0
	fmul	%f3, %f5, %f3
	fadd	%f4, %f4, %f3
	fmul	%f3, %f0, %f2
	fldi	%f0, %g4, -4
	fmul	%f0, %f3, %f0
	fadd	%f4, %f4, %f0
	fmul	%f1, %f2, %f1
	fldi	%f0, %g4, -8
	fmul	%f3, %f1, %f0
	fadd	%f3, %f4, %f3
jeq_cont.52489:
	addi	%g4, %g0, 3
	jne	%g6, %g4, jeq_else.52490
	fsub	%f0, %f3, %f17
	jmp	jeq_cont.52491
jeq_else.52490:
	fmov	%f0, %f3
jeq_cont.52491:
	fsti	%f0, %g7, -12
jle_cont.52487:
jeq_cont.52485:
	subi	%g4, %g3, 1
	mov	%g3, %g24
	subi	%g1, %g1, 48
	call	setup_startp_constants.2865
	addi	%g1, %g1, 48
	jmp	jge_cont.52483
jge_else.52482:
jge_cont.52483:
	ldi	%g3, %g23, -472
	ldi	%g3, %g3, 0
	fldi	%f1, %g3, 0
	ldi	%g22, %g1, 36
	fldi	%f0, %g22, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g3, -4
	fldi	%f0, %g22, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g3, -8
	fldi	%f0, %g22, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fjlt	%f0, %f16, fjge_else.52492
	ldi	%g4, %g23, -472
	fdiv	%f10, %f0, %f18
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
	jmp	fjge_cont.52493
fjge_else.52492:
	ldi	%g4, %g23, -476
	fdiv	%f10, %f0, %f19
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
fjge_cont.52493:
	ldi	%g3, %g23, -464
	ldi	%g3, %g3, 0
	fldi	%f1, %g3, 0
	fldi	%f0, %g22, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g3, -4
	fldi	%f0, %g22, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g3, -8
	fldi	%f0, %g22, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fjlt	%f0, %f16, fjge_else.52494
	ldi	%g4, %g23, -464
	fdiv	%f10, %f0, %f18
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
	jmp	fjge_cont.52495
fjge_else.52494:
	ldi	%g4, %g23, -468
	fdiv	%f10, %f0, %f19
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
fjge_cont.52495:
	ldi	%g3, %g23, -456
	ldi	%g3, %g3, 0
	fldi	%f1, %g3, 0
	fldi	%f0, %g22, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g3, -4
	fldi	%f0, %g22, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g3, -8
	fldi	%f0, %g22, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fjlt	%f0, %f16, fjge_else.52496
	ldi	%g4, %g23, -456
	fdiv	%f10, %f0, %f18
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
	jmp	fjge_cont.52497
fjge_else.52496:
	ldi	%g4, %g23, -460
	fdiv	%f10, %f0, %f19
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
fjge_cont.52497:
	addi	%g3, %g0, 112
	mov	%g25, %g3
	subi	%g1, %g1, 48
	call	iter_trace_diffuse_rays.2963
	addi	%g1, %g1, 48
jeq_cont.52481:
	addi	%g3, %g0, 4
	jne	%g30, %g3, jeq_else.52498
	jmp	jeq_cont.52499
jeq_else.52498:
	ldi	%g23, %g31, 700
	ldi	%g24, %g1, 40
	fldi	%f0, %g24, 0
	fsti	%f0, %g31, 636
	fldi	%f0, %g24, -4
	fsti	%f0, %g31, 632
	fldi	%f0, %g24, -8
	fsti	%f0, %g31, 628
	ldi	%g3, %g31, 28
	subi	%g3, %g3, 1
	jlt	%g3, %g0, jge_else.52500
	slli	%g4, %g3, 2
	add	%g4, %g31, %g4
	ldi	%g4, %g4, 272
	ldi	%g7, %g4, -40
	ldi	%g6, %g4, -4
	fldi	%f1, %g24, 0
	ldi	%g5, %g4, -20
	fldi	%f0, %g5, 0
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, 0
	fldi	%f1, %g24, -4
	fldi	%f0, %g5, -4
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, -4
	fldi	%f1, %g24, -8
	fldi	%f0, %g5, -8
	fsub	%f0, %f1, %f0
	fsti	%f0, %g7, -8
	addi	%g5, %g0, 2
	jne	%g6, %g5, jeq_else.52502
	ldi	%g4, %g4, -16
	fldi	%f1, %g7, 0
	fldi	%f3, %g7, -4
	fldi	%f2, %g7, -8
	fldi	%f0, %g4, 0
	fmul	%f1, %f0, %f1
	fldi	%f0, %g4, -4
	fmul	%f0, %f0, %f3
	fadd	%f1, %f1, %f0
	fldi	%f0, %g4, -8
	fmul	%f0, %f0, %f2
	fadd	%f0, %f1, %f0
	fsti	%f0, %g7, -12
	jmp	jeq_cont.52503
jeq_else.52502:
	addi	%g5, %g0, 2
	jlt	%g5, %g6, jle_else.52504
	jmp	jle_cont.52505
jle_else.52504:
	fldi	%f2, %g7, 0
	fldi	%f1, %g7, -4
	fldi	%f0, %g7, -8
	fmul	%f4, %f2, %f2
	ldi	%g5, %g4, -16
	fldi	%f3, %g5, 0
	fmul	%f5, %f4, %f3
	fmul	%f4, %f1, %f1
	fldi	%f3, %g5, -4
	fmul	%f3, %f4, %f3
	fadd	%f5, %f5, %f3
	fmul	%f4, %f0, %f0
	fldi	%f3, %g5, -8
	fmul	%f3, %f4, %f3
	fadd	%f4, %f5, %f3
	ldi	%g5, %g4, -12
	jne	%g5, %g0, jeq_else.52506
	fmov	%f3, %f4
	jmp	jeq_cont.52507
jeq_else.52506:
	fmul	%f5, %f1, %f0
	ldi	%g4, %g4, -36
	fldi	%f3, %g4, 0
	fmul	%f3, %f5, %f3
	fadd	%f4, %f4, %f3
	fmul	%f3, %f0, %f2
	fldi	%f0, %g4, -4
	fmul	%f0, %f3, %f0
	fadd	%f4, %f4, %f0
	fmul	%f1, %f2, %f1
	fldi	%f0, %g4, -8
	fmul	%f3, %f1, %f0
	fadd	%f3, %f4, %f3
jeq_cont.52507:
	addi	%g4, %g0, 3
	jne	%g6, %g4, jeq_else.52508
	fsub	%f0, %f3, %f17
	jmp	jeq_cont.52509
jeq_else.52508:
	fmov	%f0, %f3
jeq_cont.52509:
	fsti	%f0, %g7, -12
jle_cont.52505:
jeq_cont.52503:
	subi	%g4, %g3, 1
	mov	%g3, %g24
	subi	%g1, %g1, 48
	call	setup_startp_constants.2865
	addi	%g1, %g1, 48
	jmp	jge_cont.52501
jge_else.52500:
jge_cont.52501:
	ldi	%g3, %g23, -472
	ldi	%g3, %g3, 0
	fldi	%f1, %g3, 0
	ldi	%g22, %g1, 36
	fldi	%f0, %g22, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g3, -4
	fldi	%f0, %g22, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g3, -8
	fldi	%f0, %g22, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fjlt	%f0, %f16, fjge_else.52510
	ldi	%g4, %g23, -472
	fdiv	%f10, %f0, %f18
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
	jmp	fjge_cont.52511
fjge_else.52510:
	ldi	%g4, %g23, -476
	fdiv	%f10, %f0, %f19
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
fjge_cont.52511:
	ldi	%g3, %g23, -464
	ldi	%g3, %g3, 0
	fldi	%f1, %g3, 0
	fldi	%f0, %g22, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g3, -4
	fldi	%f0, %g22, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g3, -8
	fldi	%f0, %g22, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fjlt	%f0, %f16, fjge_else.52512
	ldi	%g4, %g23, -464
	fdiv	%f10, %f0, %f18
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
	jmp	fjge_cont.52513
fjge_else.52512:
	ldi	%g4, %g23, -468
	fdiv	%f10, %f0, %f19
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
fjge_cont.52513:
	ldi	%g3, %g23, -456
	ldi	%g3, %g3, 0
	fldi	%f1, %g3, 0
	fldi	%f0, %g22, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g3, -4
	fldi	%f0, %g22, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g3, -8
	fldi	%f0, %g22, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fjlt	%f0, %f16, fjge_else.52514
	ldi	%g4, %g23, -456
	fdiv	%f10, %f0, %f18
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
	jmp	fjge_cont.52515
fjge_else.52514:
	ldi	%g4, %g23, -460
	fdiv	%f10, %f0, %f19
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 48
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 48
fjge_cont.52515:
	addi	%g30, %g0, 112
	mov	%g25, %g30
	subi	%g1, %g1, 48
	call	iter_trace_diffuse_rays.2963
	addi	%g1, %g1, 48
jeq_cont.52499:
	slli	%g3, %g26, 2
	ldi	%g11, %g1, 32
	ld	%g3, %g11, %g3
	fldi	%f2, %g31, 592
	fldi	%f1, %g3, 0
	fldi	%f0, %g31, 580
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fsti	%f0, %g31, 592
	fldi	%f2, %g31, 588
	fldi	%f1, %g3, -4
	fldi	%f0, %g31, 576
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fsti	%f0, %g31, 588
	fldi	%f2, %g31, 584
	fldi	%f1, %g3, -8
	fldi	%f0, %g31, 572
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fsti	%f0, %g31, 584
jeq_cont.52425:
	addi	%g26, %g26, 1
	ldi	%g15, %g1, 28
	ldi	%g14, %g1, 24
	ldi	%g13, %g1, 20
	ldi	%g12, %g1, 16
	ldi	%g11, %g1, 12
	ldi	%g10, %g1, 8
	ldi	%g9, %g1, 4
	ldi	%g25, %g1, 0
	jmp	do_without_neighbors.2985
jge_else.52423:
	return
jle_else.52422:
	return

!==============================
! args = [%g4, %g10, %g9, %g5, %g8, %g26]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f29, %f28, %f27, %f26, %f25, %f24, %f23, %f22, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
try_exploit_neighbors.3001:
	slli	%g3, %g4, 2
	ld	%g6, %g5, %g3
	addi	%g3, %g0, 4
	jlt	%g3, %g26, jle_else.52518
	ldi	%g7, %g6, -8
	slli	%g3, %g26, 2
	ld	%g3, %g7, %g3
	jlt	%g3, %g0, jge_else.52519
	slli	%g7, %g4, 2
	ld	%g7, %g9, %g7
	ldi	%g12, %g7, -8
	slli	%g11, %g26, 2
	ld	%g11, %g12, %g11
	jne	%g11, %g3, jeq_else.52520
	slli	%g11, %g4, 2
	ld	%g11, %g8, %g11
	ldi	%g12, %g11, -8
	slli	%g11, %g26, 2
	ld	%g11, %g12, %g11
	jne	%g11, %g3, jeq_else.52522
	subi	%g11, %g4, 1
	slli	%g11, %g11, 2
	ld	%g11, %g5, %g11
	ldi	%g12, %g11, -8
	slli	%g11, %g26, 2
	ld	%g11, %g12, %g11
	jne	%g11, %g3, jeq_else.52524
	addi	%g11, %g4, 1
	slli	%g11, %g11, 2
	ld	%g11, %g5, %g11
	ldi	%g12, %g11, -8
	slli	%g11, %g26, 2
	ld	%g11, %g12, %g11
	jne	%g11, %g3, jeq_else.52526
	addi	%g11, %g0, 1
	jmp	jeq_cont.52527
jeq_else.52526:
	addi	%g11, %g0, 0
jeq_cont.52527:
	jmp	jeq_cont.52525
jeq_else.52524:
	addi	%g11, %g0, 0
jeq_cont.52525:
	jmp	jeq_cont.52523
jeq_else.52522:
	addi	%g11, %g0, 0
jeq_cont.52523:
	jmp	jeq_cont.52521
jeq_else.52520:
	addi	%g11, %g0, 0
jeq_cont.52521:
	jne	%g11, %g0, jeq_else.52528
	slli	%g3, %g4, 2
	ld	%g3, %g5, %g3
	ldi	%g25, %g3, -28
	ldi	%g9, %g3, -24
	ldi	%g10, %g3, -20
	ldi	%g11, %g3, -16
	ldi	%g12, %g3, -12
	ldi	%g13, %g3, -8
	ldi	%g14, %g3, -4
	ldi	%g15, %g3, 0
	jmp	do_without_neighbors.2985
jeq_else.52528:
	ldi	%g11, %g6, -12
	slli	%g3, %g26, 2
	ld	%g3, %g11, %g3
	jne	%g3, %g0, jeq_else.52529
	jmp	jeq_cont.52530
jeq_else.52529:
	ldi	%g7, %g7, -20
	subi	%g3, %g4, 1
	slli	%g3, %g3, 2
	ld	%g3, %g5, %g3
	ldi	%g11, %g3, -20
	ldi	%g6, %g6, -20
	addi	%g3, %g4, 1
	slli	%g3, %g3, 2
	ld	%g3, %g5, %g3
	ldi	%g12, %g3, -20
	slli	%g3, %g4, 2
	ld	%g3, %g8, %g3
	ldi	%g13, %g3, -20
	slli	%g3, %g26, 2
	ld	%g3, %g7, %g3
	fldi	%f0, %g3, 0
	fsti	%f0, %g31, 580
	fldi	%f0, %g3, -4
	fsti	%f0, %g31, 576
	fldi	%f0, %g3, -8
	fsti	%f0, %g31, 572
	slli	%g3, %g26, 2
	ld	%g3, %g11, %g3
	fldi	%f1, %g31, 580
	fldi	%f0, %g3, 0
	fadd	%f0, %f1, %f0
	fsti	%f0, %g31, 580
	fldi	%f1, %g31, 576
	fldi	%f0, %g3, -4
	fadd	%f0, %f1, %f0
	fsti	%f0, %g31, 576
	fldi	%f1, %g31, 572
	fldi	%f0, %g3, -8
	fadd	%f0, %f1, %f0
	fsti	%f0, %g31, 572
	slli	%g3, %g26, 2
	ld	%g3, %g6, %g3
	fldi	%f1, %g31, 580
	fldi	%f0, %g3, 0
	fadd	%f0, %f1, %f0
	fsti	%f0, %g31, 580
	fldi	%f1, %g31, 576
	fldi	%f0, %g3, -4
	fadd	%f0, %f1, %f0
	fsti	%f0, %g31, 576
	fldi	%f1, %g31, 572
	fldi	%f0, %g3, -8
	fadd	%f0, %f1, %f0
	fsti	%f0, %g31, 572
	slli	%g3, %g26, 2
	ld	%g3, %g12, %g3
	fldi	%f1, %g31, 580
	fldi	%f0, %g3, 0
	fadd	%f0, %f1, %f0
	fsti	%f0, %g31, 580
	fldi	%f1, %g31, 576
	fldi	%f0, %g3, -4
	fadd	%f0, %f1, %f0
	fsti	%f0, %g31, 576
	fldi	%f1, %g31, 572
	fldi	%f0, %g3, -8
	fadd	%f0, %f1, %f0
	fsti	%f0, %g31, 572
	slli	%g3, %g26, 2
	ld	%g3, %g13, %g3
	fldi	%f1, %g31, 580
	fldi	%f0, %g3, 0
	fadd	%f0, %f1, %f0
	fsti	%f0, %g31, 580
	fldi	%f1, %g31, 576
	fldi	%f0, %g3, -4
	fadd	%f0, %f1, %f0
	fsti	%f0, %g31, 576
	fldi	%f1, %g31, 572
	fldi	%f0, %g3, -8
	fadd	%f0, %f1, %f0
	fsti	%f0, %g31, 572
	slli	%g3, %g4, 2
	ld	%g3, %g5, %g3
	ldi	%g6, %g3, -16
	slli	%g3, %g26, 2
	ld	%g3, %g6, %g3
	fldi	%f2, %g31, 592
	fldi	%f1, %g3, 0
	fldi	%f0, %g31, 580
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fsti	%f0, %g31, 592
	fldi	%f2, %g31, 588
	fldi	%f1, %g3, -4
	fldi	%f0, %g31, 576
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fsti	%f0, %g31, 588
	fldi	%f2, %g31, 584
	fldi	%f1, %g3, -8
	fldi	%f0, %g31, 572
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fsti	%f0, %g31, 584
jeq_cont.52530:
	addi	%g26, %g26, 1
	jmp	try_exploit_neighbors.3001
jge_else.52519:
	return
jle_else.52518:
	return

!==============================
! args = [%g14, %g12, %g11, %g10, %g13, %g9, %g25, %g30, %g26]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f29, %f28, %f27, %f26, %f25, %f24, %f23, %f22, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
pretrace_diffuse_rays.3014:
	addi	%g3, %g0, 4
	jlt	%g3, %g26, jle_else.52533
	slli	%g3, %g26, 2
	ld	%g3, %g11, %g3
	jlt	%g3, %g0, jge_else.52534
	slli	%g3, %g26, 2
	ld	%g3, %g10, %g3
	sti	%g25, %g1, 0
	sti	%g13, %g1, 4
	sti	%g10, %g1, 8
	sti	%g11, %g1, 12
	sti	%g12, %g1, 16
	sti	%g14, %g1, 20
	jne	%g3, %g0, jeq_else.52535
	jmp	jeq_cont.52536
jeq_else.52535:
	ldi	%g3, %g25, 0
	fsti	%f16, %g31, 580
	fsti	%f16, %g31, 576
	fsti	%f16, %g31, 572
	slli	%g3, %g3, 2
	add	%g3, %g31, %g3
	ldi	%g23, %g3, 716
	slli	%g3, %g26, 2
	ld	%g22, %g30, %g3
	slli	%g3, %g26, 2
	ld	%g24, %g12, %g3
	fldi	%f0, %g24, 0
	fsti	%f0, %g31, 636
	fldi	%f0, %g24, -4
	fsti	%f0, %g31, 632
	fldi	%f0, %g24, -8
	fsti	%f0, %g31, 628
	ldi	%g3, %g31, 28
	subi	%g7, %g3, 1
	jlt	%g7, %g0, jge_else.52537
	slli	%g3, %g7, 2
	add	%g3, %g31, %g3
	ldi	%g3, %g3, 272
	ldi	%g6, %g3, -40
	ldi	%g5, %g3, -4
	fldi	%f1, %g24, 0
	ldi	%g4, %g3, -20
	fldi	%f0, %g4, 0
	fsub	%f0, %f1, %f0
	fsti	%f0, %g6, 0
	fldi	%f1, %g24, -4
	fldi	%f0, %g4, -4
	fsub	%f0, %f1, %f0
	fsti	%f0, %g6, -4
	fldi	%f1, %g24, -8
	fldi	%f0, %g4, -8
	fsub	%f0, %f1, %f0
	fsti	%f0, %g6, -8
	addi	%g4, %g0, 2
	jne	%g5, %g4, jeq_else.52539
	ldi	%g3, %g3, -16
	fldi	%f1, %g6, 0
	fldi	%f3, %g6, -4
	fldi	%f2, %g6, -8
	fldi	%f0, %g3, 0
	fmul	%f1, %f0, %f1
	fldi	%f0, %g3, -4
	fmul	%f0, %f0, %f3
	fadd	%f1, %f1, %f0
	fldi	%f0, %g3, -8
	fmul	%f0, %f0, %f2
	fadd	%f0, %f1, %f0
	fsti	%f0, %g6, -12
	jmp	jeq_cont.52540
jeq_else.52539:
	addi	%g4, %g0, 2
	jlt	%g4, %g5, jle_else.52541
	jmp	jle_cont.52542
jle_else.52541:
	fldi	%f2, %g6, 0
	fldi	%f1, %g6, -4
	fldi	%f0, %g6, -8
	fmul	%f4, %f2, %f2
	ldi	%g4, %g3, -16
	fldi	%f3, %g4, 0
	fmul	%f5, %f4, %f3
	fmul	%f4, %f1, %f1
	fldi	%f3, %g4, -4
	fmul	%f3, %f4, %f3
	fadd	%f5, %f5, %f3
	fmul	%f4, %f0, %f0
	fldi	%f3, %g4, -8
	fmul	%f3, %f4, %f3
	fadd	%f4, %f5, %f3
	ldi	%g4, %g3, -12
	jne	%g4, %g0, jeq_else.52543
	fmov	%f3, %f4
	jmp	jeq_cont.52544
jeq_else.52543:
	fmul	%f5, %f1, %f0
	ldi	%g3, %g3, -36
	fldi	%f3, %g3, 0
	fmul	%f3, %f5, %f3
	fadd	%f4, %f4, %f3
	fmul	%f3, %f0, %f2
	fldi	%f0, %g3, -4
	fmul	%f0, %f3, %f0
	fadd	%f4, %f4, %f0
	fmul	%f1, %f2, %f1
	fldi	%f0, %g3, -8
	fmul	%f3, %f1, %f0
	fadd	%f3, %f4, %f3
jeq_cont.52544:
	addi	%g3, %g0, 3
	jne	%g5, %g3, jeq_else.52545
	fsub	%f0, %f3, %f17
	jmp	jeq_cont.52546
jeq_else.52545:
	fmov	%f0, %f3
jeq_cont.52546:
	fsti	%f0, %g6, -12
jle_cont.52542:
jeq_cont.52540:
	subi	%g4, %g7, 1
	mov	%g3, %g24
	subi	%g1, %g1, 28
	call	setup_startp_constants.2865
	addi	%g1, %g1, 28
	jmp	jge_cont.52538
jge_else.52537:
jge_cont.52538:
	ldi	%g3, %g23, -472
	ldi	%g3, %g3, 0
	fldi	%f1, %g3, 0
	fldi	%f0, %g22, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g3, -4
	fldi	%f0, %g22, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g3, -8
	fldi	%f0, %g22, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	sti	%g9, %g1, 24
	fjlt	%f0, %f16, fjge_else.52547
	ldi	%g4, %g23, -472
	fdiv	%f10, %f0, %f18
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 32
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 32
	jmp	fjge_cont.52548
fjge_else.52547:
	ldi	%g4, %g23, -476
	fdiv	%f10, %f0, %f19
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 32
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 32
fjge_cont.52548:
	ldi	%g3, %g23, -464
	ldi	%g3, %g3, 0
	fldi	%f1, %g3, 0
	fldi	%f0, %g22, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g3, -4
	fldi	%f0, %g22, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g3, -8
	fldi	%f0, %g22, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fjlt	%f0, %f16, fjge_else.52549
	ldi	%g4, %g23, -464
	fdiv	%f10, %f0, %f18
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 32
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 32
	jmp	fjge_cont.52550
fjge_else.52549:
	ldi	%g4, %g23, -468
	fdiv	%f10, %f0, %f19
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 32
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 32
fjge_cont.52550:
	ldi	%g3, %g23, -456
	ldi	%g3, %g3, 0
	fldi	%f1, %g3, 0
	fldi	%f0, %g22, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g3, -4
	fldi	%f0, %g22, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g3, -8
	fldi	%f0, %g22, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fjlt	%f0, %f16, fjge_else.52551
	ldi	%g4, %g23, -456
	fdiv	%f10, %f0, %f18
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 32
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 32
	jmp	fjge_cont.52552
fjge_else.52551:
	ldi	%g4, %g23, -460
	fdiv	%f10, %f0, %f19
	ldi	%g3, %g4, -4
	ldi	%g21, %g4, 0
	subi	%g1, %g1, 32
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 32
fjge_cont.52552:
	addi	%g3, %g0, 112
	mov	%g25, %g3
	subi	%g1, %g1, 32
	call	iter_trace_diffuse_rays.2963
	addi	%g1, %g1, 32
	ldi	%g9, %g1, 24
	slli	%g3, %g26, 2
	ld	%g3, %g9, %g3
	fldi	%f0, %g31, 580
	fsti	%f0, %g3, 0
	fldi	%f0, %g31, 576
	fsti	%f0, %g3, -4
	fldi	%f0, %g31, 572
	fsti	%f0, %g3, -8
jeq_cont.52536:
	addi	%g26, %g26, 1
	ldi	%g14, %g1, 20
	ldi	%g12, %g1, 16
	ldi	%g11, %g1, 12
	ldi	%g10, %g1, 8
	ldi	%g13, %g1, 4
	ldi	%g25, %g1, 0
	jmp	pretrace_diffuse_rays.3014
jge_else.52534:
	return
jle_else.52533:
	return

!==============================
! args = [%g7, %g6, %g8]
! fargs = [%f13, %f12, %f11]
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f29, %f28, %f27, %f26, %f25, %f24, %f23, %f22, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
pretrace_pixels.3017:
	jlt	%g6, %g0, jge_else.52555
	fldi	%f3, %g31, 612
	ldi	%g3, %g31, 608
	sub	%g3, %g6, %g3
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fmul	%f0, %f3, %f0
	fldi	%f1, %g31, 648
	fmul	%f1, %f0, %f1
	fadd	%f1, %f1, %f13
	fsti	%f1, %g31, 684
	fldi	%f1, %g31, 644
	fmul	%f1, %f0, %f1
	fadd	%f1, %f1, %f12
	fsti	%f1, %g31, 680
	fldi	%f1, %g31, 640
	fmul	%f0, %f0, %f1
	fadd	%f0, %f0, %f11
	fsti	%f0, %g31, 676
	fldi	%f2, %g31, 684
	fmul	%f1, %f2, %f2
	fldi	%f0, %g31, 680
	fmul	%f0, %f0, %f0
	fadd	%f1, %f1, %f0
	fldi	%f0, %g31, 676
	fmul	%f0, %f0, %f0
	fadd	%f0, %f1, %f0
	fsqrt	%f0, %f0
	fjeq	%f0, %f16, fjne_else.52556
	fdiv	%f1, %f17, %f0
	jmp	fjne_cont.52557
fjne_else.52556:
	setL %g3, l.42861
	fldi	%f1, %g3, 0
fjne_cont.52557:
	fmul	%f0, %f2, %f1
	fsti	%f0, %g31, 684
	fldi	%f0, %g31, 680
	fmul	%f0, %f0, %f1
	fsti	%f0, %g31, 680
	fldi	%f0, %g31, 676
	fmul	%f0, %f0, %f1
	fsti	%f0, %g31, 676
	fsti	%f16, %g31, 592
	fsti	%f16, %g31, 588
	fsti	%f16, %g31, 584
	fldi	%f0, %g31, 296
	fsti	%f0, %g31, 624
	fldi	%f0, %g31, 292
	fsti	%f0, %g31, 620
	fldi	%f0, %g31, 288
	fsti	%f0, %g31, 616
	addi	%g25, %g0, 0
	slli	%g3, %g6, 2
	ld	%g3, %g7, %g3
	ldi	%g16, %g3, -28
	ldi	%g21, %g3, -24
	ldi	%g23, %g3, -20
	ldi	%g17, %g3, -16
	ldi	%g18, %g3, -12
	ldi	%g19, %g3, -8
	ldi	%g20, %g3, -4
	ldi	%g24, %g3, 0
	subi	%g22, %g31, 684
	fsti	%f11, %g1, 0
	fsti	%f12, %g1, 4
	fsti	%f13, %g1, 8
	sti	%g8, %g1, 12
	sti	%g7, %g1, 16
	sti	%g6, %g1, 20
	fmov	%f14, %f16
	fmov	%f13, %f17
	subi	%g1, %g1, 28
	call	trace_ray.2954
	addi	%g1, %g1, 28
	ldi	%g6, %g1, 20
	slli	%g3, %g6, 2
	ldi	%g7, %g1, 16
	ld	%g3, %g7, %g3
	ldi	%g3, %g3, 0
	fldi	%f0, %g31, 592
	fsti	%f0, %g3, 0
	fldi	%f0, %g31, 588
	fsti	%f0, %g3, -4
	fldi	%f0, %g31, 584
	fsti	%f0, %g3, -8
	slli	%g3, %g6, 2
	ld	%g3, %g7, %g3
	ldi	%g3, %g3, -24
	ldi	%g8, %g1, 12
	sti	%g8, %g3, 0
	slli	%g3, %g6, 2
	ld	%g3, %g7, %g3
	addi	%g26, %g0, 0
	ldi	%g30, %g3, -28
	ldi	%g25, %g3, -24
	ldi	%g9, %g3, -20
	ldi	%g13, %g3, -16
	ldi	%g10, %g3, -12
	ldi	%g11, %g3, -8
	ldi	%g12, %g3, -4
	ldi	%g14, %g3, 0
	subi	%g1, %g1, 28
	call	pretrace_diffuse_rays.3014
	addi	%g1, %g1, 28
	ldi	%g6, %g1, 20
	subi	%g6, %g6, 1
	ldi	%g8, %g1, 12
	addi	%g3, %g8, 1
	addi	%g8, %g0, 5
	jlt	%g3, %g8, jle_else.52558
	subi	%g8, %g3, 5
	jmp	jle_cont.52559
jle_else.52558:
	mov	%g8, %g3
jle_cont.52559:
	fldi	%f13, %g1, 8
	fldi	%f12, %g1, 4
	fldi	%f11, %g1, 0
	ldi	%g7, %g1, 16
	jmp	pretrace_pixels.3017
jge_else.52555:
	return

!==============================
! args = [%g15, %g16, %g18, %g17, %g19]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f29, %f28, %f27, %f26, %f25, %f24, %f23, %f22, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
scan_pixel.3028:
	ldi	%g3, %g31, 600
	jlt	%g15, %g3, jle_else.52561
	return
jle_else.52561:
	slli	%g3, %g15, 2
	ld	%g3, %g17, %g3
	ldi	%g3, %g3, 0
	fldi	%f0, %g3, 0
	fsti	%f0, %g31, 592
	fldi	%f0, %g3, -4
	fsti	%f0, %g31, 588
	fldi	%f0, %g3, -8
	fsti	%f0, %g31, 584
	ldi	%g4, %g31, 596
	addi	%g3, %g16, 1
	jlt	%g3, %g4, jle_else.52563
	addi	%g3, %g0, 0
	jmp	jle_cont.52564
jle_else.52563:
	jlt	%g0, %g16, jle_else.52565
	addi	%g3, %g0, 0
	jmp	jle_cont.52566
jle_else.52565:
	ldi	%g4, %g31, 600
	addi	%g3, %g15, 1
	jlt	%g3, %g4, jle_else.52567
	addi	%g3, %g0, 0
	jmp	jle_cont.52568
jle_else.52567:
	jlt	%g0, %g15, jle_else.52569
	addi	%g3, %g0, 0
	jmp	jle_cont.52570
jle_else.52569:
	addi	%g3, %g0, 1
jle_cont.52570:
jle_cont.52568:
jle_cont.52566:
jle_cont.52564:
	sti	%g19, %g1, 0
	sti	%g17, %g1, 4
	sti	%g18, %g1, 8
	sti	%g16, %g1, 12
	sti	%g15, %g1, 16
	jne	%g3, %g0, jeq_else.52571
	slli	%g3, %g15, 2
	ld	%g3, %g17, %g3
	addi	%g26, %g0, 0
	ldi	%g25, %g3, -28
	ldi	%g9, %g3, -24
	ldi	%g10, %g3, -20
	ldi	%g11, %g3, -16
	ldi	%g12, %g3, -12
	ldi	%g13, %g3, -8
	ldi	%g14, %g3, -4
	ldi	%g3, %g3, 0
	mov	%g15, %g3
	subi	%g1, %g1, 24
	call	do_without_neighbors.2985
	addi	%g1, %g1, 24
	jmp	jeq_cont.52572
jeq_else.52571:
	addi	%g26, %g0, 0
	mov	%g8, %g19
	mov	%g5, %g17
	mov	%g9, %g18
	mov	%g10, %g16
	mov	%g4, %g15
	subi	%g1, %g1, 24
	call	try_exploit_neighbors.3001
	addi	%g1, %g1, 24
jeq_cont.52572:
	fldi	%f0, %g31, 592
	subi	%g1, %g1, 24
	call	min_caml_int_of_float
	addi	%g1, %g1, 24
	addi	%g4, %g0, 255
	jlt	%g4, %g3, jle_else.52573
	jlt	%g3, %g0, jge_else.52575
	mov	%g4, %g3
	jmp	jge_cont.52576
jge_else.52575:
	addi	%g4, %g0, 0
jge_cont.52576:
	jmp	jle_cont.52574
jle_else.52573:
	addi	%g4, %g0, 255
jle_cont.52574:
	subi	%g1, %g1, 24
	call	print_int.2587
	addi	%g3, %g0, 32
	output	%g3
	fldi	%f0, %g31, 588
	call	min_caml_int_of_float
	addi	%g1, %g1, 24
	addi	%g4, %g0, 255
	jlt	%g4, %g3, jle_else.52577
	jlt	%g3, %g0, jge_else.52579
	mov	%g4, %g3
	jmp	jge_cont.52580
jge_else.52579:
	addi	%g4, %g0, 0
jge_cont.52580:
	jmp	jle_cont.52578
jle_else.52577:
	addi	%g4, %g0, 255
jle_cont.52578:
	subi	%g1, %g1, 24
	call	print_int.2587
	addi	%g3, %g0, 32
	output	%g3
	fldi	%f0, %g31, 584
	call	min_caml_int_of_float
	addi	%g1, %g1, 24
	addi	%g4, %g0, 255
	jlt	%g4, %g3, jle_else.52581
	jlt	%g3, %g0, jge_else.52583
	mov	%g4, %g3
	jmp	jge_cont.52584
jge_else.52583:
	addi	%g4, %g0, 0
jge_cont.52584:
	jmp	jle_cont.52582
jle_else.52581:
	addi	%g4, %g0, 255
jle_cont.52582:
	subi	%g1, %g1, 24
	call	print_int.2587
	addi	%g1, %g1, 24
	addi	%g3, %g0, 10
	output	%g3
	ldi	%g15, %g1, 16
	addi	%g15, %g15, 1
	ldi	%g16, %g1, 12
	ldi	%g18, %g1, 8
	ldi	%g17, %g1, 4
	ldi	%g19, %g1, 0
	jmp	scan_pixel.3028

!==============================
! args = [%g16, %g7, %g18, %g17, %g8]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f30, %f3, %f29, %f28, %f27, %f26, %f25, %f24, %f23, %f22, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
scan_line.3034:
	ldi	%g3, %g31, 596
	jlt	%g16, %g3, jle_else.52585
	return
jle_else.52585:
	subi	%g3, %g3, 1
	sti	%g8, %g1, 0
	sti	%g17, %g1, 4
	sti	%g18, %g1, 8
	sti	%g7, %g1, 12
	sti	%g16, %g1, 16
	jlt	%g16, %g3, jle_else.52587
	jmp	jle_cont.52588
jle_else.52587:
	addi	%g4, %g16, 1
	fldi	%f3, %g31, 612
	ldi	%g3, %g31, 604
	sub	%g3, %g4, %g3
	subi	%g1, %g1, 24
	call	min_caml_float_of_int
	fmul	%f0, %f3, %f0
	fldi	%f1, %g31, 660
	fmul	%f2, %f0, %f1
	fldi	%f1, %g31, 672
	fadd	%f13, %f2, %f1
	fldi	%f1, %g31, 656
	fmul	%f2, %f0, %f1
	fldi	%f1, %g31, 668
	fadd	%f12, %f2, %f1
	fldi	%f1, %g31, 652
	fmul	%f1, %f0, %f1
	fldi	%f0, %g31, 664
	fadd	%f11, %f1, %f0
	ldi	%g3, %g31, 600
	subi	%g6, %g3, 1
	mov	%g7, %g17
	call	pretrace_pixels.3017
	addi	%g1, %g1, 24
jle_cont.52588:
	addi	%g15, %g0, 0
	ldi	%g16, %g1, 16
	ldi	%g7, %g1, 12
	ldi	%g18, %g1, 8
	ldi	%g17, %g1, 4
	mov	%g19, %g17
	mov	%g17, %g18
	mov	%g18, %g7
	subi	%g1, %g1, 24
	call	scan_pixel.3028
	addi	%g1, %g1, 24
	ldi	%g16, %g1, 16
	addi	%g16, %g16, 1
	ldi	%g8, %g1, 0
	addi	%g3, %g8, 2
	addi	%g8, %g0, 5
	jlt	%g3, %g8, jle_else.52589
	subi	%g8, %g3, 5
	jmp	jle_cont.52590
jle_else.52589:
	mov	%g8, %g3
jle_cont.52590:
	ldi	%g3, %g31, 596
	jlt	%g16, %g3, jle_else.52591
	return
jle_else.52591:
	subi	%g3, %g3, 1
	sti	%g8, %g1, 20
	sti	%g16, %g1, 24
	jlt	%g16, %g3, jle_else.52593
	jmp	jle_cont.52594
jle_else.52593:
	addi	%g4, %g16, 1
	fldi	%f3, %g31, 612
	ldi	%g3, %g31, 604
	sub	%g3, %g4, %g3
	subi	%g1, %g1, 32
	call	min_caml_float_of_int
	addi	%g1, %g1, 32
	fmul	%f0, %f3, %f0
	fldi	%f1, %g31, 660
	fmul	%f2, %f0, %f1
	fldi	%f1, %g31, 672
	fadd	%f13, %f2, %f1
	fldi	%f1, %g31, 656
	fmul	%f2, %f0, %f1
	fldi	%f1, %g31, 668
	fadd	%f12, %f2, %f1
	fldi	%f1, %g31, 652
	fmul	%f1, %f0, %f1
	fldi	%f0, %g31, 664
	fadd	%f11, %f1, %f0
	ldi	%g3, %g31, 600
	subi	%g6, %g3, 1
	ldi	%g7, %g1, 12
	subi	%g1, %g1, 32
	call	pretrace_pixels.3017
	addi	%g1, %g1, 32
jle_cont.52594:
	addi	%g15, %g0, 0
	ldi	%g16, %g1, 24
	ldi	%g18, %g1, 8
	ldi	%g17, %g1, 4
	ldi	%g7, %g1, 12
	mov	%g19, %g7
	subi	%g1, %g1, 32
	call	scan_pixel.3028
	addi	%g1, %g1, 32
	ldi	%g16, %g1, 24
	addi	%g16, %g16, 1
	ldi	%g8, %g1, 20
	addi	%g4, %g8, 2
	addi	%g3, %g0, 5
	jlt	%g4, %g3, jle_else.52595
	subi	%g3, %g4, 5
	jmp	jle_cont.52596
jle_else.52595:
	mov	%g3, %g4
jle_cont.52596:
	ldi	%g17, %g1, 4
	ldi	%g7, %g1, 12
	ldi	%g18, %g1, 8
	mov	%g8, %g3
	mov	%g27, %g17
	mov	%g17, %g18
	mov	%g18, %g7
	mov	%g7, %g27
	jmp	scan_line.3034

!==============================
! args = [%g10, %g9]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g2, %g14, %g13, %g12, %g11, %g10, %f16, %f15, %f0, %dummy]
! ret type = Array((Array(Float) * Array(Array(Float)) * Array(Int) * Array(Bool) * Array(Array(Float)) * Array(Array(Float)) * Array(Int) * Array(Array(Float))))
!================================
init_line_elements.3044:
	jlt	%g9, %g0, jge_else.52597
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	mov	%g13, %g3
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g4, %g3
	addi	%g3, %g0, 5
	call	min_caml_create_array
	mov	%g8, %g3
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g8, -4
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g8, -8
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g8, -12
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g8, -16
	addi	%g3, %g0, 5
	addi	%g4, %g0, 0
	call	min_caml_create_array
	mov	%g12, %g3
	addi	%g3, %g0, 5
	addi	%g4, %g0, 0
	call	min_caml_create_array
	mov	%g11, %g3
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g4, %g3
	addi	%g3, %g0, 5
	call	min_caml_create_array
	mov	%g7, %g3
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g7, -4
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g7, -8
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g7, -12
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g7, -16
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g4, %g3
	addi	%g3, %g0, 5
	call	min_caml_create_array
	mov	%g6, %g3
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g6, -4
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g6, -8
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g6, -12
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g6, -16
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	call	min_caml_create_array
	mov	%g14, %g3
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g4, %g3
	addi	%g3, %g0, 5
	call	min_caml_create_array
	mov	%g5, %g3
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g5, -4
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g5, -8
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	sti	%g3, %g5, -12
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	sti	%g3, %g5, -16
	mov	%g3, %g2
	addi	%g2, %g2, 32
	sti	%g5, %g3, -28
	sti	%g14, %g3, -24
	sti	%g6, %g3, -20
	sti	%g7, %g3, -16
	sti	%g11, %g3, -12
	sti	%g12, %g3, -8
	sti	%g8, %g3, -4
	sti	%g13, %g3, 0
	slli	%g4, %g9, 2
	st	%g3, %g10, %g4
	subi	%g9, %g9, 1
	jmp	init_line_elements.3044
jge_else.52597:
	mov	%g3, %g10
	return

!==============================
! args = [%g4, %g5, %g3]
! fargs = [%f5, %f1, %f2, %f0]
! use_regs = [%g7, %g6, %g5, %g4, %g3, %g27, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f3, %f28, %f26, %f25, %f24, %f23, %f22, %f20, %f2, %f17, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
calc_dirvec.3052:
	fsti	%f0, %g1, 0
	fsti	%f2, %g1, 4
	addi	%g6, %g0, 5
	jlt	%g4, %g6, jle_else.52598
	fmul	%f2, %f5, %f5
	fmul	%f0, %f1, %f1
	fadd	%f0, %f2, %f0
	fadd	%f0, %f0, %f17
	fsqrt	%f0, %f0
	fdiv	%f2, %f5, %f0
	fdiv	%f1, %f1, %f0
	fdiv	%f0, %f17, %f0
	slli	%g4, %g5, 2
	add	%g4, %g31, %g4
	ldi	%g5, %g4, 716
	slli	%g4, %g3, 2
	ld	%g4, %g5, %g4
	ldi	%g4, %g4, 0
	fsti	%f2, %g4, 0
	fsti	%f1, %g4, -4
	fsti	%f0, %g4, -8
	addi	%g4, %g3, 40
	slli	%g4, %g4, 2
	ld	%g4, %g5, %g4
	ldi	%g4, %g4, 0
	fneg	%f4, %f1
	fsti	%f2, %g4, 0
	fsti	%f0, %g4, -4
	fsti	%f4, %g4, -8
	addi	%g4, %g3, 80
	slli	%g4, %g4, 2
	ld	%g4, %g5, %g4
	ldi	%g4, %g4, 0
	fneg	%f3, %f2
	fsti	%f0, %g4, 0
	fsti	%f3, %g4, -4
	fsti	%f4, %g4, -8
	addi	%g4, %g3, 1
	slli	%g4, %g4, 2
	ld	%g4, %g5, %g4
	ldi	%g4, %g4, 0
	fneg	%f0, %f0
	fsti	%f3, %g4, 0
	fsti	%f4, %g4, -4
	fsti	%f0, %g4, -8
	addi	%g4, %g3, 41
	slli	%g4, %g4, 2
	ld	%g4, %g5, %g4
	ldi	%g4, %g4, 0
	fsti	%f3, %g4, 0
	fsti	%f0, %g4, -4
	fsti	%f1, %g4, -8
	addi	%g3, %g3, 81
	slli	%g3, %g3, 2
	ld	%g3, %g5, %g3
	ldi	%g3, %g3, 0
	fsti	%f0, %g3, 0
	fsti	%f2, %g3, -4
	fsti	%f1, %g3, -8
	return
jle_else.52598:
	fmul	%f0, %f1, %f1
	setL %g6, l.43078
	fldi	%f6, %g6, 0
	fadd	%f0, %f0, %f6
	fsqrt	%f5, %f0
	fdiv	%f0, %f17, %f5
	fjlt	%f17, %f0, fjge_else.52600
	fjlt	%f0, %f20, fjge_else.52602
	addi	%g6, %g0, 0
	jmp	fjge_cont.52603
fjge_else.52602:
	addi	%g6, %g0, -1
fjge_cont.52603:
	jmp	fjge_cont.52601
fjge_else.52600:
	addi	%g6, %g0, 1
fjge_cont.52601:
	jne	%g6, %g0, jeq_else.52604
	fmov	%f4, %f0
	jmp	jeq_cont.52605
jeq_else.52604:
	fdiv	%f4, %f17, %f0
jeq_cont.52605:
	fmul	%f0, %f4, %f4
	setL %g7, l.45544
	fldi	%f14, %g7, 0
	fmul	%f1, %f14, %f0
	setL %g7, l.45546
	fldi	%f15, %g7, 0
	fdiv	%f3, %f1, %f15
	setL %g7, l.45548
	fldi	%f1, %g7, 0
	fsti	%f1, %g1, 8
	fldi	%f1, %g1, 8
	fmul	%f2, %f1, %f0
	setL %g7, l.45550
	fldi	%f1, %g7, 0
	fsti	%f1, %g1, 12
	fldi	%f1, %g1, 12
	fadd	%f1, %f1, %f3
	fdiv	%f1, %f2, %f1
	setL %g7, l.45552
	fldi	%f11, %g7, 0
	fmul	%f2, %f11, %f0
	setL %g7, l.45554
	fldi	%f13, %g7, 0
	fadd	%f1, %f13, %f1
	fdiv	%f2, %f2, %f1
	setL %g7, l.45556
	fldi	%f12, %g7, 0
	fmul	%f3, %f12, %f0
	setL %g7, l.45558
	fldi	%f1, %g7, 0
	fsti	%f1, %g1, 16
	fldi	%f1, %g1, 16
	fadd	%f1, %f1, %f2
	fdiv	%f1, %f3, %f1
	setL %g7, l.45560
	fldi	%f9, %g7, 0
	fmul	%f2, %f9, %f0
	fadd	%f1, %f28, %f1
	fdiv	%f2, %f2, %f1
	setL %g7, l.45563
	fldi	%f10, %g7, 0
	fmul	%f3, %f10, %f0
	setL %g7, l.45565
	fldi	%f1, %g7, 0
	fsti	%f1, %g1, 20
	fldi	%f1, %g1, 20
	fadd	%f1, %f1, %f2
	fdiv	%f2, %f3, %f1
	setL %g7, l.45575
	fldi	%f1, %g7, 0
	fsti	%f1, %g1, 24
	setL %g7, l.45567
	fldi	%f8, %g7, 0
	fmul	%f3, %f8, %f0
	setL %g7, l.45569
	fldi	%f1, %g7, 0
	fsti	%f1, %g1, 28
	fldi	%f1, %g1, 28
	fadd	%f1, %f1, %f2
	fdiv	%f1, %f3, %f1
	setL %g7, l.45571
	fldi	%f7, %g7, 0
	fmul	%f2, %f7, %f0
	fadd	%f1, %f25, %f1
	fdiv	%f1, %f2, %f1
	fmul	%f2, %f25, %f0
	fadd	%f1, %f26, %f1
	fdiv	%f2, %f2, %f1
	fldi	%f1, %g1, 24
	fmul	%f3, %f1, %f0
	fadd	%f1, %f24, %f2
	fdiv	%f1, %f3, %f1
	fadd	%f1, %f23, %f1
	fdiv	%f0, %f0, %f1
	fadd	%f0, %f17, %f0
	fdiv	%f1, %f4, %f0
	jlt	%g0, %g6, jle_else.52606
	jlt	%g6, %g0, jge_else.52608
	fmov	%f0, %f1
	jmp	jge_cont.52609
jge_else.52608:
	fsub	%f0, %f31, %f1
jge_cont.52609:
	jmp	jle_cont.52607
jle_else.52606:
	fsub	%f0, %f22, %f1
jle_cont.52607:
	fldi	%f1, %g1, 4
	fmul	%f1, %f0, %f1
	fmul	%f0, %f1, %f1
	fdiv	%f2, %f0, %f25
	fsub	%f2, %f26, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f24, %f2
	fdiv	%f2, %f0, %f2
	fsub	%f2, %f23, %f2
	fdiv	%f0, %f0, %f2
	fsub	%f0, %f17, %f0
	fdiv	%f0, %f1, %f0
	fmul	%f5, %f0, %f5
	addi	%g4, %g4, 1
	fmul	%f0, %f5, %f5
	fadd	%f0, %f0, %f6
	fsqrt	%f6, %f0
	fdiv	%f0, %f17, %f6
	fjlt	%f17, %f0, fjge_else.52610
	fjlt	%f0, %f20, fjge_else.52612
	addi	%g6, %g0, 0
	jmp	fjge_cont.52613
fjge_else.52612:
	addi	%g6, %g0, -1
fjge_cont.52613:
	jmp	fjge_cont.52611
fjge_else.52610:
	addi	%g6, %g0, 1
fjge_cont.52611:
	jne	%g6, %g0, jeq_else.52614
	fmov	%f1, %f0
	jmp	jeq_cont.52615
jeq_else.52614:
	fdiv	%f1, %f17, %f0
jeq_cont.52615:
	fmul	%f0, %f1, %f1
	fmul	%f2, %f14, %f0
	fdiv	%f3, %f2, %f15
	fldi	%f2, %g1, 8
	fmul	%f4, %f2, %f0
	fldi	%f2, %g1, 12
	fadd	%f2, %f2, %f3
	fdiv	%f2, %f4, %f2
	fmul	%f3, %f11, %f0
	fadd	%f2, %f13, %f2
	fdiv	%f3, %f3, %f2
	fmul	%f4, %f12, %f0
	fldi	%f2, %g1, 16
	fadd	%f2, %f2, %f3
	fdiv	%f2, %f4, %f2
	fmul	%f3, %f9, %f0
	fadd	%f2, %f28, %f2
	fdiv	%f2, %f3, %f2
	fmul	%f3, %f10, %f0
	fldi	%f4, %g1, 20
	fadd	%f2, %f4, %f2
	fdiv	%f2, %f3, %f2
	fmul	%f4, %f8, %f0
	fldi	%f3, %g1, 28
	fadd	%f2, %f3, %f2
	fdiv	%f2, %f4, %f2
	fmul	%f3, %f7, %f0
	fadd	%f2, %f25, %f2
	fdiv	%f2, %f3, %f2
	fmul	%f3, %f25, %f0
	fadd	%f2, %f26, %f2
	fdiv	%f2, %f3, %f2
	fldi	%f3, %g1, 24
	fmul	%f3, %f3, %f0
	fadd	%f2, %f24, %f2
	fdiv	%f2, %f3, %f2
	fadd	%f2, %f23, %f2
	fdiv	%f0, %f0, %f2
	fadd	%f0, %f17, %f0
	fdiv	%f1, %f1, %f0
	jlt	%g0, %g6, jle_else.52616
	jlt	%g6, %g0, jge_else.52618
	fmov	%f0, %f1
	jmp	jge_cont.52619
jge_else.52618:
	fsub	%f0, %f31, %f1
jge_cont.52619:
	jmp	jle_cont.52617
jle_else.52616:
	fsub	%f0, %f22, %f1
jle_cont.52617:
	fldi	%f1, %g1, 0
	fmul	%f0, %f0, %f1
	fmul	%f2, %f0, %f0
	fdiv	%f1, %f2, %f25
	fsub	%f1, %f26, %f1
	fdiv	%f1, %f2, %f1
	fsub	%f1, %f24, %f1
	fdiv	%f1, %f2, %f1
	fsub	%f1, %f23, %f1
	fdiv	%f1, %f2, %f1
	fsub	%f1, %f17, %f1
	fdiv	%f0, %f0, %f1
	fmul	%f1, %f0, %f6
	fldi	%f2, %g1, 4
	fldi	%f0, %g1, 0
	jmp	calc_dirvec.3052

!==============================
! args = [%g10, %g9, %g8]
! fargs = [%f0]
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f3, %f28, %f26, %f25, %f24, %f23, %f22, %f20, %f2, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
calc_dirvecs.3060:
	jlt	%g10, %g0, jge_else.52620
	fsti	%f0, %g1, 0
	mov	%g3, %g10
	subi	%g1, %g1, 8
	call	min_caml_float_of_int
	addi	%g1, %g1, 8
	fmov	%f1, %f0
	setL %g3, l.43074
	fldi	%f5, %g3, 0
	fmul	%f1, %f1, %f5
	setL %g3, l.43076
	fldi	%f4, %g3, 0
	fsub	%f2, %f1, %f4
	addi	%g4, %g0, 0
	fldi	%f0, %g1, 0
	fsti	%f4, %g1, 4
	fsti	%f5, %g1, 8
	fsti	%f1, %g1, 12
	mov	%g3, %g8
	mov	%g5, %g9
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 20
	call	calc_dirvec.3052
	addi	%g1, %g1, 20
	setL %g3, l.43078
	fldi	%f3, %g3, 0
	fldi	%f1, %g1, 12
	fadd	%f2, %f1, %f3
	addi	%g4, %g0, 0
	addi	%g11, %g8, 2
	fldi	%f0, %g1, 0
	fsti	%f3, %g1, 16
	mov	%g3, %g11
	mov	%g5, %g9
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 24
	call	calc_dirvec.3052
	addi	%g1, %g1, 24
	subi	%g10, %g10, 1
	addi	%g3, %g9, 1
	addi	%g9, %g0, 5
	jlt	%g3, %g9, jle_else.52621
	subi	%g9, %g3, 5
	jmp	jle_cont.52622
jle_else.52621:
	mov	%g9, %g3
jle_cont.52622:
	jlt	%g10, %g0, jge_else.52623
	mov	%g3, %g10
	subi	%g1, %g1, 24
	call	min_caml_float_of_int
	addi	%g1, %g1, 24
	fmov	%f1, %f0
	fldi	%f5, %g1, 8
	fmul	%f1, %f1, %f5
	fldi	%f4, %g1, 4
	fsub	%f2, %f1, %f4
	addi	%g4, %g0, 0
	fldi	%f0, %g1, 0
	fsti	%f1, %g1, 20
	mov	%g3, %g8
	mov	%g5, %g9
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 28
	call	calc_dirvec.3052
	addi	%g1, %g1, 28
	fldi	%f3, %g1, 16
	fldi	%f1, %g1, 20
	fadd	%f2, %f1, %f3
	addi	%g4, %g0, 0
	fldi	%f0, %g1, 0
	mov	%g3, %g11
	mov	%g5, %g9
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 28
	call	calc_dirvec.3052
	addi	%g1, %g1, 28
	subi	%g10, %g10, 1
	addi	%g3, %g9, 1
	addi	%g9, %g0, 5
	jlt	%g3, %g9, jle_else.52624
	subi	%g9, %g3, 5
	jmp	jle_cont.52625
jle_else.52624:
	mov	%g9, %g3
jle_cont.52625:
	jlt	%g10, %g0, jge_else.52626
	mov	%g3, %g10
	subi	%g1, %g1, 28
	call	min_caml_float_of_int
	addi	%g1, %g1, 28
	fmov	%f1, %f0
	fldi	%f5, %g1, 8
	fmul	%f1, %f1, %f5
	fldi	%f4, %g1, 4
	fsub	%f2, %f1, %f4
	addi	%g4, %g0, 0
	fldi	%f0, %g1, 0
	fsti	%f1, %g1, 24
	mov	%g3, %g8
	mov	%g5, %g9
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 32
	call	calc_dirvec.3052
	addi	%g1, %g1, 32
	fldi	%f3, %g1, 16
	fldi	%f1, %g1, 24
	fadd	%f2, %f1, %f3
	addi	%g4, %g0, 0
	fldi	%f0, %g1, 0
	mov	%g3, %g11
	mov	%g5, %g9
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 32
	call	calc_dirvec.3052
	addi	%g1, %g1, 32
	subi	%g10, %g10, 1
	addi	%g3, %g9, 1
	addi	%g9, %g0, 5
	jlt	%g3, %g9, jle_else.52627
	subi	%g9, %g3, 5
	jmp	jle_cont.52628
jle_else.52627:
	mov	%g9, %g3
jle_cont.52628:
	jlt	%g10, %g0, jge_else.52629
	mov	%g3, %g10
	subi	%g1, %g1, 32
	call	min_caml_float_of_int
	addi	%g1, %g1, 32
	fmov	%f1, %f0
	fldi	%f5, %g1, 8
	fmul	%f1, %f1, %f5
	fldi	%f4, %g1, 4
	fsub	%f2, %f1, %f4
	addi	%g4, %g0, 0
	fldi	%f0, %g1, 0
	fsti	%f1, %g1, 28
	mov	%g3, %g8
	mov	%g5, %g9
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 36
	call	calc_dirvec.3052
	addi	%g1, %g1, 36
	fldi	%f3, %g1, 16
	fldi	%f1, %g1, 28
	fadd	%f2, %f1, %f3
	addi	%g4, %g0, 0
	fldi	%f0, %g1, 0
	mov	%g3, %g11
	mov	%g5, %g9
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 36
	call	calc_dirvec.3052
	addi	%g1, %g1, 36
	subi	%g10, %g10, 1
	addi	%g4, %g9, 1
	addi	%g3, %g0, 5
	jlt	%g4, %g3, jle_else.52630
	subi	%g3, %g4, 5
	jmp	jle_cont.52631
jle_else.52630:
	mov	%g3, %g4
jle_cont.52631:
	fldi	%f0, %g1, 0
	mov	%g9, %g3
	jmp	calc_dirvecs.3060
jge_else.52629:
	return
jge_else.52626:
	return
jge_else.52623:
	return
jge_else.52620:
	return

!==============================
! args = [%g13, %g12, %g8]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f31, %f3, %f28, %f26, %f25, %f24, %f23, %f22, %f20, %f2, %f17, %f16, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0, %dummy]
! ret type = Unit
!================================
calc_dirvec_rows.3065:
	jlt	%g13, %g0, jge_else.52636
	mov	%g3, %g13
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	setL %g3, l.43074
	fldi	%f4, %g3, 0
	fmul	%f0, %f0, %f4
	setL %g3, l.43076
	fldi	%f3, %g3, 0
	fsub	%f0, %f0, %f3
	addi	%g3, %g0, 4
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	min_caml_float_of_int
	addi	%g1, %g1, 8
	fmov	%f1, %f0
	fmul	%f1, %f1, %f4
	fsub	%f10, %f1, %f3
	addi	%g4, %g0, 0
	fldi	%f0, %g1, 0
	fsti	%f10, %g1, 4
	fsti	%f3, %g1, 8
	fsti	%f4, %g1, 12
	fsti	%f1, %g1, 16
	mov	%g3, %g8
	mov	%g5, %g12
	fmov	%f2, %f10
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 24
	call	calc_dirvec.3052
	addi	%g1, %g1, 24
	setL %g3, l.43078
	fldi	%f5, %g3, 0
	fldi	%f1, %g1, 16
	fadd	%f9, %f1, %f5
	addi	%g4, %g0, 0
	addi	%g10, %g8, 2
	fldi	%f0, %g1, 0
	fsti	%f9, %g1, 20
	fsti	%f5, %g1, 24
	mov	%g3, %g10
	mov	%g5, %g12
	fmov	%f2, %f9
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 32
	call	calc_dirvec.3052
	addi	%g1, %g1, 32
	addi	%g6, %g0, 3
	addi	%g3, %g12, 1
	addi	%g9, %g0, 5
	jlt	%g3, %g9, jle_else.52637
	subi	%g9, %g3, 5
	jmp	jle_cont.52638
jle_else.52637:
	mov	%g9, %g3
jle_cont.52638:
	mov	%g3, %g6
	subi	%g1, %g1, 32
	call	min_caml_float_of_int
	addi	%g1, %g1, 32
	fmov	%f1, %f0
	fldi	%f4, %g1, 12
	fmul	%f1, %f1, %f4
	fldi	%f3, %g1, 8
	fsub	%f8, %f1, %f3
	addi	%g4, %g0, 0
	fldi	%f0, %g1, 0
	fsti	%f8, %g1, 28
	fsti	%f1, %g1, 32
	mov	%g3, %g8
	mov	%g5, %g9
	fmov	%f2, %f8
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 40
	call	calc_dirvec.3052
	addi	%g1, %g1, 40
	fldi	%f5, %g1, 24
	fldi	%f1, %g1, 32
	fadd	%f7, %f1, %f5
	addi	%g4, %g0, 0
	fldi	%f0, %g1, 0
	fsti	%f7, %g1, 36
	mov	%g3, %g10
	mov	%g5, %g9
	fmov	%f2, %f7
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 44
	call	calc_dirvec.3052
	addi	%g1, %g1, 44
	addi	%g6, %g0, 2
	addi	%g3, %g9, 1
	addi	%g9, %g0, 5
	jlt	%g3, %g9, jle_else.52639
	subi	%g9, %g3, 5
	jmp	jle_cont.52640
jle_else.52639:
	mov	%g9, %g3
jle_cont.52640:
	mov	%g3, %g6
	subi	%g1, %g1, 44
	call	min_caml_float_of_int
	addi	%g1, %g1, 44
	fmov	%f1, %f0
	fldi	%f4, %g1, 12
	fmul	%f1, %f1, %f4
	fldi	%f3, %g1, 8
	fsub	%f6, %f1, %f3
	addi	%g4, %g0, 0
	fldi	%f0, %g1, 0
	fsti	%f6, %g1, 40
	fsti	%f1, %g1, 44
	mov	%g3, %g8
	mov	%g5, %g9
	fmov	%f2, %f6
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 52
	call	calc_dirvec.3052
	addi	%g1, %g1, 52
	fldi	%f5, %g1, 24
	fldi	%f1, %g1, 44
	fadd	%f2, %f1, %f5
	addi	%g4, %g0, 0
	fldi	%f0, %g1, 0
	fsti	%f2, %g1, 48
	mov	%g3, %g10
	mov	%g5, %g9
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 56
	call	calc_dirvec.3052
	addi	%g1, %g1, 56
	addi	%g6, %g0, 1
	addi	%g3, %g9, 1
	addi	%g9, %g0, 5
	jlt	%g3, %g9, jle_else.52641
	subi	%g9, %g3, 5
	jmp	jle_cont.52642
jle_else.52641:
	mov	%g9, %g3
jle_cont.52642:
	mov	%g3, %g6
	subi	%g1, %g1, 56
	call	min_caml_float_of_int
	addi	%g1, %g1, 56
	fmov	%f1, %f0
	fldi	%f4, %g1, 12
	fmul	%f11, %f1, %f4
	fldi	%f3, %g1, 8
	fsub	%f1, %f11, %f3
	addi	%g4, %g0, 0
	fldi	%f0, %g1, 0
	fsti	%f11, %g1, 52
	mov	%g3, %g8
	mov	%g5, %g9
	fmov	%f2, %f1
	fmov	%f5, %f16
	fmov	%f1, %f16
	subi	%g1, %g1, 60
	call	calc_dirvec.3052
	addi	%g1, %g1, 60
	fldi	%f5, %g1, 24
	fldi	%f11, %g1, 52
	fadd	%f1, %f11, %f5
	addi	%g4, %g0, 0
	fldi	%f0, %g1, 0
	mov	%g3, %g10
	mov	%g5, %g9
	fmov	%f2, %f1
	fmov	%f5, %f16
	fmov	%f1, %f16
	subi	%g1, %g1, 60
	call	calc_dirvec.3052
	addi	%g1, %g1, 60
	addi	%g10, %g0, 0
	addi	%g3, %g9, 1
	addi	%g9, %g0, 5
	jlt	%g3, %g9, jle_else.52643
	subi	%g9, %g3, 5
	jmp	jle_cont.52644
jle_else.52643:
	mov	%g9, %g3
jle_cont.52644:
	fldi	%f0, %g1, 0
	sti	%g8, %g1, 56
	subi	%g1, %g1, 64
	call	calc_dirvecs.3060
	addi	%g1, %g1, 64
	subi	%g14, %g13, 1
	addi	%g3, %g12, 2
	addi	%g12, %g0, 5
	jlt	%g3, %g12, jle_else.52645
	subi	%g12, %g3, 5
	jmp	jle_cont.52646
jle_else.52645:
	mov	%g12, %g3
jle_cont.52646:
	ldi	%g8, %g1, 56
	addi	%g13, %g8, 4
	jlt	%g14, %g0, jge_else.52647
	mov	%g3, %g14
	subi	%g1, %g1, 64
	call	min_caml_float_of_int
	addi	%g1, %g1, 64
	fldi	%f4, %g1, 12
	fmul	%f0, %f0, %f4
	fldi	%f3, %g1, 8
	fsub	%f0, %f0, %f3
	addi	%g4, %g0, 0
	fldi	%f10, %g1, 4
	fsti	%f0, %g1, 60
	mov	%g3, %g13
	mov	%g5, %g12
	fmov	%f2, %f10
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 68
	call	calc_dirvec.3052
	addi	%g1, %g1, 68
	addi	%g4, %g0, 0
	addi	%g8, %g13, 2
	fldi	%f9, %g1, 20
	fldi	%f0, %g1, 60
	mov	%g3, %g8
	mov	%g5, %g12
	fmov	%f2, %f9
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 68
	call	calc_dirvec.3052
	addi	%g1, %g1, 68
	addi	%g3, %g12, 1
	addi	%g5, %g0, 5
	jlt	%g3, %g5, jle_else.52648
	subi	%g5, %g3, 5
	jmp	jle_cont.52649
jle_else.52648:
	mov	%g5, %g3
jle_cont.52649:
	addi	%g4, %g0, 0
	fldi	%f8, %g1, 28
	fldi	%f0, %g1, 60
	sti	%g5, %g1, 64
	mov	%g3, %g13
	fmov	%f2, %f8
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 72
	call	calc_dirvec.3052
	addi	%g1, %g1, 72
	addi	%g4, %g0, 0
	fldi	%f7, %g1, 36
	fldi	%f0, %g1, 60
	ldi	%g5, %g1, 64
	mov	%g3, %g8
	fmov	%f2, %f7
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 72
	call	calc_dirvec.3052
	addi	%g1, %g1, 72
	ldi	%g5, %g1, 64
	addi	%g3, %g5, 1
	addi	%g5, %g0, 5
	jlt	%g3, %g5, jle_else.52650
	subi	%g5, %g3, 5
	jmp	jle_cont.52651
jle_else.52650:
	mov	%g5, %g3
jle_cont.52651:
	addi	%g4, %g0, 0
	fldi	%f6, %g1, 40
	fldi	%f0, %g1, 60
	sti	%g5, %g1, 68
	mov	%g3, %g13
	fmov	%f2, %f6
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 76
	call	calc_dirvec.3052
	addi	%g1, %g1, 76
	addi	%g4, %g0, 0
	fldi	%f2, %g1, 48
	fldi	%f0, %g1, 60
	ldi	%g5, %g1, 68
	mov	%g3, %g8
	fmov	%f1, %f16
	fmov	%f5, %f16
	subi	%g1, %g1, 76
	call	calc_dirvec.3052
	addi	%g1, %g1, 76
	addi	%g10, %g0, 1
	ldi	%g5, %g1, 68
	addi	%g3, %g5, 1
	addi	%g9, %g0, 5
	jlt	%g3, %g9, jle_else.52652
	subi	%g9, %g3, 5
	jmp	jle_cont.52653
jle_else.52652:
	mov	%g9, %g3
jle_cont.52653:
	fldi	%f0, %g1, 60
	mov	%g8, %g13
	subi	%g1, %g1, 76
	call	calc_dirvecs.3060
	addi	%g1, %g1, 76
	subi	%g4, %g14, 1
	addi	%g3, %g12, 2
	addi	%g12, %g0, 5
	jlt	%g3, %g12, jle_else.52654
	subi	%g12, %g3, 5
	jmp	jle_cont.52655
jle_else.52654:
	mov	%g12, %g3
jle_cont.52655:
	addi	%g8, %g13, 4
	mov	%g13, %g4
	jmp	calc_dirvec_rows.3065
jge_else.52647:
	return
jge_else.52636:
	return

!==============================
! args = [%g6, %g7]
! fargs = []
! use_regs = [%g7, %g6, %g5, %g4, %g3, %g27, %g2, %f16, %f15, %f0, %dummy]
! ret type = Unit
!================================
create_dirvec_elements.3071:
	jlt	%g7, %g0, jge_else.52658
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
	slli	%g4, %g7, 2
	st	%g3, %g6, %g4
	subi	%g7, %g7, 1
	jlt	%g7, %g0, jge_else.52659
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 8
	call	min_caml_create_float_array
	addi	%g1, %g1, 8
	mov	%g4, %g3
	ldi	%g3, %g31, 28
	sti	%g4, %g1, 4
	subi	%g1, %g1, 12
	call	min_caml_create_array
	addi	%g1, %g1, 12
	mov	%g5, %g3
	mov	%g3, %g2
	addi	%g2, %g2, 8
	sti	%g5, %g3, -4
	ldi	%g4, %g1, 4
	sti	%g4, %g3, 0
	slli	%g4, %g7, 2
	st	%g3, %g6, %g4
	subi	%g7, %g7, 1
	jlt	%g7, %g0, jge_else.52660
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 12
	call	min_caml_create_float_array
	addi	%g1, %g1, 12
	mov	%g4, %g3
	ldi	%g3, %g31, 28
	sti	%g4, %g1, 8
	subi	%g1, %g1, 16
	call	min_caml_create_array
	addi	%g1, %g1, 16
	mov	%g5, %g3
	mov	%g3, %g2
	addi	%g2, %g2, 8
	sti	%g5, %g3, -4
	ldi	%g4, %g1, 8
	sti	%g4, %g3, 0
	slli	%g4, %g7, 2
	st	%g3, %g6, %g4
	subi	%g7, %g7, 1
	jlt	%g7, %g0, jge_else.52661
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 16
	call	min_caml_create_float_array
	addi	%g1, %g1, 16
	mov	%g4, %g3
	ldi	%g3, %g31, 28
	sti	%g4, %g1, 12
	subi	%g1, %g1, 20
	call	min_caml_create_array
	addi	%g1, %g1, 20
	mov	%g5, %g3
	mov	%g3, %g2
	addi	%g2, %g2, 8
	sti	%g5, %g3, -4
	ldi	%g4, %g1, 12
	sti	%g4, %g3, 0
	slli	%g4, %g7, 2
	st	%g3, %g6, %g4
	subi	%g7, %g7, 1
	jmp	create_dirvec_elements.3071
jge_else.52661:
	return
jge_else.52660:
	return
jge_else.52659:
	return
jge_else.52658:
	return

!==============================
! args = [%g8]
! fargs = []
! use_regs = [%g8, %g7, %g6, %g5, %g4, %g3, %g27, %g2, %f16, %f15, %f0, %dummy]
! ret type = Unit
!================================
create_dirvecs.3074:
	jlt	%g8, %g0, jge_else.52666
	addi	%g6, %g0, 120
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
	mov	%g4, %g3
	mov	%g3, %g6
	subi	%g1, %g1, 8
	call	min_caml_create_array
	slli	%g4, %g8, 2
	add	%g4, %g31, %g4
	sti	%g3, %g4, 716
	slli	%g3, %g8, 2
	add	%g3, %g31, %g3
	ldi	%g6, %g3, 716
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	addi	%g1, %g1, 8
	mov	%g4, %g3
	ldi	%g3, %g31, 28
	sti	%g4, %g1, 4
	subi	%g1, %g1, 12
	call	min_caml_create_array
	addi	%g1, %g1, 12
	mov	%g5, %g3
	mov	%g3, %g2
	addi	%g2, %g2, 8
	sti	%g5, %g3, -4
	ldi	%g4, %g1, 4
	sti	%g4, %g3, 0
	sti	%g3, %g6, -472
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 12
	call	min_caml_create_float_array
	addi	%g1, %g1, 12
	mov	%g4, %g3
	ldi	%g3, %g31, 28
	sti	%g4, %g1, 8
	subi	%g1, %g1, 16
	call	min_caml_create_array
	addi	%g1, %g1, 16
	mov	%g5, %g3
	mov	%g3, %g2
	addi	%g2, %g2, 8
	sti	%g5, %g3, -4
	ldi	%g4, %g1, 8
	sti	%g4, %g3, 0
	sti	%g3, %g6, -468
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 16
	call	min_caml_create_float_array
	addi	%g1, %g1, 16
	mov	%g4, %g3
	ldi	%g3, %g31, 28
	sti	%g4, %g1, 12
	subi	%g1, %g1, 20
	call	min_caml_create_array
	addi	%g1, %g1, 20
	mov	%g5, %g3
	mov	%g3, %g2
	addi	%g2, %g2, 8
	sti	%g5, %g3, -4
	ldi	%g4, %g1, 12
	sti	%g4, %g3, 0
	sti	%g3, %g6, -464
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 20
	call	min_caml_create_float_array
	addi	%g1, %g1, 20
	mov	%g4, %g3
	ldi	%g3, %g31, 28
	sti	%g4, %g1, 16
	subi	%g1, %g1, 24
	call	min_caml_create_array
	addi	%g1, %g1, 24
	mov	%g5, %g3
	mov	%g3, %g2
	addi	%g2, %g2, 8
	sti	%g5, %g3, -4
	ldi	%g4, %g1, 16
	sti	%g4, %g3, 0
	sti	%g3, %g6, -460
	addi	%g7, %g0, 114
	subi	%g1, %g1, 24
	call	create_dirvec_elements.3071
	addi	%g1, %g1, 24
	subi	%g8, %g8, 1
	jlt	%g8, %g0, jge_else.52667
	addi	%g6, %g0, 120
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 24
	call	min_caml_create_float_array
	addi	%g1, %g1, 24
	mov	%g4, %g3
	ldi	%g3, %g31, 28
	sti	%g4, %g1, 20
	subi	%g1, %g1, 28
	call	min_caml_create_array
	addi	%g1, %g1, 28
	mov	%g5, %g3
	mov	%g3, %g2
	addi	%g2, %g2, 8
	sti	%g5, %g3, -4
	ldi	%g4, %g1, 20
	sti	%g4, %g3, 0
	mov	%g4, %g3
	mov	%g3, %g6
	subi	%g1, %g1, 28
	call	min_caml_create_array
	slli	%g4, %g8, 2
	add	%g4, %g31, %g4
	sti	%g3, %g4, 716
	slli	%g3, %g8, 2
	add	%g3, %g31, %g3
	ldi	%g6, %g3, 716
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	addi	%g1, %g1, 28
	mov	%g4, %g3
	ldi	%g3, %g31, 28
	sti	%g4, %g1, 24
	subi	%g1, %g1, 32
	call	min_caml_create_array
	addi	%g1, %g1, 32
	mov	%g5, %g3
	mov	%g3, %g2
	addi	%g2, %g2, 8
	sti	%g5, %g3, -4
	ldi	%g4, %g1, 24
	sti	%g4, %g3, 0
	sti	%g3, %g6, -472
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 32
	call	min_caml_create_float_array
	addi	%g1, %g1, 32
	mov	%g4, %g3
	ldi	%g3, %g31, 28
	sti	%g4, %g1, 28
	subi	%g1, %g1, 36
	call	min_caml_create_array
	addi	%g1, %g1, 36
	mov	%g5, %g3
	mov	%g3, %g2
	addi	%g2, %g2, 8
	sti	%g5, %g3, -4
	ldi	%g4, %g1, 28
	sti	%g4, %g3, 0
	sti	%g3, %g6, -468
	addi	%g3, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 36
	call	min_caml_create_float_array
	addi	%g1, %g1, 36
	mov	%g4, %g3
	ldi	%g3, %g31, 28
	sti	%g4, %g1, 32
	subi	%g1, %g1, 40
	call	min_caml_create_array
	addi	%g1, %g1, 40
	mov	%g5, %g3
	mov	%g3, %g2
	addi	%g2, %g2, 8
	sti	%g5, %g3, -4
	ldi	%g4, %g1, 32
	sti	%g4, %g3, 0
	sti	%g3, %g6, -464
	addi	%g7, %g0, 115
	subi	%g1, %g1, 40
	call	create_dirvec_elements.3071
	addi	%g1, %g1, 40
	subi	%g8, %g8, 1
	jmp	create_dirvecs.3074
jge_else.52667:
	return
jge_else.52666:
	return

!==============================
! args = [%g11, %g12]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g12, %g11, %g10, %f8, %f7, %f6, %f5, %f4, %f3, %f21, %f20, %f2, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
init_dirvec_constants.3076:
	jlt	%g12, %g0, jge_else.52670
	slli	%g3, %g12, 2
	ld	%g3, %g11, %g3
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	subi	%g1, %g1, 4
	call	iter_setup_dirvec_constants.2860
	addi	%g1, %g1, 4
	subi	%g12, %g12, 1
	jlt	%g12, %g0, jge_else.52671
	slli	%g3, %g12, 2
	ld	%g3, %g11, %g3
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	subi	%g1, %g1, 4
	call	iter_setup_dirvec_constants.2860
	addi	%g1, %g1, 4
	subi	%g12, %g12, 1
	jlt	%g12, %g0, jge_else.52672
	slli	%g3, %g12, 2
	ld	%g3, %g11, %g3
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	subi	%g1, %g1, 4
	call	iter_setup_dirvec_constants.2860
	addi	%g1, %g1, 4
	subi	%g12, %g12, 1
	jlt	%g12, %g0, jge_else.52673
	slli	%g3, %g12, 2
	ld	%g3, %g11, %g3
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	subi	%g1, %g1, 4
	call	iter_setup_dirvec_constants.2860
	addi	%g1, %g1, 4
	subi	%g12, %g12, 1
	jlt	%g12, %g0, jge_else.52674
	slli	%g3, %g12, 2
	ld	%g3, %g11, %g3
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	subi	%g1, %g1, 4
	call	iter_setup_dirvec_constants.2860
	addi	%g1, %g1, 4
	subi	%g12, %g12, 1
	jlt	%g12, %g0, jge_else.52675
	slli	%g3, %g12, 2
	ld	%g3, %g11, %g3
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	subi	%g1, %g1, 4
	call	iter_setup_dirvec_constants.2860
	addi	%g1, %g1, 4
	subi	%g12, %g12, 1
	jlt	%g12, %g0, jge_else.52676
	slli	%g3, %g12, 2
	ld	%g3, %g11, %g3
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	subi	%g1, %g1, 4
	call	iter_setup_dirvec_constants.2860
	addi	%g1, %g1, 4
	subi	%g12, %g12, 1
	jlt	%g12, %g0, jge_else.52677
	slli	%g3, %g12, 2
	ld	%g3, %g11, %g3
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	subi	%g1, %g1, 4
	call	iter_setup_dirvec_constants.2860
	addi	%g1, %g1, 4
	subi	%g12, %g12, 1
	jmp	init_dirvec_constants.3076
jge_else.52677:
	return
jge_else.52676:
	return
jge_else.52675:
	return
jge_else.52674:
	return
jge_else.52673:
	return
jge_else.52672:
	return
jge_else.52671:
	return
jge_else.52670:
	return

!==============================
! args = [%g13]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g13, %g12, %g11, %g10, %f8, %f7, %f6, %f5, %f4, %f3, %f21, %f20, %f2, %f17, %f16, %f15, %f1, %f0, %dummy]
! ret type = Unit
!================================
init_vecset_constants.3079:
	jlt	%g13, %g0, jge_else.52686
	slli	%g3, %g13, 2
	add	%g3, %g31, %g3
	ldi	%g11, %g3, 716
	ldi	%g3, %g11, -476
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	subi	%g1, %g1, 4
	call	iter_setup_dirvec_constants.2860
	ldi	%g3, %g11, -472
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	call	iter_setup_dirvec_constants.2860
	ldi	%g3, %g11, -468
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	call	iter_setup_dirvec_constants.2860
	ldi	%g3, %g11, -464
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	call	iter_setup_dirvec_constants.2860
	ldi	%g3, %g11, -460
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	call	iter_setup_dirvec_constants.2860
	ldi	%g3, %g11, -456
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	call	iter_setup_dirvec_constants.2860
	ldi	%g3, %g11, -452
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	call	iter_setup_dirvec_constants.2860
	ldi	%g3, %g11, -448
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	call	iter_setup_dirvec_constants.2860
	addi	%g12, %g0, 111
	call	init_dirvec_constants.3076
	addi	%g1, %g1, 4
	subi	%g13, %g13, 1
	jlt	%g13, %g0, jge_else.52687
	slli	%g3, %g13, 2
	add	%g3, %g31, %g3
	ldi	%g11, %g3, 716
	ldi	%g3, %g11, -476
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	subi	%g1, %g1, 4
	call	iter_setup_dirvec_constants.2860
	ldi	%g3, %g11, -472
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	call	iter_setup_dirvec_constants.2860
	ldi	%g3, %g11, -468
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	call	iter_setup_dirvec_constants.2860
	ldi	%g3, %g11, -464
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	call	iter_setup_dirvec_constants.2860
	ldi	%g3, %g11, -460
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	call	iter_setup_dirvec_constants.2860
	ldi	%g3, %g11, -456
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	call	iter_setup_dirvec_constants.2860
	ldi	%g3, %g11, -452
	ldi	%g4, %g31, 28
	subi	%g5, %g4, 1
	ldi	%g6, %g3, -4
	ldi	%g7, %g3, 0
	call	iter_setup_dirvec_constants.2860
	addi	%g12, %g0, 112
	call	init_dirvec_constants.3076
	addi	%g1, %g1, 4
	subi	%g13, %g13, 1
	jmp	init_vecset_constants.3079
jge_else.52687:
	return
jge_else.52686:
	return
