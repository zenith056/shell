// Reusable Glassmorphic Card for notifications stack.
import QtQuick
import QtQuick.Layouts
import "../../Commons"
import "../../utils"
import "../../Ui"

Rectangle {
    id: cardRoot

    property var notificationData: null
    property real yOffset: 0
    property real scaleValue: 1.0
    property real opacityValue: 1.0

    signal dismissed()

    width: 380
    implicitHeight: contentRow.implicitHeight + 24
    
    radius: 12
    color: Color.background
    border.color: Color.divider
    border.width: 1
    clip: true

    transform: Translate {
        y: yOffset
        Behavior on y {
            NumberAnimation {
                duration: Style.anim.expressiveDefaultSpatial
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Style.anim.expressiveDefaultSpatialCurve
            }
        }
    }

    scale: scaleValue
    Behavior on scale {
        NumberAnimation {
            duration: Style.anim.expressiveDefaultSpatial
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Style.anim.expressiveDefaultSpatialCurve
        }
    }

    opacity: opacityValue
    Behavior on opacity {
        NumberAnimation {
            duration: Style.anim.expressiveDefaultSpatial
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Style.anim.expressiveDefaultSpatialCurve
        }
    }

    readonly property string imageSource: {
        if (!notificationData) return "";
        try {
            var img = notificationData.image;
            if (img && typeof img === "string" &&
                (img.indexOf("/") === 0 || img.indexOf("file://") === 0 ||
                 img.indexOf("http://") === 0 || img.indexOf("https://") === 0)) {
                return img;
            }
            var icon = notificationData.appIcon;
            if (icon && typeof icon === "string" &&
                (icon.indexOf("/") === 0 || icon.indexOf("file://") === 0)) {
                return icon;
            }
            var hints = notificationData.hints;
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
        } catch(e) {}
        return "";
    }

    readonly property bool hasImage: imageSource.length > 0
    readonly property bool hasBody: notificationData && notificationData.body && notificationData.body.length > 0

    RowLayout {
        id: contentRow
        anchors.fill: parent
        anchors.margins: 12
        spacing: Style.spacing.md

        // Left side: Text and icons
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.spacing.xs

            // Header Row: Icon + App Name + Close button
            RowLayout {
                Layout.fillWidth: true
                spacing: Style.spacing.sm

                Text {
                    text: cardRoot.notificationData && cardRoot.notificationData.isBluetooth ? Icons.bluetooth : Icons.bell
                    color: cardRoot.notificationData && cardRoot.notificationData.isBluetooth ? Color.success : Color.accent
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: cardRoot.notificationData ? cardRoot.notificationData.appName : ""
                    color: Color.textMuted
                    font.family: Style.font.family
                    font.pixelSize: Style.font.bodySmall
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                }

                // Close Button
                Rectangle {
                    width: 20
                    height: 20
                    radius: 10
                    color: closeMouse.containsMouse ? Color.divider : "transparent"
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        anchors.centerIn: parent
                        text: Icons.times
                        color: Color.textMuted
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: cardRoot.dismissed()
                    }
                }
            }

            // Summary (Title)
            Text {
                text: cardRoot.notificationData ? cardRoot.notificationData.summary : ""
                color: Color.text
                font.family: Style.font.family
                font.pixelSize: Style.font.body
                font.bold: true
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            // Body text (if present)
            Text {
                visible: cardRoot.hasBody
                text: cardRoot.notificationData ? cardRoot.notificationData.body : ""
                color: Color.textMuted
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                Layout.fillWidth: true
            }
        }

        // Right side: Image preview
        Rectangle {
            visible: cardRoot.hasImage
            Layout.preferredWidth: 64
            Layout.preferredHeight: 64
            Layout.alignment: Qt.AlignVCenter
            radius: 6
            color: Color.surface
            clip: true

            Image {
                anchors.fill: parent
                source: cardRoot.imageSource
                fillMode: Image.PreserveAspectCrop
            }
        }
    }
}
