#coding:utf-8
import sys
from mako.template import Template
from xml.etree.ElementTree import *

xml = parse(sys.argv[1]) # 返値はElementTree型
xmlroot = xml.getroot()

addrUnit = 4 if xmlroot.find(".//binary").get("addressing") == "byte" else 1
rom_addrUnit = 4 if xmlroot.find(".//binary").get("rom_addressing") == "byte" else 1
addrDiv = " / 4" if addrUnit == 4 else ""
direction =  xmlroot.find(".//binary").get("direction")

dirR = "-" if direction == "toSmall" else "+"
dirI = "+" if direction == "toBig" else "-"

def getAddrMode(type):
	return xmlroot.find(".//" + type).get("addressMode")

def getBranchCode(cond, type):
	return "if (" + cond + ") pc " + ("+= IMM - %d" % rom_addrUnit if getAddrMode('BEQ') == 'relative' else "= IMM")

# RS, RT, RDはformAsmの設定によって互いに役目を入れか得られる。
instInfo = [
	{'type' : 'MOV', 'formBin' : 'R', 'formAsm' : ['IRT', 'IRS'], 'code' : ["%(arg0)s = %(arg1)s"]},
	{'type' : 'ADD', 'formBin' : 'R', 'formAsm' : ['IRD', 'IRS', 'IRT'], 'code' : ["%(arg0)s = %(arg1)s + %(arg2)s"]},
	{'type' : 'SUB', 'formBin' : 'R', 'formAsm' : ['IRD', 'IRS', 'IRT'], 'code' : ["%(arg0)s = %(arg1)s - %(arg2)s"]},
	{'type' : 'MUL', 'formBin' : 'R', 'formAsm' : ['IRD', 'IRS', 'IRT'], 'code' : ["%(arg0)s = %(arg1)s * %(arg2)s"]},
	{'type' : 'DIV', 'formBin' : 'R', 'formAsm' : ['IRD', 'IRS', 'IRT'], 'code' : ["%(arg0)s = %(arg1)s / %(arg2)s"]},
	{'type' : 'SLL', 'formBin' : 'R', 'formAsm' : ['IRD', 'IRS', 'IRT'], 'code' : ["%(arg0)s = %(arg1)s << %(arg2)s"]},
	{'type' : 'SLA', 'formBin' : 'R', 'formAsm' : ['IRD', 'IRS', 'IRT'], 'code' : ["%(arg0)s = %(arg1)s << %(arg2)s"]},
	{'type' : 'SRL', 'formBin' : 'R', 'formAsm' : ['IRD', 'IRS', 'IRT'], 'code' : ["%(arg0)s = (unsigned)%(arg1)s >> %(arg2)s)"]},
	# g++ (Ubuntu 4.4.3-4ubuntu5) 4.4.3ではint32_tに対する >> 演算子は算術シフト
	{'type' : 'SRA', 'formBin' : 'R', 'formAsm' : ['IRD', 'IRS', 'IRT'], 'code' : ["%(arg0)s = %(arg1)s >> %(arg2)s"]},
	# bool値の演算ではなく、ビット列に対する演算
	{'type' : 'AND', 'formBin' : 'R', 'formAsm' : ['IRD', 'IRS', 'IRT'], 'code' : ["%(arg0)s = %(arg1)s & %(arg2)s"]},
	{'type' : 'OR', 'formBin' : 'R', 'formAsm' : ['IRD', 'IRS', 'IRT'], 'code' : ["%(arg0)s = %(arg1)s | %(arg2)s"]},
	{'type' : 'NOR', 'formBin' : 'R', 'formAsm' : ['IRD', 'IRS', 'IRT'], 'code' : ["%(arg0)s = ~(%(arg1)s | %(arg2)s)"]},
	{'type' : 'XOR', 'formBin' : 'R', 'formAsm' : ['IRD', 'IRS', 'IRT'], 'code' : ["%(arg0)s = %(arg1)s ^ %(arg2)s"]},
	{'type' : 'NOT', 'formBin' : 'R', 'formAsm' : ['IRT', 'IRS'], 'code' : ["%(arg0)s = ~%(arg1)s"]},
	{'type' : 'ADDI', 'formBin' : 'I', 'formAsm' : ['IRT', 'IRS', 'IMM'], 'code' : ["%(arg0)s = %(arg1)s + IMM"]},
	{'type' : 'SUBI', 'formBin' : 'I', 'formAsm' : ['IRT', 'IRS', 'IMM'], 'code' : ["%(arg0)s = %(arg1)s - IMM"]},
	{'type' : 'MULI', 'formBin' : 'I', 'formAsm' : ['IRT', 'IRS', 'IMM'], 'code' : ["%(arg0)s = %(arg1)s * IMM"]},
	{'type' : 'DIVI', 'formBin' : 'I', 'formAsm' : ['IRT', 'IRS', 'IMM'], 'code' : ["%(arg0)s = %(arg1)s / IMM"]},
	{'type' : 'SLLI', 'formBin' : 'I', 'formAsm' : ['IRT', 'IRS', 'IMM'], 'code' : ["%(arg0)s = %(arg1)s << IMM"]},
	{'type' : 'SLAI', 'formBin' : 'I', 'formAsm' : ['IRT', 'IRS', 'IMM'], 'code' : ["%(arg0)s = %(arg1)s << IMM"]},
	{'type' : 'SRLI', 'formBin' : 'I', 'formAsm' : ['IRT', 'IRS', 'IMM'], 'code' : ["%(arg0)s = (unsigned)%(arg1)s >> IMM"]},
	{'type' : 'SRAI', 'formBin' : 'I', 'formAsm' : ['IRT', 'IRS', 'IMM'], 'code' : ["%(arg0)s = %(arg1)s >> IMM"]},
	{'type' : 'ANDI', 'formBin' : 'I', 'formAsm' : ['IRT', 'IRS', 'IMM'], 'code' : ["%(arg0)s = %(arg1)s & IMM"]},
	{'type' : 'ORI', 'formBin' : 'I', 'formAsm' : ['IRT', 'IRS', 'IMM'], 'code' : ["%(arg0)s = %(arg1)s | IMM"]},
	{'type' : 'NORI', 'formBin' : 'I', 'formAsm' : ['IRT', 'IRS', 'IMM'], 'code' : ["%(arg0)s = ~(%(arg1)s | IMM)"]},
	{'type' : 'XORI', 'formBin' : 'I', 'formAsm' : ['IRT', 'IRS', 'IMM'], 'code' : ["%(arg0)s = %(arg1)s ^ IMM"]},
	{'type' : 'FADD', 'formBin' : 'R', 'formAsm' : ['FRD', 'FRS', 'FRT'], 'code' : ["%(arg0)s = myfadd(%(arg1)s, %(arg2)s)"]},
	{'type' : 'FSUB', 'formBin' : 'R', 'formAsm' : ['FRD', 'FRS', 'FRT'], 'code' : ["%(arg0)s = myfsub(%(arg1)s, %(arg2)s)"]},
	{'type' : 'FMUL', 'formBin' : 'R', 'formAsm' : ['FRD', 'FRS', 'FRT'], 'code' : ["%(arg0)s = myfmul(%(arg1)s, %(arg2)s)"]},
	{'type' : 'FDIV', 'formBin' : 'R', 'formAsm' : ['FRD', 'FRS', 'FRT'], 'code' : ["%(arg0)s = myfdiv(%(arg1)s, %(arg2)s)"]},
	{'type' : 'FINV', 'formBin' : 'R', 'formAsm' : ['FRT', 'FRS'], 'code' : ["%(arg0)s = myfinv(%(arg1)s)"]},
	{'type' : 'FSQRT', 'formBin' : 'R', 'formAsm' : ['FRT', 'FRS'], 'code' : ["%(arg0)s = myfsqrt(%(arg1)s)"]},
	{'type' : 'FABS', 'formBin' : 'R', 'formAsm' : ['FRT', 'FRS'], 'code' : ["%(arg0)s = myfabs(%(arg1)s)"]},
	{'type' : 'FMOV', 'formBin' : 'R', 'formAsm' : ['FRT', 'FRS'], 'code' : ["%(arg0)s = %(arg1)s"]},
	{'type' : 'FNEG', 'formBin' : 'R', 'formAsm' : ['FRT', 'FRS'], 'code' : ["%(arg0)s = myfneg(%(arg1)s)"]},
	{'type' : 'FLOOR', 'formBin' : 'R', 'formAsm' : ['FRT', 'FRS'], 'code' : ["%(arg0)s = myfloor(%(arg1)s)"]},
	{'type' : 'FSIN', 'formBin' : 'R', 'formAsm' : ['FRT', 'FRS'], 'code' : ["%(arg0)s = myfsin(%(arg1)s)"]},
	{'type' : 'FCOS', 'formBin' : 'R', 'formAsm' : ['FRT', 'FRS'], 'code' : ["%(arg0)s = myfcos(%(arg1)s)"]},
	{'type' : 'FTAN', 'formBin' : 'R', 'formAsm' : ['FRT', 'FRS'], 'code' : ["%(arg0)s = myftan(%(arg1)s)"]},
	{'type' : 'FATAN', 'formBin' : 'R', 'formAsm' : ['FRT', 'FRS'], 'code' : ["%(arg0)s = myfatan(%(arg1)s)"]},
	{'type' : 'ITOF', 'formBin' : 'R', 'formAsm' : ['FRT', 'IRS'], 'code' : ["tmp1.f = (float)%(arg1)s", "%(arg0)s = tmp1.i"]},
	{'type' : 'IMOVF', 'formBin' : 'R', 'formAsm' : ['FRT', 'IRS'], 'code' : ["%(arg0)s = %(arg1)s"]},
	{'type' : 'FTOI', 'formBin' : 'R', 'formAsm' : ['IRT', 'FRS'], 'code' : ["tmp1.i = %(arg1)s", "%(arg0)s = (int32_t)tmp1.f"]},
	{'type' : 'FMOVI', 'formBin' : 'R', 'formAsm' : ['IRT', 'FRS'], 'code' : ["%(arg0)s = %(arg1)s"]},
	{'type' : 'SETLO', 'formBin' : 'I', 'formAsm' : ['IRS', 'IMM'], 'code' : ["%(arg0)s = (%(arg0)s & 0xffff0000) | (IMM & 0xffff)"]},
	{'type' : 'SETHI', 'formBin' : 'I', 'formAsm' : ['IRS', 'IMM'], 'code' : ["%(arg0)s = ((uint32_t)IMM << 16) | (%(arg0)s & 0xffff)"]},
	{'type' : 'FSETLO', 'formBin' : 'I', 'formAsm' : ['FRS', 'IMM'], 'code' : ["%(arg0)s = (%(arg0)s & 0xffff0000) | (IMM & 0xffff)"]},
	{'type' : 'FSETHI', 'formBin' : 'I', 'formAsm' : ['FRS', 'IMM'], 'code' : ["%(arg0)s = ((uint32_t)IMM << 16) | (%(arg0)s & 0xffff)"]},
	{'type' : 'BRANCH', 'formBin' : 'J', 'formAsm' : ['LABEL'], 'code' : ["pc = get_address(inst)"]},
	## TODO : RS, RTが逆
	{'type' : 'BEQ', 'formBin' : 'I', 'formAsm' : ['IRS', 'IRT', 'LABEL'], 'code' : [getBranchCode("%(arg0)s == %(arg1)s", "BEQ")]},
	{'type' : 'BNE', 'formBin' : 'I', 'formAsm' : ['IRS', 'IRT', 'LABEL'], 'code' : [getBranchCode("%(arg0)s != %(arg1)s", "BNE")]},
	{'type' : 'BLT', 'formBin' : 'I', 'formAsm' : ['IRS', 'IRT', 'LABEL'], 'code' : [getBranchCode("%(arg0)s <  %(arg1)s", "BLT")]},
	{'type' : 'BLE', 'formBin' : 'I', 'formAsm' : ['IRS', 'IRT', 'LABEL'], 'code' : [getBranchCode("%(arg0)s <= %(arg1)s", "BLE")]},
	{'type' : 'BGT', 'formBin' : 'I', 'formAsm' : ['IRS', 'IRT', 'LABEL'], 'code' : [getBranchCode("%(arg0)s > %(arg1)s", "BGT")]},
	{'type' : 'BGE', 'formBin' : 'I', 'formAsm' : ['IRS', 'IRT', 'LABEL'], 'code' : [getBranchCode("%(arg0)s >= %(arg1)s", "BGE")]},
	{'type' : 'FBEQ', 'formBin' : 'I', 'formAsm' : ['FRS', 'FRT', 'LABEL'], 'code' : [getBranchCode("asF(%(arg0)s) == asF(%(arg1)s)", "FBEQ")]},
	{'type' : 'FBNE', 'formBin' : 'I', 'formAsm' : ['FRS', 'FRT', 'LABEL'], 'code' : [getBranchCode("asF(%(arg0)s) != asF(%(arg1)s)", "FBNE")]},
	{'type' : 'FBLT', 'formBin' : 'I', 'formAsm' : ['FRS', 'FRT', 'LABEL'], 'code' : [getBranchCode("asF(%(arg0)s) < asF(%(arg1)s)", "FBLT")]},
	{'type' : 'FBLE', 'formBin' : 'I', 'formAsm' : ['FRS', 'FRT', 'LABEL'], 'code' : [getBranchCode("asF(%(arg0)s) <= asF(%(arg1)s)", "FBLE")]},
	{'type' : 'FBGT', 'formBin' : 'I', 'formAsm' : ['FRS', 'FRT', 'LABEL'], 'code' : [getBranchCode("asF(%(arg0)s) > asF(%(arg1)s)", "FBGT")]},
	{'type' : 'FBGE', 'formBin' : 'I', 'formAsm' : ['FRS', 'FRT', 'LABEL'], 'code' : [getBranchCode("asF(%(arg0)s) >= asF(%(arg1)s)", "FBGE")]},
	{'type' : 'JMPREG', 'formBin' : 'R', 'formAsm' : ['IRS'], 'code' : ["pc = %(arg0)s"]},
	# スタックやリンクレジスタの退避を行わない関数呼び出し
	{'type' : 'JMP_LNK', 'formBin' : 'J', 'formAsm' : ['LABEL'], 'code' : ["LR = pc", "pc = get_address(inst)"]},
	{'type' : 'JMPREG_LNK', 'formBin' : 'R', 'formAsm' : ['IRS'], 'code' : ["LR = pc", "pc = %(arg0)s"]},
	# スタックやリンクレジスタの退避を行う関数呼び出し
	{'type' : 'CALL', 'formBin' : 'J', 'formAsm' : ['LABEL'], 'code' : ["RAM[FR%s] = LR" % addrDiv, "FR -= %d" % addrUnit, "LR = pc", "pc = get_address(inst)"]},
	{'type' : 'CALLREG', 'formBin' : 'R', 'formAsm' : ['IRS'], 'code' : ["RAM[FR%s] = LR" % addrDiv, "FR -= %d" % addrUnit, "LR = pc", "pc = %(arg0)s"]},
	{'type' : 'RETURN', 'formBin' : 'R', 'formAsm' : [], 'code' : ["pc = LR", "FR += %d" % addrUnit, "LR = RAM[FR%s]" % addrDiv]},
	{'type' : 'ST', 'formBin' : 'R', 'formAsm' : ['IRD', 'IRS', 'IRT'], 'code' : ["RAM[(%%(arg1)s %s %%(arg2)s)%s] = %%(arg0)s" % (dirR, addrDiv)]},
	{'type' : 'LD', 'formBin' : 'R', 'formAsm' : ['IRD', 'IRS', 'IRT'], 'code' : ["%%(arg0)s = RAM[(%%(arg1)s %s %%(arg2)s)%s]" % (dirR, addrDiv)]},
	{'type' : 'FST', 'formBin' : 'R', 'formAsm' : ['FRD', 'IRS', 'IRT'], 'code' : ["RAM[(%%(arg1)s %s %%(arg2)s)%s] = %%(arg0)s" % (dirR, addrDiv)]},
	{'type' : 'FLD', 'formBin' : 'R', 'formAsm' : ['FRD', 'IRS', 'IRT'], 'code' : ["%%(arg0)s = RAM[(%%(arg1)s %s %%(arg2)s)%s]" % (dirR, addrDiv)]},
	{'type' : 'STI', 'formBin' : 'I', 'formAsm' : ['IRT', 'IRS', 'IMM'], 'code' : ["RAM[(%%(arg1)s %s IMM)%s] = %%(arg0)s" % (dirI, addrDiv)]},
	{'type' : 'LDI', 'formBin' : 'I', 'formAsm' : ['IRT', 'IRS', 'IMM'], 'code' : ["%%(arg0)s = RAM[(%%(arg1)s %s IMM)%s]" % (dirI, addrDiv)]},
	{'type' : 'FSTI', 'formBin' : 'I', 'formAsm' : ['FRT', 'IRS', 'IMM'], 'code' : ["RAM[(%%(arg1)s %s IMM)%s] = %%(arg0)s" % (dirI, addrDiv)]},
	{'type' : 'FLDI', 'formBin' : 'I', 'formAsm' : ['FRT', 'IRS', 'IMM'], 'code' : ["%%(arg0)s = RAM[(%%(arg1)s %s IMM)%s]" % (dirI, addrDiv)]},

	# TODO バイナリデータも扱えるよう. 3班ではIRD.
	# 入力・出力ともにテキストデータとして扱う
	{'type' : 'INPUTBYTE', 'formBin' : 'R', 'formAsm' : ['IRS'], 'code' : ["%(arg0)s = getchar() & 0xff"]},
	{'type' : 'INPUTWORD', 'formBin' : 'R', 'formAsm' : ['IRS'], 'code' : ["%(arg0)s = (getchar() & 0xff) << 24", "%(arg0)s |=(getchar() & 0xff) << 16", "%(arg0)s |= (getchar() & 0xff) << 8", "%(arg0)s |= (getchar() & 0xff)"]},
	{'type' : 'INPUTFLOAT', 'formBin' : 'R', 'formAsm' : ['FRS'], 'code' : ["%(arg0)s = (getchar() & 0xff) << 24", "%(arg0)s |=(getchar() & 0xff) << 16", "%(arg0)s |= (getchar() & 0xff) << 8", "%(arg0)s |= (getchar() & 0xff)"]},
	{'type' : 'OUTPUTBYTE', 'formBin' : 'R', 'formAsm' : ['IRS'], 'code' : ["cout << (char)%(arg0)s << flush"]},
	{'type' : 'OUTPUTWORD', 'formBin' : 'R', 'formAsm' : ['IRS'], 'code' : ["cout << (int32_t)%(arg0)s << flush"]},
	{'type' : 'OUTPUTFLOAT', 'formBin' : 'R', 'formAsm' : ['FRS'], 'code' : ["cout << (float)%(arg0)s << flush"]},
	{'type' : 'HALT', 'formBin' : 'R', 'formAsm' : [], 'code' : []}
]

t = Template(filename=sys.argv[2], input_encoding="utf-8", output_encoding="utf-8", encoding_errors="replace")
print t.render(xmlroot=xmlroot, instInfo = instInfo)

