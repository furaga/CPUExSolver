//=============================================================
//
// アセンブリファイル同士のリンクを行う
//
//=============================================================
#include "linker.h"
#include <QMessageBox>
#include <QList>
// TODO
#define DATA_UNIT_SIZE 32

linker::linker()
{

}

bool linker::open(const QString filepath, QFile& file, QTextStream& stream, QFlags<QIODevice::OpenModeFlag> flgs) {
    if (filepath.endsWith(".s") == false) {
        QMessageBox::critical(
                    NULL,
                    "invalid file name",
                    "source file must be assembly file(" + filepath + ")",
                    QMessageBox::Ok,
                    QMessageBox::Cancel);
        return false;
    }
    file.setFileName(filepath);
    if (file.open(flgs) == false) {
        QMessageBox::critical(
                    NULL,
                    "can't open file",
                    "can't open " + filepath,
                    QMessageBox::Ok,
                    QMessageBox::Cancel);
        return false;
    }
    stream.setDevice(&file);
    return true;
}

void linker::close(QFile& file) {
    file.close();
}

int linker::getHeapSize(QTextStream &stream) {
    const QString& line = "";
    QRegExp r("[.]init[_]heap[_]size[ \\t]+(\\d+)");
    while (stream.atEnd() == false) {
        const QString& line = stream.readLine();
        int pos = r.indexIn(line);
        if (pos > -1) {
            return r.cap(1).toInt();
        }
    }
    return 0;
}

void linker::writeHeapInitialize(QTextStream& stream, int heap_size, QTextStream& out) {
    const QString& line = "";
    while (stream.atEnd() == false && heap_size > 0) {
        const QString& line = stream.readLine();
        out << line << endl;
        bool flg = false;
        flg |= line.trimmed().startsWith(".int");
        flg |= line.trimmed().startsWith(".long");
        flg |= line.trimmed().startsWith(".float");
        if (flg) {
            heap_size -= DATA_UNIT_SIZE;
        }
    }
}

bool linker::link(QStringList srcs, QString dst) {
    int cnt = srcs.count();
    QTextStream stream[cnt + 1];
    QFile file[cnt + 1];

    // ソースファイルを開く
    for (int i = 0; i < cnt; i++) {
        if (open(srcs[i], file[i], stream[i], QIODevice::ReadWrite | QIODevice::Text) == false) return false;
    }

    // 出力ファイルを開く
    if (open(dst, file[cnt], stream[cnt], QIODevice::WriteOnly | QIODevice::Text) == false) return false;

    // ヒープサイズを合計する
    int heap_size = 0;
    int heap_sizes[cnt];
    for (int i = 0; i < cnt; i++) {
        heap_sizes[i] = getHeapSize(stream[i]);
        heap_size += heap_sizes[i];
    }

    // ヒープサイズを書き込む
    stream[cnt] << ".init_heap_size\t" << heap_size << endl;

    // ヒープの初期化部分の書き込み
    for (int i = 0; i < cnt; i++) {
        writeHeapInitialize(stream[i], heap_sizes[i], stream[cnt]);
    }

    // メイン関数へのジャンプ命令
    stream[cnt] << "\tjmp\tmin_caml_start" << endl;

    // その他のコードの書き込み
    QRegExp r("jmp[ \t]+min_caml_start");
    for (int i = 0; i < cnt; i++) {
        while (stream[i].atEnd() == false) {
            const QString& line = stream[i].readLine();
            int pos = r.indexIn(line.trimmed());
            if (pos > -1) continue;
            stream[cnt] << line << endl;
        }
    }

    for (int i = 0; i < cnt + 1; i++) {
        close(file[i]);
    }

    return true;
}
