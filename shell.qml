import Quickshell
import QtQuick
import "config" as Config
import "modules/bar" as Bar
import "services" as Services

Scope {
    id: root

    Services.Time { }
    Services.Battery { }
    Services.Network { }
    Services.Audio { }

    Config.Config { }

    Bar.Bar { }
}
