import QtQuick 2.15
import ".."
import "../../components/config/Translations.js" as T

// Background settings – inline XMB drill-down panel (PS3 style)
Item {
    id: root
    anchors.fill: parent
    visible: false
    opacity: 0

    // Settings
    property bool useArtwork: true
    property bool useVideo: true
    property int blurIntensity: 5   // 0 (min) .. 10 (max blur)
    property string bgSource: "preset1"  // "preset1".."preset5" or "custom"
    property string customPath: ""

    // Language
    property string lang: "it"

    property int focusIndex: 0  // 0=artwork, 1=blur, 2=video, 3=default(presets), 4=custom
    property bool defaultExpanded: false
    property int presetIndex: 0  // 0..4 for 5 presets
    property bool fileBrowserActive: false
    property int browserIndex: 0

    // 5 Gradient presets
    readonly property var presets: [
        { name: "Deep Ocean",       c0: "#1a1a2e", c1: "#16213e", c2: "#0f3460", c3: "#0d2b52",
          menuC0: "#040b14", menuC1: "#0b1a32", menuC2: "#0f2848", menuC3: "#081830",
          accent: "#5890d0" },
        { name: "Midnight Violet",  c0: "#1a1028", c1: "#221838", c2: "#301850", c3: "#28104a",
          menuC0: "#0a0614", menuC1: "#140e24", menuC2: "#1e1440", menuC3: "#160c2e",
          accent: "#8868c0" },
        { name: "Dark Forest",      c0: "#0e1a14", c1: "#122418", c2: "#183822", c3: "#10301c",
          menuC0: "#040c08", menuC1: "#081610", menuC2: "#0c2418", menuC3: "#061c10",
          accent: "#4a9868" },
        { name: "Warm Ember",       c0: "#1e1410", c1: "#2a1a14", c2: "#3a2418", c3: "#321e14",
          menuC0: "#0c0804", menuC1: "#180e0a", menuC2: "#281810", menuC3: "#20140c",
          accent: "#c08850" },
        { name: "Arctic Steel",     c0: "#141820", c1: "#1a2030", c2: "#222a3e", c3: "#1e2838",
          menuC0: "#080c12", menuC1: "#0e141e", menuC2: "#161e2c", menuC3: "#101824",
          accent: "#7898b8" }
    ]

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

    // Swatch size
    readonly property real _swW: Math.round(width * 0.085)
    readonly property real _swH: Math.round(height * 0.058)

    signal settingsChanged(bool useArtwork, bool useVideo, string bgSource, string customPath, int blurIntensity)
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
                ctx.strokeRect(w * 0.08, h * 0.15, w * 0.84, h * 0.70);
                ctx.beginPath();
                ctx.moveTo(w * 0.15, h * 0.72);
                ctx.lineTo(w * 0.40, h * 0.38);
                ctx.lineTo(w * 0.55, h * 0.55);
                ctx.lineTo(w * 0.70, h * 0.32);
                ctx.lineTo(w * 0.85, h * 0.72);
                ctx.stroke();
                ctx.beginPath();
                ctx.arc(w * 0.72, h * 0.35, w * 0.08, 0, Math.PI * 2);
                ctx.stroke();
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
                    ctx.strokeRect(w * 0.08, h * 0.15, w * 0.84, h * 0.70);
                    ctx.beginPath();
                    ctx.moveTo(w * 0.15, h * 0.72);
                    ctx.lineTo(w * 0.40, h * 0.38);
                    ctx.lineTo(w * 0.55, h * 0.55);
                    ctx.lineTo(w * 0.70, h * 0.32);
                    ctx.lineTo(w * 0.85, h * 0.72);
                    ctx.stroke();
                }
            }
        }

        Item { width: Math.round(root.width * 0.008); height: 1 }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Text { text: T.t("bg_title", root.lang); font.pixelSize: root._fTitle; font.bold: true; color: "#d0e0f0" }
            Text { text: T.t("bg_subtitle", root.lang); font.pixelSize: root._fSub; color: "#5878a0" }
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
        visible: !root.fileBrowserActive

        // Game Artwork
        Item {
            id: artworkRow
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
                            ctx.strokeStyle = root.useArtwork ? "#78a8d0" : "#3a5060";
                            ctx.lineWidth = 1.0;
                            ctx.strokeRect(w * 0.05, h * 0.15, w * 0.90, h * 0.70);
                            ctx.beginPath();
                            ctx.moveTo(w * 0.12, h * 0.72); ctx.lineTo(w * 0.38, h * 0.38);
                            ctx.lineTo(w * 0.52, h * 0.52); ctx.lineTo(w * 0.68, h * 0.32);
                            ctx.lineTo(w * 0.88, h * 0.72); ctx.stroke();
                        }
                        property bool _dep: root.useArtwork
                        on_DepChanged: requestPaint()
                    }
                }

                Text {
                    text: T.t("bg_artwork", root.lang)
                    font.pixelSize: root._fItem
                    color: root.useArtwork ? "#98b0c8" : "#506070"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: Math.round(root.width * 0.015)
                anchors.verticalCenter: parent.verticalCenter
                width: Math.round(root.width * 0.044); height: Math.round(root.height * 0.024)
                radius: height / 2
                color: root.useArtwork ? "#2060a0" : "#1a2840"
                Behavior on color { ColorAnimation { duration: 200 } }
                Rectangle {
                    width: parent.height - 4; height: width; radius: width / 2; color: "#d0e0f0"
                    x: root.useArtwork ? parent.width - width - 2 : 2
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: { root.useArtwork = !root.useArtwork; root.saveSettings(); }
            }
        }

        // Blur Intensity (slider, visible only when artwork is on)
        Item {
            id: blurRow
            y: artworkRow.y + artworkRow.height + Math.round(root.height * 0.004)
            width: parent.width; height: root._rowH
            opacity: root.useArtwork ? 1.0 : 0.35
            Behavior on opacity { NumberAnimation { duration: 200 } }

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
                            ctx.strokeStyle = root.useArtwork ? "#78a8d0" : "#3a5060";
                            ctx.lineWidth = 1.0;
                            // Blur/droplet icon
                            ctx.beginPath();
                            ctx.moveTo(w * 0.50, h * 0.10);
                            ctx.quadraticCurveTo(w * 0.90, h * 0.55, w * 0.50, h * 0.90);
                            ctx.quadraticCurveTo(w * 0.10, h * 0.55, w * 0.50, h * 0.10);
                            ctx.stroke();
                        }
                        property bool _dep: root.useArtwork
                        on_DepChanged: requestPaint()
                    }
                }

                Text {
                    text: T.t("bg_blur_intensity", root.lang)
                    font.pixelSize: root._fItem
                    color: root.useArtwork ? "#98b0c8" : "#506070"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Slider track + handle
            Item {
                anchors.right: parent.right
                anchors.rightMargin: Math.round(root.width * 0.015)
                anchors.verticalCenter: parent.verticalCenter
                width: Math.round(root.width * 0.15)
                height: Math.round(root.height * 0.024)

                // Track background
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width; height: 4; radius: 2
                    color: "#1a2840"

                    // Filled portion
                    Rectangle {
                        width: parent.width * (root.blurIntensity / 10.0)
                        height: parent.height; radius: parent.radius
                        color: "#2060a0"
                        Behavior on width { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                    }
                }

                // Handle
                Rectangle {
                    width: parent.height - 2; height: width; radius: width / 2
                    color: "#d0e0f0"
                    x: parent.width * (root.blurIntensity / 10.0) - width / 2
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on x { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                }

                // Value label
                Text {
                    anchors.right: parent.left
                    anchors.rightMargin: Math.round(root.width * 0.008)
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.blurIntensity
                    font.pixelSize: root._fSub
                    color: "#5098d8"
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (root.useArtwork) {
                        root.blurIntensity = Math.min(10, root.blurIntensity + 1);
                        if (root.blurIntensity > 10) root.blurIntensity = 0;
                        root.saveSettings();
                    }
                }
            }
        }

        // Game Video
        Item {
            id: videoRow
            y: blurRow.y + blurRow.height + Math.round(root.height * 0.004)
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

                    Canvas {
                        anchors.centerIn: parent
                        width: Math.round(parent.width * 0.55); height: width
                        onPaint: {
                            var ctx = getContext("2d"); ctx.reset();
                            var w = width, h = height;
                            ctx.strokeStyle = root.useVideo ? "#78a8d0" : "#3a5060";
                            ctx.lineWidth = 1.0;
                            ctx.strokeRect(w * 0.05, h * 0.10, w * 0.90, h * 0.80);
                            ctx.beginPath();
                            ctx.moveTo(w * 0.35, h * 0.28); ctx.lineTo(w * 0.72, h * 0.50);
                            ctx.lineTo(w * 0.35, h * 0.72); ctx.closePath(); ctx.stroke();
                        }
                        property bool _dep: root.useVideo
                        on_DepChanged: requestPaint()
                    }
                }

                Text {
                    text: T.t("bg_video", root.lang)
                    font.pixelSize: root._fItem
                    color: root.useVideo ? "#98b0c8" : "#506070"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: Math.round(root.width * 0.015)
                anchors.verticalCenter: parent.verticalCenter
                width: Math.round(root.width * 0.044); height: Math.round(root.height * 0.024)
                radius: height / 2
                color: root.useVideo ? "#2060a0" : "#1a2840"
                Behavior on color { ColorAnimation { duration: 200 } }
                Rectangle {
                    width: parent.height - 4; height: width; radius: width / 2; color: "#d0e0f0"
                    x: root.useVideo ? parent.width - width - 2 : 2
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: { root.useVideo = !root.useVideo; root.saveSettings(); }
            }
        }

        // Separator (bigger gap)
        Rectangle {
            id: bgSep
            y: videoRow.y + videoRow.height + Math.round(root.height * 0.018)
            width: parent.width; height: 1; color: "#08ffffff"
        }

        // Tema Background (label)
        Text {
            id: bgThemeLabel
            y: bgSep.y + bgSep.height + Math.round(root.height * 0.012)
            text: T.t("bg_theme", root.lang)
            font.pixelSize: root._fItem
            font.bold: true
            color: "#7090b0"
        }

        // Default row (selectable, shows current preset name)
        Item {
            id: defaultRow
            y: bgThemeLabel.y + bgThemeLabel.height + Math.round(root.height * 0.008)
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
                            ctx.strokeStyle = (root.bgSource !== "custom") ? "#78a8d0" : "#3a5060";
                            ctx.lineWidth = 1.0;
                            // Paint palette icon
                            ctx.beginPath();
                            ctx.arc(w * 0.50, h * 0.50, w * 0.40, 0, Math.PI * 2);
                            ctx.stroke();
                            var dots = [[0.35, 0.35], [0.55, 0.30], [0.65, 0.45], [0.40, 0.60]];
                            for (var i = 0; i < dots.length; i++) {
                                ctx.beginPath();
                                ctx.arc(w * dots[i][0], h * dots[i][1], w * 0.06, 0, Math.PI * 2);
                                ctx.fill();
                            }
                        }
                        property string _dep: root.bgSource
                        on_DepChanged: requestPaint()
                    }
                }

                Text {
                    text: T.t("bg_preset", root.lang)
                    font.pixelSize: root._fItem
                    color: (root.bgSource !== "custom") ? "#98b0c8" : "#506070"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Current preset name on the right
            Text {
                anchors.right: parent.right
                anchors.rightMargin: Math.round(root.width * 0.015)
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    if (root.bgSource === "custom") return "—";
                    var idx = root.getPresetIdx(root.bgSource);
                    return root.presets[idx].name;
                }
                font.pixelSize: root._fSub
                color: (root.bgSource !== "custom") ? "#5098d8" : "#3a5060"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.focusIndex = 3;
                    root.defaultExpanded = !root.defaultExpanded;
                    if (root.defaultExpanded) root.presetIndex = root.getPresetIdx(root.bgSource);
                }
            }
        }

        // Preset swatches (shown below when expanded)
        Item {
            id: presetSwatchArea
            visible: root.defaultExpanded
            y: defaultRow.y + defaultRow.height + Math.round(root.height * 0.008)
            width: parent.width
            height: root._swH + Math.round(root.height * 0.032)

            Row {
                id: swatchRow
                anchors.verticalCenter: parent.verticalCenter
                spacing: Math.round(root.width * 0.010)

                Repeater {
                    model: 5
                    delegate: Item {
                        width: root._swW
                        height: root._swH + nameLabel.height + 4

                        property bool isSel: root.defaultExpanded && root.presetIndex === index
                        property bool isActive: root.bgSource === ("preset" + (index + 1))

                        // Swatch gradient preview
                        Rectangle {
                            id: swatchRect
                            width: root._swW; height: root._swH
                            radius: 6
                            border.color: parent.isSel ? "#5098d8" : (parent.isActive ? "#3878a8" : "#1a3050")
                            border.width: parent.isSel ? 2 : 1

                            gradient: Gradient {
                                GradientStop { position: 0.0; color: root.presets[index].c0 }
                                GradientStop { position: 0.3; color: root.presets[index].c1 }
                                GradientStop { position: 0.7; color: root.presets[index].c2 }
                                GradientStop { position: 1.0; color: root.presets[index].c3 }
                            }

                            // Checkmark for active
                            Canvas {
                                visible: parent.parent.isActive
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 3
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

                            Behavior on border.color { ColorAnimation { duration: 180 } }
                        }

                        Text {
                            id: nameLabel
                            anchors.top: swatchRect.bottom
                            anchors.topMargin: 3
                            anchors.horizontalCenter: swatchRect.horizontalCenter
                            text: root.presets[index].name
                            font.pixelSize: Math.max(8, Math.round(root.height * 0.012))
                            color: parent.isSel ? "#c0d8f0" : "#506878"
                            horizontalAlignment: Text.AlignHCenter
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.presetIndex = index;
                                root.bgSource = "preset" + (index + 1);
                                root.saveSettings();
                            }
                        }
                    }
                }
            }
        }

        // Custom
        Item {
            id: customRow
            y: {
                if (root.defaultExpanded)
                    return presetSwatchArea.y + presetSwatchArea.height + Math.round(root.height * 0.004);
                return defaultRow.y + defaultRow.height + Math.round(root.height * 0.004);
            }
            width: parent.width; height: root._rowH

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
                            var w = width, h = height;
                            ctx.strokeStyle = root.bgSource === "custom" ? "#78a8d0" : "#3a5060";
                            ctx.lineWidth = 1.0;
                            ctx.beginPath();
                            ctx.moveTo(w * 0.05, h * 0.28);
                            ctx.lineTo(w * 0.05, h * 0.82);
                            ctx.lineTo(w * 0.95, h * 0.82);
                            ctx.lineTo(w * 0.95, h * 0.35);
                            ctx.lineTo(w * 0.50, h * 0.35);
                            ctx.lineTo(w * 0.42, h * 0.22);
                            ctx.lineTo(w * 0.05, h * 0.22);
                            ctx.closePath(); ctx.stroke();
                        }
                        property string _dep: root.bgSource
                        on_DepChanged: requestPaint()
                    }
                }

                Text {
                    text: T.t("bg_custom", root.lang)
                    font.pixelSize: root._fItem
                    color: root.bgSource === "custom" ? "#98b0c8" : "#506070"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    visible: root.bgSource === "custom"
                    text: "\u25CF"
                    font.pixelSize: Math.round(root._fSub * 0.8)
                    color: "#5098d8"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: Math.round(root.width * 0.015)
                anchors.verticalCenter: parent.verticalCenter
                text: root.customPath !== "" ? root.getFileName(root.customPath) : T.t("bg_not_selected", root.lang)
                font.pixelSize: root._fSub
                color: root.customPath !== "" ? "#5098d8" : "#3a5060"
                elide: Text.ElideLeft
                width: root.width * 0.18
                horizontalAlignment: Text.AlignRight
            }

            MouseArea {
                anchors.fill: parent
                onClicked: { root.focusIndex = 4; root.enterPathEditor(); }
            }
        }
    }

    // FILE BROWSER

    FileBrowser {
        id: fileBrowserPanel
        anchors.fill: parent
        z: 10
        visible: false

        onFileSelected: {
            root.customPath = filePath;
            root.bgSource = "custom";
            root.fileBrowserActive = false;
            fileBrowserPanel.close();
            root.forceActiveFocus();
            root.saveSettings();
        }

        onCancelled: {
            root.fileBrowserActive = false;
            fileBrowserPanel.close();
            root.forceActiveFocus();
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
        visible: !root.fileBrowserActive

        Text {
            id: hintText
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (root.defaultExpanded)
                    return T.t("hint_preset_choose", root.lang);
                if (root.focusIndex <= 2)
                    return T.t("hint_onoff_back", root.lang);
                if (root.focusIndex === 3)
                    return T.t("hint_open_preset", root.lang);
                return T.t("hint_browse", root.lang);
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

        // File browser mode — forward keys explicitly
        if (root.fileBrowserActive) {
            fileBrowserPanel.handleKey(event);
            return;
        }

        if (root.defaultExpanded) {
            if (isLeft && root.presetIndex > 0) {
                root.presetIndex--;
            } else if (isRight && root.presetIndex < 4) {
                root.presetIndex++;
            } else if (isAccept) {
                root.bgSource = "preset" + (root.presetIndex + 1);
                root.saveSettings();
            } else if (isBack || isUp) {
                root.defaultExpanded = false;
            } else {
                event.accepted = false;
            }

        // Normal navigation
        } else {
            if (isUp && root.focusIndex > 0) {
                root.focusIndex--;
            } else if (isDown && root.focusIndex < 4) {
                root.focusIndex++;
            } else if (isLeft && root.focusIndex === 1 && root.useArtwork) {
                root.blurIntensity = Math.max(0, root.blurIntensity - 1);
                root.saveSettings();
            } else if (isRight && root.focusIndex === 1 && root.useArtwork) {
                root.blurIntensity = Math.min(10, root.blurIntensity + 1);
                root.saveSettings();
            } else if (isAccept) {
                if (root.focusIndex === 0) {
                    root.useArtwork = !root.useArtwork; root.saveSettings();
                } else if (root.focusIndex === 1) {
                    // Accept on blur cycles +1 (wraps)
                    if (root.useArtwork) {
                        root.blurIntensity = (root.blurIntensity + 1) % 11;
                        root.saveSettings();
                    }
                } else if (root.focusIndex === 2) {
                    root.useVideo = !root.useVideo; root.saveSettings();
                } else if (root.focusIndex === 3) {
                    root.defaultExpanded = true;
                    root.presetIndex = root.getPresetIdx(root.bgSource);
                } else if (root.focusIndex === 4) {
                    root.enterPathEditor();
                }
            } else if ((isRight || isDown) && root.focusIndex === 3) {
                root.defaultExpanded = true;
                root.presetIndex = root.getPresetIdx(root.bgSource);
            } else if (isBack) {
                root.closePanel();
            } else {
                event.accepted = false;
            }
        }
    }

    // FUNCTIONS

    function openPanel() {
        loadSettings();
        visible = true;
        opacity = 0;
        _slideOffset = 0;
        focusIndex = 0;
        defaultExpanded = false;
        fileBrowserActive = false;
        browserIndex = 0;
        forceActiveFocus();
        entranceAnim.start();
    }

    function closePanel() {
        if (exitAnim.running) return;
        saveSettings();
        exitAnim.start();
    }

    function enterPathEditor() {
        fileBrowserActive = true;
        fileBrowserPanel.open(customPath);
    }

    function selectCustomFile(path) {
        customPath = path;
        bgSource = "custom";
        fileBrowserActive = false;
        saveSettings();
    }

    function getFileName(path) {
        if (!path) return "";
        var idx = path.lastIndexOf("/");
        return idx >= 0 ? path.substring(idx + 1) : path;
    }

    function getPresetIdx(src) {
        if (src && src.indexOf("preset") === 0) {
            var n = parseInt(src.replace("preset", ""));
            if (n >= 1 && n <= 5) return n - 1;
        }
        return 0;
    }

    function loadSettings() {
        var art = api.memory.get("bg_use_artwork");
        useArtwork = (art !== "false");

        var vid = api.memory.get("bg_use_video");
        useVideo = (vid !== "false");

        var src = api.memory.get("bg_source");
        if (src && (src.indexOf("preset") === 0 || src === "custom")) {
            bgSource = src;
        } else {
            bgSource = "preset1";
        }

        var cp = api.memory.get("bg_custom_path");
        customPath = (cp && cp !== "") ? cp : "";
        var bi = parseInt(api.memory.get("bg_blur_intensity"));
        blurIntensity = (!isNaN(bi) && bi >= 0 && bi <= 10) ? bi : 5;
    }

    function saveSettings() {
        api.memory.set("bg_use_artwork", useArtwork ? "true" : "false");
        api.memory.set("bg_use_video", useVideo ? "true" : "false");
        api.memory.set("bg_source", bgSource);
        api.memory.set("bg_custom_path", customPath);
        api.memory.set("bg_blur_intensity", blurIntensity.toString());
        root.settingsChanged(useArtwork, useVideo, bgSource, customPath, blurIntensity);
    }
}
