//-------------------------------------------------------------
//
// 「ソルバー」メニュー系
//
//-------------------------------------------------------------

#include "mainwindow.h"

// 初期化
void MainWindow::initSolver()
{
    solverdlg = new SolverDialog(this);
}

// 設定画面を表示
void MainWindow::showSolver()
{
    solverdlg->show();
}
