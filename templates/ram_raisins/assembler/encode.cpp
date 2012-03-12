#include "assembler.h"

DEFINE_R(_mov, MOV, 0, 0);
DEFINE_R(_add, AL, 0, ADD_F);
DEFINE_R(_sub, AL, 0, SUB_F);
DEFINE_R(_mul, AL, 0, MUL_F);
DEFINE_R(_and, AL, 0, AND_F);
DEFINE_R(_or, AL, 0, OR_F);
DEFINE_R(_xor, AL, 0, XOR_F);
DEFINE_I(_addi, ADDI);
DEFINE_I(_subi, SUBI);
DEFINE_I(_muli, MULI);
DEFINE_I(_slli, SLLI);
DEFINE_I(_srli, SRLI);
DEFINE_I(_andi, ANDI);
DEFINE_I(_ori, ORI);
DEFINE_I(_xori, XORI);
DEFINE_R(_fadd, FPA, 0, FADD_F);
DEFINE_R(_fsub, FPA, 0, FSUB_F);
DEFINE_R(_fmul, FPA, 0, FMUL_F);
DEFINE_R(_finv, FPA, 0, FINV_F);
DEFINE_R(_fsqrt, FPA, 0, FSQRT_F);
DEFINE_R(_fmov, FMOV, 0, 0);
DEFINE_R(_fneg, FPA, 0, FNEG_F);
DEFINE_R(_imovf, IMOVF, 0, 0);
DEFINE_R(_fmovi, FMOVI, 0, 0);
DEFINE_I(_lli, LLI);
DEFINE_I(_lui, LUI);
DEFINE_I(_flli, FLLI);
DEFINE_I(_flui, FLUI);
DEFINE_J(_j, J);
DEFINE_I(_bne, BNE);
DEFINE_I(_blt, BLT);
DEFINE_I(_fbne, FBNE);
DEFINE_I(_fblt, FBLT);
DEFINE_R(_jr, JR, 0, 0);
DEFINE_J(_jal, JAL);
DEFINE_R(_jalr, JALR, 0, 0);
DEFINE_I(_store, STORE);
DEFINE_I(_load, LOAD);
DEFINE_R(_iold, IOLD, 0, 0);
DEFINE_R(_iost, IOST, 0, 0);
DEFINE_R(_hlt, HLT, 0, 0);

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

	if (eq(instName, "mov"))
	{
		int n = sscanf(buffer, formRR, dummy, &rt, &rs);
		if (n == 3)
		{
			code = _mov(rs, rt, rd);
			return true;
		}
	}
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
	if (eq(instName, "mul"))
	{
		int n = sscanf(buffer, formRRR, dummy, &rd, &rs, &rt);
		if (n == 4)
		{
			code = _mul(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "and"))
	{
		int n = sscanf(buffer, formRRR, dummy, &rd, &rs, &rt);
		if (n == 4)
		{
			code = _and(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "or"))
	{
		int n = sscanf(buffer, formRRR, dummy, &rd, &rs, &rt);
		if (n == 4)
		{
			code = _or(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "xor"))
	{
		int n = sscanf(buffer, formRRR, dummy, &rd, &rs, &rt);
		if (n == 4)
		{
			code = _xor(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "addi"))
	{
		int n = sscanf(buffer, formRRI, dummy, &rt, &rs, &imm);
		if (n == 4)
		{
			code = _addi(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "subi"))
	{
		int n = sscanf(buffer, formRRI, dummy, &rt, &rs, &imm);
		if (n == 4)
		{
			code = _subi(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "muli"))
	{
		int n = sscanf(buffer, formRRI, dummy, &rt, &rs, &imm);
		if (n == 4)
		{
			code = _muli(rs, rt, imm);
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
	if (eq(instName, "srli"))
	{
		int n = sscanf(buffer, formRRI, dummy, &rt, &rs, &imm);
		if (n == 4)
		{
			code = _srli(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "andi"))
	{
		int n = sscanf(buffer, formRRI, dummy, &rt, &rs, &imm);
		if (n == 4)
		{
			code = _andi(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "ori"))
	{
		int n = sscanf(buffer, formRRI, dummy, &rt, &rs, &imm);
		if (n == 4)
		{
			code = _ori(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "xori"))
	{
		int n = sscanf(buffer, formRRI, dummy, &rt, &rs, &imm);
		if (n == 4)
		{
			code = _xori(rs, rt, imm);
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
	if (eq(instName, "finv"))
	{
		int n = sscanf(buffer, formFF, dummy, &rd, &rs);
		if (n == 3)
		{
			code = _finv(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "fsqrt"))
	{
		int n = sscanf(buffer, formFF, dummy, &rd, &rs);
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
		int n = sscanf(buffer, formFF, dummy, &rd, &rs);
		if (n == 3)
		{
			code = _fneg(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "imovf"))
	{
		int n = sscanf(buffer, formFR, dummy, &rt, &rs);
		if (n == 3)
		{
			code = _imovf(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "fmovi"))
	{
		int n = sscanf(buffer, formRF, dummy, &rt, &rs);
		if (n == 3)
		{
			code = _fmovi(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "lli"))
	{
		int n = sscanf(buffer, formRI, dummy, &rs, &imm);
		if (n == 3)
		{
			code = _lli(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "lui"))
	{
		int n = sscanf(buffer, formRI, dummy, &rs, &imm);
		if (n == 3)
		{
			code = _lui(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "flli"))
	{
		int n = sscanf(buffer, formFI, dummy, &rs, &imm);
		if (n == 3)
		{
			code = _flli(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "flui"))
	{
		int n = sscanf(buffer, formFI, dummy, &rs, &imm);
		if (n == 3)
		{
			code = _flui(rs, rt, imm);
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
	if (eq(instName, "bne"))
	{
		int n = sscanf(buffer, formRRL, dummy, &rs, &rt, label);
		if (n == 4)
		{
			labelNames[currentLine] = string(label);
//			cerr << "assigned (" << currentLine << ", " << string(label) << ") in labelNames" << endl;
			useLabel = true;
			code = _bne(rs, rt, imm);
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
	if (eq(instName, "store"))
	{
		int n = sscanf(buffer, formRRI, dummy, &rt, &rs, &imm);
		if (n == 4)
		{
			code = _store(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "load"))
	{
		int n = sscanf(buffer, formRRI, dummy, &rt, &rs, &imm);
		if (n == 4)
		{
			code = _load(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "iold"))
	{
		int n = sscanf(buffer, formR, dummy, &rt);
		if (n == 2)
		{
			code = _iold(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "iost"))
	{
		int n = sscanf(buffer, formR, dummy, &rs);
		if (n == 2)
		{
			code = _iost(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "hlt"))
	{
		int n = sscanf(buffer, form, dummy);
		if (n == 1)
		{
			code = _hlt(rs, rt, rd);
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
			sprintf(mnemonicBuffer[0], "add\t$r0, $r0, $r0");
			useLabels.push_back(false);
		}
		return	useLabels;
	}
	if (eq(instName, "mov"))
	{
		if (sscanf(mnemonicBuffer[0], formRR, dummy, &rt, &rs) == 3)
		{
			sprintf(mnemonicBuffer[0], "add\t$r%d, $r%d, $r0", rt, rs);
			useLabels.push_back(false);
		}
		return	useLabels;
	}
	if (eq(instName, "neg"))
	{
		if (sscanf(mnemonicBuffer[0], formRR, dummy, &rt, &rs) == 3)
		{
			sprintf(mnemonicBuffer[0], "sub\t$r%d, $r0, $r%d", rt, rs);
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
			sprintf(mnemonicBuffer[0], "addi\t$r%d, $r0, 0", rs);
			useLabels.push_back(true);
		}
		return	useLabels;
	}
	useLabels.push_back(false);
	return useLabels;
}


