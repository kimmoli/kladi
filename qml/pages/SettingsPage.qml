import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: page

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
                id: uname
                width: parent.width
                focus: true
                label: "Username"
                placeholderText: qsTr("Enter username")
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked:
                {
                    upass.focus = true
                }
            }
            TextField
            {
                id: upass
                width: parent.width
                focus: true
                label: "Password"
                placeholderText: qsTr("Enter password")
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked:
                {
                    uname.focus = true
                }
            }

            Button
            {
                text: "generate"
                enabled: upass.text.length > 0 && uname.text.length > 0
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked:
                {
                    pastes.requestUserKey(uname.text, upass.text)
                    pageStack.navigateBack()
                }
            }

            SectionHeader
            {
                text: "Current user key"
            }

            Label
            {
                text: pastes.getSetting("userkey", "")
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
