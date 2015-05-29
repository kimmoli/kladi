/*
    kladi, Pastebin application
*/

#include "pastes.h"

Pastes::Pastes(QObject *parent) :
    QObject(parent)
{
    _pastes = QString();

    pbApi = new PastebinApi(this, DEVELKEY, getSetting("userkey", QString()).toString());

    connect(pbApi, SIGNAL(gotData(QString)), this, SLOT(processData(QString)));
}

Pastes::~Pastes()
{
}

void Pastes::test()
{
    qDebug() << "test";

    pbApi->paste("testi", "testi juttua", "", "1H", "0");
}

QVariant Pastes::getSetting(QString name, QVariant defaultValue)
{
    QSettings s("harbour-kladi", "harbour-kladi");
    s.beginGroup("Settings");
    QVariant settingValue = s.value(name, defaultValue);
    s.endGroup();

    return settingValue;
}

void Pastes::setSetting(QString name, QVariant value)
{
    QSettings s("harbour-kladi", "harbour-kladi");
    s.beginGroup("Settings");
    s.setValue(name, value);
    s.endGroup();
}

void Pastes::requestPastes()
{
    pbApi->fetchAll();
}

void Pastes::processData(QString data)
{
    qDebug() << "processing";

    // pastebin reply is close to xml, need to add headers
    _pastes = QString("<?xml version=\"1.0\" encoding=\"utf-8\"?><data>%1</data>").arg(data);
    emit pastesChanged();
}

QString Pastes::xml()
{
    return _pastes;
}
