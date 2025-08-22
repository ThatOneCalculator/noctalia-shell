import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets

NIconButton {
  id: powerToggle
  icon: "power_settings_new"
  tooltipText: "Power Settings"
  sizeMultiplier: 0.8

  colorBg: Color.mSurfaceVariant
  colorFg: "#eb6f92"
  colorBorder: Color.transparent
  colorBorderHover: Color.transparent

  anchors.verticalCenter: parent.verticalCenter
  onClicked: {
      openWleave.running = true
  }

  Process {
    id: openWleave
    running: false
    command: ["wleave"]
  }
}