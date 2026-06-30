// Power profile selector component.
// Shows three profile buttons with icons.
import QtQuick
import QtQuick.Layouts
import "../../../Commons"
import "../../../services"
import "../../../utils"

RowLayout {
    id: profileSelector

    spacing: 12

    Repeater {
        model: [
            { name: "power-saver", label: "Power Saver", icon: Icons.powerSaver },
            { name: "balanced", label: "Balanced", icon: Icons.balanced },
            { name: "performance", label: "Performance", icon: Icons.performance }
        ]

        Rectangle {
            property string profileName: modelData.name
            property bool isActive: PowerProfile.activeProfile === profileName

            Layout.fillWidth: true
            Layout.preferredHeight: 40
            radius: 8
            color: isActive ? Color.text : (btnArea.containsMouse ? Color.divider : Color.surface)

            RowLayout {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: modelData.icon
                    color: isActive ? Color.background : Color.text
                    font.family: Style.font.family
                    font.pixelSize: Style.font.title
                }

                Text {
                    text: modelData.label
                    color: isActive ? Color.background : Color.text
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                }
            }

            MouseArea {
                id: btnArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: PowerProfile.setProfile(profileName)
            }
        }
    }
}