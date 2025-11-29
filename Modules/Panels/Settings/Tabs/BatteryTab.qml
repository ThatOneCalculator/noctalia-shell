import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

NScrollView {
  id: root

  ColumnLayout {
    width: root.width - root.ScrollBar.vertical.width
    spacing: Style.marginXL

    // Battery section
    ColumnLayout {
      Layout.fillWidth: true
      spacing: Style.marginM

      NHeader {
        label: I18n.tr("settings.battery.title")
        description: I18n.tr("settings.battery.description")
      }
    }

    // Warning threshold section
    ColumnLayout {
      Layout.fillWidth: true
      spacing: Style.marginM

      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginL

        ColumnLayout {
          Layout.fillWidth: true
          spacing: Style.marginS

          NText {
            text: I18n.tr("settings.battery.low-battery-threshold.title")
            font.weight: Font.Medium
          }

          NText {
            text: I18n.tr("settings.battery.low-battery-threshold.description")
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            opacity: 0.7
          }
        }
        NSpinBox {
          Layout.alignment: Qt.AlignHCenter
          from: 5
          to: 50
          stepSize: 1
          value: Settings.data.battery.warningThreshold
          onValueChanged: Settings.data.battery.warningThreshold = value
          suffix: "%"
        }
      }
    }
  }
}
