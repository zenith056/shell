// App list delegate component for the launcher.
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import "../../../Commons"
import "../../../utils"

Rectangle {
    id: root

    property bool isSelected: false
    property var appData: null

    width: ListView.view.width
    height: 40
    color: "transparent"
    radius: 6

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 12

        IconImage {
            implicitWidth: 24
            implicitHeight: 24
            source: appData && appData.icon ? "image://icon/" + appData.icon : ""
            visible: appData && appData.icon !== ""
        }

        Rectangle {
            width: 24
            height: 24
            radius: 4
            color: Color.divider
            visible: !appData || !appData.icon

            Text {
                anchors.centerIn: parent
                text: appData ? appData.name.charAt(0).toUpperCase() : ""
                color: Color.text
                font.family: Style.font.family
                font.pixelSize: Style.font.body
                font.bold: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: appData ? appData.name : ""
                color: Color.text
                font.family: Style.font.family
                font.pixelSize: Style.font.body
                font.bold: root.isSelected
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: appData ? (appData.comment || appData.execString || "") : ""
                color: Color.textMuted
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                elide: Text.ElideRight
                Layout.fillWidth: true
                visible: text !== ""
            }
        }
    }
}
