import QtQuick
import Quickshell
import Quickshell.Io

// Download picker  (qs -p ~/.config/quickshell/ytdl)
//   form     j/k Tab row · h/l change · v video · a audio · i edit · ⏎ review · esc quit
//   confirm  y/⏎ download · n/esc back
//   running  click to focus · x cancel · esc hide (download keeps going)
//   done     o play · f folder · esc close
ShellRoot {
    id: root
    property int row: 0
    property bool insert: false
    property int typeIdx: 0
    property int vq: 0
    property int aq: 0
    readonly property var types: ["video", "audio"]
    readonly property var vqs: ["best", "2160p", "1440p", "1080p", "720p", "480p", "360p"]
    readonly property var aqs: ["mp3", "opus", "m4a"]
    readonly property var labels: ["URL", "Type", "Quality", "From", "To", "Name", "Folder"]
    readonly property var icons: ["󰌷", "󰕧", "󰓅", "󰐊", "󰓛", "󰏫", "󰉋"]
    readonly property var inputs: [urlIn, null, null, startIn, endIn, nameIn, dirIn]
    readonly property string qval: typeIdx === 0 ? vqs[vq] : aqs[aq]
    readonly property var choices: typeIdx === 0 ? vqs : aqs

    // Catppuccin Mocha
    readonly property color cBase: "#1e1e2e"
    readonly property color cMantle: "#181825"
    readonly property color cSurf: "#313244"
    readonly property color cSurf1: "#45475a"
    readonly property color cOver: "#6c7086"
    readonly property color cText: "#cdd6f4"
    readonly property color cSub: "#a6adc8"
    readonly property color cBlue: "#89b4fa"
    readonly property color cMauve: "#cba6f7"
    readonly property color cGrn: "#a6e3a1"
    readonly property color cTeal: "#94e2d5"
    readonly property color cSky: "#89dceb"
    readonly property color cPeach: "#fab387"
    readonly property color cYel: "#f9e2af"
    readonly property color cRed: "#f38ba8"
    readonly property var hues: [cBlue, cMauve, cGrn, cPeach, cPeach, cYel, cTeal]
    readonly property string fSans: "Noto Sans"
    readonly property string fMono: "JetBrainsMono Nerd Font"

    function cycle(d) {
        if (row === 1) typeIdx = (typeIdx + d + 2) % 2
        else if (row === 2) {
            if (typeIdx === 0) vq = (vq + d + vqs.length) % vqs.length
            else aq = (aq + d + aqs.length) % aqs.length
        }
    }
    function startEdit() {
        const t = inputs[row]
        if (!t) return
        insert = true
        t.forceActiveFocus()
        // time boxes: cursor at the first empty digit, the ":" are skipped by the mask
        if (row === 3 || row === 4) { const n = digits(t).length; t.cursorPosition = n + Math.floor(n / 2) }
        else t.cursorPosition = t.text.length
    }

    // ---- validation --------------------------------------------------------
    property string errMsg: ""
    function digits(t) { return t.text.replace(/\D/g, "") }
    // "HH:MM:SS" when the box is complete, "" when empty, null when half-filled
    function timeVal(t) {
        const d = digits(t)
        if (d.length === 0) return ""
        if (d.length < 6) return null
        return d.slice(0, 2) + ":" + d.slice(2, 4) + ":" + d.slice(4, 6)
    }
    function secs(v) { const p = v.split(":"); return (+p[0]) * 3600 + (+p[1]) * 60 + (+p[2]) }
    // first problem as {row, msg}, or null
    function validate() {
        const url = urlIn.text.trim()
        if (url === "") return { row: 0, msg: "URL is required" }
        if (!/^https?:\/\/\S+$/.test(url)) return { row: 0, msg: "URL must start with http:// or https://" }
        const names = ["From", "To"], vals = []
        for (let i = 0; i < 2; i++) {
            const t = i === 0 ? startIn : endIn, v = timeVal(t)
            if (v === null) return { row: 3 + i, msg: names[i] + ": type all 6 digits (HH:MM:SS) or clear it" }
            if (v !== "" && (+v.slice(3, 5) > 59 || +v.slice(6, 8) > 59))
                return { row: 3 + i, msg: names[i] + ": minutes and seconds must be 00–59" }
            vals.push(v)
        }
        if (vals[0] !== "" && vals[1] !== "" && secs(vals[1]) <= secs(vals[0]))
            return { row: 4, msg: "To must be later than From" }
        if (nameIn.text.indexOf("/") >= 0) return { row: 5, msg: "Name can't contain /" }
        if (dirIn.text.trim() === "") return { row: 6, msg: "Folder is required" }
        return null
    }
    function review() {
        const er = validate()
        if (er) { errMsg = er.msg; row = er.row }
        else { errMsg = ""; state = "confirm" }
    }

    // ---- run ---------------------------------------------------------------
    function go() {
        dl.command = ["sh", "-c", "tail --pid=$PPID -n +1 -F \"$1\" 2>/dev/null", "sh", logPath]
        state = "run"
        startMs = Date.now()
        endMs = 0
        elapsed = 0
        Quickshell.execDetached({
            command: ["setsid", "-f", "ytdl-run", urlIn.text, types[typeIdx], qval, nameIn.text, dirIn.text, timeVal(startIn), timeVal(endIn)],
            environment: { "YTDL_LOG": logPath }
        })
        dl.running = true
    }
    readonly property string logPath: Quickshell.env("XDG_RUNTIME_DIR") + "/ytdl-" + Date.now() + ".log"
    property double startMs: 0
    property double endMs: 0
    property int elapsed: 0   // seconds, frozen once done/failed
    property string title: ""
    property string filePath: ""
    property string errText: ""
    property string cookieSite: ""
    property string cookiePath: ""
    property string cookieWhy: ""   // "expired" | "missing" when YouTube wants a (new) login
    function clock(ms) { return Qt.formatTime(new Date(ms), "HH:mm:ss") }
    function fmt(t) { const h = Math.floor(t / 3600), m = Math.floor(t % 3600 / 60), x = t % 60
        return (h ? h + ":" + (m < 10 ? "0" : "") : "") + m + ":" + (x < 10 ? "0" : "") + x }
    function host(u) { const m = /^https?:\/\/([^\/]+)/.exec(u.trim()); return m ? m[1].replace(/^www\./, "") : "" }
    Timer {
        interval: 500; repeat: true; running: root.state === "run"
        onTriggered: root.elapsed = Math.floor((Date.now() - root.startMs) / 1000)
    }
    property string state: "form"   // form | confirm | run | done | fail
    readonly property bool busy: state === "run" || state === "done" || state === "fail"
    property real pct: 0
    property string speed: ""
    property string eta: ""
    Process {
        id: dl
        stdout: SplitParser {
            onRead: l => {
                if (l.startsWith("PROG")) {
                    const f = l.split("|")
                    root.pct = parseFloat(f[1]) || 0
                    root.speed = (f[2] || "").trim()
                    root.eta = (f[3] || "").trim()
                } else if (l.startsWith("META|")) root.title = l.slice(5)
                else if (l.startsWith("FILE|")) root.filePath = l.slice(5)
                else if (l.startsWith("ERR|")) root.errText = l.slice(4)
                else if (l.startsWith("COOKIES|")) { const c = l.split("|"); root.cookieWhy = c[1]; root.cookieSite = c[2] || ""; root.cookiePath = c[3] || "" }
                else if (l === "DONE") { root.pct = 100; root.endMs = Date.now(); root.state = "done" }
                else if (l === "FAIL") { root.endMs = Date.now(); root.state = "fail" }
            }
        }
    }

    function openFile() { Quickshell.execDetached(["ytdl-open", filePath]); Qt.quit() }
    function openFolder() { Quickshell.execDetached(["ytdl-open", "--folder", filePath]); Qt.quit() }
    function cancelDl() { Quickshell.execDetached(["sh", "-c", "kill $(cat \"$1.pid\")", "sh", logPath]) }
    // keycap + label, used in every footer (clickable too: the mouse works even without keyboard focus)
    component Key: Item {
        id: kc
        property string k: ""
        property string t: ""
        property color hue: root.cMauve
        signal activated()
        implicitWidth: kr.implicitWidth
        implicitHeight: 20
        Row {
            id: kr
            spacing: 5
            Rectangle {
                height: 20; width: Math.max(20, kt.implicitWidth + 12); radius: 5
                color: root.cSurf; border.color: root.cSurf1; border.width: 1
                Text { id: kt; anchors.centerIn: parent; text: kc.k; color: kc.hue; font.family: root.fMono; font.pixelSize: 11; font.bold: true }
            }
            Text { anchors.verticalCenter: parent.verticalCenter; text: kc.t; color: root.cOver; font.family: root.fSans; font.pixelSize: 12 }
        }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: kc.activated() }
    }
    // small coloured stat chip
    component Chip: Rectangle {
        property string label: ""
        property string value: ""
        property color hue: root.cSky
        height: 26; width: cr.implicitWidth + 20; radius: 13
        color: Qt.rgba(hue.r, hue.g, hue.b, 0.13); border.color: Qt.rgba(hue.r, hue.g, hue.b, 0.45)
        Row { id: cr; anchors.centerIn: parent; spacing: 6
            Text { text: label; color: root.cOver; font.family: root.fSans; font.pixelSize: 11 }
            Text { text: value; color: hue; font.family: root.fMono; font.pixelSize: 12; font.bold: true }
        }
    }

    // A real toplevel (not a layer surface): niri can focus it, Mod+drag it and Alt-Tab to it.
    // Float/centre/no-border rule: ~/.config/niri/rules/windows.kdl (title "ytdl-popup").
    FloatingWindow {
        id: win
        title: "ytdl-popup"
        color: "transparent"
        visible: true
        implicitWidth: 640
        implicitHeight: col.implicitHeight + 38
        minimumSize: Qt.size(implicitWidth, implicitHeight)
        maximumSize: Qt.size(implicitWidth, implicitHeight)

        Rectangle {
            anchors.fill: parent
            radius: 0
            color: root.cBase
            border.color: root.state === "fail" ? root.cRed : root.state === "done" ? root.cGrn : root.cMauve
            border.width: 2

            Item {
                id: keys
                anchors.fill: parent
                focus: !root.insert
                Keys.onPressed: e => {
                    const k = e.key
                    if (root.state === "confirm") {
                        if (k === Qt.Key_Y || k === Qt.Key_Return || k === Qt.Key_Enter) root.go()
                        else if (k === Qt.Key_N || k === Qt.Key_Escape) root.state = "form"
                        else return
                        e.accepted = true
                        return
                    }
                    if (root.busy) {
                        if (k === Qt.Key_Escape || k === Qt.Key_Q) Qt.quit()
                        else if (k === Qt.Key_X && root.state === "run") root.cancelDl()
                        else if (k === Qt.Key_O && root.state === "done" && root.filePath) root.openFile()
                        else if (k === Qt.Key_F && root.state === "done" && root.filePath) root.openFolder()
                        else return
                        e.accepted = true
                        return
                    }
                    if (k === Qt.Key_J || k === Qt.Key_Down || (k === Qt.Key_Tab && !(e.modifiers & Qt.ShiftModifier))) root.row = Math.min(6, root.row + 1)
                    else if (k === Qt.Key_K || k === Qt.Key_Up || k === Qt.Key_Backtab) root.row = Math.max(0, root.row - 1)
                    else if (k === Qt.Key_H || k === Qt.Key_Left) root.cycle(-1)
                    else if (k === Qt.Key_L || k === Qt.Key_Right) root.cycle(1)
                    else if (k === Qt.Key_V) root.typeIdx = 0
                    else if (k === Qt.Key_A) root.typeIdx = 1
                    else if (k === Qt.Key_I) root.startEdit()
                    else if (k === Qt.Key_G) root.row = (e.modifiers & Qt.ShiftModifier) ? 6 : 0
                    else if (k === Qt.Key_Return || k === Qt.Key_Enter) root.review()
                    else if (k === Qt.Key_Escape || k === Qt.Key_Q) Qt.quit()
                    else return
                    e.accepted = true
                }
            }

            // mouse-closable, even when the keyboard never reached us
            Text {
                text: "󰅖"
                z: 5
                anchors { top: parent.top; right: parent.right; margins: 14 }
                color: closeMa.containsMouse ? root.cRed : root.cOver; font.family: root.fMono; font.pixelSize: 18
                MouseArea { id: closeMa; anchors.fill: parent; anchors.margins: -8; hoverEnabled: true; onClicked: Qt.quit() }
            }

            Column {
                id: col
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 22 }
                spacing: 8

                // ---------- header ----------
                Row {
                    spacing: 10
                    Text { text: "󰇚"; color: root.cMauve; font.family: root.fMono; font.pixelSize: 24; anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        text: root.state === "confirm" ? "Confirm download" : root.state === "done" ? "Saved" : root.state === "fail" ? "Download failed" : root.busy ? "Downloading" : "Download"
                        color: root.cMauve; font.family: root.fMono; font.pixelSize: 20; font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle {
                        visible: root.state === "form"
                        anchors.verticalCenter: parent.verticalCenter
                        height: 20; width: mode.implicitWidth + 16; radius: 10
                        color: root.insert ? Qt.rgba(0.65, 0.89, 0.63, 0.18) : Qt.rgba(0.54, 0.71, 0.98, 0.18)
                        Text { id: mode; anchors.centerIn: parent; text: root.insert ? "INSERT" : "NORMAL"
                            color: root.insert ? root.cGrn : root.cBlue; font.family: root.fMono; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1 }
                    }
                    Text {
                        visible: root.host(urlIn.text) !== ""
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.host(urlIn.text); color: root.cSky; font.family: root.fSans; font.pixelSize: 12; font.italic: true
                    }
                }

                // ---------- confirmation ----------
                Column {
                    visible: root.state === "confirm"
                    width: col.width; spacing: 7
                    Repeater {
                        model: [0, 1, 3, 5, 6]
                        Row {
                            required property int modelData
                            spacing: 12
                            readonly property string v: modelData === 0 ? urlIn.text.trim()
                                : modelData === 1 ? root.types[root.typeIdx] + " · " + root.qval
                                : modelData === 3 ? (root.timeVal(startIn) || "start") + "   →   " + (root.timeVal(endIn) || "end")
                                : modelData === 5 ? (nameIn.text || "(video title)") : dirIn.text.trim()
                            Text { width: 78; text: root.icons[modelData] + "  " + (modelData === 3 ? "Section" : root.labels[modelData]); color: root.hues[modelData]; font.family: root.fMono; font.pixelSize: 13; font.bold: true }
                            Text { width: col.width - 90; text: v; color: root.cText; font.family: root.fSans; font.pixelSize: 14; elide: Text.ElideMiddle }
                        }
                    }
                    Item { width: 1; height: 4 }
                    Row {
                        spacing: 18
                        Key { k: "y"; t: "yes, download"; hue: root.cGrn; onActivated: root.go() }
                        Key { k: "⏎"; t: ""; hue: root.cGrn }
                        Key { k: "n"; t: "back"; hue: root.cRed; onActivated: root.state = "form" }
                        Key { k: "esc"; t: ""; hue: root.cRed }
                    }
                }

                // ---------- progress / result ----------
                Column {
                    visible: root.busy
                    width: col.width; spacing: 10
                    Text {
                        width: parent.width; elide: Text.ElideRight
                        text: root.title || root.host(urlIn.text)
                        color: root.cText; font.family: root.fSans; font.pixelSize: 15; font.bold: true
                    }
                    Text {
                        visible: root.state === "fail" && root.errText !== "" && root.cookieWhy === ""
                        width: parent.width; wrapMode: Text.Wrap; maximumLineCount: 3; elide: Text.ElideRight
                        text: root.errText; color: root.cRed; font.family: root.fSans; font.pixelSize: 13
                    }
                    // cookies expired/missing: step-by-step fix
                    Rectangle {
                        visible: root.state === "fail" && root.cookieWhy !== ""
                        width: parent.width; height: ck.implicitHeight + 20; radius: 9
                        color: Qt.rgba(0.98, 0.89, 0.69, 0.10); border.color: Qt.rgba(0.98, 0.89, 0.69, 0.55)
                        Column {
                            id: ck
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 14 }
                            spacing: 5
                            Text { text: "󰀪  Update your " + root.cookieSite + " cookies (" + root.cookieWhy + ")"; color: root.cYel; font.family: root.fSans; font.pixelSize: 13; font.bold: true }
                            Repeater {
                                model: [
                                    "Helium → private window (Ctrl+Shift+N) → log in to " + root.cookieSite,
                                    "On that " + root.cookieSite + " tab, click the cookie-export extension → Export",
                                    "Save as " + root.cookiePath + ", then chmod 600 it",
                                    "Close the private window (a closed session keeps working for weeks)",
                                    "Retry the download — no restart needed"
                                ]
                                Row {
                                    required property int index
                                    required property string modelData
                                    spacing: 8
                                    Text { text: (index + 1); width: 14; color: root.cYel; font.family: root.fMono; font.pixelSize: 12; font.bold: true }
                                    Text { text: modelData; width: ck.width - 26; wrapMode: Text.Wrap; color: root.cText; font.family: root.fSans; font.pixelSize: 12 }
                                }
                            }
                            Text { text: "Extension missing or old? chrome://extensions → Load unpacked → ~/.local/share/mpvtube-cookies (reload it once; it asks permission per site)"; width: ck.width; wrapMode: Text.Wrap; color: root.cOver; font.family: root.fSans; font.pixelSize: 11; font.italic: true }
                        }
                    }
                    Row {
                        spacing: 12
                        Text {
                            text: root.state === "fail" ? "󰀪" : root.state === "done" ? "󰄬" : Math.round(root.pct) + "%"
                            color: root.state === "fail" ? root.cRed : root.cGrn
                            font.family: root.fMono; font.pixelSize: 34; font.bold: true
                        }
                        Text {
                            anchors.bottom: parent.bottom; anchors.bottomMargin: 6
                            text: root.state === "done" ? "done in " + root.fmt(root.elapsed) : root.state === "fail" ? "failed after " + root.fmt(root.elapsed) : "running " + root.fmt(root.elapsed)
                            color: root.cSub; font.family: root.fSans; font.pixelSize: 13
                        }
                    }
                    Rectangle {
                        width: parent.width; height: 12; radius: 6; color: root.cSurf
                        Rectangle {
                            height: parent.height; radius: 6
                            width: parent.width * Math.min(1, root.pct / 100)
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0; color: root.state === "fail" ? "#eba0ac" : root.cGrn }
                                GradientStop { position: 1; color: root.state === "fail" ? root.cRed : root.cTeal }
                            }
                            Behavior on width { NumberAnimation { duration: 150 } }
                        }
                    }
                    Row {
                        spacing: 8
                        visible: root.state === "run"
                        Chip { label: "speed"; value: root.speed || "–"; hue: root.cSky }
                        Chip { label: "eta"; value: root.eta || "–"; hue: root.cPeach }
                        Chip { label: "elapsed"; value: root.fmt(root.elapsed); hue: root.cYel }
                    }
                    Text {
                        text: "started " + root.clock(root.startMs) + (root.endMs ? "   ·   ended " + root.clock(root.endMs) : "")
                        color: root.cOver; font.family: root.fMono; font.pixelSize: 12
                    }
                    Row {
                        spacing: 16
                        Key { visible: root.state === "run"; k: "x"; t: "cancel"; hue: root.cRed; onActivated: root.cancelDl() }
                        Key { visible: root.state === "run"; k: "esc"; t: "hide, keeps going"; hue: root.cMauve; onActivated: Qt.quit() }
                        Key { visible: root.state === "done"; k: "o"; t: "play"; hue: root.cGrn; onActivated: root.openFile() }
                        Key { visible: root.state === "done"; k: "f"; t: "folder"; hue: root.cTeal; onActivated: root.openFolder() }
                        Key { visible: root.state !== "run"; k: "esc"; t: "close"; hue: root.cMauve; onActivated: Qt.quit() }
                        Text { visible: root.state === "run"; text: "click window to focus"; color: root.cOver; font.family: root.fSans; font.pixelSize: 11; font.italic: true; anchors.verticalCenter: parent.verticalCenter }
                    }
                }

                // ---------- form rows (kept alive in every state: go() reads them) ----------
                Repeater {
                    model: 7
                    Rectangle {
                        id: rowItem
                        required property int index
                        readonly property bool sel: root.row === index
                        readonly property color hue: root.hues[index]
                        visible: root.state === "form"
                        width: col.width; height: 42; radius: 10
                        color: sel ? root.cSurf : "transparent"
                        border.color: sel ? Qt.rgba(hue.r, hue.g, hue.b, 0.7) : "transparent"
                        Behavior on color { ColorAnimation { duration: 90 } }
                        Rectangle { visible: rowItem.sel; width: 3; height: parent.height - 16; radius: 2; color: rowItem.hue; x: 6; anchors.verticalCenter: parent.verticalCenter }
                        Text {
                            x: 18; anchors.verticalCenter: parent.verticalCenter; width: 92
                            text: root.icons[index] + "  " + root.labels[index]
                            color: rowItem.sel ? rowItem.hue : Qt.darker(rowItem.hue, 1.5)
                            font.family: root.fMono; font.pixelSize: 13; font.bold: true
                        }
                        MouseArea { anchors.fill: parent; z: -1; onClicked: root.row = rowItem.index }

                        // Type: video | audio pills
                        Row {
                            visible: index === 1
                            x: 120; anchors.verticalCenter: parent.verticalCenter; spacing: 8
                            Repeater {
                                model: root.types
                                Rectangle {
                                    required property int index
                                    required property string modelData
                                    readonly property bool on: root.typeIdx === index
                                    height: 26; width: pl.implicitWidth + 24; radius: 13
                                    color: on ? rowItem.hue : root.cMantle
                                    border.color: on ? rowItem.hue : root.cSurf1
                                    Text { id: pl; anchors.centerIn: parent; text: modelData; color: on ? root.cBase : root.cSub; font.family: root.fMono; font.pixelSize: 12; font.bold: on }
                                    MouseArea { anchors.fill: parent; onClicked: { root.typeIdx = index; root.row = 1 } }
                                }
                            }
                        }
                        // Quality pills
                        Row {
                            visible: index === 2
                            x: 120; anchors.verticalCenter: parent.verticalCenter; spacing: 6
                            Repeater {
                                model: root.choices
                                Rectangle {
                                    required property int index
                                    required property string modelData
                                    readonly property bool on: (root.typeIdx === 0 ? root.vq : root.aq) === index
                                    height: 26; width: ql.implicitWidth + 18; radius: 13
                                    color: on ? rowItem.hue : root.cMantle
                                    border.color: on ? rowItem.hue : root.cSurf1
                                    Text { id: ql; anchors.centerIn: parent; text: modelData; color: on ? root.cBase : root.cSub; font.family: root.fMono; font.pixelSize: 12; font.bold: on }
                                    MouseArea { anchors.fill: parent; onClicked: { if (root.typeIdx === 0) root.vq = index; else root.aq = index; root.row = 2 } }
                                }
                            }
                        }

                        // time rows get an OTP-style box
                        Rectangle {
                            visible: index === 3 || index === 4
                            x: 118; width: 128; height: 30; radius: 7
                            anchors.verticalCenter: parent.verticalCenter
                            color: root.cMantle
                            border.color: (sel && root.insert) ? rowItem.hue : root.cSurf1
                        }
                        // text rows
                        TextInput {
                            id: ti
                            visible: index === 0 || index >= 3
                            inputMask: (index === 3 || index === 4) ? "00:00:00;_" : ""
                            onTextChanged: root.errMsg = ""
                            x: (index === 3 || index === 4) ? 130 : 120
                            width: (index === 3 || index === 4) ? 110 : parent.width - 134
                            anchors.verticalCenter: parent.verticalCenter
                            clip: true
                            color: (index === 3 || index === 4) ? rowItem.hue : root.cText
                            font.family: (index === 3 || index === 4) ? root.fMono : root.fSans
                            font.pixelSize: (index === 3 || index === 4) ? 16 : 14
                            font.bold: index === 3 || index === 4
                            font.letterSpacing: (index === 3 || index === 4) ? 2 : 0
                            selectionColor: rowItem.hue; selectedTextColor: root.cBase
                            text: index === 0 ? Quickshell.env("YTDL_URL") : index === 6 ? Quickshell.env("YTDL_DIR") : ""
                            Component.onCompleted: {
                                if (index === 0) urlIn = ti
                                else if (index === 3) startIn = ti
                                else if (index === 4) endIn = ti
                                else if (index === 5) nameIn = ti
                                else if (index === 6) dirIn = ti
                            }
                            Keys.onPressed: e => {
                                if (e.key === Qt.Key_Escape || e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                                    root.insert = false
                                    keys.forceActiveFocus()
                                    e.accepted = true
                                }
                            }
                            Text {
                                visible: !ti.text && index === 5
                                text: "(video title)"; color: root.cOver; font.family: root.fSans; font.pixelSize: 14; font.italic: true
                            }
                        }
                        Text {
                            visible: index === 3 || index === 4
                            x: 262; anchors.verticalCenter: parent.verticalCenter
                            text: index === 3 ? "HH:MM:SS · blank = from start" : "HH:MM:SS · blank = to end"
                            color: root.cOver; font.family: root.fSans; font.pixelSize: 11; font.italic: true
                        }
                    }
                }

                // ---------- error callout ----------
                Rectangle {
                    visible: root.state === "form" && root.errMsg !== ""
                    width: col.width; height: et.implicitHeight + 16; radius: 9
                    color: Qt.rgba(0.95, 0.55, 0.66, 0.12); border.color: Qt.rgba(0.95, 0.55, 0.66, 0.6)
                    Text {
                        id: et
                        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 12 }
                        wrapMode: Text.Wrap
                        text: "󰀪  " + root.errMsg
                        color: root.cRed; font.family: root.fSans; font.pixelSize: 13; font.bold: true
                    }
                }

                // ---------- form footer ----------
                Flow {
                    visible: root.state === "form"
                    width: col.width; spacing: 14
                    Key { k: "j"; t: ""; hue: root.cBlue }
                    Key { k: "k"; t: "move"; hue: root.cBlue }
                    Key { k: "h"; t: ""; hue: root.cGrn }
                    Key { k: "l"; t: "change"; hue: root.cGrn }
                    Key { k: "v"; t: ""; hue: root.cMauve }
                    Key { k: "a"; t: "video/audio"; hue: root.cMauve }
                    Key { k: "i"; t: "edit"; hue: root.cYel }
                    Key { k: "⏎"; t: "review"; hue: root.cGrn; onActivated: root.review() }
                    Key { k: "esc"; t: "quit"; hue: root.cRed; onActivated: Qt.quit() }
                }
                Item { width: 1; height: 2 }
            }
        }
    }

    property var urlIn
    property var startIn
    property var endIn
    property var nameIn
    property var dirIn
}
