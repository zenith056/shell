// Bluetooth indicator widget for the status bar.
// Shows a Bluetooth icon and opens popup on click.
import QtQuick
import "../../services"
import "../../Commons"
import "../../utils"
import "bluetooth"

Item {
    id: bluetooth

    width: iconText.implicitWidth
    height: iconText.implicitHeight

    Text {
        id: iconText
        text: {
            if (!Bluetooth.enabled) return Icons.bluetoothOff;
            if (Bluetooth.connectedDevice) return Icons.headphones;
            return Icons.bluetooth;
        }
        color: Bluetooth.connectedDevice ? Color.success : BarConfig.textColor
        font.family: Style.font.family
        font.pixelSize: Bluetooth.connectedDevice ? Style.font.indicator + 2 : Style.font.indicator
        verticalAlignment: Text.AlignVCenter
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (bluetoothPopup.isOpen) {
                bluetoothPopup.hide();
            } else {
                bluetoothPopup.show(bar, iconText);
            }
        }
    }

    BluetoothPopup {
        id: bluetoothPopup
    }
}