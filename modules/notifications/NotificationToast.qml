// Compact notification toast for desktop notifications.
// Shows one notification at a time centered at the bottom of the screen.
// Dynamic height based on content: summary, body text, and image preview on the right.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../Commons"
import "../../services"
import "../../utils"
import "../../Ui"

Item {
    id: notificationRoot

    property PanelWindow barWindow: null
    property bool showing: false
    property var currentNotification: null

    // Resolve image source from notification: check image, appIcon, and hints
    readonly property string imageSource: {
        if (!currentNotification) return "";
        try {
            var img = currentNotification.image;
            if (img && typeof img === "string" &&
                (img.indexOf("/") === 0 || img.indexOf("file://") === 0 ||
                 img.indexOf("http://") === 0 || img.indexOf("https://") === 0)) {
                return img;
            }
            var icon = currentNotification.appIcon;
            if (icon && typeof icon === "string" &&
                (icon.indexOf("/") === 0 || icon.indexOf("file://") === 0)) {
                return icon;
            }
            var hints = currentNotification.hints;
            if (hints && typeof hints === "object") {
                var candidates = [
                    hints["image-path"],
                    hints["image_path"],
                    hints["image"],
                    hints["app_icon"],
                    hints["app-icon"]
                ];
                for (var i = 0; i < candidates.length; i++) {
                    var path = candidates[i];
                    if (path && typeof path === "string" &&
                        (path.indexOf("/") === 0 || path.indexOf("file://") === 0 ||
                         path.indexOf("http://") === 0 || path.indexOf("https://") === 0)) {
                        return path;
                    }
                }
            }
        } catch(e) {
            // Silently ignore errors resolving image
        }
        return "";
    }

    readonly property bool hasImage: imageSource.length > 0

    readonly property bool hasBody: {
        if (!currentNotification) return false;
        var b = currentNotification.body;
        return b && b.length > 0;
    }

    Timer {
        id: dismissTimer
        interval: 4000
        onTriggered: notificationRoot.showing = false
    }

    Connections {
        target: Notifications.trackedNotifications
        ignoreUnknownSignals: true
        function onValuesChanged() {
            var list = Notifications.trackedNotifications.values
            if (list.length > 0) {
                var latest = list[list.length - 1]
                if (latest) {
                    notificationRoot.currentNotification = latest
                    dismissTimer.restart()
                    notificationRoot.showing = true
                }
            }
        }
    }

    onShowingChanged: {
        if (showing) {
            if (barWindow) {
                toastPopup.anchor.window = barWindow
                toastPopup.anchor.rect = Qt.rect(
                    barWindow.width / 2 - toastPopup.implicitWidth / 2,
                    (barWindow.screen ? barWindow.screen.height : 1080) - toastPopup.implicitHeight - 40,
                    toastPopup.implicitWidth,
                    toastPopup.implicitHeight
                )
            }
            toastPopup.visible = true
            enterAnim.start()
        } else {
            exitAnim.start()
        }
    }

    SequentialAnimation {
        id: enterAnim
        ParallelAnimation {
            Anim { target: toastCard; property: "opacity"; from: 0; to: 1; type: Anim.DefaultSpatial }
            Anim { target: toastTranslate; property: "y"; from: 30; to: 0; type: Anim.DefaultSpatial }
            Anim { target: toastCard; property: "scale"; from: 0.8; to: 1; type: Anim.DefaultSpatial }
        }
    }

    SequentialAnimation {
        id: exitAnim
        ParallelAnimation {
            Anim { target: toastCard; property: "opacity"; from: 1; to: 0; type: Anim.DefaultSpatial }
            Anim { target: toastTranslate; property: "y"; from: 0; to: 30; type: Anim.DefaultSpatial }
            Anim { target: toastCard; property: "scale"; from: 1; to: 0.8; type: Anim.DefaultSpatial }
        }
        ScriptAction { script: toastPopup.visible = false }
    }

    PopupWindow {
        id: toastPopup
        visible: false
        color: "transparent"
        implicitWidth: notificationRoot.hasImage ? 380 : 300
        implicitHeight: contentColumn.implicitHeight + 32
        grabFocus: false

        Rectangle {
            id: toastCard
            anchors.fill: parent
            color: Color.background
            radius: 12
            opacity: 0
            scale: 0.8
            clip: true

            transform: Translate {
                id: toastTranslate
                y: 30
            }

            RowLayout {
                id: contentRow
                anchors.fill: parent
                anchors.margins: 12
                spacing: Style.spacing.md

                // Left side: text content
                ColumnLayout {
                    id: contentColumn
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Style.spacing.sm

                    // Header Row: Icon + App Name
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.spacing.sm

                        Text {
                            text: Icons.bell
                            color: Color.accent
                            font.family: Style.font.family
                            font.pixelSize: Style.font.heading
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            text: notificationRoot.currentNotification ? notificationRoot.currentNotification.appName : ""
                            color: Color.textMuted
                            font.family: Style.font.family
                            font.pixelSize: Style.font.body
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    // Summary (Title)
                    Text {
                        text: notificationRoot.currentNotification ? notificationRoot.currentNotification.summary : ""
                        color: Color.text
                        font.family: Style.font.family
                        font.pixelSize: Style.font.subtitle
                        font.bold: true
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }

                    // Body text (if present)
                    Text {
                        visible: notificationRoot.hasBody
                        text: notificationRoot.currentNotification ? notificationRoot.currentNotification.body : ""
                        color: Color.textMuted
                        font.family: Style.font.family
                        font.pixelSize: Style.font.body
                        wrapMode: Text.Wrap
                        textFormat: Text.RichText
                        Layout.fillWidth: true
                    }
                }

                // Right side: image preview (if present)
                Rectangle {
                    visible: notificationRoot.hasImage
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 80
                    Layout.maximumHeight: 80
                    Layout.alignment: Qt.AlignVCenter
                    radius: 8
                    color: Color.background
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: notificationRoot.imageSource
                        fillMode: Image.PreserveAspectCrop
                    }
                }
            }
        }
    }
}
