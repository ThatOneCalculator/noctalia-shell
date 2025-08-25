import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services
import qs.Widgets

NIconButton {
    id: root

    property ShellScreen screen
    property real scaling: ScalingService.scale(screen)

    Process {
        id: openWleave
        running: false
        command: ["wleave"]
    }

    sizeMultiplier: 0.8

    icon: "power_settings_new"
    tooltipText: "Power Settings"
    colorBg: Color.mSurfaceVariant
    colorFg: "#eb6f92"
    colorBorder: Color.transparent
    colorBorderHover: Color.transparent
    onClicked: openWleave.running = true
}
