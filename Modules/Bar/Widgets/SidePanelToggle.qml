import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services

NIconButton {
  id: root

  property ShellScreen screen
  property real scaling: ScalingService.scale(screen)

  icon: ""
  nerd: true
  
  tooltipText: "Open Side Panel"
  sizeMultiplier: 0.8

  colorBg: Color.mSurfaceVariant
  colorFg: Color.mTertiary
  colorBorder: Color.transparent
  colorBorderHover: Color.transparent
  fontPointSize: Style.fontSizeM

  anchors.verticalCenter: parent.verticalCenter
  onClicked: PanelService.getPanel("sidePanel")?.toggle(screen)
}
