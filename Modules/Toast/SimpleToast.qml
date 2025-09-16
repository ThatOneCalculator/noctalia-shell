import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Rectangle {
  id: root

  property string message: ""
  property string description: ""
  property string type: "notice"
  property int duration: 3000
  readonly property real initialScale: 0.7

  signal hidden

  width: Math.min(500 * scaling, parent.width * 0.8)
  height: Math.max(60 * scaling, contentLayout.implicitHeight + Style.marginL * 2 * scaling)
  radius: Style.radiusL * scaling
  visible: false
  opacity: 0
  scale: initialScale

  // Clean surface background like NToast
  color: Color.mSurface

  // Colored border based on type
  border.color: {
    switch (type) {
    case "warning":
      return Color.mPrimary
    case "error":
      return Color.mError
    default:
      return Color.mOutline
    }
  }
  border.width: Math.max(2, Style.borderM * scaling)

  Behavior on opacity {
    NumberAnimation {
      duration: Style.animationNormal
      easing.type: Easing.OutCubic
    }
  }

  Behavior on scale {
    NumberAnimation {
      duration: Style.animationNormal
      easing.type: Easing.OutCubic
    }
  }

  Timer {
    id: hideTimer
    interval: root.duration
    onTriggered: root.hide()
  }

  Timer {
    id: hideAnimation
    interval: Style.animationFast
    onTriggered: {
      root.visible = false
      root.hidden()
    }
  }

  RowLayout {
    id: contentLayout
    anchors.fill: parent
    anchors.margins: Style.marginL * scaling
    spacing: Style.marginL * scaling

    // Icon
    NIcon {
      id: icon
      icon: {
        switch (type) {
        case "warning":
          return "toast-warning"
        case "error":
          return "toast-error"
        default:
          return "toast-notice"
        }
      }
      color: {
        switch (type) {
        case "warning":
          return Color.mPrimary
        case "error":
          return Color.mError
        default:
          return Color.mOnSurface
        }
      }
      font.pointSize: Style.fontSizeXXL * 1.5 * scaling
      Layout.alignment: Qt.AlignVCenter
    }

    // Label and description
    ColumnLayout {
      spacing: Style.marginXXS * scaling
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter

      NText {
        Layout.fillWidth: true
        text: root.message
        color: Color.mOnSurface
        font.pointSize: Style.fontSizeL * scaling
        font.weight: Style.fontWeightBold
        wrapMode: Text.WordWrap
        visible: text.length > 0
      }

      NText {
        Layout.fillWidth: true
        text: root.description
        color: Color.mOnSurface
        font.pointSize: Style.fontSizeM * scaling
        wrapMode: Text.WordWrap
        visible: text.length > 0
      }
    }

    // Close button
    NIconButton {
      id: closeButton
      icon: "close"

      colorBg: Color.mSurfaceVariant
      colorFg: Color.mOnSurface
      colorBorder: Color.transparent
      colorBorderHover: Color.mOutline

      baseSize: Style.baseWidgetSize * 0.8
      Layout.alignment: Qt.AlignTop

      onClicked: root.hide()
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton
    onClicked: root.hide()
    cursorShape: Qt.PointingHandCursor
  }

  function show(msg, desc, msgType, msgDuration) {
    message = msg
    description = desc || ""
    type = msgType || "notice"
    duration = msgDuration || 3000

    visible = true
    opacity = 1
    scale = 1.0

    hideTimer.restart()
  }

  function hide() {
    hideTimer.stop()
    opacity = 0
    scale = initialScale
    hideAnimation.start()
  }

  function hideImmediately() {
    opacity = 0
    scale = initialScale
    root.visible = false
    root.hidden()
  }
}
