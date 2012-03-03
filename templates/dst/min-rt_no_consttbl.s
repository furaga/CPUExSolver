	jmp	min_caml_start

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


min_caml_start:
	addi	%g2, %g0, 1912
	addi	%g3, %g0, 1
	addi	%g4, %g0, -1
	fmvhi	%f16, 0
	fmvlo	%f16, 0
	fmvhi	%f17, 16256
	fmvlo	%f17, 0
	fmvhi	%f18, 17279
	fmvlo	%f18, 0
	fmvhi	%f19, 16128
	fmvlo	%f19, 0
	fmvhi	%f20, 16384
	fmvlo	%f20, 0
	fmvhi	%f21, 49024
	fmvlo	%f21, 0
	fmvhi	%f22, 20078
	fmvlo	%f22, 27432
	fmvhi	%f23, 15820
	fmvlo	%f23, 52420
	fmvhi	%f24, 16457
	fmvlo	%f24, 4058
	fmvhi	%f25, 48588
	fmvlo	%f25, 52420
	fmvhi	%f26, 15395
	fmvlo	%f26, 55050
	fmvhi	%f27, 16329
	fmvlo	%f27, 4058
	fmvhi	%f28, 16230
	fmvlo	%f28, 26206
	fmvhi	%f29, 15948
	fmvlo	%f29, 52420
	fmvhi	%f30, 16752
	fmvlo	%f30, 0
	fmvhi	%f31, 16880
	fmvlo	%f31, 0
	addi	%g5, %g0, 1
	addi	%g6, %g0, 0
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1908
	subi	%g1, %g1, 4
	call	min_caml_create_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 1
	addi	%g6, %g0, 0
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1904
	call	min_caml_create_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 1
	addi	%g6, %g0, 0
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1900
	call	min_caml_create_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 1
	addi	%g6, %g0, 0
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1896
	call	min_caml_create_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 1
	addi	%g6, %g0, 1
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1892
	call	min_caml_create_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 1
	addi	%g6, %g0, 0
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1888
	call	min_caml_create_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 1
	addi	%g6, %g0, 0
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1884
	call	min_caml_create_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 0
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1880
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g6, %g5
	ldi	%g2, %g0, -188
	addi	%g8, %g0, 60
	addi	%g12, %g0, 0
	addi	%g11, %g0, 0
	addi	%g10, %g0, 0
	addi	%g9, %g0, 0
	addi	%g7, %g0, 0
	mov	%g5, %g2
	addi	%g2, %g2, 44
	sti	%g6, %g5, -40
	sti	%g6, %g5, -36
	sti	%g6, %g5, -32
	sti	%g6, %g5, -28
	sti	%g7, %g5, -24
	sti	%g6, %g5, -20
	sti	%g6, %g5, -16
	sti	%g9, %g5, -12
	sti	%g10, %g5, -8
	sti	%g11, %g5, -4
	sti	%g12, %g5, 0
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1640
	mov	%g6, %g5
	mov	%g5, %g8
	call	min_caml_create_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 3
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1628
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 3
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1616
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 3
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1604
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 1
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1600
	fmov	%f0, %f18
	call	min_caml_create_float_array
	ldi	%g2, %g0, -188
	addi	%g8, %g0, 50
	addi	%g5, %g0, 1
	addi	%g6, %g0, -1
	call	min_caml_create_array
	mov	%g6, %g5
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1400
	mov	%g5, %g8
	call	min_caml_create_array
	ldi	%g2, %g0, -188
	addi	%g8, %g0, 1
	addi	%g5, %g0, 1
	ldi	%g6, %g0, -1400
	call	min_caml_create_array
	mov	%g6, %g5
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1396
	mov	%g5, %g8
	call	min_caml_create_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 1
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1392
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 1
	addi	%g6, %g0, 0
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1388
	call	min_caml_create_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 1
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1384
	fmov	%f0, %f22
	call	min_caml_create_float_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 3
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1372
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 1
	addi	%g6, %g0, 0
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1368
	call	min_caml_create_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 3
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1356
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 3
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1344
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 3
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1332
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 3
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1320
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 2
	addi	%g6, %g0, 0
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1312
	call	min_caml_create_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 2
	addi	%g6, %g0, 0
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1304
	call	min_caml_create_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 1
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1300
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 3
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1288
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 3
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1276
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 3
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1264
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 3
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1252
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 3
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1240
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 3
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1228
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 0
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1224
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g9, %g5
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 0
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1220
	subi	%g6, %g0, -1224
	call	min_caml_create_array
	mov	%g6, %g5
	ldi	%g2, %g0, -188
	addi	%g8, %g0, 0
	mov	%g5, %g2
	addi	%g2, %g2, 8
	sti	%g6, %g5, -4
	sti	%g9, %g5, 0
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1216
	mov	%g6, %g5
	mov	%g5, %g8
	call	min_caml_create_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 5
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1196
	subi	%g6, %g0, -1216
	call	min_caml_create_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 0
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1192
	fmov	%f0, %f16
	call	min_caml_create_float_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 3
	sti	%g2, %g0, -188
	subi	%g2, %g0, -1180
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g8, %g5
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 60
	sti	%g2, %g0, -188
	subi	%g2, %g0, -940
	subi	%g6, %g0, -1192
	call	min_caml_create_array
	mov	%g6, %g5
	ldi	%g2, %g0, -188
	sti	%g2, %g0, -188
	subi	%g2, %g0, -932
	mov	%g5, %g2
	addi	%g2, %g2, 8
	sti	%g6, %g5, -4
	sti	%g8, %g5, 0
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 0
	sti	%g2, %g0, -188
	subi	%g2, %g0, -928
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g8, %g5
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 0
	sti	%g2, %g0, -188
	subi	%g2, %g0, -924
	subi	%g6, %g0, -928
	call	min_caml_create_array
	ldi	%g2, %g0, -188
	sti	%g2, %g0, -188
	subi	%g2, %g0, -916
	mov	%g6, %g2
	addi	%g2, %g2, 8
	sti	%g5, %g6, -4
	sti	%g8, %g6, 0
	ldi	%g2, %g0, -188
	addi	%g8, %g0, 180
	addi	%g7, %g0, 0
	mov	%g5, %g2
	addi	%g2, %g2, 12
	fsti	%f16, %g5, -8
	sti	%g6, %g5, -4
	sti	%g7, %g5, 0
	sti	%g2, %g0, -188
	subi	%g2, %g0, -196
	mov	%g6, %g5
	mov	%g5, %g8
	call	min_caml_create_array
	ldi	%g2, %g0, -188
	addi	%g5, %g0, 1
	addi	%g6, %g0, 0
	sti	%g2, %g0, -188
	subi	%g2, %g0, -192
	call	min_caml_create_array
	ldi	%g2, %g0, -188
	addi	%g8, %g0, 128
	addi	%g5, %g0, 128
	call	rt.3098
	addi	%g1, %g1, 4
	addi	%g0, %g0, 0
	halt

!---------------------------------------------------------------------
! args = []
! fargs = [%f1, %f0]
! ret type = Bool
!---------------------------------------------------------------------
fless.2523:
	fjlt	%f1, %f0, fjge_else.7587
	addi	%g5, %g0, 0
	return
fjge_else.7587:
	addi	%g5, %g0, 1
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f0]
! ret type = Bool
!---------------------------------------------------------------------
fispos.2526:
	fjlt	%f16, %f0, fjge_else.7588
	addi	%g5, %g0, 0
	return
fjge_else.7588:
	addi	%g5, %g0, 1
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f0]
! ret type = Bool
!---------------------------------------------------------------------
fisneg.2528:
	fjlt	%f0, %f16, fjge_else.7589
	addi	%g5, %g0, 0
	return
fjge_else.7589:
	addi	%g5, %g0, 1
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f0]
! ret type = Bool
!---------------------------------------------------------------------
fiszero.2530:
	fjeq	%f0, %f16, fjne_else.7590
	addi	%g5, %g0, 0
	return
fjne_else.7590:
	addi	%g5, %g0, 1
	return

!---------------------------------------------------------------------
! args = [%g6, %g5]
! fargs = []
! ret type = Bool
!---------------------------------------------------------------------
xor.2532:
	jne	%g6, %g5, jeq_else.7591
	addi	%g5, %g0, 0
	return
jeq_else.7591:
	addi	%g5, %g0, 1
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f1]
! ret type = Float
!---------------------------------------------------------------------
fabs.2535:
	fjlt	%f1, %f16, fjge_else.7592
	fmov	%f0, %f1
	return
fjge_else.7592:
	fneg	%f0, %f1
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f0]
! ret type = Float
!---------------------------------------------------------------------
fneg.2539:
	fneg	%f0, %f0
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f0]
! ret type = Float
!---------------------------------------------------------------------
fhalf.2541:
	fmul	%f0, %f0, %f19
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f0]
! ret type = Float
!---------------------------------------------------------------------
fsqr.2543:
	fmul	%f0, %f0, %f0
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f2, %f3, %f1]
! ret type = Float
!---------------------------------------------------------------------
atan_sub.2548:
	fjlt	%f2, %f19, fjge_else.7593
	fsub	%f0, %f2, %f17
	fmul	%f4, %f2, %f2
	fmul	%f4, %f4, %f3
	fadd	%f2, %f2, %f2
	fadd	%f2, %f2, %f17
	fadd	%f1, %f2, %f1
	fdiv	%f1, %f4, %f1
	fmov	%f2, %f0
	jmp	atan_sub.2548
fjge_else.7593:
	fmov	%f0, %f1
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f0]
! ret type = Float
!---------------------------------------------------------------------
atan.2552:
	fjlt	%f17, %f0, fjge_else.7594
	fjlt	%f0, %f21, fjge_else.7596
	addi	%g5, %g0, 0
	jmp	fjge_cont.7597
fjge_else.7596:
	addi	%g5, %g0, -1
fjge_cont.7597:
	jmp	fjge_cont.7595
fjge_else.7594:
	addi	%g5, %g0, 1
fjge_cont.7595:
	jne	%g5, %g0, jeq_else.7598
	fmov	%f5, %f0
	jmp	jeq_cont.7599
jeq_else.7598:
	fdiv	%f5, %f17, %f0
jeq_cont.7599:
	fmvhi	%f2, 16688
	fmvlo	%f2, 0
	fmul	%f3, %f5, %f5
	fmov	%f1, %f16
	subi	%g1, %g1, 4
	call	atan_sub.2548
	addi	%g1, %g1, 4
	fadd	%f0, %f17, %f0
	fdiv	%f1, %f5, %f0
	jlt	%g0, %g5, jle_else.7600
	jlt	%g5, %g0, jge_else.7601
	fmov	%f0, %f1
	return
jge_else.7601:
	fmvhi	%f0, 49097
	fmvlo	%f0, 4058
	fsub	%f0, %f0, %f1
	return
jle_else.7600:
	fsub	%f0, %f27, %f1
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f2, %f3, %f1]
! ret type = Float
!---------------------------------------------------------------------
tan_sub.6247:
	fmvhi	%f0, 16416
	fmvlo	%f0, 0
	fjlt	%f2, %f0, fjge_else.7602
	fsub	%f0, %f2, %f20
	fsub	%f1, %f2, %f1
	fdiv	%f1, %f3, %f1
	fmov	%f2, %f0
	jmp	tan_sub.6247
fjge_else.7602:
	fmov	%f0, %f1
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f0]
! ret type = Float
!---------------------------------------------------------------------
tan.2554:
	fmvhi	%f2, 16656
	fmvlo	%f2, 0
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

!---------------------------------------------------------------------
! args = []
! fargs = [%f1]
! ret type = Float
!---------------------------------------------------------------------
sin_sub.2556:
	fmvhi	%f2, 16585
	fmvlo	%f2, 4058
	fjlt	%f2, %f1, fjge_else.7603
	fjlt	%f1, %f16, fjge_else.7604
	fmov	%f0, %f1
	return
fjge_else.7604:
	fadd	%f1, %f1, %f2
	jmp	sin_sub.2556
fjge_else.7603:
	fsub	%f1, %f1, %f2
	jmp	sin_sub.2556

!---------------------------------------------------------------------
! args = []
! fargs = [%f3]
! ret type = Float
!---------------------------------------------------------------------
sin.2558:
	fmvhi	%f5, 16457
	fmvlo	%f5, 4058
	fmvhi	%f4, 16585
	fmvlo	%f4, 4058
	fmov	%f1, %f3
	subi	%g1, %g1, 4
	call	fabs.2535
	fmov	%f1, %f0
	call	sin_sub.2556
	addi	%g1, %g1, 4
	fjlt	%f5, %f0, fjge_else.7605
	fjlt	%f16, %f3, fjge_else.7607
	addi	%g5, %g0, 0
	jmp	fjge_cont.7608
fjge_else.7607:
	addi	%g5, %g0, 1
fjge_cont.7608:
	jmp	fjge_cont.7606
fjge_else.7605:
	fjlt	%f16, %f3, fjge_else.7609
	addi	%g5, %g0, 1
	jmp	fjge_cont.7610
fjge_else.7609:
	addi	%g5, %g0, 0
fjge_cont.7610:
fjge_cont.7606:
	fjlt	%f5, %f0, fjge_else.7611
	fmov	%f1, %f0
	jmp	fjge_cont.7612
fjge_else.7611:
	fsub	%f1, %f4, %f0
fjge_cont.7612:
	fjlt	%f27, %f1, fjge_else.7613
	fmov	%f0, %f1
	jmp	fjge_cont.7614
fjge_else.7613:
	fsub	%f0, %f5, %f1
fjge_cont.7614:
	fmul	%f0, %f0, %f19
	subi	%g1, %g1, 4
	call	tan.2554
	addi	%g1, %g1, 4
	fmul	%f1, %f20, %f0
	fmul	%f0, %f0, %f0
	fadd	%f0, %f17, %f0
	fdiv	%f1, %f1, %f0
	jne	%g5, %g0, jeq_else.7615
	fmov	%f0, %f1
	jmp	fneg.2539
jeq_else.7615:
	fmov	%f0, %f1
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f0]
! ret type = Float
!---------------------------------------------------------------------
cos.2560:
	fsub	%f3, %f27, %f0
	jmp	sin.2558

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
mul10.2562:
	slli	%g6, %g5, 3
	slli	%g5, %g5, 1
	add	%g5, %g6, %g5
	return

!---------------------------------------------------------------------
! args = [%g7, %g6]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
read_int_token.2566:
	input	%g8
	addi	%g5, %g0, 48
	jlt	%g8, %g5, jle_else.7616
	addi	%g5, %g0, 57
	jlt	%g5, %g8, jle_else.7618
	addi	%g5, %g0, 0
	jmp	jle_cont.7619
jle_else.7618:
	addi	%g5, %g0, 1
jle_cont.7619:
	jmp	jle_cont.7617
jle_else.7616:
	addi	%g5, %g0, 1
jle_cont.7617:
	jne	%g5, %g0, jeq_else.7620
	ldi	%g5, %g0, -1904
	jne	%g5, %g0, jeq_else.7621
	addi	%g5, %g0, 45
	jne	%g6, %g5, jeq_else.7623
	addi	%g5, %g0, -1
	sti	%g5, %g0, -1904
	jmp	jeq_cont.7624
jeq_else.7623:
	addi	%g5, %g0, 1
	sti	%g5, %g0, -1904
jeq_cont.7624:
	jmp	jeq_cont.7622
jeq_else.7621:
jeq_cont.7622:
	ldi	%g5, %g0, -1908
	subi	%g1, %g1, 4
	call	mul10.2562
	addi	%g1, %g1, 4
	subi	%g6, %g8, 48
	add	%g5, %g5, %g6
	sti	%g5, %g0, -1908
	addi	%g7, %g0, 1
	mov	%g6, %g8
	jmp	read_int_token.2566
jeq_else.7620:
	jne	%g7, %g0, jeq_else.7625
	addi	%g7, %g0, 0
	mov	%g6, %g8
	jmp	read_int_token.2566
jeq_else.7625:
	ldi	%g5, %g0, -1904
	jne	%g5, %g3, jeq_else.7626
	ldi	%g5, %g0, -1908
	return
jeq_else.7626:
	ldi	%g5, %g0, -1908
	sub	%g5, %g0, %g5
	return

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
read_int.2569:
	addi	%g5, %g0, 0
	sti	%g5, %g0, -1908
	addi	%g5, %g0, 0
	sti	%g5, %g0, -1904
	addi	%g7, %g0, 0
	addi	%g6, %g0, 32
	jmp	read_int_token.2566

!---------------------------------------------------------------------
! args = [%g8, %g6]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
read_float_token1.2575:
	input	%g7
	addi	%g5, %g0, 48
	jlt	%g7, %g5, jle_else.7627
	addi	%g5, %g0, 57
	jlt	%g5, %g7, jle_else.7629
	addi	%g5, %g0, 0
	jmp	jle_cont.7630
jle_else.7629:
	addi	%g5, %g0, 1
jle_cont.7630:
	jmp	jle_cont.7628
jle_else.7627:
	addi	%g5, %g0, 1
jle_cont.7628:
	jne	%g5, %g0, jeq_else.7631
	ldi	%g5, %g0, -1888
	jne	%g5, %g0, jeq_else.7632
	addi	%g5, %g0, 45
	jne	%g6, %g5, jeq_else.7634
	addi	%g5, %g0, -1
	sti	%g5, %g0, -1888
	jmp	jeq_cont.7635
jeq_else.7634:
	addi	%g5, %g0, 1
	sti	%g5, %g0, -1888
jeq_cont.7635:
	jmp	jeq_cont.7633
jeq_else.7632:
jeq_cont.7633:
	ldi	%g5, %g0, -1900
	subi	%g1, %g1, 4
	call	mul10.2562
	addi	%g1, %g1, 4
	subi	%g6, %g7, 48
	add	%g5, %g5, %g6
	sti	%g5, %g0, -1900
	addi	%g8, %g0, 1
	mov	%g6, %g7
	jmp	read_float_token1.2575
jeq_else.7631:
	jne	%g8, %g0, jeq_else.7636
	addi	%g8, %g0, 0
	mov	%g6, %g7
	jmp	read_float_token1.2575
jeq_else.7636:
	mov	%g5, %g7
	return

!---------------------------------------------------------------------
! args = [%g6]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
read_float_token2.2578:
	input	%g7
	addi	%g5, %g0, 48
	jlt	%g7, %g5, jle_else.7637
	addi	%g5, %g0, 57
	jlt	%g5, %g7, jle_else.7639
	addi	%g5, %g0, 0
	jmp	jle_cont.7640
jle_else.7639:
	addi	%g5, %g0, 1
jle_cont.7640:
	jmp	jle_cont.7638
jle_else.7637:
	addi	%g5, %g0, 1
jle_cont.7638:
	jne	%g5, %g0, jeq_else.7641
	ldi	%g5, %g0, -1896
	subi	%g1, %g1, 4
	call	mul10.2562
	subi	%g6, %g7, 48
	add	%g5, %g5, %g6
	sti	%g5, %g0, -1896
	ldi	%g5, %g0, -1892
	call	mul10.2562
	addi	%g1, %g1, 4
	sti	%g5, %g0, -1892
	addi	%g6, %g0, 1
	jmp	read_float_token2.2578
jeq_else.7641:
	jne	%g6, %g0, jeq_else.7642
	addi	%g6, %g0, 0
	jmp	read_float_token2.2578
jeq_else.7642:
	return

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
read_float.2580:
	addi	%g5, %g0, 0
	sti	%g5, %g0, -1900
	addi	%g5, %g0, 0
	sti	%g5, %g0, -1896
	addi	%g5, %g0, 1
	sti	%g5, %g0, -1892
	addi	%g5, %g0, 0
	sti	%g5, %g0, -1888
	addi	%g8, %g0, 0
	addi	%g6, %g0, 32
	subi	%g1, %g1, 4
	call	read_float_token1.2575
	addi	%g1, %g1, 4
	addi	%g6, %g0, 46
	jne	%g5, %g6, jeq_else.7644
	addi	%g6, %g0, 0
	subi	%g1, %g1, 4
	call	read_float_token2.2578
	ldi	%g5, %g0, -1900
	call	min_caml_float_of_int
	fmov	%f4, %f0
	ldi	%g5, %g0, -1896
	call	min_caml_float_of_int
	fmov	%f3, %f0
	ldi	%g5, %g0, -1892
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fdiv	%f1, %f3, %f0
	fadd	%f1, %f4, %f1
	jmp	jeq_cont.7645
jeq_else.7644:
	ldi	%g5, %g0, -1900
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fmov	%f1, %f0
jeq_cont.7645:
	ldi	%g5, %g0, -1888
	jne	%g5, %g3, jeq_else.7646
	fmov	%f0, %f1
	return
jeq_else.7646:
	fneg	%f0, %f1
	return

!---------------------------------------------------------------------
! args = [%g10, %g9, %g7, %g8]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
div_binary_search.2582:
	add	%g5, %g7, %g8
	srli	%g6, %g5, 1
	mul	%g11, %g6, %g9
	sub	%g5, %g8, %g7
	jlt	%g3, %g5, jle_else.7647
	mov	%g5, %g7
	return
jle_else.7647:
	jlt	%g11, %g10, jle_else.7648
	jne	%g11, %g10, jeq_else.7649
	mov	%g5, %g6
	return
jeq_else.7649:
	mov	%g8, %g6
	jmp	div_binary_search.2582
jle_else.7648:
	mov	%g7, %g6
	jmp	div_binary_search.2582

!---------------------------------------------------------------------
! args = [%g10]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
print_int.2587:
	jlt	%g10, %g0, jge_else.7650
	mvhi	%g9, 1525
	mvlo	%g9, 57600
	addi	%g7, %g0, 0
	addi	%g8, %g0, 3
	sti	%g10, %g1, 0
	subi	%g1, %g1, 8
	call	div_binary_search.2582
	addi	%g1, %g1, 8
	mvhi	%g6, 1525
	mvlo	%g6, 57600
	mul	%g6, %g5, %g6
	ldi	%g10, %g1, 0
	sub	%g10, %g10, %g6
	jlt	%g0, %g5, jle_else.7651
	addi	%g12, %g0, 0
	jmp	jle_cont.7652
jle_else.7651:
	addi	%g6, %g0, 48
	add	%g5, %g6, %g5
	output	%g5
	addi	%g12, %g0, 1
jle_cont.7652:
	mvhi	%g9, 152
	mvlo	%g9, 38528
	addi	%g7, %g0, 0
	addi	%g8, %g0, 10
	sti	%g10, %g1, 4
	subi	%g1, %g1, 12
	call	div_binary_search.2582
	addi	%g1, %g1, 12
	mvhi	%g6, 152
	mvlo	%g6, 38528
	mul	%g6, %g5, %g6
	ldi	%g10, %g1, 4
	sub	%g10, %g10, %g6
	jlt	%g0, %g5, jle_else.7653
	jne	%g12, %g0, jeq_else.7655
	addi	%g13, %g0, 0
	jmp	jeq_cont.7656
jeq_else.7655:
	addi	%g6, %g0, 48
	add	%g5, %g6, %g5
	output	%g5
	addi	%g13, %g0, 1
jeq_cont.7656:
	jmp	jle_cont.7654
jle_else.7653:
	addi	%g6, %g0, 48
	add	%g5, %g6, %g5
	output	%g5
	addi	%g13, %g0, 1
jle_cont.7654:
	mvhi	%g9, 15
	mvlo	%g9, 16960
	addi	%g7, %g0, 0
	addi	%g8, %g0, 10
	sti	%g10, %g1, 8
	subi	%g1, %g1, 16
	call	div_binary_search.2582
	addi	%g1, %g1, 16
	mvhi	%g6, 15
	mvlo	%g6, 16960
	mul	%g6, %g5, %g6
	ldi	%g10, %g1, 8
	sub	%g10, %g10, %g6
	jlt	%g0, %g5, jle_else.7657
	jne	%g13, %g0, jeq_else.7659
	addi	%g12, %g0, 0
	jmp	jeq_cont.7660
jeq_else.7659:
	addi	%g6, %g0, 48
	add	%g5, %g6, %g5
	output	%g5
	addi	%g12, %g0, 1
jeq_cont.7660:
	jmp	jle_cont.7658
jle_else.7657:
	addi	%g6, %g0, 48
	add	%g5, %g6, %g5
	output	%g5
	addi	%g12, %g0, 1
jle_cont.7658:
	mvhi	%g9, 1
	mvlo	%g9, 34464
	addi	%g7, %g0, 0
	addi	%g8, %g0, 10
	sti	%g10, %g1, 12
	subi	%g1, %g1, 20
	call	div_binary_search.2582
	addi	%g1, %g1, 20
	mvhi	%g6, 1
	mvlo	%g6, 34464
	mul	%g6, %g5, %g6
	ldi	%g10, %g1, 12
	sub	%g10, %g10, %g6
	jlt	%g0, %g5, jle_else.7661
	jne	%g12, %g0, jeq_else.7663
	addi	%g13, %g0, 0
	jmp	jeq_cont.7664
jeq_else.7663:
	addi	%g6, %g0, 48
	add	%g5, %g6, %g5
	output	%g5
	addi	%g13, %g0, 1
jeq_cont.7664:
	jmp	jle_cont.7662
jle_else.7661:
	addi	%g6, %g0, 48
	add	%g5, %g6, %g5
	output	%g5
	addi	%g13, %g0, 1
jle_cont.7662:
	addi	%g9, %g0, 10000
	addi	%g7, %g0, 0
	addi	%g8, %g0, 10
	sti	%g10, %g1, 16
	subi	%g1, %g1, 24
	call	div_binary_search.2582
	addi	%g1, %g1, 24
	addi	%g6, %g0, 10000
	mul	%g6, %g5, %g6
	ldi	%g10, %g1, 16
	sub	%g10, %g10, %g6
	jlt	%g0, %g5, jle_else.7665
	jne	%g13, %g0, jeq_else.7667
	addi	%g12, %g0, 0
	jmp	jeq_cont.7668
jeq_else.7667:
	addi	%g6, %g0, 48
	add	%g5, %g6, %g5
	output	%g5
	addi	%g12, %g0, 1
jeq_cont.7668:
	jmp	jle_cont.7666
jle_else.7665:
	addi	%g6, %g0, 48
	add	%g5, %g6, %g5
	output	%g5
	addi	%g12, %g0, 1
jle_cont.7666:
	addi	%g9, %g0, 1000
	addi	%g7, %g0, 0
	addi	%g8, %g0, 10
	sti	%g10, %g1, 20
	subi	%g1, %g1, 28
	call	div_binary_search.2582
	addi	%g1, %g1, 28
	muli	%g6, %g5, 1000
	ldi	%g10, %g1, 20
	sub	%g10, %g10, %g6
	jlt	%g0, %g5, jle_else.7669
	jne	%g12, %g0, jeq_else.7671
	addi	%g13, %g0, 0
	jmp	jeq_cont.7672
jeq_else.7671:
	addi	%g6, %g0, 48
	add	%g5, %g6, %g5
	output	%g5
	addi	%g13, %g0, 1
jeq_cont.7672:
	jmp	jle_cont.7670
jle_else.7669:
	addi	%g6, %g0, 48
	add	%g5, %g6, %g5
	output	%g5
	addi	%g13, %g0, 1
jle_cont.7670:
	addi	%g9, %g0, 100
	addi	%g7, %g0, 0
	addi	%g8, %g0, 10
	sti	%g10, %g1, 24
	subi	%g1, %g1, 32
	call	div_binary_search.2582
	addi	%g1, %g1, 32
	muli	%g6, %g5, 100
	ldi	%g10, %g1, 24
	sub	%g10, %g10, %g6
	jlt	%g0, %g5, jle_else.7673
	jne	%g13, %g0, jeq_else.7675
	addi	%g12, %g0, 0
	jmp	jeq_cont.7676
jeq_else.7675:
	addi	%g6, %g0, 48
	add	%g5, %g6, %g5
	output	%g5
	addi	%g12, %g0, 1
jeq_cont.7676:
	jmp	jle_cont.7674
jle_else.7673:
	addi	%g6, %g0, 48
	add	%g5, %g6, %g5
	output	%g5
	addi	%g12, %g0, 1
jle_cont.7674:
	addi	%g9, %g0, 10
	addi	%g7, %g0, 0
	addi	%g8, %g0, 10
	sti	%g10, %g1, 28
	subi	%g1, %g1, 36
	call	div_binary_search.2582
	addi	%g1, %g1, 36
	muli	%g6, %g5, 10
	ldi	%g10, %g1, 28
	sub	%g6, %g10, %g6
	jlt	%g0, %g5, jle_else.7677
	jne	%g12, %g0, jeq_else.7679
	addi	%g7, %g0, 0
	jmp	jeq_cont.7680
jeq_else.7679:
	addi	%g7, %g0, 48
	add	%g5, %g7, %g5
	output	%g5
	addi	%g7, %g0, 1
jeq_cont.7680:
	jmp	jle_cont.7678
jle_else.7677:
	addi	%g7, %g0, 48
	add	%g5, %g7, %g5
	output	%g5
	addi	%g7, %g0, 1
jle_cont.7678:
	addi	%g5, %g0, 48
	add	%g5, %g5, %g6
	output	%g5
	return
jge_else.7650:
	addi	%g5, %g0, 45
	output	%g5
	sub	%g10, %g0, %g10
	jmp	print_int.2587

!---------------------------------------------------------------------
! args = []
! fargs = [%f1]
! ret type = Float
!---------------------------------------------------------------------
sgn.2619:
	fmov	%f0, %f1
	subi	%g1, %g1, 4
	call	fiszero.2530
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7681
	fmov	%f0, %f1
	subi	%g1, %g1, 4
	call	fispos.2526
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7682
	fmov	%f0, %f21
	return
jeq_else.7682:
	fmov	%f0, %f17
	return
jeq_else.7681:
	fmov	%f0, %f16
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = [%f1]
! ret type = Float
!---------------------------------------------------------------------
fneg_cond.2621:
	jne	%g5, %g0, jeq_else.7683
	fmov	%f0, %f1
	jmp	fneg.2539
jeq_else.7683:
	fmov	%f0, %f1
	return

!---------------------------------------------------------------------
! args = [%g6, %g5]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
add_mod5.2624:
	add	%g6, %g6, %g5
	addi	%g5, %g0, 5
	jlt	%g6, %g5, jle_else.7684
	subi	%g5, %g6, 5
	return
jle_else.7684:
	mov	%g5, %g6
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = [%f2, %f1, %f0]
! ret type = Unit
!---------------------------------------------------------------------
vecset.2627:
	fsti	%f2, %g5, 0
	fsti	%f1, %g5, -4
	fsti	%f0, %g5, -8
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = [%f0]
! ret type = Unit
!---------------------------------------------------------------------
vecfill.2632:
	fsti	%f0, %g5, 0
	fsti	%f0, %g5, -4
	fsti	%f0, %g5, -8
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
vecbzero.2635:
	fmov	%f0, %f16
	jmp	vecfill.2632

!---------------------------------------------------------------------
! args = [%g6, %g5]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
veccpy.2637:
	fldi	%f0, %g5, 0
	fsti	%f0, %g6, 0
	fldi	%f0, %g5, -4
	fsti	%f0, %g6, -4
	fldi	%f0, %g5, -8
	fsti	%f0, %g6, -8
	return

!---------------------------------------------------------------------
! args = [%g6, %g7]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
vecunit_sgn.2645:
	fldi	%f1, %g6, 0
	fmov	%f0, %f1
	subi	%g1, %g1, 4
	call	fsqr.2543
	fmov	%f2, %f0
	fldi	%f0, %g6, -4
	call	fsqr.2543
	fadd	%f2, %f2, %f0
	fldi	%f0, %g6, -8
	call	fsqr.2543
	fadd	%f0, %f2, %f0
	fsqrt	%f2, %f0
	fmov	%f0, %f2
	call	fiszero.2530
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7688
	jne	%g7, %g0, jeq_else.7690
	fdiv	%f0, %f17, %f2
	jmp	jeq_cont.7691
jeq_else.7690:
	fdiv	%f0, %f21, %f2
jeq_cont.7691:
	jmp	jeq_cont.7689
jeq_else.7688:
	fmov	%f0, %f17
jeq_cont.7689:
	fmul	%f1, %f1, %f0
	fsti	%f1, %g6, 0
	fldi	%f1, %g6, -4
	fmul	%f1, %f1, %f0
	fsti	%f1, %g6, -4
	fldi	%f1, %g6, -8
	fmul	%f0, %f1, %f0
	fsti	%f0, %g6, -8
	return

!---------------------------------------------------------------------
! args = [%g6, %g5]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
veciprod.2648:
	fldi	%f1, %g6, 0
	fldi	%f0, %g5, 0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g6, -4
	fldi	%f0, %g5, -4
	fmul	%f0, %f1, %f0
	fadd	%f2, %f2, %f0
	fldi	%f1, %g6, -8
	fldi	%f0, %g5, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = [%f2, %f1, %f0]
! ret type = Float
!---------------------------------------------------------------------
veciprod2.2651:
	fldi	%f3, %g5, 0
	fmul	%f3, %f3, %f2
	fldi	%f2, %g5, -4
	fmul	%f1, %f2, %f1
	fadd	%f2, %f3, %f1
	fldi	%f1, %g5, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	return

!---------------------------------------------------------------------
! args = [%g6, %g5]
! fargs = [%f0]
! ret type = Unit
!---------------------------------------------------------------------
vecaccum.2656:
	fldi	%f2, %g6, 0
	fldi	%f1, %g5, 0
	fmul	%f1, %f0, %f1
	fadd	%f1, %f2, %f1
	fsti	%f1, %g6, 0
	fldi	%f2, %g6, -4
	fldi	%f1, %g5, -4
	fmul	%f1, %f0, %f1
	fadd	%f1, %f2, %f1
	fsti	%f1, %g6, -4
	fldi	%f2, %g6, -8
	fldi	%f1, %g5, -8
	fmul	%f0, %f0, %f1
	fadd	%f0, %f2, %f0
	fsti	%f0, %g6, -8
	return

!---------------------------------------------------------------------
! args = [%g6, %g5]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
vecadd.2660:
	fldi	%f1, %g6, 0
	fldi	%f0, %g5, 0
	fadd	%f0, %f1, %f0
	fsti	%f0, %g6, 0
	fldi	%f1, %g6, -4
	fldi	%f0, %g5, -4
	fadd	%f0, %f1, %f0
	fsti	%f0, %g6, -4
	fldi	%f1, %g6, -8
	fldi	%f0, %g5, -8
	fadd	%f0, %f1, %f0
	fsti	%f0, %g6, -8
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = [%f0]
! ret type = Unit
!---------------------------------------------------------------------
vecscale.2666:
	fldi	%f1, %g5, 0
	fmul	%f1, %f1, %f0
	fsti	%f1, %g5, 0
	fldi	%f1, %g5, -4
	fmul	%f1, %f1, %f0
	fsti	%f1, %g5, -4
	fldi	%f1, %g5, -8
	fmul	%f0, %f1, %f0
	fsti	%f0, %g5, -8
	return

!---------------------------------------------------------------------
! args = [%g7, %g6, %g5]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
vecaccumv.2669:
	fldi	%f2, %g7, 0
	fldi	%f1, %g6, 0
	fldi	%f0, %g5, 0
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fsti	%f0, %g7, 0
	fldi	%f2, %g7, -4
	fldi	%f1, %g6, -4
	fldi	%f0, %g5, -4
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fsti	%f0, %g7, -4
	fldi	%f2, %g7, -8
	fldi	%f1, %g6, -8
	fldi	%f0, %g5, -8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	fsti	%f0, %g7, -8
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
o_texturetype.2673:
	ldi	%g5, %g5, 0
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
o_form.2675:
	ldi	%g5, %g5, -4
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
o_reflectiontype.2677:
	ldi	%g5, %g5, -8
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Bool
!---------------------------------------------------------------------
o_isinvert.2679:
	ldi	%g5, %g5, -24
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
o_isrot.2681:
	ldi	%g5, %g5, -12
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_param_a.2683:
	ldi	%g5, %g5, -16
	fldi	%f0, %g5, 0
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_param_b.2685:
	ldi	%g5, %g5, -16
	fldi	%f0, %g5, -4
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_param_c.2687:
	ldi	%g5, %g5, -16
	fldi	%f0, %g5, -8
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Array(Float)
!---------------------------------------------------------------------
o_param_abc.2689:
	ldi	%g5, %g5, -16
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_param_x.2691:
	ldi	%g5, %g5, -20
	fldi	%f0, %g5, 0
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_param_y.2693:
	ldi	%g5, %g5, -20
	fldi	%f0, %g5, -4
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_param_z.2695:
	ldi	%g5, %g5, -20
	fldi	%f0, %g5, -8
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_diffuse.2697:
	ldi	%g5, %g5, -28
	fldi	%f0, %g5, 0
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_hilight.2699:
	ldi	%g5, %g5, -28
	fldi	%f0, %g5, -4
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_color_red.2701:
	ldi	%g5, %g5, -32
	fldi	%f0, %g5, 0
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_color_green.2703:
	ldi	%g5, %g5, -32
	fldi	%f0, %g5, -4
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_color_blue.2705:
	ldi	%g5, %g5, -32
	fldi	%f0, %g5, -8
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_param_r1.2707:
	ldi	%g5, %g5, -36
	fldi	%f0, %g5, 0
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_param_r2.2709:
	ldi	%g5, %g5, -36
	fldi	%f0, %g5, -4
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
o_param_r3.2711:
	ldi	%g5, %g5, -36
	fldi	%f0, %g5, -8
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Array(Float)
!---------------------------------------------------------------------
o_param_ctbl.2713:
	ldi	%g5, %g5, -40
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Array(Float)
!---------------------------------------------------------------------
p_rgb.2715:
	ldi	%g5, %g5, 0
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Array(Array(Float))
!---------------------------------------------------------------------
p_intersection_points.2717:
	ldi	%g5, %g5, -4
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Array(Int)
!---------------------------------------------------------------------
p_surface_ids.2719:
	ldi	%g5, %g5, -8
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Array(Bool)
!---------------------------------------------------------------------
p_calc_diffuse.2721:
	ldi	%g5, %g5, -12
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Array(Array(Float))
!---------------------------------------------------------------------
p_energy.2723:
	ldi	%g5, %g5, -16
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Array(Array(Float))
!---------------------------------------------------------------------
p_received_ray_20percent.2725:
	ldi	%g5, %g5, -20
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
p_group_id.2727:
	ldi	%g5, %g5, -24
	ldi	%g5, %g5, 0
	return

!---------------------------------------------------------------------
! args = [%g5, %g6]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
p_set_group_id.2729:
	ldi	%g5, %g5, -24
	sti	%g6, %g5, 0
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Array(Array(Float))
!---------------------------------------------------------------------
p_nvectors.2732:
	ldi	%g5, %g5, -28
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Array(Float)
!---------------------------------------------------------------------
d_vec.2734:
	ldi	%g5, %g5, 0
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Array(Array(Float))
!---------------------------------------------------------------------
d_const.2736:
	ldi	%g5, %g5, -4
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
r_surface_id.2738:
	ldi	%g5, %g5, 0
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = (Array(Float) * Array(Array(Float)))
!---------------------------------------------------------------------
r_dvec.2740:
	ldi	%g5, %g5, -4
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Float
!---------------------------------------------------------------------
r_bright.2742:
	fldi	%f0, %g5, -8
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f0]
! ret type = Float
!---------------------------------------------------------------------
rad.2744:
	fmvhi	%f1, 15502
	fmvlo	%f1, 64045
	fmul	%f0, %f0, %f1
	return

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
read_screen_settings.2746:
	subi	%g1, %g1, 4
	call	read_float.2580
	fsti	%f0, %g0, -1628
	call	read_float.2580
	fsti	%f0, %g0, -1632
	call	read_float.2580
	fsti	%f0, %g0, -1636
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
	fmvhi	%f2, 17224
	fmvlo	%f2, 0
	fmul	%f1, %f1, %f2
	fsti	%f1, %g0, -1240
	fmvhi	%f1, 49992
	fmvlo	%f1, 0
	fmul	%f1, %f8, %f1
	fsti	%f1, %g0, -1244
	fmul	%f1, %f7, %f6
	fmul	%f1, %f1, %f2
	fsti	%f1, %g0, -1248
	fsti	%f6, %g0, -1264
	fsti	%f16, %g0, -1268
	fsti	%f0, %g1, 8
	subi	%g1, %g1, 16
	call	fneg.2539
	fmov	%f1, %f0
	fsti	%f1, %g0, -1272
	fmov	%f0, %f8
	call	fneg.2539
	addi	%g1, %g1, 16
	fmov	%f1, %f0
	fldi	%f0, %g1, 8
	fmul	%f0, %f1, %f0
	fsti	%f0, %g0, -1252
	fmov	%f0, %f7
	subi	%g1, %g1, 16
	call	fneg.2539
	addi	%g1, %g1, 16
	fsti	%f0, %g0, -1256
	fmul	%f0, %f1, %f6
	fsti	%f0, %g0, -1260
	fldi	%f1, %g0, -1628
	fldi	%f0, %g0, -1240
	fsub	%f0, %f1, %f0
	fsti	%f0, %g0, -1616
	fldi	%f1, %g0, -1632
	fldi	%f0, %g0, -1244
	fsub	%f0, %f1, %f0
	fsti	%f0, %g0, -1620
	fldi	%f1, %g0, -1636
	fldi	%f0, %g0, -1248
	fsub	%f0, %f1, %f0
	fsti	%f0, %g0, -1624
	return

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
read_light.2748:
	subi	%g1, %g1, 4
	call	read_int.2569
	call	read_float.2580
	call	rad.2744
	fmov	%f7, %f0
	fmov	%f3, %f7
	call	sin.2558
	call	fneg.2539
	fsti	%f0, %g0, -1608
	call	read_float.2580
	call	rad.2744
	fmov	%f6, %f0
	fmov	%f0, %f7
	call	cos.2560
	fmov	%f7, %f0
	fmov	%f3, %f6
	call	sin.2558
	fmul	%f0, %f7, %f0
	fsti	%f0, %g0, -1604
	fmov	%f0, %f6
	call	cos.2560
	fmul	%f0, %f7, %f0
	fsti	%f0, %g0, -1612
	call	read_float.2580
	addi	%g1, %g1, 4
	fsti	%f0, %g0, -1600
	return

!---------------------------------------------------------------------
! args = [%g7, %g6]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
rotate_quadratic_matrix.2750:
	fldi	%f6, %g6, 0
	fmov	%f0, %f6
	subi	%g1, %g1, 4
	call	cos.2560
	fmov	%f9, %f0
	fmov	%f3, %f6
	call	sin.2558
	fmov	%f7, %f0
	fldi	%f6, %g6, -4
	fmov	%f0, %f6
	call	cos.2560
	fmov	%f8, %f0
	fmov	%f3, %f6
	call	sin.2558
	fmov	%f10, %f0
	fldi	%f11, %g6, -8
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
	fldi	%f1, %g7, 0
	fldi	%f2, %g7, -4
	fldi	%f3, %g7, -8
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
	fsti	%f0, %g7, 0
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
	fsti	%f0, %g7, -4
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
	fsti	%f0, %g7, -8
	fmul	%f0, %f1, %f13
	fmul	%f7, %f0, %f11
	fmul	%f0, %f2, %f12
	fmul	%f0, %f0, %f5
	fadd	%f7, %f7, %f0
	fmul	%f0, %f3, %f6
	fmul	%f0, %f0, %f4
	fadd	%f0, %f7, %f0
	fmul	%f0, %f20, %f0
	fsti	%f0, %g6, 0
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
	fsti	%f2, %g6, -4
	fmul	%f1, %f1, %f13
	fmul	%f0, %f0, %f12
	fadd	%f1, %f1, %f0
	fmul	%f0, %f3, %f6
	fadd	%f0, %f1, %f0
	fmul	%f0, %f20, %f0
	fsti	%f0, %g6, -8
	return

!---------------------------------------------------------------------
! args = [%g12]
! fargs = []
! ret type = Bool
!---------------------------------------------------------------------
read_nth_object.2753:
	subi	%g1, %g1, 4
	call	read_int.2569
	addi	%g1, %g1, 4
	mov	%g14, %g5
	jne	%g14, %g4, jeq_else.7701
	addi	%g5, %g0, 0
	return
jeq_else.7701:
	subi	%g1, %g1, 4
	call	read_int.2569
	mov	%g18, %g5
	call	read_int.2569
	mov	%g16, %g5
	call	read_int.2569
	mov	%g10, %g5
	addi	%g5, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g9, %g5
	call	read_float.2580
	fsti	%f0, %g9, 0
	call	read_float.2580
	fsti	%f0, %g9, -4
	call	read_float.2580
	fsti	%f0, %g9, -8
	addi	%g5, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g13, %g5
	call	read_float.2580
	fsti	%f0, %g13, 0
	call	read_float.2580
	fsti	%f0, %g13, -4
	call	read_float.2580
	fsti	%f0, %g13, -8
	call	read_float.2580
	call	fisneg.2528
	mov	%g11, %g5
	addi	%g5, %g0, 2
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g17, %g5
	call	read_float.2580
	fsti	%f0, %g17, 0
	call	read_float.2580
	fsti	%f0, %g17, -4
	addi	%g5, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	mov	%g19, %g5
	call	read_float.2580
	fsti	%f0, %g19, 0
	call	read_float.2580
	fsti	%f0, %g19, -4
	call	read_float.2580
	fsti	%f0, %g19, -8
	addi	%g5, %g0, 3
	fmov	%f0, %f16
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	mov	%g15, %g5
	jne	%g10, %g0, jeq_else.7702
	jmp	jeq_cont.7703
jeq_else.7702:
	subi	%g1, %g1, 4
	call	read_float.2580
	call	rad.2744
	fsti	%f0, %g15, 0
	call	read_float.2580
	call	rad.2744
	fsti	%f0, %g15, -4
	call	read_float.2580
	call	rad.2744
	addi	%g1, %g1, 4
	fsti	%f0, %g15, -8
jeq_cont.7703:
	addi	%g7, %g0, 2
	jne	%g18, %g7, jeq_else.7704
	addi	%g7, %g0, 1
	jmp	jeq_cont.7705
jeq_else.7704:
	mov	%g7, %g11
jeq_cont.7705:
	addi	%g5, %g0, 4
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	mov	%g6, %g5
	mov	%g5, %g2
	addi	%g2, %g2, 44
	sti	%g6, %g5, -40
	sti	%g15, %g5, -36
	sti	%g19, %g5, -32
	sti	%g17, %g5, -28
	sti	%g7, %g5, -24
	sti	%g13, %g5, -20
	sti	%g9, %g5, -16
	sti	%g10, %g5, -12
	sti	%g16, %g5, -8
	sti	%g18, %g5, -4
	sti	%g14, %g5, 0
	slli	%g6, %g12, 2
	sti	%g5, %g6, -1640
	addi	%g5, %g0, 3
	jne	%g18, %g5, jeq_else.7706
	fldi	%f1, %g9, 0
	fmov	%f0, %f1
	subi	%g1, %g1, 4
	call	fiszero.2530
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7708
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
	jmp	jeq_cont.7709
jeq_else.7708:
	fmov	%f0, %f16
jeq_cont.7709:
	fsti	%f0, %g9, 0
	fldi	%f1, %g9, -4
	fmov	%f0, %f1
	subi	%g1, %g1, 8
	call	fiszero.2530
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7710
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
	jmp	jeq_cont.7711
jeq_else.7710:
	fmov	%f0, %f16
jeq_cont.7711:
	fsti	%f0, %g9, -4
	fldi	%f1, %g9, -8
	fmov	%f0, %f1
	subi	%g1, %g1, 12
	call	fiszero.2530
	addi	%g1, %g1, 12
	jne	%g5, %g0, jeq_else.7712
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
	jmp	jeq_cont.7713
jeq_else.7712:
	fmov	%f0, %f16
jeq_cont.7713:
	fsti	%f0, %g9, -8
	jmp	jeq_cont.7707
jeq_else.7706:
	addi	%g5, %g0, 2
	jne	%g18, %g5, jeq_else.7714
	jne	%g11, %g0, jeq_else.7716
	addi	%g7, %g0, 1
	jmp	jeq_cont.7717
jeq_else.7716:
	addi	%g7, %g0, 0
jeq_cont.7717:
	mov	%g6, %g9
	subi	%g1, %g1, 16
	call	vecunit_sgn.2645
	addi	%g1, %g1, 16
	jmp	jeq_cont.7715
jeq_else.7714:
jeq_cont.7715:
jeq_cont.7707:
	jne	%g10, %g0, jeq_else.7718
	jmp	jeq_cont.7719
jeq_else.7718:
	mov	%g6, %g15
	mov	%g7, %g9
	subi	%g1, %g1, 16
	call	rotate_quadratic_matrix.2750
	addi	%g1, %g1, 16
jeq_cont.7719:
	addi	%g5, %g0, 1
	return

!---------------------------------------------------------------------
! args = [%g12]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
read_object.2755:
	addi	%g5, %g0, 60
	jlt	%g12, %g5, jle_else.7720
	return
jle_else.7720:
	sti	%g12, %g1, 0
	subi	%g1, %g1, 8
	call	read_nth_object.2753
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7722
	ldi	%g12, %g1, 0
	sti	%g12, %g0, -1884
	return
jeq_else.7722:
	ldi	%g12, %g1, 0
	addi	%g12, %g12, 1
	jmp	read_object.2755

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
read_all_object.2757:
	addi	%g12, %g0, 0
	jmp	read_object.2755

!---------------------------------------------------------------------
! args = [%g9]
! fargs = []
! ret type = Array(Int)
!---------------------------------------------------------------------
read_net_item.2759:
	subi	%g1, %g1, 4
	call	read_int.2569
	addi	%g1, %g1, 4
	mov	%g6, %g5
	jne	%g6, %g4, jeq_else.7724
	addi	%g5, %g9, 1
	addi	%g6, %g0, -1
	jmp	min_caml_create_array
jeq_else.7724:
	addi	%g5, %g9, 1
	sti	%g6, %g1, 0
	sti	%g9, %g1, 4
	mov	%g9, %g5
	subi	%g1, %g1, 12
	call	read_net_item.2759
	addi	%g1, %g1, 12
	ldi	%g9, %g1, 4
	slli	%g7, %g9, 2
	ldi	%g6, %g1, 0
	st	%g6, %g5, %g7
	return

!---------------------------------------------------------------------
! args = [%g10]
! fargs = []
! ret type = Array(Array(Int))
!---------------------------------------------------------------------
read_or_network.2761:
	addi	%g9, %g0, 0
	subi	%g1, %g1, 4
	call	read_net_item.2759
	addi	%g1, %g1, 4
	mov	%g6, %g5
	ldi	%g5, %g6, 0
	jne	%g5, %g4, jeq_else.7725
	addi	%g5, %g10, 1
	jmp	min_caml_create_array
jeq_else.7725:
	addi	%g5, %g10, 1
	sti	%g6, %g1, 0
	sti	%g10, %g1, 4
	mov	%g10, %g5
	subi	%g1, %g1, 12
	call	read_or_network.2761
	addi	%g1, %g1, 12
	ldi	%g10, %g1, 4
	slli	%g7, %g10, 2
	ldi	%g6, %g1, 0
	st	%g6, %g5, %g7
	return

!---------------------------------------------------------------------
! args = [%g10]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
read_and_network.2763:
	addi	%g9, %g0, 0
	subi	%g1, %g1, 4
	call	read_net_item.2759
	addi	%g1, %g1, 4
	ldi	%g6, %g5, 0
	jne	%g6, %g4, jeq_else.7726
	return
jeq_else.7726:
	slli	%g6, %g10, 2
	sti	%g5, %g6, -1400
	addi	%g10, %g10, 1
	jmp	read_and_network.2763

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
read_parameter.2765:
	subi	%g1, %g1, 4
	call	read_screen_settings.2746
	call	read_light.2748
	call	read_all_object.2757
	addi	%g10, %g0, 0
	call	read_and_network.2763
	addi	%g10, %g0, 0
	call	read_or_network.2761
	addi	%g1, %g1, 4
	sti	%g5, %g0, -1396
	return

!---------------------------------------------------------------------
! args = [%g6, %g10, %g9, %g8, %g7]
! fargs = [%f4, %f3, %f2]
! ret type = Bool
!---------------------------------------------------------------------
solver_rect_surface.2767:
	slli	%g5, %g9, 2
	fld	%f5, %g10, %g5
	fmov	%f0, %f5
	subi	%g1, %g1, 4
	call	fiszero.2530
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7729
	mov	%g5, %g6
	subi	%g1, %g1, 4
	call	o_param_abc.2689
	mov	%g11, %g5
	mov	%g5, %g6
	call	o_isinvert.2679
	mov	%g6, %g5
	fmov	%f0, %f5
	call	fisneg.2528
	call	xor.2532
	slli	%g6, %g9, 2
	fld	%f1, %g11, %g6
	call	fneg_cond.2621
	fsub	%f0, %f0, %f4
	fdiv	%f4, %f0, %f5
	slli	%g5, %g8, 2
	fld	%f0, %g10, %g5
	fmul	%f0, %f4, %f0
	fadd	%f1, %f0, %f3
	call	fabs.2535
	fmov	%f1, %f0
	slli	%g5, %g8, 2
	fld	%f0, %g11, %g5
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7730
	addi	%g5, %g0, 0
	return
jeq_else.7730:
	slli	%g5, %g7, 2
	fld	%f0, %g10, %g5
	fmul	%f0, %f4, %f0
	fadd	%f1, %f0, %f2
	subi	%g1, %g1, 4
	call	fabs.2535
	fmov	%f1, %f0
	slli	%g5, %g7, 2
	fld	%f0, %g11, %g5
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7731
	addi	%g5, %g0, 0
	return
jeq_else.7731:
	fsti	%f4, %g0, -1392
	addi	%g5, %g0, 1
	return
jeq_else.7729:
	addi	%g5, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g6, %g10]
! fargs = [%f8, %f7, %f6]
! ret type = Int
!---------------------------------------------------------------------
solver_rect.2776:
	addi	%g9, %g0, 0
	addi	%g8, %g0, 1
	addi	%g7, %g0, 2
	sti	%g10, %g1, 0
	sti	%g6, %g1, 4
	fmov	%f2, %f6
	fmov	%f3, %f7
	fmov	%f4, %f8
	subi	%g1, %g1, 12
	call	solver_rect_surface.2767
	addi	%g1, %g1, 12
	jne	%g5, %g0, jeq_else.7732
	addi	%g9, %g0, 1
	addi	%g8, %g0, 2
	addi	%g7, %g0, 0
	ldi	%g6, %g1, 4
	ldi	%g10, %g1, 0
	fmov	%f2, %f8
	fmov	%f3, %f6
	fmov	%f4, %f7
	subi	%g1, %g1, 12
	call	solver_rect_surface.2767
	addi	%g1, %g1, 12
	jne	%g5, %g0, jeq_else.7733
	addi	%g9, %g0, 2
	addi	%g8, %g0, 0
	addi	%g7, %g0, 1
	ldi	%g6, %g1, 4
	ldi	%g10, %g1, 0
	fmov	%f2, %f7
	fmov	%f3, %f8
	fmov	%f4, %f6
	subi	%g1, %g1, 12
	call	solver_rect_surface.2767
	addi	%g1, %g1, 12
	jne	%g5, %g0, jeq_else.7734
	addi	%g5, %g0, 0
	return
jeq_else.7734:
	addi	%g5, %g0, 3
	return
jeq_else.7733:
	addi	%g5, %g0, 2
	return
jeq_else.7732:
	addi	%g5, %g0, 1
	return

!---------------------------------------------------------------------
! args = [%g5, %g6]
! fargs = [%f2, %f1, %f4]
! ret type = Int
!---------------------------------------------------------------------
solver_surface.2782:
	subi	%g1, %g1, 4
	call	o_param_abc.2689
	addi	%g1, %g1, 4
	mov	%g7, %g5
	fsti	%f1, %g1, 0
	fsti	%f2, %g1, 4
	mov	%g5, %g7
	subi	%g1, %g1, 12
	call	veciprod.2648
	fmov	%f5, %f0
	fmov	%f0, %f5
	call	fispos.2526
	addi	%g1, %g1, 12
	jne	%g5, %g0, jeq_else.7735
	addi	%g5, %g0, 0
	return
jeq_else.7735:
	fldi	%f2, %g1, 4
	fldi	%f1, %g1, 0
	mov	%g5, %g7
	fmov	%f0, %f4
	subi	%g1, %g1, 12
	call	veciprod2.2651
	call	fneg.2539
	addi	%g1, %g1, 12
	fdiv	%f0, %f0, %f5
	fsti	%f0, %g0, -1392
	addi	%g5, %g0, 1
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = [%f3, %f2, %f1]
! ret type = Float
!---------------------------------------------------------------------
quadratic.2788:
	fmov	%f0, %f3
	subi	%g1, %g1, 4
	call	fsqr.2543
	addi	%g1, %g1, 4
	fmov	%f4, %f0
	sti	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_a.2683
	fmul	%f5, %f4, %f0
	fmov	%f0, %f2
	call	fsqr.2543
	addi	%g1, %g1, 8
	fmov	%f4, %f0
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_b.2685
	fmul	%f0, %f4, %f0
	fadd	%f5, %f5, %f0
	fmov	%f0, %f1
	call	fsqr.2543
	addi	%g1, %g1, 8
	fmov	%f4, %f0
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_c.2687
	addi	%g1, %g1, 8
	fmul	%f0, %f4, %f0
	fadd	%f4, %f5, %f0
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_isrot.2681
	addi	%g1, %g1, 8
	mov	%g6, %g5
	jne	%g6, %g0, jeq_else.7736
	fmov	%f0, %f4
	return
jeq_else.7736:
	fmul	%f5, %f2, %f1
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r1.2707
	addi	%g1, %g1, 8
	fmul	%f0, %f5, %f0
	fadd	%f4, %f4, %f0
	fmul	%f1, %f1, %f3
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r2.2709
	addi	%g1, %g1, 8
	fmul	%f0, %f1, %f0
	fadd	%f4, %f4, %f0
	fmul	%f1, %f3, %f2
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r3.2711
	addi	%g1, %g1, 8
	fmul	%f0, %f1, %f0
	fadd	%f0, %f4, %f0
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = [%f5, %f7, %f2, %f6, %f4, %f1]
! ret type = Float
!---------------------------------------------------------------------
bilinear.2793:
	fmul	%f3, %f5, %f6
	sti	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_a.2683
	addi	%g1, %g1, 8
	fmul	%f8, %f3, %f0
	fmul	%f3, %f7, %f4
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_b.2685
	addi	%g1, %g1, 8
	fmul	%f0, %f3, %f0
	fadd	%f8, %f8, %f0
	fmul	%f3, %f2, %f1
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_c.2687
	addi	%g1, %g1, 8
	fmul	%f0, %f3, %f0
	fadd	%f3, %f8, %f0
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_isrot.2681
	addi	%g1, %g1, 8
	mov	%g6, %g5
	jne	%g6, %g0, jeq_else.7737
	fmov	%f0, %f3
	return
jeq_else.7737:
	fmul	%f8, %f2, %f4
	fmul	%f0, %f7, %f1
	fadd	%f8, %f8, %f0
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r1.2707
	addi	%g1, %g1, 8
	fmul	%f8, %f8, %f0
	fmul	%f1, %f5, %f1
	fmul	%f0, %f2, %f6
	fadd	%f1, %f1, %f0
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r2.2709
	addi	%g1, %g1, 8
	fmul	%f0, %f1, %f0
	fadd	%f2, %f8, %f0
	fmul	%f1, %f5, %f4
	fmul	%f0, %f7, %f6
	fadd	%f1, %f1, %f0
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r3.2711
	fmul	%f0, %f1, %f0
	fadd	%f0, %f2, %f0
	call	fhalf.2541
	addi	%g1, %g1, 8
	fadd	%f0, %f3, %f0
	return

!---------------------------------------------------------------------
! args = [%g7, %g5]
! fargs = [%f6, %f10, %f1]
! ret type = Int
!---------------------------------------------------------------------
solver_second.2801:
	fldi	%f12, %g5, 0
	fldi	%f7, %g5, -4
	fldi	%f11, %g5, -8
	fsti	%f1, %g1, 0
	mov	%g5, %g7
	fmov	%f1, %f11
	fmov	%f2, %f7
	fmov	%f3, %f12
	subi	%g1, %g1, 8
	call	quadratic.2788
	fmov	%f9, %f0
	fmov	%f0, %f9
	call	fiszero.2530
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7738
	fldi	%f1, %g1, 0
	fsti	%f6, %g1, 4
	mov	%g5, %g7
	fmov	%f4, %f10
	fmov	%f2, %f11
	fmov	%f5, %f12
	subi	%g1, %g1, 12
	call	bilinear.2793
	addi	%g1, %g1, 12
	fmov	%f7, %f0
	fldi	%f6, %g1, 4
	fldi	%f1, %g1, 0
	mov	%g5, %g7
	fmov	%f2, %f10
	fmov	%f3, %f6
	subi	%g1, %g1, 12
	call	quadratic.2788
	mov	%g5, %g7
	call	o_form.2675
	addi	%g1, %g1, 12
	addi	%g6, %g0, 3
	jne	%g5, %g6, jeq_else.7739
	fsub	%f1, %f0, %f17
	jmp	jeq_cont.7740
jeq_else.7739:
	fmov	%f1, %f0
jeq_cont.7740:
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
	jne	%g5, %g0, jeq_else.7741
	addi	%g5, %g0, 0
	return
jeq_else.7741:
	fldi	%f0, %g1, 8
	fsqrt	%f1, %f0
	mov	%g5, %g7
	subi	%g1, %g1, 16
	call	o_isinvert.2679
	addi	%g1, %g1, 16
	jne	%g5, %g0, jeq_else.7742
	fmov	%f0, %f1
	subi	%g1, %g1, 16
	call	fneg.2539
	addi	%g1, %g1, 16
	jmp	jeq_cont.7743
jeq_else.7742:
	fmov	%f0, %f1
jeq_cont.7743:
	fsub	%f0, %f0, %f7
	fdiv	%f0, %f0, %f9
	fsti	%f0, %g0, -1392
	addi	%g5, %g0, 1
	return
jeq_else.7738:
	addi	%g5, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g5, %g10, %g6]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
solver.2807:
	slli	%g5, %g5, 2
	ldi	%g12, %g5, -1640
	fldi	%f1, %g6, 0
	mov	%g5, %g12
	subi	%g1, %g1, 4
	call	o_param_x.2691
	fsub	%f8, %f1, %f0
	fldi	%f1, %g6, -4
	mov	%g5, %g12
	call	o_param_y.2693
	fsub	%f10, %f1, %f0
	fldi	%f1, %g6, -8
	mov	%g5, %g12
	call	o_param_z.2695
	fsub	%f6, %f1, %f0
	mov	%g5, %g12
	call	o_form.2675
	addi	%g1, %g1, 4
	mov	%g6, %g5
	jne	%g6, %g3, jeq_else.7744
	mov	%g6, %g12
	fmov	%f7, %f10
	jmp	solver_rect.2776
jeq_else.7744:
	addi	%g5, %g0, 2
	jne	%g6, %g5, jeq_else.7745
	mov	%g6, %g10
	mov	%g5, %g12
	fmov	%f4, %f6
	fmov	%f1, %f10
	fmov	%f2, %f8
	jmp	solver_surface.2782
jeq_else.7745:
	mov	%g5, %g10
	mov	%g7, %g12
	fmov	%f1, %f6
	fmov	%f6, %f8
	jmp	solver_second.2801

!---------------------------------------------------------------------
! args = [%g8, %g6, %g7]
! fargs = [%f4, %f6, %f3]
! ret type = Int
!---------------------------------------------------------------------
solver_rect_fast.2811:
	fldi	%f0, %g7, 0
	fsub	%f0, %f0, %f4
	fldi	%f2, %g7, -4
	fmul	%f7, %f0, %f2
	fldi	%f0, %g6, -4
	fmul	%f0, %f7, %f0
	fadd	%f1, %f0, %f6
	subi	%g1, %g1, 4
	call	fabs.2535
	fmov	%f1, %f0
	mov	%g5, %g8
	call	o_param_b.2685
	fmov	%f5, %f0
	fmov	%f0, %f5
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7746
	addi	%g5, %g0, 0
	jmp	jeq_cont.7747
jeq_else.7746:
	fldi	%f0, %g6, -8
	fmul	%f0, %f7, %f0
	fadd	%f1, %f0, %f3
	subi	%g1, %g1, 4
	call	fabs.2535
	fmov	%f1, %f0
	mov	%g5, %g8
	call	o_param_c.2687
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7748
	addi	%g5, %g0, 0
	jmp	jeq_cont.7749
jeq_else.7748:
	fmov	%f0, %f2
	subi	%g1, %g1, 4
	call	fiszero.2530
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7750
	addi	%g5, %g0, 1
	jmp	jeq_cont.7751
jeq_else.7750:
	addi	%g5, %g0, 0
jeq_cont.7751:
jeq_cont.7749:
jeq_cont.7747:
	jne	%g5, %g0, jeq_else.7752
	fldi	%f0, %g7, -8
	fsub	%f0, %f0, %f6
	fldi	%f7, %g7, -12
	fmul	%f8, %f0, %f7
	fldi	%f0, %g6, 0
	fmul	%f0, %f8, %f0
	fadd	%f1, %f0, %f4
	subi	%g1, %g1, 4
	call	fabs.2535
	fmov	%f1, %f0
	mov	%g5, %g8
	call	o_param_a.2683
	fmov	%f2, %f0
	fmov	%f0, %f2
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7753
	addi	%g5, %g0, 0
	jmp	jeq_cont.7754
jeq_else.7753:
	fldi	%f0, %g6, -8
	fmul	%f0, %f8, %f0
	fadd	%f1, %f0, %f3
	subi	%g1, %g1, 4
	call	fabs.2535
	fmov	%f1, %f0
	mov	%g5, %g8
	call	o_param_c.2687
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7755
	addi	%g5, %g0, 0
	jmp	jeq_cont.7756
jeq_else.7755:
	fmov	%f0, %f7
	subi	%g1, %g1, 4
	call	fiszero.2530
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7757
	addi	%g5, %g0, 1
	jmp	jeq_cont.7758
jeq_else.7757:
	addi	%g5, %g0, 0
jeq_cont.7758:
jeq_cont.7756:
jeq_cont.7754:
	jne	%g5, %g0, jeq_else.7759
	fldi	%f0, %g7, -16
	fsub	%f0, %f0, %f3
	fldi	%f3, %g7, -20
	fmul	%f7, %f0, %f3
	fldi	%f0, %g6, 0
	fmul	%f0, %f7, %f0
	fadd	%f1, %f0, %f4
	subi	%g1, %g1, 4
	call	fabs.2535
	fmov	%f1, %f0
	fmov	%f0, %f2
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7760
	addi	%g5, %g0, 0
	jmp	jeq_cont.7761
jeq_else.7760:
	fldi	%f0, %g6, -4
	fmul	%f0, %f7, %f0
	fadd	%f1, %f0, %f6
	subi	%g1, %g1, 4
	call	fabs.2535
	fmov	%f1, %f0
	fmov	%f0, %f5
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7762
	addi	%g5, %g0, 0
	jmp	jeq_cont.7763
jeq_else.7762:
	fmov	%f0, %f3
	subi	%g1, %g1, 4
	call	fiszero.2530
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7764
	addi	%g5, %g0, 1
	jmp	jeq_cont.7765
jeq_else.7764:
	addi	%g5, %g0, 0
jeq_cont.7765:
jeq_cont.7763:
jeq_cont.7761:
	jne	%g5, %g0, jeq_else.7766
	addi	%g5, %g0, 0
	return
jeq_else.7766:
	fsti	%f7, %g0, -1392
	addi	%g5, %g0, 3
	return
jeq_else.7759:
	fsti	%f8, %g0, -1392
	addi	%g5, %g0, 2
	return
jeq_else.7752:
	fsti	%f7, %g0, -1392
	addi	%g5, %g0, 1
	return

!---------------------------------------------------------------------
! args = [%g5, %g6]
! fargs = [%f3, %f2, %f1]
! ret type = Int
!---------------------------------------------------------------------
solver_surface_fast.2818:
	fldi	%f0, %g6, 0
	subi	%g1, %g1, 4
	call	fisneg.2528
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7767
	addi	%g5, %g0, 0
	return
jeq_else.7767:
	fldi	%f0, %g6, -4
	fmul	%f3, %f0, %f3
	fldi	%f0, %g6, -8
	fmul	%f0, %f0, %f2
	fadd	%f2, %f3, %f0
	fldi	%f0, %g6, -12
	fmul	%f0, %f0, %f1
	fadd	%f0, %f2, %f0
	fsti	%f0, %g0, -1392
	addi	%g5, %g0, 1
	return

!---------------------------------------------------------------------
! args = [%g8, %g7]
! fargs = [%f3, %f2, %f1]
! ret type = Int
!---------------------------------------------------------------------
solver_second_fast.2824:
	fldi	%f7, %g7, 0
	fmov	%f0, %f7
	subi	%g1, %g1, 4
	call	fiszero.2530
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7768
	fldi	%f0, %g7, -4
	fmul	%f4, %f0, %f3
	fldi	%f0, %g7, -8
	fmul	%f0, %f0, %f2
	fadd	%f4, %f4, %f0
	fldi	%f0, %g7, -12
	fmul	%f0, %f0, %f1
	fadd	%f6, %f4, %f0
	mov	%g5, %g8
	subi	%g1, %g1, 4
	call	quadratic.2788
	mov	%g5, %g8
	call	o_form.2675
	addi	%g1, %g1, 4
	addi	%g6, %g0, 3
	jne	%g5, %g6, jeq_else.7769
	fsub	%f1, %f0, %f17
	jmp	jeq_cont.7770
jeq_else.7769:
	fmov	%f1, %f0
jeq_cont.7770:
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
	jne	%g5, %g0, jeq_else.7771
	addi	%g5, %g0, 0
	return
jeq_else.7771:
	mov	%g5, %g8
	subi	%g1, %g1, 8
	call	o_isinvert.2679
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7772
	fldi	%f0, %g1, 0
	fsqrt	%f0, %f0
	fsub	%f1, %f6, %f0
	fldi	%f0, %g7, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g0, -1392
	jmp	jeq_cont.7773
jeq_else.7772:
	fldi	%f0, %g1, 0
	fsqrt	%f0, %f0
	fadd	%f1, %f6, %f0
	fldi	%f0, %g7, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g0, -1392
jeq_cont.7773:
	addi	%g5, %g0, 1
	return
jeq_else.7768:
	addi	%g5, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g7, %g9, %g6]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
solver_fast.2830:
	slli	%g5, %g7, 2
	ldi	%g8, %g5, -1640
	fldi	%f1, %g6, 0
	mov	%g5, %g8
	subi	%g1, %g1, 4
	call	o_param_x.2691
	fsub	%f3, %f1, %f0
	fldi	%f1, %g6, -4
	mov	%g5, %g8
	call	o_param_y.2693
	fsub	%f2, %f1, %f0
	fldi	%f1, %g6, -8
	mov	%g5, %g8
	call	o_param_z.2695
	fsub	%f1, %f1, %f0
	mov	%g5, %g9
	call	d_const.2736
	slli	%g6, %g7, 2
	ld	%g7, %g5, %g6
	mov	%g5, %g8
	call	o_form.2675
	addi	%g1, %g1, 4
	mov	%g6, %g5
	jne	%g6, %g3, jeq_else.7774
	mov	%g5, %g9
	subi	%g1, %g1, 4
	call	d_vec.2734
	addi	%g1, %g1, 4
	mov	%g6, %g5
	fmov	%f6, %f2
	fmov	%f4, %f3
	fmov	%f3, %f1
	jmp	solver_rect_fast.2811
jeq_else.7774:
	addi	%g5, %g0, 2
	jne	%g6, %g5, jeq_else.7775
	mov	%g6, %g7
	mov	%g5, %g8
	jmp	solver_surface_fast.2818
jeq_else.7775:
	jmp	solver_second_fast.2824

!---------------------------------------------------------------------
! args = [%g5, %g7, %g6]
! fargs = [%f2, %f1, %f0]
! ret type = Int
!---------------------------------------------------------------------
solver_surface_fast2.2834:
	fldi	%f0, %g7, 0
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fisneg.2528
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7776
	addi	%g5, %g0, 0
	return
jeq_else.7776:
	fldi	%f1, %g6, -12
	fldi	%f0, %g1, 0
	fmul	%f0, %f0, %f1
	fsti	%f0, %g0, -1392
	addi	%g5, %g0, 1
	return

!---------------------------------------------------------------------
! args = [%g8, %g7, %g6]
! fargs = [%f3, %f2, %f1]
! ret type = Int
!---------------------------------------------------------------------
solver_second_fast2.2841:
	fldi	%f4, %g7, 0
	fmov	%f0, %f4
	subi	%g1, %g1, 4
	call	fiszero.2530
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7777
	fldi	%f0, %g7, -4
	fmul	%f3, %f0, %f3
	fldi	%f0, %g7, -8
	fmul	%f0, %f0, %f2
	fadd	%f2, %f3, %f0
	fldi	%f0, %g7, -12
	fmul	%f0, %f0, %f1
	fadd	%f1, %f2, %f0
	fldi	%f2, %g6, -12
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
	jne	%g5, %g0, jeq_else.7778
	addi	%g5, %g0, 0
	return
jeq_else.7778:
	mov	%g5, %g8
	subi	%g1, %g1, 8
	call	o_isinvert.2679
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7779
	fldi	%f0, %g1, 0
	fsqrt	%f0, %f0
	fsub	%f1, %f1, %f0
	fldi	%f0, %g7, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g0, -1392
	jmp	jeq_cont.7780
jeq_else.7779:
	fldi	%f0, %g1, 0
	fsqrt	%f0, %f0
	fadd	%f1, %f1, %f0
	fldi	%f0, %g7, -16
	fmul	%f0, %f1, %f0
	fsti	%f0, %g0, -1392
jeq_cont.7780:
	addi	%g5, %g0, 1
	return
jeq_else.7777:
	addi	%g5, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g6, %g7]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
solver_fast2.2848:
	slli	%g5, %g6, 2
	ldi	%g8, %g5, -1640
	mov	%g5, %g8
	subi	%g1, %g1, 4
	call	o_param_ctbl.2713
	mov	%g10, %g5
	fldi	%f4, %g10, 0
	fldi	%f6, %g10, -4
	fldi	%f3, %g10, -8
	mov	%g5, %g7
	call	d_const.2736
	slli	%g6, %g6, 2
	ld	%g9, %g5, %g6
	mov	%g5, %g8
	call	o_form.2675
	addi	%g1, %g1, 4
	mov	%g6, %g5
	jne	%g6, %g3, jeq_else.7781
	mov	%g5, %g7
	subi	%g1, %g1, 4
	call	d_vec.2734
	addi	%g1, %g1, 4
	mov	%g6, %g5
	mov	%g7, %g9
	jmp	solver_rect_fast.2811
jeq_else.7781:
	addi	%g5, %g0, 2
	jne	%g6, %g5, jeq_else.7782
	mov	%g6, %g10
	mov	%g7, %g9
	mov	%g5, %g8
	fmov	%f0, %f3
	fmov	%f1, %f6
	fmov	%f2, %f4
	jmp	solver_surface_fast2.2834
jeq_else.7782:
	mov	%g6, %g10
	mov	%g7, %g9
	fmov	%f1, %f3
	fmov	%f2, %f6
	fmov	%f3, %f4
	jmp	solver_second_fast2.2841

!---------------------------------------------------------------------
! args = [%g7, %g8]
! fargs = []
! ret type = Array(Float)
!---------------------------------------------------------------------
setup_rect_table.2851:
	addi	%g5, %g0, 6
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	fldi	%f0, %g7, 0
	sti	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	fiszero.2530
	addi	%g1, %g1, 8
	mov	%g6, %g5
	jne	%g6, %g0, jeq_else.7783
	mov	%g5, %g8
	subi	%g1, %g1, 8
	call	o_isinvert.2679
	mov	%g6, %g5
	fldi	%f0, %g7, 0
	call	fisneg.2528
	mov	%g9, %g5
	mov	%g5, %g9
	call	xor.2532
	mov	%g6, %g5
	mov	%g5, %g8
	call	o_param_a.2683
	fmov	%f1, %f0
	mov	%g5, %g6
	call	fneg_cond.2621
	addi	%g1, %g1, 8
	ldi	%g5, %g1, 0
	fsti	%f0, %g5, 0
	fldi	%f0, %g7, 0
	fdiv	%f0, %f17, %f0
	fsti	%f0, %g5, -4
	jmp	jeq_cont.7784
jeq_else.7783:
	ldi	%g5, %g1, 0
	fsti	%f16, %g5, -4
jeq_cont.7784:
	fldi	%f0, %g7, -4
	subi	%g1, %g1, 8
	call	fiszero.2530
	addi	%g1, %g1, 8
	mov	%g6, %g5
	jne	%g6, %g0, jeq_else.7785
	mov	%g5, %g8
	subi	%g1, %g1, 8
	call	o_isinvert.2679
	mov	%g6, %g5
	fldi	%f0, %g7, -4
	call	fisneg.2528
	mov	%g9, %g5
	mov	%g5, %g9
	call	xor.2532
	mov	%g6, %g5
	mov	%g5, %g8
	call	o_param_b.2685
	fmov	%f1, %f0
	mov	%g5, %g6
	call	fneg_cond.2621
	addi	%g1, %g1, 8
	ldi	%g5, %g1, 0
	fsti	%f0, %g5, -8
	fldi	%f0, %g7, -4
	fdiv	%f0, %f17, %f0
	fsti	%f0, %g5, -12
	jmp	jeq_cont.7786
jeq_else.7785:
	ldi	%g5, %g1, 0
	fsti	%f16, %g5, -12
jeq_cont.7786:
	fldi	%f0, %g7, -8
	subi	%g1, %g1, 8
	call	fiszero.2530
	addi	%g1, %g1, 8
	mov	%g6, %g5
	jne	%g6, %g0, jeq_else.7787
	mov	%g5, %g8
	subi	%g1, %g1, 8
	call	o_isinvert.2679
	mov	%g6, %g5
	fldi	%f0, %g7, -8
	call	fisneg.2528
	mov	%g9, %g5
	mov	%g5, %g9
	call	xor.2532
	mov	%g6, %g5
	mov	%g5, %g8
	call	o_param_c.2687
	fmov	%f1, %f0
	mov	%g5, %g6
	call	fneg_cond.2621
	addi	%g1, %g1, 8
	ldi	%g5, %g1, 0
	fsti	%f0, %g5, -16
	fldi	%f0, %g7, -8
	fdiv	%f0, %f17, %f0
	fsti	%f0, %g5, -20
	jmp	jeq_cont.7788
jeq_else.7787:
	ldi	%g5, %g1, 0
	fsti	%f16, %g5, -20
jeq_cont.7788:
	return

!---------------------------------------------------------------------
! args = [%g7, %g8]
! fargs = []
! ret type = Array(Float)
!---------------------------------------------------------------------
setup_surface_table.2854:
	addi	%g5, %g0, 4
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	fldi	%f1, %g7, 0
	sti	%g5, %g1, 0
	mov	%g5, %g8
	subi	%g1, %g1, 8
	call	o_param_a.2683
	fmov	%f4, %f0
	fmul	%f2, %f1, %f4
	fldi	%f1, %g7, -4
	mov	%g5, %g8
	call	o_param_b.2685
	fmov	%f3, %f0
	fmul	%f0, %f1, %f3
	fadd	%f5, %f2, %f0
	fldi	%f1, %g7, -8
	mov	%g5, %g8
	call	o_param_c.2687
	fmov	%f2, %f0
	fmul	%f0, %f1, %f2
	fadd	%f1, %f5, %f0
	fmov	%f0, %f1
	call	fispos.2526
	addi	%g1, %g1, 8
	mov	%g6, %g5
	jne	%g6, %g0, jeq_else.7789
	ldi	%g5, %g1, 0
	fsti	%f16, %g5, 0
	jmp	jeq_cont.7790
jeq_else.7789:
	fdiv	%f0, %f21, %f1
	ldi	%g5, %g1, 0
	fsti	%f0, %g5, 0
	fdiv	%f0, %f4, %f1
	subi	%g1, %g1, 8
	call	fneg.2539
	fsti	%f0, %g5, -4
	fdiv	%f0, %f3, %f1
	call	fneg.2539
	fsti	%f0, %g5, -8
	fdiv	%f0, %f2, %f1
	call	fneg.2539
	addi	%g1, %g1, 8
	fsti	%f0, %g5, -12
jeq_cont.7790:
	return

!---------------------------------------------------------------------
! args = [%g7, %g8]
! fargs = []
! ret type = Array(Float)
!---------------------------------------------------------------------
setup_second_table.2857:
	addi	%g5, %g0, 5
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	fldi	%f3, %g7, 0
	fldi	%f2, %g7, -4
	fldi	%f6, %g7, -8
	sti	%g5, %g1, 0
	fsti	%f2, %g1, 4
	fsti	%f3, %g1, 8
	mov	%g5, %g8
	fmov	%f1, %f6
	subi	%g1, %g1, 16
	call	quadratic.2788
	fmov	%f5, %f0
	mov	%g5, %g8
	call	o_param_a.2683
	addi	%g1, %g1, 16
	fldi	%f3, %g1, 8
	fmul	%f0, %f3, %f0
	subi	%g1, %g1, 16
	call	fneg.2539
	fmov	%f1, %f0
	mov	%g5, %g8
	call	o_param_b.2685
	addi	%g1, %g1, 16
	fldi	%f2, %g1, 4
	fmul	%f0, %f2, %f0
	subi	%g1, %g1, 16
	call	fneg.2539
	fmov	%f2, %f0
	mov	%g5, %g8
	call	o_param_c.2687
	fmul	%f0, %f6, %f0
	call	fneg.2539
	addi	%g1, %g1, 16
	fmov	%f4, %f0
	ldi	%g5, %g1, 0
	fsti	%f5, %g5, 0
	mov	%g5, %g8
	subi	%g1, %g1, 16
	call	o_isrot.2681
	addi	%g1, %g1, 16
	mov	%g6, %g5
	jne	%g6, %g0, jeq_else.7791
	ldi	%g5, %g1, 0
	fsti	%f1, %g5, -4
	fsti	%f2, %g5, -8
	fsti	%f4, %g5, -12
	jmp	jeq_cont.7792
jeq_else.7791:
	fldi	%f6, %g7, -8
	mov	%g5, %g8
	subi	%g1, %g1, 16
	call	o_param_r2.2709
	fmov	%f3, %f0
	fmul	%f8, %f6, %f3
	fldi	%f7, %g7, -4
	mov	%g5, %g8
	call	o_param_r3.2711
	fmov	%f6, %f0
	fmul	%f0, %f7, %f6
	fadd	%f0, %f8, %f0
	call	fhalf.2541
	addi	%g1, %g1, 16
	fsub	%f0, %f1, %f0
	ldi	%g5, %g1, 0
	fsti	%f0, %g5, -4
	fldi	%f7, %g7, -8
	mov	%g5, %g8
	subi	%g1, %g1, 16
	call	o_param_r1.2707
	fmov	%f1, %f0
	fmul	%f7, %f7, %f1
	fldi	%f0, %g7, 0
	fmul	%f0, %f0, %f6
	fadd	%f0, %f7, %f0
	call	fhalf.2541
	addi	%g1, %g1, 16
	fsub	%f0, %f2, %f0
	ldi	%g5, %g1, 0
	fsti	%f0, %g5, -8
	fldi	%f0, %g7, -4
	fmul	%f1, %f0, %f1
	fldi	%f0, %g7, 0
	fmul	%f0, %f0, %f3
	fadd	%f0, %f1, %f0
	subi	%g1, %g1, 16
	call	fhalf.2541
	addi	%g1, %g1, 16
	fsub	%f0, %f4, %f0
	fsti	%f0, %g5, -12
jeq_cont.7792:
	fmov	%f0, %f5
	subi	%g1, %g1, 16
	call	fiszero.2530
	addi	%g1, %g1, 16
	mov	%g6, %g5
	jne	%g6, %g0, jeq_else.7793
	fdiv	%f0, %f17, %f5
	ldi	%g5, %g1, 0
	fsti	%f0, %g5, -16
	jmp	jeq_cont.7794
jeq_else.7793:
jeq_cont.7794:
	ldi	%g5, %g1, 0
	return

!---------------------------------------------------------------------
! args = [%g11, %g10]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
iter_setup_dirvec_constants.2860:
	jlt	%g10, %g0, jge_else.7795
	slli	%g5, %g10, 2
	ldi	%g8, %g5, -1640
	mov	%g5, %g11
	subi	%g1, %g1, 4
	call	d_const.2736
	mov	%g12, %g5
	mov	%g5, %g11
	call	d_vec.2734
	mov	%g7, %g5
	mov	%g5, %g8
	call	o_form.2675
	addi	%g1, %g1, 4
	jne	%g5, %g3, jeq_else.7796
	subi	%g1, %g1, 4
	call	setup_rect_table.2851
	addi	%g1, %g1, 4
	slli	%g6, %g10, 2
	st	%g5, %g12, %g6
	jmp	jeq_cont.7797
jeq_else.7796:
	addi	%g6, %g0, 2
	jne	%g5, %g6, jeq_else.7798
	subi	%g1, %g1, 4
	call	setup_surface_table.2854
	addi	%g1, %g1, 4
	slli	%g6, %g10, 2
	st	%g5, %g12, %g6
	jmp	jeq_cont.7799
jeq_else.7798:
	subi	%g1, %g1, 4
	call	setup_second_table.2857
	addi	%g1, %g1, 4
	slli	%g6, %g10, 2
	st	%g5, %g12, %g6
jeq_cont.7799:
jeq_cont.7797:
	subi	%g10, %g10, 1
	jmp	iter_setup_dirvec_constants.2860
jge_else.7795:
	return

!---------------------------------------------------------------------
! args = [%g11]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
setup_dirvec_constants.2863:
	ldi	%g5, %g0, -1884
	subi	%g10, %g5, 1
	jmp	iter_setup_dirvec_constants.2860

!---------------------------------------------------------------------
! args = [%g8, %g7]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
setup_startp_constants.2865:
	jlt	%g7, %g0, jge_else.7801
	slli	%g5, %g7, 2
	ldi	%g5, %g5, -1640
	sti	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_ctbl.2713
	addi	%g1, %g1, 8
	mov	%g9, %g5
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_form.2675
	addi	%g1, %g1, 8
	mov	%g10, %g5
	fldi	%f1, %g8, 0
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_x.2691
	addi	%g1, %g1, 8
	fsub	%f0, %f1, %f0
	fsti	%f0, %g9, 0
	fldi	%f1, %g8, -4
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_y.2693
	addi	%g1, %g1, 8
	fsub	%f0, %f1, %f0
	fsti	%f0, %g9, -4
	fldi	%f1, %g8, -8
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_z.2695
	addi	%g1, %g1, 8
	fsub	%f0, %f1, %f0
	fsti	%f0, %g9, -8
	addi	%g6, %g0, 2
	jne	%g10, %g6, jeq_else.7802
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_abc.2689
	fldi	%f2, %g9, 0
	fldi	%f1, %g9, -4
	fldi	%f0, %g9, -8
	call	veciprod2.2651
	addi	%g1, %g1, 8
	fsti	%f0, %g9, -12
	jmp	jeq_cont.7803
jeq_else.7802:
	addi	%g6, %g0, 2
	jlt	%g6, %g10, jle_else.7804
	jmp	jle_cont.7805
jle_else.7804:
	fldi	%f3, %g9, 0
	fldi	%f2, %g9, -4
	fldi	%f1, %g9, -8
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	quadratic.2788
	addi	%g1, %g1, 8
	addi	%g5, %g0, 3
	jne	%g10, %g5, jeq_else.7806
	fsub	%f1, %f0, %f17
	jmp	jeq_cont.7807
jeq_else.7806:
	fmov	%f1, %f0
jeq_cont.7807:
	fsti	%f1, %g9, -12
jle_cont.7805:
jeq_cont.7803:
	subi	%g7, %g7, 1
	jmp	setup_startp_constants.2865
jge_else.7801:
	return

!---------------------------------------------------------------------
! args = [%g8]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
setup_startp.2868:
	subi	%g6, %g0, -1276
	mov	%g5, %g8
	subi	%g1, %g1, 4
	call	veccpy.2637
	addi	%g1, %g1, 4
	ldi	%g5, %g0, -1884
	subi	%g7, %g5, 1
	jmp	setup_startp_constants.2865

!---------------------------------------------------------------------
! args = [%g6]
! fargs = [%f1, %f3, %f2]
! ret type = Bool
!---------------------------------------------------------------------
is_rect_outside.2870:
	subi	%g1, %g1, 4
	call	fabs.2535
	fmov	%f1, %f0
	mov	%g5, %g6
	call	o_param_a.2683
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7809
	addi	%g5, %g0, 0
	jmp	jeq_cont.7810
jeq_else.7809:
	fmov	%f1, %f3
	subi	%g1, %g1, 4
	call	fabs.2535
	fmov	%f1, %f0
	mov	%g5, %g6
	call	o_param_b.2685
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7811
	addi	%g5, %g0, 0
	jmp	jeq_cont.7812
jeq_else.7811:
	fmov	%f1, %f2
	subi	%g1, %g1, 4
	call	fabs.2535
	fmov	%f1, %f0
	mov	%g5, %g6
	call	o_param_c.2687
	call	fless.2523
	addi	%g1, %g1, 4
jeq_cont.7812:
jeq_cont.7810:
	jne	%g5, %g0, jeq_else.7813
	mov	%g5, %g6
	subi	%g1, %g1, 4
	call	o_isinvert.2679
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7814
	addi	%g5, %g0, 1
	return
jeq_else.7814:
	addi	%g5, %g0, 0
	return
jeq_else.7813:
	mov	%g5, %g6
	jmp	o_isinvert.2679

!---------------------------------------------------------------------
! args = [%g5]
! fargs = [%f2, %f1, %f0]
! ret type = Bool
!---------------------------------------------------------------------
is_plane_outside.2875:
	sti	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_abc.2689
	mov	%g6, %g5
	mov	%g5, %g6
	call	veciprod2.2651
	addi	%g1, %g1, 8
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_isinvert.2679
	mov	%g6, %g5
	call	fisneg.2528
	call	xor.2532
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7815
	addi	%g5, %g0, 1
	return
jeq_else.7815:
	addi	%g5, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = [%f3, %f2, %f1]
! ret type = Bool
!---------------------------------------------------------------------
is_second_outside.2880:
	sti	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	quadratic.2788
	addi	%g1, %g1, 8
	fmov	%f1, %f0
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_form.2675
	addi	%g1, %g1, 8
	mov	%g6, %g5
	addi	%g7, %g0, 3
	jne	%g6, %g7, jeq_else.7816
	fsub	%f0, %f1, %f17
	jmp	jeq_cont.7817
jeq_else.7816:
	fmov	%f0, %f1
jeq_cont.7817:
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_isinvert.2679
	mov	%g6, %g5
	call	fisneg.2528
	call	xor.2532
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7818
	addi	%g5, %g0, 1
	return
jeq_else.7818:
	addi	%g5, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g8]
! fargs = [%f3, %f2, %f1]
! ret type = Bool
!---------------------------------------------------------------------
is_outside.2885:
	mov	%g5, %g8
	subi	%g1, %g1, 4
	call	o_param_x.2691
	fsub	%f8, %f3, %f0
	mov	%g5, %g8
	call	o_param_y.2693
	fsub	%f7, %f2, %f0
	mov	%g5, %g8
	call	o_param_z.2695
	fsub	%f6, %f1, %f0
	mov	%g5, %g8
	call	o_form.2675
	addi	%g1, %g1, 4
	mov	%g6, %g5
	jne	%g6, %g3, jeq_else.7819
	mov	%g6, %g8
	fmov	%f2, %f6
	fmov	%f3, %f7
	fmov	%f1, %f8
	jmp	is_rect_outside.2870
jeq_else.7819:
	addi	%g5, %g0, 2
	jne	%g6, %g5, jeq_else.7820
	mov	%g5, %g8
	fmov	%f0, %f6
	fmov	%f1, %f7
	fmov	%f2, %f8
	jmp	is_plane_outside.2875
jeq_else.7820:
	mov	%g5, %g8
	fmov	%f1, %f6
	fmov	%f2, %f7
	fmov	%f3, %f8
	jmp	is_second_outside.2880

!---------------------------------------------------------------------
! args = [%g9, %g10]
! fargs = [%f3, %f2, %f1]
! ret type = Bool
!---------------------------------------------------------------------
check_all_inside.2890:
	slli	%g5, %g9, 2
	ld	%g6, %g10, %g5
	jne	%g6, %g4, jeq_else.7821
	addi	%g5, %g0, 1
	return
jeq_else.7821:
	slli	%g5, %g6, 2
	ldi	%g8, %g5, -1640
	fsti	%f1, %g1, 0
	fsti	%f2, %g1, 4
	fsti	%f3, %g1, 8
	subi	%g1, %g1, 16
	call	is_outside.2885
	addi	%g1, %g1, 16
	jne	%g5, %g0, jeq_else.7822
	addi	%g9, %g9, 1
	fldi	%f3, %g1, 8
	fldi	%f2, %g1, 4
	fldi	%f1, %g1, 0
	jmp	check_all_inside.2890
jeq_else.7822:
	addi	%g5, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g11, %g10]
! fargs = []
! ret type = Bool
!---------------------------------------------------------------------
shadow_check_and_group.2896:
	slli	%g5, %g11, 2
	ld	%g7, %g10, %g5
	jne	%g7, %g4, jeq_else.7823
	addi	%g5, %g0, 0
	return
jeq_else.7823:
	subi	%g6, %g0, -1372
	subi	%g9, %g0, -932
	sti	%g7, %g1, 0
	subi	%g1, %g1, 8
	call	solver_fast.2830
	addi	%g1, %g1, 8
	fldi	%f1, %g0, -1392
	fsti	%f1, %g1, 4
	jne	%g5, %g0, jeq_else.7824
	addi	%g5, %g0, 0
	jmp	jeq_cont.7825
jeq_else.7824:
	fmvhi	%f0, 48716
	fmvlo	%f0, 52420
	subi	%g1, %g1, 12
	call	fless.2523
	addi	%g1, %g1, 12
jeq_cont.7825:
	jne	%g5, %g0, jeq_else.7826
	ldi	%g7, %g1, 0
	slli	%g5, %g7, 2
	ldi	%g5, %g5, -1640
	subi	%g1, %g1, 12
	call	o_isinvert.2679
	addi	%g1, %g1, 12
	jne	%g5, %g0, jeq_else.7827
	addi	%g5, %g0, 0
	return
jeq_else.7827:
	addi	%g11, %g11, 1
	jmp	shadow_check_and_group.2896
jeq_else.7826:
	fldi	%f1, %g1, 4
	fadd	%f0, %f1, %f26
	fldi	%f1, %g0, -1604
	fmul	%f2, %f1, %f0
	fldi	%f1, %g0, -1372
	fadd	%f3, %f2, %f1
	fldi	%f1, %g0, -1608
	fmul	%f2, %f1, %f0
	fldi	%f1, %g0, -1376
	fadd	%f2, %f2, %f1
	fldi	%f1, %g0, -1612
	fmul	%f1, %f1, %f0
	fldi	%f0, %g0, -1380
	fadd	%f1, %f1, %f0
	addi	%g9, %g0, 0
	sti	%g10, %g1, 8
	subi	%g1, %g1, 16
	call	check_all_inside.2890
	addi	%g1, %g1, 16
	jne	%g5, %g0, jeq_else.7828
	addi	%g11, %g11, 1
	ldi	%g10, %g1, 8
	jmp	shadow_check_and_group.2896
jeq_else.7828:
	addi	%g5, %g0, 1
	return

!---------------------------------------------------------------------
! args = [%g12, %g13]
! fargs = []
! ret type = Bool
!---------------------------------------------------------------------
shadow_check_one_or_group.2899:
	slli	%g5, %g12, 2
	ld	%g6, %g13, %g5
	jne	%g6, %g4, jeq_else.7829
	addi	%g5, %g0, 0
	return
jeq_else.7829:
	slli	%g5, %g6, 2
	ldi	%g10, %g5, -1400
	addi	%g11, %g0, 0
	subi	%g1, %g1, 4
	call	shadow_check_and_group.2896
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7830
	addi	%g12, %g12, 1
	jmp	shadow_check_one_or_group.2899
jeq_else.7830:
	addi	%g5, %g0, 1
	return

!---------------------------------------------------------------------
! args = [%g14, %g15]
! fargs = []
! ret type = Bool
!---------------------------------------------------------------------
shadow_check_one_or_matrix.2902:
	slli	%g5, %g14, 2
	ld	%g13, %g15, %g5
	ldi	%g7, %g13, 0
	jne	%g7, %g4, jeq_else.7831
	addi	%g5, %g0, 0
	return
jeq_else.7831:
	addi	%g5, %g0, 99
	sti	%g13, %g1, 0
	jne	%g7, %g5, jeq_else.7832
	addi	%g5, %g0, 1
	jmp	jeq_cont.7833
jeq_else.7832:
	subi	%g6, %g0, -1372
	subi	%g9, %g0, -932
	subi	%g1, %g1, 8
	call	solver_fast.2830
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7834
	addi	%g5, %g0, 0
	jmp	jeq_cont.7835
jeq_else.7834:
	fldi	%f1, %g0, -1392
	fmov	%f0, %f25
	subi	%g1, %g1, 8
	call	fless.2523
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7836
	addi	%g5, %g0, 0
	jmp	jeq_cont.7837
jeq_else.7836:
	addi	%g12, %g0, 1
	subi	%g1, %g1, 8
	call	shadow_check_one_or_group.2899
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7838
	addi	%g5, %g0, 0
	jmp	jeq_cont.7839
jeq_else.7838:
	addi	%g5, %g0, 1
jeq_cont.7839:
jeq_cont.7837:
jeq_cont.7835:
jeq_cont.7833:
	jne	%g5, %g0, jeq_else.7840
	addi	%g14, %g14, 1
	jmp	shadow_check_one_or_matrix.2902
jeq_else.7840:
	addi	%g12, %g0, 1
	ldi	%g13, %g1, 0
	subi	%g1, %g1, 8
	call	shadow_check_one_or_group.2899
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7841
	addi	%g14, %g14, 1
	jmp	shadow_check_one_or_matrix.2902
jeq_else.7841:
	addi	%g5, %g0, 1
	return

!---------------------------------------------------------------------
! args = [%g13, %g16, %g15]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
solve_each_element.2905:
	slli	%g5, %g13, 2
	ld	%g14, %g16, %g5
	jne	%g14, %g4, jeq_else.7842
	return
jeq_else.7842:
	subi	%g6, %g0, -1288
	mov	%g10, %g15
	mov	%g5, %g14
	subi	%g1, %g1, 4
	call	solver.2807
	addi	%g1, %g1, 4
	mov	%g11, %g5
	jne	%g11, %g0, jeq_else.7844
	slli	%g5, %g14, 2
	ldi	%g5, %g5, -1640
	subi	%g1, %g1, 4
	call	o_isinvert.2679
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7845
	return
jeq_else.7845:
	addi	%g13, %g13, 1
	jmp	solve_each_element.2905
jeq_else.7844:
	fldi	%f2, %g0, -1392
	fmov	%f0, %f2
	fmov	%f1, %f16
	subi	%g1, %g1, 4
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7847
	jmp	jeq_cont.7848
jeq_else.7847:
	fldi	%f0, %g0, -1384
	fmov	%f1, %f2
	subi	%g1, %g1, 4
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7849
	jmp	jeq_cont.7850
jeq_else.7849:
	fadd	%f11, %f2, %f26
	fldi	%f0, %g15, 0
	fmul	%f1, %f0, %f11
	fldi	%f0, %g0, -1288
	fadd	%f3, %f1, %f0
	fldi	%f0, %g15, -4
	fmul	%f1, %f0, %f11
	fldi	%f0, %g0, -1292
	fadd	%f10, %f1, %f0
	fldi	%f0, %g15, -8
	fmul	%f1, %f0, %f11
	fldi	%f0, %g0, -1296
	fadd	%f9, %f1, %f0
	addi	%g9, %g0, 0
	fsti	%f3, %g1, 0
	mov	%g10, %g16
	fmov	%f1, %f9
	fmov	%f2, %f10
	subi	%g1, %g1, 8
	call	check_all_inside.2890
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7851
	jmp	jeq_cont.7852
jeq_else.7851:
	fsti	%f11, %g0, -1384
	subi	%g5, %g0, -1372
	fldi	%f3, %g1, 0
	fmov	%f0, %f9
	fmov	%f1, %f10
	fmov	%f2, %f3
	subi	%g1, %g1, 8
	call	vecset.2627
	addi	%g1, %g1, 8
	sti	%g14, %g0, -1368
	sti	%g11, %g0, -1388
jeq_cont.7852:
jeq_cont.7850:
jeq_cont.7848:
	addi	%g13, %g13, 1
	jmp	solve_each_element.2905

!---------------------------------------------------------------------
! args = [%g17, %g18, %g15]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
solve_one_or_network.2909:
	slli	%g5, %g17, 2
	ld	%g5, %g18, %g5
	jne	%g5, %g4, jeq_else.7853
	return
jeq_else.7853:
	slli	%g5, %g5, 2
	ldi	%g16, %g5, -1400
	addi	%g13, %g0, 0
	sti	%g15, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element.2905
	addi	%g1, %g1, 8
	addi	%g17, %g17, 1
	ldi	%g15, %g1, 0
	jmp	solve_one_or_network.2909

!---------------------------------------------------------------------
! args = [%g19, %g20, %g15]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
trace_or_matrix.2913:
	slli	%g5, %g19, 2
	ld	%g18, %g20, %g5
	ldi	%g5, %g18, 0
	jne	%g5, %g4, jeq_else.7855
	return
jeq_else.7855:
	addi	%g6, %g0, 99
	sti	%g15, %g1, 0
	jne	%g5, %g6, jeq_else.7857
	addi	%g17, %g0, 1
	subi	%g1, %g1, 8
	call	solve_one_or_network.2909
	addi	%g1, %g1, 8
	jmp	jeq_cont.7858
jeq_else.7857:
	subi	%g6, %g0, -1288
	mov	%g10, %g15
	subi	%g1, %g1, 8
	call	solver.2807
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7859
	jmp	jeq_cont.7860
jeq_else.7859:
	fldi	%f1, %g0, -1392
	fldi	%f0, %g0, -1384
	subi	%g1, %g1, 8
	call	fless.2523
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7861
	jmp	jeq_cont.7862
jeq_else.7861:
	addi	%g17, %g0, 1
	subi	%g1, %g1, 8
	call	solve_one_or_network.2909
	addi	%g1, %g1, 8
jeq_cont.7862:
jeq_cont.7860:
jeq_cont.7858:
	addi	%g19, %g19, 1
	ldi	%g15, %g1, 0
	jmp	trace_or_matrix.2913

!---------------------------------------------------------------------
! args = [%g15]
! fargs = []
! ret type = Bool
!---------------------------------------------------------------------
judge_intersection.2917:
	fsti	%f22, %g0, -1384
	addi	%g19, %g0, 0
	ldi	%g20, %g0, -1396
	subi	%g1, %g1, 4
	call	trace_or_matrix.2913
	fldi	%f2, %g0, -1384
	fmov	%f0, %f2
	fmov	%f1, %f25
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7863
	addi	%g5, %g0, 0
	return
jeq_else.7863:
	fmvhi	%f0, 19646
	fmvlo	%f0, 48160
	fmov	%f1, %f2
	jmp	fless.2523

!---------------------------------------------------------------------
! args = [%g11, %g14, %g13]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
solve_each_element_fast.2919:
	mov	%g5, %g13
	subi	%g1, %g1, 4
	call	d_vec.2734
	addi	%g1, %g1, 4
	mov	%g15, %g5
	slli	%g5, %g11, 2
	ld	%g12, %g14, %g5
	jne	%g12, %g4, jeq_else.7864
	return
jeq_else.7864:
	mov	%g7, %g13
	mov	%g6, %g12
	subi	%g1, %g1, 4
	call	solver_fast2.2848
	addi	%g1, %g1, 4
	mov	%g16, %g5
	jne	%g16, %g0, jeq_else.7866
	slli	%g5, %g12, 2
	ldi	%g5, %g5, -1640
	subi	%g1, %g1, 4
	call	o_isinvert.2679
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7867
	return
jeq_else.7867:
	addi	%g11, %g11, 1
	jmp	solve_each_element_fast.2919
jeq_else.7866:
	fldi	%f2, %g0, -1392
	fmov	%f0, %f2
	fmov	%f1, %f16
	subi	%g1, %g1, 4
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7869
	jmp	jeq_cont.7870
jeq_else.7869:
	fldi	%f0, %g0, -1384
	fmov	%f1, %f2
	subi	%g1, %g1, 4
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7871
	jmp	jeq_cont.7872
jeq_else.7871:
	fadd	%f11, %f2, %f26
	fldi	%f0, %g15, 0
	fmul	%f1, %f0, %f11
	fldi	%f0, %g0, -1276
	fadd	%f3, %f1, %f0
	fldi	%f0, %g15, -4
	fmul	%f1, %f0, %f11
	fldi	%f0, %g0, -1280
	fadd	%f10, %f1, %f0
	fldi	%f0, %g15, -8
	fmul	%f1, %f0, %f11
	fldi	%f0, %g0, -1284
	fadd	%f9, %f1, %f0
	addi	%g9, %g0, 0
	fsti	%f3, %g1, 0
	mov	%g10, %g14
	fmov	%f1, %f9
	fmov	%f2, %f10
	subi	%g1, %g1, 8
	call	check_all_inside.2890
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7873
	jmp	jeq_cont.7874
jeq_else.7873:
	fsti	%f11, %g0, -1384
	subi	%g5, %g0, -1372
	fldi	%f3, %g1, 0
	fmov	%f0, %f9
	fmov	%f1, %f10
	fmov	%f2, %f3
	subi	%g1, %g1, 8
	call	vecset.2627
	addi	%g1, %g1, 8
	sti	%g12, %g0, -1368
	sti	%g16, %g0, -1388
jeq_cont.7874:
jeq_cont.7872:
jeq_cont.7870:
	addi	%g11, %g11, 1
	jmp	solve_each_element_fast.2919

!---------------------------------------------------------------------
! args = [%g17, %g18, %g13]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
solve_one_or_network_fast.2923:
	slli	%g5, %g17, 2
	ld	%g5, %g18, %g5
	jne	%g5, %g4, jeq_else.7875
	return
jeq_else.7875:
	slli	%g5, %g5, 2
	ldi	%g14, %g5, -1400
	addi	%g11, %g0, 0
	sti	%g13, %g1, 0
	subi	%g1, %g1, 8
	call	solve_each_element_fast.2919
	addi	%g1, %g1, 8
	addi	%g17, %g17, 1
	ldi	%g13, %g1, 0
	jmp	solve_one_or_network_fast.2923

!---------------------------------------------------------------------
! args = [%g19, %g20, %g13]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
trace_or_matrix_fast.2927:
	slli	%g5, %g19, 2
	ld	%g18, %g20, %g5
	ldi	%g6, %g18, 0
	jne	%g6, %g4, jeq_else.7877
	return
jeq_else.7877:
	addi	%g5, %g0, 99
	sti	%g13, %g1, 0
	jne	%g6, %g5, jeq_else.7879
	addi	%g17, %g0, 1
	subi	%g1, %g1, 8
	call	solve_one_or_network_fast.2923
	addi	%g1, %g1, 8
	jmp	jeq_cont.7880
jeq_else.7879:
	mov	%g7, %g13
	subi	%g1, %g1, 8
	call	solver_fast2.2848
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7881
	jmp	jeq_cont.7882
jeq_else.7881:
	fldi	%f1, %g0, -1392
	fldi	%f0, %g0, -1384
	subi	%g1, %g1, 8
	call	fless.2523
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7883
	jmp	jeq_cont.7884
jeq_else.7883:
	addi	%g17, %g0, 1
	subi	%g1, %g1, 8
	call	solve_one_or_network_fast.2923
	addi	%g1, %g1, 8
jeq_cont.7884:
jeq_cont.7882:
jeq_cont.7880:
	addi	%g19, %g19, 1
	ldi	%g13, %g1, 0
	jmp	trace_or_matrix_fast.2927

!---------------------------------------------------------------------
! args = [%g13]
! fargs = []
! ret type = Bool
!---------------------------------------------------------------------
judge_intersection_fast.2931:
	fsti	%f22, %g0, -1384
	addi	%g19, %g0, 0
	ldi	%g20, %g0, -1396
	subi	%g1, %g1, 4
	call	trace_or_matrix_fast.2927
	fldi	%f2, %g0, -1384
	fmov	%f0, %f2
	fmov	%f1, %f25
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7885
	addi	%g5, %g0, 0
	return
jeq_else.7885:
	fmvhi	%f0, 19646
	fmvlo	%f0, 48160
	fmov	%f1, %f2
	jmp	fless.2523

!---------------------------------------------------------------------
! args = [%g6]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
get_nvector_rect.2933:
	ldi	%g7, %g0, -1388
	subi	%g5, %g0, -1356
	subi	%g1, %g1, 4
	call	vecbzero.2635
	subi	%g7, %g7, 1
	slli	%g5, %g7, 2
	fld	%f1, %g6, %g5
	call	sgn.2619
	call	fneg.2539
	addi	%g1, %g1, 4
	slli	%g5, %g7, 2
	fsti	%f0, %g5, -1356
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
get_nvector_plane.2935:
	sti	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_a.2683
	call	fneg.2539
	addi	%g1, %g1, 8
	fsti	%f0, %g0, -1356
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_b.2685
	call	fneg.2539
	addi	%g1, %g1, 8
	fsti	%f0, %g0, -1360
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_c.2687
	call	fneg.2539
	addi	%g1, %g1, 8
	fsti	%f0, %g0, -1364
	return

!---------------------------------------------------------------------
! args = [%g5]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
get_nvector_second.2937:
	fldi	%f1, %g0, -1372
	sti	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_x.2691
	addi	%g1, %g1, 8
	fsub	%f5, %f1, %f0
	fldi	%f1, %g0, -1376
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_y.2693
	addi	%g1, %g1, 8
	fsub	%f2, %f1, %f0
	fldi	%f1, %g0, -1380
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_z.2695
	addi	%g1, %g1, 8
	fsub	%f1, %f1, %f0
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_a.2683
	addi	%g1, %g1, 8
	fmul	%f8, %f5, %f0
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_b.2685
	addi	%g1, %g1, 8
	fmul	%f3, %f2, %f0
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_c.2687
	addi	%g1, %g1, 8
	fmul	%f6, %f1, %f0
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_isrot.2681
	addi	%g1, %g1, 8
	mov	%g6, %g5
	jne	%g6, %g0, jeq_else.7888
	fsti	%f8, %g0, -1356
	fsti	%f3, %g0, -1360
	fsti	%f6, %g0, -1364
	jmp	jeq_cont.7889
jeq_else.7888:
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r3.2711
	addi	%g1, %g1, 8
	fmov	%f7, %f0
	fmul	%f9, %f2, %f7
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r2.2709
	fmov	%f4, %f0
	fmul	%f0, %f1, %f4
	fadd	%f0, %f9, %f0
	call	fhalf.2541
	addi	%g1, %g1, 8
	fadd	%f0, %f8, %f0
	fsti	%f0, %g0, -1356
	fmul	%f8, %f5, %f7
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_param_r1.2707
	fmov	%f7, %f0
	fmul	%f0, %f1, %f7
	fadd	%f0, %f8, %f0
	call	fhalf.2541
	fadd	%f0, %f3, %f0
	fsti	%f0, %g0, -1360
	fmul	%f1, %f5, %f4
	fmul	%f0, %f2, %f7
	fadd	%f0, %f1, %f0
	call	fhalf.2541
	addi	%g1, %g1, 8
	fadd	%f0, %f6, %f0
	fsti	%f0, %g0, -1364
jeq_cont.7889:
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_isinvert.2679
	addi	%g1, %g1, 8
	mov	%g7, %g5
	subi	%g6, %g0, -1356
	jmp	vecunit_sgn.2645

!---------------------------------------------------------------------
! args = [%g5, %g6]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
get_nvector.2939:
	sti	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	o_form.2675
	addi	%g1, %g1, 8
	mov	%g7, %g5
	jne	%g7, %g3, jeq_else.7890
	jmp	get_nvector_rect.2933
jeq_else.7890:
	addi	%g6, %g0, 2
	jne	%g7, %g6, jeq_else.7891
	ldi	%g5, %g1, 0
	jmp	get_nvector_plane.2935
jeq_else.7891:
	ldi	%g5, %g1, 0
	jmp	get_nvector_second.2937

!---------------------------------------------------------------------
! args = [%g8, %g7]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
utexture.2942:
	mov	%g5, %g8
	subi	%g1, %g1, 4
	call	o_texturetype.2673
	mov	%g6, %g5
	mov	%g5, %g8
	call	o_color_red.2701
	fsti	%f0, %g0, -1344
	mov	%g5, %g8
	call	o_color_green.2703
	fsti	%f0, %g0, -1348
	mov	%g5, %g8
	call	o_color_blue.2705
	addi	%g1, %g1, 4
	fsti	%f0, %g0, -1352
	jne	%g6, %g3, jeq_else.7892
	fldi	%f1, %g7, 0
	mov	%g5, %g8
	subi	%g1, %g1, 4
	call	o_param_x.2691
	fsub	%f5, %f1, %f0
	fmvhi	%f8, 15692
	fmvlo	%f8, 52420
	fmul	%f0, %f5, %f8
	call	min_caml_floor
	fmvhi	%f7, 16800
	fmvlo	%f7, 0
	fmul	%f0, %f0, %f7
	fsub	%f1, %f5, %f0
	fmvhi	%f5, 16672
	fmvlo	%f5, 0
	fmov	%f0, %f5
	call	fless.2523
	mov	%g9, %g5
	fldi	%f1, %g7, -8
	mov	%g5, %g8
	call	o_param_z.2695
	fsub	%f6, %f1, %f0
	fmul	%f0, %f6, %f8
	call	min_caml_floor
	fmul	%f0, %f0, %f7
	fsub	%f1, %f6, %f0
	fmov	%f0, %f5
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g9, %g0, jeq_else.7893
	jne	%g5, %g0, jeq_else.7895
	fmov	%f0, %f18
	jmp	jeq_cont.7896
jeq_else.7895:
	fmov	%f0, %f16
jeq_cont.7896:
	jmp	jeq_cont.7894
jeq_else.7893:
	jne	%g5, %g0, jeq_else.7897
	fmov	%f0, %f16
	jmp	jeq_cont.7898
jeq_else.7897:
	fmov	%f0, %f18
jeq_cont.7898:
jeq_cont.7894:
	fsti	%f0, %g0, -1348
	return
jeq_else.7892:
	addi	%g5, %g0, 2
	jne	%g6, %g5, jeq_else.7900
	fldi	%f1, %g7, -4
	fmvhi	%f0, 16000
	fmvlo	%f0, 0
	fmul	%f3, %f1, %f0
	subi	%g1, %g1, 4
	call	sin.2558
	call	fsqr.2543
	addi	%g1, %g1, 4
	fmul	%f1, %f18, %f0
	fsti	%f1, %g0, -1344
	fsub	%f0, %f17, %f0
	fmul	%f0, %f18, %f0
	fsti	%f0, %g0, -1348
	return
jeq_else.7900:
	addi	%g5, %g0, 3
	jne	%g6, %g5, jeq_else.7902
	fldi	%f1, %g7, 0
	mov	%g5, %g8
	subi	%g1, %g1, 4
	call	o_param_x.2691
	fsub	%f1, %f1, %f0
	fldi	%f2, %g7, -8
	mov	%g5, %g8
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
	fmvhi	%f1, 16672
	fmvlo	%f1, 0
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
	call	cos.2560
	call	fsqr.2543
	addi	%g1, %g1, 12
	fmul	%f1, %f0, %f18
	fsti	%f1, %g0, -1348
	fsub	%f0, %f17, %f0
	fmul	%f0, %f0, %f18
	fsti	%f0, %g0, -1352
	return
jeq_else.7902:
	addi	%g5, %g0, 4
	jne	%g6, %g5, jeq_else.7904
	fldi	%f1, %g7, 0
	mov	%g5, %g8
	subi	%g1, %g1, 12
	call	o_param_x.2691
	fsub	%f1, %f1, %f0
	mov	%g5, %g8
	call	o_param_a.2683
	fsqrt	%f0, %f0
	fmul	%f2, %f1, %f0
	fldi	%f1, %g7, -8
	mov	%g5, %g8
	call	o_param_z.2695
	fsub	%f1, %f1, %f0
	mov	%g5, %g8
	call	o_param_c.2687
	fsqrt	%f0, %f0
	fmul	%f3, %f1, %f0
	fmov	%f0, %f2
	call	fsqr.2543
	fmov	%f1, %f0
	fmov	%f0, %f3
	call	fsqr.2543
	fadd	%f7, %f1, %f0
	fmov	%f1, %f2
	call	fabs.2535
	fmov	%f1, %f0
	fmvhi	%f6, 14545
	fmvlo	%f6, 46863
	fmov	%f0, %f6
	call	fless.2523
	addi	%g1, %g1, 12
	jne	%g5, %g0, jeq_else.7905
	fdiv	%f1, %f3, %f2
	subi	%g1, %g1, 12
	call	fabs.2535
	call	atan.2552
	addi	%g1, %g1, 12
	fmul	%f0, %f0, %f31
	fdiv	%f0, %f0, %f24
	jmp	jeq_cont.7906
jeq_else.7905:
	fmov	%f0, %f30
jeq_cont.7906:
	fsti	%f0, %g1, 8
	subi	%g1, %g1, 16
	call	min_caml_floor
	addi	%g1, %g1, 16
	fmov	%f1, %f0
	fldi	%f0, %g1, 8
	fsub	%f8, %f0, %f1
	fldi	%f1, %g7, -4
	mov	%g5, %g8
	subi	%g1, %g1, 16
	call	o_param_y.2693
	fsub	%f1, %f1, %f0
	mov	%g5, %g8
	call	o_param_b.2685
	fsqrt	%f0, %f0
	fmul	%f2, %f1, %f0
	fmov	%f1, %f7
	call	fabs.2535
	fmov	%f1, %f0
	fmov	%f0, %f6
	call	fless.2523
	addi	%g1, %g1, 16
	jne	%g5, %g0, jeq_else.7907
	fdiv	%f1, %f2, %f7
	subi	%g1, %g1, 16
	call	fabs.2535
	call	atan.2552
	addi	%g1, %g1, 16
	fmul	%f0, %f0, %f31
	fdiv	%f0, %f0, %f24
	jmp	jeq_cont.7908
jeq_else.7907:
	fmov	%f0, %f30
jeq_cont.7908:
	fsti	%f0, %g1, 12
	subi	%g1, %g1, 20
	call	min_caml_floor
	addi	%g1, %g1, 20
	fmov	%f1, %f0
	fldi	%f0, %g1, 12
	fsub	%f1, %f0, %f1
	fmvhi	%f2, 15897
	fmvlo	%f2, 39321
	fsub	%f0, %f19, %f8
	subi	%g1, %g1, 20
	call	fsqr.2543
	fsub	%f2, %f2, %f0
	fsub	%f0, %f19, %f1
	call	fsqr.2543
	fsub	%f1, %f2, %f0
	fmov	%f0, %f1
	call	fisneg.2528
	addi	%g1, %g1, 20
	jne	%g5, %g0, jeq_else.7909
	fmov	%f0, %f1
	jmp	jeq_cont.7910
jeq_else.7909:
	fmov	%f0, %f16
jeq_cont.7910:
	fmul	%f1, %f18, %f0
	fmvhi	%f0, 16025
	fmvlo	%f0, 39321
	fdiv	%f0, %f1, %f0
	fsti	%f0, %g0, -1352
	return
jeq_else.7904:
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f0, %f4, %f3]
! ret type = Unit
!---------------------------------------------------------------------
add_light.2945:
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fispos.2526
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7913
	jmp	jeq_cont.7914
jeq_else.7913:
	subi	%g5, %g0, -1344
	subi	%g6, %g0, -1320
	fldi	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	vecaccum.2656
	addi	%g1, %g1, 8
jeq_cont.7914:
	fmov	%f0, %f4
	subi	%g1, %g1, 8
	call	fispos.2526
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7915
	return
jeq_else.7915:
	fmov	%f0, %f4
	subi	%g1, %g1, 8
	call	fsqr.2543
	call	fsqr.2543
	addi	%g1, %g1, 8
	fmul	%f0, %f0, %f3
	fldi	%f1, %g0, -1320
	fadd	%f1, %f1, %f0
	fsti	%f1, %g0, -1320
	fldi	%f1, %g0, -1324
	fadd	%f1, %f1, %f0
	fsti	%f1, %g0, -1324
	fldi	%f1, %g0, -1328
	fadd	%f0, %f1, %f0
	fsti	%f0, %g0, -1328
	return

!---------------------------------------------------------------------
! args = [%g21, %g23]
! fargs = [%f13, %f12]
! ret type = Unit
!---------------------------------------------------------------------
trace_reflections.2949:
	jlt	%g21, %g0, jge_else.7918
	slli	%g5, %g21, 2
	ldi	%g22, %g5, -196
	mov	%g5, %g22
	subi	%g1, %g1, 4
	call	r_dvec.2740
	mov	%g24, %g5
	mov	%g13, %g24
	call	judge_intersection_fast.2931
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7919
	jmp	jeq_cont.7920
jeq_else.7919:
	ldi	%g5, %g0, -1368
	slli	%g6, %g5, 2
	ldi	%g5, %g0, -1388
	add	%g6, %g6, %g5
	mov	%g5, %g22
	subi	%g1, %g1, 4
	call	r_surface_id.2738
	addi	%g1, %g1, 4
	jne	%g6, %g5, jeq_else.7921
	addi	%g14, %g0, 0
	ldi	%g15, %g0, -1396
	subi	%g1, %g1, 4
	call	shadow_check_one_or_matrix.2902
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.7923
	mov	%g5, %g24
	subi	%g1, %g1, 4
	call	d_vec.2734
	addi	%g1, %g1, 4
	subi	%g6, %g0, -1356
	sti	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	veciprod.2648
	addi	%g1, %g1, 8
	fsti	%f0, %g1, 4
	mov	%g5, %g22
	subi	%g1, %g1, 12
	call	r_bright.2742
	addi	%g1, %g1, 12
	fmov	%f3, %f0
	fmul	%f1, %f3, %f13
	fldi	%f0, %g1, 4
	fmul	%f0, %f1, %f0
	ldi	%g5, %g1, 0
	fsti	%f0, %g1, 8
	mov	%g6, %g23
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
	jmp	jeq_cont.7924
jeq_else.7923:
jeq_cont.7924:
	jmp	jeq_cont.7922
jeq_else.7921:
jeq_cont.7922:
jeq_cont.7920:
	subi	%g21, %g21, 1
	jmp	trace_reflections.2949
jge_else.7918:
	return

!---------------------------------------------------------------------
! args = [%g25, %g23, %g26]
! fargs = [%f14, %f11]
! ret type = Unit
!---------------------------------------------------------------------
trace_ray.2954:
	addi	%g5, %g0, 4
	jlt	%g5, %g25, jle_else.7926
	mov	%g5, %g26
	subi	%g1, %g1, 4
	call	p_surface_ids.2719
	addi	%g1, %g1, 4
	mov	%g27, %g5
	fsti	%f11, %g1, 0
	mov	%g15, %g23
	subi	%g1, %g1, 8
	call	judge_intersection.2917
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7927
	addi	%g6, %g0, -1
	slli	%g5, %g25, 2
	st	%g6, %g27, %g5
	jne	%g25, %g0, jeq_else.7928
	return
jeq_else.7928:
	subi	%g5, %g0, -1604
	mov	%g6, %g23
	subi	%g1, %g1, 8
	call	veciprod.2648
	call	fneg.2539
	addi	%g1, %g1, 8
	fsti	%f0, %g1, 4
	subi	%g1, %g1, 12
	call	fispos.2526
	addi	%g1, %g1, 12
	jne	%g5, %g0, jeq_else.7930
	return
jeq_else.7930:
	fldi	%f0, %g1, 4
	subi	%g1, %g1, 12
	call	fsqr.2543
	addi	%g1, %g1, 12
	fmov	%f1, %f0
	fldi	%f0, %g1, 4
	fmul	%f0, %f1, %f0
	fmul	%f1, %f0, %f14
	fldi	%f0, %g0, -1600
	fmul	%f0, %f1, %f0
	fldi	%f1, %g0, -1320
	fadd	%f1, %f1, %f0
	fsti	%f1, %g0, -1320
	fldi	%f1, %g0, -1324
	fadd	%f1, %f1, %f0
	fsti	%f1, %g0, -1324
	fldi	%f1, %g0, -1328
	fadd	%f0, %f1, %f0
	fsti	%f0, %g0, -1328
	return
jeq_else.7927:
	ldi	%g10, %g0, -1368
	slli	%g5, %g10, 2
	ldi	%g8, %g5, -1640
	mov	%g5, %g8
	subi	%g1, %g1, 12
	call	o_reflectiontype.2677
	mov	%g28, %g5
	mov	%g5, %g8
	call	o_diffuse.2697
	fmov	%f10, %f0
	fmul	%f13, %f10, %f14
	mov	%g6, %g23
	mov	%g5, %g8
	call	get_nvector.2939
	subi	%g5, %g0, -1372
	subi	%g6, %g0, -1288
	call	veccpy.2637
	addi	%g1, %g1, 12
	subi	%g7, %g0, -1372
	sti	%g8, %g1, 8
	subi	%g1, %g1, 16
	call	utexture.2942
	slli	%g6, %g10, 2
	ldi	%g5, %g0, -1388
	add	%g6, %g6, %g5
	slli	%g5, %g25, 2
	st	%g6, %g27, %g5
	mov	%g5, %g26
	call	p_intersection_points.2717
	slli	%g6, %g25, 2
	ld	%g6, %g5, %g6
	subi	%g5, %g0, -1372
	call	veccpy.2637
	mov	%g5, %g26
	call	p_calc_diffuse.2721
	addi	%g1, %g1, 16
	sti	%g5, %g1, 12
	fmov	%f0, %f19
	fmov	%f1, %f10
	subi	%g1, %g1, 20
	call	fless.2523
	addi	%g1, %g1, 20
	mov	%g6, %g5
	jne	%g6, %g0, jeq_else.7933
	addi	%g7, %g0, 1
	slli	%g6, %g25, 2
	ldi	%g5, %g1, 12
	st	%g7, %g5, %g6
	mov	%g5, %g26
	subi	%g1, %g1, 20
	call	p_energy.2723
	mov	%g7, %g5
	slli	%g5, %g25, 2
	ld	%g6, %g7, %g5
	subi	%g5, %g0, -1344
	call	veccpy.2637
	slli	%g5, %g25, 2
	ld	%g5, %g7, %g5
	fmvhi	%f0, 15232
	fmvlo	%f0, 0
	fmul	%f0, %f0, %f13
	call	vecscale.2666
	mov	%g5, %g26
	call	p_nvectors.2732
	slli	%g6, %g25, 2
	ld	%g6, %g5, %g6
	subi	%g5, %g0, -1356
	call	veccpy.2637
	addi	%g1, %g1, 20
	jmp	jeq_cont.7934
jeq_else.7933:
	addi	%g7, %g0, 0
	slli	%g6, %g25, 2
	ldi	%g5, %g1, 12
	st	%g7, %g5, %g6
jeq_cont.7934:
	fmvhi	%f3, 49152
	fmvlo	%f3, 0
	subi	%g5, %g0, -1356
	mov	%g6, %g23
	subi	%g1, %g1, 20
	call	veciprod.2648
	fmul	%f0, %f3, %f0
	subi	%g5, %g0, -1356
	mov	%g6, %g23
	call	vecaccum.2656
	addi	%g1, %g1, 20
	ldi	%g8, %g1, 8
	mov	%g5, %g8
	subi	%g1, %g1, 20
	call	o_hilight.2699
	fmul	%f12, %f14, %f0
	addi	%g14, %g0, 0
	ldi	%g15, %g0, -1396
	call	shadow_check_one_or_matrix.2902
	addi	%g1, %g1, 20
	jne	%g5, %g0, jeq_else.7935
	subi	%g5, %g0, -1604
	subi	%g6, %g0, -1356
	subi	%g1, %g1, 20
	call	veciprod.2648
	call	fneg.2539
	fmul	%f5, %f0, %f13
	subi	%g5, %g0, -1604
	mov	%g6, %g23
	call	veciprod.2648
	call	fneg.2539
	fmov	%f4, %f0
	fmov	%f3, %f12
	fmov	%f0, %f5
	call	add_light.2945
	addi	%g1, %g1, 20
	jmp	jeq_cont.7936
jeq_else.7935:
jeq_cont.7936:
	subi	%g8, %g0, -1372
	subi	%g1, %g1, 20
	call	setup_startp.2868
	addi	%g1, %g1, 20
	ldi	%g5, %g0, -192
	subi	%g21, %g5, 1
	sti	%g23, %g1, 16
	fsti	%f10, %g1, 20
	subi	%g1, %g1, 28
	call	trace_reflections.2949
	fmov	%f0, %f14
	fmov	%f1, %f23
	call	fless.2523
	addi	%g1, %g1, 28
	jne	%g5, %g0, jeq_else.7937
	return
jeq_else.7937:
	addi	%g5, %g0, 4
	jlt	%g25, %g5, jle_else.7939
	jmp	jle_cont.7940
jle_else.7939:
	addi	%g5, %g25, 1
	addi	%g6, %g0, -1
	slli	%g5, %g5, 2
	st	%g6, %g27, %g5
jle_cont.7940:
	addi	%g5, %g0, 2
	jne	%g28, %g5, jeq_else.7941
	fldi	%f10, %g1, 20
	fsub	%f0, %f17, %f10
	fmul	%f14, %f14, %f0
	addi	%g25, %g25, 1
	fldi	%f0, %g0, -1384
	fldi	%f11, %g1, 0
	fadd	%f11, %f11, %f0
	ldi	%g23, %g1, 16
	jmp	trace_ray.2954
jeq_else.7941:
	return
jle_else.7926:
	return

!---------------------------------------------------------------------
! args = [%g13]
! fargs = [%f12]
! ret type = Unit
!---------------------------------------------------------------------
trace_diffuse_ray.2960:
	sti	%g13, %g1, 0
	subi	%g1, %g1, 8
	call	judge_intersection_fast.2931
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7944
	return
jeq_else.7944:
	ldi	%g5, %g0, -1368
	slli	%g5, %g5, 2
	ldi	%g16, %g5, -1640
	ldi	%g13, %g1, 0
	mov	%g5, %g13
	subi	%g1, %g1, 8
	call	d_vec.2734
	mov	%g6, %g5
	mov	%g5, %g16
	call	get_nvector.2939
	subi	%g7, %g0, -1372
	mov	%g8, %g16
	call	utexture.2942
	addi	%g14, %g0, 0
	ldi	%g15, %g0, -1396
	call	shadow_check_one_or_matrix.2902
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7946
	subi	%g5, %g0, -1604
	subi	%g6, %g0, -1356
	subi	%g1, %g1, 8
	call	veciprod.2648
	call	fneg.2539
	addi	%g1, %g1, 8
	fsti	%f0, %g1, 4
	subi	%g1, %g1, 12
	call	fispos.2526
	addi	%g1, %g1, 12
	jne	%g5, %g0, jeq_else.7947
	fmov	%f1, %f16
	jmp	jeq_cont.7948
jeq_else.7947:
	fldi	%f0, %g1, 4
	fmov	%f1, %f0
jeq_cont.7948:
	fmul	%f1, %f12, %f1
	mov	%g5, %g16
	subi	%g1, %g1, 12
	call	o_diffuse.2697
	addi	%g1, %g1, 12
	fmul	%f0, %f1, %f0
	subi	%g5, %g0, -1344
	subi	%g6, %g0, -1332
	jmp	vecaccum.2656
jeq_else.7946:
	return

!---------------------------------------------------------------------
! args = [%g24, %g23, %g22, %g21]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
iter_trace_diffuse_rays.2963:
	jlt	%g21, %g0, jge_else.7950
	slli	%g5, %g21, 2
	ld	%g5, %g24, %g5
	subi	%g1, %g1, 4
	call	d_vec.2734
	mov	%g6, %g5
	mov	%g5, %g23
	call	veciprod.2648
	addi	%g1, %g1, 4
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	fisneg.2528
	addi	%g1, %g1, 8
	jne	%g5, %g0, jeq_else.7951
	slli	%g5, %g21, 2
	ld	%g13, %g24, %g5
	fmvhi	%f1, 17174
	fmvlo	%f1, 0
	fldi	%f0, %g1, 0
	fdiv	%f12, %f0, %f1
	subi	%g1, %g1, 8
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 8
	jmp	jeq_cont.7952
jeq_else.7951:
	addi	%g5, %g21, 1
	slli	%g5, %g5, 2
	ld	%g13, %g24, %g5
	fmvhi	%f1, 49942
	fmvlo	%f1, 0
	fldi	%f0, %g1, 0
	fdiv	%f12, %f0, %f1
	subi	%g1, %g1, 8
	call	trace_diffuse_ray.2960
	addi	%g1, %g1, 8
jeq_cont.7952:
	subi	%g21, %g21, 2
	jmp	iter_trace_diffuse_rays.2963
jge_else.7950:
	return

!---------------------------------------------------------------------
! args = [%g24, %g23, %g22]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
trace_diffuse_rays.2968:
	mov	%g8, %g22
	subi	%g1, %g1, 4
	call	setup_startp.2868
	addi	%g1, %g1, 4
	addi	%g21, %g0, 118
	jmp	iter_trace_diffuse_rays.2963

!---------------------------------------------------------------------
! args = [%g25, %g23, %g22]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
trace_diffuse_ray_80percent.2972:
	sti	%g22, %g1, 0
	sti	%g23, %g1, 4
	jne	%g25, %g0, jeq_else.7954
	jmp	jeq_cont.7955
jeq_else.7954:
	ldi	%g24, %g0, -1196
	subi	%g1, %g1, 12
	call	trace_diffuse_rays.2968
	addi	%g1, %g1, 12
jeq_cont.7955:
	jne	%g25, %g3, jeq_else.7956
	jmp	jeq_cont.7957
jeq_else.7956:
	ldi	%g24, %g0, -1200
	ldi	%g23, %g1, 4
	ldi	%g22, %g1, 0
	subi	%g1, %g1, 12
	call	trace_diffuse_rays.2968
	addi	%g1, %g1, 12
jeq_cont.7957:
	addi	%g5, %g0, 2
	jne	%g25, %g5, jeq_else.7958
	jmp	jeq_cont.7959
jeq_else.7958:
	ldi	%g24, %g0, -1204
	ldi	%g23, %g1, 4
	ldi	%g22, %g1, 0
	subi	%g1, %g1, 12
	call	trace_diffuse_rays.2968
	addi	%g1, %g1, 12
jeq_cont.7959:
	addi	%g5, %g0, 3
	jne	%g25, %g5, jeq_else.7960
	jmp	jeq_cont.7961
jeq_else.7960:
	ldi	%g24, %g0, -1208
	ldi	%g23, %g1, 4
	ldi	%g22, %g1, 0
	subi	%g1, %g1, 12
	call	trace_diffuse_rays.2968
	addi	%g1, %g1, 12
jeq_cont.7961:
	addi	%g5, %g0, 4
	jne	%g25, %g5, jeq_else.7962
	return
jeq_else.7962:
	ldi	%g24, %g0, -1212
	ldi	%g23, %g1, 4
	ldi	%g22, %g1, 0
	jmp	trace_diffuse_rays.2968

!---------------------------------------------------------------------
! args = [%g5, %g26]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
calc_diffuse_using_1point.2976:
	sti	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	p_received_ray_20percent.2725
	addi	%g1, %g1, 8
	mov	%g6, %g5
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	p_nvectors.2732
	addi	%g1, %g1, 8
	mov	%g8, %g5
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	p_intersection_points.2717
	addi	%g1, %g1, 8
	mov	%g9, %g5
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	p_energy.2723
	mov	%g27, %g5
	slli	%g7, %g26, 2
	ld	%g7, %g6, %g7
	subi	%g6, %g0, -1332
	mov	%g5, %g7
	call	veccpy.2637
	addi	%g1, %g1, 8
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	p_group_id.2727
	mov	%g25, %g5
	slli	%g5, %g26, 2
	ld	%g23, %g8, %g5
	slli	%g5, %g26, 2
	ld	%g22, %g9, %g5
	call	trace_diffuse_ray_80percent.2972
	addi	%g1, %g1, 8
	slli	%g5, %g26, 2
	ld	%g6, %g27, %g5
	subi	%g5, %g0, -1332
	subi	%g7, %g0, -1320
	jmp	vecaccumv.2669

!---------------------------------------------------------------------
! args = [%g7, %g5, %g9, %g6, %g8]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
calc_diffuse_using_5points.2979:
	slli	%g10, %g7, 2
	ld	%g5, %g5, %g10
	subi	%g1, %g1, 4
	call	p_received_ray_20percent.2725
	mov	%g10, %g5
	subi	%g5, %g7, 1
	slli	%g5, %g5, 2
	ld	%g5, %g9, %g5
	call	p_received_ray_20percent.2725
	mov	%g12, %g5
	slli	%g5, %g7, 2
	ld	%g5, %g9, %g5
	call	p_received_ray_20percent.2725
	mov	%g14, %g5
	addi	%g5, %g7, 1
	slli	%g5, %g5, 2
	ld	%g5, %g9, %g5
	call	p_received_ray_20percent.2725
	mov	%g11, %g5
	slli	%g5, %g7, 2
	ld	%g5, %g6, %g5
	call	p_received_ray_20percent.2725
	mov	%g13, %g5
	slli	%g5, %g8, 2
	ld	%g5, %g10, %g5
	subi	%g6, %g0, -1332
	call	veccpy.2637
	slli	%g5, %g8, 2
	ld	%g5, %g12, %g5
	subi	%g6, %g0, -1332
	call	vecadd.2660
	slli	%g5, %g8, 2
	ld	%g5, %g14, %g5
	subi	%g6, %g0, -1332
	call	vecadd.2660
	slli	%g5, %g8, 2
	ld	%g5, %g11, %g5
	subi	%g6, %g0, -1332
	call	vecadd.2660
	slli	%g5, %g8, 2
	ld	%g5, %g13, %g5
	subi	%g6, %g0, -1332
	call	vecadd.2660
	slli	%g5, %g7, 2
	ld	%g5, %g9, %g5
	call	p_energy.2723
	addi	%g1, %g1, 4
	slli	%g6, %g8, 2
	ld	%g6, %g5, %g6
	subi	%g5, %g0, -1332
	subi	%g7, %g0, -1320
	jmp	vecaccumv.2669

!---------------------------------------------------------------------
! args = [%g5, %g26]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
do_without_neighbors.2985:
	addi	%g6, %g0, 4
	jlt	%g6, %g26, jle_else.7964
	sti	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	p_surface_ids.2719
	addi	%g1, %g1, 8
	mov	%g6, %g5
	slli	%g7, %g26, 2
	ld	%g6, %g6, %g7
	jlt	%g6, %g0, jge_else.7965
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	p_calc_diffuse.2721
	addi	%g1, %g1, 8
	mov	%g6, %g5
	slli	%g7, %g26, 2
	ld	%g6, %g6, %g7
	sti	%g26, %g1, 4
	jne	%g6, %g0, jeq_else.7966
	jmp	jeq_cont.7967
jeq_else.7966:
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 12
	call	calc_diffuse_using_1point.2976
	addi	%g1, %g1, 12
jeq_cont.7967:
	ldi	%g26, %g1, 4
	addi	%g26, %g26, 1
	ldi	%g5, %g1, 0
	jmp	do_without_neighbors.2985
jge_else.7965:
	return
jle_else.7964:
	return

!---------------------------------------------------------------------
! args = [%g7, %g6, %g5]
! fargs = []
! ret type = Bool
!---------------------------------------------------------------------
neighbors_exist.2988:
	ldi	%g8, %g0, -1316
	addi	%g5, %g6, 1
	jlt	%g5, %g8, jle_else.7970
	addi	%g5, %g0, 0
	return
jle_else.7970:
	jlt	%g0, %g6, jle_else.7971
	addi	%g5, %g0, 0
	return
jle_else.7971:
	ldi	%g6, %g0, -1312
	addi	%g5, %g7, 1
	jlt	%g5, %g6, jle_else.7972
	addi	%g5, %g0, 0
	return
jle_else.7972:
	jlt	%g0, %g7, jle_else.7973
	addi	%g5, %g0, 0
	return
jle_else.7973:
	addi	%g5, %g0, 1
	return

!---------------------------------------------------------------------
! args = [%g5, %g6]
! fargs = []
! ret type = Int
!---------------------------------------------------------------------
get_surface_id.2992:
	subi	%g1, %g1, 4
	call	p_surface_ids.2719
	addi	%g1, %g1, 4
	slli	%g6, %g6, 2
	ld	%g5, %g5, %g6
	return

!---------------------------------------------------------------------
! args = [%g7, %g8, %g10, %g9, %g6]
! fargs = []
! ret type = Bool
!---------------------------------------------------------------------
neighbors_are_available.2995:
	slli	%g5, %g7, 2
	ld	%g5, %g10, %g5
	sti	%g6, %g1, 0
	subi	%g1, %g1, 8
	call	get_surface_id.2992
	addi	%g1, %g1, 8
	mov	%g11, %g5
	slli	%g5, %g7, 2
	ld	%g5, %g8, %g5
	ldi	%g6, %g1, 0
	subi	%g1, %g1, 8
	call	get_surface_id.2992
	addi	%g1, %g1, 8
	jne	%g5, %g11, jeq_else.7974
	slli	%g5, %g7, 2
	ld	%g5, %g9, %g5
	ldi	%g6, %g1, 0
	subi	%g1, %g1, 8
	call	get_surface_id.2992
	addi	%g1, %g1, 8
	jne	%g5, %g11, jeq_else.7975
	subi	%g5, %g7, 1
	slli	%g5, %g5, 2
	ld	%g5, %g10, %g5
	ldi	%g6, %g1, 0
	subi	%g1, %g1, 8
	call	get_surface_id.2992
	addi	%g1, %g1, 8
	jne	%g5, %g11, jeq_else.7976
	addi	%g5, %g7, 1
	slli	%g5, %g5, 2
	ld	%g5, %g10, %g5
	ldi	%g6, %g1, 0
	subi	%g1, %g1, 8
	call	get_surface_id.2992
	addi	%g1, %g1, 8
	jne	%g5, %g11, jeq_else.7977
	addi	%g5, %g0, 1
	return
jeq_else.7977:
	addi	%g5, %g0, 0
	return
jeq_else.7976:
	addi	%g5, %g0, 0
	return
jeq_else.7975:
	addi	%g5, %g0, 0
	return
jeq_else.7974:
	addi	%g5, %g0, 0
	return

!---------------------------------------------------------------------
! args = [%g7, %g15, %g16, %g18, %g17, %g26]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
try_exploit_neighbors.3001:
	slli	%g5, %g7, 2
	ld	%g5, %g18, %g5
	addi	%g6, %g0, 4
	jlt	%g6, %g26, jle_else.7978
	sti	%g5, %g1, 0
	mov	%g6, %g26
	subi	%g1, %g1, 8
	call	get_surface_id.2992
	addi	%g1, %g1, 8
	mov	%g6, %g5
	jlt	%g6, %g0, jge_else.7979
	sti	%g7, %g1, 4
	mov	%g6, %g26
	mov	%g9, %g17
	mov	%g10, %g18
	mov	%g8, %g16
	subi	%g1, %g1, 12
	call	neighbors_are_available.2995
	addi	%g1, %g1, 12
	mov	%g6, %g5
	jne	%g6, %g0, jeq_else.7980
	ldi	%g7, %g1, 4
	slli	%g5, %g7, 2
	ld	%g5, %g18, %g5
	jmp	do_without_neighbors.2985
jeq_else.7980:
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 12
	call	p_calc_diffuse.2721
	addi	%g1, %g1, 12
	slli	%g6, %g26, 2
	ld	%g5, %g5, %g6
	jne	%g5, %g0, jeq_else.7981
	jmp	jeq_cont.7982
jeq_else.7981:
	ldi	%g7, %g1, 4
	mov	%g8, %g26
	mov	%g6, %g17
	mov	%g9, %g18
	mov	%g5, %g16
	subi	%g1, %g1, 12
	call	calc_diffuse_using_5points.2979
	addi	%g1, %g1, 12
jeq_cont.7982:
	addi	%g26, %g26, 1
	ldi	%g7, %g1, 4
	jmp	try_exploit_neighbors.3001
jge_else.7979:
	return
jle_else.7978:
	return

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
write_ppm_header.3008:
	addi	%g5, %g0, 80
	output	%g5
	addi	%g5, %g0, 51
	output	%g5
	addi	%g5, %g0, 10
	output	%g5
	ldi	%g10, %g0, -1312
	subi	%g1, %g1, 4
	call	print_int.2587
	addi	%g5, %g0, 32
	output	%g5
	ldi	%g10, %g0, -1316
	call	print_int.2587
	addi	%g5, %g0, 32
	output	%g5
	addi	%g10, %g0, 255
	call	print_int.2587
	addi	%g1, %g1, 4
	addi	%g5, %g0, 10
	output	%g5
	return

!---------------------------------------------------------------------
! args = []
! fargs = [%f0]
! ret type = Unit
!---------------------------------------------------------------------
write_rgb_element.3010:
	subi	%g1, %g1, 4
	call	min_caml_int_of_float
	addi	%g1, %g1, 4
	addi	%g10, %g0, 255
	jlt	%g10, %g5, jle_else.7985
	jlt	%g5, %g0, jge_else.7987
	mov	%g10, %g5
	jmp	jge_cont.7988
jge_else.7987:
	addi	%g10, %g0, 0
jge_cont.7988:
	jmp	jle_cont.7986
jle_else.7985:
	addi	%g10, %g0, 255
jle_cont.7986:
	jmp	print_int.2587

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
write_rgb.3012:
	fldi	%f0, %g0, -1320
	subi	%g1, %g1, 4
	call	write_rgb_element.3010
	addi	%g5, %g0, 32
	output	%g5
	fldi	%f0, %g0, -1324
	call	write_rgb_element.3010
	addi	%g5, %g0, 32
	output	%g5
	fldi	%f0, %g0, -1328
	call	write_rgb_element.3010
	addi	%g1, %g1, 4
	addi	%g5, %g0, 10
	output	%g5
	return

!---------------------------------------------------------------------
! args = [%g25, %g26]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
pretrace_diffuse_rays.3014:
	addi	%g5, %g0, 4
	jlt	%g5, %g26, jle_else.7989
	mov	%g6, %g26
	mov	%g5, %g25
	subi	%g1, %g1, 4
	call	get_surface_id.2992
	addi	%g1, %g1, 4
	jlt	%g5, %g0, jge_else.7990
	mov	%g5, %g25
	subi	%g1, %g1, 4
	call	p_calc_diffuse.2721
	addi	%g1, %g1, 4
	slli	%g6, %g26, 2
	ld	%g5, %g5, %g6
	jne	%g5, %g0, jeq_else.7991
	jmp	jeq_cont.7992
jeq_else.7991:
	mov	%g5, %g25
	subi	%g1, %g1, 4
	call	p_group_id.2727
	mov	%g7, %g5
	subi	%g5, %g0, -1332
	call	vecbzero.2635
	mov	%g5, %g25
	call	p_nvectors.2732
	addi	%g1, %g1, 4
	sti	%g5, %g1, 0
	mov	%g5, %g25
	subi	%g1, %g1, 8
	call	p_intersection_points.2717
	addi	%g1, %g1, 8
	mov	%g6, %g5
	slli	%g7, %g7, 2
	ldi	%g24, %g7, -1196
	slli	%g7, %g26, 2
	ldi	%g5, %g1, 0
	ld	%g23, %g5, %g7
	slli	%g5, %g26, 2
	ld	%g22, %g6, %g5
	subi	%g1, %g1, 8
	call	trace_diffuse_rays.2968
	mov	%g5, %g25
	call	p_received_ray_20percent.2725
	slli	%g6, %g26, 2
	ld	%g6, %g5, %g6
	subi	%g5, %g0, -1332
	call	veccpy.2637
	addi	%g1, %g1, 8
jeq_cont.7992:
	addi	%g26, %g26, 1
	jmp	pretrace_diffuse_rays.3014
jge_else.7990:
	return
jle_else.7989:
	return

!---------------------------------------------------------------------
! args = [%g31, %g29, %g27]
! fargs = [%f3, %f14, %f13]
! ret type = Unit
!---------------------------------------------------------------------
pretrace_pixels.3017:
	jlt	%g29, %g0, jge_else.7995
	fldi	%f4, %g0, -1300
	ldi	%g5, %g0, -1304
	sub	%g5, %g29, %g5
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fmul	%f0, %f4, %f0
	fldi	%f1, %g0, -1264
	fmul	%f1, %f0, %f1
	fadd	%f1, %f1, %f3
	fsti	%f1, %g0, -1228
	fldi	%f1, %g0, -1268
	fmul	%f1, %f0, %f1
	fadd	%f1, %f1, %f14
	fsti	%f1, %g0, -1232
	fldi	%f1, %g0, -1272
	fmul	%f0, %f0, %f1
	fadd	%f0, %f0, %f13
	fsti	%f0, %g0, -1236
	addi	%g7, %g0, 0
	subi	%g6, %g0, -1228
	call	vecunit_sgn.2645
	subi	%g5, %g0, -1320
	call	vecbzero.2635
	subi	%g5, %g0, -1616
	subi	%g6, %g0, -1288
	call	veccpy.2637
	addi	%g1, %g1, 4
	addi	%g25, %g0, 0
	slli	%g5, %g29, 2
	ld	%g26, %g31, %g5
	subi	%g23, %g0, -1228
	fsti	%f13, %g1, 0
	fsti	%f14, %g1, 4
	fsti	%f3, %g1, 8
	sti	%g27, %g1, 12
	fmov	%f11, %f16
	fmov	%f14, %f17
	subi	%g1, %g1, 20
	call	trace_ray.2954
	slli	%g5, %g29, 2
	ld	%g5, %g31, %g5
	call	p_rgb.2715
	mov	%g6, %g5
	subi	%g5, %g0, -1320
	call	veccpy.2637
	addi	%g1, %g1, 20
	slli	%g5, %g29, 2
	ld	%g5, %g31, %g5
	ldi	%g27, %g1, 12
	mov	%g6, %g27
	subi	%g1, %g1, 20
	call	p_set_group_id.2729
	slli	%g5, %g29, 2
	ld	%g25, %g31, %g5
	addi	%g26, %g0, 0
	call	pretrace_diffuse_rays.3014
	subi	%g29, %g29, 1
	addi	%g5, %g0, 1
	mov	%g6, %g27
	call	add_mod5.2624
	addi	%g1, %g1, 20
	fldi	%f3, %g1, 8
	fldi	%f14, %g1, 4
	fldi	%f13, %g1, 0
	mov	%g27, %g5
	jmp	pretrace_pixels.3017
jge_else.7995:
	return

!---------------------------------------------------------------------
! args = [%g31, %g5, %g27]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
pretrace_line.3024:
	fldi	%f3, %g0, -1300
	ldi	%g6, %g0, -1308
	sub	%g5, %g5, %g6
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fmul	%f0, %f3, %f0
	fldi	%f1, %g0, -1252
	fmul	%f2, %f0, %f1
	fldi	%f1, %g0, -1240
	fadd	%f3, %f2, %f1
	fldi	%f1, %g0, -1256
	fmul	%f2, %f0, %f1
	fldi	%f1, %g0, -1244
	fadd	%f14, %f2, %f1
	fldi	%f1, %g0, -1260
	fmul	%f1, %f0, %f1
	fldi	%f0, %g0, -1248
	fadd	%f13, %f1, %f0
	ldi	%g5, %g0, -1312
	subi	%g29, %g5, 1
	jmp	pretrace_pixels.3017

!---------------------------------------------------------------------
! args = [%g29, %g28, %g31, %g18, %g17]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
scan_pixel.3028:
	ldi	%g5, %g0, -1312
	jlt	%g29, %g5, jle_else.7997
	return
jle_else.7997:
	slli	%g5, %g29, 2
	ld	%g5, %g18, %g5
	subi	%g1, %g1, 4
	call	p_rgb.2715
	subi	%g6, %g0, -1320
	call	veccpy.2637
	mov	%g5, %g17
	mov	%g6, %g28
	mov	%g7, %g29
	call	neighbors_exist.2988
	addi	%g1, %g1, 4
	sti	%g17, %g1, 0
	sti	%g18, %g1, 4
	jne	%g5, %g0, jeq_else.7999
	slli	%g5, %g29, 2
	ld	%g5, %g18, %g5
	addi	%g26, %g0, 0
	subi	%g1, %g1, 12
	call	do_without_neighbors.2985
	addi	%g1, %g1, 12
	jmp	jeq_cont.8000
jeq_else.7999:
	addi	%g26, %g0, 0
	mov	%g16, %g31
	mov	%g15, %g28
	mov	%g7, %g29
	subi	%g1, %g1, 12
	call	try_exploit_neighbors.3001
	addi	%g1, %g1, 12
jeq_cont.8000:
	subi	%g1, %g1, 12
	call	write_rgb.3012
	addi	%g1, %g1, 12
	addi	%g29, %g29, 1
	ldi	%g18, %g1, 4
	ldi	%g17, %g1, 0
	jmp	scan_pixel.3028

!---------------------------------------------------------------------
! args = [%g28, %g31, %g18, %g17, %g27]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
scan_line.3034:
	ldi	%g5, %g0, -1316
	jlt	%g28, %g5, jle_else.8001
	return
jle_else.8001:
	subi	%g5, %g5, 1
	sti	%g27, %g1, 0
	sti	%g17, %g1, 4
	sti	%g18, %g1, 8
	sti	%g31, %g1, 12
	sti	%g28, %g1, 16
	jlt	%g28, %g5, jle_else.8003
	jmp	jle_cont.8004
jle_else.8003:
	addi	%g5, %g28, 1
	mov	%g31, %g17
	subi	%g1, %g1, 24
	call	pretrace_line.3024
	addi	%g1, %g1, 24
jle_cont.8004:
	addi	%g29, %g0, 0
	ldi	%g28, %g1, 16
	ldi	%g31, %g1, 12
	ldi	%g18, %g1, 8
	ldi	%g17, %g1, 4
	subi	%g1, %g1, 24
	call	scan_pixel.3028
	addi	%g1, %g1, 24
	ldi	%g28, %g1, 16
	addi	%g28, %g28, 1
	addi	%g5, %g0, 2
	ldi	%g27, %g1, 0
	mov	%g6, %g27
	subi	%g1, %g1, 24
	call	add_mod5.2624
	addi	%g1, %g1, 24
	ldi	%g18, %g1, 8
	ldi	%g17, %g1, 4
	ldi	%g31, %g1, 12
	mov	%g27, %g5
	mov	%g30, %g17
	mov	%g17, %g31
	mov	%g31, %g18
	mov	%g18, %g30
	jmp	scan_line.3034

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = Array(Array(Float))
!---------------------------------------------------------------------
create_float5x3array.3040:
	addi	%g5, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	mov	%g6, %g5
	addi	%g5, %g0, 5
	call	min_caml_create_array
	addi	%g1, %g1, 4
	addi	%g7, %g0, 3
	sti	%g5, %g1, 0
	mov	%g5, %g7
	fmov	%f0, %f16
	subi	%g1, %g1, 8
	call	min_caml_create_float_array
	addi	%g1, %g1, 8
	mov	%g6, %g5
	ldi	%g5, %g1, 0
	sti	%g6, %g5, -4
	addi	%g7, %g0, 3
	mov	%g5, %g7
	fmov	%f0, %f16
	subi	%g1, %g1, 8
	call	min_caml_create_float_array
	addi	%g1, %g1, 8
	mov	%g6, %g5
	ldi	%g5, %g1, 0
	sti	%g6, %g5, -8
	addi	%g7, %g0, 3
	mov	%g5, %g7
	fmov	%f0, %f16
	subi	%g1, %g1, 8
	call	min_caml_create_float_array
	addi	%g1, %g1, 8
	mov	%g6, %g5
	ldi	%g5, %g1, 0
	sti	%g6, %g5, -12
	addi	%g7, %g0, 3
	mov	%g5, %g7
	fmov	%f0, %f16
	subi	%g1, %g1, 8
	call	min_caml_create_float_array
	addi	%g1, %g1, 8
	mov	%g6, %g5
	ldi	%g5, %g1, 0
	sti	%g6, %g5, -16
	return

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = (Array(Float) * Array(Array(Float)) * Array(Int) * Array(Bool) * Array(Array(Float)) * Array(Array(Float)) * Array(Int) * Array(Array(Float)))
!---------------------------------------------------------------------
create_pixel.3042:
	addi	%g5, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	mov	%g9, %g5
	call	create_float5x3array.3040
	mov	%g11, %g5
	addi	%g5, %g0, 5
	addi	%g6, %g0, 0
	call	min_caml_create_array
	mov	%g8, %g5
	addi	%g5, %g0, 5
	addi	%g6, %g0, 0
	call	min_caml_create_array
	mov	%g14, %g5
	call	create_float5x3array.3040
	mov	%g13, %g5
	call	create_float5x3array.3040
	mov	%g10, %g5
	addi	%g5, %g0, 1
	addi	%g6, %g0, 0
	call	min_caml_create_array
	mov	%g12, %g5
	call	create_float5x3array.3040
	addi	%g1, %g1, 4
	mov	%g6, %g5
	mov	%g5, %g2
	addi	%g2, %g2, 32
	sti	%g6, %g5, -28
	sti	%g12, %g5, -24
	sti	%g10, %g5, -20
	sti	%g13, %g5, -16
	sti	%g14, %g5, -12
	sti	%g8, %g5, -8
	sti	%g11, %g5, -4
	sti	%g9, %g5, 0
	return

!---------------------------------------------------------------------
! args = [%g15, %g16]
! fargs = []
! ret type = Array((Array(Float) * Array(Array(Float)) * Array(Int) * Array(Bool) * Array(Array(Float)) * Array(Array(Float)) * Array(Int) * Array(Array(Float))))
!---------------------------------------------------------------------
init_line_elements.3044:
	jlt	%g16, %g0, jge_else.8005
	subi	%g1, %g1, 4
	call	create_pixel.3042
	addi	%g1, %g1, 4
	slli	%g6, %g16, 2
	st	%g5, %g15, %g6
	subi	%g16, %g16, 1
	jmp	init_line_elements.3044
jge_else.8005:
	mov	%g5, %g15
	return

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = Array((Array(Float) * Array(Array(Float)) * Array(Int) * Array(Bool) * Array(Array(Float)) * Array(Array(Float)) * Array(Int) * Array(Array(Float))))
!---------------------------------------------------------------------
create_pixelline.3047:
	ldi	%g5, %g0, -1312
	sti	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	create_pixel.3042
	addi	%g1, %g1, 8
	mov	%g6, %g5
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	min_caml_create_array
	addi	%g1, %g1, 8
	mov	%g15, %g5
	ldi	%g5, %g0, -1312
	subi	%g16, %g5, 2
	jmp	init_line_elements.3044

!---------------------------------------------------------------------
! args = []
! fargs = [%f0, %f6]
! ret type = Float
!---------------------------------------------------------------------
adjust_position.3049:
	fmul	%f0, %f0, %f0
	fadd	%f0, %f0, %f23
	fsqrt	%f7, %f0
	fdiv	%f0, %f17, %f7
	subi	%g1, %g1, 4
	call	atan.2552
	fmul	%f0, %f0, %f6
	call	tan.2554
	addi	%g1, %g1, 4
	fmul	%f0, %f0, %f7
	return

!---------------------------------------------------------------------
! args = [%g6, %g8, %g7]
! fargs = [%f1, %f8, %f10, %f9]
! ret type = Unit
!---------------------------------------------------------------------
calc_dirvec.3052:
	addi	%g5, %g0, 5
	jlt	%g6, %g5, jle_else.8006
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
	slli	%g5, %g8, 2
	ldi	%g6, %g5, -1196
	slli	%g5, %g7, 2
	ld	%g5, %g6, %g5
	call	d_vec.2734
	fmov	%f0, %f3
	fmov	%f1, %f4
	fmov	%f2, %f5
	call	vecset.2627
	addi	%g5, %g7, 40
	slli	%g5, %g5, 2
	ld	%g5, %g6, %g5
	call	d_vec.2734
	fmov	%f0, %f4
	call	fneg.2539
	fmov	%f7, %f0
	fmov	%f0, %f7
	fmov	%f1, %f3
	fmov	%f2, %f5
	call	vecset.2627
	addi	%g5, %g7, 80
	slli	%g5, %g5, 2
	ld	%g5, %g6, %g5
	call	d_vec.2734
	fmov	%f0, %f5
	call	fneg.2539
	fmov	%f6, %f0
	fmov	%f0, %f7
	fmov	%f1, %f6
	fmov	%f2, %f3
	call	vecset.2627
	addi	%g5, %g7, 1
	slli	%g5, %g5, 2
	ld	%g5, %g6, %g5
	call	d_vec.2734
	fmov	%f0, %f3
	call	fneg.2539
	fmov	%f3, %f0
	fmov	%f0, %f3
	fmov	%f1, %f7
	fmov	%f2, %f6
	call	vecset.2627
	addi	%g5, %g7, 41
	slli	%g5, %g5, 2
	ld	%g5, %g6, %g5
	call	d_vec.2734
	fmov	%f0, %f4
	fmov	%f1, %f3
	fmov	%f2, %f6
	call	vecset.2627
	addi	%g5, %g7, 81
	slli	%g5, %g5, 2
	ld	%g5, %g6, %g5
	call	d_vec.2734
	addi	%g1, %g1, 4
	fmov	%f0, %f4
	fmov	%f1, %f5
	fmov	%f2, %f3
	jmp	vecset.2627
jle_else.8006:
	fmov	%f6, %f10
	fmov	%f0, %f8
	subi	%g1, %g1, 4
	call	adjust_position.3049
	addi	%g1, %g1, 4
	addi	%g6, %g6, 1
	fsti	%f0, %g1, 0
	fmov	%f6, %f9
	subi	%g1, %g1, 8
	call	adjust_position.3049
	addi	%g1, %g1, 8
	fmov	%f8, %f0
	fldi	%f0, %g1, 0
	fmov	%f1, %f0
	jmp	calc_dirvec.3052

!---------------------------------------------------------------------
! args = [%g10, %g8, %g9]
! fargs = [%f9]
! ret type = Unit
!---------------------------------------------------------------------
calc_dirvecs.3060:
	jlt	%g10, %g0, jge_else.8007
	mov	%g5, %g10
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fmul	%f11, %f0, %f29
	fsub	%f10, %f11, %f28
	addi	%g6, %g0, 0
	fsti	%f9, %g1, 0
	sti	%g8, %g1, 4
	mov	%g7, %g9
	fmov	%f8, %f16
	fmov	%f1, %f16
	subi	%g1, %g1, 12
	call	calc_dirvec.3052
	addi	%g1, %g1, 12
	fadd	%f10, %f11, %f23
	addi	%g6, %g0, 0
	addi	%g7, %g9, 2
	fldi	%f9, %g1, 0
	ldi	%g8, %g1, 4
	fmov	%f8, %f16
	fmov	%f1, %f16
	subi	%g1, %g1, 12
	call	calc_dirvec.3052
	addi	%g1, %g1, 12
	subi	%g10, %g10, 1
	addi	%g5, %g0, 1
	ldi	%g8, %g1, 4
	mov	%g6, %g8
	subi	%g1, %g1, 12
	call	add_mod5.2624
	addi	%g1, %g1, 12
	fldi	%f9, %g1, 0
	mov	%g8, %g5
	jmp	calc_dirvecs.3060
jge_else.8007:
	return

!---------------------------------------------------------------------
! args = [%g11, %g8, %g9]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
calc_dirvec_rows.3065:
	jlt	%g11, %g0, jge_else.8009
	mov	%g5, %g11
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	addi	%g1, %g1, 4
	fmul	%f0, %f0, %f29
	fsub	%f9, %f0, %f28
	addi	%g10, %g0, 4
	sti	%g9, %g1, 0
	sti	%g8, %g1, 4
	subi	%g1, %g1, 12
	call	calc_dirvecs.3060
	addi	%g1, %g1, 12
	subi	%g11, %g11, 1
	addi	%g5, %g0, 2
	ldi	%g8, %g1, 4
	mov	%g6, %g8
	subi	%g1, %g1, 12
	call	add_mod5.2624
	addi	%g1, %g1, 12
	ldi	%g9, %g1, 0
	addi	%g9, %g9, 4
	mov	%g8, %g5
	jmp	calc_dirvec_rows.3065
jge_else.8009:
	return

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = (Array(Float) * Array(Array(Float)))
!---------------------------------------------------------------------
create_dirvec.3069:
	addi	%g5, %g0, 3
	fmov	%f0, %f16
	subi	%g1, %g1, 4
	call	min_caml_create_float_array
	addi	%g1, %g1, 4
	mov	%g6, %g5
	ldi	%g5, %g0, -1884
	sti	%g6, %g1, 0
	subi	%g1, %g1, 8
	call	min_caml_create_array
	addi	%g1, %g1, 8
	mov	%g7, %g5
	mov	%g5, %g2
	addi	%g2, %g2, 8
	sti	%g7, %g5, -4
	ldi	%g6, %g1, 0
	sti	%g6, %g5, 0
	return

!---------------------------------------------------------------------
! args = [%g9, %g8]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
create_dirvec_elements.3071:
	jlt	%g8, %g0, jge_else.8011
	subi	%g1, %g1, 4
	call	create_dirvec.3069
	addi	%g1, %g1, 4
	slli	%g6, %g8, 2
	st	%g5, %g9, %g6
	subi	%g8, %g8, 1
	jmp	create_dirvec_elements.3071
jge_else.8011:
	return

!---------------------------------------------------------------------
! args = [%g10]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
create_dirvecs.3074:
	jlt	%g10, %g0, jge_else.8013
	addi	%g5, %g0, 120
	sti	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	create_dirvec.3069
	addi	%g1, %g1, 8
	mov	%g6, %g5
	ldi	%g5, %g1, 0
	subi	%g1, %g1, 8
	call	min_caml_create_array
	slli	%g6, %g10, 2
	sti	%g5, %g6, -1196
	slli	%g5, %g10, 2
	ldi	%g9, %g5, -1196
	addi	%g8, %g0, 118
	call	create_dirvec_elements.3071
	addi	%g1, %g1, 8
	subi	%g10, %g10, 1
	jmp	create_dirvecs.3074
jge_else.8013:
	return

!---------------------------------------------------------------------
! args = [%g14, %g13]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
init_dirvec_constants.3076:
	jlt	%g13, %g0, jge_else.8015
	slli	%g5, %g13, 2
	ld	%g11, %g14, %g5
	subi	%g1, %g1, 4
	call	setup_dirvec_constants.2863
	addi	%g1, %g1, 4
	subi	%g13, %g13, 1
	jmp	init_dirvec_constants.3076
jge_else.8015:
	return

!---------------------------------------------------------------------
! args = [%g15]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
init_vecset_constants.3079:
	jlt	%g15, %g0, jge_else.8017
	slli	%g5, %g15, 2
	ldi	%g14, %g5, -1196
	addi	%g13, %g0, 119
	subi	%g1, %g1, 4
	call	init_dirvec_constants.3076
	addi	%g1, %g1, 4
	subi	%g15, %g15, 1
	jmp	init_vecset_constants.3079
jge_else.8017:
	return

!---------------------------------------------------------------------
! args = []
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
init_dirvecs.3081:
	addi	%g10, %g0, 4
	subi	%g1, %g1, 4
	call	create_dirvecs.3074
	addi	%g11, %g0, 9
	addi	%g8, %g0, 0
	addi	%g9, %g0, 0
	call	calc_dirvec_rows.3065
	addi	%g1, %g1, 4
	addi	%g15, %g0, 4
	jmp	init_vecset_constants.3079

!---------------------------------------------------------------------
! args = [%g14, %g13]
! fargs = [%f9, %f2, %f1, %f0]
! ret type = Unit
!---------------------------------------------------------------------
add_reflection.3083:
	fsti	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	create_dirvec.3069
	mov	%g11, %g5
	mov	%g5, %g11
	call	d_vec.2734
	addi	%g1, %g1, 8
	fldi	%f0, %g1, 0
	subi	%g1, %g1, 8
	call	vecset.2627
	addi	%g1, %g1, 8
	sti	%g11, %g1, 4
	subi	%g1, %g1, 12
	call	setup_dirvec_constants.2863
	addi	%g1, %g1, 12
	mov	%g5, %g2
	addi	%g2, %g2, 12
	fsti	%f9, %g5, -8
	ldi	%g11, %g1, 4
	sti	%g11, %g5, -4
	sti	%g13, %g5, 0
	slli	%g6, %g14, 2
	sti	%g5, %g6, -196
	return

!---------------------------------------------------------------------
! args = [%g5, %g6]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
setup_rect_reflection.3090:
	slli	%g16, %g5, 2
	ldi	%g15, %g0, -192
	mov	%g5, %g6
	subi	%g1, %g1, 4
	call	o_diffuse.2697
	fsub	%f9, %f17, %f0
	fldi	%f2, %g0, -1604
	fmov	%f0, %f2
	call	fneg.2539
	fmov	%f11, %f0
	fldi	%f0, %g0, -1608
	call	fneg.2539
	fmov	%f10, %f0
	fldi	%f0, %g0, -1612
	call	fneg.2539
	addi	%g1, %g1, 4
	addi	%g13, %g16, 1
	fsti	%f0, %g1, 0
	fsti	%f9, %g1, 4
	mov	%g14, %g15
	fmov	%f1, %f10
	subi	%g1, %g1, 12
	call	add_reflection.3083
	addi	%g1, %g1, 12
	addi	%g14, %g15, 1
	addi	%g13, %g16, 2
	fldi	%f1, %g0, -1608
	fldi	%f9, %g1, 4
	fldi	%f0, %g1, 0
	fmov	%f2, %f11
	subi	%g1, %g1, 12
	call	add_reflection.3083
	addi	%g1, %g1, 12
	addi	%g14, %g15, 2
	addi	%g13, %g16, 3
	fldi	%f0, %g0, -1612
	fldi	%f9, %g1, 4
	fmov	%f1, %f10
	fmov	%f2, %f11
	subi	%g1, %g1, 12
	call	add_reflection.3083
	addi	%g1, %g1, 12
	addi	%g5, %g15, 3
	sti	%g5, %g0, -192
	return

!---------------------------------------------------------------------
! args = [%g5, %g7]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
setup_surface_reflection.3093:
	slli	%g5, %g5, 2
	addi	%g13, %g5, 1
	ldi	%g14, %g0, -192
	mov	%g5, %g7
	subi	%g1, %g1, 4
	call	o_diffuse.2697
	fsub	%f9, %f17, %f0
	mov	%g5, %g7
	call	o_param_abc.2689
	subi	%g6, %g0, -1604
	call	veciprod.2648
	fmov	%f3, %f0
	mov	%g5, %g7
	call	o_param_a.2683
	fmul	%f0, %f20, %f0
	fmul	%f1, %f0, %f3
	fldi	%f0, %g0, -1604
	fsub	%f2, %f1, %f0
	mov	%g5, %g7
	call	o_param_b.2685
	fmul	%f0, %f20, %f0
	fmul	%f1, %f0, %f3
	fldi	%f0, %g0, -1608
	fsub	%f1, %f1, %f0
	mov	%g5, %g7
	call	o_param_c.2687
	addi	%g1, %g1, 4
	fmul	%f0, %f20, %f0
	fmul	%f3, %f0, %f3
	fldi	%f0, %g0, -1612
	fsub	%f0, %f3, %f0
	sti	%g14, %g1, 0
	subi	%g1, %g1, 8
	call	add_reflection.3083
	addi	%g1, %g1, 8
	ldi	%g14, %g1, 0
	addi	%g5, %g14, 1
	sti	%g5, %g0, -192
	return

!---------------------------------------------------------------------
! args = [%g17]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
setup_reflections.3096:
	jlt	%g17, %g0, jge_else.8022
	slli	%g5, %g17, 2
	ldi	%g6, %g5, -1640
	mov	%g5, %g6
	subi	%g1, %g1, 4
	call	o_reflectiontype.2677
	addi	%g1, %g1, 4
	addi	%g7, %g0, 2
	jne	%g5, %g7, jeq_else.8023
	mov	%g5, %g6
	subi	%g1, %g1, 4
	call	o_diffuse.2697
	fmov	%f1, %f0
	fmov	%f0, %f17
	call	fless.2523
	addi	%g1, %g1, 4
	jne	%g5, %g0, jeq_else.8024
	return
jeq_else.8024:
	mov	%g5, %g6
	subi	%g1, %g1, 4
	call	o_form.2675
	addi	%g1, %g1, 4
	jne	%g5, %g3, jeq_else.8026
	mov	%g5, %g17
	jmp	setup_rect_reflection.3090
jeq_else.8026:
	addi	%g7, %g0, 2
	jne	%g5, %g7, jeq_else.8027
	mov	%g7, %g6
	mov	%g5, %g17
	jmp	setup_surface_reflection.3093
jeq_else.8027:
	return
jeq_else.8023:
	return
jge_else.8022:
	return

!---------------------------------------------------------------------
! args = [%g8, %g5]
! fargs = []
! ret type = Unit
!---------------------------------------------------------------------
rt.3098:
	sti	%g8, %g0, -1312
	sti	%g5, %g0, -1316
	srli	%g6, %g8, 1
	sti	%g6, %g0, -1304
	srli	%g5, %g5, 1
	sti	%g5, %g0, -1308
	fmvhi	%f3, 17152
	fmvlo	%f3, 0
	mov	%g5, %g8
	subi	%g1, %g1, 4
	call	min_caml_float_of_int
	fdiv	%f0, %f3, %f0
	fsti	%f0, %g0, -1300
	call	create_pixelline.3047
	mov	%g31, %g5
	call	create_pixelline.3047
	mov	%g18, %g5
	call	create_pixelline.3047
	addi	%g1, %g1, 4
	mov	%g20, %g5
	sti	%g18, %g1, 0
	subi	%g1, %g1, 8
	call	read_parameter.2765
	call	write_ppm_header.3008
	call	init_dirvecs.3081
	subi	%g5, %g0, -932
	call	d_vec.2734
	mov	%g6, %g5
	subi	%g5, %g0, -1604
	call	veccpy.2637
	subi	%g11, %g0, -932
	call	setup_dirvec_constants.2863
	ldi	%g5, %g0, -1884
	subi	%g17, %g5, 1
	call	setup_reflections.3096
	addi	%g1, %g1, 8
	addi	%g5, %g0, 0
	addi	%g27, %g0, 0
	ldi	%g18, %g1, 0
	sti	%g20, %g1, 4
	sti	%g31, %g1, 8
	mov	%g31, %g18
	subi	%g1, %g1, 16
	call	pretrace_line.3024
	addi	%g1, %g1, 16
	addi	%g28, %g0, 0
	addi	%g27, %g0, 2
	ldi	%g31, %g1, 8
	ldi	%g18, %g1, 0
	ldi	%g20, %g1, 4
	mov	%g17, %g20
	jmp	scan_line.3034
