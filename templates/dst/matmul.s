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
	mvlo	%g2, 40
	addi	%g29, %g0, 1
	sub	%g30, %g0, %g29
	! 0.000000
	fmvhi	%f16, 0
	fmvlo	%f16, 0
	! 12.000000
	fmvhi	%f17, 16704
	fmvlo	%f17, 0
	! 11.000000
	fmvhi	%f18, 16688
	fmvlo	%f18, 0
	! 10.000000
	fmvhi	%f19, 16672
	fmvlo	%f19, 0
	! 9.000000
	fmvhi	%f20, 16656
	fmvlo	%f20, 0
	! 8.000000
	fmvhi	%f21, 16640
	fmvlo	%f21, 0
	! 7.000000
	fmvhi	%f22, 16608
	fmvlo	%f22, 0
	! 6.000000
	fmvhi	%f23, 16576
	fmvlo	%f23, 0
	! 5.000000
	fmvhi	%f24, 16544
	fmvlo	%f24, 0
	! 4.000000
	fmvhi	%f25, 16512
	fmvlo	%f25, 0
	! 3.000000
	fmvhi	%f26, 16448
	fmvlo	%f26, 0
	! 1.000000
	fmvhi	%f27, 16256
	fmvlo	%f27, 0
	! 2.000000
	fmvhi	%f28, 16384
	fmvlo	%f28, 0
	fmov	%f0, %f28
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g0, 4
	subi	%g2, %g0, -36
	fsti	%f0, %g1, 0
	sti	%g31, %g1, 8
	subi	%g1, %g1, 12
	jal	min_caml_create_array
	addi	%g1, %g1, 12
	ldi	%g31, %g1, 8
	ldi	%g2, %g0, 4
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g0, 4
	subi	%g2, %g0, -32
	sti	%g31, %g1, 8
	subi	%g1, %g1, 12
	jal	min_caml_create_array
	addi	%g1, %g1, 12
	ldi	%g31, %g1, 8
	ldi	%g2, %g0, 4
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g0, 4
	subi	%g2, %g0, -28
	sti	%g31, %g1, 8
	subi	%g1, %g1, 12
	jal	min_caml_create_array
	addi	%g1, %g1, 12
	ldi	%g31, %g1, 8
	ldi	%g2, %g0, 4
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g0, 4
	subi	%g2, %g0, -24
	sti	%g31, %g1, 8
	subi	%g1, %g1, 12
	jal	min_caml_create_array
	addi	%g1, %g1, 12
	ldi	%g31, %g1, 8
	ldi	%g2, %g0, 4
	addi	%g3, %g0, 1
	addi	%g4, %g0, 1
	sti	%g2, %g0, 4
	subi	%g2, %g0, -20
	sti	%g31, %g1, 8
	subi	%g1, %g1, 12
	jal	min_caml_create_array
	addi	%g1, %g1, 12
	ldi	%g31, %g1, 8
	ldi	%g2, %g0, 4
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g0, 4
	subi	%g2, %g0, -16
	sti	%g31, %g1, 8
	subi	%g1, %g1, 12
	jal	min_caml_create_array
	addi	%g1, %g1, 12
	ldi	%g31, %g1, 8
	ldi	%g2, %g0, 4
	addi	%g3, %g0, 0
	fmov	%f0, %f16
	sti	%g2, %g0, 4
	subi	%g2, %g0, -12
	sti	%g31, %g1, 8
	subi	%g1, %g1, 12
	jal	min_caml_create_float_array
	addi	%g1, %g1, 12
	ldi	%g31, %g1, 8
	ldi	%g2, %g0, 4
	addi	%g3, %g0, 2
	addi	%g4, %g0, 3
	sti	%g31, %g1, 8
	subi	%g1, %g1, 12
	jal	make.477
	addi	%g1, %g1, 12
	ldi	%g31, %g1, 8
	sti	%g3, %g0, -8
	addi	%g4, %g0, 3
	addi	%g5, %g0, 2
	sti	%g3, %g1, 4
	mov	%g3, %g4
	mov	%g4, %g5
	sti	%g31, %g1, 12
	subi	%g1, %g1, 16
	jal	make.477
	addi	%g1, %g1, 16
	ldi	%g31, %g1, 12
	sti	%g3, %g0, -4
	addi	%g4, %g0, 2
	addi	%g5, %g0, 2
	sti	%g3, %g1, 8
	mov	%g3, %g4
	mov	%g4, %g5
	sti	%g31, %g1, 16
	subi	%g1, %g1, 20
	jal	make.477
	addi	%g1, %g1, 20
	ldi	%g31, %g1, 16
	mov	%g8, %g3
	sti	%g8, %g0, 0
	ldi	%g6, %g1, 4
	ldi	%g3, %g6, 0
	fmov	%f0, %f27
	fsti	%f0, %g3, 0
	ldi	%g3, %g6, 0
	fldi	%f0, %g1, 0
	fsti	%f0, %g3, -4
	ldi	%g3, %g6, 0
	fmov	%f0, %f26
	fsti	%f0, %g3, -8
	ldi	%g3, %g6, -4
	fmov	%f0, %f25
	fsti	%f0, %g3, 0
	ldi	%g3, %g6, -4
	fmov	%f0, %f24
	fsti	%f0, %g3, -4
	ldi	%g3, %g6, -4
	fmov	%f0, %f23
	fsti	%f0, %g3, -8
	ldi	%g7, %g1, 8
	ldi	%g3, %g7, 0
	fmov	%f0, %f22
	fsti	%f0, %g3, 0
	ldi	%g3, %g7, 0
	fmov	%f0, %f21
	fsti	%f0, %g3, -4
	ldi	%g3, %g7, -4
	fmov	%f0, %f20
	fsti	%f0, %g3, 0
	ldi	%g3, %g7, -4
	fmov	%f0, %f19
	fsti	%f0, %g3, -4
	ldi	%g3, %g7, -8
	fmov	%f0, %f18
	fsti	%f0, %g3, 0
	ldi	%g3, %g7, -8
	fmov	%f0, %f17
	fsti	%f0, %g3, -4
	addi	%g3, %g0, 2
	addi	%g4, %g0, 3
	addi	%g5, %g0, 2
	sti	%g8, %g1, 12
	sti	%g31, %g1, 20
	subi	%g1, %g1, 24
	jal	mul.469
	addi	%g1, %g1, 24
	ldi	%g31, %g1, 20
	ldi	%g3, %g1, 12
	ldi	%g4, %g3, 0
	fldi	%f0, %g4, 0
	sti	%g31, %g1, 20
	subi	%g1, %g1, 24
	jal	min_caml_truncate
	addi	%g1, %g1, 24
	ldi	%g31, %g1, 20
	sti	%g31, %g1, 20
	subi	%g1, %g1, 24
	jal	print_int.467
	addi	%g1, %g1, 24
	ldi	%g31, %g1, 20
	sti	%g3, %g1, 20
	addi	%g3, %g0, 10
	output	%g3
	ldi	%g3, %g1, 20
	ldi	%g3, %g1, 12
	ldi	%g4, %g3, 0
	fldi	%f0, %g4, -4
	sti	%g31, %g1, 20
	subi	%g1, %g1, 24
	jal	min_caml_truncate
	addi	%g1, %g1, 24
	ldi	%g31, %g1, 20
	sti	%g31, %g1, 20
	subi	%g1, %g1, 24
	jal	print_int.467
	addi	%g1, %g1, 24
	ldi	%g31, %g1, 20
	sti	%g3, %g1, 20
	addi	%g3, %g0, 10
	output	%g3
	ldi	%g3, %g1, 20
	ldi	%g3, %g1, 12
	ldi	%g4, %g3, -4
	fldi	%f0, %g4, 0
	sti	%g31, %g1, 20
	subi	%g1, %g1, 24
	jal	min_caml_truncate
	addi	%g1, %g1, 24
	ldi	%g31, %g1, 20
	sti	%g31, %g1, 20
	subi	%g1, %g1, 24
	jal	print_int.467
	addi	%g1, %g1, 24
	ldi	%g31, %g1, 20
	sti	%g3, %g1, 20
	addi	%g3, %g0, 10
	output	%g3
	ldi	%g3, %g1, 20
	ldi	%g3, %g1, 12
	ldi	%g3, %g3, -4
	fldi	%f0, %g3, -4
	sti	%g31, %g1, 20
	subi	%g1, %g1, 24
	jal	min_caml_truncate
	addi	%g1, %g1, 24
	ldi	%g31, %g1, 20
	sti	%g31, %g1, 20
	subi	%g1, %g1, 24
	jal	print_int.467
	addi	%g1, %g1, 24
	ldi	%g31, %g1, 20
	sti	%g3, %g1, 20
	addi	%g3, %g0, 10
	output	%g3
	ldi	%g3, %g1, 20
	halt

!---------------------------------------------------------------------
! args = [%g3, %g4, %g5, %g6]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
div_binary_search.462:
	add	%g7, %g5, %g6
	srli	%g7, %g7, 1
	mul	%g8, %g7, %g4
	sub	%g9, %g6, %g5
	jlt	%g29, %g9, jle_else.1131
	mov	%g3, %g5
	b	%g31
jle_else.1131:
	jlt	%g8, %g3, jle_else.1132
	jeq	%g8, %g3, jne_else.1133
	mov	%g6, %g7
	jmp	div_binary_search.462
jne_else.1133:
	mov	%g3, %g7
	b	%g31
jle_else.1132:
	mov	%g5, %g7
	jmp	div_binary_search.462

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
print_int.467:
	jlt	%g3, %g0, jge_else.1134
	mvhi	%g4, 1525
	mvlo	%g4, 57600
	addi	%g5, %g0, 0
	addi	%g6, %g0, 3
	sti	%g3, %g1, 0
	sti	%g31, %g1, 8
	subi	%g1, %g1, 12
	jal	div_binary_search.462
	addi	%g1, %g1, 12
	ldi	%g31, %g1, 8
	mvhi	%g4, 1525
	mvlo	%g4, 57600
	mul	%g4, %g3, %g4
	ldi	%g5, %g1, 0
	sub	%g4, %g5, %g4
	sti	%g4, %g1, 4
	jlt	%g0, %g3, jle_else.1135
	addi	%g3, %g0, 0
	jmp	jle_cont.1136
jle_else.1135:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
jle_cont.1136:
	mvhi	%g4, 152
	mvlo	%g4, 38528
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	ldi	%g7, %g1, 4
	sti	%g3, %g1, 8
	mov	%g3, %g7
	sti	%g31, %g1, 16
	subi	%g1, %g1, 20
	jal	div_binary_search.462
	addi	%g1, %g1, 20
	ldi	%g31, %g1, 16
	mvhi	%g4, 152
	mvlo	%g4, 38528
	mul	%g4, %g3, %g4
	ldi	%g5, %g1, 4
	sub	%g4, %g5, %g4
	sti	%g4, %g1, 12
	jlt	%g0, %g3, jle_else.1137
	ldi	%g5, %g1, 8
	jeq	%g5, %g0, jne_else.1139
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
	jmp	jne_cont.1140
jne_else.1139:
	addi	%g3, %g0, 0
jne_cont.1140:
	jmp	jle_cont.1138
jle_else.1137:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
jle_cont.1138:
	mvhi	%g4, 15
	mvlo	%g4, 16960
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	ldi	%g7, %g1, 12
	sti	%g3, %g1, 16
	mov	%g3, %g7
	sti	%g31, %g1, 24
	subi	%g1, %g1, 28
	jal	div_binary_search.462
	addi	%g1, %g1, 28
	ldi	%g31, %g1, 24
	mvhi	%g4, 15
	mvlo	%g4, 16960
	mul	%g4, %g3, %g4
	ldi	%g5, %g1, 12
	sub	%g4, %g5, %g4
	sti	%g4, %g1, 20
	jlt	%g0, %g3, jle_else.1141
	ldi	%g5, %g1, 16
	jeq	%g5, %g0, jne_else.1143
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
	jmp	jne_cont.1144
jne_else.1143:
	addi	%g3, %g0, 0
jne_cont.1144:
	jmp	jle_cont.1142
jle_else.1141:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
jle_cont.1142:
	mvhi	%g4, 1
	mvlo	%g4, 34464
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	ldi	%g7, %g1, 20
	sti	%g3, %g1, 24
	mov	%g3, %g7
	sti	%g31, %g1, 32
	subi	%g1, %g1, 36
	jal	div_binary_search.462
	addi	%g1, %g1, 36
	ldi	%g31, %g1, 32
	mvhi	%g4, 1
	mvlo	%g4, 34464
	mul	%g4, %g3, %g4
	ldi	%g5, %g1, 20
	sub	%g4, %g5, %g4
	sti	%g4, %g1, 28
	jlt	%g0, %g3, jle_else.1145
	ldi	%g5, %g1, 24
	jeq	%g5, %g0, jne_else.1147
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
	jmp	jne_cont.1148
jne_else.1147:
	addi	%g3, %g0, 0
jne_cont.1148:
	jmp	jle_cont.1146
jle_else.1145:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
jle_cont.1146:
	addi	%g4, %g0, 10000
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	ldi	%g7, %g1, 28
	sti	%g3, %g1, 32
	mov	%g3, %g7
	sti	%g31, %g1, 40
	subi	%g1, %g1, 44
	jal	div_binary_search.462
	addi	%g1, %g1, 44
	ldi	%g31, %g1, 40
	addi	%g4, %g0, 10000
	mul	%g4, %g3, %g4
	ldi	%g5, %g1, 28
	sub	%g4, %g5, %g4
	sti	%g4, %g1, 36
	jlt	%g0, %g3, jle_else.1149
	ldi	%g5, %g1, 32
	jeq	%g5, %g0, jne_else.1151
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
	jmp	jne_cont.1152
jne_else.1151:
	addi	%g3, %g0, 0
jne_cont.1152:
	jmp	jle_cont.1150
jle_else.1149:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
jle_cont.1150:
	addi	%g4, %g0, 1000
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	ldi	%g7, %g1, 36
	sti	%g3, %g1, 40
	mov	%g3, %g7
	sti	%g31, %g1, 48
	subi	%g1, %g1, 52
	jal	div_binary_search.462
	addi	%g1, %g1, 52
	ldi	%g31, %g1, 48
	muli	%g4, %g3, 1000
	ldi	%g5, %g1, 36
	sub	%g4, %g5, %g4
	sti	%g4, %g1, 44
	jlt	%g0, %g3, jle_else.1153
	ldi	%g5, %g1, 40
	jeq	%g5, %g0, jne_else.1155
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
	jmp	jne_cont.1156
jne_else.1155:
	addi	%g3, %g0, 0
jne_cont.1156:
	jmp	jle_cont.1154
jle_else.1153:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
jle_cont.1154:
	addi	%g4, %g0, 100
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	ldi	%g7, %g1, 44
	sti	%g3, %g1, 48
	mov	%g3, %g7
	sti	%g31, %g1, 56
	subi	%g1, %g1, 60
	jal	div_binary_search.462
	addi	%g1, %g1, 60
	ldi	%g31, %g1, 56
	muli	%g4, %g3, 100
	ldi	%g5, %g1, 44
	sub	%g4, %g5, %g4
	sti	%g4, %g1, 52
	jlt	%g0, %g3, jle_else.1157
	ldi	%g5, %g1, 48
	jeq	%g5, %g0, jne_else.1159
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
	jmp	jne_cont.1160
jne_else.1159:
	addi	%g3, %g0, 0
jne_cont.1160:
	jmp	jle_cont.1158
jle_else.1157:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
jle_cont.1158:
	addi	%g4, %g0, 10
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	ldi	%g7, %g1, 52
	sti	%g3, %g1, 56
	mov	%g3, %g7
	sti	%g31, %g1, 64
	subi	%g1, %g1, 68
	jal	div_binary_search.462
	addi	%g1, %g1, 68
	ldi	%g31, %g1, 64
	muli	%g4, %g3, 10
	ldi	%g5, %g1, 52
	sub	%g4, %g5, %g4
	sti	%g4, %g1, 60
	jlt	%g0, %g3, jle_else.1161
	ldi	%g5, %g1, 56
	jeq	%g5, %g0, jne_else.1163
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
	jmp	jne_cont.1164
jne_else.1163:
	addi	%g3, %g0, 0
jne_cont.1164:
	jmp	jle_cont.1162
jle_else.1161:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
jle_cont.1162:
	addi	%g3, %g0, 48
	ldi	%g4, %g1, 60
	add	%g3, %g3, %g4
	output	%g3
	b	%g31
jge_else.1134:
	addi	%g4, %g0, 45
	sti	%g3, %g1, 0
	output	%g4
	ldi	%g3, %g1, 0
	sub	%g3, %g0, %g3
	jmp	print_int.467

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
loop3.608:
	ldi	%g4, %g28, -20
	ldi	%g5, %g28, -16
	ldi	%g6, %g28, -12
	ldi	%g7, %g28, -8
	ldi	%g8, %g28, -4
	jlt	%g3, %g0, jge_else.1165
	slli	%g9, %g5, 2
	ld	%g6, %g6, %g9
	slli	%g9, %g4, 2
	fld	%f0, %g6, %g9
	slli	%g5, %g5, 2
	ld	%g5, %g8, %g5
	slli	%g8, %g3, 2
	fld	%f1, %g5, %g8
	slli	%g5, %g3, 2
	ld	%g5, %g7, %g5
	slli	%g7, %g4, 2
	fld	%f2, %g5, %g7
	fmul	%f1, %f1, %f2
	fadd	%f0, %f0, %f1
	slli	%g4, %g4, 2
	fst	%f0, %g6, %g4
	subi	%g3, %g3, 1
	ldi	%g27, %g28, 0
	b	%g27
jge_else.1165:
	b	%g31

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
loop2.601:
	ldi	%g4, %g28, -20
	ldi	%g5, %g28, -16
	ldi	%g6, %g28, -12
	ldi	%g7, %g28, -8
	ldi	%g8, %g28, -4
	jlt	%g3, %g0, jge_else.1167
	mov	%g9, %g2
	addi	%g2, %g2, 24
	setL %g10, loop3.608
	sti	%g10, %g9, 0
	sti	%g3, %g9, -20
	sti	%g5, %g9, -16
	sti	%g6, %g9, -12
	sti	%g7, %g9, -8
	sti	%g8, %g9, -4
	subi	%g4, %g4, 1
	sti	%g3, %g1, 0
	mov	%g3, %g4
	mov	%g28, %g9
	ldi	%g27, %g28, 0
	subi	%g1, %g1, 8
	callR	%g27
	addi	%g1, %g1, 8
	ldi	%g3, %g1, 0
	subi	%g3, %g3, 1
	ldi	%g27, %g28, 0
	b	%g27
jge_else.1167:
	b	%g31

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
loop1.597:
	ldi	%g4, %g28, -20
	ldi	%g5, %g28, -16
	ldi	%g6, %g28, -12
	ldi	%g7, %g28, -8
	ldi	%g8, %g28, -4
	jlt	%g3, %g0, jge_else.1169
	mov	%g9, %g2
	addi	%g2, %g2, 24
	setL %g10, loop2.601
	sti	%g10, %g9, 0
	sti	%g5, %g9, -20
	sti	%g3, %g9, -16
	sti	%g6, %g9, -12
	sti	%g7, %g9, -8
	sti	%g8, %g9, -4
	subi	%g4, %g4, 1
	sti	%g3, %g1, 0
	mov	%g3, %g4
	mov	%g28, %g9
	ldi	%g27, %g28, 0
	subi	%g1, %g1, 8
	callR	%g27
	addi	%g1, %g1, 8
	ldi	%g3, %g1, 0
	subi	%g3, %g3, 1
	ldi	%g27, %g28, 0
	b	%g27
jge_else.1169:
	b	%g31

!---------------------------------------------------------------------
! args = [%g3, %g4, %g5, %g6, %g7, %g8]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
mul.469:
	mov	%g28, %g2
	addi	%g2, %g2, 24
	setL %g9, loop1.597
	sti	%g9, %g28, 0
	sti	%g5, %g28, -20
	sti	%g4, %g28, -16
	sti	%g8, %g28, -12
	sti	%g7, %g28, -8
	sti	%g6, %g28, -4
	subi	%g3, %g3, 1
	ldi	%g27, %g28, 0
	b	%g27

!---------------------------------------------------------------------
! args = [%g3]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
init.585:
	ldi	%g4, %g28, -8
	ldi	%g5, %g28, -4
	jlt	%g3, %g0, jge_else.1171
	fmov	%f0, %f16
	sti	%g5, %g1, 0
	sti	%g3, %g1, 4
	mov	%g3, %g4
	sti	%g31, %g1, 12
	subi	%g1, %g1, 16
	jal	min_caml_create_float_array
	addi	%g1, %g1, 16
	ldi	%g31, %g1, 12
	ldi	%g4, %g1, 4
	slli	%g5, %g4, 2
	ldi	%g6, %g1, 0
	st	%g3, %g6, %g5
	subi	%g3, %g4, 1
	ldi	%g27, %g28, 0
	b	%g27
jge_else.1171:
	b	%g31

!---------------------------------------------------------------------
! args = [%g3, %g4]
! fargs = []
! ret type = Array(Array(Float))
!---------------------------------------------------------------------
make.477:
	subi	%g5, %g0, -12
	sti	%g3, %g1, 0
	sti	%g4, %g1, 4
	mov	%g4, %g5
	sti	%g31, %g1, 12
	subi	%g1, %g1, 16
	jal	min_caml_create_array
	addi	%g1, %g1, 16
	ldi	%g31, %g1, 12
	mov	%g28, %g2
	addi	%g2, %g2, 12
	setL %g4, init.585
	sti	%g4, %g28, 0
	ldi	%g4, %g1, 4
	sti	%g4, %g28, -8
	sti	%g3, %g28, -4
	ldi	%g4, %g1, 0
	subi	%g4, %g4, 1
	sti	%g3, %g1, 8
	mov	%g3, %g4
	ldi	%g27, %g28, 0
	subi	%g1, %g1, 16
	callR	%g27
	addi	%g1, %g1, 16
	ldi	%g3, %g1, 8
	b	%g31
