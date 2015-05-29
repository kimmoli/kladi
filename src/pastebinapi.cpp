#include "pastebinapi.h"

PastebinApi::PastebinApi(QObject *parent, QString devKey, QString userKey) :
    QObject(parent)
{
    _devKey = devKey;
    _userKey = userKey;
    _manager = new QNetworkAccessManager(this);

    apiUrl = "http://pastebin.com/api/api_post.php";

    qDebug() << "devkey" << _devKey;
    qDebug() << "userkey" << _userKey;

    connect(_manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(finished(QNetworkReply*)));
}

void PastebinApi::paste(QString name, QString code, QString format, QString expire, QString priv)
{
    QString opt = "paste";

    if (format.isEmpty())
        format = "text";

    qDebug() << name;
    qDebug() << code;
    qDebug() << format << expire << priv;

    QNetworkRequest req;
    req.setUrl(QUrl(apiUrl));

    QString datas("api_option=" + opt +
                  "&api_dev_key=" + _devKey +
                  "&api_user_key=" + _userKey +
                  "&api_paste_name=" + QUrl::toPercentEncoding(name) +
                  "&api_paste_format=" + format +
                  "&api_paste_private=" + priv +
                  "&api_paste_expire_date=" + expire +
                  "&api_paste_code=" + QUrl::toPercentEncoding(code));

    QByteArray data = datas.toLocal8Bit();

    req.setRawHeader("Accept", "text/*");
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    req.setHeader(QNetworkRequest::ContentLengthHeader, QString::number(data.size()));

    QNetworkReply *reply = _manager->post(req, data);

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(errorReply(QNetworkReply::NetworkError)));
}

void PastebinApi::finished(QNetworkReply *reply)
{
    QByteArray r = reply->readAll();
    reply->deleteLater();

    qDebug() << "got reply";

    if (QString(r).startsWith("<paste>"))
    {
        qDebug() << "looks like data";
        emit gotData(QString(r));
        return;
    }

    if (QString(r).startsWith("http"))
    {
        qDebug() << "this was a URL";
        emit pasted(QString(r));
        return;
    }

    qDebug() << "dunno what was it";

}

void PastebinApi::errorReply(QNetworkReply::NetworkError error)
{
    qCritical() << error << ((QNetworkReply *)sender())->errorString();
}

void PastebinApi::fetchAll()
{
    QString opt = "list";

    QNetworkRequest req;
    req.setUrl(QUrl(apiUrl));

    QString datas("api_option=" + opt +
                  "&api_dev_key=" + _devKey +
                  "&api_user_key=" + _userKey);

    QByteArray data = datas.toLocal8Bit();

    req.setRawHeader("Accept", "text/*");
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    req.setHeader(QNetworkRequest::ContentLengthHeader, QString::number(data.size()));

    QNetworkReply *reply = _manager->post(req, data);

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(errorReply(QNetworkReply::NetworkError)));
}
