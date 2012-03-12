#ifndef GENERATINGDIALOG_H
#define GENERATINGDIALOG_H

#include <QDialog>
#include <QProcess>
namespace Ui {
class GeneratingDialog;
}

class GeneratingDialog : public QDialog
{
    Q_OBJECT
    
public:
    explicit GeneratingDialog(QWidget *parent = 0);
    ~GeneratingDialog();
    
    void init(QString configPath, QString dstPath);

private:
    Ui::GeneratingDialog *ui;
    QProcess* process;
private slots:
    void updateOutput();
    void updateError();
    void processError(QProcess::ProcessError err);
    void proc_finished(int ret, QProcess::ExitStatus stat);
};

#endif // GENERATINGDIALOG_H
