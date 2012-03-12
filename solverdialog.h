#ifndef SOLVERDIALOG_H
#define SOLVERDIALOG_H

#include <QDialog>
#include <map>
#include "generatingdialog.h"
using namespace std;

namespace Ui {
class SolverDialog;
}

struct OpTableRow
{
    QString format;
    OpTableRow(QString format)
    {
        this->format = format;
    }
};

class SolverDialog : public QDialog
{
    Q_OBJECT
    
public:
    explicit SolverDialog(QWidget *parent = 0);
    ~SolverDialog();
    
private:
    Ui::SolverDialog *ui;
    map<QString, int> opTableData;
    GeneratingDialog genDlg;

    bool writeXML(QString path);
    void showMessage(QString msg);

private slots:
    void setFRegConstNumMax(int max);
    void setIRegs();

    void initOpTable();
    void changeOpName(QString str);
    void changeOpOrder(){}

    void changeCallUse();
    void changeUse();

    void generate();
};

#endif // SOLVERDIALOG_H
