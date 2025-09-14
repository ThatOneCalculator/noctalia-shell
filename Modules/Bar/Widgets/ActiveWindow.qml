import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Commons
import qs.Services
import qs.Widgets

Item {
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

  readonly property bool showIcon: (widgetSettings.showIcon !== undefined) ? widgetSettings.showIcon : widgetMetadata.showIcon

  // 6% of total width
  readonly property real minWidth: Math.max(1, screen.width * 0.06)
  readonly property real maxWidth: minWidth * 2

  readonly property string barPosition: Settings.data.bar.position
  implicitHeight: (barPosition === "left" || barPosition === "right") ? calculatedVerticalHeight() : Math.round(Style.barHeight * scaling)
  implicitWidth: (barPosition === "left" || barPosition === "right") ? Math.round(Style.baseWidgetSize * 0.8 * scaling) : (horizontalLayout.implicitWidth + Style.marginM * 2 * scaling)

  function getTitle() {
    try {
      return CompositorService.focusedWindowTitle !== "(No active window)" ? CompositorService.focusedWindowTitle : ""
    } catch (e) {
      Logger.warn("ActiveWindow", "Error getting title:", e)
      return ""
    }
  }

  visible: getTitle() !== ""

  function calculatedVerticalHeight() {
    // Use standard widget height like other widgets
    return Math.round(Style.capsuleHeight * scaling)
  }

  function calculatedHorizontalWidth() {
    let total = Style.marginM * 2 * scaling // internal padding

    if (showIcon) {
      total += Style.baseWidgetSize * 0.5 * scaling + 2 * scaling // icon + spacing
    }

    // Calculate actual text width more accurately
    const title = getTitle()
    if (title !== "") {
      // Estimate text width: average character width * number of characters
      const avgCharWidth = Style.fontSizeS * scaling * 0.6 // rough estimate
      const titleWidth = Math.min(title.length * avgCharWidth, 80 * scaling)
      total += titleWidth
    }

    // Row layout handles spacing between widgets
    return Math.max(total, Style.capsuleHeight * scaling) // Minimum width
  }

  function getAppIcon() {
    try {
      // Try CompositorService first
      const focusedWindow = CompositorService.getFocusedWindow()
      if (focusedWindow && focusedWindow.appId) {
        try {
          const idValue = focusedWindow.appId
          const normalizedId = (typeof idValue === 'string') ? idValue : String(idValue)
          const iconResult = AppIcons.iconForAppId(normalizedId.toLowerCase())
          if (iconResult && iconResult !== "") {
            return iconResult
          }
        } catch (iconError) {
          Logger.warn("ActiveWindow", "Error getting icon from CompositorService:", iconError)
        }
      }

      // Fallback to ToplevelManager
      if (ToplevelManager && ToplevelManager.activeToplevel) {
        try {
          const activeToplevel = ToplevelManager.activeToplevel
          if (activeToplevel.appId) {
            const idValue2 = activeToplevel.appId
            const normalizedId2 = (typeof idValue2 === 'string') ? idValue2 : String(idValue2)
            const iconResult2 = AppIcons.iconForAppId(normalizedId2.toLowerCase())
            if (iconResult2 && iconResult2 !== "") {
              return iconResult2
            }
          }
        } catch (fallbackError) {
          Logger.warn("ActiveWindow", "Error getting icon from ToplevelManager:", fallbackError)
        }
      }

      return ""
    } catch (e) {
      Logger.warn("ActiveWindow", "Error in getAppIcon:", e)
      return ""
    }
  }

  // A hidden text element to safely measure the full title width
  NText {
    id: fullTitleMetrics
    visible: false
    text: getTitle()
    font.pointSize: Style.fontSizeS * scaling
    font.weight: Style.fontWeightMedium
  }

  Rectangle {
    id: windowTitleRect
    visible: root.visible
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    width: (barPosition === "left" || barPosition === "right") ? Math.round(Style.capsuleHeight * scaling) : (horizontalLayout.implicitWidth + Style.marginM * 2 * scaling)
    height: (barPosition === "left" || barPosition === "right") ? Math.round(Style.capsuleHeight * scaling) : Math.round(Style.capsuleHeight * scaling)
    radius: Math.round(Style.radiusM * scaling)
    color: Color.mSurfaceVariant

    Item {
      id: mainContainer
      anchors.fill: parent
      anchors.leftMargin: (barPosition === "left" || barPosition === "right") ? 0 : Style.marginXS * scaling
      anchors.rightMargin: (barPosition === "left" || barPosition === "right") ? 0 : Style.marginXS * scaling
      clip: true

      // Horizontal layout for top/bottom bars
      RowLayout {
        id: horizontalLayout
        anchors.centerIn: parent
        spacing: 2 * scaling
        visible: barPosition === "top" || barPosition === "bottom"

        // Window icon
        Item {
          // Layout.preferredWidth: Math.round(18 * scaling)
          // Layout.preferredHeight: Math.round(18 * scaling)
          Layout.preferredWidth: Style.baseWidgetSize * 0.5 * scaling
          Layout.preferredHeight: Style.baseWidgetSize * 0.5 * scaling
          Layout.alignment: Qt.AlignVCenter
          visible: getTitle() !== "" && showIcon

          IconImage {
            id: windowIcon
            anchors.fill: parent
            source: getAppIcon()
            asynchronous: true
            smooth: true
            visible: source !== ""

            // Handle loading errors gracefully
            onStatusChanged: {
              if (status === Image.Error) {
                Logger.warn("ActiveWindow", "Failed to load icon:", source)
              }
            }
          }
        }

        NText {
          id: titleText
          Layout.preferredWidth: {
            try {
              if (mouseArea.containsMouse) {
                return Math.round(Math.min(fullTitleMetrics.contentWidth, root.maxWidth * scaling))
              } else {
                return Math.round(Math.min(fullTitleMetrics.contentWidth, 80 * scaling)) // Limited width for horizontal bars
              }
            } catch (e) {
              Logger.warn("ActiveWindow", "Error calculating width:", e)
              return 80 * scaling
            }
          }
          Layout.alignment: Qt.AlignVCenter
          horizontalAlignment: Text.AlignLeft
          text: getTitle()
          font.pointSize: Style.fontSizeS * scaling
          font.weight: Style.fontWeightMedium
          elide: mouseArea.containsMouse ? Text.ElideNone : Text.ElideRight
          verticalAlignment: Text.AlignVCenter
          color: "#c4a7e7"
          clip: true

          Behavior on Layout.preferredWidth {
            NumberAnimation {
              duration: Style.animationSlow
              easing.type: Easing.InOutCubic
            }
          }
        }
      }

      // Vertical layout for left/right bars - icon only
      Item {
        id: verticalLayout
        anchors.centerIn: parent
        width: parent.width - Style.marginXS * scaling * 2
        height: parent.height - Style.marginXS * scaling * 2
        visible: barPosition === "left" || barPosition === "right"

        // Window icon
        Item {
          width: Style.baseWidgetSize * 0.5 * scaling
          height: Style.baseWidgetSize * 0.5 * scaling
          anchors.centerIn: parent
          visible: getTitle() !== "" && showIcon

          IconImage {
            id: windowIconVertical
            anchors.fill: parent
            source: getAppIcon()
            asynchronous: true
            smooth: true
            visible: source !== ""

            // Handle loading errors gracefully
            onStatusChanged: {
              if (status === Image.Error) {
                Logger.warn("ActiveWindow", "Failed to load icon:", source)
              }
            }
          }
        }
      }

      // Mouse area for hover detection
      MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: {
          if (barPosition === "left" || barPosition === "right") {
            tooltip.show()
          }
        }
        onExited: {
          if (barPosition === "left" || barPosition === "right") {
            tooltip.hide()
          }
        }
      }

      // Hover tooltip with full title (only for vertical bars)
      NTooltip {
        id: tooltip
        target: verticalLayout
        text: getTitle()
        positionLeft: barPosition === "right"
        positionRight: barPosition === "left"
        delay: 500
      }
    }
  }

  Connections {
    target: CompositorService
    function onActiveWindowChanged() {
      try {
        windowIcon.source = Qt.binding(getAppIcon)
        windowIconVertical.source = Qt.binding(getAppIcon)
      } catch (e) {
        Logger.warn("ActiveWindow", "Error in onActiveWindowChanged:", e)
      }
    }
    function onWindowListChanged() {
      try {
        windowIcon.source = Qt.binding(getAppIcon)
        windowIconVertical.source = Qt.binding(getAppIcon)
      } catch (e) {
        Logger.warn("ActiveWindow", "Error in onWindowListChanged:", e)
      }
    }
  }
}
