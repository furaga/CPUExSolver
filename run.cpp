#include "mainwindow.h"
#include <QFileInfo>

//=============================================================
//
// 「実行」メニュー系
//
//  1.アセンブリをアセンブラでアセンブルして
//  2.シミュレータで実行
//
//=============================================================

//-------------------------------------------------------------
// アセンブリをアセンブラでバイナリにアセンブル
//-------------------------------------------------------------
void MainWindow::assemble(const QString& assembler, const QString& src, const QString& binary) {
    process->start(
                QFileInfo(assembler).canonicalFilePath() + " " +
                QFileInfo(src).canonicalFilePath() /*+ " " +
                QFileInfo(target).canonicalFilePath()*/
    );
    process->waitForFinished();
    updateOutput();
    updateError();
}

//-------------------------------------------------------------
// シミュレータでバイナリを実行
//-------------------------------------------------------------
void MainWindow::simulate(const QString &simulator, const QString &binary) {
    process->start(
                QFileInfo(simulator).canonicalFilePath() + " " +
                QFileInfo(binary).canonicalFilePath()
    );
    process->waitForFinished();
    updateOutput();
    updateError();
}

//-------------------------------------------------------------
// 実行（アセンブル＋シミュレート）。ファイル名指定版
//-------------------------------------------------------------
void MainWindow::run(const QString& base) {
    QString src = "./asm/" + base + ".s";
    QString binary = "./asm/" + base + ".bin";
//    QString binary = "./bin/" + base + ".bin";
    ui->textEdit->append("[" + base + "]");
    ui->textEdit->append("assemble...");
    assemble("./tools/asmcho", src, binary);
    ui->textEdit->append("simulate...");
    simulate("./tools/simcho", binary);
}

//-------------------------------------------------------------
// スタートアッププロジェクトを実行（アセンブル＋シミュレート）
//-------------------------------------------------------------
void MainWindow::run() {
    QString base = QFileInfo(startupProject->whatsThis(0)).completeBaseName();

    run(base);
}

//-------------------------------------------------------------
// 開かれているすべてのプロジェクトを実行
//-------------------------------------------------------------
void MainWindow::runAll() {
    for (int i = 0; i < ui->treeWidget->topLevelItemCount(); i++) {
        QString base = QFileInfo(ui->treeWidget->topLevelItem(i)->whatsThis(0)).completeBaseName();
        if (base == "") continue;
        run(base);
    }
}
