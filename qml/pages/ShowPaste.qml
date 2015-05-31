import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: showPastePage

    SilicaFlickable
    {
        id: flick
        anchors.fill: parent

        contentHeight: area.height
        VerticalScrollDecorator { flickable: flick }

        PullDownMenu
        {
            MenuItem
            {
                text: "Save to file"
                onClicked:
                {
                    var afnd = pageStack.push(Qt.resolvedUrl("AskFilename.qml"), { filename: currentPasteTitle })
                    afnd.accepted.connect(function()
                    {
                        if (pastes.save(afnd.filename, pastes.raw()))
                            messagebox.showMessage("Saved " + afnd.filename)
                        else
                            messagebox.showError("Failed to save")
                    })
                }
            }
            MenuItem
            {
                text: "Copy to clipboard"
                onClicked: Clipboard.text = area.text
            }
        }

        PageHeader
        {
            id: dh
            title: currentPasteTitle
        }

        TextArea
        {
            id: area
            width: showPastePage.width
            height: showPastePage.height - dh.height

            anchors.top: dh.bottom

            selectionMode: TextEdit.SelectCharacters
            readOnly: true
            background: null

            text: pastes.raw()
        }
    }
}
