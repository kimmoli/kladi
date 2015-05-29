/*
    kladi, Pastebin application
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: page

    BusyIndicator
    {
        id: isBusy
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: !dataReady
    }

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

                onClicked:
                {
                    console.log("click " + paste_key)
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
                            text: paste_title.length > 0 ? paste_title : paste_key
                            color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                        }
                        Label
                        {
                            text:
                            {
                                return new Date(paste_date * 1000);
                            }
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: listItem.highlighted ? Theme.highlightColor : Theme.secondaryColor
                        }
                    }
                    Image
                    {
                        id: privImg
                        visible: paste_private > 0
                        scale: 0.5
                        source: "image://theme/icon-m-device-lock"
                    }
                }

            }
        }
    }
}


