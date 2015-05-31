/*
    kladi, Pastebin application
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.XmlListModel 2.0
import harbour.kladi.Pastes 1.0
import "components"

ApplicationWindow
{
    id: kladi

    onApplicationActiveChanged: openingBrowser = false

    initialPage: Qt.resolvedUrl("pages/FrontPage.qml")
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    property bool dataReady: false
    property bool processing: false
    property bool openingBrowser: false
    property bool userInfoFetced: false

    property string currentPasteTitle: ""
    property string currentPasteSize: ""
    property string currentPasteFormat: ""
    property string currentPasteDate: ""
    property string currentPasteExpire: ""
    property string currentPastePrivacy: ""

    property string userName: ""
    property string userFormat: "text"
    property string userPrivacy: "1"
    property string userExpire: "1M"

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

            if (!userInfoFetced)
            {
                dataReady = false
                pastes.fetchUserInfo()
            }
        }

        onUserInfoChanged:
        {
            console.log("user info changed")

            myInfo.xml = pastes.userInfo()
            myInfo.reload()
        }

        onRawPasteChanged:
        {
            processing = false
            pageStack.push(Qt.resolvedUrl("pages/ShowPaste.qml"))
            pageStack.pushAttached(Qt.resolvedUrl("pages/PasteInfo.qml"))
        }

        onError:
        {
            processing = false
            dataReady = true
            messagebox.showError(pastes.msg())
        }

        onSuccess:
        {
            messagebox.showMessage(pastes.msg())
            //myPastes.xml = ""
            dataReady = false
            processing = false
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
        running: !dataReady || processing || openingBrowser
    }

    XmlListModel
    {
        id: myPastes

        query: "/data/paste"

        XmlRole { name: "paste_title"; query: "paste_title/string()" }
        XmlRole { name: "paste_key"; query: "paste_key/string()" }
        XmlRole { name: "paste_date"; query: "paste_date/string()" }
        XmlRole { name: "paste_private"; query: "paste_private/string()" }
        XmlRole { name: "paste_size"; query: "paste_size/string()" }
        XmlRole { name: "paste_format_long"; query: "paste_format_long/string()" }
        XmlRole { name: "paste_expire_date"; query: "paste_expire_date/string()" }

        onStatusChanged:
        {
            switch (status)
            {
                case XmlListModel.Ready:    console.log("[READY] " + count + " items"); break
                case XmlListModel.Error:    console.log("[ERROR] Error: ''" + errorString() + "'"); break
                case XmlListModel.Loading:  console.log("[LOADING]"); break
            }
            if (status == XmlListModel.Ready)
                dataReady = true
        }
    }

    XmlListModel
    {
        id: myInfo

        query: "/data/user"

        XmlRole { name: "user_name"; query: "user_name/string()" }
        XmlRole { name: "user_format_short"; query: "user_format_short/string()" }
        XmlRole { name: "user_expiration"; query: "user_expiration/string()" }
        XmlRole { name: "user_private"; query: "user_private/string()" }

        onStatusChanged:
        {
            switch (status)
            {
                case XmlListModel.Ready:    console.log("[READY] " + count + " items"); break
                case XmlListModel.Error:    console.log("[ERROR] Error: ''" + errorString() + "'"); break
                case XmlListModel.Loading:  console.log("[LOADING]"); break
            }
            if (status == XmlListModel.Ready)
            {
                userInfoFetced = true
                dataReady = true
                if (myInfo.count>0)
                {
                    userName = myInfo.get(0).user_name
                    userExpire = myInfo.get(0).user_expiration
                    userFormat = myInfo.get(0).user_format_short
                    userPrivacy = myInfo.get(0).user_private
                    if (userPrivacy == "2")
                    {
                        userPrivacy = "1"
                        messagebox.showError("Private pastes not supported<br>Setting to unlisted")
                    }

                }
            }
        }
    }
}


