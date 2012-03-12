#include "solverdialog.h"
#include "ui_solverdialog.h"
#include <QTextDocument>
#include <QFile>
#include <QFileDialog>
#include <QMessageBox>
#include <qmap.h>
#include <qstring.h>
#include <qtextstream.h>
#include <qtextcodec.h>

SolverDialog::SolverDialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::SolverDialog)
{
    ui->setupUi(this);

    QStringList allRegs;
    for (int i = 0; i < ui->spinIRegNum->value(); i++)
    {
        allRegs << QString("%1%2").arg(ui->lineIRegPrefix->text()).arg(i);
    }
    ui->comboZR->addItems(allRegs);
    ui->comboZR->setCurrentIndex(0);
    ui->comboFR->addItems(allRegs);
    ui->comboFR->setCurrentIndex(1);
    ui->comboHR->addItems(allRegs);
    ui->comboHR->setCurrentIndex(2);
    ui->comboP1R->addItems(allRegs);
    ui->comboP1R->setCurrentIndex(29);
    ui->comboM1R->addItems(allRegs);
    ui->comboM1R->setCurrentIndex(30);
    allRegs.insert(0, "専用レジスタを使用");
    ui->comboLR->addItems(allRegs);
    ui->comboLR->setCurrentIndex(0);

    initOpTable();
}

SolverDialog::~SolverDialog()
{
    delete ui;
}

void SolverDialog::initOpTable()
{
    QList<QLineEdit*> list;
    QList<QCheckBox*> listCheck;

    list.append(ui->lineMOV); listCheck.append(ui->checkMOV);
    list.append(ui->lineADD); listCheck.append(NULL);
    list.append(ui->lineSUB); listCheck.append(NULL);
    list.append(ui->lineMUL); listCheck.append(ui->checkMUL);
    list.append(ui->lineDIV); listCheck.append(ui->checkDIV);
    list.append(ui->lineSLL); listCheck.append(ui->checkSLL);
    list.append(ui->lineSLA); listCheck.append(ui->checkSLA);
    list.append(ui->lineSRL); listCheck.append(ui->checkSRL);
    list.append(ui->lineSRA); listCheck.append(ui->checkSRA);
    list.append(ui->lineSHIFT); listCheck.append(ui->checkSHIFT);
    list.append(ui->lineAND); listCheck.append(ui->checkAND);
    list.append(ui->lineOR); listCheck.append(ui->checkOR);
    list.append(ui->lineNOR); listCheck.append(ui->checkNOR);
    list.append(ui->lineXOR); listCheck.append(ui->checkXOR);
    list.append(ui->lineNOT); listCheck.append(ui->checkNOT);
    list.append(ui->lineADDI); listCheck.append(ui->checkADDI);
    list.append(ui->lineSUBI); listCheck.append(ui->checkSUBI);
    list.append(ui->lineMULI); listCheck.append(ui->checkMULI);
    list.append(ui->lineDIVI); listCheck.append(ui->checkDIVI);
    list.append(ui->lineSLLI); listCheck.append(NULL);
    list.append(ui->lineSLAI); listCheck.append(ui->checkSLAI);
    list.append(ui->lineSRLI); listCheck.append(ui->checkSRLI);
    list.append(ui->lineSRAI); listCheck.append(NULL);
    list.append(ui->lineSHIFTI); listCheck.append(ui->checkSHIFTI);
    list.append(ui->lineANDI); listCheck.append(ui->checkANDI);
    list.append(ui->lineORI); listCheck.append(ui->checkORI);
    list.append(ui->lineNORI); listCheck.append(ui->checkNORI);
    list.append(ui->lineXORI); listCheck.append(ui->checkXORI);
    list.append(ui->lineFMOV); listCheck.append(NULL);
    list.append(ui->lineFNEG); listCheck.append(NULL);
    list.append(ui->lineFADD); listCheck.append(NULL);
    list.append(ui->lineFSUB); listCheck.append(NULL);
    list.append(ui->lineFMUL); listCheck.append(NULL);
    list.append(ui->lineFMULN); listCheck.append(ui->checkFMULN);
    list.append(ui->lineFDIV); listCheck.append(ui->checkFDIV);
    list.append(ui->lineFINV); listCheck.append(ui->checkFINV);
    list.append(ui->lineFINVN); listCheck.append(ui->checkFINVN);
    list.append(ui->lineFABS); listCheck.append(ui->checkFABS);
    list.append(ui->lineFSQRT); listCheck.append(NULL);
    list.append(ui->lineFLOOR); listCheck.append(ui->checkFLOOR);
    list.append(ui->lineFSIN); listCheck.append(ui->checkFSIN);
    list.append(ui->lineFCOS); listCheck.append(ui->checkFCOS);
    list.append(ui->lineFTAN); listCheck.append(ui->checkFTAN);
    list.append(ui->lineFATAN); listCheck.append(ui->checkFATAN);
    list.append(ui->lineITOF); listCheck.append(ui->checkITOF);
    list.append(ui->lineFTOI); listCheck.append(ui->checkFTOI);
    list.append(ui->lineIMOVF); listCheck.append(ui->checkIMOVF);
    list.append(ui->lineFMOVI); listCheck.append(ui->checkFMOVI);
    list.append(ui->lineSETLO); listCheck.append(NULL);
    list.append(ui->lineSETHI); listCheck.append(NULL);
    list.append(ui->lineFSETLO); listCheck.append(ui->checkFSETLO);
    list.append(ui->lineFSETHI); listCheck.append(ui->checkFSETHI);
    list.append(ui->lineJMP); listCheck.append(NULL);
    list.append(ui->lineBEQ); listCheck.append(ui->checkBEQ);
    list.append(ui->lineBNE); listCheck.append(ui->checkBNE);
    list.append(ui->lineBLT); listCheck.append(NULL);
    list.append(ui->lineBLE); listCheck.append(ui->checkBLE);
    list.append(ui->lineBGT); listCheck.append(ui->checkBGT);
    list.append(ui->lineBGE); listCheck.append(ui->checkBGE);
    list.append(ui->lineFBEQ); listCheck.append(ui->checkFBEQ);
    list.append(ui->lineFBNE); listCheck.append(ui->checkFBNE);
    list.append(ui->lineFBLT); listCheck.append(NULL);
    list.append(ui->lineFBLE); listCheck.append(ui->checkFBLE);
    list.append(ui->lineFBGT); listCheck.append(ui->checkFBGT);
    list.append(ui->lineFBGE); listCheck.append(ui->checkFBGE);
    list.append(ui->lineJMPREG); listCheck.append(NULL);
    list.append(ui->lineJMP_LNK); listCheck.append(NULL);
    list.append(ui->lineJMPREG_LNK); listCheck.append(NULL);
    list.append(ui->lineCALL); listCheck.append(NULL);
    list.append(ui->lineCALLREG); listCheck.append(NULL);
    list.append(ui->lineRETURN); listCheck.append(NULL);
    list.append(ui->lineST); listCheck.append(ui->checkST);
    list.append(ui->lineLD); listCheck.append(ui->checkLD);
    list.append(ui->lineFST); listCheck.append(ui->checkFST);
    list.append(ui->lineFLD); listCheck.append(ui->checkFLD);
    list.append(ui->lineSTI); listCheck.append(NULL);
    list.append(ui->lineLDI); listCheck.append(NULL);
    list.append(ui->lineFSTI); listCheck.append(NULL);
    list.append(ui->lineFLDI); listCheck.append(NULL);
    list.append(ui->lineINPUTBYTE); listCheck.append(NULL);
    list.append(ui->lineINPUTWORD); listCheck.append(ui->checkINPUTWORD);
    list.append(ui->lineINPUTFLOAT); listCheck.append(ui->checkINPUTFLOAT);
    list.append(ui->lineOUTPUTBYTE); listCheck.append(NULL);
    list.append(ui->lineOUTPUTWORD); listCheck.append(ui->checkOUTPUTWORD);
    list.append(ui->lineOUTPUTFLOAT); listCheck.append(ui->checkOUTPUTFLOAT);
    list.append(ui->lineHALT); listCheck.append(NULL);

    for (int i = 0; i < list.length(); i++)
    {
        opTableData[list[i]->whatsThis()] = i;
        ui->tableOpSets->verticalHeaderItem(i)->setText(list[i]->text());
        ui->tableOpSets->item(i, 0)->setWhatsThis("%1 = %2 + %3");

        if (listCheck[i])
        {
            listCheck[i]->setWhatsThis(list[i]->whatsThis());
            for (int j = 0; j < ui->tableOpSets->columnCount(); j++)
            {
                if (listCheck[i]->isChecked())
                {
                    ui->tableOpSets->item(i, j)->setFlags(ui->tableOpSets->item(i, j)->flags() | Qt::ItemIsEnabled);
                }
                else
                {
                    ui->tableOpSets->item(i, j)->setFlags(ui->tableOpSets->item(i, j)->flags() ^ Qt::ItemIsEnabled);
                }
            }
        }
    }

    changeCallUse();
}

void SolverDialog::setIRegs()
{
    for (int i = 0; i < ui->spinIRegNum->maximum(); i++)
    {
        QString reg =
                i < ui->spinIRegNum->value() ?
                    QString("%1%2").arg(ui->lineIRegPrefix->text()).arg(i) :
                    "";
        ui->comboZR->setItemText(i, reg);
        ui->comboFR->setItemText(i, reg);
        ui->comboHR->setItemText(i, reg);
        ui->comboP1R->setItemText(i, reg);
        ui->comboM1R->setItemText(i, reg);
        ui->comboLR->setItemText(i + 1, reg);
    }
}

void SolverDialog::setFRegConstNumMax(int max)
{
    ui->spinFRegConstNum->setMaximum(max);
}

void SolverDialog::changeOpName(QString name)
{
    ui->tableOpSets->verticalHeaderItem(opTableData[focusWidget()->whatsThis()])->setText(name);
}

void SolverDialog::changeCallUse()
{
    QTableWidgetItem* item;
    if (ui->radioJMPSIMPLE->isChecked())
    {
        for (int i = 0; i < ui->tableOpSets->columnCount(); i++)
        {
            item = ui->tableOpSets->item(opTableData["JMP_LNK"], i); item->setFlags(item->flags() | Qt::ItemIsEnabled);
            item = ui->tableOpSets->item(opTableData["JMPREG_LNK"], i); item->setFlags(item->flags() | Qt::ItemIsEnabled);
            item = ui->tableOpSets->item(opTableData["CALL"], i); item->setFlags(item->flags() & ~Qt::ItemIsEnabled);
            item = ui->tableOpSets->item(opTableData["CALLREG"], i); item->setFlags(item->flags() & ~Qt::ItemIsEnabled);
            item = ui->tableOpSets->item(opTableData["RETURN"], i); item->setFlags(item->flags() & ~Qt::ItemIsEnabled);
        }
    }
    else if (ui->radioJMPHARD->isChecked())
    {
        for (int i = 0; i < ui->tableOpSets->columnCount(); i++)
        {
            item = ui->tableOpSets->item(opTableData["JMP_LNK"], i); item->setFlags(item->flags() & ~Qt::ItemIsEnabled);
            item = ui->tableOpSets->item(opTableData["JMPREG_LNK"], i); item->setFlags(item->flags() & ~Qt::ItemIsEnabled);
            item = ui->tableOpSets->item(opTableData["CALL"], i); item->setFlags(item->flags() | Qt::ItemIsEnabled);
            item = ui->tableOpSets->item(opTableData["CALLREG"], i); item->setFlags(item->flags() | Qt::ItemIsEnabled);
            item = ui->tableOpSets->item(opTableData["RETURN"], i); item->setFlags(item->flags() | Qt::ItemIsEnabled);
        }
    }
}

void SolverDialog::changeUse()
{
    int row = opTableData[focusWidget()->whatsThis()];
    bool flg = ((QCheckBox)focusWidget()).isChecked();
    for (int i = 0; i < ui->tableOpSets->columnCount(); i++)
    {
        if (flg)
        {
            ui->tableOpSets->item(row, i)->setFlags(ui->tableOpSets->item(row, i)->flags() | Qt::ItemIsEnabled);
        }
        else
        {
            ui->tableOpSets->item(row, i)->setFlags(ui->tableOpSets->item(row, i)->flags() ^ Qt::ItemIsEnabled);
        }
    }
}

/*
void SolverDialog::toggleOrder()
{
    int row = opTableData[focusWidget()->whatsThis()];
    ui->tableOpSets->verticalHeaderItem(opTableData[focusWidget()->whatsThis()])->setText(name);
}
*/

void SolverDialog::showMessage(QString msg)
{
    QMessageBox::critical(
                NULL,
                "エラー",
                msg,
                QMessageBox::Ok);
}

bool SolverDialog::writeXML(QString path)
{
    QFile file(path);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text) == false)
    {
        QMessageBox::critical(
                    NULL,
                    "書き込みエラー",
                    "設定ファイルの書き込みができませんでした",
                    QMessageBox::Ok);
        return false;
    }

    QTextStream out(&file);

    out.setCodec("UTF-8");

    QString r = ui->lineIRegPrefix->text();
    QString f = ui->lineFRegPrefix->text();

    QString lr_index = QString("%1").arg(ui->comboLR->currentIndex() - 1);
    if (lr_index == "-1")
    {
        lr_index = "";
    }
    QString endian = ui->comboEndian->currentIndex() == 0 ? "LITTLE" : "BIG";
    QString ram_addressing = ui->comboRAMAddressing->currentIndex() == 0 ? "word" : "byte";
    QString rom_addressing = ui->comboROMAddressing->currentIndex() == 0 ? "word" : "byte";

    QString consts;
    for (int i = 0; i < ui->tableConsts->rowCount(); i++)
    {
        QString name = ui->tableConsts->item(i, 0)->text().trimmed();
        QString value = "0b" + ui->tableConsts->item(i, 1)->text().trimmed();
        // TOOD: nameがアルファベットのみ。valueは10のみで6文字以下
        if (name != "" && value != "0b")
        {
            consts += "\t\t\t<" + name + " value=\"" + value + "\"/>\n";
        }
    }

    QString insts;

    map<QString, int>::iterator iter = opTableData.begin();
    QStringList absoluteOps;
    QStringList relativeOps;
    relativeOps << "BEQ" << "BNE" << "BLT" << "BLE" << "BGT" << "BGE";
    relativeOps << "FBEQ" << "FBNE" << "FBLT" << "FBLE" << "FBGT" << "FBGE";
    for (int i = 0; i < ui->tableOpSets->rowCount() || iter != opTableData.end(); i++, iter++)
    {
        int row = (*iter).second;
        QString type = (*iter).first;
        QString use = ui->tableOpSets->item(row, 0)->flags() & Qt::ItemIsEnabled ? "" : " use=\"false\"";
        QString name = " name=\"" + ui->tableOpSets->verticalHeaderItem((*iter).second)->text() + "\"";
        QString addressMode = "";
        QString op = ui->tableOpSets->item(row, 1)->text();
        QString funct = op[0].isDigit() ? "" : " funct=\"0b" + ui->tableOpSets->item(row, 2)->text() + "\"";

        if (absoluteOps.contains(type))
        {
            addressMode = " addressMode=\"absolute\"";
        }
        else if (relativeOps.contains(type))
        {
            addressMode = " addressMode=\"relative\"";
        }

        // TODO
        op = " op=\"" + (op[0].isDigit() ? "0b" + op : op) + "\"";

        // TODO formAsm attribute
        insts += "\t\t<" + type + use + name + op + funct + addressMode + "/>\n";
    }

    QString add = ui->lineADD->text();
    QString sub = ui->lineSUB->text();
    QString nor = ui->lineNOR->text();
    QString addi = ui->lineADDI->text();
    QString fsethi = ui->lineFSETHI->text();
    QString fsetlo = ui->lineFSETLO->text();

    // QStringでくくると日本語もいい感じに表示されるっぽい
    out     << "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\" ?>\n"
            << "<architecture name=\"" << ui->lineArchName->text() << "\">\n"
            << "\t<registers>\n"
            << QString("\t\t<!-- %は特殊文字として扱われるためとして%%とエスケープする -->\n")
            << "\t\t<intRegs num=\"" << ui->spinIRegNum->text() << "\" prefix=\"" << r << "\"/>\n"
            << "\t\t<floatRegs num=\"" << ui->spinFRegNum->text() << "\" prefix=\"" << f << "\"/>\n"
            << "\t\t<constFloatRegs num=\"" << ui->spinFRegConstNum->text() << "\"/>\n"
            << "\t\t<zeroReg index=\"" << ui->comboZR->currentIndex() << "\"/>\n"
            << "\t\t<frameReg index=\"" << ui->comboFR->currentIndex() << "\"/>\n"
            << "\t\t<heapReg index=\"" << ui->comboHR->currentIndex() << "\"/>\n"
            << "\t\t<oneReg index=\"" << ui->comboP1R->currentIndex() << "\"/>\n"
            << "\t\t<minusOneReg index=\"" << ui->comboM1R->currentIndex() << "\"/>\n"
            << QString("\t\t<!-- indexを\"\"にすると汎用レジスタとは別に用意されたレジスタが使われる -->\n")
            << "\t\t<linkReg index=\"" << lr_index << "\"/>\n"
            << "\t</registers>\n"
            << "\n"
            << "\t<RAM size=\"" << ui->spinRAMSize->text() << "\" />\n"
            << "\t<comment text=\"" << ui->lineComment->text() << "\" />\n"
            << "\n"
            << "\t<binary endian=\"" << endian << "\" constTableType=\"no_use\" tag=\"0xffFFffFF\" addressing=\"" << ram_addressing << "\" rom_addressing=\"" << rom_addressing << "\" direction=\"toBig\"/>\n"
            << "\t<instructions forward=\"true\">\n"
            << "\t\t<CONST>\n"
            << consts
            << "\t\t</CONST>\n"
            << "\n"
            << insts
            << "\n"
            << "\t\t<mnemonics>\n"
            << "\t\t\t<NOP name=\"nop\" formAsm=\"\">\n"
            << "\t\t\t\t<inst command=\"&quot;" << add << "\\t" << r << "0, " << r << "0, " << r << "0&quot;\"/>\n"
            << "\t\t\t</NOP>\n"
            << "\t\t\t<MOV name=\"mov\" formAsm=\"IRT, IRS\">\n"
            << "\t\t\t\t<inst command=\"&quot;" << add << "\\t" << r << "%d, " << r << "%d, " << r << "0&quot;, rt, rs\"/>\n"
            << "\t\t\t</MOV>\n"
            << "\t\t\t<NOT name=\"not\" formAsm=\"IRT, IRS\">\n"
            << "\t\t\t\t<inst command=\"&quot;" << nor << "\\t" << r << "%d, " << r << "%d, " << r << "0&quot;, rt, rs, rs\" />\n"
            << "\t\t\t</NOT>\n"
            << "\t\t\t<NEG name=\"neg\" formAsm=\"IRT, IRS\">\n"
            << "\t\t\t\t<inst command=\"&quot;" << sub << "\\t" << r << "%d, " << r << "0, " << r << "%d&quot;, rt, rs\"/>\n"
            << "\t\t\t</NEG>\n"
            << "\t\t\t<SETL name=\"setl\" formAsm=\"IRS, LABEL\">\n"
            << "\t\t\t\t<inst useLabel=\"true\" command=\"&quot;" << addi << "\\t" << r << "%d, " << r << "0, 0&quot;, rs\"/>\n"
            << "\t\t\t</SETL>\n"
            << "\t\t\t<FSET name=\"fliw\" formAsm=\"FRS, FLOAT\">\n"
            << "\t\t\t\t<inst command=\"&quot;" << fsetlo << "\\t" << f << "%d, %d&quot;, rs, gethi(d)\"/>\n"
            << "\t\t\t\t<inst command=\"&quot;" << fsethi << "\\t" << f << "%d, %d&quot;, rs, getlo(d)\"/>\n"
            << "\t\t\t</FSET>\n"
            << "\t\t</mnemonics>\n"
            << "\t</instructions>\n"
            << "</architecture>\n";

    file.close();

    return true;
}

void SolverDialog::generate()
{
    QString filepath = QFileDialog::getExistingDirectory(
                this,
                "アーキテクチャを作成場所を選んでください",
                ".");
    if (filepath == "" || QDir(filepath).exists() == false)
    {
        return;
    }
    QString configFile = ui->lineArchName->text() + ".xml";
    writeXML("templates/" + configFile);
    if (QDir(filepath).exists() == false) return;
    genDlg.init("../" + configFile, filepath + "/" + ui->lineArchName->text());
    genDlg.show();
    return;
}
