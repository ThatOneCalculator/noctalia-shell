import QtQuick
import Quickshell
import Quickshell.Widgets
import QtQuick.Effects
import qs.Commons
import qs.Widgets
import qs.Services

NIconButton {
  id: root

  property ShellScreen screen
  property real scaling: 1.0

  // Widget properties passed from Bar.qml for per-instance settings
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  property var widgetMetadata: BarWidgetRegistry.widgetMetadata[widgetId]
  property var widgetSettings: {
    if (section && sectionWidgetIndex >= 0) {
      var widgets = Settings.data.bar.widgets[section]
      if (widgets && sectionWidgetIndex < widgets.length) {
        return widgets[sectionWidgetIndex]
      }
    }
    return {}
  }

  readonly property bool useDistroLogo: (widgetSettings.useDistroLogo !== undefined) ? widgetSettings.useDistroLogo : widgetMetadata.useDistroLogo

  icon: useDistroLogo ? "" : "" // "noctalia"
  nerd: !useDistroLogo
  tooltipText: "Open side panel."
  sizeRatio: 0.8

  colorBg: Color.mSurfaceVariant
  colorFg: "#31748f"
  colorBorder: Color.transparent
  colorBorderHover: Color.transparent

  onClicked: PanelService.getPanel("sidePanel")?.toggle(this)
  onRightClicked: PanelService.getPanel("settingsPanel")?.toggle()

  IconImage {
    id: logo
    anchors.centerIn: parent
    width: root.width * 0.6
    height: width
    source: useDistroLogo ? DistroLogoService.osLogo : ""
    visible: useDistroLogo && source !== ""
    smooth: true
  }

  MultiEffect {
    anchors.fill: logo
    source: logo
    //visible: logo.visible
    colorization: 1
    brightness: 1
    saturation: 1
    colorizationColor: root.hovering ? Color.mSurfaceVariant : Color.mOnSurface
  }
}
