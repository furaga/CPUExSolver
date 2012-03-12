#include "assembler.h"

DEFINE_R(_add, ALU, 0, ADD_F);
DEFINE_R(_sub, ALU, 0, SUB_F);
DEFINE_I(_slli, SLLI);
DEFINE_I(_srai, SRAI);
DEFINE_R(_fadd, FPU, 0, FADD_F);
DEFINE_R(_fsub, FPU, 0, FSUB_F);
DEFINE_R(_fmul, FPU, 0, FMUL_F);
DEFINE_R(_fdiv, FPU, 0, FDIV_F);
DEFINE_R(_fsqrt, FPU, 0, FSQRT_F);
DEFINE_R(_fmov, Move, 0, FMOV_F);
DEFINE_R(_fneg, FPU, 0, FNEG_F);
DEFINE_I(_mvlo, MVLO);
DEFINE_I(_mvhi, MVHI);
DEFINE_I(_fmvlo, FMVLO);
DEFINE_I(_fmvhi, FMVHI);
DEFINE_J(_j, J);
DEFINE_I(_beq, BEQ);
DEFINE_I(_blt, BLT);
DEFINE_I(_fbne, FBNE);
DEFINE_I(_fblt, FBLT);
DEFINE_R(_jr, JR, 0, 0);
DEFINE_J(_jal, JAL);
DEFINE_R(_jalr, JALR, 0, 0);
DEFINE_J(_call, CALL);
DEFINE_R(_callr, CALLR, 0, 0);
DEFINE_R(_return, RETURN, 0, 0);
DEFINE_I(_sti, STI);
DEFINE_I(_ldi, LDI);
DEFINE_I(_fsti, FSTI);
DEFINE_I(_fldi, FLDI);
DEFINE_R(_input, System, 0, INPUT_F);
DEFINE_R(_output, System, 0, OUTPUT_F);
DEFINE_R(_halt, System, 0, HALT_F);

typedef union
{
	uint32_t i;
	float f;
} conv;

uint32_t double2bin(double d)
{
	conv f;
	f.f = (float)d;
	return f.i;
}

uint32_t gethi(double d)
{
	return (double2bin(d) >> 16) & 0xffff;
}

uint32_t getlo(double d)
{
	return double2bin(d) & 0xffff;
}

//-----------------------------------------------------------------------------
//
// 命令コマンドを解釈してバイナリに変換
//
//-----------------------------------------------------------------------------
bool encode(char* instName, char* buffer, map<uint32_t, string>& labelNames, uint32_t currentLine, uint32_t& code, bool& useLabel)
{
	uint32_t rs = 0;
	uint32_t rt = 0;
	uint32_t rd = 0;
	uint32_t imm = 0;
	double d = 0;
	char label[MAX_LINE_SIZE];
	char dummy[MAX_LINE_SIZE];

	if (eq(instName, "add"))
	{
		int n = sscanf(buffer, formRRR, dummy, &rd, &rs, &rt);
		if (n == 4)
		{
			code = _add(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "sub"))
	{
		int n = sscanf(buffer, formRRR, dummy, &rd, &rs, &rt);
		if (n == 4)
		{
			code = _sub(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "slli"))
	{
		int n = sscanf(buffer, formRRI, dummy, &rt, &rs, &imm);
		if (n == 4)
		{
			code = _slli(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "srai"))
	{
		int n = sscanf(buffer, formRRI, dummy, &rt, &rs, &imm);
		if (n == 4)
		{
			code = _srai(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "fadd"))
	{
		int n = sscanf(buffer, formFFF, dummy, &rd, &rs, &rt);
		if (n == 4)
		{
			code = _fadd(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "fsub"))
	{
		int n = sscanf(buffer, formFFF, dummy, &rd, &rs, &rt);
		if (n == 4)
		{
			code = _fsub(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "fmul"))
	{
		int n = sscanf(buffer, formFFF, dummy, &rd, &rs, &rt);
		if (n == 4)
		{
			code = _fmul(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "fdiv"))
	{
		int n = sscanf(buffer, formFFF, dummy, &rd, &rs, &rt);
		if (n == 4)
		{
			code = _fdiv(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "fsqrt"))
	{
		int n = sscanf(buffer, formFF, dummy, &rt, &rs);
		if (n == 3)
		{
			code = _fsqrt(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "fmov"))
	{
		int n = sscanf(buffer, formFF, dummy, &rt, &rs);
		if (n == 3)
		{
			code = _fmov(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "fneg"))
	{
		int n = sscanf(buffer, formFF, dummy, &rt, &rs);
		if (n == 3)
		{
			code = _fneg(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "mvlo"))
	{
		int n = sscanf(buffer, formRI, dummy, &rs, &imm);
		if (n == 3)
		{
			code = _mvlo(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "mvhi"))
	{
		int n = sscanf(buffer, formRI, dummy, &rs, &imm);
		if (n == 3)
		{
			code = _mvhi(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "fmvlo"))
	{
		int n = sscanf(buffer, formFI, dummy, &rs, &imm);
		if (n == 3)
		{
			code = _fmvlo(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "fmvhi"))
	{
		int n = sscanf(buffer, formFI, dummy, &rs, &imm);
		if (n == 3)
		{
			code = _fmvhi(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "j"))
	{
		int n = sscanf(buffer, formL, dummy, label);
		if (n == 2)
		{
			labelNames[currentLine] = string(label);
//			cerr << "assigned (" << currentLine << ", " << string(label) << ") in labelNames" << endl;
			useLabel = true;
			code = _j(0);
			return true;
		}
	}
	if (eq(instName, "beq"))
	{
		int n = sscanf(buffer, formRRL, dummy, &rs, &rt, label);
		if (n == 4)
		{
			labelNames[currentLine] = string(label);
//			cerr << "assigned (" << currentLine << ", " << string(label) << ") in labelNames" << endl;
			useLabel = true;
			code = _beq(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "blt"))
	{
		int n = sscanf(buffer, formRRL, dummy, &rs, &rt, label);
		if (n == 4)
		{
			labelNames[currentLine] = string(label);
//			cerr << "assigned (" << currentLine << ", " << string(label) << ") in labelNames" << endl;
			useLabel = true;
			code = _blt(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "fbne"))
	{
		int n = sscanf(buffer, formFFL, dummy, &rs, &rt, label);
		if (n == 4)
		{
			labelNames[currentLine] = string(label);
//			cerr << "assigned (" << currentLine << ", " << string(label) << ") in labelNames" << endl;
			useLabel = true;
			code = _fbne(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "fblt"))
	{
		int n = sscanf(buffer, formFFL, dummy, &rs, &rt, label);
		if (n == 4)
		{
			labelNames[currentLine] = string(label);
//			cerr << "assigned (" << currentLine << ", " << string(label) << ") in labelNames" << endl;
			useLabel = true;
			code = _fblt(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "jr"))
	{
		int n = sscanf(buffer, formR, dummy, &rs);
		if (n == 2)
		{
			code = _jr(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "jal"))
	{
		int n = sscanf(buffer, formL, dummy, label);
		if (n == 2)
		{
			labelNames[currentLine] = string(label);
//			cerr << "assigned (" << currentLine << ", " << string(label) << ") in labelNames" << endl;
			useLabel = true;
			code = _jal(0);
			return true;
		}
	}
	if (eq(instName, "jalr"))
	{
		int n = sscanf(buffer, formR, dummy, &rs);
		if (n == 2)
		{
			code = _jalr(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "call"))
	{
		int n = sscanf(buffer, formL, dummy, label);
		if (n == 2)
		{
			labelNames[currentLine] = string(label);
//			cerr << "assigned (" << currentLine << ", " << string(label) << ") in labelNames" << endl;
			useLabel = true;
			code = _call(0);
			return true;
		}
	}
	if (eq(instName, "callr"))
	{
		int n = sscanf(buffer, formR, dummy, &rs);
		if (n == 2)
		{
			code = _callr(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "return"))
	{
		int n = sscanf(buffer, form, dummy);
		if (n == 1)
		{
			code = _return(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "sti"))
	{
		int n = sscanf(buffer, formRRI, dummy, &rt, &rs, &imm);
		if (n == 4)
		{
			code = _sti(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "ldi"))
	{
		int n = sscanf(buffer, formRRI, dummy, &rt, &rs, &imm);
		if (n == 4)
		{
			code = _ldi(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "fsti"))
	{
		int n = sscanf(buffer, formFRI, dummy, &rt, &rs, &imm);
		if (n == 4)
		{
			code = _fsti(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "fldi"))
	{
		int n = sscanf(buffer, formFRI, dummy, &rt, &rs, &imm);
		if (n == 4)
		{
			code = _fldi(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "input"))
	{
		int n = sscanf(buffer, formR, dummy, &rs);
		if (n == 2)
		{
			code = _input(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "output"))
	{
		int n = sscanf(buffer, formR, dummy, &rs);
		if (n == 2)
		{
			code = _output(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "halt"))
	{
		int n = sscanf(buffer, form, dummy);
		if (n == 1)
		{
			code = _halt(rs, rt, rd);
			return true;
		}
	}
	
	return false;
}

//-----------------------------------------------------------------------------
//
// 擬似命令（ニーモニック）の解決
// 返り値は分解された各命令がラベルを使うかどうか
//
//-----------------------------------------------------------------------------
vector<bool> mnemonic(char* instName, char mnemonicBuffer[][MAX_LINE_SIZE], map<uint32_t, string>& labelNames, uint32_t currentLine)
{
	uint32_t rs = 0;
	uint32_t rt = 0;
	uint32_t rd = 0;
	uint32_t imm = 0;
	double d = 0;
	char label[MAX_LINE_SIZE];
	char dummy[MAX_LINE_SIZE];
	vector<bool> useLabels;

	if (eq(instName, "nop"))
	{
		if (sscanf(mnemonicBuffer[0], form, dummy) == 1)
		{
			sprintf(mnemonicBuffer[0], "add\t＄r0, ＄r0, ＄r0");
			useLabels.push_back(false);
		}
		return	useLabels;
	}
	if (eq(instName, "mov"))
	{
		if (sscanf(mnemonicBuffer[0], formRR, dummy, &rt, &rs) == 3)
		{
			sprintf(mnemonicBuffer[0], "add\t＄r%d, ＄r%d, ＄r0", rt, rs);
			useLabels.push_back(false);
		}
		return	useLabels;
	}
	if (eq(instName, "not"))
	{
		if (sscanf(mnemonicBuffer[0], formRR, dummy, &rt, &rs) == 3)
		{
			sprintf(mnemonicBuffer[0], "nor\t＄r%d, ＄r%d, ＄r0", rt, rs, rs);
			useLabels.push_back(false);
		}
		return	useLabels;
	}
	if (eq(instName, "neg"))
	{
		if (sscanf(mnemonicBuffer[0], formRR, dummy, &rt, &rs) == 3)
		{
			sprintf(mnemonicBuffer[0], "sub\t＄r%d, ＄r0, ＄r%d", rt, rs);
			useLabels.push_back(false);
		}
		return	useLabels;
	}
	if (eq(instName, "setl"))
	{
		if (sscanf(mnemonicBuffer[0], formRL, dummy, &rs, label) == 3)
		{
			labelNames[currentLine] = string(label);
//			cerr << "assigned (" << currentLine << ", " << string(label) << ") in labelNames" << endl;
			sprintf(mnemonicBuffer[0], "addi\t＄r%d, ＄r0, 0", rs);
			useLabels.push_back(true);
		}
		return	useLabels;
	}
	if (eq(instName, "fliw"))
	{
		if (sscanf(mnemonicBuffer[0], formFD, dummy, &rs, &d) == 3)
		{
			sprintf(mnemonicBuffer[0], "fmvlo\t＄f%d, %d", rs, gethi(d));
			useLabels.push_back(false);
			sprintf(mnemonicBuffer[1], "fmvhi\t＄f%d, %d", rs, getlo(d));
			useLabels.push_back(false);
		}
		return	useLabels;
	}
	useLabels.push_back(false);
	return useLabels;
}


