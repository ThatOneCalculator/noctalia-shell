import Quickshell
import qs.Commons
import qs.Widgets

NIconButton {
  id: sidePanelToggle
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
  onClicked: sidePanel.toggle(screen)
}
