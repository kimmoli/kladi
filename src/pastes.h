/*
    kladi, Pastebin application
*/

#ifndef PASTES_H
#define PASTES_H
#include <QObject>
#include <QDebug>
#include <QSettings>
#include <QNetworkRequest>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QUrl>
#include <QUrlQuery>

class Pastes : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool userKeyOk READ userKeyOk NOTIFY userKeyOkChanged)

public:
    explicit Pastes(QObject *parent = 0);
    ~Pastes();

    Q_INVOKABLE QVariant getSetting(QString name, QVariant defaultValue);
    Q_INVOKABLE void setSetting(QString name, QVariant value);

    Q_INVOKABLE void newPaste(QString name, QString code, QString format="text", QString expire="N", QString priv="0");
    Q_INVOKABLE void fetchAll();
    Q_INVOKABLE void deletePaste(QString key);
    Q_INVOKABLE void requestUserKey(QString username, QString password);
    Q_INVOKABLE void fetchRaw(QString key);

    bool userKeyOk() { return (_userKey.length() == 32); }

    Q_INVOKABLE QString xml() { return _pastes; }
    Q_INVOKABLE QString raw() { return _rawPaste; }
    Q_INVOKABLE QString msg() { return _message; }

    enum Request
    {
        None,
        New,
        List,
        Delete,
        UserKey,
        Login,
        Raw
    };

signals:
    void pastesChanged();
    void error();
    void rawPasteChanged();
    void success();
    void userKeyOkChanged();

private slots:
    void finished(QNetworkReply *reply);
    void errorReply(QNetworkReply::NetworkError error);

private:
    QString _pastes;
    QString _apiUrl;
    QString _rawUrl;
    QString _loginUrl;
    QString _userKey;
    QString _develKey;
    QNetworkAccessManager *_manager;
    QString _rawPaste;
    QString _message;
    Request _lastRequest;

};


#endif // PASTES_H

