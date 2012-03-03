
!----------------------------------------------------------------------
!
! 		↓　ここから lib_asm.s
!
!----------------------------------------------------------------------

! * create_array
min_caml_create_array:
	slli %g5, %g5, 2
	add %g7, %g5, %g2
	mov %g5, %g2
CREATE_ARRAY_LOOP:
	jlt %g7, %g2, CREATE_ARRAY_END
	jeq %g7, %g2, CREATE_ARRAY_END
	sti %g6, %g2, 0
	addi %g2, %g2, 4
	jmp CREATE_ARRAY_LOOP
CREATE_ARRAY_END:
	return

! * create_float_array
min_caml_create_float_array:
	slli %g5, %g5, 2
	add %g6, %g5, %g2
	mov %g5, %g2
CREATE_FLOAT_ARRAY_LOOP:
	jlt %g6, %g2, CREATE_FLOAT_ARRAY_END
	jeq %g6, %g2, CREATE_FLOAT_ARRAY_END
	fsti %f0, %g2, 0
	addi %g2, %g2, 4
	jmp CREATE_FLOAT_ARRAY_LOOP
CREATE_FLOAT_ARRAY_END:
	return

! * floor		%f0 + MAGICF - MAGICF
min_caml_floor:
	fmov %f1, %f0
	! %f4 <- 0.0
	! fset %f4, 0.0
	fmvhi %f4, 0
	fmvlo %f4, 0
	fjlt %f4, %f0, FLOOR_POSITIVE	! if (%f4 <= %f0) goto FLOOR_PISITIVE
	fjeq %f4, %f0, FLOOR_POSITIVE
FLOOR_NEGATIVE:
	fneg %f0, %f0
	! %f2 <- 8388608.0(0x4b000000)
	fmvhi %f2, 19200
	fmvlo %f2, 0
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
	! %f3 <- 1.0
	! fset %f3, 1.0
	fmvhi %f3, 16256
	fmvlo %f3, 0
	fadd %f0, %f0, %f3
	fsub %f0, %f0, %f2
	fneg %f0, %f0
	return
FLOOR_POSITIVE:
	! %f2 <- 8388608.0(0x4b000000)
	fmvhi %f2, 19200
	fmvlo %f2, 0
	fjlt %f0, %f2, FLOOR_POSITIVE_MAIN
	fjeq %f0, %f2, FLOOR_POSITIVE_MAIN
	return
FLOOR_POSITIVE_MAIN:
	fmov %f1, %f0
	fadd %f0, %f0, %f2
	fsti %f0, %g1, 0
	ldi %g6, %g1, 0
	fsub %f0, %f0, %f2
	fsti %f0, %g1, 0
	ldi %g6, %g1, 0
	fjlt %f0, %f1, FLOOR_RET
	fjeq %f0, %f1, FLOOR_RET
	! %f3 <- 1.0
	! fset %f3, 1.0
	fmvhi %f3, 16256
	fmvlo %f3, 0
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
	jlt %g0, %g5, ITOF_MAIN		! if (%g0 <= %g5) goto ITOF_MAIN
	jeq %g0, %g5, ITOF_MAIN
	sub %g5, %g0, %g5
	call ITOF_MAIN
	fneg %f0, %f0
	return
ITOF_MAIN:
	! %f1 <- 8388608.0(0x4b000000)
	fmvhi %f1, 19200
	fmvlo %f1, 0
	! %g6 <- 0x4b000000
	mvhi %g6, 19200
	mvlo %g6, 0
	! %g7 <- 0x00800000
	mvhi %g7, 128
	mvlo %g7, 0
	jlt %g7, %g5, ITOF_BIG
	jeq %g7, %g5, ITOF_BIG
	add %g5, %g5, %g6
	sti %g5, %g1, 0
	fldi %f0, %g1, 0
	fsub %f0, %f0, %f1
	return
ITOF_BIG:
	! %f2 <- 0.0
	! fset %f2, 0.0
	fmvhi %f2, 0
	fmvlo %f2, 0
ITOF_LOOP:
	sub %g5, %g5, %g7
	fadd %f2, %f2, %f1
	jlt %g7, %g5, ITOF_LOOP
	jeq %g7, %g5, ITOF_LOOP
	add %g5, %g5, %g6
	sti %g5, %g1, 0
	fldi %f0, %g1, 0
	fsub %f0, %f0, %f1
	fadd %f0, %f0, %f2
	return

! * int_of_float
min_caml_int_of_float:
	! %f1 <- 0.0
	! fset %f1, 0.0
	fmvhi %f1, 0
	fmvlo %f1, 0
	fjlt %f1, %f0, FTOI_MAIN			! if (0.0 <= %f0) goto FTOI_MAIN
	fjeq %f1, %f0, FTOI_MAIN
	fneg %f0, %f0
	call FTOI_MAIN
	sub %g5, %g0, %g5
	return
FTOI_MAIN:
	call min_caml_floor
	! %f2 <- 8388608.0(0x4b000000)
	fmvhi %f2, 19200
	fmvlo %f2, 0
	! %g6 <- 0x4b000000
	mvhi %g6, 19200
	mvlo %g6, 0
	fjlt %f2, %f0, FTOI_BIG		! if (MAGICF <= %f0) goto FTOI_BIG
	fjeq %f2, %f0, FTOI_BIG
	fadd %f0, %f0, %f2
	fsti %f0, %g1, 0
	ldi %g5, %g1, 0
	sub %g5, %g5, %g6
	return
FTOI_BIG:
	! %g7 <- 0x00800000
	mvhi %g7, 128
	mvlo %g7, 0
	mov %g5, %g0
FTOI_LOOP:
	fsub %f0, %f0, %f2
	add %g5, %g5, %g7
	fjlt %f2, %f0, FTOI_LOOP
	fjeq %f2, %f0, FTOI_LOOP
	fadd %f0, %f0, %f2
	fsti %f0, %g1, 0
	ldi %g7, %g1, 0
	sub %g7, %g7, %g6
	add %g5, %g7, %g5
	return
	
! * truncate
min_caml_truncate:
	jmp min_caml_int_of_float
	
min_caml_read_int:
	addi %g5, %g0, 0
	! 24 - 31
	input %g6
	add %g5, %g5, %g6
	slli %g5, %g5, 8
	! 16 - 23
	input %g6
	add %g5, %g5, %g6
	slli %g5, %g5, 8
	! 8 - 15
	input %g6
	add %g5, %g5, %g6
	slli %g5, %g5, 8
	! 0 - 7
	input %g6
	add %g5, %g5, %g6
	return

min_caml_read_float:
	call min_caml_read_int
	sti %g5, %g1, 0
	fldi %f0, %g1, 0
	return

!----------------------------------------------------------------------
!
! 		↑　ここまで lib_asm.s
!
!----------------------------------------------------------------------


