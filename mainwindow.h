#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include "ui_mainwindow.h"
#include "linker.h"
#include "aboutdialog.h"
#include "configdialog.h"
#include "finddialog.h"
#include <QMainWindow>
#include <QProcess>

namespace Ui {
class MainWindow;
}

class QTextEdit;
class QMenu;
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
    ConfigDialog* configdlg;
    FindDialog* findDialog;
    QMenu* p_projectTreeMenu;
    QMenu* f_projectTreeMenu;
    QMenu* s_projectTreeMenu;
    QTreeWidgetItem* startupProject;
    QProcess* process;

    // 初期化系
    void initEdit();
    void initFile();
    void initConfig();
    void initHelp();
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
    bool build(const QString& src, const QStringList& srcs);
    bool build(QTreeWidgetItem* project);
    QTreeWidgetItem* getProject(QTreeWidgetItem* item);

    // 実行メニュー系(run.cpp)
    void assemble(const QString& assembler, const QString& src, const QString& binary);
    void simulate(const QString& simulator, const QString& binary);
    void run(const QString& base);
    void run(QTreeWidgetItem* project);

    void errorMsg(const QString& msg);
    void setStartupProject(QTreeWidgetItem* item);

    void addFileToSrcFolder(const QString& filepath, int delta);

    void createNewFile(const QString& filepath);

private slots:

    // ファイルメニュー系(file.cpp)
    void createProject(QString filepath);
    void createProject();
    void newProject();
    void openFile();
    void openItem(QTreeWidgetItem* item, int idx);
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
    void showFind();
    void textEditNextTab();
    void textEditBackTab();

    // ビルドメニュー系(build.cpp)
    void updateOutput();
    void updateError();
    void processError(QProcess::ProcessError err);
    void proc_finished(int ret, QProcess::ExitStatus stat);
    bool buildStartupProject();
    bool buildSelectedProject();
    void buildAll();

    // 実行メニュー系(run.cpp)
    void runStartupProject();
    void runSelectedProject();
    void runAll();

    // 設定メニュー系
    void showConfig();

    // ヘルプメニュー系(help.cpp)
    void showAbout();

    // その他プロジェクトビュー系(projectview.cpp)
    void setStartupProject();
    void removeProject();
    void removeTreeNode();
    void addNewFileAbove();
    void addExistFileAbove();
    void addNewFileBelow();
    void addExistFileBelow();

    //
    void setInputFile();
    void setOutputFile();
    void toggleOutputEnable();
};

#endif // MAINWINDOW_H
