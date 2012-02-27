.init_heap_size	608
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
l.934:	! 12.000000
	.long	0x41400000
l.929:	! 11.000000
	.long	0x41300000
l.924:	! 10.000000
	.long	0x41200000
l.919:	! 9.000000
	.long	0x41100000
l.914:	! 8.000000
	.long	0x41000000
l.909:	! 7.000000
	.long	0x40e00000
l.904:	! 6.000000
	.long	0x40c00000
l.899:	! 5.000000
	.long	0x40a00000
l.894:	! 4.000000
	.long	0x40800000
l.889:	! 3.000000
	.long	0x40400000
l.881:	! 1.000000
	.long	0x3f800000
l.877:	! 0.000000
	.long	0x0
l.875:	! 2.000000
	.long	0x40000000
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
	subi	%g1, %g1, 48
	addi	%g28, %g0, 1
	addi	%g29, %g0, -1
	setL %g27, l.877
	fldi	%f16, %g27, 0
	setL %g27, l.934
	fldi	%f17, %g27, 0
	setL %g27, l.929
	fldi	%f18, %g27, 0
	setL %g27, l.924
	fldi	%f19, %g27, 0
	setL %g27, l.919
	fldi	%f20, %g27, 0
	setL %g27, l.914
	fldi	%f21, %g27, 0
	setL %g27, l.909
	fldi	%f22, %g27, 0
	setL %g27, l.904
	fldi	%f23, %g27, 0
	setL %g27, l.899
	fldi	%f24, %g27, 0
	setL %g27, l.894
	fldi	%f25, %g27, 0
	setL %g27, l.889
	fldi	%f26, %g27, 0
	setL %g27, l.881
	fldi	%f27, %g27, 0
	setL %g27, l.875
	fldi	%f28, %g27, 0
	fmov	%f0, %f28
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 44
	subi	%g2, %g31, 4
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	min_caml_create_array
	ldi	%g2, %g31, 44
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 44
	subi	%g2, %g31, 8
	call	min_caml_create_array
	ldi	%g2, %g31, 44
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 44
	subi	%g2, %g31, 12
	call	min_caml_create_array
	ldi	%g2, %g31, 44
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 44
	subi	%g2, %g31, 16
	call	min_caml_create_array
	ldi	%g2, %g31, 44
	addi	%g3, %g0, 1
	addi	%g4, %g0, 1
	sti	%g2, %g31, 44
	subi	%g2, %g31, 20
	call	min_caml_create_array
	ldi	%g2, %g31, 44
	addi	%g3, %g0, 1
	addi	%g4, %g0, 0
	sti	%g2, %g31, 44
	subi	%g2, %g31, 24
	call	min_caml_create_array
	ldi	%g2, %g31, 44
	addi	%g3, %g0, 0
	fmov	%f0, %f16
	sti	%g2, %g31, 44
	subi	%g2, %g31, 28
	call	min_caml_create_float_array
	ldi	%g2, %g31, 44
	addi	%g3, %g0, 2
	addi	%g4, %g0, 3
	call	make.441
	addi	%g1, %g1, 8
	sti	%g3, %g31, 32
	addi	%g4, %g0, 3
	addi	%g5, %g0, 2
	sti	%g3, %g1, 4
	mov	%g3, %g4
	mov	%g4, %g5
	subi	%g1, %g1, 12
	call	make.441
	addi	%g1, %g1, 12
	sti	%g3, %g31, 36
	addi	%g4, %g0, 2
	addi	%g5, %g0, 2
	sti	%g3, %g1, 8
	mov	%g3, %g4
	mov	%g4, %g5
	subi	%g1, %g1, 16
	call	make.441
	addi	%g1, %g1, 16
	mov	%g8, %g3
	sti	%g8, %g31, 40
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
	subi	%g1, %g1, 20
	call	mul.433
	addi	%g1, %g1, 20
	ldi	%g3, %g1, 12
	ldi	%g4, %g3, 0
	fldi	%f0, %g4, 0
	subi	%g1, %g1, 20
	call	min_caml_truncate
	call	print_int.431
	addi	%g1, %g1, 20
	sti	%g3, %g1, 20
	addi	%g3, %g0, 10
	output	%g3
	ldi	%g3, %g1, 20
	ldi	%g3, %g1, 12
	ldi	%g4, %g3, 0
	fldi	%f0, %g4, -4
	subi	%g1, %g1, 20
	call	min_caml_truncate
	call	print_int.431
	addi	%g1, %g1, 20
	sti	%g3, %g1, 20
	addi	%g3, %g0, 10
	output	%g3
	ldi	%g3, %g1, 20
	ldi	%g3, %g1, 12
	ldi	%g4, %g3, -4
	fldi	%f0, %g4, 0
	subi	%g1, %g1, 20
	call	min_caml_truncate
	call	print_int.431
	addi	%g1, %g1, 20
	sti	%g3, %g1, 20
	addi	%g3, %g0, 10
	output	%g3
	ldi	%g3, %g1, 20
	ldi	%g3, %g1, 12
	ldi	%g3, %g3, -4
	fldi	%f0, %g3, -4
	subi	%g1, %g1, 20
	call	min_caml_truncate
	call	print_int.431
	addi	%g1, %g1, 20
	sti	%g3, %g1, 20
	addi	%g3, %g0, 10
	output	%g3
	ldi	%g3, %g1, 20
	halt

!==============================
! args = [%g3, %g4, %g5, %g6]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0]
! ret type = Int
!================================
div_binary_search.426:
	add	%g7, %g5, %g6
	srli	%g7, %g7, 1
	mul	%g8, %g7, %g4
	sub	%g9, %g6, %g5
	jlt	%g28, %g9, jle_else.1081
	mov	%g3, %g5
	return
jle_else.1081:
	jlt	%g8, %g3, jle_else.1082
	jne	%g8, %g3, jeq_else.1083
	mov	%g3, %g7
	return
jeq_else.1083:
	mov	%g6, %g7
	jmp	div_binary_search.426
jle_else.1082:
	mov	%g5, %g7
	jmp	div_binary_search.426

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0]
! ret type = Unit
!================================
print_int.431:
	jlt	%g3, %g0, jge_else.1084
	mvhi	%g4, 1525
	mvlo	%g4, 57600
	addi	%g5, %g0, 0
	addi	%g6, %g0, 3
	sti	%g3, %g1, 0
	subi	%g1, %g1, 8
	call	div_binary_search.426
	addi	%g1, %g1, 8
	mvhi	%g4, 1525
	mvlo	%g4, 57600
	mul	%g4, %g3, %g4
	ldi	%g5, %g1, 0
	sub	%g4, %g5, %g4
	sti	%g4, %g1, 4
	jlt	%g0, %g3, jle_else.1085
	addi	%g3, %g0, 0
	jmp	jle_cont.1086
jle_else.1085:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
jle_cont.1086:
	mvhi	%g4, 152
	mvlo	%g4, 38528
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	ldi	%g7, %g1, 4
	sti	%g3, %g1, 8
	mov	%g3, %g7
	subi	%g1, %g1, 16
	call	div_binary_search.426
	addi	%g1, %g1, 16
	mvhi	%g4, 152
	mvlo	%g4, 38528
	mul	%g4, %g3, %g4
	ldi	%g5, %g1, 4
	sub	%g4, %g5, %g4
	sti	%g4, %g1, 12
	jlt	%g0, %g3, jle_else.1087
	ldi	%g5, %g1, 8
	jne	%g5, %g0, jeq_else.1089
	addi	%g3, %g0, 0
	jmp	jeq_cont.1090
jeq_else.1089:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
jeq_cont.1090:
	jmp	jle_cont.1088
jle_else.1087:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
jle_cont.1088:
	mvhi	%g4, 15
	mvlo	%g4, 16960
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	ldi	%g7, %g1, 12
	sti	%g3, %g1, 16
	mov	%g3, %g7
	subi	%g1, %g1, 24
	call	div_binary_search.426
	addi	%g1, %g1, 24
	mvhi	%g4, 15
	mvlo	%g4, 16960
	mul	%g4, %g3, %g4
	ldi	%g5, %g1, 12
	sub	%g4, %g5, %g4
	sti	%g4, %g1, 20
	jlt	%g0, %g3, jle_else.1091
	ldi	%g5, %g1, 16
	jne	%g5, %g0, jeq_else.1093
	addi	%g3, %g0, 0
	jmp	jeq_cont.1094
jeq_else.1093:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
jeq_cont.1094:
	jmp	jle_cont.1092
jle_else.1091:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
jle_cont.1092:
	mvhi	%g4, 1
	mvlo	%g4, 34464
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	ldi	%g7, %g1, 20
	sti	%g3, %g1, 24
	mov	%g3, %g7
	subi	%g1, %g1, 32
	call	div_binary_search.426
	addi	%g1, %g1, 32
	mvhi	%g4, 1
	mvlo	%g4, 34464
	mul	%g4, %g3, %g4
	ldi	%g5, %g1, 20
	sub	%g4, %g5, %g4
	sti	%g4, %g1, 28
	jlt	%g0, %g3, jle_else.1095
	ldi	%g5, %g1, 24
	jne	%g5, %g0, jeq_else.1097
	addi	%g3, %g0, 0
	jmp	jeq_cont.1098
jeq_else.1097:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
jeq_cont.1098:
	jmp	jle_cont.1096
jle_else.1095:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
jle_cont.1096:
	addi	%g4, %g0, 10000
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	ldi	%g7, %g1, 28
	sti	%g3, %g1, 32
	mov	%g3, %g7
	subi	%g1, %g1, 40
	call	div_binary_search.426
	addi	%g1, %g1, 40
	addi	%g4, %g0, 10000
	mul	%g4, %g3, %g4
	ldi	%g5, %g1, 28
	sub	%g4, %g5, %g4
	sti	%g4, %g1, 36
	jlt	%g0, %g3, jle_else.1099
	ldi	%g5, %g1, 32
	jne	%g5, %g0, jeq_else.1101
	addi	%g3, %g0, 0
	jmp	jeq_cont.1102
jeq_else.1101:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
jeq_cont.1102:
	jmp	jle_cont.1100
jle_else.1099:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
jle_cont.1100:
	addi	%g4, %g0, 1000
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	ldi	%g7, %g1, 36
	sti	%g3, %g1, 40
	mov	%g3, %g7
	subi	%g1, %g1, 48
	call	div_binary_search.426
	addi	%g1, %g1, 48
	muli	%g4, %g3, 1000
	ldi	%g5, %g1, 36
	sub	%g4, %g5, %g4
	sti	%g4, %g1, 44
	jlt	%g0, %g3, jle_else.1103
	ldi	%g5, %g1, 40
	jne	%g5, %g0, jeq_else.1105
	addi	%g3, %g0, 0
	jmp	jeq_cont.1106
jeq_else.1105:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
jeq_cont.1106:
	jmp	jle_cont.1104
jle_else.1103:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
jle_cont.1104:
	addi	%g4, %g0, 100
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	ldi	%g7, %g1, 44
	sti	%g3, %g1, 48
	mov	%g3, %g7
	subi	%g1, %g1, 56
	call	div_binary_search.426
	addi	%g1, %g1, 56
	muli	%g4, %g3, 100
	ldi	%g5, %g1, 44
	sub	%g4, %g5, %g4
	sti	%g4, %g1, 52
	jlt	%g0, %g3, jle_else.1107
	ldi	%g5, %g1, 48
	jne	%g5, %g0, jeq_else.1109
	addi	%g3, %g0, 0
	jmp	jeq_cont.1110
jeq_else.1109:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
jeq_cont.1110:
	jmp	jle_cont.1108
jle_else.1107:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
jle_cont.1108:
	addi	%g4, %g0, 10
	addi	%g5, %g0, 0
	addi	%g6, %g0, 10
	ldi	%g7, %g1, 52
	sti	%g3, %g1, 56
	mov	%g3, %g7
	subi	%g1, %g1, 64
	call	div_binary_search.426
	addi	%g1, %g1, 64
	muli	%g4, %g3, 10
	ldi	%g5, %g1, 52
	sub	%g4, %g5, %g4
	sti	%g4, %g1, 60
	jlt	%g0, %g3, jle_else.1111
	ldi	%g5, %g1, 56
	jne	%g5, %g0, jeq_else.1113
	addi	%g3, %g0, 0
	jmp	jeq_cont.1114
jeq_else.1113:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
jeq_cont.1114:
	jmp	jle_cont.1112
jle_else.1111:
	addi	%g5, %g0, 48
	add	%g3, %g5, %g3
	output	%g3
	addi	%g3, %g0, 1
jle_cont.1112:
	addi	%g3, %g0, 48
	ldi	%g4, %g1, 60
	add	%g3, %g3, %g4
	output	%g3
	return
jge_else.1084:
	addi	%g4, %g0, 45
	sti	%g3, %g1, 0
	output	%g4
	ldi	%g3, %g1, 0
	sub	%g3, %g0, %g3
	jmp	print_int.431

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0]
! ret type = Unit
!================================
loop3.572:
	ldi	%g4, %g30, -20
	ldi	%g5, %g30, -16
	ldi	%g6, %g30, -12
	ldi	%g7, %g30, -8
	ldi	%g8, %g30, -4
	jlt	%g3, %g0, jge_else.1115
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
	ldi	%g27, %g30, 0
	b	%g27
jge_else.1115:
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0]
! ret type = Unit
!================================
loop2.565:
	ldi	%g4, %g30, -20
	ldi	%g5, %g30, -16
	ldi	%g6, %g30, -12
	ldi	%g7, %g30, -8
	ldi	%g8, %g30, -4
	jlt	%g3, %g0, jge_else.1117
	mov	%g9, %g2
	addi	%g2, %g2, 24
	setL %g10, loop3.572
	sti	%g10, %g9, 0
	sti	%g3, %g9, -20
	sti	%g5, %g9, -16
	sti	%g6, %g9, -12
	sti	%g7, %g9, -8
	sti	%g8, %g9, -4
	subi	%g4, %g4, 1
	sti	%g30, %g1, 0
	sti	%g3, %g1, 4
	mov	%g3, %g4
	mov	%g30, %g9
	ldi	%g27, %g30, 0
	subi	%g1, %g1, 12
	callR	%g27
	addi	%g1, %g1, 12
	ldi	%g3, %g1, 4
	subi	%g3, %g3, 1
	ldi	%g30, %g1, 0
	ldi	%g27, %g30, 0
	b	%g27
jge_else.1117:
	return

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0]
! ret type = Unit
!================================
loop1.561:
	ldi	%g4, %g30, -20
	ldi	%g5, %g30, -16
	ldi	%g6, %g30, -12
	ldi	%g7, %g30, -8
	ldi	%g8, %g30, -4
	jlt	%g3, %g0, jge_else.1119
	mov	%g9, %g2
	addi	%g2, %g2, 24
	setL %g10, loop2.565
	sti	%g10, %g9, 0
	sti	%g5, %g9, -20
	sti	%g3, %g9, -16
	sti	%g6, %g9, -12
	sti	%g7, %g9, -8
	sti	%g8, %g9, -4
	subi	%g4, %g4, 1
	sti	%g30, %g1, 0
	sti	%g3, %g1, 4
	mov	%g3, %g4
	mov	%g30, %g9
	ldi	%g27, %g30, 0
	subi	%g1, %g1, 12
	callR	%g27
	addi	%g1, %g1, 12
	ldi	%g3, %g1, 4
	subi	%g3, %g3, 1
	ldi	%g30, %g1, 0
	ldi	%g27, %g30, 0
	b	%g27
jge_else.1119:
	return

!==============================
! args = [%g3, %g4, %g5, %g6, %g7, %g8]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0]
! ret type = Unit
!================================
mul.433:
	mov	%g30, %g2
	addi	%g2, %g2, 24
	setL %g9, loop1.561
	sti	%g9, %g30, 0
	sti	%g5, %g30, -20
	sti	%g4, %g30, -16
	sti	%g8, %g30, -12
	sti	%g7, %g30, -8
	sti	%g6, %g30, -4
	subi	%g3, %g3, 1
	ldi	%g27, %g30, 0
	b	%g27

!==============================
! args = [%g3]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0]
! ret type = Unit
!================================
init.549:
	ldi	%g4, %g30, -8
	ldi	%g5, %g30, -4
	jlt	%g3, %g0, jge_else.1121
	fmov	%f0, %f16
	sti	%g30, %g1, 0
	sti	%g5, %g1, 4
	sti	%g3, %g1, 8
	mov	%g3, %g4
	subi	%g1, %g1, 16
	call	min_caml_create_float_array
	addi	%g1, %g1, 16
	ldi	%g4, %g1, 8
	slli	%g5, %g4, 2
	ldi	%g6, %g1, 4
	st	%g3, %g6, %g5
	subi	%g3, %g4, 1
	ldi	%g30, %g1, 0
	ldi	%g27, %g30, 0
	b	%g27
jge_else.1121:
	return

!==============================
! args = [%g3, %g4]
! fargs = []
! use_regs = [%g9, %g8, %g7, %g6, %g5, %g4, %g30, %g3, %g27, %g26, %g25, %g24, %g23, %g22, %g21, %g20, %g19, %g18, %g17, %g16, %g15, %g14, %g13, %g12, %g11, %g10, %f9, %f8, %f7, %f6, %f5, %f4, %f3, %f2, %f15, %f14, %f13, %f12, %f11, %f10, %f1, %f0]
! ret type = Array(Array(Float))
!================================
make.441:
	subi	%g5, %g31, 28
	sti	%g3, %g1, 0
	sti	%g4, %g1, 4
	mov	%g4, %g5
	subi	%g1, %g1, 12
	call	min_caml_create_array
	addi	%g1, %g1, 12
	mov	%g30, %g2
	addi	%g2, %g2, 12
	setL %g4, init.549
	sti	%g4, %g30, 0
	ldi	%g4, %g1, 4
	sti	%g4, %g30, -8
	sti	%g3, %g30, -4
	ldi	%g4, %g1, 0
	subi	%g4, %g4, 1
	sti	%g3, %g1, 8
	mov	%g3, %g4
	ldi	%g27, %g30, 0
	subi	%g1, %g1, 16
	callR	%g27
	addi	%g1, %g1, 16
	ldi	%g3, %g1, 8
	return
