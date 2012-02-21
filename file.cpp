//=============================================================
//
// 「ファイル」メニュー系
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
#include <QMessageBox>

//-------------------------------------------------------------
// 初期化
//-------------------------------------------------------------
void MainWindow::initFile() {

}

//-------------------------------------------------------------
// ソースファイルが入ったフォルダを作る（リストビューに表示）
//-------------------------------------------------------------
QTreeWidgetItem* MainWindow::createSrcFolder(QStringList files) {
    QTreeWidgetItem* folder = new QTreeWidgetItem(QStringList("src"));
    foreach (const QString& file, files) {
        QString fileName = QFileInfo(file).fileName();
        QTreeWidgetItem* item = new QTreeWidgetItem(QStringList(fileName));
        item->setWhatsThis(0, file);
        folder->addChild(item);
    }
    return folder;
}

//-------------------------------------------------------------
// プロジェクトを作ってリストビューに表示
//-------------------------------------------------------------
void MainWindow::createProject(QString filepath) {
    QFileInfo fileInfo = QFileInfo(filepath);
    QString fileName = fileInfo.fileName();
    QString projectName = QString(fileName).remove(QRegExp("[.].*"));
    // リストビューにプロジェクトを追加
    QTreeWidgetItem* item = new QTreeWidgetItem(QStringList(projectName));
    item->setWhatsThis(0, fileInfo.canonicalFilePath());
    item->addChild(createSrcFolder(QStringList(fileInfo.canonicalFilePath())));
    ui->treeWidget->addTopLevelItem(item);
    ui->treeWidget->expandAll();
    if (startupProject == NULL) {
        setStartupProject(item);
    }
}

void MainWindow::createProject() {
    QStringList names = QFileDialog::getOpenFileNames(
                this,
                "select ML/Assembly files",
                ".",
                "ML file (*.ml);;Assembly file (*.s)");
    foreach (const QString& filepath, names) {
        createProject(filepath);
    }
}

//-------------------------------------------------------------
// プロジェクトを新規作成
//-------------------------------------------------------------
void MainWindow::newProject() {
    QString filepath = QFileDialog::getSaveFileName(
                this,
                "set ML/Assembly file name",
                ".",
                "ML/Assembly file (*.ml *.s)");
    if (filepath == "") return;
    // 空のファイルを生成
    createNewFile(filepath);
    // プロジェクトを開く
    createProject(filepath);
}

//-------------------------------------------------------------
// タブを新しく開いてファイル内容を表示
//-------------------------------------------------------------
void MainWindow::createTextTab(const QString& path, const QString& tabName) {
    for (int i = 0; i < ui->tabWidget->count(); i++) {
        if (path == ui->tabWidget->tabWhatsThis(i)) {
            ui->tabWidget->setCurrentIndex(i);
            return;
        }
    }
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QMessageBox::critical(this, "can't open file", "can't open " + path, QMessageBox::Ok, QMessageBox::Cancel);
        return;
    }
    QTextStream in(&file);
    QString text;
    while (!in.atEnd()) {
        text += in.readLine() + "\n";
    }
    // TODO : これのDELETE
    QTextEdit* textEdit = new QTextEdit(this);
    textEdit->setPlainText(text);
    textEdit->setFont(QFont("Monospace", 11));
    ui->tabWidget->addTab(textEdit, tabName);
    ui->tabWidget->setTabWhatsThis(ui->tabWidget->count() - 1, path);
    ui->tabWidget->setCurrentIndex(ui->tabWidget->count() - 1);
}

//-------------------------------------------------------------
// ファイルをエディタ画面に開く
//-------------------------------------------------------------
void MainWindow::openFile() {
    openItem(ui->treeWidget->currentItem(), 0);
}

//-------------------------------------------------------------
// フォルダなら展開し、ファイルならエディタ画面に開く
//-------------------------------------------------------------
void MainWindow::openItem(QTreeWidgetItem* item, int idx) {
    // 子ノードがあるならフォルダなので展開・畳み込みを行う
    if (item->childCount() > 0) {
        if (item->isExpanded()) {
            ui->treeWidget->expandItem(item);
        }
        else {
            ui->treeWidget->collapseItem(item);
        }
        return;
    }

    // ファイルが存在すればエディタ画面に開く
    QString filepath = item->whatsThis(0);
    if (QFile::exists(filepath)) {
        createTextTab(filepath, QFileInfo(filepath).fileName());
    }
}

//-------------------------------------------------------------
// 選択中のタブを消す
//-------------------------------------------------------------
void MainWindow::closeFile() {
    int cur = ui->tabWidget->currentIndex();
    ui->tabWidget->removeTab(cur);
}

//-------------------------------------------------------------
// 指定された番号のタブのファイルの保存
//-------------------------------------------------------------
void MainWindow::saveFile(int i) {
    QString path = ui->tabWidget->tabWhatsThis(i);
    QFile file(path);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text) == false) {
        return;
    }
    QTextStream out(&file);
    out << ((QTextEdit*)(ui->tabWidget->widget(i)))->toPlainText();
}

//-------------------------------------------------------------
// 選択中のタブのファイルを保存
//-------------------------------------------------------------
void MainWindow::saveFile() {
    int cur = ui->tabWidget->currentIndex();
    saveFile(cur);
}

//-------------------------------------------------------------
// 開かれているすべてのファイルを保存
//-------------------------------------------------------------
void MainWindow::saveAllFile() {
    for (int i = 0; i < ui->tabWidget->count(); i++) {
        saveFile(i);
    }
}

//-------------------------------------------------------------
// プロジェクトビューを右クリックしたとき、メニューを表示する
//-------------------------------------------------------------
void MainWindow::showProjectViewContextMenu(const QPoint& point) {
    QMenu* menu = NULL;
    QTreeWidgetItem* item = ui->treeWidget->currentItem();
    if (item == NULL) return;
    if (item->parent() == NULL) menu = p_projectTreeMenu;
    else if (item->parent()->parent() == NULL) menu = f_projectTreeMenu;
    else if (item->parent()->parent()->parent() == NULL) menu = s_projectTreeMenu;
    menu->exec(ui->treeWidget->viewport()->mapToGlobal(point));
}

