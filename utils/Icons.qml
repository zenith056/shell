pragma Singleton
import QtQuick

Singleton {
    id: root

    function resolve(iconName: string): string {
        // Resolve icon name to themed icon path
        // Uses system icon theme
        return iconName
    }
}
