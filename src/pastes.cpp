/*
    kladi, Pastebin application
*/

#include "pastes.h"
#include <QtQml>

Pastes::Pastes(QObject *parent) :
    QObject(parent)
{
    _pastes = QString();
    _apiUrl = "https://pastebin.com/api/api_post.php";
    _rawUrl = "http://pastebin.com/raw.php";
    _loginUrl = "https://pastebin.com/api/api_login.php";
    _userKey = getSetting("userkey", QString()).toString();
    emit userKeyOkChanged();
    _develKey = DEVELKEY;
    _lastRequest = None;

    _manager = new QNetworkAccessManager(this);

    connect(_manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(finished(QNetworkReply*)));
}

Pastes::~Pastes()
{
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

    if (name == "userkey")
    {
        _userKey = value.toString();
        emit userKeyOkChanged();
    }
}

void Pastes::newPaste(QString name, QString code, QString format, QString expire, QString priv)
{
    QString opt = "paste";

    if (format.isEmpty())
        format = "text";

    qDebug() << name;
    qDebug() << code;
    qDebug() << format << expire << priv;

    QNetworkRequest req;
    req.setUrl(QUrl(_apiUrl));

    QString datas("api_option=" + opt +
                  "&api_dev_key=" + _develKey +
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

    _lastRequest = New;

    QNetworkReply *reply = _manager->post(req, data);

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(errorReply(QNetworkReply::NetworkError)));
}

void Pastes::fetchAll()
{
    QString opt = "list";

    QNetworkRequest req;
    req.setUrl(QUrl(_apiUrl));

    QString datas("api_option=" + opt +
                  "&api_dev_key=" + _develKey +
                  "&api_user_key=" + _userKey);

    QByteArray data = datas.toLocal8Bit();

    req.setRawHeader("Accept", "text/*");
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    req.setHeader(QNetworkRequest::ContentLengthHeader, QString::number(data.size()));

    _lastRequest = List;

    QNetworkReply *reply = _manager->post(req, data);

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(errorReply(QNetworkReply::NetworkError)));
}

void Pastes::fetchRaw(QString key)
{
    if (key.isEmpty())
        return;

    QUrl url(_rawUrl);
    QUrlQuery q;

    q.addQueryItem("i", key);

    url.setQuery(q);

    QNetworkRequest req(url);

    req.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);
    req.setAttribute(QNetworkRequest::Attribute(QNetworkRequest::User + 1), key);
    QNetworkReply *reply = _manager->get(req);

    _lastRequest = Raw;

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(errorReply(QNetworkReply::NetworkError)));
}

void Pastes::deletePaste(QString key)
{
    if (key.isEmpty())
        return;

    QString opt = "delete";

    QNetworkRequest req;
    req.setUrl(QUrl(_apiUrl));

    QString datas("api_option=" + opt +
                  "&api_dev_key=" + _develKey +
                  "&api_user_key=" + _userKey +
                  "&api_paste_key=" + key);

    QByteArray data = datas.toLocal8Bit();

    req.setRawHeader("Accept", "text/*");
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    req.setHeader(QNetworkRequest::ContentLengthHeader, QString::number(data.size()));

    _lastRequest = Delete;

    QNetworkReply *reply = _manager->post(req, data);

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(errorReply(QNetworkReply::NetworkError)));
}

void Pastes::requestUserKey(QString username, QString password)
{
    if (username.isEmpty() || password.isEmpty())
        return;

    QNetworkRequest req;
    req.setUrl(QUrl(_loginUrl));

    QString datas("api_dev_key=" + _develKey +
                  "&api_user_name=" + QUrl::toPercentEncoding(username) +
                  "&api_user_password=" + QUrl::toPercentEncoding(password));

    QByteArray data = datas.toLocal8Bit();

    req.setRawHeader("Accept", "text/*");
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    req.setHeader(QNetworkRequest::ContentLengthHeader, QString::number(data.size()));

    _lastRequest = UserKey;

    QNetworkReply *reply = _manager->post(req, data);

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(errorReply(QNetworkReply::NetworkError)));
}

void Pastes::fetchUserInfo()
{
    QString opt = "userdetails";

    QNetworkRequest req;
    req.setUrl(QUrl(_apiUrl));

    QString datas("api_option=" + opt +
                  "&api_dev_key=" + _develKey +
                  "&api_user_key=" + _userKey);

    QByteArray data = datas.toLocal8Bit();

    req.setRawHeader("Accept", "text/*");
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    req.setHeader(QNetworkRequest::ContentLengthHeader, QString::number(data.size()));

    _lastRequest = UserInfo;

    QNetworkReply *reply = _manager->post(req, data);

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(errorReply(QNetworkReply::NetworkError)));
}


/*****************/

void Pastes::finished(QNetworkReply *reply)
{
    QString r(reply->readAll());
    reply->deleteLater();

    qDebug() << "Got reply";

    if (r.startsWith("Bad API request"))
    {
        qDebug() << "error";
        _lastRequest = None;

        _message = r;
        emit error();
    }
    else if (r.startsWith("<user>") && _lastRequest == UserInfo)
    {
        qDebug() << "looks like user info";
        _lastRequest = None;

        _userInfo = QString("<?xml version=\"1.0\" encoding=\"utf-8\"?><data>%1</data>").arg(r);
        emit userInfoChanged();
    }
    else if (r.startsWith("<paste>") && _lastRequest == List)
    {
        qDebug() << "looks like list of pastes";
        _lastRequest = None;

        _pastes = QString("<?xml version=\"1.0\" encoding=\"utf-8\"?><data>%1</data>").arg(r);
        emit pastesChanged();
    }
    else if (r.startsWith("No pastes") && _lastRequest == List)
    {
        qDebug() << "No pastes. damnit.";
        _lastRequest = None;

        _pastes = QString("<?xml version=\"1.0\" encoding=\"utf-8\"?><data></data>");
        emit pastesChanged();
    }
    else if (_lastRequest == New)
    {
        _lastRequest = None;
        if (r.startsWith("http"))
        {
            qDebug() << "this was a URL, so paste success";

            _message = r;
            emit success();
        }
        else
        {
            qDebug() << "Not an URL, raise error";

            _message = r;
            emit error();
        }
    }
    else if (r.length() == 32 && _lastRequest == UserKey)
    {
        qDebug() << "seems to be a user key";
        _lastRequest = None;

        setSetting("userkey", r);

        _message = "New key successfully collected";
        emit success();
    }
    else if (r.startsWith("Paste Removed") && _lastRequest == Delete)
    {
        qDebug() << "deleted";
        _lastRequest = None;

        _message = "Deleted succesfully";
        emit success();
    }
    else if (_lastRequest == Raw)
    {
        qDebug() << "raw";
        _lastRequest = None;

        if (r.isEmpty())
        {
            _message = "This paste is empty!<br>Deleted? Expired?";
            emit error();
        }
        else
        {
           _rawPaste = r;
           emit rawPasteChanged();
        }
    }
}

void Pastes::errorReply(QNetworkReply::NetworkError error)
{
    qCritical() << error << ((QNetworkReply *)sender())->errorString();
}

/******************************/

bool Pastes::fileExists(QString filename)
{
    QString filepath = QString("%1/%2")
            .arg(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation))
            .arg(filename);

    QFile test(filepath);

    return test.exists();
}

bool Pastes::save(QString filename, QString data)
{
    QString filepath = QString("%1/%2")
            .arg(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation))
            .arg(filename);

    QFile f(filepath);

    if (!f.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text))
        return false;

    f.write(data.toLocal8Bit());
    f.close();

    return true;
}
