import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Widgets
import qs.Services

ColumnLayout {
  id: root
  spacing: Style.marginM * scaling

  // Properties to receive data from parent
  property var widgetData: null
  property var widgetMetadata: null

  // Local state
  property bool valueShowIcon: widgetData.showIcon !== undefined ? widgetData.showIcon : widgetMetadata.showIcon
  property bool valueAutoHide: widgetData.autoHide !== undefined ? widgetData.autoHide : widgetMetadata.autoHide
  property string valueScrollingMode: widgetData.scrollingMode || widgetMetadata.scrollingMode
  property int valueWidth: widgetData.width !== undefined ? widgetData.width : widgetMetadata.width
  property bool valueColorizeIcons: widgetData.colorizeIcons !== undefined ? widgetData.colorizeIcons : widgetMetadata.colorizeIcons

  function saveSettings() {
    var settings = Object.assign({}, widgetData || {})
    settings.autoHide = valueAutoHide
    settings.showIcon = valueShowIcon
    settings.scrollingMode = valueScrollingMode
    settings.width = parseInt(widthInput.text) || widgetMetadata.width
    settings.colorizeIcons = valueColorizeIcons
    return settings
  }

  NToggle {
    Layout.fillWidth: true
    label: I18n.tr("bar.widget-settings.active-window.auto-hide.label")
    description: I18n.tr("bar.widget-settings.active-window.auto-hide.description")
    checked: root.valueAutoHide
    onToggled: checked => root.valueAutoHide = checked
  }

  NToggle {
    Layout.fillWidth: true
    label: I18n.tr("bar.widget-settings.active-window.show-app-icon.label")
    description: I18n.tr("bar.widget-settings.active-window.show-app-icon.description")
    checked: root.valueShowIcon
    onToggled: checked => root.valueShowIcon = checked
  }

  NToggle {
    Layout.fillWidth: true
    label: I18n.tr("bar.widget-settings.active-window.colorize-icons.label")
    description: I18n.tr("bar.widget-settings.active-window.colorize-icons.description")
    checked: root.valueColorizeIcons
    onToggled: checked => root.valueColorizeIcons = checked
  }

  NTextInput {
    id: widthInput
    Layout.fillWidth: true
    label: I18n.tr("bar.widget-settings.active-window.width.label")
    description: I18n.tr("bar.widget-settings.active-window.width.description")
    placeholderText: widgetMetadata.width
    text: valueWidth
  }

  NComboBox {
    label: I18n.tr("bar.widget-settings.active-window.scrolling-mode.label")
    description: I18n.tr("bar.widget-settings.active-window.scrolling-mode.description")
    model: [{
        "key": "always",
        "name": I18n.tr("options.scrolling-modes.always")
      }, {
        "key": "hover",
        "name": I18n.tr("options.scrolling-modes.hover")
      }, {
        "key": "never",
        "name": I18n.tr("options.scrolling-modes.never")
      }]
    currentKey: valueScrollingMode
    onSelected: key => valueScrollingMode = key
    minimumWidth: 200 * scaling
  }
}
