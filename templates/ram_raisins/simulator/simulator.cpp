#include "../include/common.h"
#include <cmath>
#include <cassert>
#include <fcntl.h>

// 命令の各要素にアクセスする関数を定義
#define DEF_ELE_GET(name, shift, mask) \
	uint32_t name(uint32_t inst) {\
		return ((inst >> shift) & mask);\
	}
DEF_ELE_GET(get_opcode, 26, 0x3f)
DEF_ELE_GET(get_rs, 21, 0x1f)
DEF_ELE_GET(get_rt, 16, 0x1f)
DEF_ELE_GET(get_rd, 11, 0x1f)
DEF_ELE_GET(get_shamt, 6, 0x1f)
DEF_ELE_GET(get_funct, 0, 0x3f)
DEF_ELE_GET(get_address, 0, 0x3ffffff)
int32_t get_imm(uint32_t inst)
{
 	if (inst & (1 << 15))
 	{
		// 即値は負の数のとき符号拡張する
 		return (0xffff << 16) | (inst & 0xffff);
 	}
	return inst & 0xffff;
}

//------------------------------------------------------------------

// 整数レジスタ
int32_t ireg[INTREG_NUM];
// 浮動小数レジスタ
uint32_t freg[INTREG_NUM];

// 即値
#define IMM get_imm(inst)
// rs（整数レジスタ）
#define IRS ireg[get_rs(inst)]
// rt（整数レジスタ）
#define IRT ireg[get_rt(inst)]
// rd（整数レジスタ）
#define IRD ireg[get_rd(inst)]
// rs（浮動小数レジスタ）
#define FRS freg[get_rs(inst)]
// rt（浮動小数レジスタ）
#define FRT freg[get_rt(inst)]
// rd（浮動小数レジスタ）
#define FRD freg[get_rd(inst)]
// フレームレジスタ
#define ZR ireg[0] 
// ヒープレジスタ
#define FR ireg[30]
// ゼロレジスタ
#define HR ireg[29]
// リンクレジスタ
#define LR ireg[31]

//------------------------------------------------------------------

// アドレスをバイト/ワードアドレッシングに応じて変換
#define addr(x) (x/* / 4*/)
#define rom_addr(x) (x/* / 4*/)
#define ADDRESSING_UNIT	1
#define ROM_ADDRESSING_UNIT	1

//------------------------------------------------------------------

// 停止命令か
#define isHalt(opcode, funct) (opcode == HLT)

// 発行命令数
long long unsigned cnt;

// ROM
uint32_t ROM[ROM_NUM];
// RAM
uint32_t RAM[(int)(RAM_NUM * 1024 * 1024 / 4)];
// プログラムカウンタ
uint32_t pc;

typedef union{	uint32_t i; float f;} conv;

uint32_t myfadd(uint32_t rs, uint32_t rt)
{
	conv a, b, c;
	a.i = rs;
	b.i = rt;
	c.f = a.f + b.f;
	return c.i;
}
uint32_t myfsub(uint32_t rs, uint32_t rt)
{
	conv a, b, c;
	a.i = rs;
	b.i = rt;
	c.f = a.f - b.f;
	return c.i;
}
uint32_t myfmul(uint32_t rs, uint32_t rt)
{
	conv a, b, c;
	a.i = rs;
	b.i = rt;
	c.f = a.f * b.f;
	return c.i;
}
uint32_t myfdiv(uint32_t rs, uint32_t rt)
{
	conv a, b, c;
	a.i = rs;
	b.i = rt;
	c.f = a.f / b.f;
	return c.i;
}
uint32_t myfinv(uint32_t rs)
{
	conv a, b;
	a.i = rs;
	b.f = 1 / a.f;
	return b.i;
}
uint32_t myfsqrt(uint32_t rs)
{
	conv a, b;
	a.i = rs;
	b.f = sqrt(a.f);
	return b.i;
}
uint32_t myfabs(uint32_t rs)
{
	conv a, b;
	a.i = rs;
	b.f = abs(a.f);
	return b.i;
}
uint32_t myfneg(uint32_t rs)
{
	conv a, b;
	a.i = rs;
	b.f = -a.f;
	return b.i;
}
uint32_t myfloor(uint32_t rs)
{
	conv a, b;
	a.i = rs;
	b.f = floor(a.f);
	return b.i;
}
uint32_t myfsin(uint32_t rs)
{
	conv a, b;
	a.i = rs;
	b.f = sin(a.f);
	return b.i;
}
uint32_t myfcos(uint32_t rs)
{
	conv a, b;
	a.i = rs;
	b.f = cos(a.f);
	return b.i;
}
uint32_t myftan(uint32_t rs)
{
	conv a, b;
	a.i = rs;
	b.f = tan(a.f);
	return b.i;
}
uint32_t myfatan(uint32_t rs)
{
	conv a, b;
	a.i = rs;
	b.f = atan(a.f);
	return b.i;
}
float asF(uint32_t r)
{
	conv a;
	a.i = r;
	return a.f;
}

//-----------------------------------------------------------------------------
//
// エンディアンの変換
//
//-----------------------------------------------------------------------------

#define toggle_endian(data) ((data << 24) | ((data << 8) & 0x00ff0000) | ((data >> 8) & 0x0000ff00) | ((data >> 24) & 0x000000ff))

//-----------------------------------------------------------------------------
//
// シミュレート
//
//-----------------------------------------------------------------------------
int simulate(char* srcPath)
{
	uint32_t inst;

	uint8_t opcode, funct;
	
	conv tmp1;

	// 初期化
	FR = sizeof(RAM) / 4 - 1;
	// cerr << "FR = " << FR << endl;

	// バイナリを読み込む
	FILE* srcFile = fopen(srcPath, "rb");
	if (srcFile == NULL)
	{
		cerr << "couldn't open " << srcPath << endl;
		return 1;
	}
	fread(ROM, 4 * ROM_NUM, 1, srcFile);
	fclose(srcFile);
	
	cerr << srcPath << endl;

	// メインループ
	do
	{
		bool error = false;
	
		ZR = 0;

		// フレーム/ヒープレジスタは絶対に負になることはない
		if (FR < 0)
		{
			cerr << "error> Frame Register(reg[30]) has become less than 0." << endl;
			break;
		}
		if(HR < 0) 
		{
			cerr << "error> Heap Register(reg[29]) has become less than 0." << endl;
			break;
		}

		assert(rom_addr(pc) >= 0);
		inst = toggle_endian(ROM[rom_addr(pc)]);

		opcode = get_opcode(inst);
		funct = get_funct(inst);
		if (ireg[0] != 0)
		{
			cerr << "g0 = " << ireg[0] << endl;
			exit(-1);
		}

		cnt++;
		pc += ROM_ADDRESSING_UNIT;

		// 1億命令発行されるごとにピリオドを一個ずつ出力する（どれだけ命令が発行されたか視覚的にわかりやすくなる）
		if (!(cnt % (100000000)))
		{
			cerr << "." << flush;
		}
		
		// 読み込んだopcode・functに対応する命令を実行する
		switch(opcode)
		{
			case AL:
				switch (funct)
				{
					case ADD_F:
						IRD = IRS + IRT;
						break;
					case SUB_F:
						IRD = IRS - IRT;
						break;
					case MUL_F:
						IRD = IRS * IRT;
						break;
					case AND_F:
						IRD = IRS & IRT;
						break;
					case OR_F:
						IRD = IRS | IRT;
						break;
					case XOR_F:
						IRD = IRS ^ IRT;
						break;
					default:
						break;
				}			
				break;
			case FPA:
				switch (funct)
				{
					case FADD_F:
						FRD = myfadd(FRS, FRT);
						break;
					case FSUB_F:
						FRD = myfsub(FRS, FRT);
						break;
					case FMUL_F:
						FRD = myfmul(FRS, FRT);
						break;
					case FINV_F:
						FRD = myfinv(FRS);
						break;
					case FSQRT_F:
						FRD = myfsqrt(FRS);
						break;
					case FNEG_F:
						FRD = myfneg(FRS);
						break;
					default:
						break;
				}			
				break;
			case MOV:
				IRT = IRS;
				break;
			case ADDI:
				IRT = IRS + IMM;
				break;
			case SUBI:
				IRT = IRS - IMM;
				break;
			case MULI:
				IRT = IRS * IMM;
				break;
			case SLLI:
				IRT = IRS << IMM;
				break;
			case SRLI:
				IRT = IRS >> IMM;
				break;
			case ANDI:
				IRT = IRS & IMM;
				break;
			case ORI:
				IRT = IRS | IMM;
				break;
			case XORI:
				IRT = IRS ^ IMM;
				break;
			case FMOV:
				FRT = FRS;
				break;
			case IMOVF:
				memcpy(&FRT, &IRS, 4);
				break;
			case FMOVI:
				memcpy(&IRT, &FRS, 4);
				break;
			case LLI:
				IRS = (IRS & 0xffff0000) | (IMM & 0xffff);
				break;
			case LUI:
				IRS = ((uint32_t)IMM << 16) | (IRS & 0xffff);
				break;
			case FLLI:
				FRS = (FRS & 0xffff0000) | (IMM & 0xffff);
				break;
			case FLUI:
				FRS = ((uint32_t)IMM << 16) | (FRS & 0xffff);
				break;
			case J:
				pc = get_address(inst);
				break;
			case BNE:
				if (IRS != IRT) pc += IMM - 1;
				break;
			case BLT:
				if (IRS <  IRT) pc += IMM - 1;
				break;
			case FBNE:
				if (asF(FRS) != asF(FRT)) pc += IMM - 1;
				break;
			case FBLT:
				if (asF(FRS) < asF(FRT)) pc += IMM - 1;
				break;
			case JR:
				pc = IRS;
				break;
			case JAL:
				LR = pc;
				pc = get_address(inst);
				break;
			case JALR:
				LR = pc;
				pc = IRS;
				break;
			case STORE:
				assert(IRS + IMM >= 0);
				RAM[(IRS + IMM)] = IRT;
				break;
			case LOAD:
				assert(IRS + IMM >= 0);
				IRT = RAM[(IRS + IMM)];
				break;
			case IOLD:
				IRT = getchar() & 0xff;
				break;
			case IOST:
				cout << (char)IRS << flush;
				break;
			case HLT:
				break;
			default:
				cerr << "invalid opcode. (opcode = " << (int)opcode << ", funct = " << (int)funct <<  ", pc = " << pc << ")" << endl;
				break;
		}
	}
	while (!isHalt(opcode, funct)); // hltが来たら終了

	// 発行命令数を表示
	cerr << "\n" << cnt << " instructions had been issued" << endl;

	return 0;
} 

int main(int argc, char** argv)
{
	if (argc <= 1)
	{
		cerr << "usage: ./simulator binaryfile" << endl;
		return 1;
	}
	
	cerr << "<simulate> ";
	
	simulate(argv[1]);

	return 0;
}

