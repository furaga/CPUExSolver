#include "mainwindow.h"
#include "aboutdialog.h"
#include "global.h"
#include "linker.h"
#include <QColor>
#include <QBrush>
#include <QFile>
#include <QTextStream>
#include <QTextEdit>
#include <QFileDialog>
#include <QMessageBox>

//-------------------------------------------------------------
// コンストラクタ
//-------------------------------------------------------------
MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow),
    startupProject(NULL)
{
    ui->setupUi(this);
    initEdit();
    initFile();
    initHelp();
    initProjectView();
    initBuild();
}

//-------------------------------------------------------------
// デストラクタ
//-------------------------------------------------------------
MainWindow::~MainWindow()
{
    SAFE_DELETE(p_projectTreeMenu);
    SAFE_DELETE(f_projectTreeMenu);
    SAFE_DELETE(s_projectTreeMenu);
    delete ui;
}

//-------------------------------------------------------------
// メニューにアクションを追加
//-------------------------------------------------------------
void MainWindow::addAction(QMenu* menu, const QString& title, const char* signal, const char* slot) {
    QAction* action = new QAction(title, this);
    menu->addAction(action);
    connect(action, signal, this, slot);
}

void MainWindow::errorMsg(const QString& msg) {
    QMessageBox::critical(
                NULL,
                "ERROR",
                msg,
                QMessageBox::Ok,
                QMessageBox::Cancel);
}

//=============================================================
//
// 「ビルド」メニュー系
//
//=============================================================


//=============================================================
//
// 「設定」メニュー系
//
//=============================================================
