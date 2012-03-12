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

#define AL (0x00)
#define FPA (0x30)
#define MOV (0x14)
#define ADD_F (0x00)
#define SUB_F (0x01)
#define MUL_F (0x02)
#define AND_F (0x03)
#define OR_F (0x04)
#define XOR_F (0x05)
#define ADDI (0x01)
#define SUBI (0x02)
#define MULI (0x03)
#define SLLI (0x08)
#define SRLI (0x07)
#define ANDI (0x04)
#define ORI (0x05)
#define XORI (0x06)
#define FADD_F (0x00)
#define FSUB_F (0x01)
#define FMUL_F (0x02)
#define FINV_F (0x0B)
#define FSQRT_F (0x03)
#define FMOV (0x15)
#define FNEG_F (0x07)
#define IMOVF (0x17)
#define FMOVI (0x16)
#define LLI (0x1B)
#define LUI (0x18)
#define FLLI (0x1A)
#define FLUI (0x19)
#define J (0x22)
#define BNE (0x20)
#define BLT (0x21)
#define FBNE (0x2B)
#define FBLT (0x2A)
#define JR (0x24)
#define JAL (0x23)
#define JALR (0x29)
#define STORE (0x12)
#define LOAD (0x10)
#define IOLD (0x27)
#define IOST (0x28)
#define HLT (0x26)

using namespace std;
#endif

