import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.Commons
import qs.Services
import qs.Widgets

NIconButton {
  id: root

  property ShellScreen screen
  property real scaling: 1.0
  readonly property bool hasPP: PowerProfileService.available

  sizeRatio: 0.8
  visible: hasPP

  function profileIcon() {
    if (!hasPP)
      return "balanced"
    if (PowerProfileService.profile === PowerProfile.Performance)
      return "performance"
    if (PowerProfileService.profile === PowerProfile.Balanced)
      return "balanced"
    if (PowerProfileService.profile === PowerProfile.PowerSaver)
      return "powersaver"
  }

  function profileName() {
    if (!hasPP)
      return "Unknown"
    if (PowerProfileService.profile === PowerProfile.Performance)
      return "Performance"
    if (PowerProfileService.profile === PowerProfile.Balanced)
      return "Balanced"
    if (PowerProfileService.profile === PowerProfile.PowerSaver)
      return "Power Saver"
  }

  function changeProfile() {
    if (!hasPP)
      return
    PowerProfileService.cycleProfile()
  }

  function profileColor() {
    if (!hasPP)
      return "#e0def4"
    if (PowerProfileService.profile === PowerProfile.Performance)
        return "#ebbcba"
    else if (PowerProfileService.profile === PowerProfile.Balanced)
        return "#c4a7e7"
    else if (PowerProfileService.profile === PowerProfile.PowerSaver)
        return "#9ccfd8"
  }

  icon: root.profileIcon()
  tooltipText: root.profileName()
  colorBg: Color.mSurfaceVariant
  colorFg: root.profileColor()
  colorBorder: Color.transparent
  colorBorderHover: Color.transparent
  onClicked: root.changeProfile()
}
