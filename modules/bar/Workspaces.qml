// Workspace indicator widget for the status bar.
// Renders workspace dots: filled (●) for active, hollow (○) for inactive.
// FIXME: Hardcoded to 5 workspaces — needs integration with window manager.
import QtQuick
import "../../config"

Text {
    id: workspaces

    property int current: 1   // Active workspace index (1-based)
    property int total: 5     // Total number of workspaces

    // Build dot string: filled circle for current, hollow for others
    text: {
        var result = ""
        for (var i = 1; i <= total; i++) {
            if (i === current) result += "● "
            else result += "○ "
        }
        return result
    }
    color: BarConfig.textColor
    font.family: BarConfig.fontFamily
    font.pixelSize: BarConfig.fontSize
    verticalAlignment: Text.AlignVCenter
}
