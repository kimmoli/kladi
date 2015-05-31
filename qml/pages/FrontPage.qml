/*
    kladi, Pastebin application
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: page

    SilicaFlickable
    {
        anchors.fill: parent

        PullDownMenu
        {
            MenuItem
            {
                text: "About..."
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem
            {
                text:
                {
                    if (pastes.userKeyOk && userName.length > 0)
                        return "Logged in as " + userName
                    return "Login"
                }
                onClicked: pageStack.push(Qt.resolvedUrl("LoginPage.qml"))
            }
            MenuItem
            {
                text: "Refresh"
                enabled: pastes.userKeyOk
                onClicked:
                {
                    dataReady = false
                    pastes.fetchAll()
                }
            }

            MenuItem
            {
                text: "New paste from clipboard"
                enabled: pastes.userKeyOk
                onClicked:
                {
                    processing = true
                    pastes.newPaste("Pasted from Jolla", Clipboard.text, userFormat, userExpire, userPrivacy)
                }
            }
            MenuItem
            {
                text: "New paste..."
                enabled: pastes.userKeyOk
                onClicked:
                {
                    var editDialog = pageStack.push(Qt.resolvedUrl("EditPaste.qml"))
                    editDialog.accepted.connect(function()
                    {
                        processing = true
                        pastes.newPaste(editDialog.pasteTitle, editDialog.code, editDialog.format, editDialog.expire, editDialog.privacy)
                    })
                }
            }
        }

        InteractionHintLabel
        {
            id: noData
            anchors.centerIn: parent
            text:
            {
                if (!pastes.userKeyOk)
                    return "You need to login first. Pulldown to login"
                return "You do not have any pastes. Pulldown to submit new paste"
            }
            visible: dataReady && myPastes.count === 0
            onVisibleChanged: if (visible) pdHint.start(); else pdHint.stop()
        }

        TouchInteractionHint
        {
            id: pdHint
            direction: TouchInteraction.Down
            anchors.horizontalCenter: parent.horizontalCenter
            loops: 3
        }

        SilicaListView
        {
            id: listView
            anchors.fill: parent
            model: myPastes

            header: PageHeader { title: "Your pastebin" }

            VerticalScrollDecorator {}

            delegate: ListItem
            {
                function remove()
                {
                    remorseAction("Deleting", function()
                    {
                        processing = true
                        pastes.deletePaste(paste_key)
                    })
                }

                id: listItem
                menu: ContextMenu
                {
                    MenuItem
                    {
                        text: "Copy URL to clipboard"
                        onClicked: Clipboard.text = "http://pastebin.com/" + paste_key
                    }
                    MenuItem
                    {
                        text: "Open in browser"

                        onClicked:
                        {
                            openingBrowser = true
                            Qt.openUrlExternally("http://pastebin.com/" + paste_key)
                        }
                    }
                    MenuItem
                    {
                        text: "Delete (no undo)"
                        onClicked:
                        {
                            remove()
                        }
                    }
                }

                onClicked:
                {
                    if (paste_expire_date != 0 && paste_expire_date < new Date()/1000)
                    {
                        messagebox.showMessage("This paste has expired, refreshing")

                        dataReady = false
                        processing = false
                        pastes.fetchAll()
                        return
                    }
                    if (paste_private == "2")
                    {
                        messagebox.showMessage("Opening private paste in browser")
                        openingBrowser = true
                        Qt.openUrlExternally("http://pastebin.com/" + paste_key)
                        return
                    }

                    processing = true

                    if (paste_size > 50000)
                        messagebox.showMessage("Opening large paste...")

                    currentPasteTitle = paste_title.length > 0 ? paste_title : "Untitled"
                    currentPasteSize = paste_size
                    currentPasteFormat = paste_format_long
                    currentPasteDate = Qt.formatDateTime(new Date(paste_date * 1000))
                    currentPasteExpire = paste_expire_date == 0 ? "Never" : Qt.formatDateTime(new Date(paste_expire_date * 1000))
                    currentPastePrivacy = paste_private

                    pastes.fetchRaw(paste_key)
                }

                Row
                {
                    x: Theme.paddingLarge
                    spacing: page.width - col.width - privImg.width - 2*Theme.paddingLarge

                    Column
                    {
                        id: col
                        Label
                        {
                            text: paste_title.length > 0 ? paste_title : "Untitled"
                            color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                        }
                        Row
                        {
                            spacing: Theme.paddingMedium
                            Label
                            {
                                text:
                                {
                                    return Qt.formatDateTime(new Date(paste_date * 1000))
                                }
                                font.pixelSize: Theme.fontSizeExtraSmall
                                color: listItem.highlighted ? Theme.highlightColor : Theme.secondaryColor
                            }
                            Label
                            {
                                text:
                                {
                                    if (paste_expire_date == 0)
                                        return ""
                                    var secsToExpire = (paste_expire_date - new Date()/1000)
                                    if (secsToExpire < 60)
                                        return "Expires in " + Math.floor(secsToExpire) + " sec"
                                    if (secsToExpire < 3600)
                                        return "Expires in " + Math.floor(secsToExpire/60) + " min"
                                    if (secsToExpire < 86400)
                                        return "Expires in " + Math.floor(secsToExpire/3600) + " h"
                                    return ""
                                }
                                font.pixelSize: Theme.fontSizeExtraSmall
                                color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                            }
                        }
                    }
                    Image
                    {
                        id: privImg
                        scale: 0.75
                        source:
                        {
                            if (paste_private == 0)
                                return "image://theme/icon-m-region"
                            if (paste_private == 1)
                                return "image://theme/icon-m-remote-security"
                            if (paste_private == 2)
                                return "image://theme/icon-m-device-lock"
                        }
                    }
                }
            }
        }
    }
}


