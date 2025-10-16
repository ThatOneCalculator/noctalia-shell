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

  baseSize: Style.capsuleHeight
  applyUiScale: false
  density: Settings.data.bar.density
  visible: PowerProfileService.available
  icon: PowerProfileService.getIcon()
  tooltipText: I18n.tr("tooltips.power-profile", {
                         "profile": PowerProfileService.getName()
                       })
  tooltipDirection: BarService.getTooltipDirection()
  colorBg: (Settings.data.bar.showCapsule ? Color.mSurfaceVariant : Color.transparent)
  colorFg: PowerProfileService.getColor()
  colorBorder: Color.transparent
  colorBorderHover: Color.transparent
  onClicked: PowerProfileService.cycleProfile()
}
