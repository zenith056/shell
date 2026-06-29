// Workspace indicator widget for the status bar.
// Shows workspace numbers from niri: white for active, gray for inactive.
import QtQuick
import "../../services"
import "../../Commons"

Row {
    id: workspaces

    property int current: Workspaces.current
    property int total: Workspaces.total

    spacing: 6

    Repeater {
        model: workspaces.total

        Text {
            text: index + 1
            color: index + 1 === workspaces.current ? Color.activeWorkspace : Color.inactiveWorkspace
            font.family: BarConfig.fontFamily
            font.pixelSize: BarConfig.fontSize
            verticalAlignment: Text.AlignVCenter
        }
    }
}
