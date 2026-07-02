// Network indicator widget for the status bar.
// Shows a connection icon and opens popup on click.
import QtQuick
import "../../services"
import "../../Commons"
import "../../utils"
import "../../Ui"

Item {
    id: network

    implicitWidth: Style.font.indicator + 2
    height: BarConfig.height

    Component.onCompleted: PopupControl.networkIndicator = network

    Text {
        anchors.centerIn: parent
        text: Network.connected ? Icons.signalIcon(Network.signalStrength) : Icons.ethernet
        color: Network.connected ? Color.text : Color.textMuted
        font.family: Style.font.family
        font.pixelSize: Style.font.indicator

        Behavior on color {
            CAnim { animType: Anim.DefaultEffects }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: PopupControl.toggle("network", network)
        onEntered: {
            PopupControl.indicatorHovered = true
            PopupControl.open("network", network)
        }
        onExited: {
            PopupControl.indicatorHovered = false
            PopupControl.checkClose()
        }
    }
}
