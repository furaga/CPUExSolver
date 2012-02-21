#include "finddialog.h"
#include "ui_finddialog.h"

FindDialog::FindDialog(QWidget *parent, QTabWidget* tab) :
    QDialog(parent),
    ui(new Ui::FindDialog),
    tabWidget(tab)
{
    ui->setupUi(this);
}

FindDialog::~FindDialog()
{
    delete ui;
}

QTextEdit* FindDialog::getCurrentTextEdit() {

    return (QTextEdit*)tabWidget->currentWidget();
}

bool FindDialog::find() {
    QTextEdit* textEdit = getCurrentTextEdit();
    if (textEdit == NULL) return false;
    int from = textEdit->textCursor().selectionEnd();
    QTextCursor cursor = textEdit->document()->find(ui->findString->text(), from);
    if (!cursor.isNull()) {
        textEdit->setTextCursor(cursor);
        return true;
    }
    else {
        return false;
    }
}

bool FindDialog::replace() {
    bool found = find();
    QTextEdit* textEdit = getCurrentTextEdit();
    if (textEdit == NULL) return false;
    if (found == false) return false;
    textEdit->cut();
    textEdit->insertPlainText(ui->replaceString->text());
    return true;
}

void FindDialog::replaceAll() {
    int cnt = 0;
    while (replace()) {
        cnt++;
    }
}
