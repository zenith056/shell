// Entry point for the Quickshell Wayland shell.
// Instantiates global config and the status bar.
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import QtQuick
import "config"
import "services"
import "modules/bar"

Scope {
    id: root

    Config { }   // Loads and watches shell.json for runtime config

    Bar { }      // Renders the top status bar
}
