// Compact stacked notification toast system.
// Manages system notifications and Bluetooth status pill events.
// Stacks up to 3 cards behind each other, unrolling upwards when hovered.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../Commons"
import "../../services"
import "../../utils"
import "../../Ui"

Item {
    id: root

    property PanelWindow barWindow: null
    property var activeNotifications: []
    property bool stackHovered: false
    property bool isReady: false

    // Startup guard to ignore historical cached notifications on load/reload
    Timer {
        id: startupTimer
        interval: 1000
        running: true
        onTriggered: root.isReady = true
    }

    Connections {
        target: Notifications.trackedNotifications
        ignoreUnknownSignals: true
        function onValuesChanged() {
            if (!root.isReady) return
            var list = Notifications.trackedNotifications.values
            if (list.length > 0) {
                var latest = list[list.length - 1]
                if (latest) {
                    // Check if we already have this notification in our activeNotifications
                    var exists = false
                    for (var i = 0; i < activeNotifications.length; i++) {
                        if (activeNotifications[i].id === latest.id) {
                            exists = true
                            break
                        }
                    }
                    if (!exists) {
                        var newNotif = {
                            id: latest.id,
                            appName: latest.appName || "Notification",
                            summary: latest.summary || "",
                            body: latest.body || "",
                            image: latest.image || "",
                            appIcon: latest.appIcon || "",
                            hints: latest.hints || {},
                            duration: 6,
                            isBluetooth: false
                        }
                        var arr = activeNotifications.slice()
                        arr.unshift(newNotif)
                        activeNotifications = arr
                    }
                }
            }
        }
    }

    // Connections to handle Bluetooth connection notifications
    Connections {
        target: Bluetooth
        ignoreUnknownSignals: true
        property string lastConnectedAddress: ""
        function onConnectedDeviceChanged() {
            var dev = Bluetooth.connectedDevice
            var addr = dev ? dev.address : ""
            if (addr !== lastConnectedAddress) {
                lastConnectedAddress = addr
                if (dev) {
                    var bat = dev.battery
                    var batteryText = bat >= 0 ? ("Battery: " + bat + "%") : "Connected"
                    var btNotif = {
                        id: "bluetooth_" + addr + "_" + Date.now(),
                        appName: "Bluetooth",
                        summary: dev.name || "Bluetooth Device",
                        body: batteryText,
                        image: "",
                        appIcon: "",
                        hints: {},
                        duration: 6,
                        isBluetooth: true
                    }
                    var arr = activeNotifications.slice()
                    arr.unshift(btNotif)
                    activeNotifications = arr
                }
            }
        }
    }

    // Timer to decrease duration of active notifications and auto-dismiss them
    Timer {
        id: durationTimer
        interval: 1000
        repeat: true
        running: activeNotifications.length > 0 && !root.stackHovered
        onTriggered: {
            var updated = []
            for (var i = 0; i < activeNotifications.length; i++) {
                var notif = activeNotifications[i]
                notif.duration -= 1
                if (notif.duration > 0) {
                    updated.push(notif)
                }
            }
            activeNotifications = updated
        }
    }

    function dismissNotification(index) {
        if (index >= 0 && index < activeNotifications.length) {
            var arr = activeNotifications.slice()
            arr.splice(index, 1)
            activeNotifications = arr
        }
    }

    onActiveNotificationsChanged: {
        if (activeNotifications.length > 0) {
            if (barWindow) {
                toastPopup.anchor.window = barWindow
                toastPopup.anchor.rect = Qt.rect(
                    barWindow.width - 400 - 20,
                    (barWindow.screen ? barWindow.screen.height : 1080) - 500 - 20,
                    400,
                    500
                )
            }
            toastPopup.visible = true
        } else {
            toastPopup.visible = false
        }
    }

    PopupWindow {
        id: toastPopup
        visible: false
        color: "transparent"
        implicitWidth: 400
        implicitHeight: 500
        grabFocus: false

        Item {
            id: container
            anchors.fill: parent

            Item {
                id: deckContainer
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: 380
                height: {
                    if (root.activeNotifications.length === 0) return 0
                    if (!isHovered) {
                        return 160
                    } else {
                        var h = card0.implicitHeight
                        if (root.activeNotifications.length > 1) h += card1.implicitHeight + 8
                        if (root.activeNotifications.length > 2) h += card2.implicitHeight + 8
                        return h + 10
                    }
                }

                readonly property bool isHovered: hoverArea.hovered
                onIsHoveredChanged: root.stackHovered = isHovered

                Behavior on height {
                    NumberAnimation {
                        duration: Style.anim.expressiveDefaultSpatial
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Style.anim.expressiveDefaultSpatialCurve
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#01000000"
                }

                HoverHandler {
                    id: hoverArea
                }

                NotificationCard {
                    id: card0
                    visible: root.activeNotifications.length > 0
                    notificationData: root.activeNotifications.length > 0 ? root.activeNotifications[0] : null
                    anchors.bottom: parent.bottom
                    
                    yOffset: 0
                    scaleValue: 1.0
                    opacityValue: 1.0
                    z: 10

                    onDismissed: root.dismissNotification(0)
                }

                NotificationCard {
                    id: card1
                    visible: root.activeNotifications.length > 1
                    notificationData: root.activeNotifications.length > 1 ? root.activeNotifications[1] : null
                    anchors.bottom: parent.bottom
                    
                    yOffset: deckContainer.isHovered ? -(card0.implicitHeight + 8) : -8
                    scaleValue: deckContainer.isHovered ? 1.0 : 0.96
                    opacityValue: deckContainer.isHovered ? 1.0 : 0.85
                    z: 9

                    onDismissed: root.dismissNotification(1)
                }

                NotificationCard {
                    id: card2
                    visible: root.activeNotifications.length > 2
                    notificationData: root.activeNotifications.length > 2 ? root.activeNotifications[2] : null
                    anchors.bottom: parent.bottom
                    
                    yOffset: deckContainer.isHovered ? -(card0.implicitHeight + card1.implicitHeight + 16) : -16
                    scaleValue: deckContainer.isHovered ? 1.0 : 0.92
                    opacityValue: deckContainer.isHovered ? 1.0 : 0.70
                    z: 8

                    onDismissed: root.dismissNotification(2)
                }
            }
        }
    }
}
