pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.Commons
import qs.Services

Singleton {
  id: root

  readonly property var powerProfiles: PowerProfiles
  readonly property bool available: powerProfiles && powerProfiles.hasPerformanceProfile
  property int profile: powerProfiles ? powerProfiles.profile : PowerProfile.Balanced

  function getName(p) {
    if (!available)
      return "Unknown"

    const prof = (p !== undefined) ? p : profile

    switch (prof) {
    case PowerProfile.Performance:
      return "Performance"
    case PowerProfile.Balanced:
      return "Balanced"
    case PowerProfile.PowerSaver:
      return "Power saver"
    default:
      return "Unknown"
    }
  }

  function getIcon(p) {
    if (!available)
      return "balanced"

    const prof = (p !== undefined) ? p : profile

    switch (prof) {
    case PowerProfile.Performance:
      return "performance"
    case PowerProfile.Balanced:
      return "balanced"
    case PowerProfile.PowerSaver:
      return "powersaver"
    default:
      return "balanced"
    }
  }

  function setProfile(p) {
    if (!available)
      return
    try {
      powerProfiles.profile = p
    } catch (e) {
      Logger.error("PowerProfileService", "Failed to set profile:", e)
    }
  }

  function cycleProfile() {
    if (!available)
      return
    const current = powerProfiles.profile
    if (current === PowerProfile.Performance)
      setProfile(PowerProfile.PowerSaver)
    else if (current === PowerProfile.Balanced)
      setProfile(PowerProfile.Performance)
    else if (current === PowerProfile.PowerSaver)
      setProfile(PowerProfile.Balanced)
  }
  
  function getColor(p) {
    if (!available)
      return "#e0def4"

    const prof = (p !== undefined) ? p : profile

    switch (prof) {
    case PowerProfile.Performance:
      return "#ebbcba"
    case PowerProfile.Balanced:
      return "#c4a7e7"
    case PowerProfile.PowerSaver:
      return "#9ccfd8"
    default:
      return "#e0def4"
    }
  }

  Connections {
    target: powerProfiles
    function onProfileChanged() {
      root.profile = powerProfiles.profile
      // Only show toast if we have a valid profile name (not "Unknown")
      const profileName = root.getName()
      if (profileName !== "Unknown") {
        ToastService.showNotice(I18n.tr("toast.power-profile.changed"), I18n.tr("toast.power-profile.profile-name", {
                                                                                  "profile": profileName
                                                                                }))
      }
    }
  }
}
