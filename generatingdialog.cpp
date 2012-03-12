#include "generatingdialog.h"
#include "ui_generatingdialog.h"

GeneratingDialog::GeneratingDialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::GeneratingDialog)
{
    ui->setupUi(this);
    process = new QProcess(this);
    connect(process, SIGNAL(readyReadStandardOutput()), this, SLOT(updateOutput()));
    connect(process, SIGNAL(readyReadStandardError()), this, SLOT(updateError()));
    connect(process, SIGNAL(error(QProcess::ProcessError)),
            this, SLOT(processError(QProcess::ProcessError)));
    connect(process, SIGNAL(finished(int, QProcess::ExitStatus)),
            this, SLOT(proc_finished(int, QProcess::ExitStatus)));
}

GeneratingDialog::~GeneratingDialog()
{
    delete ui;
}

// エラーが出た
void GeneratingDialog::processError(QProcess::ProcessError err)
{

}

// ビルド系の初期化
void GeneratingDialog::proc_finished(int ret, QProcess::ExitStatus stat)
{
    updateOutput();
    updateError();
    if (stat == QProcess::NormalExit)
    {
        ui->label->setText("生成が完了しました");
    }
    else
    {
        ui->label->setText("生成中にエラーが発生しました");
    }
    ui->pushOK->setEnabled(true);
}

// 標準出力をテキストボックスに表示
void GeneratingDialog::updateOutput()
{
    QByteArray output = process->readAllStandardOutput();
    QString str = QString::fromLocal8Bit(output);
    ui->textEdit->moveCursor(QTextCursor::End);
    ui->textEdit->insertPlainText(str);
}

// 標準エラーをテキストボックスに表示
void GeneratingDialog::updateError()
{
    QByteArray output = process->readAllStandardError();
    QString str = QString::fromLocal8Bit(output);
    ui->textEdit->moveCursor(QTextCursor::End);
    ui->textEdit->insertPlainText(str);
}

void GeneratingDialog::init(QString configPath, QString dstPath)
{
    ui->label->setText("アーキテクチャを生成しています");

    process->setWorkingDirectory("templates");
    ui->textEdit->clear();
    ui->pushOK->setEnabled(false);
    QStringList args;
    args    << "CONFIGFILE=" + configPath
            << "DSTDIR=" + dstPath
            << "DSTDIR_TOP=" + dstPath;
    process->start("make", args);
}

