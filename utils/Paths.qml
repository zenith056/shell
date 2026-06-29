// Filesystem paths singleton.
// Provides standard directories for config, cache, and app data.
pragma Singleton
import QtQuick

Singleton {
    id: root

    // Base config directory (e.g., ~/.config)
    readonly property string home: StandardPaths.writableLocation(StandardPaths.ConfigLocation)
    // Quickshell config path (e.g., ~/.config/quickshell)
    readonly property string config: home + "/quickshell"
    // System cache directory
    readonly property string cache: StandardPaths.writableLocation(StandardPaths.CacheLocation)
    // Application data directory
    readonly property string data: StandardPaths.writableLocation(StandardPaths.AppDataLocation)
}
