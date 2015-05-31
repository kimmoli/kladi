#include "consolereader.h"
#include <unistd.h>
#include <QtDBus/QtDBus>
#include <QtDBus/QDBusArgument>

consolereader::consolereader(QObject *parent) :
    QObject(parent)
{
    p = new Pastes();

    if (!p->userKeyOk())
    {
        printf("Please login first through GUI\n");

        emit quit();
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

    p->newPaste("Pasted from Jolla", _buffer, "text", "1H", "1");

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
