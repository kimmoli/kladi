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
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"),
                                          { "version": Qt.application.version,
                                              "year": "2014",
                                              "name": "Pastebin application",
                                              "imagelocation": "/usr/share/icons/hicolor/86x86/apps/harbour-kladi.png"} )
            }
            MenuItem
            {
                text: "Login"
                onClicked: pageStack.push(Qt.resolvedUrl("LoginPage.qml"))
            }
            MenuItem
            {
                text: "New paste from clipboard"
                onClicked:
                {
                    processing = true
                    pastes.newPaste("Pasted from Jolla", Clipboard.text, "text", "1M", "1")
                }
            }
            MenuItem
            {
                text: "New paste..."
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

        Label
        {
            id: noData
            anchors.centerIn: parent
            text: "No pastes, or not logged in"
            visible: dataReady && myPastes.count == 0
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
                        onClicked: Qt.openUrlExternally("http://pastebin.com/" + paste_key)
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
                    currentPasteTitle = paste_title.length > 0 ? paste_title : "Untitled"
                    currentPasteSize = paste_size
                    currentPasteFormat = paste_format_long
                    currentPasteDate = Qt.formatDateTime(new Date(paste_date * 1000))
                    currentPasteExpire = paste_expire_date == 0 ? "Never" : Qt.formatDateTime(new Date(paste_expire_date * 1000))
                    currentPastePrivacy = paste_private

                    processing = true
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
                        Label
                        {
                            text:
                            {
                                return Qt.formatDateTime(new Date(paste_date * 1000))
                            }
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: listItem.highlighted ? Theme.highlightColor : Theme.secondaryColor
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


