// System tray indicator for the status bar.
// Displays tray item icons with click-to-activate and right-click menu support.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import "../../Commons"

RowLayout {
    id: trayRoot

    spacing: 4

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: trayItem

            required property var modelData
            property var trayObj: modelData

            implicitWidth: 20
            implicitHeight: BarConfig.height

            Image {
                id: trayIcon
                anchors.centerIn: parent
                width: 16
                height: 16
                source: trayItem.trayObj ? trayItem.trayObj.icon : ""
                sourceSize: Qt.size(16, 16)
                smooth: false
                asynchronous: true
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                hoverEnabled: true

                onClicked: function(mouse) {
                    if (!trayItem.trayObj) return
                    if (mouse.button === Qt.LeftButton) {
                        trayItem.trayObj.activate()
                    } else if (mouse.button === Qt.RightButton) {
                        if (trayItem.trayObj.hasMenu) {
                            menuAnchor.anchor.window = Window.window
                            menuAnchor.anchor.rect = Qt.rect(
                                trayItem.mapToItem(Window.window.contentItem, trayItem.width, 0).x,
                                BarConfig.height,
                                0, 0
                            )
                            menuAnchor.menu = trayItem.trayObj.menu
                            menuAnchor.open()
                        }
                    }
                }

                onWheel: function(wheel) {
                    if (!trayItem.trayObj) return
                    var delta = wheel.angleDelta.y > 0 ? 1 : -1
                    trayItem.trayObj.scroll(delta, false)
                }
            }
        }
    }

    QsMenuAnchor {
        id: menuAnchor
    }
}
