import QtQuick
import "../../config" as Config

Text {
    id: workspaces

    property int current: 1
    property int total: 5

    text: {
        var result = ""
        for (var i = 1; i <= total; i++) {
            if (i === current) result += "● "
            else result += "○ "
        }
        return result
    }
    color: Config.BarConfig.textColor
    font.pixelSize: 14
    verticalAlignment: Text.AlignVCenter
}
