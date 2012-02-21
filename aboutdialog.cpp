#include "aboutdialog.h"
#include "ui_aboutdialog.h"
#include <QSize>

aboutdialog::aboutdialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::aboutdialog)
{
    ui->setupUi(this);

    bool res = pixmap.load("./resources/ika.jpg");
    pixmap = pixmap.scaled(
                QSize(
                    ui->graphicsView->width() - 5,
                    ui->graphicsView->height() - 5));
    scene.addPixmap(pixmap);
    ui->graphicsView->setScene(&scene);
}

aboutdialog::~aboutdialog()
{
    delete ui;
}
