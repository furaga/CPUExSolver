#ifndef _COMMON_H
#define _COMMON_H

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/types.h>
#include <vector>
#include <map>
#define rep(i, n) for (int i = 0; i < n; i++)
#define repi(i, n) for (int i = 1; i < n; i++)
#define eq(a, b) (strcmp(a, b) == 0)

#define ROM_NUM (64 * 1024) // 64KByte
#define RAM_NUM (8.00)

#define MAX_INSTS 64 // 6bit

#define INTREG_NUM (32)
#define FLOATREG_NUM (32)

#define ALU (0b0)
#define FPU (0b1)
#define Move (0b10)
#define System (0b11)
#define ADD_F (0b0)
#define SUB_F (0b1)
#define SLLI (0b1000)
#define SRAI (0b1011)
#define FADD_F (0b1)
#define FSUB_F (0b10)
#define FMUL_F (0b11)
#define FDIV_F (0b101)
#define FSQRT_F (0b1001)
#define FMOV_F (0b1)
#define FNEG_F (0b0)
#define MVLO (0b10001)
#define MVHI (0b10010)
#define FMVLO (0b10011)
#define FMVHI (0b10100)
#define J (0b10101)
#define BEQ (0b10110)
#define BLT (0b11000)
#define FBNE (0b11101)
#define FBLT (0b11110)
#define JR (0b100010)
#define JAL (0b100011)
#define JALR (0b100100)
#define CALL (0b100101)
#define CALLR (0b100110)
#define RETURN (0b100111)
#define STI (0b101000)
#define LDI (0b101001)
#define FSTI (0b101010)
#define FLDI (0b101011)
#define INPUT_F (0b0)
#define OUTPUT_F (0b11)
#define HALT_F (0b110)

using namespace std;
#endif

