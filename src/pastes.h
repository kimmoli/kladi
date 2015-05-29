/*
    kladi, Pastebin application
*/

#ifndef PASTES_H
#define PASTES_H
#include <QObject>
#include <QDebug>
#include <QSettings>

#include "pastebinapi.h"

class Pastes : public QObject
{
    Q_OBJECT

public:
    explicit Pastes(QObject *parent = 0);
    ~Pastes();

    Q_INVOKABLE QVariant getSetting(QString name, QVariant defaultValue);
    Q_INVOKABLE void setSetting(QString name, QVariant value);

    Q_INVOKABLE void test();

    Q_INVOKABLE void requestPastes();
    Q_INVOKABLE QString xml();

public slots:
    void processData(QString data);

signals:
    void pastesChanged();

private:
    PastebinApi *pbApi;
    QString _pastes;
};


#endif // PASTES_H

