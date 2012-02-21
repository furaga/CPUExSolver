#ifndef FINDDIALOG_H
#define FINDDIALOG_H

#include <QDialog>
#include <QTabWidget>
#include <QTextEdit>

namespace Ui {
class FindDialog;
}

class FindDialog : public QDialog
{
    Q_OBJECT
    
public:
    explicit FindDialog(QWidget *parent, QTabWidget* tabWidget);
    ~FindDialog();
    
private:
    Ui::FindDialog *ui;
    QTabWidget* tabWidget;

    QTextEdit* getCurrentTextEdit();

public slots:
    bool find();
    bool replace();
    void replaceAll();
};

#endif // FINDDIALOG_H
