#include "assembler.h"

DEFINE_R(_add, SPECIAL, 0, ADD_F);
DEFINE_R(_sub, SPECIAL, 0, SUB_F);
DEFINE_R(_mul, SPECIAL, 0, MUL_F);
DEFINE_R(_div, SPECIAL, 0, DIV_F);
DEFINE_R(_sll, SPECIAL, 0, SLL_F);
DEFINE_R(_srl, SPECIAL, 0, SRL_F);
DEFINE_R(_nor, SPECIAL, 0, NOR_F);
DEFINE_R(_not, SPECIAL, 0, NOT_F);
DEFINE_I(_addi, ADDI);
DEFINE_I(_subi, SUBI);
DEFINE_I(_muli, MULI);
DEFINE_I(_slli, SLLI);
DEFINE_I(_srli, SRLI);
DEFINE_R(_fadd, FPI, 0, FADD_F);
DEFINE_R(_fsub, FPI, 0, FSUB_F);
DEFINE_R(_fmul, FPI, 0, FMUL_F);
DEFINE_R(_fdiv, FPI, 0, FDIV_F);
DEFINE_R(_fsqrt, FPI, 0, FSQRT_F);
DEFINE_R(_fabs, FPI, 0, FABS_F);
DEFINE_R(_fmov, FPI, 0, FMOV_F);
DEFINE_R(_fneg, FPI, 0, FNEG_F);
DEFINE_I(_mvlo, MVLO);
DEFINE_I(_mvhi, MVHI);
DEFINE_J(_jmp, JMP);
DEFINE_I(_jeq, JEQ);
DEFINE_I(_jne, JNE);
DEFINE_I(_jlt, JLT);
DEFINE_I(_fjeq, FJEQ);
DEFINE_I(_fjne, FJNE);
DEFINE_I(_fjlt, FJLT);
DEFINE_R(_b, SPECIAL, 0, B_F);
DEFINE_J(_call, CALL);
DEFINE_R(_callR, SPECIAL, 0, CALLR_F);
DEFINE_R(_return, RETURN, 0, RETURN_F);
DEFINE_R(_st, ST, 0, ST_F);
DEFINE_R(_ld, LD, 0, LD_F);
DEFINE_R(_fst, FST, 0, FST_F);
DEFINE_R(_fld, FLD, 0, FLD_F);
DEFINE_I(_sti, STI);
DEFINE_I(_ldi, LDI);
DEFINE_I(_fsti, FSTI);
DEFINE_I(_fldi, FLDI);
DEFINE_R(_input, IO, 0, INPUT_F);
DEFINE_R(_output, IO, 0, OUTPUT_F);
DEFINE_R(_halt, SPECIAL, 0, HALT_F);

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
	if (eq(instName, "mul"))
	{
		int n = sscanf(buffer, formRRR, dummy, &rd, &rs, &rt);
		if (n == 4)
		{
			code = _mul(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "div"))
	{
		int n = sscanf(buffer, formRRR, dummy, &rd, &rs, &rt);
		if (n == 4)
		{
			code = _div(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "sll"))
	{
		int n = sscanf(buffer, formRRR, dummy, &rd, &rs, &rt);
		if (n == 4)
		{
			code = _sll(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "srl"))
	{
		int n = sscanf(buffer, formRRR, dummy, &rd, &rs, &rt);
		if (n == 4)
		{
			code = _srl(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "nor"))
	{
		int n = sscanf(buffer, formRRR, dummy, &rd, &rs, &rt);
		if (n == 4)
		{
			code = _nor(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "not"))
	{
		int n = sscanf(buffer, formRR, dummy, &rt, &rs);
		if (n == 3)
		{
			code = _not(rs, rt, rd);
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
	if (eq(instName, "fabs"))
	{
		int n = sscanf(buffer, formFF, dummy, &rt, &rs);
		if (n == 3)
		{
			code = _fabs(rs, rt, rd);
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
	if (eq(instName, "jmp"))
	{
		int n = sscanf(buffer, formL, dummy, label);
		if (n == 2)
		{
			labelNames[currentLine] = string(label);
//			cerr << "assigned (" << currentLine << ", " << string(label) << ") in labelNames" << endl;
			useLabel = true;
			code = _jmp(0);
			return true;
		}
	}
	if (eq(instName, "jeq"))
	{
		int n = sscanf(buffer, formRRL, dummy, &rt, &rs, label);
		if (n == 4)
		{
			labelNames[currentLine] = string(label);
//			cerr << "assigned (" << currentLine << ", " << string(label) << ") in labelNames" << endl;
			useLabel = true;
			code = _jeq(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "jne"))
	{
		int n = sscanf(buffer, formRRL, dummy, &rt, &rs, label);
		if (n == 4)
		{
			labelNames[currentLine] = string(label);
//			cerr << "assigned (" << currentLine << ", " << string(label) << ") in labelNames" << endl;
			useLabel = true;
			code = _jne(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "jlt"))
	{
		int n = sscanf(buffer, formRRL, dummy, &rt, &rs, label);
		if (n == 4)
		{
			labelNames[currentLine] = string(label);
//			cerr << "assigned (" << currentLine << ", " << string(label) << ") in labelNames" << endl;
			useLabel = true;
			code = _jlt(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "fjeq"))
	{
		int n = sscanf(buffer, formFFL, dummy, &rt, &rs, label);
		if (n == 4)
		{
			labelNames[currentLine] = string(label);
//			cerr << "assigned (" << currentLine << ", " << string(label) << ") in labelNames" << endl;
			useLabel = true;
			code = _fjeq(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "fjne"))
	{
		int n = sscanf(buffer, formFFL, dummy, &rt, &rs, label);
		if (n == 4)
		{
			labelNames[currentLine] = string(label);
//			cerr << "assigned (" << currentLine << ", " << string(label) << ") in labelNames" << endl;
			useLabel = true;
			code = _fjne(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "fjlt"))
	{
		int n = sscanf(buffer, formFFL, dummy, &rt, &rs, label);
		if (n == 4)
		{
			labelNames[currentLine] = string(label);
//			cerr << "assigned (" << currentLine << ", " << string(label) << ") in labelNames" << endl;
			useLabel = true;
			code = _fjlt(rs, rt, imm);
			return true;
		}
	}
	if (eq(instName, "b"))
	{
		int n = sscanf(buffer, formR, dummy, &rs);
		if (n == 2)
		{
			code = _b(rs, rt, rd);
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
	if (eq(instName, "callR"))
	{
		int n = sscanf(buffer, formR, dummy, &rs);
		if (n == 2)
		{
			code = _callR(rs, rt, rd);
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
	if (eq(instName, "st"))
	{
		int n = sscanf(buffer, formRRR, dummy, &rd, &rs, &rt);
		if (n == 4)
		{
			code = _st(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "ld"))
	{
		int n = sscanf(buffer, formRRR, dummy, &rd, &rs, &rt);
		if (n == 4)
		{
			code = _ld(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "fst"))
	{
		int n = sscanf(buffer, formFRR, dummy, &rd, &rs, &rt);
		if (n == 4)
		{
			code = _fst(rs, rt, rd);
			return true;
		}
	}
	if (eq(instName, "fld"))
	{
		int n = sscanf(buffer, formFRR, dummy, &rd, &rs, &rt);
		if (n == 4)
		{
			code = _fld(rs, rt, rd);
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
	char label[MAX_LINE_SIZE];
	char dummy[MAX_LINE_SIZE];
	vector<bool> useLabels;

	if (eq(instName, "nop"))
	{
		if (sscanf(mnemonicBuffer[0], form, dummy) == 1)
		{
			sprintf(mnemonicBuffer[0], "add\t$iR0, $iR0, $iR0");
			useLabels.push_back(false);
		}
		return	useLabels;
	}
	if (eq(instName, "mov"))
	{
		if (sscanf(mnemonicBuffer[0], formRR, dummy, &rt, &rs) == 3)
		{
			sprintf(mnemonicBuffer[0], "add\t$iR%d, $iR%d, $iR0", rt, rs);
			useLabels.push_back(false);
		}
		return	useLabels;
	}
	if (eq(instName, "neg"))
	{
		if (sscanf(mnemonicBuffer[0], formRR, dummy, &rt, &rs) == 3)
		{
			sprintf(mnemonicBuffer[0], "sub\t$iR%d, $iR0, $iR%d", rt, rs);
			useLabels.push_back(false);
		}
		return	useLabels;
	}
	if (eq(instName, "setL"))
	{
		if (sscanf(mnemonicBuffer[0], formRL, dummy, &rs, label) == 3)
		{
			labelNames[currentLine] = string(label);
//			cerr << "assigned (" << currentLine << ", " << string(label) << ") in labelNames" << endl;
			sprintf(mnemonicBuffer[0], "addi\t$iR%d, $iR0, 0", rs);
			useLabels.push_back(true);
		}
		return	useLabels;
	}
	useLabels.push_back(false);
	return useLabels;
}


