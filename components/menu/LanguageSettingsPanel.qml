import QtQuick 2.15
import ".."

// Language settings – inline XMB drill-down panel
Item {
    id: root
    anchors.fill: parent
    visible: false
    opacity: 0

    // Settings
    property string currentLang: "it"  // "it" or "en"
    readonly property var availableLangs: ["it", "en"]
    readonly property var langLabels: ["Italiano", "English"]

    // Layout
    readonly property real _bigIconSz:  Math.round(height * 0.100)
    readonly property real _smIconSz:   Math.round(height * 0.036)
    readonly property real _curIconSz:  Math.round(height * 0.048)
    readonly property real _contentX:   Math.round(width * 0.195)
    readonly property real _headerY:    Math.round(height * 0.125)
    readonly property real _listY:      _headerY + Math.round(height * 0.110)
    readonly property real _rowH:       Math.round(height * 0.048)
    readonly property real _fTitle:     Math.max(14, Math.round(height * 0.025))
    readonly property real _fSub:       Math.max(10, Math.round(height * 0.016))
    readonly property real _fItem:      Math.max(12, Math.round(height * 0.021))

    signal settingsChanged(string lang)
    signal closed()

    property real _slideOffset: 0

    // Block touch events
    MouseArea { anchors.fill: parent; z: -1 }

    // LARGE ICON

    Rectangle {
        x: Math.round(root.width * 0.055)
        y: Math.round(root.height * 0.055)
        width: root._bigIconSz
        height: root._bigIconSz
        radius: width * 0.24
        color: "#12ffffff"

        Rectangle {
            anchors.fill: parent; radius: parent.radius
            color: "transparent"; border.color: "#0affffff"; border.width: 1
        }

        Canvas {
            anchors.centerIn: parent
            width: Math.round(parent.width * 0.42)
            height: width
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                var w = width, h = height;
                ctx.strokeStyle = "#8aadcc"; ctx.lineWidth = 1.5;
                // Globe icon
                var cx = w * 0.5, cy = h * 0.5, r = w * 0.42;
                ctx.beginPath(); ctx.arc(cx, cy, r, 0, Math.PI * 2); ctx.stroke();
                // Horizontal line
                ctx.beginPath(); ctx.moveTo(cx - r, cy); ctx.lineTo(cx + r, cy); ctx.stroke();
                // Vertical ellipse
                ctx.beginPath(); ctx.ellipse(cx - r * 0.35, cy - r, r * 0.7, r * 2); ctx.stroke();
            }
        }
    }

    // BREADCRUMB

    Row {
        id: breadcrumb
        x: root._contentX + root._slideOffset
        y: root._headerY
        spacing: Math.round(root.width * 0.012)

        Rectangle {
            width: root._smIconSz; height: width
            radius: width * 0.5; color: "#10ffffff"
            anchors.verticalCenter: parent.verticalCenter

            Canvas {
                anchors.centerIn: parent
                width: Math.round(parent.width * 0.50); height: width
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    var w = width, h = height, cx = w / 2, cy = h / 2;
                    ctx.fillStyle = "#5a7a94";
                    var outerR = w * 0.45, innerR = outerR * 0.65, teeth = 6, toothH = outerR * 0.3;
                    ctx.beginPath();
                    for (var t = 0; t < teeth; t++) {
                        var a1 = (t / teeth) * Math.PI * 2 - Math.PI / 2;
                        var a2 = ((t + 0.35) / teeth) * Math.PI * 2 - Math.PI / 2;
                        var a3 = ((t + 0.65) / teeth) * Math.PI * 2 - Math.PI / 2;
                        var a4 = ((t + 1) / teeth) * Math.PI * 2 - Math.PI / 2;
                        if (t === 0) ctx.moveTo(cx + (outerR + toothH) * Math.cos(a1), cy + (outerR + toothH) * Math.sin(a1));
                        ctx.lineTo(cx + (outerR + toothH) * Math.cos(a2), cy + (outerR + toothH) * Math.sin(a2));
                        ctx.lineTo(cx + outerR * Math.cos(a3), cy + outerR * Math.sin(a3));
                        ctx.lineTo(cx + outerR * Math.cos(a4), cy + outerR * Math.sin(a4));
                        ctx.lineTo(cx + (outerR + toothH) * Math.cos(a4), cy + (outerR + toothH) * Math.sin(a4));
                    }
                    ctx.closePath(); ctx.fill();
                    ctx.globalCompositeOperation = "destination-out";
                    ctx.beginPath(); ctx.arc(cx, cy, innerR, 0, Math.PI * 2); ctx.fill();
                    ctx.globalCompositeOperation = "source-over";
                }
            }
        }

        Text {
            text: "\u25C2"
            font.pixelSize: Math.round(root.height * 0.030)
            color: "#506a80"
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: root._curIconSz; height: width
            radius: width * 0.24; color: "#18ffffff"
            anchors.verticalCenter: parent.verticalCenter

            Canvas {
                anchors.centerIn: parent
                width: Math.round(parent.width * 0.48); height: width
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    var w = width, h = height;
                    ctx.strokeStyle = "#a0c0dd"; ctx.lineWidth = 1.2;
                    // Small globe
                    var cx = w * 0.5, cy = h * 0.5, r = w * 0.4;
                    ctx.beginPath(); ctx.arc(cx, cy, r, 0, Math.PI * 2); ctx.stroke();
                    ctx.beginPath(); ctx.moveTo(cx - r, cy); ctx.lineTo(cx + r, cy); ctx.stroke();
                    ctx.beginPath(); ctx.ellipse(cx - r * 0.35, cy - r, r * 0.7, r * 2); ctx.stroke();
                }
            }
        }

        Item { width: Math.round(root.width * 0.008); height: 1 }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Text {
                text: root.currentLang === "it" ? "Lingua" : "Language"
                font.pixelSize: root._fTitle; font.bold: true; color: "#d0e0f0"
            }
            Text {
                text: root.currentLang === "it" ? "Lingua dell'interfaccia" : "Interface language"
                font.pixelSize: root._fSub; color: "#5878a0"
            }
        }
    }

    MouseArea {
        x: breadcrumb.x
        y: breadcrumb.y - Math.round(root.height * 0.01)
        width: Math.min(breadcrumb.width, root.width * 0.35)
        height: breadcrumb.height + Math.round(root.height * 0.02)
        onClicked: root.closePanel()
    }

    Rectangle {
        x: root._contentX + root._slideOffset
        y: root._headerY + Math.round(root.height * 0.068)
        width: root.width * 0.54; height: 1; color: "#0cffffff"
    }

    // CONTENT ROW

    Item {
        id: contentArea
        x: root._contentX + root._slideOffset
        y: root._listY
        width: root.width * 0.58
        height: root.height - y - Math.round(root.height * 0.060)
        clip: true

        Item {
            id: langRow
            y: 0; width: parent.width; height: root._rowH

            Rectangle {
                anchors.fill: parent; radius: 6
                color: "#0affffff"
                border.color: "#1a3860"
                border.width: 1
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: Math.round(root.width * 0.012)

                Rectangle {
                    width: root._smIconSz; height: width
                    radius: width * 0.24; color: "#0cffffff"
                    anchors.verticalCenter: parent.verticalCenter

                    Canvas {
                        anchors.centerIn: parent
                        width: Math.round(parent.width * 0.55); height: width
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            var w = width, h = height;
                            ctx.strokeStyle = "#a0c0dd"; ctx.lineWidth = 1.2;
                            // "A" text icon for language
                            ctx.font = "bold " + Math.round(h * 0.65) + "px sans-serif";
                            ctx.textAlign = "center"; ctx.textBaseline = "middle";
                            ctx.fillStyle = "#a0c0dd";
                            ctx.fillText("A", w * 0.5, h * 0.5);
                        }
                        onVisibleChanged: if (visible) requestPaint()
                    }
                }

                Text {
                    text: root.currentLang === "it" ? "Lingua" : "Language"
                    font.pixelSize: root._fItem
                    color: "#98b0c8"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: Math.round(root.width * 0.015)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Math.round(root.width * 0.008)

                Text {
                    text: "\u25C2"
                    font.pixelSize: root._fItem
                    color: "#5098d8"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: root.langLabels[root.availableLangs.indexOf(root.currentLang)]
                    font.pixelSize: root._fItem
                    font.bold: true
                    color: "#d0e0f0"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "\u25B8"
                    font.pixelSize: root._fItem
                    color: "#5098d8"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    // HINT BAR

    Text {
        id: hintText
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Math.round(root.height * 0.025)
        anchors.right: parent.right
        anchors.rightMargin: Math.round(root.width * 0.025)
        text: root.currentLang === "it"
            ? "←→ Scegli lingua  ·  B Indietro"
            : "←→ Choose language  ·  B Back"
        font.pixelSize: Math.max(11, Math.round(root.height * 0.016))
        color: "#ffffff"
        opacity: 1.0
    }

    // ANIMATIONS

    ParallelAnimation {
        id: entranceAnim
        NumberAnimation { target: root; property: "opacity"; from: 0; to: 1; duration: 300; easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "_slideOffset"; from: root.width * 0.05; to: 0; duration: 350; easing.type: Easing.OutCubic }
    }

    SequentialAnimation {
        id: exitAnim
        ParallelAnimation {
            NumberAnimation { target: root; property: "opacity"; to: 0; duration: 250; easing.type: Easing.InCubic }
            NumberAnimation { target: root; property: "_slideOffset"; to: root.width * 0.05; duration: 250; easing.type: Easing.InCubic }
        }
        ScriptAction { script: { root.visible = false; root.closed(); } }
    }

    // KEYBOARD

    Keys.onPressed: {
        event.accepted = true;

        var isBack   = (event.key === Qt.Key_Escape || event.key === Qt.Key_Back ||
                        event.key === Qt.Key_Backspace || event.key === 1048577);
        var isLeft   = (event.key === Qt.Key_Left);
        var isRight  = (event.key === Qt.Key_Right);

        if (isLeft || isRight) {
            var idx = root.availableLangs.indexOf(root.currentLang);
            if (isRight) idx = (idx + 1) % root.availableLangs.length;
            else idx = (idx - 1 + root.availableLangs.length) % root.availableLangs.length;
            root.currentLang = root.availableLangs[idx];
            root.saveSettings();
        } else if (isBack) {
            root.closePanel();
        } else {
            event.accepted = false;
        }
    }

    // FUNCTIONS

    function openPanel() {
        loadSettings();
        visible = true;
        opacity = 0;
        _slideOffset = 0;
        forceActiveFocus();
        entranceAnim.start();
    }

    function closePanel() {
        if (exitAnim.running) return;
        saveSettings();
        exitAnim.start();
    }

    function loadSettings() {
        var lang = api.memory.get("ui_language");
        if (lang && root.availableLangs.indexOf(lang) >= 0) {
            root.currentLang = lang;
        } else {
            root.currentLang = "en";
        }
    }

    function saveSettings() {
        api.memory.set("ui_language", root.currentLang);
        root.settingsChanged(root.currentLang);
    }
}
