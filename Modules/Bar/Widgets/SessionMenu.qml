import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services
import qs.Widgets

NIconButton {
  id: root

  property real scaling: 1.0

  compact: (Settings.data.bar.density === "compact")
  baseSize: Style.capsuleHeight
  icon: "power"
  tooltipText: I18n.tr("tooltips.session-menu")
  tooltipDirection: BarService.getTooltipDirection()
  colorBg: (Settings.data.bar.showCapsule ? Color.mSurfaceVariant : Color.transparent)
  colorFg: Color.mError
  colorBorder: Color.transparent
  colorBorderHover: Color.transparent
  onClicked: PanelService.getPanel("sessionMenuPanel")?.toggle()
}
