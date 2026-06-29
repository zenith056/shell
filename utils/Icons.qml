// Icon resolver singleton.
// Maps icon names to themed icon paths (currently a pass-through stub).
pragma Singleton
import QtQuick

Singleton {
    id: root

    // Resolve an icon name to its full themed path
    // TODO: Implement real icon theme resolution using Qt.labs.platform or xdg
    function resolve(iconName: string): string {
        return iconName  // Pass-through: return name as-is for now
    }
}
