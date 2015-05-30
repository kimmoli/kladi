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
                                              "imagelocation": "/usr/share/icons/hicolor/86x86/apps/kladi.png"} )
            }
            MenuItem
            {
                text: "Settings"
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem
            {
                text: "New paste from clipboard"
                onClicked: pastes.newPaste("Pasted from Jolla", Clipboard.text, "text", "1H", "0")
            }
            MenuItem
            {
                text: "New paste..."
                onClicked: pastes.newPaste("testi", "Testidataa-tekstiä", "text", "1H", "0")
            }
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
                        text: "Delete (no remorse, no undo)"
                        onClicked:
                        {
                            dataReady = false
                            pastes.deletePaste(paste_key)
                        }
                    }
                }

                onClicked:
                {
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
                        visible: paste_private == 2
                        scale: 0.75
                        source: "image://theme/icon-m-device-lock"
                    }
                }
            }
        }
    }
}


