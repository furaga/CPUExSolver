#include "mainwindow.h"
#include <QFileInfo>
#include <QProcess>

//=============================================================
//
// 「実行」メニュー系
//
//  1.lib_ml.mlをくっつけて(src.ml -> __tmp__.ml)
//  2.min-caml.optでコンパイルし（-> __tmp__.s)
//  3.lib_asm.sとリンクする（-> src.s）
//
//=============================================================

void MainWindow::initBuild() {
    process = new QProcess(this);
    QObject::connect(process, SIGNAL(readyReadStandardOutput()), this, SLOT(updateOutput()));
    QObject::connect(process, SIGNAL(readyReadStandardError()), this, SLOT(updateError()) );
    QObject::connect(
                process, SIGNAL(error(QProcess::ProcessError)),
                this, SLOT(processError(QProcess::ProcessError)));
    QObject::connect(
                process, SIGNAL(finished(int, QProcess::ExitStatus)),
                this, SLOT(proc_finished(int, QProcess::ExitStatus)));
}

void MainWindow::processError(QProcess::ProcessError err) {
    ui->textEdit->append(QString("err = %1").arg(err));
}

void MainWindow::proc_finished(int ret, QProcess::ExitStatus stat) {
    ui->textEdit->append(QString("ret = %1, stat = %2").arg(ret).arg(stat));
    updateOutput();
    updateError();
}

void MainWindow::updateOutput() {
    QByteArray output = process->readAllStandardOutput();
    QString str = QString::fromLocal8Bit(output);
    ui->textEdit->append(str);
}

void MainWindow::updateError() {
    QByteArray output = process->readAllStandardError();
    QString str = QString::fromLocal8Bit(output);
    ui->textEdit_2->append(str);
}

//-------------------------------------------------------------
// MLファイルを結合する。catだとなんかうまくいかなかったので自力でつなげている
//-------------------------------------------------------------
bool MainWindow::link_ml(QStringList files, QString target) {
    int cnt = files.count();

    // 出力ファイルを開く
    QFile out(target);
    if (out.open(QIODevice::WriteOnly | QIODevice::Text) == false) {
        errorMsg("cant open " + target);
        return false;
    }

    // 入力ファイルの内容を順次書き込んでいく
    QFile in;
    QTextStream sin;
    QTextStream sout(&out);
    for (int i = 0; i < cnt; i++) {
        in.setFileName(files[i]);
        if (in.open(QIODevice::ReadOnly | QIODevice::Text) == false) {
            errorMsg("can't open " + files[i]);
            out.close();
            return false;
        }
        sin.setDevice(&in);
        QString str = sin.readAll();
        sout << str;
        in.close();
    }

    // 後始末
    out.close();

    return true;
}

//-------------------------------------------------------------
//
//-------------------------------------------------------------
bool MainWindow::link_asm(QStringList files, QString target) {
    linker link;
    link.link(files, target);
    return true;
}

//-------------------------------------------------------------
//
//-------------------------------------------------------------
bool MainWindow::compile(QString compiler, QString target) {
    QString compilerPath = QFileInfo(compiler).canonicalFilePath();
    QString targetDir = QFileInfo(target).canonicalPath();
    QString targetName = QFileInfo(target).completeBaseName();
    process->setWorkingDirectory(targetDir);
    process->start(compilerPath + " " + targetName);
    process->waitForFinished();
    updateOutput();
    updateError();
    return true;
}

bool MainWindow::build(const QString& src) {
    QString srcBaseName = QFileInfo(src).completeBaseName();
    QString tmp = "./asm/__temp__";

    ui->textEdit->append("[" + srcBaseName + "]");
    ui->textEdit->append("link ml library files...");
    if (link_ml(QStringList() << "./lib/lib_ml.ml" << src, tmp + ".ml") == false) {
        return false;
    }
    ui->textEdit->append("compile...");
    if (compile("./tools/min-caml.opt", tmp + ".ml") == false) {
        return false;
    }
    ui->textEdit->append("link assembly library files...");
    if (link_asm(QStringList() << "./lib/lib_asm.s" << tmp + ".s", "./asm/" + srcBaseName + ".s") == false) {
        return false;
    }
}


//-------------------------------------------------------------
// スタートアッププロジェクトのみビルド
//-------------------------------------------------------------
bool MainWindow::build() {
    if (startupProject == NULL) {
        errorMsg("please set start up project");
        return false;
    }
    QString src = startupProject->whatsThis(0);
    ui->textEdit->clear();
    ui->textEdit_2->clear();
    return build(src);
}

//-------------------------------------------------------------
//
//-------------------------------------------------------------
void MainWindow::buildAll() {
    ui->textEdit->clear();
    ui->textEdit_2->clear();
    for (int i = 0; i < ui->treeWidget->topLevelItemCount(); i++) {
        QString src = ui->treeWidget->topLevelItem(i)->whatsThis(0);
        if (src == "") continue;
        build(src);
    }
}

