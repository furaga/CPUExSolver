//=============================================================
//
// プロジェクトビュー関連の関数群
//
//=============================================================

#include "mainwindow.h"
#include "aboutdialog.h"
#include "global.h"
#include <QColor>
#include <QBrush>
#include <QFile>
#include <QTextStream>
#include <QTextEdit>
#include <QFileDialog>

//-------------------------------------------------------------
// プロジェクトビューの初期化
//-------------------------------------------------------------
void MainWindow::initProjectView() {
    //-------------------------------------------------------------
    // ライブラリ用のプロジェクト作成
    //-------------------------------------------------------------
    QDir dir("./lib");
    QStringList filter;
    filter << "*.ml" << "*.s";
    dir.setNameFilters(filter);
    if (dir.exists()) {
        QTreeWidgetItem* item = new QTreeWidgetItem(QStringList("lib"));
        ui->treeWidget->addTopLevelItem(item);
        item->addChild(createSrcFolder(dir.entryList()));
    }

    //-------------------------------------------------------------
    // プロジェクトビューで使うコンテキストメニューを作る
    //-------------------------------------------------------------

    // プロジェクト名を右クリックしたときのメニュー
    p_projectTreeMenu = new QMenu(ui->treeWidget);
    addAction(p_projectTreeMenu, "set to startup project", SIGNAL(triggered()), SLOT(setStartupProject()));
    p_projectTreeMenu->addSeparator();
    addAction(p_projectTreeMenu, "remove this project", SIGNAL(triggered()), SLOT(removeProject()));
    p_projectTreeMenu->addSeparator();
    addAction(p_projectTreeMenu, "build", SIGNAL(triggered()), SLOT(showAbout()));
    addAction(p_projectTreeMenu, "run", SIGNAL(triggered()), SLOT(showAbout()));

    // フォルダ名を右クリックしたときのメニュー
    f_projectTreeMenu = new QMenu(ui->treeWidget);

    // ファイル名を右クリックしたときのメニュー
    s_projectTreeMenu = new QMenu(ui->treeWidget);
    addAction(s_projectTreeMenu, "open", SIGNAL(triggered()), SLOT(openFile()));
    s_projectTreeMenu->addSeparator();
    addAction(s_projectTreeMenu, "remove", SIGNAL(triggered()), SLOT(removeTreeNode()));
    s_projectTreeMenu->addSeparator();
    addAction(s_projectTreeMenu, "build", SIGNAL(triggered()), SLOT(showAbout()));
    addAction(s_projectTreeMenu, "run", SIGNAL(triggered()), SLOT(showAbout()));
    s_projectTreeMenu->addSeparator();
    addAction(s_projectTreeMenu, "add a file above this file", SIGNAL(triggered()), SLOT(showAbout()));
    addAction(s_projectTreeMenu, "add a file below this file", SIGNAL(triggered()), SLOT(showAbout()));
}

//-------------------------------------------------------------
// 選択されたプロジェクトをスタートアッププロジェクトにする
//-------------------------------------------------------------
void MainWindow::setStartupProject() {
    if (startupProject != NULL) startupProject->setForeground(0, QBrush(QColor(0, 0, 0)));
    startupProject = ui->treeWidget->currentItem();
    if (startupProject != NULL) startupProject->setForeground(0, QBrush(QColor(255, 0, 0)));
}

//-------------------------------------------------------------
// ノードtargetとその子ノードを再帰的に削除
//-------------------------------------------------------------
void MainWindow::deleteTreeNode(QTreeWidgetItem* target) {
    if (target == NULL) return;
    for (int i = target->childCount() - 1; i >= 0; i--) {
        deleteTreeNode(target->child(i));
    }
    SAFE_DELETE(target);
}

//-------------------------------------------------------------
// 選択されたプロジェクトを削除
//-------------------------------------------------------------
void MainWindow::removeProject() {
    QTreeWidgetItem* target = ui->treeWidget->currentItem();
    if (startupProject == target) {
        startupProject == NULL;
    }
    deleteTreeNode(target);
}

//-------------------------------------------------------------
// 選択されたノードを削除
//-------------------------------------------------------------
void MainWindow::removeTreeNode() {
    QTreeWidgetItem* target = ui->treeWidget->currentItem();
    deleteTreeNode(target);
}
