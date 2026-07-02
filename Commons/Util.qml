// Pure utility functions singleton.
// No state, no side effects — just helpers.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    function isPlainObject(value) {
        return value !== null && typeof value === "object" && !Array.isArray(value)
    }

    function get(obj, path, fallback) {
        var parts = path.split(".")
        var current = obj
        for (var i = 0; i < parts.length; i++) {
            if (!isPlainObject(current)) {
                return fallback
            }
            current = current[parts[i]]
            if (current === undefined) return fallback
        }
        return current !== undefined ? current : fallback
    }
}
