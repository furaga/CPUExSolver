;;初期化
ori $r30, $r30, 12
setl $r31, HALT
ori $r0, $r0, 2
ori $r1, $r1, 4

;;FIB関数呼び出し
store $r31, $r30, 2
addi $r30, $r30, 10
store $r30, $r30, -1
jal FIB
load $r30, $r30, -1
subi $r30, $r30, 10
load $r31, $r30, 2
jr $r31

FIB:
blt $r1, $r0, F_EXIT
subi $r1, $r1, 1

store $r1, $r30, 5

store $r31, $r30, 2
addi $r30, $r30, 10
store $r30, $r30, -2
jal FIB
load $r30, $r30, -2
subi $r30, $r30, 10
load $r31, $r30, 2

load $r1, $r30, 5
subi $r1, $r1, 1
store $r5, $r30, 4

store $r31, $r30, 2
addi $r30, $r30, 10
store $r30, $r30, -2
jal FIB
load $r30, $r30, -2
subi $r30, $r30, 10
load $r31, $r30, 2

load $r7, $r30, 4

add $r5, $r5, $r7
jr $r31

F_EXIT:
addi $r29, $r5, 48
iost $r29
andi $r29, $r29, 0
ori $r29, $r29, 10
iost $r29
andi $r5, $r5, 0
ori $r5, $r5, 1
jr $r31

HALT:
addi $r29, $r1, 48
iost $r29
addi $r29, $r5, 48
iost $r29
;;iost $r1, $r1, 0
hlt
