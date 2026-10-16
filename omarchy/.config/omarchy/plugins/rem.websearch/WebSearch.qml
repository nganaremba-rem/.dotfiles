import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui

Item {
  id: root

  property var shell: null
  property var manifest: null

  property bool opened: false
  property string query: ""
  property int engineIndex: 0       // chosen with Tab
  property var suggestions: []
  property int selected: -1         // -1 = the typed text itself

  readonly property var engines: [
    { key: "d",    name: "DuckDuckGo", icon: "󰇥", color: "#de5833", url: "https://duckduckgo.com/?q=" },
    { key: "g",    name: "Google",     icon: "󰊭", color: "#4285f4", url: "https://www.google.com/search?q=" },
    { key: "yt",   name: "YouTube",    icon: "󰗃", color: "#ff3030", url: "https://www.youtube.com/results?search_query=" },
    { key: "gh",   name: "GitHub",     icon: "󰊤", color: "#a371f7", url: "https://github.com/search?q=" },
    { key: "wiki", name: "ArchWiki",   icon: "󰣇", color: "#1793d1", url: "https://wiki.archlinux.org/index.php?search=" },
    { key: "p",    name: "Perplexity", icon: "󰧑", color: "#20b8cd", url: "https://www.perplexity.ai/search?q=" },
    { key: "r",    name: "Reddit",     icon: "󰑍", color: "#ff5700", url: "https://www.reddit.com/search/?q=" },
    { key: "mdn",  name: "MDN",        icon: "󰌠", color: "#83d0f2", url: "https://developer.mozilla.org/en-US/search?q=" }
  ]

  // "yt lofi" → YouTube + "lofi". Without a prefix the Tab-chosen engine is used.
  readonly property var parsed: {
    var m = /^(\S+)\s+(.*)$/.exec(query)
    if (m) for (var i = 0; i < engines.length; i++)
      if (engines[i].key === m[1].toLowerCase()) return { engine: i, text: m[2], prefixed: true }
    return { engine: engineIndex, text: query, prefixed: false }
  }
  readonly property var engine: engines[parsed.engine]
  readonly property string searchText: parsed.text.trim()

  property color background: Commons.Color.menu.background
  property color foreground: Commons.Color.menu.text
  property color border: Commons.Color.menu.border
  property var borderSpec: Border.surfaceSpec("menu", "border", border, Math.max(1, Style.space(2)))
  property color scrim: Commons.Color.menu.scrim
  property color selectedBackground: Commons.Color.menu.selectedBackground
  property color selectedText: Commons.Color.menu.selectedText
  readonly property string fontFamily: Style.font.menuFamily

  function open(payloadJson) {
    query = ""; suggestions = []; selected = -1
    opened = true
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }
  function close() { opened = false }
  function dismiss() {
    opened = false
    if (shell && typeof shell.hide === "function") shell.hide((manifest && manifest.id) || "rem.websearch")
  }

  function launch(text) {
    var t = (text || "").trim()
    if (!t) return
    Quickshell.execDetached(["xdg-open", engine.url + encodeURIComponent(t)])
    dismiss()
  }
  function activate() {
    launch(selected >= 0 ? suggestions[selected] : searchText)
  }

  function setQuery(q) {
    query = q; selected = -1
    if (searchText.length < 2) { suggestions = []; suggestTimer.stop(); return }
    suggestTimer.restart()
  }

  Timer { id: suggestTimer; interval: 150; onTriggered: { suggestProc.running = false; suggestProc.running = true } }

  Process {
    id: suggestProc
    command: ["curl", "-s", "-m", "3", "-G", "--data-urlencode", "q=" + root.searchText,
              "--data-urlencode", "type=list", "https://duckduckgo.com/ac/"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var out = JSON.parse(text)
          root.suggestions = (out[1] || []).slice(0, 6)
        } catch (e) { root.suggestions = [] }
      }
    }
  }

  OverlayWindow {
    id: panel
    shown: root.opened
    WlrLayershell.namespace: "rem-websearch"

    Rectangle { anchors.fill: parent; color: root.scrim; opacity: root.opened ? 1 : 0
      Behavior on opacity { NumberAnimation { duration: 140 } } }
    MouseArea { anchors.fill: parent; onClicked: root.dismiss() }

    BorderSurface {
      id: card
      width: Math.min(Style.space(660), panel.width - Style.gapsOut * 2)
      height: content.implicitHeight + padding * 2 + Style.space(8)
      x: (panel.width - width) / 2
      y: panel.height * 0.2 + (1 - appear) * Style.space(-18)
      opacity: appear
      scale: 0.97 + 0.03 * appear
      property real appear: root.opened ? 1 : 0
      Behavior on appear { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

      radius: Style.cornerRadius * 1.5
      color: root.background
      borderSpec: Border.surfaceSpec("menu", "border", root.engine.color, Math.max(1, Style.space(2)))
      padding: Style.spacing.panelPadding

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true
        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          var k = event.key
          if (k === Qt.Key_Escape) { if (root.query) root.setQuery(""); else root.dismiss() }
          else if (k === Qt.Key_Return || k === Qt.Key_Enter) root.activate()
          else if (k === Qt.Key_Tab) root.engineIndex = (root.engineIndex + 1) % root.engines.length
          else if (k === Qt.Key_Backtab) root.engineIndex = (root.engineIndex + root.engines.length - 1) % root.engines.length
          else if (k === Qt.Key_Down) root.selected = Math.min(root.selected + 1, root.suggestions.length - 1)
          else if (k === Qt.Key_Up) root.selected = Math.max(root.selected - 1, -1)
          else if (k === Qt.Key_Backspace) {
            if (event.modifiers & Qt.ControlModifier) root.setQuery(root.query.replace(/\s*\S*\s*$/, ""))
            else root.setQuery(root.query.slice(0, -1))
          }
          else if (k === Qt.Key_U && (event.modifiers & Qt.ControlModifier)) root.setQuery("")
          else if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127
                   && !(event.modifiers & Qt.ControlModifier)) root.setQuery(root.query + event.text)
          else return
          event.accepted = true
        }
      }

      Column {
        id: content
        anchors.left: parent.left; anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: card.contentTopInset
        anchors.leftMargin: card.contentLeftInset
        anchors.rightMargin: card.contentRightInset
        spacing: Style.space(14)

        // ── input row ──
        Row {
          width: parent.width
          spacing: Style.space(14)
          height: Style.space(52)

          Rectangle {
            width: height; height: parent.height; radius: Style.cornerRadius
            color: Qt.rgba(Qt.color(root.engine.color).r, Qt.color(root.engine.color).g, Qt.color(root.engine.color).b, 0.18)
            Behavior on color { ColorAnimation { duration: 150 } }
            Text {
              anchors.centerIn: parent
              text: root.engine.icon
              color: root.engine.color
              font.family: root.fontFamily
              font.pixelSize: Style.font.displayLarge
            }
          }

          Item {
            width: parent.width - parent.height - parent.spacing
            height: parent.height
            Text {
              id: input
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width
              textFormat: Text.PlainText
              text: root.query || ("Search " + root.engine.name + "…")
              opacity: root.query ? 1 : 0.5
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.display
              elide: Text.ElideLeft
            }
            Rectangle {  // blinking caret
              visible: root.query !== "" ? true : true
              x: root.query ? Math.min(input.contentWidth, input.width) + 2 : 0
              anchors.verticalCenter: parent.verticalCenter
              width: Style.space(2); height: Style.font.display * 1.1
              color: root.engine.color
              SequentialAnimation on opacity { running: root.opened; loops: Animation.Infinite
                NumberAnimation { to: 0; duration: 520 } NumberAnimation { to: 1; duration: 520 } }
            }
          }
        }

        // ── engine chips ──
        Flow {
          width: parent.width
          spacing: Style.space(8)
          Repeater {
            model: root.engines
            delegate: Rectangle {
              required property int index
              required property var modelData
              readonly property bool active: index === root.parsed.engine
              height: Style.space(30)
              width: chipRow.implicitWidth + Style.space(22)
              radius: height / 2
              color: active ? modelData.color : "transparent"
              border.width: 1
              border.color: active ? modelData.color : Qt.rgba(1, 1, 1, 0.14)
              Behavior on color { ColorAnimation { duration: 120 } }
              Row {
                id: chipRow
                anchors.centerIn: parent
                spacing: Style.space(6)
                Text { text: modelData.icon; color: active ? "#fff" : modelData.color
                  font.family: root.fontFamily; font.pixelSize: Style.font.bodySmall }
                Text { text: modelData.name; color: active ? "#fff" : root.foreground
                  opacity: active ? 1 : 0.75
                  font.family: root.fontFamily; font.pixelSize: Style.font.bodySmall; font.bold: active }
                Text { text: modelData.key; color: active ? "#fff" : root.foreground
                  opacity: 0.5; font.family: "monospace"; font.pixelSize: Style.font.bodySmall - 1 }
              }
              MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: { root.engineIndex = index; root.query = root.parsed.text; keyCatcher.forceActiveFocus() } }
            }
          }
        }

        // ── suggestions ──
        Column {
          width: parent.width
          spacing: Style.space(2)
          visible: root.suggestions.length > 0
          Rectangle { width: parent.width; height: 1; color: root.foreground; opacity: 0.1 }
          Repeater {
            model: root.suggestions
            delegate: Rectangle {
              required property int index
              required property string modelData
              readonly property bool hot: index === root.selected
              width: parent.width
              height: Style.space(38)
              radius: Style.cornerRadius
              color: hot ? root.selectedBackground : "transparent"
              Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left; anchors.leftMargin: Style.space(12)
                spacing: Style.space(12)
                Text { text: "󰍉"; color: hot ? root.selectedText : root.engine.color
                  font.family: root.fontFamily; font.pixelSize: Style.font.title }
                Text { text: modelData; textFormat: Text.PlainText
                  color: hot ? root.selectedText : root.foreground
                  font.family: root.fontFamily; font.pixelSize: Style.font.title }
              }
              Text {
                anchors.right: parent.right; anchors.rightMargin: Style.space(12)
                anchors.verticalCenter: parent.verticalCenter
                visible: hot; text: "↵"; color: root.selectedText
                font.family: root.fontFamily; font.pixelSize: Style.font.title
              }
              MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onContainsMouseChanged: if (containsMouse) root.selected = index
                onClicked: root.launch(modelData) }
            }
          }
        }

        // ── hints ──
        Row {
          spacing: Style.space(18)
          Repeater {
            model: ["↵ search", "⇥ engine", "↑↓ suggestions", "esc close"]
            delegate: Text { required property string modelData; text: modelData
              color: root.foreground; opacity: 0.45
              font.family: root.fontFamily; font.pixelSize: Style.font.bodySmall - 1 }
          }
        }
      }
    }
  }
}
