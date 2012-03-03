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
#define RAM_NUM (8.0)

#define MAX_INSTS 64 // 6bit

#define INTREG_NUM (32)
#define FLOATREG_NUM (32)

#define SPECIAL (0)
#define FPI (1)
#define IO (2)
#define ADD_F (1)
#define SUB_F (2)
#define MUL_F (3)
#define DIV_F (4)
#define SLL_F (5)
#define SRL_F (8)
#define NOR_F (50)
#define NOT_F (11)
#define ADDI (3)
#define ADDI_F (0)
#define SUBI (4)
#define SUBI_F (0)
#define MULI (5)
#define MULI_F (0)
#define SLLI (7)
#define SLLI_F (0)
#define SRLI (10)
#define SRLI_F (0)
#define FADD_F (0)
#define FSUB_F (1)
#define FMUL_F (2)
#define FDIV_F (3)
#define FSQRT_F (5)
#define FABS_F (6)
#define FMOV_F (7)
#define FNEG_F (8)
#define MVLO (14)
#define MVLO_F (0)
#define MVHI (15)
#define MVHI_F (0)
#define FMVLO (16)
#define FMVLO_F (0)
#define FMVHI (17)
#define FMVHI_F (0)
#define JMP (18)
#define JMP_F (0)
#define JEQ (19)
#define JEQ_F (0)
#define JNE (20)
#define JNE_F (0)
#define JLT (21)
#define JLT_F (0)
#define FJEQ (25)
#define FJEQ_F (0)
#define FJNE (26)
#define FJNE_F (0)
#define FJLT (27)
#define FJLT_F (0)
#define B_F (13)
#define CALL (31)
#define CALL_F (0)
#define CALLR_F (14)
#define RETURN (32)
#define RETURN_F (0)
#define ST (33)
#define ST_F (0)
#define LD (34)
#define LD_F (0)
#define FST (35)
#define FST_F (0)
#define FLD (36)
#define FLD_F (0)
#define STI (37)
#define STI_F (0)
#define LDI (38)
#define LDI_F (0)
#define FSTI (39)
#define FSTI_F (0)
#define FLDI (40)
#define FLDI_F (0)
#define INPUT_F (0)
#define OUTPUT_F (3)
#define HALT_F (15)

using namespace std;
#endif

