import QtQuick
import QtQuick.Controls
import qs.Commons
import qs.Services

Item {
  id: root

  property string icon: ""
  property string text: ""
  property string tooltipText: ""
  property real sizeRatio: 0.8
  property bool autoHide: false
  property bool forceOpen: false
  property bool disableOpen: false
  property bool rightOpen: false
  property bool hovered: false
  property real fontSize: Style.fontSizeXS

  // Bar position detection for pill direction
  readonly property string barPosition: Settings.data.bar.position
  readonly property bool isVerticalBar: barPosition === "left" || barPosition === "right"

  // Determine pill direction based on section position
  readonly property bool openRightward: rightOpen
  readonly property bool openLeftward: !rightOpen

  // Effective shown state (true if animated open or forced)
  readonly property bool revealed: forceOpen || showPill

  signal shown
  signal hidden
  signal entered
  signal exited
  signal clicked
  signal rightClicked
  signal middleClicked
  signal wheel(int delta)

  // Internal state
  property bool showPill: false
  property bool shouldAnimateHide: false

  // Sizing logic for horizontal bars
  readonly property int iconSize: Math.round(Style.baseWidgetSize * sizeRatio * scaling)
  readonly property int pillWidth: iconSize
  readonly property int pillPaddingHorizontal: Style.marginS * scaling
  readonly property int pillPaddingVertical: Style.marginS * scaling
  readonly property int pillOverlap: iconSize * 0.5
  readonly property int maxPillWidth: Math.max(1, textItem.implicitWidth + pillPaddingHorizontal * 4)
  readonly property int maxPillHeight: iconSize

  // For horizontal bars: height is just icon size, width includes pill space
  width: revealed ? (openRightward ? (iconSize + maxPillWidth - pillOverlap) : (iconSize + maxPillWidth - pillOverlap)) : iconSize
  height: iconSize

  Rectangle {
    id: pill
    width: revealed ? maxPillWidth : 1
    height: revealed ? maxPillHeight : 1

    // Position based on direction - center the pill relative to the icon
    x: openLeftward ? (iconCircle.x + iconCircle.width / 2 - width) : (iconCircle.x + iconCircle.width / 2 - pillOverlap)
    y: 0

    opacity: revealed ? Style.opacityFull : Style.opacityNone
    color: Color.mSurfaceVariant
    border.color: Color.mOutline
    border.width: Math.max(1, Style.borderS * scaling)

    // Radius logic for horizontal expansion - rounded on the side that connects to icon
    topLeftRadius: openLeftward ? iconSize * 0.5 : 0
    bottomLeftRadius: openLeftward ? iconSize * 0.5 : 0
    topRightRadius: openRightward ? iconSize * 0.5 : 0
    bottomRightRadius: openRightward ? iconSize * 0.5 : 0

    anchors.verticalCenter: parent.verticalCenter

    NText {
      id: textItem
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      anchors.horizontalCenterOffset: openLeftward ? -6 * scaling : 6 * scaling // Adjust based on opening direction
      text: root.text
      font.family: Settings.data.ui.fontFixed
      font.pointSize: Style.fontSizeXXS * scaling
      font.weight: Style.fontWeightBold
      color: Color.mOnSurface
      visible: revealed
    }

    Behavior on width {
      enabled: showAnim.running || hideAnim.running
      NumberAnimation {
        duration: Style.animationNormal
        easing.type: Easing.OutCubic
      }
    }
    Behavior on height {
      enabled: showAnim.running || hideAnim.running
      NumberAnimation {
        duration: Style.animationNormal
        easing.type: Easing.OutCubic
      }
    }
    Behavior on opacity {
      enabled: showAnim.running || hideAnim.running
      NumberAnimation {
        duration: Style.animationNormal
        easing.type: Easing.OutCubic
      }
    }
  }

  Rectangle {
    id: iconCircle
    width: iconSize
    height: iconSize
    radius: width * 0.5
    color: hovered && !forceOpen ? Color.mTertiary : Color.mSurfaceVariant

    // Icon positioning based on direction
    x: openLeftward ? (parent.width - width) : 0
    y: 0
    anchors.verticalCenter: parent.verticalCenter

    Behavior on color {
      ColorAnimation {
        duration: Style.animationNormal
        easing.type: Easing.InOutQuad
      }
    }

    NIcon {
      icon: root.icon
      font.pointSize: Style.fontSizeM * scaling
      color: hovered && !forceOpen ? Color.mOnTertiary : Color.mOnSurface
      // Center horizontally
      x: (iconCircle.width - width) / 2
      // Center vertically accounting for font metrics
      y: (iconCircle.height - height) / 2 + (height - contentHeight) / 2
    }
  }

  ParallelAnimation {
    id: showAnim
    running: false
    NumberAnimation {
      target: pill
      property: "width"
      from: 1
      to: maxPillWidth
      duration: Style.animationNormal
      easing.type: Easing.OutCubic
    }
    NumberAnimation {
      target: pill
      property: "height"
      from: 1
      to: maxPillHeight
      duration: Style.animationNormal
      easing.type: Easing.OutCubic
    }
    NumberAnimation {
      target: pill
      property: "opacity"
      from: 0
      to: 1
      duration: Style.animationNormal
      easing.type: Easing.OutCubic
    }
    onStarted: {
      showPill = true
    }
    onStopped: {
      delayedHideAnim.start()
      root.shown()
    }
  }

  SequentialAnimation {
    id: delayedHideAnim
    running: false
    PauseAnimation {
      duration: 2500
    }
    ScriptAction {
      script: if (shouldAnimateHide) {
                hideAnim.start()
              }
    }
  }

  ParallelAnimation {
    id: hideAnim
    running: false
    NumberAnimation {
      target: pill
      property: "width"
      from: maxPillWidth
      to: 1
      duration: Style.animationNormal
      easing.type: Easing.InCubic
    }
    NumberAnimation {
      target: pill
      property: "height"
      from: maxPillHeight
      to: 1
      duration: Style.animationNormal
      easing.type: Easing.InCubic
    }
    NumberAnimation {
      target: pill
      property: "opacity"
      from: 1
      to: 0
      duration: Style.animationNormal
      easing.type: Easing.InCubic
    }
    onStopped: {
      showPill = false
      shouldAnimateHide = false
      root.hidden()
    }
  }

  NTooltip {
    id: tooltip
    target: pill
    text: root.tooltipText
    positionLeft: barPosition === "right"
    positionRight: barPosition === "left"
    positionAbove: Settings.data.bar.position === "bottom"
    delay: Style.tooltipDelayLong
  }

  Timer {
    id: showTimer
    interval: Style.pillDelay
    onTriggered: {
      if (!showPill) {
        showAnim.start()
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    onEntered: {
      hovered = true
      root.entered()
      tooltip.show()
      if (disableOpen) {
        return
      }
      if (!forceOpen) {
        showDelayed()
      }
    }
    onExited: {
      hovered = false
      root.exited()
      if (!forceOpen) {
        hide()
      }
      tooltip.hide()
    }
    onClicked: function (mouse) {
      if (mouse.button === Qt.LeftButton) {
        root.clicked()
      } else if (mouse.button === Qt.RightButton) {
        root.rightClicked()
      } else if (mouse.button === Qt.MiddleButton) {
        root.middleClicked()
      }
    }
    onWheel: wheel => {
               root.wheel(wheel.angleDelta.y)
             }
  }

  function show() {
    if (!showPill) {
      shouldAnimateHide = autoHide
      showAnim.start()
    } else {
      hideAnim.stop()
      delayedHideAnim.restart()
    }
  }

  function hide() {
    if (forceOpen) {
      return
    }
    if (showPill) {
      hideAnim.start()
    }
    showTimer.stop()
  }

  function showDelayed() {
    if (!showPill) {
      shouldAnimateHide = autoHide
      showTimer.start()
    } else {
      hideAnim.stop()
      delayedHideAnim.restart()
    }
  }

  onForceOpenChanged: {
    if (forceOpen) {
      // Immediately lock open without animations
      showAnim.stop()
      hideAnim.stop()
      delayedHideAnim.stop()
      showPill = true
    } else {
      hide()
    }
  }
}
