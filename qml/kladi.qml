/*
    kladi, Pastebin application
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.XmlListModel 2.0
import kladi.Pastes 1.0
import "components"

ApplicationWindow
{
    id: kladi

    initialPage: Qt.resolvedUrl("pages/FrontPage.qml")
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    property bool dataReady: false

    Pastes
    {
        id: pastes

        Component.onCompleted:
        {
            pastes.fetchAll()
        }

        onPastesChanged:
        {
            console.log("pastes changed")

            myPastes.xml = pastes.xml()
            myPastes.reload()
        }

        onRawPasteChanged:
        {
            pageStack.push(Qt.resolvedUrl("pages/ShowPaste.qml"))
        }

        onError:
        {
            messagebox.showError(pastes.msg())
        }

        onSuccess:
        {
            messagebox.showMessage(pastes.msg())
            myPastes.xml = ""
            dataReady = false
            pastes.fetchAll()
        }
    }

    Messagebox
    {
        id: messagebox
    }

    BusyIndicator
    {
        id: isBusy
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: !dataReady
    }

    XmlListModel
    {
        id: myPastes

        query: "/data/paste"

        XmlRole { name: "paste_title"; query: "paste_title/string()" }
        XmlRole { name: "paste_key"; query: "paste_key/string()" }
        XmlRole { name: "paste_date"; query: "paste_date/string()" }
        XmlRole { name: "paste_private"; query: "paste_private/string()" }

        onStatusChanged:
        {
            switch (status)
            {
                case XmlListModel.Ready:    console.log("[READY]   '" + source + "' | "  + count + " items"); break
                case XmlListModel.Error:    console.log("[ERROR]   '" + source + "' | Error: ''" + errorString() + "'"); break
                case XmlListModel.Loading:  console.log("[LOADING] '" + source + "'"); break
            }

            if (status == XmlListModel.Ready)
                dataReady = true
        }
    }
}


