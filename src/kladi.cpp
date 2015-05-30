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


int main(int argc, char *argv[])
{
    qmlRegisterType<Pastes>("harbour.kladi.Pastes", 1, 0, "Pastes");

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->setSource(SailfishApp::pathTo("qml/kladi.qml"));
    view->show();

    app->setApplicationVersion(APPVERSION);

    return app->exec();
}

