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
        text: Bluetooth.enabled ? Icons.bluetooth : Icons.bluetoothOff
        color: Bluetooth.connectedDevice ? Color.success : BarConfig.textColor
        font.family: Style.font.family
        font.pixelSize: Style.font.indicator
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