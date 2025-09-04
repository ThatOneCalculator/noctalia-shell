import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services
import qs.Widgets

NIconButton {
    id: root

    property ShellScreen screen
    property real scaling: ScalingService.scale(screen)

    icon: "power_settings_new"
    tooltipText: "Power Settings"
    colorBg: Color.mSurfaceVariant
    colorFg: "#eb6f92"
    colorBorder: Color.transparent
    colorBorderHover: Color.transparent
    onClicked: Quickshell.execDetached(["wleave"])
}