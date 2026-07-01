// Search bar component for the launcher.
import QtQuick
import QtQuick.Layouts
import "../../../Commons"
import "../../../utils"

Rectangle {
    id: root

    property alias input: searchInput
    signal searchChanged(string query)
    signal escapePressed()

    Layout.fillWidth: true
    Layout.preferredHeight: 40
    color: searchInput.activeFocus ? Color.divider : Color.surface
    radius: 8

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        Text {
            text: Icons.search
            color: Color.textMuted
            font.family: Style.font.family
            font.pixelSize: Style.font.body
        }

        TextInput {
            id: searchInput
            Layout.fillWidth: true
            color: Color.text
            font.family: Style.font.family
            font.pixelSize: Style.font.body
            clip: true
            focus: true
            activeFocusOnPress: true

            onTextChanged: root.searchChanged(text)
            Keys.onEscapePressed: root.escapePressed()
        }
    }

    function clear() {
        searchInput.text = "";
    }
}
