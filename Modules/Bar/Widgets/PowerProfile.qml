import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.Commons
import qs.Services.Power
import qs.Services.UI
import qs.Widgets

NIconButton {
  id: root

  property ShellScreen screen

  baseSize: Style.getCapsuleHeightForScreen(screen?.name)
  applyUiScale: false
  customRadius: Style.radiusL
  visible: PowerProfileService.available
  icon: PowerProfileService.getIcon()
  tooltipText: I18n.tr("tooltips.power-profile", {
                         "profile": PowerProfileService.getName()
                       })
  tooltipDirection: BarService.getTooltipDirection(screen?.name)
  colorBg: Style.capsuleColor
  colorFg: PowerProfileService.getColor()
  colorBorder: "transparent"
  colorBorderHover: "transparent"
  border.color: Style.capsuleBorderColor
  border.width: Style.capsuleBorderWidth
  onClicked: PowerProfileService.cycleProfile()
  onRightClicked: PowerProfileService.cycleProfileReverse()
}
