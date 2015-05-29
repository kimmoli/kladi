import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: page

    Component.onCompleted:
    {
        ti.text = pastes.getSetting("userkey", "");
    }

    SilicaFlickable
    {
        anchors.fill: parent

        contentHeight: column.height

        Column
        {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader
            {
                title: "Settings"
            }
            TextField
            {
                id: ti
                width: parent.width
                focus: true
                placeholderText: qsTr("Enter user key")
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked:
                {
                    pastes.setSetting("userkey", ti.text)
                }
            }
        }
    }
}
