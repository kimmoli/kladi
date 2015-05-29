#ifndef PASTEBINAPI_H
#define PASTEBINAPI_H

#include <QObject>
#include <QNetworkRequest>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class PastebinApi : public QObject
{
    Q_OBJECT
public:
    explicit PastebinApi(QObject *parent = 0, QString devKey = "", QString userKey = "");
    void paste(QString name, QString code, QString format, QString expire, QString priv);

    QString apiUrl;
    void fetchAll();

signals:
    void pasted(QString url);
    void gotData(QString data);

//public slots:

private slots:
    void finished(QNetworkReply *reply);
    void errorReply(QNetworkReply::NetworkError error);

private:
    QNetworkAccessManager *_manager;

    QString _devKey;
    QString _userKey;


};

#endif // PASTEBINAPI_H
