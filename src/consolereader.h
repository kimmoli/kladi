#ifndef CONSOLEREADER_H
#define CONSOLEREADER_H

#include <QObject>
#include "pastes.h"

class consolereader : public QObject
{
    Q_OBJECT
public:
    explicit consolereader(QObject *parent = 0);
    ~consolereader();

    bool running;

signals:
    void quit();

public slots:
    void success();
    void error();

public:
    Pastes *p;
    QString _buffer;

};

#endif // CONSOLEREADER_H
