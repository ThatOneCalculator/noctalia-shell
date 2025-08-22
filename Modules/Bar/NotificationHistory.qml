import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Services
import qs.Widgets

NIconButton {
  id: root

  visible: Settings.data.bar.showNotificationsHistory
  sizeMultiplier: 0.8
  icon: "notifications"
  tooltipText: "Notification History"
  colorBg: Color.mSurfaceVariant
  colorFg: "#f6c177"
  colorBorder: Color.transparent
  colorBorderHover: Color.transparent

  onClicked: {
    notificationHistoryPanel.toggle(screen)
  }
}
