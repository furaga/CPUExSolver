#coding:utf-8
import sys
from mako.template import Template
from xml.etree.ElementTree import *

xml = parse(sys.argv[1]) # 返値はElementTree型
xmlroot = xml.getroot()

addrUnit = 4 if xmlroot.find(".//binary").get("addressing") == "byte" else 1
addrDiv = " / 4" if addrUnit == 4 else ""
direction =  xmlroot.find(".//binary").get("direction")

dirR = "-" if direction == "toSmall" else "+"
dirI = "+" if direction == "toBig" else "-"

def getAddrMode(type):
	return xmlroot.find(".//" + type).get("addressMode")

def getBranchCode(cond, type):
	return "if (" + cond + ") pc " + ("+= IMM - %d" % addrUnit if getAddrMode('BEQ') == 'relative' else "= IMM")

instInfo = [
	{'type' : 'MOV', 'formBin' : 'R', 'formAsm' : 'RR', 'code' : ["IRT = IRS"]},
	{'type' : 'ADD', 'formBin' : 'R', 'formAsm' : 'RRR', 'code' : ["IRD = IRS + IRT"]},
	{'type' : 'SUB', 'formBin' : 'R', 'formAsm' : 'RRR', 'code' : ["IRD = IRS - IRT"]},
	{'type' : 'MUL', 'formBin' : 'R', 'formAsm' : 'RRR', 'code' : ["IRD = IRS * IRT"]},
	{'type' : 'DIV', 'formBin' : 'R', 'formAsm' : 'RRR', 'code' : ["IRD = IRS / IRT"]},
	{'type' : 'SLL', 'formBin' : 'R', 'formAsm' : 'RRR', 'code' : ["IRD = IRS << IRT"]},
	{'type' : 'SLA', 'formBin' : 'R', 'formAsm' : 'RRR', 'code' : ["IRD = IRS << IRT"]},
	{'type' : 'SRL', 'formBin' : 'R', 'formAsm' : 'RRR', 'code' : ["IRD = (unsigned)IRS >> IRT)"]},
	# g++ (Ubuntu 4.4.3-4ubuntu5) 4.4.3ではint32_tに対する >> 演算子は算術シフト
	{'type' : 'SRA', 'formBin' : 'R', 'formAsm' : 'RRR', 'code' : ["IRD = IRS >> IRT"]},
	# bool値の演算ではなく、ビット列に対する演算
	{'type' : 'AND', 'formBin' : 'R', 'formAsm' : 'RRR', 'code' : ["IRD = IRS & IRT"]},
	{'type' : 'OR', 'formBin' : 'R', 'formAsm' : 'RRR', 'code' : ["IRD = IRS | IRT"]},
	{'type' : 'NOR', 'formBin' : 'R', 'formAsm' : 'RRR', 'code' : ["IRD = ~(IRS | IRT)"]},
	{'type' : 'XOR', 'formBin' : 'R', 'formAsm' : 'RRR', 'code' : ["IRD = IRS ^ IRT"]},
	{'type' : 'NOT', 'formBin' : 'R', 'formAsm' : 'RR', 'code' : ["IRD = ~IRS"]},
	{'type' : 'ADDI', 'formBin' : 'I', 'formAsm' : 'RRI', 'code' : ["IRT = IRS + IMM"]},
	{'type' : 'SUBI', 'formBin' : 'I', 'formAsm' : 'RRI', 'code' : ["IRT = IRS - IMM"]},
	{'type' : 'MULI', 'formBin' : 'I', 'formAsm' : 'RRI', 'code' : ["IRT = IRS * IMM"]},
	{'type' : 'DIVI', 'formBin' : 'I', 'formAsm' : 'RRI', 'code' : ["IRT = IRS / IMM"]},
	{'type' : 'SLLI', 'formBin' : 'I', 'formAsm' : 'RRI', 'code' : ["IRT = IRS << IMM"]},
	{'type' : 'SLAI', 'formBin' : 'I', 'formAsm' : 'RRI', 'code' : ["IRT = IRS << IMM"]},
	{'type' : 'SRLI', 'formBin' : 'I', 'formAsm' : 'RRI', 'code' : ["IRT = (unsigned)IRS >> IMM"]},
	{'type' : 'SRAI', 'formBin' : 'I', 'formAsm' : 'RRI', 'code' : ["IRT = IRS >> IMM"]},
	{'type' : 'ANDI', 'formBin' : 'I', 'formAsm' : 'RRI', 'code' : ["IRT = IRS & IMM"]},
	{'type' : 'ORI', 'formBin' : 'I', 'formAsm' : 'RRI', 'code' : ["IRT = IRS | IMM"]},
	{'type' : 'NORI', 'formBin' : 'I', 'formAsm' : 'RRI', 'code' : ["IRT = ~(IRS | IMM)"]},
	{'type' : 'XORI', 'formBin' : 'I', 'formAsm' : 'RRI', 'code' : ["IRT = IRS ^ IMM"]},
	{'type' : 'FADD', 'formBin' : 'R', 'formAsm' : 'FFF', 'code' : ["FRD = myfadd(FRS, FRT)"]},
	{'type' : 'FSUB', 'formBin' : 'R', 'formAsm' : 'FFF', 'code' : ["FRD = myfsub(FRS, FRT)"]},
	{'type' : 'FMUL', 'formBin' : 'R', 'formAsm' : 'FFF', 'code' : ["FRD = myfmul(FRS, FRT)"]},
	{'type' : 'FDIV', 'formBin' : 'R', 'formAsm' : 'FFF', 'code' : ["FRD = myfdiv(FRS, FRT)"]},
	{'type' : 'FINV', 'formBin' : 'R', 'formAsm' : 'FF', 'code' : ["FRD = myfinv(FRS, FRT)"]},
	{'type' : 'FSQRT', 'formBin' : 'R', 'formAsm' : 'FF', 'code' : ["FRT = myfsqrt(FRS)"]},
	{'type' : 'FABS', 'formBin' : 'R', 'formAsm' : 'FF', 'code' : ["FRT = myfabs(FRS)"]},
	{'type' : 'FMOV', 'formBin' : 'R', 'formAsm' : 'FF', 'code' : ["FRT = FRS"]},
	{'type' : 'FNEG', 'formBin' : 'R', 'formAsm' : 'FF', 'code' : ["FRT = myfneg(FRS)"]},
	{'type' : 'FLOOR', 'formBin' : 'R', 'formAsm' : 'FF', 'code' : ["FRT = myfloor(FRS)"]},
	{'type' : 'FSIN', 'formBin' : 'R', 'formAsm' : 'FF', 'code' : ["FRT = myfsin(FRS)"]},
	{'type' : 'FCOS', 'formBin' : 'R', 'formAsm' : 'FF', 'code' : ["FRT = myfcos(FRS)"]},
	{'type' : 'FTAN', 'formBin' : 'R', 'formAsm' : 'FF', 'code' : ["FRT = myftan(FRS)"]},
	{'type' : 'FATAN', 'formBin' : 'R', 'formAsm' : 'FF', 'code' : ["FRT = myfatan(FRS)"]},
	{'type' : 'ITOF', 'formBin' : 'R', 'formAsm' : 'FI', 'code' : ["tmp1.f = (float)IRS", "FRT = tmp1.i"]},
	{'type' : 'IMOVF', 'formBin' : 'R', 'formAsm' : 'FI', 'code' : ["FRT = IRS"]},
	{'type' : 'FTOI', 'formBin' : 'R', 'formAsm' : 'IF', 'code' : ["tmp1.i = FRS", "IRT = (int32_t)tmp1.f"]},
	{'type' : 'FMOVI', 'formBin' : 'R', 'formAsm' : 'IF', 'code' : ["IRT = FRS"]},
	{'type' : 'ASSIGNLO', 'formBin' : 'I', 'formAsm' : 'RI', 'code' : ["IRS = (IRS & 0xffff0000) | (IMM & 0xffff)"]},
	{'type' : 'ASSIGNHI', 'formBin' : 'I', 'formAsm' : 'RI', 'code' : ["IRS = ((uint32_t)IMM << 16) | (IRS & 0xffff)"]},
	{'type' : 'FASSIGNLO', 'formBin' : 'I', 'formAsm' : 'FI', 'code' : ["FRS = (FRS & 0xffff0000) | (IMM & 0xffff)"]},
	{'type' : 'FASSIGNHI', 'formBin' : 'I', 'formAsm' : 'FI', 'code' : ["FRS = ((uint32_t)IMM << 16) | (FRS & 0xffff)"]},
	{'type' : 'BRANCH', 'formBin' : 'J', 'formAsm' : 'L', 'code' : ["pc = get_address(inst)"]},
	
	## TODO : RS, RTが逆
	{'type' : 'BEQ', 'formBin' : 'I', 'formAsm' : 'RRL', 'code' : [getBranchCode("IRS == IRT", "BEQ")]},
	{'type' : 'BNE', 'formBin' : 'I', 'formAsm' : 'RRL', 'code' : [getBranchCode("IRS != IRT", "BNE")]},
	{'type' : 'BLT', 'formBin' : 'I', 'formAsm' : 'RRL', 'code' : [getBranchCode("IRS > IRT", "BLT")]},
	{'type' : 'BLE', 'formBin' : 'I', 'formAsm' : 'RRL', 'code' : [getBranchCode("IRS >= IRT", "BLE")]},
	{'type' : 'BGT', 'formBin' : 'I', 'formAsm' : 'RRL', 'code' : [getBranchCode("IRS < IRT", "BGT")]},
	{'type' : 'BGE', 'formBin' : 'I', 'formAsm' : 'RRL', 'code' : [getBranchCode("IRS <= IRT", "BGE")]},
	{'type' : 'FBEQ', 'formBin' : 'I', 'formAsm' : 'FFL', 'code' : [getBranchCode("asF(FRS) == asF(FRT)", "FBEQ")]},
	{'type' : 'FBNE', 'formBin' : 'I', 'formAsm' : 'FFL', 'code' : [getBranchCode("asF(FRS) != asF(FRT)", "FBNE")]},
	{'type' : 'FBLT', 'formBin' : 'I', 'formAsm' : 'FFL', 'code' : [getBranchCode("asF(FRS) > asF(FRT)", "FBLT")]},
	{'type' : 'FBLE', 'formBin' : 'I', 'formAsm' : 'FFL', 'code' : [getBranchCode("asF(FRS) >= asF(FRT)", "FBLE")]},
	{'type' : 'FBGT', 'formBin' : 'I', 'formAsm' : 'FFL', 'code' : [getBranchCode("asF(FRS) < asF(FRT)", "FBGT")]},
	{'type' : 'FBGE', 'formBin' : 'I', 'formAsm' : 'FFL', 'code' : [getBranchCode("asF(FRS) <= asF(FRT)", "FBGE")]},
	{'type' : 'JMPREG', 'formBin' : 'R', 'formAsm' : 'R', 'code' : ["pc = IRS"]},
	{'type' : 'CALL', 'formBin' : 'J', 'formAsm' : 'L', 'code' : ["RAM[FR%s] = LR" % addrDiv, "FR -= %d" % addrUnit, "LR = pc", "pc = get_address(inst)"]},
	{'type' : 'CALLREG', 'formBin' : 'R', 'formAsm' : 'R', 'code' : ["RAM[FR%s] = LR" % addrDiv, "FR -= %d" % addrUnit, "LR = pc", "pc = IRS"]},
	{'type' : 'RETURN', 'formBin' : 'R', 'formAsm' : '', 'code' : ["pc = LR", "FR += %d" % addrUnit, "LR = RAM[FR%s]" % addrDiv]},
	{'type' : 'ST', 'formBin' : 'R', 'formAsm' : 'RRR', 'code' : ["RAM[(IRS %s IRT)%s] = IRD" % (dirR, addrDiv)]},
	{'type' : 'LD', 'formBin' : 'R', 'formAsm' : 'RRR', 'code' : ["IRD = RAM[(IRS %s IRT)%s]" % (dirR, addrDiv)]},
	{'type' : 'FST', 'formBin' : 'R', 'formAsm' : 'FRR', 'code' : ["RAM[(IRS %s IRT)%s] = FRD" % (dirR, addrDiv)]},
	{'type' : 'FLD', 'formBin' : 'R', 'formAsm' : 'FRR', 'code' : ["FRD = RAM[(IRS %s IRT)%s]" % (dirR, addrDiv)]},
	{'type' : 'STI', 'formBin' : 'I', 'formAsm' : 'RRI', 'code' : ["RAM[(IRS %s IMM)%s] = IRT" % (dirI, addrDiv)]},
	{'type' : 'LDI', 'formBin' : 'I', 'formAsm' : 'RRI', 'code' : ["IRT = RAM[(IRS %s IMM)%s]" % (dirI, addrDiv)]},
	{'type' : 'FSTI', 'formBin' : 'I', 'formAsm' : 'FRI', 'code' : ["RAM[(IRS %s IMM)%s] = FRT" % (dirI, addrDiv)]},
	{'type' : 'FLDI', 'formBin' : 'I', 'formAsm' : 'FRI', 'code' : ["FRT = RAM[(IRS %s IMM)%s]" % (dirI, addrDiv)]},

	# TODO バイナリデータも扱えるよう. 3班ではIRD.
	# 入力・出力ともにテキストデータとして扱う
	{'type' : 'INPUTBYTE', 'formBin' : 'R', 'formAsm' : 'R', 'code' : ["IRS = getchar() & 0xff"]},
	{'type' : 'INPUTWORD', 'formBin' : 'R', 'formAsm' : 'R', 'code' : ["IRS = (getchar() & 0xff) << 24", "IRS |=(getchar() & 0xff) << 16", "IRS |= (getchar() & 0xff) << 8", "IRS |= (getchar() & 0xff)"]},
	{'type' : 'INPUTFLOAT', 'formBin' : 'R', 'formAsm' : 'F', 'code' : ["FRS = (getchar() & 0xff) << 24", "FRS |=(getchar() & 0xff) << 16", "FRS |= (getchar() & 0xff) << 8", "FRS |= (getchar() & 0xff)"]},
	{'type' : 'OUTPUTBYTE', 'formBin' : 'R', 'formAsm' : 'R', 'code' : ["cout << (char)IRS << flush"]},
	{'type' : 'OUTPUTWORD', 'formBin' : 'R', 'formAsm' : 'R', 'code' : ["cout << (int32_t)IRS << flush"]},
	{'type' : 'OUTPUTFLOAT', 'formBin' : 'R', 'formAsm' : 'F', 'code' : ["cout << (float)IRS << flush"]},
	{'type' : 'HALT', 'formBin' : 'R', 'formAsm' : '', 'code' : []}
]

t = Template(filename=sys.argv[2], input_encoding="utf-8", output_encoding="utf-8", encoding_errors="replace")
print t.render(xmlroot=xmlroot, instInfo = instInfo)

