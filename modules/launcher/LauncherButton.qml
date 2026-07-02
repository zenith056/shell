// Launcher button widget for the status bar.
// Shows a launcher icon and opens popup on click.
import QtQuick
import "../../Commons"
import "../../utils"
import "../../Ui"

Item {
    id: launcherButton

    property var barWindow: null

    implicitWidth: Style.font.indicator + 2
    height: BarConfig.height

    Text {
        anchors.centerIn: parent
        text: Icons.launcher
        color: LauncherState.isOpen ? Color.textMuted : BarConfig.textColor
        font.family: Style.font.family
        font.pixelSize: Style.font.indicator

        Behavior on color {
            CAnim { animType: Anim.FastEffects }
        }

        scale: clickAnim.running ? 0.85 : 1.0
        Behavior on scale {
            Anim { type: Anim.FastEffects }
        }
    }

    SequentialAnimation {
        id: clickAnim
        Anim { target: launcherButton; property: "scale"; to: 0.85; type: Anim.FastEffects }
        Anim { target: launcherButton; property: "scale"; to: 1.0; type: Anim.FastEffects }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            clickAnim.restart()
            if (LauncherState.isOpen) {
                LauncherState.hide();
            } else {
                LauncherState.show(launcherButton, launcherButton.barWindow);
            }
        }
        onEntered: {
            LauncherState.indicatorHovered = true
            if (!LauncherState.isOpen) {
                LauncherState.show(launcherButton, launcherButton.barWindow);
            }
        }
        onExited: {
            LauncherState.indicatorHovered = false
            LauncherState.checkClose()
        }
    }
}
