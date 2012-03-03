#include "assembler.h"

// ニーモニックが複数の命令に分解されたときの格納先
char mnemonicBuffer[16][MAX_LINE_SIZE];
// 命令読み込みに使われるバッファ
char* buffer = mnemonicBuffer[0];
// 命令コード
char instName[MAX_LINE_SIZE];
// ヒープサイズ
uint32_t heapSize = 0;
// ラベルが使用される命令の番号と、どのラベルが使われるのかの対応表
map<uint32_t, string> labelNames;
// ラベルと対応する行数
map<string, uint32_t> labels;
// 現在何行目を読み込んでいるか
uint32_t cur = 1;
// アセンブルして得られたバイナリ列. 第二要素はラベルを使うか。setLを分解したときのaddiの処理などに使う
vector<pair<uint32_t, bool> > binaries;

// 入力・出力ファイル
FILE* srcFile;
FILE* dstFile;

//-----------------------------------------------------------------------------
//
// エンディアンの変換
//
//-----------------------------------------------------------------------------
uint32_t endian(uint32_t data, bool isBig)
{
	// デフォルトではリトルエンディアンなので、
	// ビッグエンディアンが選択されたときに切り替える
	if (isBig)
	{
		return (data << 24) | ((data << 8) & 0x00ff0000) | ((data >> 8) & 0x0000ff00) | ((data >> 24) & 0x000000ff);
	}
	return data;
}

void push(vector<pair<uint32_t, bool> >& vec, uint32_t data, bool useLabel = false)
{
	vec.push_back(make_pair(data, useLabel));
}

//-----------------------------------------------------------------------------
//
// ラベル名から対応するアドレスを得る。base = 0なら絶対アドレス
//
//-----------------------------------------------------------------------------
uint32_t getAddr(string label, uint32_t base = 0)
{
	if (labels.count(label) == 0)
	{
		cerr << label << " is not assigned in labels" << endl;
		exit(-1);
	}
	uint32_t addr = labels[label];
	
//	cerr << "addr of " << label << " is " << addr << endl; 
	
	return  addr - base;
}

//-----------------------------------------------------------------------------
//
// 命令コマンドを順に読んでいく
//
//-----------------------------------------------------------------------------
bool readInstructions()
{
	bool error = false;
	char* str = NULL;

	while(fgets(buffer, MAX_LINE_SIZE, srcFile) != NULL)
	{
		if(sscanf(buffer, "%s", instName) == 1)
		{
 	 	 	if(strchr(buffer,':'))
			{
 	 	 		// ラベル
 	 	 		if((str = strtok(instName, ":")) == NULL)
				{
					cerr << "error at label line " << cur << " >" << buffer << endl;
					error = true;
				}
				labels[str] = binaries.size() * 4;
			}
			else if (string(instName).find("!") == 0)
			{
				// コメント
			}
			else
			{
				// 命令コマンド

				// ニーモニックを解決
				vector<bool> useLabels = mnemonic(instName, mnemonicBuffer, labelNames, binaries.size());

				// 普通useLabels.size()は１だが、instNameがニーモニックで複数命令に分解されたら１より大きい値になる
				rep(i, useLabels.size())
				{
					sscanf(mnemonicBuffer[i], "%s", instName);
					uint32_t enc = 0;
					bool useLabel = false;
					bool result = encode(instName, mnemonicBuffer[i], labelNames, binaries.size(), enc, useLabel);
					if (result == false)
					{
						cerr << "error at inst line " << cur << " >" << buffer << endl;
						error = true;
					}
					else
					{
						push(binaries, enc, useLabel | useLabels[i]);
					}
				}
			}
		}
		cur++;
	}

	return error == false;
}

//-----------------------------------------------------------------------------
//
// ラベル解決
//
//-----------------------------------------------------------------------------
void resolveLabels()
{
	for (int i = 0; i < binaries.size(); i++)
	{
		// ラベルを使わない命令なら飛ばす
		if (binaries[i].second == false)
		{
			continue;
		}
		
		// 命令の種類を取得
		uint32_t instType = (binaries[i].first & 0xfc000000) >> 26;
		string name;
		switch (instType)
		{ 
			// I形式
			case JEQ:
			case JNE:
			case JLT:
			case FJEQ:
			case FJNE:
			case FJLT:
				if (labelNames.count(i) <= 0)
				{
					cout << i << " is not assigned in labelNames.(" << i << ")" << endl;
					exit(-1);
				} 
				name = labelNames[i];
				binaries[i].first = (binaries[i].first & 0xffFF0000) | (getAddr(name, 4 * i) & 0xffFF);
				break;
			case ADDI:
			case SUBI:
			case MULI:
			case SLLI:
			case SRLI:
			case MVLO:
			case MVHI:
			case FMVLO:
			case FMVHI:
			case STI:
			case LDI:
			case FSTI:
			case FLDI:
				if (labelNames.count(i) <= 0)
				{
					cout << i << " is not assigned in labelNames.(" << i << ")" << endl;
					exit(-1);
				} 
				name = labelNames[i];
				binaries[i].first = (binaries[i].first & 0xffFF0000) | (getAddr(name) & 0xffFF);
				break;
			case JMP:
			case CALL:
				// 絶対アドレス
				if (labelNames.count(i) <= 0)
				{
					cout << i << " is not assigned in labelNames.(" << i << ")" << endl;
					exit(-1);
				} 
				name = labelNames[i];
				binaries[i].first = (binaries[i].first & 0xfc000000) | (getAddr(name) & 0x3FFffFF);
				break;
			default:
				break;
		}
	}
}

//-----------------------------------------------------------------------------
//
// 出力
//
//-----------------------------------------------------------------------------
void output()
{
	rep(i, binaries.size())
	{
		binaries[i].first = endian(binaries[i].first, true);
		fwrite(&binaries[i].first, sizeof(uint32_t), 1, dstFile);
	}
}

//-----------------------------------------------------------------------------
//
// アセンブル
//
//-----------------------------------------------------------------------------
bool assemble(const char* srcPath, const char* dstPath)
{
	bool error = false;
	
	// 入力ファイルを開く
	srcFile = fopen(srcPath, "r");
	if (srcFile == NULL)
	{
		cerr << "couldn't open " << srcPath << endl;
		return false;
	}

	bool result = false;


	cerr << "cur = " << cur << endl;

	// ラベルや各コマンドを読み込む
	result = readInstructions();
	if (result == false)
	{
		cerr << "couldn't read instruction datas correctly" << endl;
		error = true;
	}

	// 入力ファイルを閉じる
	fclose(srcFile);

	// エラーが起きてればこの時点で戻るa
	if (error)
	{
		return false;
	}

	// ラベル解決
	resolveLabels();

	// 出力ファイルを開く
	dstFile = fopen(dstPath, "w");
	if (dstFile == NULL)
	{
		cerr << "couldn't open " << dstPath << endl;
		return false;
	}

	// 出力
	output();

	// 出力ファイルを閉じる
	fclose(dstFile);

	return true;
}

int main(int argc, char** argv)
{
	// コマンド引数から入力ファイル・出力ファイルを探す
	int src = 0, dst = 0;
	repi(i, argc)
	{
		if (argv[i][0] != '-')
		{
			if (src <= 0) src = i;
			else dst = i;
		}
	}

	if (src <= 0 || dst <= 0)
	{
		cerr << "usage: ./assembler src dst" << endl;
		return 1;
	}

	cerr << "<assemble> ";
	
	bool result = assemble(argv[src], argv[dst]);
	
	if (result)
	{
		cerr << argv[src] << " => " << argv[dst] << endl;
	}
	else
	{
		cerr << "couldn't assemble " << argv[src] << endl;
	}

	return 0;
}


