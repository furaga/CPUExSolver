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
//
// 「実行」メニュー系
//
//  1.アセンブリをアセンブラでアセンブルして
//  2.シミュレータで実行
//
//=============================================================

//-------------------------------------------------------------
// ビルド系の初期化
//-------------------------------------------------------------
void MainWindow::initBuild() {
    process = new QProcess(this);
    connect(process, SIGNAL(readyReadStandardOutput()), this, SLOT(updateOutput()));
    connect(process, SIGNAL(readyReadStandardError()), this, SLOT(updateError()));
    connect(
                process, SIGNAL(error(QProcess::ProcessError)),
                this, SLOT(processError(QProcess::ProcessError)));
    connect(
                process, SIGNAL(finished(int, QProcess::ExitStatus)),
                this, SLOT(proc_finished(int, QProcess::ExitStatus)));
}

//-------------------------------------------------------------
// エラーが出たときに
//-------------------------------------------------------------
void MainWindow::processError(QProcess::ProcessError err) {
    ui->textEdit->append(QString("err = %1").arg(err));
}

//-------------------------------------------------------------
// ビルド系の初期化
//-------------------------------------------------------------
void MainWindow::proc_finished(int ret, QProcess::ExitStatus stat) {
    updateOutput();
    updateError();
}

void MainWindow::updateOutput() {
    QByteArray output = process->readAllStandardOutput();
    QString str = QString::fromLocal8Bit(output);
    ui->textEdit->insertPlainText(str);
}

void MainWindow::updateError() {
    QByteArray output = process->readAllStandardError();
    QString str = QString::fromLocal8Bit(output);
    ui->textEdit_2->insertPlainText(str);
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
    process->setWorkingDirectory("./tools");
    process->start("make " + target + ".comp");
/*
    process->setStandardInputFile("");
    process->setStandardOutputFile("");
    QString compilerPath = QFileInfo(compiler).canonicalFilePath();
    QString targetDir = QFileInfo(target).canonicalPath();
    QString targetName = QFileInfo(target).completeBaseName();
    //    process->setWorkingDirectory(targetDir);
    //    process->start(compilerPath + " -inline 250 " + targetName);
    process->waitForFinished();
*/
    return true;
}

bool MainWindow::build(const QString& src, const QStringList& srcs) {
    QString srcBaseName = QFileInfo(src).completeBaseName();
    QString tmp = "./asm/__temp__";

    ui->textEdit->append("[" + srcBaseName + "]");

    QString target = QFileInfo(src).canonicalPath() + "/" + srcBaseName;
    QString lib_asms = "../lib/lib_asm.s";
    QString lib_mls = "../lib/lib_ml.ml";
    for (int i = 0; i < srcs.count() - 1; i++) {
        lib_mls += " " + srcs[i];
    }

    QStringList args;
    args    << "LIB_ASM=" + lib_asms
            << "LIB_ML=" + lib_mls
            << "INLINE=-inline 250"
            << target + ".comp";

    process->setWorkingDirectory("./tools");
    process->start("make", args);

}

QTreeWidgetItem* MainWindow::getProject(QTreeWidgetItem* item) {
    QTreeWidgetItem* project = NULL;
    while (item != NULL) {
        project = item;
        item = item->parent();
    }
    return project;
}

//-------------------------------------------------------------
// スタートアッププロジェクトのみビルド
//-------------------------------------------------------------
bool MainWindow::build(QTreeWidgetItem* project) {
    if (project == NULL) {
        errorMsg("プロジェクトが正しく選択されていません");
        return false;
    }
    QTreeWidgetItem* folder = project->child(0);
    QStringList srcs;
    QString src;
    for (int i = 0; i < folder->childCount(); i++) {
        src = folder->child(i)->whatsThis(0);
        srcs << src;
    }
    ui->textEdit->clear();
    ui->textEdit_2->clear();
    return build(src, srcs);
}

//-------------------------------------------------------------
// スタートアッププロジェクトのみビルド
//-------------------------------------------------------------
bool MainWindow::buildStartupProject() {
    if (startupProject == NULL) {
        errorMsg("スタートアッププロジェクトを設定してください");
        return false;
    }
    return build(startupProject);
}

bool MainWindow::buildSelectedProject() {
    QTreeWidgetItem* item = ui->treeWidget->currentItem();
    QTreeWidgetItem* project = getProject(item);
    return build(project);
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
//        build(src);
    }
}

//-------------------------------------------------------------
// アセンブリをアセンブラでバイナリにアセンブル
//-------------------------------------------------------------
void MainWindow::assemble(const QString& assembler, const QString& src, const QString& binary) {
    process->setStandardInputFile("");
    process->setStandardOutputFile("");
    process->start(
                QFileInfo(assembler).canonicalFilePath() + " " +
                QFileInfo(src).canonicalFilePath() /*+ " " +
                QFileInfo(target).canonicalFilePath()*/
    );
    process->waitForFinished();
}

//-------------------------------------------------------------
// シミュレータでバイナリを実行
//-------------------------------------------------------------
void MainWindow::simulate(const QString &simulator, const QString &binary) {
    process->setStandardInputFile("./asm/base.sld");
//    process->setStandardOutputFile("./asm/base.ppm");
    process->start(
                QFileInfo(simulator).canonicalFilePath() + " " +
                QFileInfo(binary).canonicalFilePath()
    );
    process->waitForFinished();
}

//-------------------------------------------------------------
// 実行（アセンブル＋シミュレート）。ファイル名指定版
//-------------------------------------------------------------
void MainWindow::run(const QString& filepath) {
    QString base = QFileInfo(filepath).completeBaseName();
    QString target = QFileInfo(filepath).canonicalPath() + "/" + base + ".run";
    QStringList args("-s");
    args << target;
    QString inputFile = ui->lineEditInput->text();
    QString outputFile = ui->checkBoxOutput->checkState() != Qt::Checked ? ui->lineEditOutput->text() : "";

    process->setWorkingDirectory("./tools");
    process->setStandardInputFile(inputFile);
    process->setStandardOutputFile(outputFile);
//    QStringList args("-s")
///    process->setStandardInputFile(inputFile)
//    process->setStandardOutputFile(outputFile);
    process->start("make", args);
}

//-------------------------------------------------------------
// 指定されたプロジェクトを実行（アセンブル＋シミュレート）
//-------------------------------------------------------------
void MainWindow::run(QTreeWidgetItem *project) {
    if (project == NULL) {
        errorMsg("プロジェクトが正しく設定されていません");
        return;
    }
    QString base = QFileInfo(project->whatsThis(0)).completeBaseName();
    run(project->whatsThis(0));
}

//-------------------------------------------------------------
// スタートアッププロジェクトを実行（アセンブル＋シミュレート）
//-------------------------------------------------------------
void MainWindow::runStartupProject() {
    run(startupProject);
}

//-------------------------------------------------------------
// プロジェクトビューの選択されたアイテムを含むプロジェクトを実行（アセンブル＋シミュレート）
//-------------------------------------------------------------
void MainWindow::runSelectedProject() {
    QTreeWidgetItem* project = getProject(ui->treeWidget->currentItem());
    run(project);
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
