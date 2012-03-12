#include "mainwindow.h"
#include <QFileInfo>
#include <QProcess>

//------------------------------------------------------------
//
// 「実行」メニュー系
//
//------------------------------------------------------------

//-------------------------------------------------------------
// ビルド
//-------------------------------------------------------------

// ビルド系の初期化
void MainWindow::initBuild()
{
    process = new QProcess(this);
    connect(process, SIGNAL(readyReadStandardOutput()), this, SLOT(updateOutput()));
    connect(process, SIGNAL(readyReadStandardError()), this, SLOT(updateError()));
    connect(process, SIGNAL(error(QProcess::ProcessError)),
            this, SLOT(processError(QProcess::ProcessError)));
    connect(process, SIGNAL(finished(int, QProcess::ExitStatus)),
            this, SLOT(proc_finished(int, QProcess::ExitStatus)));
}

// エラーが出た
void MainWindow::processError(QProcess::ProcessError err)
{

}

// プロセスが終了した
void MainWindow::proc_finished(int ret, QProcess::ExitStatus stat)
{
    updateOutput();
    updateError();
    if (stat == QProcess::NormalExit)
    {
        statusBar()->showMessage("正常終了", 3000);
    }
    else
    {
        statusBar()->showMessage(QString("プロセスが中止されました"), 3000);
    }
}

// 標準出力をテキストボックスに表示
void MainWindow::updateOutput()
{
    QByteArray output = process->readAllStandardOutput();
    QString str = QString::fromLocal8Bit(output);
    ui->textEdit->moveCursor(QTextCursor::End);
    ui->textEdit->insertPlainText(str);
}

// 標準エラーをテキストボックスに表示
void MainWindow::updateError()
{
    QByteArray output = process->readAllStandardError();
    QString str = QString::fromLocal8Bit(output);
    // TODO
    QTextEdit* textEdit = ui->checkBoxSeplateStdErr->checkState() == Qt::Checked ? ui->textEdit :ui->textEdit_2;
    textEdit->moveCursor(QTextCursor::End);
    textEdit->insertPlainText(str);
}

// itemが属すプロジェクトを返す
QTreeWidgetItem* MainWindow::getProject(QTreeWidgetItem* item)
{
    QTreeWidgetItem* project = NULL;
    while (item != NULL)
    {
        project = item;
        item = item->parent();
    }
    return project;
}

// スタートアッププロジェクトをビルド
bool MainWindow::buildStartupProject()
{
    if (startupProject == NULL)
    {
        errorMsg("スタートアッププロジェクトを設定してください");
        return false;
    }
    return build(startupProject);
}

// 指定されたプロジェクトをビルド
bool MainWindow::buildSelectedProject()
{
    QTreeWidgetItem* project = getProject(ui->treeWidget->currentItem());
    return build(project);
}

// すべてのプロジェクトをビルド
void MainWindow::buildAll()
{
    ui->textEdit->clear();
    ui->textEdit_2->clear();

    // TODO 一つのプロセスが終わるまで次のプロセスを実行してはいけない
    for (int i = 1; i < ui->treeWidget->topLevelItemCount(); i++) {
        QTreeWidgetItem* project = getProject(ui->treeWidget->topLevelItem(i));
//        build(project);
    }
}

// 引数のプルジェクトをビルド
bool MainWindow::build(QTreeWidgetItem* project)
{
    if (project == NULL)
    {
        errorMsg("プロジェクトが正しく選択されていません");
        return false;
    }
    QTreeWidgetItem* folder = project->child(0);
    QStringList srcs;
    QString src;
    for (int i = 0; i < folder->childCount(); i++)
    {
        src = folder->child(i)->whatsThis(0);
        srcs << src;
    }
    ui->textEdit->clear();
    ui->textEdit_2->clear();
    return build(src, srcs);
}

// ビルド(コンパイル + アセンブル)の実装
bool MainWindow::build(const QString& src, const QStringList& srcs)
{
    saveAllFile();

    QString srcBaseName = QFileInfo(src).completeBaseName();

    ui->textEdit->append("[" + srcBaseName + "]");

    QString target = QFileInfo(src).canonicalPath() + "/" + srcBaseName;

    // TODO
    QString lib_asms = "lib_asm.s";
    QString lib_mls = "lib_ml.ml";
    for (int i = 0; i < srcs.count() - 1; i++)
    {
        lib_mls += " " + srcs[i];
    }

    QStringList args;
    args    << "LIB_ASM=" + lib_asms
            << "LIB_ML=" + lib_mls
            << "BINARY=" + QString(ui->comboInputFormat->currentIndex() == 0 ? " " : "-b")                // TODO
            << "INLINE=--inline " + ui->spinInline->text()     // TODO
            << target + ".bin_f";

    process->setWorkingDirectory(ui->lineArchPath->text());
    process->start("make", args);

    statusBar()->showMessage("ビルド開始", 3000);

    return true;
}

//-------------------------------------------------------------
// 実行
//-------------------------------------------------------------

// スタートアッププロジェクトを実行（アセンブル＋シミュレート）
void MainWindow::runStartupProject()
{
    if (startupProject == NULL)
    {
        errorMsg("スタートアッププロジェクトを設定してください");
        return;
    }
    run(startupProject);
}

// プロジェクトビューの選択されたアイテムを含むプロジェクトを実行（アセンブル＋シミュレート）
void MainWindow::runSelectedProject()
{
    QTreeWidgetItem* project = getProject(ui->treeWidget->currentItem());
    run(project);
}

// TODO: 開かれているすべてのプロジェクトを実行
void MainWindow::runAll()
{
    for (int i = 0; i < ui->treeWidget->topLevelItemCount(); i++)
    {
        QString base = QFileInfo(ui->treeWidget->topLevelItem(i)->whatsThis(0)).completeBaseName();
        if (base == "") continue;
//        run(base);
    }
}

// 指定されたプロジェクトを実行（アセンブル＋シミュレート）
void MainWindow::run(QTreeWidgetItem *project)
{
    if (project == NULL)
    {
        errorMsg("プロジェクトが正しく設定されていません");
        return;
    }
    run(project->whatsThis(0));

    // TODO: アセンブリファイルをプロジェクトビューに追加
}

// 実行（アセンブル＋シミュレート）。ファイル名指定版
void MainWindow::run(const QString& filepath)
{
    saveAllFile();

    QString base = QFileInfo(filepath).completeBaseName();
    QString target = QFileInfo(filepath).canonicalPath() + "/" + base + ".run";
    QString inputFile = ui->lineEditInput->text();
    QString outputFile = ui->checkBoxOutput->checkState() != Qt::Checked ? ui->lineEditOutput->text() : "";
    QStringList args(target);
    args << "-s";
    process->setStandardInputFile(inputFile);
    process->setStandardOutputFile(outputFile);
    // TODO
    process->setWorkingDirectory(ui->lineArchPath->text());
    ui->textEdit->clear();
    ui->textEdit_2->clear();
    process->start("make", args);
}

// プロセスを中断
void MainWindow::cancel()
{
    process->kill();
}
