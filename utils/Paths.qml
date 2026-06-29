pragma Singleton
import QtQuick

Singleton {
    id: root

    readonly property string home: StandardPaths.writableLocation(StandardPaths.ConfigLocation)
    readonly property string config: home + "/quickshell"
    readonly property string cache: StandardPaths.writableLocation(StandardPaths.CacheLocation)
    readonly property string data: StandardPaths.writableLocation(StandardPaths.AppDataLocation)
}
