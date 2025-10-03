pragma Singleton

import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs.Commons
import qs.Services
import "../Helpers/sha256.js" as Checksum

Singleton {
  id: root

  // Configuration
  property int maxVisible: 5
  property int maxHistory: 100
  property string historyFile: Quickshell.env("NOCTALIA_NOTIF_HISTORY_FILE") || (Settings.cacheDir + "notifications.json")

  // Models
  property ListModel activeList: ListModel {}
  property ListModel historyList: ListModel {}

  // Internal state
  property var activeMap: ({})
  property var imageQueue: []
  property var progressTimers: ({})
  PanelWindow {
    implicitHeight: 1
    implicitWidth: 1
    color: Color.transparent
    mask: Region {}

    Image {
      id: cacher
      width: 64
      height: 64
      visible: true
      cache: false
      asynchronous: true
      mipmap: true
      antialiasing: true

      onStatusChanged: {
        if (imageQueue.length === 0)
        return
        const req = imageQueue[0]

        if (status === Image.Ready) {
          Quickshell.execDetached(["mkdir", "-p", Settings.cacheDirImagesNotifications])
          grabToImage(result => {
                        if (result.saveToFile(req.dest))
                        updateImagePath(req.imageId, req.dest)
                        processNextImage()
                      })
        } else if (status === Image.Error) {
          processNextImage()
        }
      }

      function processNextImage() {
        imageQueue.shift()
        if (imageQueue.length > 0) {
          source = imageQueue[0].src
        } else {
          source = ""
        }
      }
    }
  }

  // Notification server
  NotificationServer {
    keepOnReload: false
    imageSupported: true
    actionsSupported: true
    onNotification: notification => handleNotification(notification)
  }

  // Main handler
  function handleNotification(notification) {
    const data = createData(notification)
    addToHistory(data)

    if (Settings.data.notifications?.doNotDisturb)
      return

    activeMap[data.id] = notification
    notification.tracked = true
    notification.closed.connect(() => removeActive(data.id))

    activeList.insert(0, data)
    while (activeList.count > maxVisible) {
      const last = activeList.get(activeList.count - 1)
      activeMap[last.id]?.dismiss()
      activeList.remove(activeList.count - 1)
    }
  }

  function createData(n) {
    const time = new Date()
    const id = Checksum.sha256(JSON.stringify({
                                                "summary": n.summary,
                                                "body": n.body,
                                                "app": n.appName,
                                                "time": time.getTime()
                                              }))

    const image = n.image || getIcon(n.appIcon)
    const imageId = generateImageId(n, image)
    queueImage(image, imageId)

    return {
      "id": id,
      "summary": (n.summary || ""),
      "body": stripTags(n.body || ""),
      "appName": getAppName(n.appName),
      "urgency": n.urgency < 0 || n.urgency > 2 ? 1 : n.urgency,
      "expireTimeout": n.expireTimeout,
      "timestamp": time,
      "progress": 1.0,
      "originalImage": image,
      "cachedImage": imageId ? (Settings.cacheDirImagesNotifications + imageId + ".png") : image,
      "actionsJson": JSON.stringify((n.actions || []).map(a => ({
                                                                  "text": a.text || "Action",
                                                                  "identifier": a.identifier || ""
                                                                })))
    }
  }

  function queueImage(path, imageId) {
    if (!path || !path.startsWith("image://") || !imageId)
      return

    const dest = Settings.cacheDirImagesNotifications + imageId + ".png"

    for (const req of imageQueue) {
      if (req.imageId === imageId)
        return
    }

    imageQueue.push({
                      "src": path,
                      "dest": dest,
                      "imageId": imageId
                    })

    if (imageQueue.length === 1)
      cacher.source = path
  }

  function updateImagePath(id, path) {
    updateModel(activeList, id, "cachedImage", path)
    updateModel(historyList, id, "cachedImage", path)
    saveHistory()
  }

  function updateModel(model, id, prop, value) {
    for (var i = 0; i < model.count; i++) {
      if (model.get(i).id === id) {
        model.setProperty(i, prop, value)
        break
      }
    }
  }

  function removeActive(id) {
    for (var i = 0; i < activeList.count; i++) {
      if (activeList.get(i).id === id) {
        activeList.remove(i)
        delete activeMap[id]
        delete progressTimers[id]
        break
      }
    }
  }

  // Auto-hide timer
  Timer {
    interval: 10
    repeat: true
    running: activeList.count > 0
    onTriggered: {
      const now = Date.now()
      const durations = [Settings.data.notifications?.lowUrgencyDuration * 1000 || 3000, Settings.data.notifications?.normalUrgencyDuration * 1000 || 8000, Settings.data.notifications?.criticalUrgencyDuration * 1000 || 15000]

      for (var i = activeList.count - 1; i >= 0; i--) {
        const notif = activeList.get(i)
        const elapsed = now - notif.timestamp.getTime()
        var expire = 0

        if (Settings.data.notifications?.respectExpireTimeout)
        expire = notif.expireTimeout > 0 ? notif.expireTimeout : durations[notif.urgency]
        else
        expire = durations[notif.urgency]

        const progress = Math.max(1.0 - (elapsed / expire), 0.0)
        updateModel(activeList, notif.id, "progress", progress)

        if (elapsed >= expire) {
          animateAndRemove(notif.id)
          delete progressTimers[notif.id]
          break
        }
      }
    }
  }

  // History management
  function addToHistory(data) {
    historyList.insert(0, data)

    while (historyList.count > maxHistory) {
      const old = historyList.get(historyList.count - 1)
      if (old.cachedImage && !old.cachedImage.startsWith("image://")) {
        Quickshell.execDetached(["rm", "-f", old.cachedImage])
      }
      historyList.remove(historyList.count - 1)
    }
    saveHistory()
  }

  // Persistence
  FileView {
    id: historyFileView
    path: historyFile
    printErrors: false
    onLoaded: loadHistory()
    onLoadFailed: error => {
      if (error === 2)
      writeAdapter()
    }

    JsonAdapter {
      id: adapter
      property var notifications: []
    }
  }

  Timer {
    id: saveTimer
    interval: 200
    onTriggered: performSaveHistory()
  }

  function saveHistory() {
    saveTimer.restart()
  }

  function performSaveHistory() {
    try {
      const items = []
      for (var i = 0; i < historyList.count; i++) {
        const n = historyList.get(i)
        const copy = Object.assign({}, n)
        copy.timestamp = n.timestamp.getTime()
        items.push(copy)
      }
      adapter.notifications = items
      historyFileView.writeAdapter()
    } catch (e) {
      Logger.error("Notifications", "Save history failed:", e)
    }
  }

  function loadHistory() {
    try {
      historyList.clear()
      for (const item of adapter.notifications || []) {
        const time = new Date(item.timestamp)

        let cachedImage = item.cachedImage || ""
        if (item.originalImage && item.originalImage.startsWith("image://") && !cachedImage) {
          const imageId = generateImageId(item, item.originalImage)
          if (imageId) {
            cachedImage = Settings.cacheDirImagesNotifications + imageId + ".png"
          }
        }

        historyList.append({
                             "id": item.id || "",
                             "summary": item.summary || "",
                             "body": item.body || "",
                             "appName": item.appName || "",
                             "urgency": item.urgency < 0 || item.urgency > 2 ? 1 : item.urgency,
                             "timestamp": time,
                             "originalImage": item.originalImage || "",
                             "cachedImage": cachedImage
                           })
      }
    } catch (e) {
      Logger.error("Notifications", "Load failed:", e)
    }
  }

  function getAppName(name) {
    if (!name || name.trim() === "")
      return "Unknown"

    name = name.trim()

    if (name.includes(".") && (name.startsWith("com.") || name.startsWith("org.") || name.startsWith("io.") || name.startsWith("net."))) {
      const parts = name.split(".")
      let appPart = parts[parts.length - 1]

      if (!appPart || appPart === "app" || appPart === "desktop") {
        appPart = parts[parts.length - 2] || parts[0]
      }

      if (appPart) {
        name = appPart
      }
    }

    if (name.includes(".")) {
      const parts = name.split(".")
      let displayName = parts[parts.length - 1]

      if (!displayName || /^\d+$/.test(displayName)) {
        displayName = parts[parts.length - 2] || parts[0]
      }

      if (displayName) {
        displayName = displayName.charAt(0).toUpperCase() + displayName.slice(1)
        displayName = displayName.replace(/([a-z])([A-Z])/g, '$1 $2')
        displayName = displayName.replace(/app$/i, '').trim()
        displayName = displayName.replace(/desktop$/i, '').trim()
        displayName = displayName.replace(/flatpak$/i, '').trim()

        if (!displayName) {
          displayName = parts[parts.length - 1].charAt(0).toUpperCase() + parts[parts.length - 1].slice(1)
        }
      }

      return displayName || name
    }

    let displayName = name.charAt(0).toUpperCase() + name.slice(1)
    displayName = displayName.replace(/([a-z])([A-Z])/g, '$1 $2')
    displayName = displayName.replace(/app$/i, '').trim()
    displayName = displayName.replace(/desktop$/i, '').trim()

    return displayName || name
  }

  function getIcon(icon) {
    if (!icon)
      return ""
    if (icon.startsWith("/") || icon.startsWith("file://"))
      return icon
    return ThemeIcons.iconFromName(icon)
  }

  function stripTags(text) {
    return text.replace(/<[^>]*>?/gm, '')
  }

  function generateImageId(notification, image) {
    if (image && image.startsWith("image://")) {
      if (image.startsWith("image://qsimage/")) {
        const key = (notification.appName || "") + "|" + (notification.summary || "")
        return Checksum.sha256(key)
      }
      return Checksum.sha256(image)
    }
    return ""
  }

  // Public API
  function dismissActiveNotification(id) {
    activeMap[id]?.dismiss()
    removeActive(id)
  }

  function dismissAllActive() {
    Object.values(activeMap).forEach(n => n.dismiss())
    activeList.clear()
    activeMap = {}
  }

  function invokeAction(id, actionId) {
    const n = activeMap[id]
    if (!n?.actions)
      return false

    for (const action of n.actions) {
      if (action.identifier === actionId && action.invoke) {
        action.invoke()
        return true
      }
    }
    return false
  }

  function removeFromHistory(notificationId) {
    for (var i = 0; i < historyList.count; i++) {
      const notif = historyList.get(i)
      if (notif.id === notificationId) {
        if (notif.cachedImage && !notif.cachedImage.startsWith("image://")) {
          Quickshell.execDetached(["rm", "-f", notif.cachedImage])
        }
        historyList.remove(i)
        saveHistory()
        return true
      }
    }
    return false
  }

  function clearHistory() {
    try {
      Quickshell.execDetached(["sh", "-c", `rm -rf "${Settings.cacheDirImagesNotifications}"*`])
    } catch (e) {
      Logger.error("Notifications", "Failed to clear cache directory:", e)
    }

    historyList.clear()
    saveHistory()
  }

  // Signals & connections
  signal animateAndRemove(string notificationId)

  Connections {
    target: Settings.data.notifications
    function onDoNotDisturbChanged() {
      const enabled = Settings.data.notifications.doNotDisturb
      ToastService.showNotice(enabled ? I18n.tr("toast.do-not-disturb.enabled") : I18n.tr("toast.do-not-disturb.disabled"), enabled ? I18n.tr("toast.do-not-disturb.enabled-desc") : I18n.tr("toast.do-not-disturb.disabled-desc"))
    }
  }
}
