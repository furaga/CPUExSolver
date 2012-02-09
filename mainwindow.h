#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include "ui_mainwindow.h"
#include "linker.h"
#include <QMainWindow>
#include <QProcess>

namespace Ui {
class MainWindow;
}

class QTextEdit;
class QMenu;
class aboutdialog;
class QProcess;

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
    QProcess* process;

    // 初期化系
    void initHelp();
    void initEdit();
    void initFile();
    void initProjectView();
    void initBuild();

    // メニューにアクションを追加
    void addAction(QMenu* menu, const QString& title, const char* signal, const char* slot);

    // エディタ画面に新しいタブを作る
    void createTextTab(const QString& path, const QString& tabName);

    // エディタ画面の選択中のタブを取得
    QTextEdit* getCurrentTextEdit();

    // 再帰的にプロジェクトビューのノードtargetを削除(projectview.cpp)
    void deleteTreeNode(QTreeWidgetItem* target);

    // ビルドメニュー系(build.cpp)
    bool link_ml(QStringList files, QString target);
    bool link_asm(QStringList files, QString target);
    bool compile(QString compiler, QString target);
    void updateOutput();
    void updateError();
    void processError(QProcess::ProcessError err);
    void proc_finished(int ret, QProcess::ExitStatus stat);
    bool build(const QString& src);

    // 実行メニュー系(run.cpp)
    void assemble(const QString& assembler, const QString& src, const QString& binary);
    void simulate(const QString& simulator, const QString& binary);
    void run(const QString& base);

    void errorMsg(const QString& msg);
    void setStartupProject(QTreeWidgetItem* item);

private slots:

    // ファイルメニュー系(file.cpp)
    void createProject();
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

    // ビルドメニュー系(build.cpp)
    bool build();
    void buildAll();

    // 実行メニュー系(run.cpp)
    void run();// {linker link; link.link(QStringList("./lib/lib_asm.s"), "./lib/dst.s"); }
    void runAll();

    // 設定メニュー系

    // ヘルプメニュー系(help.cpp)
    void showAbout();

    // その他プロジェクトビュー系(projectview.cpp)
    void setStartupProject();
    void removeProject();
    void removeTreeNode();
};

#endif // MAINWINDOW_H
