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
PROTO_I(_slli);
PROTO_I(_srai);
PROTO_R(_fadd);
PROTO_R(_fsub);
PROTO_R(_fmul);
PROTO_R(_fdiv);
PROTO_R(_fsqrt);
PROTO_R(_fmov);
PROTO_R(_fneg);
PROTO_I(_mvlo);
PROTO_I(_mvhi);
PROTO_I(_fmvlo);
PROTO_I(_fmvhi);
PROTO_J(_j);
PROTO_I(_beq);
PROTO_I(_blt);
PROTO_I(_fbne);
PROTO_I(_fblt);
PROTO_R(_jr);
PROTO_J(_jal);
PROTO_R(_jalr);
PROTO_J(_call);
PROTO_R(_callr);
PROTO_R(_return);
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
#define formR "%s ＄r%d"
#define formF "%s ＄f%d"
#define formD "%s %lf"

// 2オペランド命令の読み込みフォーマット
#define formRI "%s ＄r%d, %d"
#define formRL "%s ＄r%d, %s"
#define formRR "%s ＄r%d, ＄r%d"
#define formRF "%s ＄r%d, ＄f%d"
#define formRD "%s ＄r%d, %lf"

#define formFI "%s ＄f%d, %d"
#define formFL "%s ＄f%d, %s"
#define formFR "%s ＄f%d, ＄r%d"
#define formFF "%s ＄f%d, ＄f%d"
#define formFD "%s ＄f%d, %lf"

// 3オペランド命令の読み込みフォーマット
#define formRRI "%s ＄r%d, ＄r%d, %d"
#define formRRL "%s ＄r%d, ＄r%d, %s"
#define formRRR "%s ＄r%d, ＄r%d, ＄r%d"
#define formRRF "%s ＄r%d, ＄r%d, ＄f%d"
#define formRRD "%s ＄r%d, ＄r%d, %lf"

#define formRFI "%s ＄r%d, ＄f%d, %d"
#define formRFL "%s ＄r%d, ＄f%d, %s"
#define formRFR "%s ＄r%d, ＄f%d, ＄r%d"
#define formRFF "%s ＄r%d, ＄f%d, ＄f%d"
#define formRFD "%s ＄r%d, ＄f%d, %lf"

#define formFRI "%s ＄f%d, ＄r%d, %d"
#define formFRL "%s ＄f%d, ＄r%d, %s"
#define formFRR "%s ＄f%d, ＄r%d, ＄r%d"
#define formFRF "%s ＄f%d, ＄r%d, ＄f%d"
#define formFRD "%s ＄f%d, ＄r%d, %lf"

#define formFFI "%s ＄f%d, ＄f%d, %d"
#define formFFL "%s ＄f%d, ＄f%d, %s"
#define formFFR "%s ＄f%d, ＄f%d, ＄r%d"
#define formFFF "%s ＄f%d, ＄f%d, ＄f%d"
#define formFFD "%s ＄f%d, ＄f%d, %lf"

bool encode(char* instName, char* buffer, map<uint32_t, string>& labelNames, uint32_t currentLine, uint32_t& code, bool& useLabel);
vector<bool> mnemonic(char* instName, char mnemonicBuffer[][MAX_LINE_SIZE], map<uint32_t, string>& labelNames, uint32_t currentLine);

#endif

