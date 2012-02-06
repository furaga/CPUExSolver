#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include "ui_mainwindow.h"
#include "linker.h"
#include <QMainWindow>

namespace Ui {
class MainWindow;
}

class QTextEdit;
class QMenu;
class aboutdialog;

class MainWindow : public QMainWindow
{
    Q_OBJECT
    
public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();
    
private:
    Ui::MainWindow *ui;
    QTreeWidgetItem* createSrcFolder(QStringList files);
    aboutdialog* aboutdlg;
    QMenu* p_projectTreeMenu;
    QMenu* f_projectTreeMenu;
    QMenu* s_projectTreeMenu;
    QTreeWidgetItem* startupProject;

    // 初期化系
    void initHelp();
    void initEdit();
    void initFile();
    void initProjectView();

    // メニューにアクションを追加
    void addAction(QMenu* menu, const QString& title, const char* signal, const char* slot);

    // エディタ画面に新しいタブを作る
    void createTextTab(const QString& path, const QString& tabName);

    // エディタ画面の選択中のタブを取得
    QTextEdit* getCurrentTextEdit();

    // 再帰的にプロジェクトビューのノードtargetを削除(projectview.cpp)
    void deleteTreeNode(QTreeWidgetItem* target);

private slots:

    // ファイルメニュー系(file.cpp)
    void openProject();
    void newProject();
    void openFile();
    void openFile(QTreeWidgetItem* item, int idx);
    void closeFile();
    void saveFile(int i);
    void saveFile();
    void saveAllFile();
    void showProjectViewContextMenu(const QPoint& point);

    // 編集メニュー系(edit.cpp)
    void textEditUndo();
    void textEditRedo();
    void textEditCut();
    void textEditCopy();
    void textEditPaste();
    void textEditDelete();
    void textEditSelectAll();
    void textEditFind();
    void textEditNextTab();
    void textEditBackTab();

    // ビルドメニュー系
    void build() { }
    void buildAll() { }

    // 実行メニュー系
    void run();// {linker link; link.link(QStringList("./lib/lib_asm.s"), "./lib/dst.s"); }
    void runAll() { }

    // 設定メニュー系

    // ヘルプメニュー系(help.cpp)
    void showAbout();

    // その他プロジェクトビュー系(projectview.cpp)
    void setStartupProject();
    void removeProject();
    void removeTreeNode();
};

#endif // MAINWINDOW_H
