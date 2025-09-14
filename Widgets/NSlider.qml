import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import qs.Commons
import qs.Services

Slider {
  id: root

  // Optional color to cut the track beneath the knob (should match surrounding background)
  property var cutoutColor
  property bool snapAlways: true
  property real heightRatio: 0.75

  readonly property real knobDiameter: Math.round(Style.baseWidgetSize * heightRatio * scaling)
  readonly property real trackHeight: knobDiameter * 0.5
  readonly property real cutoutExtra: Math.round(Style.baseWidgetSize * 0.1 * scaling)

  snapMode: snapAlways ? Slider.SnapAlways : Slider.SnapOnRelease
  implicitHeight: Math.max(trackHeight, knobDiameter)

  background: Rectangle {
    x: root.leftPadding
    y: root.topPadding + root.availableHeight / 2 - height / 2
    implicitWidth: Style.sliderWidth
    implicitHeight: trackHeight
    width: root.availableWidth
    height: implicitHeight
    radius: height / 2
    color: Color.mSurface

    Rectangle {
      id: activeTrack
      width: root.visualPosition * parent.width
      height: parent.height
      color: Color.mPrimary
      radius: parent.radius
    }

    // Circular cutout
    Rectangle {
      id: knobCutout
      width: knobDiameter + cutoutExtra
      height: knobDiameter + cutoutExtra
      radius: width / 2
      color: root.cutoutColor !== undefined ? root.cutoutColor : Color.mSurface
      x: Math.max(0, Math.min(parent.width - width, Math.round(root.visualPosition * (parent.width - root.knobDiameter) - cutoutExtra / 2)))
      y: (parent.height - height) / 2
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  handle: Item {
    width: knob.implicitWidth
    height: knob.implicitHeight
    x: root.leftPadding + Math.round(root.visualPosition * (root.availableWidth - width))
    y: root.topPadding + root.availableHeight / 2 - height / 2

    Rectangle {
      id: knob
      implicitWidth: knobDiameter
      implicitHeight: knobDiameter
      radius: width * 0.5
      color: root.pressed ? Color.mTertiary : Color.mSurface
      border.color: Color.mPrimary
      border.width: Math.max(1, Style.borderL * scaling)
      anchors.centerIn: parent

      Behavior on color {
        ColorAnimation {
          duration: Style.animationFast
        }
      }
    }
  }
}
