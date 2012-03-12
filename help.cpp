//=============================================================
//
// 「ヘルプ」メニュー系
//
//=============================================================

#include "mainwindow.h"

// 初期化
void MainWindow::initHelp() {
    aboutdlg = new aboutdialog(this);
}

// アバウト画面を表示
void MainWindow::showAbout() {
    aboutdlg->show();
}
