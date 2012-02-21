#ifndef ABOUTDIALOG_H
#define ABOUTDIALOG_H

#include <QDialog>
#include <QGraphicsScene>
#include <QPixmap>

namespace Ui {
class aboutdialog;
}

class aboutdialog : public QDialog
{
    Q_OBJECT
    
public:
    explicit aboutdialog(QWidget *parent = 0);
    ~aboutdialog();
    
private:
    Ui::aboutdialog *ui;
    QPixmap pixmap;
    QGraphicsScene scene;
};

#endif // ABOUTDIALOG_H
