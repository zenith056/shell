// Network indicator widget for the status bar.
// Shows a connection icon and opens popup on click.
import QtQuick
import "../../services"
import "../../Commons"
import "../../utils"
import "network"

Item {
    id: network

    implicitWidth: Style.font.indicator + 2
    height: BarConfig.height

    Text {
        id: iconText
        anchors.centerIn: parent
        text: Network.connected ? Icons.signalIcon(Network.signalStrength) : Icons.ethernet
        color: BarConfig.textColor
        font.family: Style.font.family
        font.pixelSize: Style.font.indicator
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (networkPopup.isOpen) {
                networkPopup.hide();
            } else {
                networkPopup.show(bar, iconText);
            }
        }
    }

    NetworkPopup {
        id: networkPopup
        onRequestPassword: function(ssid) {
            passwordDialog.showDialog(bar, iconText, ssid);
        }
    }

    PasswordDialog {
        id: passwordDialog
    }
}
