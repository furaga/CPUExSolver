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

// プロジェクトビューの初期化
void MainWindow::initProjectView()
{
    // ライブラリ用のプロジェクト作成
    QDir dir("./lib");
    QStringList filter;
    filter << "*.ml" << "*.s";
    dir.setNameFilters(filter);
    if (dir.exists())
    {
        QTreeWidgetItem* item = new QTreeWidgetItem(QStringList("lib"));
        item->setWhatsThis(0, LIBRARY);
        ui->treeWidget->addTopLevelItem(item);
        QStringList srcs(dir.entryList());
        for (int i = 0; i < srcs.count(); i++)
        {
            srcs[i] = dir.canonicalPath() + "/" + srcs[i];
        }
        item->addChild(createSrcFolder(srcs));
    }

    // プロジェクトビューで使うコンテキストメニューを作る

    // プロジェクト名を右クリックしたときのメニュー
    p_projectTreeMenu = new QMenu(ui->treeWidget);
    addAction(p_projectTreeMenu, "スタートアッププロジェクトに設定(&S)", SIGNAL(triggered()), SLOT(setStartupProject()));
    p_projectTreeMenu->addSeparator();
    addAction(p_projectTreeMenu, "プロジェクトを削除", SIGNAL(triggered()), SLOT(removeProject()));
    p_projectTreeMenu->addSeparator();
    addAction(p_projectTreeMenu, "リビルド(&B)", SIGNAL(triggered()), SLOT(buildSelectedProject()));
    addAction(p_projectTreeMenu, "実行(&R)", SIGNAL(triggered()), SLOT(runSelectedProject()));

    // フォルダ名を右クリックしたときのメニュー
    f_projectTreeMenu = new QMenu(ui->treeWidget);

    // ファイル名を右クリックしたときのメニュー
    s_projectTreeMenu = new QMenu(ui->treeWidget);
    addAction(s_projectTreeMenu, "開く(&O)", SIGNAL(triggered()), SLOT(openFile()));
    s_projectTreeMenu->addSeparator();
    addAction(s_projectTreeMenu, "プロジェクトから除外", SIGNAL(triggered()), SLOT(removeTreeNode()));
    s_projectTreeMenu->addSeparator();
    addAction(s_projectTreeMenu, "リビルド(&B)", SIGNAL(triggered()), SLOT(buildSelectedProject()));
    addAction(s_projectTreeMenu, "実行(&R)", SIGNAL(triggered()), SLOT(runSelectedProject()));
    s_projectTreeMenu->addSeparator();
    addAction(s_projectTreeMenu, "上に既存のファイルを追加", SIGNAL(triggered()), SLOT(addExistFileAbove()));
    addAction(s_projectTreeMenu, "上に新しいファイルを追加", SIGNAL(triggered()), SLOT(addNewFileAbove()));
    addAction(s_projectTreeMenu, "下に既存のファイルを追加", SIGNAL(triggered()), SLOT(addExistFileBelow()));
    addAction(s_projectTreeMenu, "下に新しいファイルを追加", SIGNAL(triggered()), SLOT(addNewFileBelow()));

    // ライブラリファイルを右クリックしたときのメニュー
    lib_s_projectTreeMenu = new QMenu(ui->treeWidget);
    addAction(lib_s_projectTreeMenu, "開く(&O)", SIGNAL(triggered()), SLOT(openFile()));
}

// 選択されたプロジェクトをスタートアッププロジェクトにする
void MainWindow::setStartupProject(QTreeWidgetItem* item)
{
    if (startupProject != NULL)
    {
        startupProject->setForeground(0, QBrush(QColor(0, 0, 0)));
    }
    startupProject = item;
    if (startupProject != NULL)
    {
        startupProject->setForeground(0, QBrush(QColor(255, 0, 0)));
    }
}

void MainWindow::setStartupProject()
{
    setStartupProject(ui->treeWidget->currentItem());
}

// ノードtargetとその子ノードを再帰的に削除
void MainWindow::deleteTreeNode(QTreeWidgetItem* target)
{
    if (target == NULL) return;
    for (int i = target->childCount() - 1; i >= 0; i--)
    {
        deleteTreeNode(target->child(i));
    }
    SAFE_DELETE(target);
}

// 選択されたプロジェクトを削除
void MainWindow::removeProject()
{
    QTreeWidgetItem* target = ui->treeWidget->currentItem();
    QTreeWidgetItem* prev = startupProject;
    setStartupProject(NULL);
    deleteTreeNode(target);
    if (prev == target)
    {
        if (ui->treeWidget->topLevelItemCount() >= 2)
        {
            setStartupProject(ui->treeWidget->topLevelItem(1));
//            ui->textEdit->append(QString("cnt = %1").arg(ui->treeWidget->topLevelItemCount()));
        }
    }
    else
    {
        setStartupProject(prev);
    }
}

// 選択されたノードを削除
void MainWindow::removeTreeNode()
{
    QTreeWidgetItem* target = ui->treeWidget->currentItem();
    deleteTreeNode(target);
}

// ソースフォルダにファイルを追加
void MainWindow::addFileToSrcFolder(const QString& filepath, int delta)
{
    if (filepath == "") return;
    QString fileName = QFileInfo(filepath).fileName();
    QTreeWidgetItem* item = new QTreeWidgetItem(QStringList(fileName));
    item->setWhatsThis(0, filepath);
    QTreeWidgetItem* folder = ui->treeWidget->currentItem()->parent();
    int idx = folder->indexOfChild(ui->treeWidget->currentItem()) + delta;
    folder->insertChild(idx, item);
}

// 指定されたファイル名の上に新規ファイルを追加
void MainWindow::addNewFileAbove()
{
    QString filepath = QFileDialog::getSaveFileName(
                this,
                "set ML/Assembly file name",
                ".",
                "ML/Assembly file (*.ml *.s)");
    createNewFile(filepath);
    addFileToSrcFolder(filepath, 0);
}

// 指定されたファイル名の上に既存のファイルを追加
void MainWindow::addExistFileAbove()
{
    QString filepath = QFileDialog::getOpenFileName(
                this,
                "set ML/Assembly file name",
                ".",
                "ML/Assembly file (*.ml *.s)");
    addFileToSrcFolder(filepath, 0);
}

// 指定されたファイル名の下に新規ファイルを追加
void MainWindow::addNewFileBelow()
{
    QString filepath = QFileDialog::getSaveFileName(
                this,
                "set ML/Assembly file name",
                ".",
                "ML/Assembly file (*.ml *.s)");
    createNewFile(filepath);
    addFileToSrcFolder(filepath, 1);
}

// 指定されたファイル名の下に既存のファイルを追加
void MainWindow::addExistFileBelow()
{
    QString filepath = QFileDialog::getOpenFileName(
                this,
                "set ML/Assembly file name",
                ".",
                "ML/Assembly file (*.ml *.s)");
    addFileToSrcFolder(filepath, 1);
}
