#-------------------------------------------------
#
# Project created by QtCreator 2012-02-03T20:52:10
#
#-------------------------------------------------

QT       += core gui

TARGET = CPUExSolver
TEMPLATE = app


SOURCES += main.cpp\
        mainwindow.cpp \
    aboutdialog.cpp \
    edit.cpp \
    file.cpp \
    projectview.cpp \
    help.cpp \
    run.cpp \
    finddialog.cpp \
    configdialog.cpp \
    config.cpp \
    solver.cpp \
    solverdialog.cpp \
    generatingdialog.cpp

HEADERS  += mainwindow.h \
    global.h \
    aboutdialog.h \
    linker.h \
    finddialog.h \
    configdialog.h \
    solverdialog.h \
    generatingdialog.h

FORMS    += mainwindow.ui \
    aboutdialog.ui \
    finddialog.ui \
    configdialog.ui \
    solverdialog.ui \
    generatingdialog.ui

RESOURCES += \
    resources.qrc
