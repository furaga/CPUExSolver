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

#define SPECIAL (000)
#define FPI (021)
#define IO (001)
#define ADD_F (040)
#define SUB_F (042)
#define MUL_F (030)
#define SLL_F (000)
#define ADDI (010)
#define ADDI_F (0)
#define SUBI (020)
#define SUBI_F (0)
#define MULI (030)
#define MULI_F (0)
#define SLLI (050)
#define SLLI_F (0)
#define SRLI (052)
#define SRLI_F (0)
#define FADD_F (000)
#define FSUB_F (001)
#define FMUL_F (002)
#define FDIV_F (003)
#define FSQRT_F (004)
#define FABS_F (005)
#define FMOV_F (006)
#define FNEG_F (007)
#define MVLO (007)
#define MVLO_F (0)
#define MVHI (017)
#define MVHI_F (0)
#define JMP (002)
#define JMP_F (0)
#define JEQ (012)
#define JEQ_F (0)
#define JNE (022)
#define JNE_F (0)
#define JLT (032)
#define JLT_F (0)
#define FJEQ (062)
#define FJEQ_F (0)
#define FJLT (072)
#define FJLT_F (0)
#define B_F (010)
#define CALL (060)
#define CALL_F (0)
#define CALLR_F (060)
#define RETURN (070)
#define RETURN_F (0)
#define ST (033)
#define ST_F (0)
#define LD (023)
#define LD_F (0)
#define FST_F (071)
#define FLD_F (061)
#define STI (053)
#define STI_F (0)
#define LDI (043)
#define LDI_F (0)
#define FSTI (071)
#define FSTI_F (0)
#define FLDI (061)
#define FLDI_F (0)
#define INPUT_F (000)
#define OUTPUT_F (001)
#define HALT_F (077)

using namespace std;
#endif

