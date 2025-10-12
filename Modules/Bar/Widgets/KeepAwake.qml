import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services
import qs.Widgets

NIconButton {
  id: root

  property ShellScreen screen
  property real scaling: 1.0

  baseSize: Style.capsuleHeight
  compact: (Settings.data.bar.density === "compact")
  icon: IdleInhibitorService.isInhibited ? "keep-awake-on" : "keep-awake-off"
  tooltipText: IdleInhibitorService.isInhibited ? I18n.tr("tooltips.disable-keep-awake") : I18n.tr("tooltips.enable-keep-awake")
  tooltipDirection: BarService.getTooltipDirection()
  colorBg: (Settings.data.bar.showCapsule ? Color.mSurfaceVariant : Color.transparent)
  colorFg: IdleInhibitorService.isInhibited ? Color.mPrimary : Color.mOnSurface
  colorBorder: Color.transparent
  colorBorderHover: Color.transparent
  onClicked: IdleInhibitorService.manualToggle()
}
