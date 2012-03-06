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
	b %g31
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
	b %g31
CREATE_FLOAT_ARRAY_CONTINUE:
	fsti %f0, %g2, 0
	addi %g2, %g2, 4
	jmp CREATE_FLOAT_ARRAY_LOOP

! * floor		%f0 + MAGICF - MAGICF
min_caml_floor:
	fmov %f1, %f0
	! %f4 <- 0.0
	! fset %f4, 0.0
	! test test 
	fmvhi %f4, 0
	fmvlo %f4, 0
	fjlt %f0, %f4, FLOOR_NEGATIVE	! if (%f4 <= %f0) goto FLOOR_PISITIVE
FLOOR_POSITIVE:
	! %f2 <- 8388608.0(0x4b000000)
	fmvhi %f2, 19200
	fmvlo %f2, 0
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
	b %g31
FLOOR_POSITIVE_RET:
	! %f3 <- 1.0
	! fset %f3, 1.0
	fmvhi %f3, 16256
	fmvlo %f3, 0
	fsub %f0, %f0, %f3
	b %g31
FLOOR_NEGATIVE:
	fneg %f0, %f0
	! %f2 <- 8388608.0(0x4b000000)
	fmvhi %f2, 19200
	fmvlo %f2, 0
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
	fmvhi %f3, 16256
	fmvlo %f3, 0
	fadd %f0, %f0, %f3
	fsub %f0, %f0, %f2
FLOOR_NEGATIVE_RET:
	fneg %f0, %f0
	b %g31
	
min_caml_ceil:
	fneg %f0, %f0

	sti %g31, %g1, 0
	addi %g1, %g1, -4
	jal min_caml_floor
	addi %g1, %g1, 4
	ldi %g31, %g1, 0

	fneg %f0, %f0
	b %g31

! * float_of_int
min_caml_float_of_int:
	jlt %g3, %g0, ITOF_NEGATIVE_MAIN		! if (%g0 <= %g3) goto ITOF_MAIN
ITOF_MAIN:
	! %f1 <- 8388608.0(0x4b000000)
	fmvhi %f1, 19200
	fmvlo %f1, 0
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
	fmvhi %f2, 0
	fmvlo %f2, 0
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
	b %g31
ITOF_SMALL:
	add %g3, %g3, %g4
	sti %g3, %g1, 0
	fldi  %f0, %g1, 0
	fsub %f0, %f0, %f1
	b %g31
ITOF_NEGATIVE_MAIN:
	sub %g3, %g0, %g3

	sti %g31, %g1, 0
	addi %g1, %g1, -4
	jal ITOF_MAIN
	addi %g1, %g1, 4
	ldi %g31, %g1, 0

	fneg %f0, %f0
	b %g31

! * int_of_float
min_caml_int_of_float:
	! %f1 <- 0.0
	! fset %f1, 0.0
	fmvhi %f1, 0
	fmvlo %f1, 0
	fjlt %f0, %f1, FTOI_NEGATIVE_MAIN			! if (0.0 <= %f0) goto FTOI_MAIN
FTOI_POSITIVE_MAIN:

	sti %g31, %g1, 0
	addi %g1, %g1, -4
	jal min_caml_floor
	addi %g1, %g1, 4
	ldi %g31, %g1, 0

	! %f2 <- 8388608.0(0x4b000000)
	fmvhi %f2, 19200
	fmvlo %f2, 0
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
	b %g31
FTOI_SMALL:
	fadd %f0, %f0, %f2
	fsti %f0, %g1, 0
	ldi %g3, %g1, 0
	sub %g3, %g3, %g4
	b %g31
FTOI_NEGATIVE_MAIN:
	fneg %f0, %f0

	sti %g31, %g1, 0
	addi %g1, %g1, -4
	jal FTOI_POSITIVE_MAIN
	addi %g1, %g1, 4
	ldi %g31, %g1, 0

	sub %g3, %g0, %g3
	b %g31
	
! * truncate
min_caml_truncate:
	jmp min_caml_int_of_float
	
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
	b %g31

min_caml_read_float:
	sti %g31, %g1, 0
	addi %g1, %g1, -4
	jal min_caml_read_int
	addi %g1, %g1, 4
	ldi %g31, %g1, 0

	sti %g3, %g1, 0
	fldi  %f0, %g1, 0
	b %g31

!----------------------------------------------------------------------
!
! lib_asm.s
!
!----------------------------------------------------------------------



min_caml_start:
	mvhi	%g2, 0
	mvlo	%g2, 24
	addi	%g29, %g0, 1
	sub	%g30, %g0, %g29
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g0, 4
	subi	%g2, %g0, -20
	subi	%g1, %g1, 4
	call	min_caml_create_array
	ldi	%g2, %g0, 4
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g0, 4
	subi	%g2, %g0, -16
	call	min_caml_create_array
	ldi	%g2, %g0, 4
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g0, 4
	subi	%g2, %g0, -12
	call	min_caml_create_array
	ldi	%g2, %g0, 4
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g0, 4
	subi	%g2, %g0, -8
	call	min_caml_create_array
	ldi	%g2, %g0, 4
	addi	%g3, %g0, 1
	addi	%g4, %g0, 1
	sti	%g2, %g0, 4
	subi	%g2, %g0, -4
	call	min_caml_create_array
	ldi	%g2, %g0, 4
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g0, 4
	subi	%g2, %g0, 0
	call	min_caml_create_array
	ldi	%g2, %g0, 4
	addi	%g4, %g0, 10
	call	fib.342
	mov	%g8, %g3
	call	print_int.340
	addi	%g1, %g1, 4
	halt

!---------------------------------------------------------------------
! args = [%g8, %g7, %g5, %g6]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
div_binary_search.335:
	add	%g3, %g5, %g6
	srli	%g4, %g3, 1
	mul	%g9, %g4, %g7
	sub	%g3, %g6, %g5
	jlt	%g29, %g3, jle_else.694
	mov	%g3, %g5
	return
jle_else.694:
	jlt	%g9, %g8, jle_else.695
	jeq	%g9, %g8, jne_else.696
	mov	%g6, %g4
	jmp	div_binary_search.335
jne_else.696:
	mov	%g3, %g4
	return
jle_else.695:
	mov	%g5, %g4
	jmp	div_binary_search.335

!---------------------------------------------------------------------
! args = [%g8]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
print_int.340:
	jlt	%g8, %g0, jge_else.697
	mvhi	%g7, 1525
	mvlo	%g7, 57600
	addi	%g5, %g0, 0
	addi	%g6, %g0, 3
	sti	%g8, %g1, 0
	subi	%g1, %g1, 8
	call	div_binary_search.335
	addi	%g1, %g1, 8
	mvhi	%g4, 1525
	mvlo	%g4, 57600
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 0
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.698
	addi	%g10, %g0, 0
	jmp	jle_cont.699
jle_else.698:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jle_cont.699:
	mvhi	%g7, 152
	mvlo	%g7, 38528
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 4
	subi	%g1, %g1, 12
	call	div_binary_search.335
	addi	%g1, %g1, 12
	mvhi	%g4, 152
	mvlo	%g4, 38528
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 4
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.700
	jeq	%g10, %g0, jne_else.702
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
	jmp	jne_cont.703
jne_else.702:
	addi	%g11, %g0, 0
jne_cont.703:
	jmp	jle_cont.701
jle_else.700:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jle_cont.701:
	mvhi	%g7, 15
	mvlo	%g7, 16960
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 8
	subi	%g1, %g1, 16
	call	div_binary_search.335
	addi	%g1, %g1, 16
	mvhi	%g4, 15
	mvlo	%g4, 16960
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 8
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.704
	jeq	%g11, %g0, jne_else.706
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
	jmp	jne_cont.707
jne_else.706:
	addi	%g10, %g0, 0
jne_cont.707:
	jmp	jle_cont.705
jle_else.704:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jle_cont.705:
	mvhi	%g7, 1
	mvlo	%g7, 34464
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 12
	subi	%g1, %g1, 20
	call	div_binary_search.335
	addi	%g1, %g1, 20
	mvhi	%g4, 1
	mvlo	%g4, 34464
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 12
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.708
	jeq	%g10, %g0, jne_else.710
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
	jmp	jne_cont.711
jne_else.710:
	addi	%g11, %g0, 0
jne_cont.711:
	jmp	jle_cont.709
jle_else.708:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jle_cont.709:
	addi	%g7, %g0, 10000
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 16
	subi	%g1, %g1, 24
	call	div_binary_search.335
	addi	%g1, %g1, 24
	addi	%g4, %g0, 10000
	mul	%g4, %g3, %g4
	ldi	%g8, %g1, 16
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.712
	jeq	%g11, %g0, jne_else.714
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
	jmp	jne_cont.715
jne_else.714:
	addi	%g10, %g0, 0
jne_cont.715:
	jmp	jle_cont.713
jle_else.712:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jle_cont.713:
	addi	%g7, %g0, 1000
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 20
	subi	%g1, %g1, 28
	call	div_binary_search.335
	addi	%g1, %g1, 28
	muli	%g4, %g3, 1000
	ldi	%g8, %g1, 20
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.716
	jeq	%g10, %g0, jne_else.718
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
	jmp	jne_cont.719
jne_else.718:
	addi	%g11, %g0, 0
jne_cont.719:
	jmp	jle_cont.717
jle_else.716:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g11, %g0, 1
jle_cont.717:
	addi	%g7, %g0, 100
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 24
	subi	%g1, %g1, 32
	call	div_binary_search.335
	addi	%g1, %g1, 32
	muli	%g4, %g3, 100
	ldi	%g8, %g1, 24
	sub	%g8, %g8, %g4
	jlt	%g0, %g3, jle_else.720
	jeq	%g11, %g0, jne_else.722
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
	jmp	jne_cont.723
jne_else.722:
	addi	%g10, %g0, 0
jne_cont.723:
	jmp	jle_cont.721
jle_else.720:
	addi	%g4, %g0, 48
	add	%g3, %g4, %g3
	output	%g3
	addi	%g10, %g0, 1
jle_cont.721:
	addi	%g7, %g0, 10
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	sti	%g8, %g1, 28
	subi	%g1, %g1, 36
	call	div_binary_search.335
	addi	%g1, %g1, 36
	muli	%g4, %g3, 10
	ldi	%g8, %g1, 28
	sub	%g4, %g8, %g4
	jlt	%g0, %g3, jle_else.724
	jeq	%g10, %g0, jne_else.726
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g5, %g0, 1
	jmp	jne_cont.727
jne_else.726:
	addi	%g5, %g0, 0
jne_cont.727:
	jmp	jle_cont.725
jle_else.724:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g5, %g0, 1
jle_cont.725:
	addi	%g3, %g0, 48
	add	%g3, %g3, %g4
	output	%g3
	return
jge_else.697:
	addi	%g3, %g0, 45
	output	%g3
	sub	%g8, %g0, %g8
	jmp	print_int.340

!---------------------------------------------------------------------
! args = [%g4]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
fib.342:
	jlt	%g29, %g4, jle_else.728
	mov	%g3, %g4
	return
jle_else.728:
	subi	%g3, %g4, 1
	sti	%g4, %g1, 0
	mov	%g4, %g3
	subi	%g1, %g1, 8
	call	fib.342
	addi	%g1, %g1, 8
	mov	%g5, %g3
	ldi	%g4, %g1, 0
	subi	%g4, %g4, 2
	sti	%g5, %g1, 4
	subi	%g1, %g1, 12
	call	fib.342
	addi	%g1, %g1, 12
	ldi	%g5, %g1, 4
	add	%g3, %g5, %g3
	return
