#ifndef _ASSEMBLER_H
#define _ASSEMBLER_H

#include "../include/common.h"

#define DATA_UNIT 32
#define MAX_LINE_SIZE 512
#define MAX_LINES 10000
#define MAX_LABELS 10000

#define PROTO_R(name) \
	uint32_t name(uint8_t, uint8_t, uint8_t);

#define PROTO_I(name) \
	uint32_t name(uint8_t, uint8_t, uint16_t);

#define PROTO_J(name) \
	uint32_t name(uint32_t);

#define DEFINE_R(name, opcode, shaft, funct) \
	uint32_t name(uint8_t rs, uint8_t rt, uint8_t rd) {\
		return (opcode << 26 | ((uint32_t)rs << 21) | ((uint32_t) rt << 16)\
				| ((uint32_t) rd << 11) | ((uint32_t) shaft << 6) |funct);\
	}

#define DEFINE_I(name, opcode) \
	uint32_t name(uint8_t rs, uint8_t rt, uint16_t imm) {\
		return (opcode << 26 | ((uint32_t)rs << 21) | ((uint32_t) rt << 16) | imm);\
	}
#define DEFINE_J(name, opcode) \
	uint32_t name(uint32_t address) {\
		return (opcode << 26 | address);\
	}

PROTO_R(_add);
PROTO_R(_sub);
PROTO_R(_mul);
PROTO_R(_div);
PROTO_R(_sll);
PROTO_R(_srl);
PROTO_R(_nor);
PROTO_R(_not);
PROTO_I(_addi);
PROTO_I(_subi);
PROTO_I(_muli);
PROTO_I(_slli);
PROTO_I(_srli);
PROTO_R(_fadd);
PROTO_R(_fsub);
PROTO_R(_fmul);
PROTO_R(_fdiv);
PROTO_R(_fsqrt);
PROTO_R(_fabs);
PROTO_R(_fmov);
PROTO_R(_fneg);
PROTO_I(_mvlo);
PROTO_I(_mvhi);
PROTO_J(_jmp);
PROTO_I(_jeq);
PROTO_I(_jne);
PROTO_I(_jlt);
PROTO_I(_fjeq);
PROTO_I(_fjne);
PROTO_I(_fjlt);
PROTO_R(_b);
PROTO_J(_call);
PROTO_R(_callR);
PROTO_R(_return);
PROTO_R(_st);
PROTO_R(_ld);
PROTO_R(_fst);
PROTO_R(_fld);
PROTO_I(_sti);
PROTO_I(_ldi);
PROTO_I(_fsti);
PROTO_I(_fldi);
PROTO_R(_input);
PROTO_R(_output);
PROTO_R(_halt);

// 0オペランド命令の読み込みフォーマット
#define form "%s"

// 1オペランド命令の読み込みフォーマット
#define formI "%s %d"
#define formL "%s %s"
#define formR "%s $iR%d"
#define formF "%s $fR%d"

// 2オペランド命令の読み込みフォーマット
#define formRI "%s $iR%d, %d"
#define formRL "%s $iR%d, %s"
#define formRR "%s $iR%d, $iR%d"
#define formRF "%s $iR%d, $fR%d"

#define formFI "%s $fR%d, %d"
#define formFL "%s $fR%d, %s"
#define formFR "%s $fR%d, $iR%d"
#define formFF "%s $fR%d, $fR%d"

// 3オペランド命令の読み込みフォーマット
#define formRRI "%s $iR%d, $iR%d, %d"
#define formRRL "%s $iR%d, $iR%d, %s"
#define formRRR "%s $iR%d, $iR%d, $iR%d"
#define formRRF "%s $iR%d, $iR%d, $fR%d"

#define formRFI "%s $iR%d, $fR%d, %d"
#define formRFL "%s $iR%d, $fR%d, %s"
#define formRFR "%s $iR%d, $fR%d, $iR%d"
#define formRFF "%s $iR%d, $fR%d, $fR%d"

#define formFRI "%s $fR%d, $iR%d, %d"
#define formFRL "%s $fR%d, $iR%d, %s"
#define formFRR "%s $fR%d, $iR%d, $iR%d"
#define formFRF "%s $fR%d, $iR%d, $fR%d"

#define formFFI "%s $fR%d, $fR%d, %d"
#define formFFL "%s $fR%d, $fR%d, %s"
#define formFFR "%s $fR%d, $fR%d, $iR%d"
#define formFFF "%s $fR%d, $fR%d, $fR%d"

bool encode(char* instName, char* buffer, map<uint32_t, string>& labelNames, uint32_t currentLine, uint32_t& code, bool& useLabel);
vector<bool> mnemonic(char* instName, char mnemonicBuffer[][MAX_LINE_SIZE], map<uint32_t, string>& labelNames, uint32_t currentLine);

#endif

