.init_heap_size	576
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
l.648:	! 1.570796
	.long	0x3fc90fda
l.646:	! 0.500000
	.long	0x3f000000
l.642:	! 3.141593
	.long	0x40490fda
l.639:	! 6.283185
	.long	0x40c90fda
l.636:	! 9.000000
	.long	0x41100000
l.634:	! 1.000000
	.long	0x3f800000
l.632:	! 2.000000
	.long	0x40000000
l.630:	! 2.500000
	.long	0x40200000
l.628:	! 0.000000
	.long	0x0
l.620:	! 48.300300
	.long	0x42413381
l.618:	! 4.500000
	.long	0x40900000
l.616:	! -12.300000
	.long	0xc144ccc4
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
	subi	%g1, %g1, 32
	addi	%g28, %g0, 1
	addi	%g29, %g0, -1
	setL %g27, l.628
	fldi	%f16, %g27, 0
	setL %g27, l.648
	fldi	%f17, %g27, 0
	setL %g27, l.639
	fldi	%f18, %g27, 0
	setL %g27, l.634
	fldi	%f19, %g27, 0
	setL %g27, l.632
	fldi	%f20, %g27, 0
	setL %g27, l.646
	fldi	%f21, %g27, 0
	setL %g27, l.642
	fldi	%f22, %g27, 0
	setL %g27, l.636
	fldi	%f23, %g27, 0
	setL %g27, l.630
	fldi	%f24, %g27, 0
	setL %g27, l.620
	fldi	%f25, %g27, 0
	setL %g27, l.618
	fldi	%f26, %g27, 0
	setL %g27, l.616
	fldi	%f27, %g27, 0
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 28
	subi	%g2, %g31, 4
	subi	%g1, %g1, 4
	call	min_caml_create_array
	ldi	%g2, %g31, 28
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 28
	subi	%g2, %g31, 8
	call	min_caml_create_array
	ldi	%g2, %g31, 28
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 28
	subi	%g2, %g31, 12
	call	min_caml_create_array
	ldi	%g2, %g31, 28
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 28
	subi	%g2, %g31, 16
	call	min_caml_create_array
	ldi	%g2, %g31, 28
	addi	%g3, %g0, 1
	addi	%g4, %g0, 1
	sti	%g2, %g31, 28
	subi	%g2, %g31, 20
	call	min_caml_create_array
	ldi	%g2, %g31, 28
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 28
	subi	%g2, %g31, 24
	call	min_caml_create_array
	ldi	%g2, %g31, 28
	fmov	%f1, %f27
	call	abs_float.267
	fsqrt	%f0, %f0
	call	cos.290
	fmov	%f2, %f0
	call	sin.288
	fadd	%f0, %f0, %f26
	fsub	%f3, %f0, %f25
	mvhi	%g3, 15
	mvlo	%g3, 16960
	call	min_caml_float_of_int
	fmul	%f0, %f3, %f0
	call	min_caml_int_of_float
	mov	%g8, %g3
	call	print_int.313
	addi	%g1, %g1, 4
	halt

!==============================
! args = []
! fargs = [%f1]
! use_regs = [%g27, %f16, %f15, %f1, %f0]
! ret type = Float
!================================
fabs.265:
	fjlt	%f1, %f16, fjge_else.666
	fmov	%f0, %f1
	return
fjge_else.666:
	fneg	%f0, %f1
	return

!==============================
! args = []
! fargs = [%f1]
! use_regs = [%g27, %f16, %f15, %f1, %f0]
! ret type = Float
!================================
abs_float.267:
	jmp	fabs.265

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g27, %f15, %f0]
! ret type = Float
!================================
fneg.269:
	fneg	%f0, %f0
	return

!==============================
! args = []
! fargs = [%f2, %f3, %f1]
! use_regs = [%g27, %f3, %f24, %f20, %f2, %f15, %f1, %f0]
! ret type = Float
!================================
tan_sub.567:
	fjlt	%f2, %f24, fjge_else.667
	fsub	%f0, %f2, %f20
	fsub	%f1, %f2, %f1
	fdiv	%f1, %f3, %f1
	fmov	%f2, %f0
	jmp	tan_sub.567
fjge_else.667:
	fmov	%f0, %f1
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g27, %f3, %f24, %f23, %f20, %f2, %f19, %f16, %f15, %f1, %f0]
! ret type = Float
!================================
tan.284:
	fmul	%f3, %f0, %f0
	fsti	%f0, %g1, 0
	fmov	%f1, %f16
	fmov	%f2, %f23
	subi	%g1, %g1, 8
	call	tan_sub.567
	addi	%g1, %g1, 8
	fmov	%f1, %f0
	fsub	%f1, %f19, %f1
	fldi	%f0, %g1, 0
	fdiv	%f0, %f0, %f1
	return

!==============================
! args = []
! fargs = [%f1]
! use_regs = [%g27, %f18, %f16, %f15, %f1, %f0]
! ret type = Float
!================================
sin_sub.286:
	fjlt	%f18, %f1, fjge_else.668
	fjlt	%f1, %f16, fjge_else.669
	fmov	%f0, %f1
	return
fjge_else.669:
	fadd	%f1, %f1, %f18
	jmp	sin_sub.286
fjge_else.668:
	fsub	%f1, %f1, %f18
	jmp	sin_sub.286

!==============================
! args = []
! fargs = [%f2]
! use_regs = [%g3, %g27, %f3, %f24, %f23, %f22, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f1, %f0]
! ret type = Float
!================================
sin.288:
	fmov	%f1, %f2
	call	fabs.265
	fmov	%f1, %f0
	subi	%g1, %g1, 4
	call	sin_sub.286
	addi	%g1, %g1, 4
	fjlt	%f22, %f0, fjge_else.670
	fjlt	%f16, %f2, fjge_else.672
	addi	%g3, %g0, 0
	jmp	fjge_cont.673
fjge_else.672:
	addi	%g3, %g0, 1
fjge_cont.673:
	jmp	fjge_cont.671
fjge_else.670:
	fjlt	%f16, %f2, fjge_else.674
	addi	%g3, %g0, 1
	jmp	fjge_cont.675
fjge_else.674:
	addi	%g3, %g0, 0
fjge_cont.675:
fjge_cont.671:
	fjlt	%f22, %f0, fjge_else.676
	fmov	%f1, %f0
	jmp	fjge_cont.677
fjge_else.676:
	fsub	%f1, %f18, %f0
fjge_cont.677:
	fjlt	%f17, %f1, fjge_else.678
	fmov	%f0, %f1
	jmp	fjge_cont.679
fjge_else.678:
	fsub	%f0, %f22, %f1
fjge_cont.679:
	fmul	%f0, %f0, %f21
	subi	%g1, %g1, 4
	call	tan.284
	addi	%g1, %g1, 4
	fmul	%f1, %f20, %f0
	fmul	%f0, %f0, %f0
	fadd	%f0, %f19, %f0
	fdiv	%f1, %f1, %f0
	jne	%g3, %g0, jeq_else.680
	fmov	%f0, %f1
	jmp	fneg.269
jeq_else.680:
	fmov	%f0, %f1
	return

!==============================
! args = []
! fargs = [%f0]
! use_regs = [%g3, %g27, %f3, %f24, %f23, %f22, %f21, %f20, %f2, %f19, %f18, %f17, %f16, %f15, %f1, %f0]
! ret type = Float
!================================
cos.290:
	fsub	%f2, %f17, %f0
	jmp	sin.288

!==============================
! args = [%g8, %g7, %g5, %g6]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %f15]
! ret type = Int
!================================
div_binary_search.308:
	add	%g3, %g5, %g6
	srli	%g4, %g3, 1
	mul	%g9, %g4, %g7
	sub	%g3, %g6, %g5
	jlt	%g28, %g3, jle_else.681
	mov	%g3, %g5
	return
jle_else.681:
	jlt	%g9, %g8, jle_else.682
	jne	%g9, %g8, jeq_else.683
	mov	%g3, %g4
	return
jeq_else.683:
	mov	%g6, %g4
	jmp	div_binary_search.308
jle_else.682:
	mov	%g5, %g4
	jmp	div_binary_search.308

!==============================
! args = [%g8]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g3, %g27, %g11, %g10, %f15, %dummy]
! ret type = Unit
!================================
print_int.313:
	jlt	%g8, %g0, jge_else.684
	mvhi	%g7, 1525
	mvlo	%g7, 57600
	addi	%g5, %g0, 0
	addi	%g6, %g0, 3
	sti	%g8, %g1, 0
	subi	%g1, %g1, 8
	call	div_binary_search.308
	addi	%g1, %g1, 8
	mvhi	%g4, 1525
	mvlo	%g4, 57600
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 0
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.685
	addi	%g10, %g0, 0
	jmp	jle_cont.686
jle_else.685:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jle_cont.686:
	mvhi	%g7, 152
	mvlo	%g7, 38528
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 4
	subi	%g1, %g1, 12
	call	div_binary_search.308
	addi	%g1, %g1, 12
	mvhi	%g4, 152
	mvlo	%g4, 38528
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 4
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.687
	jne	%g10, %g0, jeq_else.689
	addi	%g11, %g0, 0
	jmp	jeq_cont.690
jeq_else.689:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jeq_cont.690:
	jmp	jle_cont.688
jle_else.687:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jle_cont.688:
	mvhi	%g7, 15
	mvlo	%g7, 16960
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 8
	subi	%g1, %g1, 16
	call	div_binary_search.308
	addi	%g1, %g1, 16
	mvhi	%g4, 15
	mvlo	%g4, 16960
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 8
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.691
	jne	%g11, %g0, jeq_else.693
	addi	%g10, %g0, 0
	jmp	jeq_cont.694
jeq_else.693:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jeq_cont.694:
	jmp	jle_cont.692
jle_else.691:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jle_cont.692:
	mvhi	%g7, 1
	mvlo	%g7, 34464
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 12
	subi	%g1, %g1, 20
	call	div_binary_search.308
	addi	%g1, %g1, 20
	mvhi	%g4, 1
	mvlo	%g4, 34464
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 12
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.695
	jne	%g10, %g0, jeq_else.697
	addi	%g11, %g0, 0
	jmp	jeq_cont.698
jeq_else.697:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jeq_cont.698:
	jmp	jle_cont.696
jle_else.695:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jle_cont.696:
	addi	%g7, %g0, 10000
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 16
	subi	%g1, %g1, 24
	call	div_binary_search.308
	addi	%g1, %g1, 24
	addi	%g4, %g0, 10000
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 16
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.699
	jne	%g11, %g0, jeq_else.701
	addi	%g10, %g0, 0
	jmp	jeq_cont.702
jeq_else.701:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jeq_cont.702:
	jmp	jle_cont.700
jle_else.699:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jle_cont.700:
	addi	%g7, %g0, 1000
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 20
	subi	%g1, %g1, 28
	call	div_binary_search.308
	addi	%g1, %g1, 28
	muli	%g4, %g3, 1000
	ldi	%g8, %g1, 20
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.703
	jne	%g10, %g0, jeq_else.705
	addi	%g11, %g0, 0
	jmp	jeq_cont.706
jeq_else.705:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jeq_cont.706:
	jmp	jle_cont.704
jle_else.703:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jle_cont.704:
	addi	%g7, %g0, 100
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 24
	subi	%g1, %g1, 32
	call	div_binary_search.308
	addi	%g1, %g1, 32
	muli	%g4, %g3, 100
	ldi	%g8, %g1, 24
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.707
	jne	%g11, %g0, jeq_else.709
	addi	%g10, %g0, 0
	jmp	jeq_cont.710
jeq_else.709:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jeq_cont.710:
	jmp	jle_cont.708
jle_else.707:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jle_cont.708:
	addi	%g7, %g0, 10
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 28
	subi	%g1, %g1, 36
	call	div_binary_search.308
	addi	%g1, %g1, 36
	muli	%g4, %g3, 10
	ldi	%g8, %g1, 28
	sub	%g4, %g8, %g4
	jlt	%g0, %g3, jle_else.711
	jne	%g10, %g0, jeq_else.713
	addi	%g5, %g0, 0
	jmp	jeq_cont.714
jeq_else.713:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g5, %g0, 1
jeq_cont.714:
	jmp	jle_cont.712
jle_else.711:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g5, %g0, 1
jle_cont.712:
	addi	%g3, %g0, 48
	add	%g3, %g3, %g4
	output	%g3
	return
jge_else.684:
	addi	%g3, %g0, 45
	output	%g3
	sub	%g8, %g0, %g8
	jmp	print_int.313
