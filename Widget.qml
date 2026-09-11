import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

// Sysmon — CPU %, memory %, and network rate in a framed pill.
//
// The metrics come from bin/sysmon next to this file: one /proc read plus a
// difference against the previous sample, printed as a single waybar-style JSON
// line. bin/sysmon pads every field to a fixed width, so the pill never resizes
// and never shoves its neighbours around as the numbers change.
Item {
  id: root

  // Injected by the bar after load.
  property var bar
  property string moduleName: "alijiujiu.sysmon"
  property var settings: ({})

  property string output: ""
  property string detail: ""
  property bool alert: false
  property bool hovered: false

  function setting(name, fallback) {
    var value = settings ? settings[name] : undefined
    return value === undefined || value === null || value === "" ? fallback : value
  }

  // Bundled files resolve relative to this QML file, so the plugin works from
  // wherever it was cloned into (~/.config/omarchy/plugins/<id>/).
  function localFile(relative) {
    return decodeURIComponent(Qt.resolvedUrl(relative).toString().replace(/^file:\/\//, ""))
  }

  function quote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  readonly property string metricsScript: localFile("bin/sysmon")
  readonly property string monitorScript: localFile("bin/open-monitor")
  readonly property int fontSize: Number(setting("fontSize", 11))
  readonly property real borderAlpha: Math.max(0, Math.min(1, Number(setting("borderAlpha", 0.7))))
  readonly property color ink: bar ? bar.foreground : Color.foreground
  readonly property color warn: bar ? bar.urgent : Color.urgent

  implicitWidth: pill.implicitWidth
  implicitHeight: bar ? bar.barSize : Style.bar.sizeHorizontal

  function refresh() {
    if (!proc.running) proc.running = true
  }

  function commandFor(button) {
    var custom = button === Qt.RightButton ? root.setting("onRightClick", "")
      : button === Qt.MiddleButton ? root.setting("onMiddleClick", "")
      : root.setting("onClick", "")

    if (custom) return String(custom)
    if (button === Qt.RightButton) return "omarchy-launch-or-focus-tui htop"
    if (button === Qt.MiddleButton) return ""
    return root.quote(root.monitorScript)
  }

  // bash, not the script's shebang or mode: a clone that dropped the mode still runs.
  Process {
    id: proc
    command: ["bash", root.metricsScript]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var data
        try { data = JSON.parse(text) } catch (e) { return }
        root.output = String(data.text || "").trim()
        root.detail = String(data.tooltip || "")
        root.alert = data.class === "active"
      }
    }
  }

  Timer {
    interval: Math.max(1, Number(root.setting("interval", 2))) * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  Rectangle {
    id: pill

    anchors.centerIn: parent
    implicitWidth: label.implicitWidth + Style.space(8)
    implicitHeight: label.implicitHeight + Style.space(2)
    height: Math.min(implicitHeight, root.implicitHeight - Style.space(4))
    radius: height / 2
    color: Qt.alpha(root.ink, borderAlpha * (root.hovered ? 0.17 : 0.12))
    border.width: 1
    border.color: Qt.alpha(root.alert ? root.warn : root.ink,
                           Math.min(1, borderAlpha + (root.hovered ? 0.3 : 0)))

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    Text {
      id: label

      anchors.centerIn: parent
      text: root.output
      color: root.ink
      font.family: bar ? bar.fontFamily : Style.fontFamily
      font.pixelSize: root.fontSize
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    onEntered: {
      root.hovered = true
      if (bar) bar.showTooltip(root, root.detail || root.output)
    }
    onExited: {
      root.hovered = false
      if (bar) bar.hideTooltip(root)
    }
    onClicked: function(mouse) {
      var command = root.commandFor(mouse.button)
      if (command && bar) bar.run(command)
    }
  }
}
