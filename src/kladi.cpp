/*
    kladi, Pastebin application
*/


#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QtQml>
#include <QScopedPointer>
#include <QQuickView>
#include <QQmlEngine>
#include <QGuiApplication>
#include <QQmlContext>
#include <QCoreApplication>
#include "pastes.h"
#include "consolereader.h"

int main(int argc, char *argv[])
{
    if (argc > 1)
    {
        if (QString(argv[1]) == "-")
        {
            QCoreApplication* capp;
            capp = new QCoreApplication(argc, argv);
            QString title("Pasted from Jolla");
            QString expire("1M");

            if (argc > 2)
                title = QString(argv[2]);
            if (argc > 3)
                expire = QString(argv[3]);

            consolereader *c = new consolereader(title, expire);

            capp->connect(c, SIGNAL(quit()), capp, SLOT(quit()));

            if (c->running)
                return capp->exec();
        }
        return 0;
    }

    printf("Kladi version %s (C) kimmoli 2015\n\n", APPVERSION);
    printf("To use this from console, login through GUI, and start\n");
    printf("  harbour-kladi - {title} {expire=N,10M,1H,1D,1W,2W,1M}\n");
    printf("to get paste input from stdin.\n\n");

    qmlRegisterType<Pastes>("harbour.kladi.Pastes", 1, 0, "Pastes");

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->setSource(SailfishApp::pathTo("qml/kladi.qml"));
    view->show();

    app->setApplicationVersion(APPVERSION);

    return app->exec();
}

