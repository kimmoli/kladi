#include "consolereader.h"
#include <unistd.h>
#include <QtDBus/QtDBus>
#include <QtDBus/QDBusArgument>

consolereader::consolereader(QString title, QString expire, QObject *parent) :
    QObject(parent), running(true), _title(title), _expire(expire)
{
    p = new Pastes();

    if (!p->userKeyOk())
    {
        printf("Please login first through GUI\n");

        running = false;
        return;
    }

    connect(p, SIGNAL(error()), this, SLOT(error()));
    connect(p, SIGNAL(success()), this, SLOT(success()));

    char ch;
    while(read(STDIN_FILENO, &ch, 1) > 0)
    {
        _buffer.append(ch);
    }
    // loop exits on ctrl-D, EOF

    printf("Please wait...\n");

    if (!QString("N 10M 1H 1D 1W 2W 1M").contains(_expire))
        _expire = "1M";

    p->newPaste(_title, _buffer, "text", _expire, "1");

}

void consolereader::error()
{
    printf("Paste failed: %s\n", qPrintable(p->msg()));
    emit quit();
}

void consolereader::success()
{
    printf("Paste URL: %s\n", qPrintable(p->msg()));

    QDBusMessage m = QDBusMessage::createMethodCall("com.kimmoli.kladi",
                                                    "/",
                                                    "",
                                                    "fetchAll" );

    QDBusConnection::sessionBus().send(m);

    emit quit();
}

consolereader::~consolereader()
{
}
