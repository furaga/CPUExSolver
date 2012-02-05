#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include "ui_mainwindow.h"
#include <QMainWindow>

namespace Ui {
class MainWindow;
}

class QTextEdit;
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
    QMenu* p_projectTreeMenu;
    QMenu* f_projectTreeMenu;
    QMenu* s_projectTreeMenu;
    void createTextTab(const QString& path, const QString& tabName);
    QTextEdit* getCurrentTextEdit();
    aboutdialog* aboutdlg;

private slots:
    // ファイルメニュー系
    void openProject();
    void newProject();
    void openFile(QTreeWidgetItem* item, int idx);
    void closeFile();
    void saveFile(int i);
    void saveFile();
    void saveAllFile();
    void showProjectViewContextMenu(const QPoint& point);
    // 編集メニュー系
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
    // 実行メニュー系
    // 設定メニュー系
    // ヘルプメニュー系
    void showAbout();
};

#endif // MAINWINDOW_H
