//=============================================================
//
// 「編集」メニュー系
//
//=============================================================

#include "mainwindow.h"
#include <QTextEdit>

// 初期化
void MainWindow::initEdit() {
    ui->tabWidget->clear();
    findDialog = new FindDialog(this, ui->tabWidget);
}

// 選択中のタブ内のテキストボックスを取得
QTextEdit* MainWindow::getCurrentTextEdit() {
    int cur = ui->tabWidget->currentIndex();
    return (QTextEdit*)ui->tabWidget->widget(cur);
}

// もとに戻す
void MainWindow::textEditUndo() {
    QTextEdit* textEdit = getCurrentTextEdit();
    if (textEdit == NULL) return;
    textEdit->undo();
}

// やりなおし
void MainWindow::textEditRedo() {
    QTextEdit* textEdit = getCurrentTextEdit();
    if (textEdit == NULL) return;
    textEdit->redo();
}

// 切りとり
void MainWindow::textEditCut() {
    QTextEdit* textEdit = getCurrentTextEdit();
    if (textEdit == NULL) return;
    textEdit->cut();
}

// コピー
void MainWindow::textEditCopy() {
    QTextEdit* textEdit = getCurrentTextEdit();
    if (textEdit == NULL) return;
    textEdit->copy();
}

// 貼り付け
void MainWindow::textEditPaste() {
    QTextEdit* textEdit = getCurrentTextEdit();
    if (textEdit == NULL) return;
    textEdit->paste();
}

// 削除
void MainWindow::textEditDelete() {
    QTextEdit* textEdit = getCurrentTextEdit();
    if (textEdit == NULL) return;
//TODO
    textEdit->cut();
}

// すべて選択
void MainWindow::textEditSelectAll() {
    QTextEdit* textEdit = getCurrentTextEdit();
    if (textEdit == NULL) return;
    textEdit->selectAll();
}

// 検索・置換
void MainWindow::textEditFind() {

}

void MainWindow::showFind() {
    findDialog->show();
}

// 次のタブへ移動
void MainWindow::textEditNextTab() {
    int cur = ui->tabWidget->currentIndex();
    int cnt = ui->tabWidget->count();
    ui->tabWidget->setCurrentIndex((cur + 1) % cnt);
}

// 前のタブへ移動
void MainWindow::textEditBackTab() {
    int cur = ui->tabWidget->currentIndex();
    int cnt = ui->tabWidget->count();
    ui->tabWidget->setCurrentIndex((cur + cnt - 1) % cnt);
}
