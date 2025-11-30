import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Services.Control
import qs.Services.UI
import qs.Widgets

ColumnLayout {
  id: contentColumn
  spacing: Style.marginL
  width: root.width

  NHeader {
    label: I18n.tr("settings.hooks.system-hooks.section.label")
    description: I18n.tr("settings.hooks.system-hooks.section.description")
  }

  // Enable/Disable Toggle
  NToggle {
    label: I18n.tr("settings.hooks.system-hooks.enable.label")
    description: I18n.tr("settings.hooks.system-hooks.enable.description")
    checked: Settings.data.hooks.enabled
    onToggled: checked => Settings.data.hooks.enabled = checked
  }

  ColumnLayout {
    visible: Settings.data.hooks.enabled
    spacing: Style.marginL
    Layout.fillWidth: true

    NDivider {
      Layout.fillWidth: true
    }

    // Wallpaper Hook Section
    NInputAction {
      id: wallpaperHookInput
      label: I18n.tr("settings.hooks.wallpaper-changed.label")
      description: I18n.tr("settings.hooks.wallpaper-changed.description")
      placeholderText: I18n.tr("settings.hooks.wallpaper-changed.placeholder")
      text: Settings.data.hooks.wallpaperChange
      onEditingFinished: {
        Settings.data.hooks.wallpaperChange = wallpaperHookInput.text;
      }
      onActionClicked: {
        if (wallpaperHookInput.text) {
          HooksService.executeWallpaperHook("test", "test-screen");
        }
      }
      Layout.fillWidth: true
    }

    NDivider {
      Layout.fillWidth: true
    }

    // Dark Mode Hook Section
    NInputAction {
      id: darkModeHookInput
      label: I18n.tr("settings.hooks.theme-changed.label")
      description: I18n.tr("settings.hooks.theme-changed.description")
      placeholderText: I18n.tr("settings.hooks.theme-changed.placeholder")
      text: Settings.data.hooks.darkModeChange
      onEditingFinished: {
        Settings.data.hooks.darkModeChange = darkModeHookInput.text;
      }
      onActionClicked: {
        if (darkModeHookInput.text) {
          HooksService.executeDarkModeHook(Settings.data.colorSchemes.darkMode);
        }
      }
      Layout.fillWidth: true
    }

    NDivider {
      Layout.fillWidth: true
    }

    // Battery Dropped Threshold Hook Section
    NInputAction {
      id: batteryDroppedThresholdHookInput
      label: I18n.tr("settings.hooks.battery-dropped-threshold.label")
      description: I18n.tr("settings.hooks.battery-dropped-threshold.description")
      placeholderText: I18n.tr("settings.hooks.battery-dropped-threshold.placeholder")
      text: Settings.data.hooks.batteryDroppedThreshold
      onEditingFinished: {
        Settings.data.hooks.batteryDroppedThreshold = batteryDroppedThresholdHookInput.text;
      }
      onActionClicked: {
        if (batteryDroppedThresholdHookInput.text) {
          HooksService.executeBatteryDroppedThresholdHook(Settings.data.battery.warningThreshold, false);
        }
      }
      Layout.fillWidth: true
    }

    NDivider {
      Layout.fillWidth: true
    }

    // Battery Surpassed Threshold Hook Section
    NInputAction {
      id: batterySurpassedThresholdHookInput
      label: I18n.tr("settings.hooks.battery-surpassed-threshold.label")
      description: I18n.tr("settings.hooks.battery-surpassed-threshold.description")
      placeholderText: I18n.tr("settings.hooks.battery-surpassed-threshold.placeholder")
      text: Settings.data.hooks.batterySurpassedThreshold
      onEditingFinished: {
        Settings.data.hooks.batterySurpassedThreshold = batterySurpassedThresholdHookInput.text;
      }
      onActionClicked: {
        if (batterySurpassedThresholdHookInput.text) {
          HooksService.executeBatterySurpassedThresholdHook(Settings.data.battery.warningThreshold + 5, false);
        }
      }
      Layout.fillWidth: true
    }

    NDivider {
      Layout.fillWidth: true
    }

    // AC Power Unplugged Hook Section
    NInputAction {
      id: acPowerUnpluggedHookInput
      label: I18n.tr("settings.hooks.ac-power-unplugged.label")
      description: I18n.tr("settings.hooks.ac-power-unplugged.description")
      placeholderText: I18n.tr("settings.hooks.ac-power-unplugged.placeholder")
      text: Settings.data.hooks.acPowerUnplugged
      onEditingFinished: {
        Settings.data.hooks.acPowerUnplugged = acPowerUnpluggedHookInput.text;
      }
      onActionClicked: {
        if (acPowerUnpluggedHookInput.text) {
          HooksService.executeAcPowerUnpluggedHook(false);
        }
      }
      Layout.fillWidth: true
    }

    NDivider {
      Layout.fillWidth: true
    }

    // AC Power Plugged Hook Section
    NInputAction {
      id: acPowerPluggedHookInput
      label: I18n.tr("settings.hooks.ac-power-plugged.label")
      description: I18n.tr("settings.hooks.ac-power-plugged.description")
      placeholderText: I18n.tr("settings.hooks.ac-power-plugged.placeholder")
      text: Settings.data.hooks.acPowerPlugged
      onEditingFinished: {
        Settings.data.hooks.acPowerPlugged = acPowerPluggedHookInput.text;
      }
      onActionClicked: {
        if (acPowerPluggedHookInput.text) {
          HooksService.executeAcPowerPluggedHook(true);
        }
      }
      Layout.fillWidth: true
    }

    NDivider {
      Layout.fillWidth: true
    }

    // Info section
    ColumnLayout {
      spacing: Style.marginM
      Layout.fillWidth: true

      NLabel {
        label: I18n.tr("settings.hooks.info.command-info.label")
        description: I18n.tr("settings.hooks.info.command-info.description")
      }

      NLabel {
        label: I18n.tr("settings.hooks.info.parameters.label")
        description: I18n.tr("settings.hooks.info.parameters.description")
      }
    }
  }
}
