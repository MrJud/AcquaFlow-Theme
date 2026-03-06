import QtQuick 2.15
import ".."
import "../../components/config/Translations.js" as T

// Clock settings – inline XMB drill-down panel (PS3 style)
Item {
    id: root
    anchors.fill: parent
    visible: false
    opacity: 0

    // Settings
    property bool use24h: true  // true=24h, false=12h
    property int  fontIndex: 0  // 0..4 index into fontFiles
    property int  colorIndex: 1  // 0..N index into colorPalette
    property bool fillMode: true  // false=outline, true=filled
    property bool rainbow: false  // rainbow animation (outline only)

    // Language
    property string lang: "it"

    // Rainbow animated colors (matches RetroAchievements hub panel borders — 3 offset phases)
    property color _borderAnim: "#58d8f0"
    SequentialAnimation {
        running: root.rainbow && root.visible
        loops: Animation.Infinite
        ColorAnimation { target: root; property: "_borderAnim"; to: "#70b0f8"; duration: 1800; easing.type: Easing.InOutSine   }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#4060f0"; duration: 1400; easing.type: Easing.InOutCubic  }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#2888f0"; duration: 1600; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#18b0d8"; duration: 2000; easing.type: Easing.InOutSine   }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#18c8a8"; duration: 1200; easing.type: Easing.OutCubic    }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#20a0e0"; duration: 1000; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#80a0f0"; duration: 1800; easing.type: Easing.InOutCubic  }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#f0a0c8"; duration: 2200; easing.type: Easing.InOutSine   }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#d898e0"; duration: 1500; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#a8d0f0"; duration: 1000; easing.type: Easing.OutCubic    }
        ColorAnimation { target: root; property: "_borderAnim"; to: "#58d8f0"; duration: 1800; easing.type: Easing.InOutSine   }
    }
    property color _borderAnim2: "#2090e0"
    SequentialAnimation {
        running: root.rainbow && root.visible
        loops: Animation.Infinite
        ColorAnimation { target: root; property: "_borderAnim2"; to: "#18c8a8"; duration: 2200; easing.type: Easing.InOutSine   }
        ColorAnimation { target: root; property: "_borderAnim2"; to: "#50d8f0"; duration: 1600; easing.type: Easing.InOutCubic  }
        ColorAnimation { target: root; property: "_borderAnim2"; to: "#d898e0"; duration: 2000; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: root; property: "_borderAnim2"; to: "#f0a0c8"; duration: 1400; easing.type: Easing.OutCubic    }
        ColorAnimation { target: root; property: "_borderAnim2"; to: "#80a0f0"; duration: 1800; easing.type: Easing.InOutSine   }
        ColorAnimation { target: root; property: "_borderAnim2"; to: "#38b8d8"; duration: 1200; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: root; property: "_borderAnim2"; to: "#2090e0"; duration: 1600; easing.type: Easing.InOutCubic  }
    }
    property color _borderAnim3: "#20b8a0"
    SequentialAnimation {
        running: root.rainbow && root.visible
        loops: Animation.Infinite
        ColorAnimation { target: root; property: "_borderAnim3"; to: "#a8d0f0"; duration: 1800; easing.type: Easing.InOutCubic  }
        ColorAnimation { target: root; property: "_borderAnim3"; to: "#e08050"; duration: 2400; easing.type: Easing.InOutSine   }
        ColorAnimation { target: root; property: "_borderAnim3"; to: "#40d8d0"; duration: 1600; easing.type: Easing.InOutQuad   }
        ColorAnimation { target: root; property: "_borderAnim3"; to: "#70b0f8"; duration: 2000; easing.type: Easing.OutCubic    }
        ColorAnimation { target: root; property: "_borderAnim3"; to: "#f0a0c8"; duration: 1400; easing.type: Easing.InOutSine   }
        ColorAnimation { target: root; property: "_borderAnim3"; to: "#20b8a0"; duration: 1800; easing.type: Easing.InOutQuad   }
    }
    property real _borderAngle: 0
    NumberAnimation {
        running: root.rainbow && root.visible
        target: root; property: "_borderAngle"
        loops: Animation.Infinite
        from: 0; to: 360; duration: 10000
    }

    property int focusIndex: 0  // 0=format, 1=font, 2=color, 3=fill, 4=rainbow
    property bool fontExpanded: false
    property int  fontPreviewIdx: 0
    property bool colorExpanded: false
    property int  colorPreviewIdx: 0

    // 10 Clock Fonts
    readonly property var fontFiles: [
        "Electrolize.ttf",
        "Rajdhani.ttf",
        "Audiowide.ttf",
        "Quantico.ttf",
        "Michroma.ttf",
        "ChakraPetch.ttf",
        "Bungee.ttf",
        "BlackOpsOne.ttf",
        "ShareTech.ttf",
        "VT323.ttf"
    ]
    readonly property var fontNames: [
        "Electrolize",
        "Rajdhani",
        "Audiowide",
        "Quantico",
        "Michroma",
        "Chakra Petch",
        "Bungee",
        "Black Ops One",
        "Share Tech",
        "VT323"
    ]

    // Color palette
    readonly property var colorPalette: [
        { name: "Teal",       outline: "#1ABC9C", fill: "#33FFFFFF" },
        { name: "Bianco",     outline: "#FFFFFF", fill: "#33FFFFFF" },
        { name: "Azzurro",    outline: "#5DADE2", fill: "#33FFFFFF" },
        { name: "Viola",      outline: "#A569BD", fill: "#33FFFFFF" },
        { name: "Rosa",       outline: "#EC7063", fill: "#33FFFFFF" },
        { name: "Arancio",    outline: "#F39C12", fill: "#33FFFFFF" },
        { name: "Verde",      outline: "#2ECC71", fill: "#33FFFFFF" },
        { name: "Rosso",      outline: "#E74C3C", fill: "#33FFFFFF" },
        { name: "Oro",        outline: "#F1C40F", fill: "#33FFFFFF" },
        { name: "Ciano",      outline: "#00BCD4", fill: "#33FFFFFF" }
    ]

    // Font Loaders
    FontLoader { id: font0; source: "../../assets/fonts/watch/Electrolize.ttf" }
    FontLoader { id: font1; source: "../../assets/fonts/watch/Rajdhani.ttf" }
    FontLoader { id: font2; source: "../../assets/fonts/watch/Audiowide.ttf" }
    FontLoader { id: font3; source: "../../assets/fonts/watch/Quantico.ttf" }
    FontLoader { id: font4; source: "../../assets/fonts/watch/Michroma.ttf" }
    FontLoader { id: font5; source: "../../assets/fonts/watch/ChakraPetch.ttf" }
    FontLoader { id: font6; source: "../../assets/fonts/watch/Bungee.ttf" }
    FontLoader { id: font7; source: "../../assets/fonts/watch/BlackOpsOne.ttf" }
    FontLoader { id: font8; source: "../../assets/fonts/watch/ShareTech.ttf" }
    FontLoader { id: font9; source: "../../assets/fonts/watch/VT323.ttf" }

    function getFontFamily(idx) {
        switch (idx) {
            case 0: return font0.name;
            case 1: return font1.name;
            case 2: return font2.name;
            case 3: return font3.name;
            case 4: return font4.name;
            case 5: return font5.name;
            case 6: return font6.name;
            case 7: return font7.name;
            case 8: return font8.name;
            case 9: return font9.name;
        }
        return font0.name;
    }

    // Layout (XMB metrics)
    readonly property real _contentX:  Math.round(width * 0.195)
    readonly property real _headerY:   Math.round(height * 0.125)
    readonly property real _listY:     _headerY + Math.round(height * 0.110)
    readonly property real _bigIconSz: Math.round(height * 0.100)
    readonly property real _smIconSz:  Math.round(height * 0.036)
    readonly property real _curIconSz: Math.round(height * 0.048)
    readonly property real _rowH:      Math.round(height * 0.048)
    readonly property real _fTitle:    Math.max(14, Math.round(height * 0.025))
    readonly property real _fSub:      Math.max(10, Math.round(height * 0.016))
    readonly property real _fItem:     Math.max(12, Math.round(height * 0.021))

    signal settingsChanged(bool use24h, int fontIndex, int colorIndex)
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
                var w = width, h = height, cx = w / 2, cy = h / 2;
                ctx.strokeStyle = "#8aadcc"; ctx.lineWidth = 1.5;
                // Clock circle
                ctx.beginPath();
                ctx.arc(cx, cy, w * 0.44, 0, Math.PI * 2);
                ctx.stroke();
                // Hour hand
                ctx.beginPath();
                ctx.moveTo(cx, cy);
                ctx.lineTo(cx - w * 0.06, cy - h * 0.22);
                ctx.stroke();
                // Minute hand
                ctx.beginPath();
                ctx.moveTo(cx, cy);
                ctx.lineTo(cx + w * 0.18, cy - h * 0.12);
                ctx.stroke();
                // Center dot
                ctx.beginPath();
                ctx.arc(cx, cy, w * 0.04, 0, Math.PI * 2);
                ctx.fillStyle = "#8aadcc"; ctx.fill();
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
                    var w = width, h = height, cx = w / 2, cy = h / 2;
                    ctx.strokeStyle = "#a0c0dd"; ctx.lineWidth = 1.2;
                    ctx.beginPath(); ctx.arc(cx, cy, w * 0.44, 0, Math.PI * 2); ctx.stroke();
                    ctx.beginPath(); ctx.moveTo(cx, cy); ctx.lineTo(cx - w * 0.06, cy - h * 0.22); ctx.stroke();
                    ctx.beginPath(); ctx.moveTo(cx, cy); ctx.lineTo(cx + w * 0.18, cy - h * 0.12); ctx.stroke();
                }
            }
        }

        Item { width: Math.round(root.width * 0.008); height: 1 }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Text { text: T.t("clock_title", root.lang); font.pixelSize: root._fTitle; font.bold: true; color: "#d0e0f0" }
            Text { text: T.t("clock_subtitle", root.lang); font.pixelSize: root._fSub; color: "#5878a0" }
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

    // CONTENT AREA

    Item {
        id: contentArea
        x: root._contentX + root._slideOffset
        y: root._listY
        width: root.width * 0.58
        height: root.height - y - Math.round(root.height * 0.060)
        clip: true

        // TIME FORMAT (24h / 12h toggle)
        Item {
            id: formatRow
            y: 0; width: parent.width; height: root._rowH

            Rectangle {
                anchors.fill: parent; radius: 6
                color: root.focusIndex === 0 ? "#0affffff" : "transparent"
                border.color: root.focusIndex === 0 ? "#1a3860" : "transparent"
                border.width: root.focusIndex === 0 ? 1 : 0
                Behavior on color { ColorAnimation { duration: 180 } }
                Behavior on border.color { ColorAnimation { duration: 180 } }
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
                            var ctx = getContext("2d"); ctx.reset();
                            var w = width, h = height;
                            ctx.strokeStyle = "#78a8d0"; ctx.lineWidth = 1.0;
                            // "24" text
                            ctx.font = "bold " + Math.round(h * 0.55) + "px sans-serif";
                            ctx.fillStyle = "#78a8d0";
                            ctx.textAlign = "center"; ctx.textBaseline = "middle";
                            ctx.fillText(root.use24h ? "24" : "12", w / 2, h / 2);
                        }
                        property bool _dep: root.use24h
                        on_DepChanged: requestPaint()
                    }
                }

                Text {
                    text: T.t("clock_format", root.lang)
                    font.pixelSize: root._fItem
                    color: "#98b0c8"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Toggle + label
            Row {
                anchors.right: parent.right
                anchors.rightMargin: Math.round(root.width * 0.015)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Math.round(root.width * 0.008)

                Text {
                    text: root.use24h ? T.t("clock_24h", root.lang) : T.t("clock_12h", root.lang)
                    font.pixelSize: root._fSub
                    color: "#5098d8"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: Math.round(root.width * 0.044); height: Math.round(root.height * 0.024)
                    radius: height / 2
                    color: root.use24h ? "#2060a0" : "#1a2840"
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Rectangle {
                        width: parent.height - 4; height: width; radius: width / 2; color: "#d0e0f0"
                        x: root.use24h ? parent.width - width - 2 : 2
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: { root.use24h = !root.use24h; root.saveSettings(); }
            }
        }

        // Separator
        Rectangle {
            id: sep1
            y: formatRow.y + formatRow.height + Math.round(root.height * 0.024)
            width: parent.width; height: 1; color: "#08ffffff"
        }

        // FONT OROLOGIO
        Text {
            id: fontLabel
            y: sep1.y + sep1.height + Math.round(root.height * 0.016)
            text: T.t("clock_font_section", root.lang)
            font.pixelSize: root._fItem; font.bold: true; color: "#7090b0"
        }

        Item {
            id: fontRow
            y: fontLabel.y + fontLabel.height + Math.round(root.height * 0.008)
            width: parent.width; height: root._rowH

            Rectangle {
                anchors.fill: parent; radius: 6
                color: root.focusIndex === 1 ? "#0affffff" : "transparent"
                border.color: root.focusIndex === 1 ? "#1a3860" : "transparent"
                border.width: root.focusIndex === 1 ? 1 : 0
                Behavior on color { ColorAnimation { duration: 180 } }
                Behavior on border.color { ColorAnimation { duration: 180 } }
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
                            var ctx = getContext("2d"); ctx.reset();
                            var w = width, h = height;
                            ctx.strokeStyle = "#78a8d0"; ctx.lineWidth = 1.0;
                            // "A" letter icon for font
                            ctx.font = "bold italic " + Math.round(h * 0.65) + "px serif";
                            ctx.fillStyle = "#78a8d0";
                            ctx.textAlign = "center"; ctx.textBaseline = "middle";
                            ctx.fillText("A", w / 2, h / 2);
                        }
                    }
                }

                Text {
                    text: T.t("clock_font", root.lang)
                    font.pixelSize: root._fItem
                    color: "#98b0c8"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: Math.round(root.width * 0.015)
                anchors.verticalCenter: parent.verticalCenter
                text: root.fontNames[root.fontIndex]
                font.pixelSize: root._fSub
                color: "#5098d8"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.focusIndex = 1;
                    root.fontExpanded = !root.fontExpanded;
                    if (root.fontExpanded) root.fontPreviewIdx = root.fontIndex;
                }
            }
        }

        // Font preview cards (expanded)
        Item {
            id: fontPreviewArea
            visible: root.fontExpanded
            y: fontRow.y + fontRow.height + Math.round(root.height * 0.012)
            width: parent.width
            height: Math.round(root.height * 0.38)
            clip: true

            Flickable {
                id: fontFlickable
                anchors.fill: parent
                contentHeight: fontColumn.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                // Auto-scroll to keep selected item visible
                function ensureVisible(idx) {
                    var itemH = Math.round(root.height * 0.038);
                    var spacing = Math.round(root.height * 0.006);
                    var itemY = idx * (itemH + spacing);
                    if (itemY < contentY) contentY = itemY;
                    else if (itemY + itemH > contentY + height) contentY = itemY + itemH - height;
                }

                Column {
                    id: fontColumn
                    width: parent.width
                    spacing: Math.round(root.height * 0.006)

                    Repeater {
                        model: root.fontFiles.length
                        delegate: Item {
                            width: fontColumn.width
                            height: Math.round(root.height * 0.038)

                        property bool isSel: root.fontExpanded && root.fontPreviewIdx === index
                        property bool isActive: root.fontIndex === index

                        Rectangle {
                            anchors.fill: parent; radius: 5
                            color: parent.isSel ? "#0effffff" : "transparent"
                            border.color: parent.isSel ? "#1a3860" : (parent.isActive ? "#0e2a48" : "transparent")
                            border.width: parent.isSel ? 1 : (parent.isActive ? 1 : 0)
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: Math.round(root.width * 0.008)
                            spacing: Math.round(root.width * 0.018)

                            // Font name
                            Text {
                                text: root.fontNames[index]
                                font.pixelSize: root._fSub
                                color: parent.parent.isSel ? "#c0d8f0" : (parent.parent.isActive ? "#7098c0" : "#506878")
                                width: Math.round(root.width * 0.08)
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            // Time preview in this font
                            Text {
                                text: "12:45"
                                font.family: root.getFontFamily(index)
                                font.pixelSize: Math.round(root.height * 0.028)
                                font.bold: true
                                color: parent.parent.isSel ? "#d0e8ff" : "#7898b8"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        // Active checkmark
                        Canvas {
                            visible: parent.isActive
                            anchors.right: parent.right
                            anchors.rightMargin: Math.round(root.width * 0.012)
                            anchors.verticalCenter: parent.verticalCenter
                            width: Math.round(root.height * 0.016); height: width
                            onPaint: {
                                var ctx = getContext("2d"); ctx.reset();
                                var w = width, h = height;
                                ctx.fillStyle = "#5098d8";
                                ctx.beginPath(); ctx.arc(w / 2, h / 2, w / 2, 0, Math.PI * 2); ctx.fill();
                                ctx.strokeStyle = "#ffffff"; ctx.lineWidth = 1.2;
                                ctx.beginPath();
                                ctx.moveTo(w * 0.28, h * 0.52);
                                ctx.lineTo(w * 0.44, h * 0.68);
                                ctx.lineTo(w * 0.72, h * 0.34);
                                ctx.stroke();
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.fontPreviewIdx = index;
                                root.fontIndex = index;
                                root.saveSettings();
                            }
                        }
                    }
                }
            }  // Column
            }  // Flickable
        }

        // Separator 2
        Rectangle {
            id: sep2
            y: {
                if (root.fontExpanded)
                    return fontPreviewArea.y + fontPreviewArea.height + Math.round(root.height * 0.024);
                return fontRow.y + fontRow.height + Math.round(root.height * 0.024);
            }
            width: parent.width; height: 1; color: "#08ffffff"
        }

        Text {
            id: colorLabel
            y: sep2.y + sep2.height + Math.round(root.height * 0.016)
            text: T.t("clock_color_section", root.lang)
            font.pixelSize: root._fItem; font.bold: true; color: "#7090b0"
        }

        Item {
            id: colorRow
            y: colorLabel.y + colorLabel.height + Math.round(root.height * 0.008)
            width: parent.width; height: root._rowH

            Rectangle {
                anchors.fill: parent; radius: 6
                color: root.focusIndex === 2 ? "#0affffff" : "transparent"
                border.color: root.focusIndex === 2 ? "#1a3860" : "transparent"
                border.width: root.focusIndex === 2 ? 1 : 0
                Behavior on color { ColorAnimation { duration: 180 } }
                Behavior on border.color { ColorAnimation { duration: 180 } }
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: Math.round(root.width * 0.012)

                Rectangle {
                    width: root._smIconSz; height: width
                    radius: width * 0.24; color: "#0cffffff"
                    anchors.verticalCenter: parent.verticalCenter

                    // Color swatch icon
                    Rectangle {
                        anchors.centerIn: parent
                        width: Math.round(parent.width * 0.50)
                        height: width; radius: width * 0.25
                        color: root.colorPalette[root.colorIndex].outline
                    }
                }

                Text {
                    text: T.t("clock_color", root.lang)
                    font.pixelSize: root._fItem
                    color: "#98b0c8"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Current color circle + name on right
            Row {
                anchors.right: parent.right
                anchors.rightMargin: Math.round(root.width * 0.015)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Math.round(root.width * 0.006)

                Text {
                    text: root.colorPalette[root.colorIndex].name
                    font.pixelSize: root._fSub
                    color: "#5098d8"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: Math.round(root.height * 0.018)
                    height: width; radius: width / 2
                    color: root.colorPalette[root.colorIndex].outline
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.focusIndex = 2;
                    root.colorExpanded = !root.colorExpanded;
                    if (root.colorExpanded) root.colorPreviewIdx = root.colorIndex;
                }
            }
        }

        // Color palette grid (expanded)
        Item {
            id: colorPaletteArea
            visible: root.colorExpanded
            y: colorRow.y + colorRow.height + Math.round(root.height * 0.012)
            width: parent.width
            height: Math.round(root.height * 0.10)

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: Math.round(root.width * 0.010)

                Repeater {
                    model: root.colorPalette.length
                    delegate: Item {
                        width: Math.round(root.width * 0.038)
                        height: Math.round(root.height * 0.070)

                        property bool isSel: root.colorExpanded && root.colorPreviewIdx === index
                        property bool isActive: root.colorIndex === index

                        Column {
                            anchors.centerIn: parent
                            spacing: 3

                            Rectangle {
                                id: colorCircle
                                width: Math.round(root.height * 0.032)
                                height: width; radius: width / 2
                                color: root.colorPalette[index].outline
                                border.color: parent.parent.isSel ? "#ffffff" : (parent.parent.isActive ? "#a0c0e0" : "transparent")
                                border.width: parent.parent.isSel ? 2 : (parent.parent.isActive ? 1.5 : 0)
                                anchors.horizontalCenter: parent.horizontalCenter

                                // Scale on selection
                                scale: parent.parent.isSel ? 1.25 : 1.0
                                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                                Behavior on border.color { ColorAnimation { duration: 150 } }
                            }

                            Text {
                                text: root.colorPalette[index].name
                                font.pixelSize: Math.max(7, Math.round(root.height * 0.010))
                                color: parent.parent.isSel ? "#c0d8f0" : "#506878"
                                anchors.horizontalCenter: parent.horizontalCenter
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.colorPreviewIdx = index;
                                root.colorIndex = index;
                                root.saveSettings();
                            }
                        }
                    }
                }
            }
        }

        // Separator 3
        Rectangle {
            id: sep3
            y: {
                if (root.colorExpanded)
                    return colorPaletteArea.y + colorPaletteArea.height + Math.round(root.height * 0.024);
                return colorRow.y + colorRow.height + Math.round(root.height * 0.024);
            }
            width: parent.width; height: 1; color: "#08ffffff"
        }

        // RIEMPIMENTO (Fill / Outline toggle)
        Item {
            id: fillRow
            y: sep3.y + sep3.height + Math.round(root.height * 0.012)
            width: parent.width; height: root._rowH

            Rectangle {
                anchors.fill: parent; radius: 6
                color: root.focusIndex === 3 ? "#0affffff" : "transparent"
                border.color: root.focusIndex === 3 ? "#1a3860" : "transparent"
                border.width: root.focusIndex === 3 ? 1 : 0
                Behavior on color { ColorAnimation { duration: 180 } }
                Behavior on border.color { ColorAnimation { duration: 180 } }
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
                            var ctx = getContext("2d"); ctx.reset();
                            var w = width, h = height;
                            ctx.strokeStyle = "#78a8d0"; ctx.lineWidth = 1.2;
                            ctx.strokeRect(w * 0.15, h * 0.15, w * 0.7, h * 0.7);
                            if (root.fillMode) {
                                ctx.fillStyle = "#78a8d0";
                                ctx.fillRect(w * 0.25, h * 0.25, w * 0.5, h * 0.5);
                            }
                        }
                        property bool _dep: root.fillMode
                        on_DepChanged: requestPaint()
                    }
                }

                Text {
                    text: T.t("clock_fill", root.lang)
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
                    text: root.fillMode ? T.t("clock_fill_solid", root.lang) : T.t("clock_fill_outline", root.lang)
                    font.pixelSize: root._fSub
                    color: "#5098d8"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: Math.round(root.width * 0.044); height: Math.round(root.height * 0.024)
                    radius: height / 2
                    color: root.fillMode ? "#2060a0" : "#1a2840"
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Rectangle {
                        width: parent.height - 4; height: width; radius: width / 2; color: "#d0e0f0"
                        x: root.fillMode ? parent.width - width - 2 : 2
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: { root.fillMode = !root.fillMode; root.saveSettings(); }
            }
        }

        // Separator 4
        Rectangle {
            id: sep4
            y: fillRow.y + fillRow.height + Math.round(root.height * 0.024)
            width: parent.width; height: 1; color: "#08ffffff"
        }

        // RAINBOW (toggle)
        Item {
            id: rainbowRow
            y: sep4.y + sep4.height + Math.round(root.height * 0.012)
            width: parent.width; height: root._rowH
            opacity: 1.0

            Rectangle {
                anchors.fill: parent; radius: 6
                color: root.focusIndex === 4 ? "#0affffff" : "transparent"
                border.color: root.focusIndex === 4 ? "#1a3860" : "transparent"
                border.width: root.focusIndex === 4 ? 1 : 0
                Behavior on color { ColorAnimation { duration: 180 } }
                Behavior on border.color { ColorAnimation { duration: 180 } }
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
                            var ctx = getContext("2d"); ctx.reset();
                            var w = width, h = height, cx = w / 2, cy = h * 0.7;
                            var colors = ["#E74C3C","#F39C12","#F1C40F","#2ECC71","#5DADE2","#A569BD"];
                            for (var i = 0; i < colors.length; i++) {
                                ctx.strokeStyle = colors[i]; ctx.lineWidth = 1.5;
                                var r = w * 0.38 - i * 1.8;
                                ctx.beginPath();
                                ctx.arc(cx, cy, Math.max(r, 2), Math.PI, 0);
                                ctx.stroke();
                            }
                        }
                    }
                }

                Text {
                    text: T.t("clock_rainbow", root.lang)
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
                    text: root.rainbow ? T.t("on", root.lang) : T.t("off", root.lang)
                    font.pixelSize: root._fSub
                    color: "#5098d8"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: Math.round(root.width * 0.044); height: Math.round(root.height * 0.024)
                    radius: height / 2
                    color: root.rainbow ? "#2060a0" : "#1a2840"
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Rectangle {
                        width: parent.height - 4; height: width; radius: width / 2; color: "#d0e0f0"
                        x: root.rainbow ? parent.width - width - 2 : 2
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.rainbow = !root.rainbow;
                    root.saveSettings();
                }
            }
        }
    }

    // LIVE PREVIEW

    property color _previewColor: {
        if (rainbow)
            return _borderAnim;
        var cidx = fontExpanded ? fontIndex : (colorExpanded ? colorPreviewIdx : colorIndex);
        return colorPalette[cidx].outline;
    }

    Item {
        id: previewArea
        anchors.right: parent.right
        anchors.rightMargin: Math.round(root.width * 0.02)
        anchors.verticalCenter: parent.verticalCenter
        width: Math.round(root.width * 0.22)
        height: Math.round(root.height * 0.18)

        // Source: expanded outline text (white for shader coloring)
        Item {
            id: previewOutline
            anchors.fill: parent
            visible: false

            Repeater {
                model: [
                    {dx:-1,dy:-1},{dx:0,dy:-1},{dx:1,dy:-1},
                    {dx:-1,dy:0},              {dx:1,dy:0},
                    {dx:-1,dy:1}, {dx:0,dy:1}, {dx:1,dy:1}
                ]
                Text {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: modelData.dx
                    anchors.verticalCenterOffset: modelData.dy
                    text: root.use24h ? "14:30" : "2:30"
                    color: "white"
                    font.pixelSize: Math.round(root.height * 0.065)
                    font.bold: true
                    font.family: root.getFontFamily(root.fontExpanded ? root.fontPreviewIdx : root.fontIndex)
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        // Mask: center text for alpha cutout
        Item {
            id: previewMask
            anchors.fill: parent
            visible: false

            Text {
                anchors.centerIn: parent
                text: root.use24h ? "14:30" : "2:30"
                color: "white"
                font.pixelSize: Math.round(root.height * 0.065)
                font.bold: true
                font.family: root.getFontFamily(root.fontExpanded ? root.fontPreviewIdx : root.fontIndex)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        // Fill source: solid text for fill mode shader
        Item {
            id: previewFillSource
            anchors.fill: parent
            visible: false

            Text {
                anchors.centerIn: parent
                text: root.use24h ? "14:30" : "2:30"
                color: "white"
                font.pixelSize: Math.round(root.height * 0.065)
                font.bold: true
                font.family: root.getFontFamily(root.fontExpanded ? root.fontPreviewIdx : root.fontIndex)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        // OUTLINE — non-rainbow: single color with alpha mask
        ShaderEffect {
            anchors.fill: parent
            visible: !root.fillMode && !root.rainbow
            property variant src: ShaderEffectSource { sourceItem: previewOutline }
            property variant msk: ShaderEffectSource { sourceItem: previewMask }
            property color outlineCol: root._previewColor
            fragmentShader: "
                varying highp vec2 qt_TexCoord0;
                uniform lowp float qt_Opacity;
                uniform sampler2D src;
                uniform sampler2D msk;
                uniform lowp vec4 outlineCol;
                void main() {
                    lowp float s = texture2D(src, qt_TexCoord0).a;
                    lowp float m = texture2D(msk, qt_TexCoord0).a;
                    gl_FragColor = outlineCol * s * (1.0 - m) * qt_Opacity;
                }
            "
        }

        // OUTLINE — rainbow: conical gradient with 3 colors + alpha mask
        ShaderEffect {
            anchors.fill: parent
            visible: !root.fillMode && root.rainbow
            property variant src: ShaderEffectSource { sourceItem: previewOutline }
            property variant msk: ShaderEffectSource { sourceItem: previewMask }
            property color col1: root._borderAnim
            property color col2: root._borderAnim2
            property color col3: root._borderAnim3
            property real angle: root._borderAngle * 0.0174533
            fragmentShader: "
                varying highp vec2 qt_TexCoord0;
                uniform lowp float qt_Opacity;
                uniform sampler2D src;
                uniform sampler2D msk;
                uniform lowp vec4 col1;
                uniform lowp vec4 col2;
                uniform lowp vec4 col3;
                uniform highp float angle;
                void main() {
                    lowp float s = texture2D(src, qt_TexCoord0).a;
                    lowp float m = texture2D(msk, qt_TexCoord0).a;
                    highp vec2 center = qt_TexCoord0 - vec2(0.5);
                    highp float a = atan(center.y, center.x) + angle;
                    highp float t = fract(a / 6.2831853);
                    lowp vec4 c;
                    if (t < 0.333)
                        c = mix(col1, col2, t * 3.0);
                    else if (t < 0.666)
                        c = mix(col2, col3, (t - 0.333) * 3.0);
                    else
                        c = mix(col3, col1, (t - 0.666) * 3.0);
                    gl_FragColor = c * s * (1.0 - m) * qt_Opacity;
                }
            "
        }

        // Semi-transparent interior (outline mode)
        Text {
            visible: !root.fillMode
            anchors.centerIn: parent
            text: root.use24h ? "14:30" : "2:30"
            color: "#33FFFFFF"
            font.pixelSize: Math.round(root.height * 0.065)
            font.bold: true
            font.family: root.getFontFamily(root.fontExpanded ? root.fontPreviewIdx : root.fontIndex)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        // FILLED — non-rainbow: solid color text
        Text {
            visible: root.fillMode && !root.rainbow
            anchors.centerIn: parent
            text: root.use24h ? "14:30" : "2:30"
            color: root._previewColor
            font.pixelSize: Math.round(root.height * 0.065)
            font.bold: true
            font.family: root.getFontFamily(root.fontExpanded ? root.fontPreviewIdx : root.fontIndex)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        // FILLED — rainbow: conical gradient on text
        ShaderEffect {
            anchors.fill: parent
            visible: root.fillMode && root.rainbow
            property variant src: ShaderEffectSource { sourceItem: previewFillSource }
            property color col1: root._borderAnim
            property color col2: root._borderAnim2
            property color col3: root._borderAnim3
            property real angle: root._borderAngle * 0.0174533
            fragmentShader: "
                varying highp vec2 qt_TexCoord0;
                uniform lowp float qt_Opacity;
                uniform sampler2D src;
                uniform lowp vec4 col1;
                uniform lowp vec4 col2;
                uniform lowp vec4 col3;
                uniform highp float angle;
                void main() {
                    lowp float s = texture2D(src, qt_TexCoord0).a;
                    highp vec2 center = qt_TexCoord0 - vec2(0.5);
                    highp float a = atan(center.y, center.x) + angle;
                    highp float t = fract(a / 6.2831853);
                    lowp vec4 c;
                    if (t < 0.333)
                        c = mix(col1, col2, t * 3.0);
                    else if (t < 0.666)
                        c = mix(col2, col3, (t - 0.333) * 3.0);
                    else
                        c = mix(col3, col1, (t - 0.666) * 3.0);
                    gl_FragColor = c * s * qt_Opacity;
                }
            "
        }

        // AM/PM label if 12h
        Text {
            visible: !root.use24h
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.verticalCenter
            anchors.topMargin: Math.round(root.height * 0.042)
            text: "PM"
            font.pixelSize: Math.max(9, Math.round(root.height * 0.015))
            color: root._previewColor
            opacity: 0.6
        }
    }

    // CONTROL HINTS

    Item {
        id: controlHintsOuter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Math.round(root.height * 0.025)
        anchors.right: parent.right
        anchors.rightMargin: Math.round(root.width * 0.025)
        width: hintText.implicitWidth
        height: Math.round(root.height * 0.035)

        Text {
            id: hintText
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (root.fontExpanded)
                    return T.t("hint_font_choose", root.lang);
                if (root.colorExpanded)
                    return T.t("hint_color_choose", root.lang);
                if (root.focusIndex === 0)
                    return T.t("hint_onoff_back", root.lang);
                if (root.focusIndex === 1)
                    return T.t("hint_choose_font", root.lang);
                if (root.focusIndex === 2)
                    return T.t("hint_choose_color", root.lang);
                if (root.focusIndex === 3)
                    return T.t("hint_onoff_back", root.lang);
                return T.t("hint_onoff_back", root.lang);
            }
            font.pixelSize: Math.max(11, Math.round(root.height * 0.016))
            color: "#ffffff"
        }
    }

    // ANIMATIONS

    ParallelAnimation {
        id: entranceAnim
        NumberAnimation { target: root; property: "opacity"; from: 0; to: 1; duration: 380; easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "_slideOffset"; from: root.width * 0.04; to: 0; duration: 420; easing.type: Easing.OutCubic }
    }

    ParallelAnimation {
        id: exitAnim
        NumberAnimation { target: root; property: "opacity"; from: 1; to: 0; duration: 250; easing.type: Easing.InCubic }
        NumberAnimation { target: root; property: "_slideOffset"; from: 0; to: root.width * 0.04; duration: 250; easing.type: Easing.InCubic }
        onFinished: { root.visible = false; root.closed(); }
    }

    // KEYBOARD

    Keys.onPressed: {
        event.accepted = true;

        var isAccept = (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === 1048576);
        var isBack   = (event.key === Qt.Key_Escape || event.key === Qt.Key_Back ||
                        event.key === Qt.Key_Backspace || event.key === 1048577);
        var isUp     = (event.key === Qt.Key_Up);
        var isDown   = (event.key === Qt.Key_Down);
        var isLeft   = (event.key === Qt.Key_Left);
        var isRight  = (event.key === Qt.Key_Right);

        // Font expanded
        if (root.fontExpanded) {
            if (isUp && root.fontPreviewIdx > 0) {
                root.fontPreviewIdx--;
                fontFlickable.ensureVisible(root.fontPreviewIdx);
            } else if (isDown && root.fontPreviewIdx < 9) {
                root.fontPreviewIdx++;
                fontFlickable.ensureVisible(root.fontPreviewIdx);
            } else if (isAccept) {
                root.fontIndex = root.fontPreviewIdx;
                root.saveSettings();
            } else if (isBack) {
                root.fontExpanded = false;
            } else {
                event.accepted = false;
            }
            return;
        }

        // Color expanded
        if (root.colorExpanded) {
            if (isLeft && root.colorPreviewIdx > 0) {
                root.colorPreviewIdx--;
            } else if (isRight && root.colorPreviewIdx < root.colorPalette.length - 1) {
                root.colorPreviewIdx++;
            } else if (isAccept) {
                root.colorIndex = root.colorPreviewIdx;
                root.saveSettings();
            } else if (isBack) {
                root.colorExpanded = false;
            } else {
                event.accepted = false;
            }
            return;
        }

        // Normal navigation
        if (isUp && root.focusIndex > 0) {
            root.focusIndex--;
        } else if (isDown && root.focusIndex < 4) {
            root.focusIndex++;
        } else if (isAccept) {
            if (root.focusIndex === 0) {
                root.use24h = !root.use24h;
                root.saveSettings();
            } else if (root.focusIndex === 1) {
                root.fontExpanded = true;
                root.fontPreviewIdx = root.fontIndex;
            } else if (root.focusIndex === 2) {
                root.colorExpanded = true;
                root.colorPreviewIdx = root.colorIndex;
            } else if (root.focusIndex === 3) {
                root.fillMode = !root.fillMode;
                root.saveSettings();
            } else if (root.focusIndex === 4) {
                root.rainbow = !root.rainbow;
                root.saveSettings();
            }
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
        focusIndex = 0;
        fontExpanded = false;
        colorExpanded = false;
        forceActiveFocus();
        entranceAnim.start();
    }

    function closePanel() {
        if (exitAnim.running) return;
        saveSettings();
        exitAnim.start();
    }

    function loadSettings() {
        var fmt = api.memory.get("clock_format");
        use24h = (fmt !== "12h");

        var fi = api.memory.get("clock_font_index");
        if (fi !== undefined && fi !== "" && !isNaN(parseInt(fi))) {
            var parsed = parseInt(fi);
            if (parsed >= 0 && parsed < fontFiles.length) fontIndex = parsed;
            else fontIndex = 0;
        } else {
            fontIndex = 0;
        }

        var ci = api.memory.get("clock_color_index");
        if (ci !== undefined && ci !== "" && !isNaN(parseInt(ci))) {
            var parsedC = parseInt(ci);
            if (parsedC >= 0 && parsedC < colorPalette.length) colorIndex = parsedC;
            else colorIndex = 1;
        } else {
            colorIndex = 1;
        }

        var fm = api.memory.get("clock_fill_mode");
        fillMode = (fm === undefined || fm === "") ? true : (fm === "filled");

        var rb = api.memory.get("clock_rainbow");
        rainbow = (rb === "on");
    }

    function saveSettings() {
        api.memory.set("clock_format", use24h ? "24h" : "12h");
        api.memory.set("clock_font_index", fontIndex.toString());
        api.memory.set("clock_color_index", colorIndex.toString());
        api.memory.set("clock_fill_mode", fillMode ? "filled" : "outline");
        api.memory.set("clock_rainbow", rainbow ? "on" : "off");
        root.settingsChanged(use24h, fontIndex, colorIndex);
    }
}
