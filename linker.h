#ifndef LINKER_H
#define LINKER_H

#include <QStringList>
#include <QTextStream>
#include <QFile>

class linker
{
public:
    linker();
    bool open(const QString filepath, QFile& file, QTextStream& stream, QFlags<QIODevice::OpenModeFlag> flgs);
    void close(QFile& file);
    int getHeapSize(QTextStream& stream);
    void writeHeapInitialize(QTextStream& stream, int heap_size, QTextStream& out);
    bool link(QStringList srcs, QString dst);
};

#endif // LINKER_H
