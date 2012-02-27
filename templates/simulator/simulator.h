#include "../dst/assembler/common.h"

#include <cmath>

#define DEF_ELE_ACC(name, shift, mask) 	uint32_t name(uint32_t inst) {		return ((inst >> shift) & mask);	}

int32_t reg[INTREG_NUM];
uint32_t freg[INTREG_NUM];
uint32_t ROM[ROM_NUM];
uint32_t RAM[(int)(RAM_NUM * 1024 * 1024 / 4)];
uint32_t pc;

// TODO
uint32_t lr;

// 発行命令数
long long unsigned cnt;

//TODO
void to_bin(uint32_t);
#define dump(x) fprintf(stderr, "%s: ", #x); to_bin(x);
#define SIGN(x) (((x)&0x80000000)>>31)
#define ELSE(x) ((x)&0x7fffffff)

// 命令の各要素にアクセスする関数を定義
DEF_ELE_GET(get_opcode, 26, 0x3f);		
DEF_ELE_GET(get_rsi, 21, 0x1f);
DEF_ELE_GET(get_rti, 16, 0x1f);
DEF_ELE_GET(get_rdi, 11, 0x1f);
DEF_ELE_GET(get_shamt, 6, 0x1f);
DEF_ELE_GET(get_funct, 0, 0x3f);
DEF_ELE_GET(get_address, 0, 0x3ffffff);

// 即値は負の数のとき符号拡張する
int32_t get_imm(uint32_t inst)
{
 	if (inst & (1 << 15))
 	{
 		return (0xffff << 16) | (inst & 0xffff)
 	}
	return inst & 0xffff;
}


