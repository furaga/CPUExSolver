.init_heap_size	0
	addi %g3, %g0, 1
	addi %g4, %g0, 50
	call min_caml_create_array
	call min_caml_float_create_array
	addi %g3, %g3, 48
	output %g3
	halt

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



