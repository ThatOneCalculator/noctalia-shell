pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.Commons
import qs.Services.UI

Singleton {
  id: root

  // Battery monitoring state
  property real lastBatteryPercent: -1
  property bool lastChargingState: false
  property bool lastAcConnected: false
  property bool batteryThresholdNotified: false

  // Hook connections for automatic script execution
  Connections {
    target: Settings.data.colorSchemes
    function onDarkModeChanged() {
      executeDarkModeHook(Settings.data.colorSchemes.darkMode);
    }
  }

  Connections {
    target: WallpaperService
    function onWallpaperChanged(screenName, path) {
      executeWallpaperHook(path, screenName);
    }
  }

  // Battery monitoring connections
  Connections {
    target: UPower.displayDevice
    function onPercentageChanged() {
      if (!UPower.displayDevice || !UPower.displayDevice.ready || !UPower.displayDevice.isLaptopBattery) {
        return;
      }

      const currentPercent = UPower.displayDevice.percentage * 100;
      const isCharging = UPower.displayDevice.state === UPowerDeviceState.Charging;
      const warningThreshold = Settings.data.battery.warningThreshold;

      // Check for threshold crossing
      if (root.lastBatteryPercent >= 0) {
        // Battery dropped to threshold
        if (root.lastBatteryPercent > warningThreshold && currentPercent <= warningThreshold && !isCharging) {
          executeBatteryDroppedThresholdHook(currentPercent, isCharging);
          root.batteryThresholdNotified = true;
        } else
          // Battery surpassed threshold
          if (root.lastBatteryPercent <= warningThreshold && currentPercent > warningThreshold && root.batteryThresholdNotified) {
            executeBatterySurpassedThresholdHook(currentPercent, isCharging);
            root.batteryThresholdNotified = false;
          }
      }

      root.lastBatteryPercent = currentPercent;
      root.lastChargingState = isCharging;
    }

    function onStateChanged() {
      if (!UPower.displayDevice || !UPower.displayDevice.ready || !UPower.displayDevice.isLaptopBattery) {
        return;
      }

      const isCharging = UPower.displayDevice.state === UPowerDeviceState.Charging;
      const currentPercent = UPower.displayDevice.percentage * 100;

      // Reset threshold notification when charging starts
      if (isCharging && !root.lastChargingState) {
        root.batteryThresholdNotified = false;
      }

      root.lastChargingState = isCharging;
      root.lastBatteryPercent = currentPercent;
    }
  }

  // AC Power monitoring via charging state changes
  Connections {
    target: UPower.displayDevice
    function onStateChanged() {
      if (!UPower.displayDevice || !UPower.displayDevice.ready || !UPower.displayDevice.isLaptopBattery) {
        return;
      }

      const isCharging = UPower.displayDevice.state === UPowerDeviceState.Charging;

      // Detect AC power changes based on charging state transitions
      if (root.lastChargingState !== isCharging) {
        if (isCharging) {
          executeAcPowerPluggedHook(true);
        } else {
          executeAcPowerUnpluggedHook(false);
        }
      }
    }
  }

  // Execute wallpaper change hook
  function executeWallpaperHook(wallpaperPath, screenName) {
    if (!Settings.data.hooks?.enabled) {
      return;
    }

    const script = Settings.data.hooks?.wallpaperChange;
    if (!script || script === "") {
      return;
    }

    try {
      let command = script.replace(/\$1/g, wallpaperPath);
      command = command.replace(/\$2/g, screenName || "");
      Quickshell.execDetached(["sh", "-c", command]);
      Logger.d("HooksService", `Executed wallpaper hook: ${command}`);
    } catch (e) {
      Logger.e("HooksService", `Failed to execute wallpaper hook: ${e}`);
    }
  }

  // Execute dark mode change hook
  function executeDarkModeHook(isDarkMode) {
    if (!Settings.data.hooks?.enabled) {
      return;
    }

    const script = Settings.data.hooks?.darkModeChange;
    if (!script || script === "") {
      return;
    }

    try {
      const command = script.replace(/\$1/g, isDarkMode ? "true" : "false");
      Quickshell.execDetached(["sh", "-c", command]);
      Logger.d("HooksService", `Executed dark mode hook: ${command}`);
    } catch (e) {
      Logger.e("HooksService", `Failed to execute dark mode hook: ${e}`);
    }
  }

  // Execute battery dropped to threshold hook
  function executeBatteryDroppedThresholdHook(batteryPercent, isCharging) {
    if (!Settings.data.hooks?.enabled) {
      return;
    }

    const script = Settings.data.hooks?.batteryDroppedThreshold;
    if (!script || script === "") {
      return;
    }

    try {
      let command = script.replace(/\$1/g, batteryPercent.toString());
      command = command.replace(/\$2/g, isCharging ? "true" : "false");
      Quickshell.execDetached(["sh", "-c", command]);
      Logger.d("HooksService", `Executed battery dropped threshold hook: ${command}`);
    } catch (e) {
      Logger.e("HooksService", `Failed to execute battery dropped threshold hook: ${e}`);
    }
  }

  // Execute battery surpassed threshold hook
  function executeBatterySurpassedThresholdHook(batteryPercent, isCharging) {
    if (!Settings.data.hooks?.enabled) {
      return;
    }

    const script = Settings.data.hooks?.batterySurpassedThreshold;
    if (!script || script === "") {
      return;
    }

    try {
      let command = script.replace(/\$1/g, batteryPercent.toString());
      command = command.replace(/\$2/g, isCharging ? "true" : "false");
      Quickshell.execDetached(["sh", "-c", command]);
      Logger.d("HooksService", `Executed battery surpassed threshold hook: ${command}`);
    } catch (e) {
      Logger.e("HooksService", `Failed to execute battery surpassed threshold hook: ${e}`);
    }
  }

  // Execute AC power unplugged hook
  function executeAcPowerUnpluggedHook(acConnected) {
    if (!Settings.data.hooks?.enabled) {
      return;
    }

    const script = Settings.data.hooks?.acPowerUnplugged;
    if (!script || script === "") {
      return;
    }

    try {
      const command = script.replace(/\$1/g, acConnected ? "true" : "false");
      Quickshell.execDetached(["sh", "-c", command]);
      Logger.d("HooksService", `Executed AC power unplugged hook: ${command}`);
    } catch (e) {
      Logger.e("HooksService", `Failed to execute AC power unplugged hook: ${e}`);
    }
  }

  // Execute AC power plugged hook
  function executeAcPowerPluggedHook(acConnected) {
    if (!Settings.data.hooks?.enabled) {
      return;
    }

    const script = Settings.data.hooks?.acPowerPlugged;
    if (!script || script === "") {
      return;
    }

    try {
      const command = script.replace(/\$1/g, acConnected ? "true" : "false");
      Quickshell.execDetached(["sh", "-c", command]);
      Logger.d("HooksService", `Executed AC power plugged hook: ${command}`);
    } catch (e) {
      Logger.e("HooksService", `Failed to execute AC power plugged hook: ${e}`);
    }
  }

  // Initialize the service
  function init() {
    Logger.i("HooksService", "Service started");

    // Initialize battery state
    if (UPower.displayDevice && UPower.displayDevice.ready && UPower.displayDevice.isLaptopBattery) {
      root.lastBatteryPercent = UPower.displayDevice.percentage * 100;
      root.lastChargingState = UPower.displayDevice.state === UPowerDeviceState.Charging;
    }

    // Initialize AC adapter state based on charging state
    root.lastAcConnected = root.lastChargingState;
  }
}
