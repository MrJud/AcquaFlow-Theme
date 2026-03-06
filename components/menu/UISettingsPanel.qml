import QtQuick 2.15
import QtGraphicalEffects 1.15
import ".."
import "../../components/config/Translations.js" as T

// UI Settings – inline XMB drill-down panel (PS3 style)
Item {
    id: root
    anchors.fill: parent
    visible: false
    opacity: 0

    // Settings
    property bool platformBarAutoHide: false
    property bool showLogoOutline: true
    property bool showBattery: true
    property bool showWifi: true
    property string screenSizeMode: "auto"   // "auto" | "small" | "large"

    // Language
    property string lang: "it"

    property int focusIndex: 0  // 0=platformBarAutoHide, 1=showLogoOutline, 2=showBattery, 3=showWifi, 4=screenSize

    // Layout (proportional – matching BackgroundSettingsPanel)
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

    signal settingsChanged(bool platformBarAutoHide, bool showLogoOutline, bool showBattery, bool showWifi, string screenSizeMode)
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
                // UI icon - monitor/display
                var mw = w * 0.8, mh = h * 0.55;
                var mx = (w - mw) / 2, my = h * 0.1;
                // Monitor body
                ctx.strokeRect(mx, my, mw, mh);
                // Screen content lines
                ctx.beginPath();
                ctx.moveTo(mx + mw * 0.15, my + mh * 0.3);
                ctx.lineTo(mx + mw * 0.85, my + mh * 0.3);
                ctx.moveTo(mx + mw * 0.15, my + mh * 0.55);
                ctx.lineTo(mx + mw * 0.65, my + mh * 0.55);
                ctx.moveTo(mx + mw * 0.15, my + mh * 0.8);
                ctx.lineTo(mx + mw * 0.45, my + mh * 0.8);
                ctx.stroke();
                // Stand
                ctx.beginPath();
                ctx.moveTo(w * 0.5, my + mh);
                ctx.lineTo(w * 0.5, my + mh + h * 0.15);
                ctx.stroke();
                // Base
                ctx.beginPath();
                ctx.moveTo(w * 0.3, my + mh + h * 0.15);
                ctx.lineTo(w * 0.7, my + mh + h * 0.15);
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
                    // Mini monitor icon
                    var mw = w * 0.8, mh = h * 0.55;
                    var mx = (w - mw) / 2, my = h * 0.15;
                    ctx.strokeRect(mx, my, mw, mh);
                    ctx.beginPath();
                    ctx.moveTo(w * 0.5, my + mh);
                    ctx.lineTo(w * 0.5, my + mh + h * 0.12);
                    ctx.stroke();
                }
            }
        }

        Item { width: Math.round(root.width * 0.008); height: 1 }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Text { text: T.t("ui_title", root.lang); font.pixelSize: root._fTitle; font.bold: true; color: "#d0e0f0" }
            Text { text: T.t("ui_subtitle", root.lang); font.pixelSize: root._fSub; color: "#5878a0" }
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

        // PLATFORM BAR AUTO HIDE (toggle)
        Item {
            id: autoHideRow
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
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            var w = width, h = height;
                            // Eye icon (visibility)
                            ctx.strokeStyle = root.focusIndex === 0 ? "#a0c0dd" : "#5a7a94";
                            ctx.lineWidth = 1.2;
                            ctx.beginPath();
                            ctx.moveTo(0, h * 0.5);
                            ctx.quadraticCurveTo(w * 0.5, h * 0.05, w, h * 0.5);
                            ctx.quadraticCurveTo(w * 0.5, h * 0.95, 0, h * 0.5);
                            ctx.stroke();
                            // Pupil
                            ctx.beginPath();
                            ctx.arc(w * 0.5, h * 0.5, w * 0.15, 0, Math.PI * 2);
                            ctx.fillStyle = root.focusIndex === 0 ? "#a0c0dd" : "#5a7a94";
                            ctx.fill();
                        }
                        onVisibleChanged: if (visible) requestPaint()
                    }
                }

                Text {
                    text: T.t("ui_platformbar_hide", root.lang)
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
                    text: root.platformBarAutoHide ? T.t("on", root.lang) : T.t("off", root.lang)
                    font.pixelSize: root._fSub
                    color: "#5098d8"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: Math.round(root.width * 0.044); height: Math.round(root.height * 0.024)
                    radius: height / 2
                    color: root.platformBarAutoHide ? "#2060a0" : "#1a2840"
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Rectangle {
                        width: parent.height - 4; height: width; radius: width / 2; color: "#d0e0f0"
                        x: root.platformBarAutoHide ? parent.width - width - 2 : 2
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    }
                }
            }
        }

        // LOGO OUTLINE TOGGLE
        Item {
            id: outlineRow
            y: root._rowH + Math.round(root.height * 0.012)
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
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            var w = width, h = height;
                            var clr = root.focusIndex === 1 ? "#a0c0dd" : "#5a7a94";
                            ctx.strokeStyle = clr; ctx.lineWidth = 1.2;
                            // Star/sparkle icon (outline effect)
                            var cx = w * 0.5, cy = h * 0.5;
                            var outerR = w * 0.42, innerR = outerR * 0.4;
                            var spikes = 4;
                            ctx.beginPath();
                            for (var i = 0; i < spikes * 2; i++) {
                                var r = (i % 2 === 0) ? outerR : innerR;
                                var a = (i / (spikes * 2)) * Math.PI * 2 - Math.PI / 2;
                                if (i === 0) ctx.moveTo(cx + r * Math.cos(a), cy + r * Math.sin(a));
                                else ctx.lineTo(cx + r * Math.cos(a), cy + r * Math.sin(a));
                            }
                            ctx.closePath();
                            ctx.stroke();
                        }
                        onVisibleChanged: if (visible) requestPaint()
                    }
                }

                Text {
                    text: T.t("ui_logo_outline", root.lang)
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
                    text: root.showLogoOutline ? T.t("on", root.lang) : T.t("off", root.lang)
                    font.pixelSize: root._fSub
                    color: "#5098d8"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: Math.round(root.width * 0.044); height: Math.round(root.height * 0.024)
                    radius: height / 2
                    color: root.showLogoOutline ? "#2060a0" : "#1a2840"
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Rectangle {
                        width: parent.height - 4; height: width; radius: width / 2; color: "#d0e0f0"
                        x: root.showLogoOutline ? parent.width - width - 2 : 2
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    }
                }
            }
        }

        // --- SEPARATOR ---
        Rectangle {
            x: 0
            y: (root._rowH + Math.round(root.height * 0.012)) * 2 + Math.round(root.height * 0.010)
            width: parent.width * 0.85; height: 1; color: "#0cffffff"
        }

        // SHOW BATTERY (toggle)
        Item {
            id: batteryRow
            y: (root._rowH + Math.round(root.height * 0.012)) * 2 + Math.round(root.height * 0.035)
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
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            var w = width, h = height;
                            var clr = root.focusIndex === 2 ? "#a0c0dd" : "#5a7a94";
                            ctx.strokeStyle = clr; ctx.lineWidth = 1.2;
                            // Battery icon
                            var bw = w * 0.7, bh = h * 0.45;
                            var bx = (w - bw) / 2, by = (h - bh) / 2;
                            ctx.strokeRect(bx, by, bw, bh);
                            ctx.fillStyle = clr;
                            ctx.fillRect(bx + bw, by + bh * 0.25, w * 0.1, bh * 0.5);
                            ctx.fillStyle = clr;
                            ctx.globalAlpha = 0.4;
                            ctx.fillRect(bx + 2, by + 2, (bw - 4) * 0.6, bh - 4);
                            ctx.globalAlpha = 1.0;
                        }
                        onVisibleChanged: if (visible) requestPaint()
                    }
                }

                Text {
                    text: T.t("ui_show_battery", root.lang)
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
                    text: root.showBattery ? T.t("on", root.lang) : T.t("off", root.lang)
                    font.pixelSize: root._fSub
                    color: "#5098d8"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: Math.round(root.width * 0.044); height: Math.round(root.height * 0.024)
                    radius: height / 2
                    color: root.showBattery ? "#2060a0" : "#1a2840"
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Rectangle {
                        width: parent.height - 4; height: width; radius: width / 2; color: "#d0e0f0"
                        x: root.showBattery ? parent.width - width - 2 : 2
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    }
                }
            }
        }

        // SHOW WIFI (toggle)
        Item {
            id: wifiRow
            y: (root._rowH + Math.round(root.height * 0.012)) * 2 + Math.round(root.height * 0.035) + root._rowH + Math.round(root.height * 0.012)
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
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            var w = width, h = height;
                            var clr = root.focusIndex === 3 ? "#a0c0dd" : "#5a7a94";
                            ctx.strokeStyle = clr; ctx.lineWidth = 1.2;
                            // WiFi icon - 3 arcs + dot
                            var cx = w * 0.5, cy = h * 0.85;
                            for (var i = 1; i <= 3; i++) {
                                var r = w * 0.18 * i;
                                ctx.beginPath();
                                ctx.arc(cx, cy, r, -Math.PI * 0.75, -Math.PI * 0.25);
                                ctx.stroke();
                            }
                            ctx.fillStyle = clr;
                            ctx.beginPath();
                            ctx.arc(cx, cy, w * 0.06, 0, Math.PI * 2);
                            ctx.fill();
                        }
                        onVisibleChanged: if (visible) requestPaint()
                    }
                }

                Text {
                    text: T.t("ui_show_wifi", root.lang)
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
                    text: root.showWifi ? T.t("on", root.lang) : T.t("off", root.lang)
                    font.pixelSize: root._fSub
                    color: "#5098d8"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: Math.round(root.width * 0.044); height: Math.round(root.height * 0.024)
                    radius: height / 2
                    color: root.showWifi ? "#2060a0" : "#1a2840"
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Rectangle {
                        width: parent.height - 4; height: width; radius: width / 2; color: "#d0e0f0"
                        x: root.showWifi ? parent.width - width - 2 : 2
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    }
                }
            }
        }

        // SCREEN SIZE (cycle: Auto → Small → Large)
        Item {
            id: screenSizeRow
            y: (root._rowH + Math.round(root.height * 0.012)) * 2 + Math.round(root.height * 0.035) + (root._rowH + Math.round(root.height * 0.012)) * 2
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
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            var w = width, h = height;
                            var clr = root.focusIndex === 4 ? "#a0c0dd" : "#5a7a94";
                            ctx.strokeStyle = clr; ctx.lineWidth = 1.2;
                            // Monitor icon
                            ctx.strokeRect(w * 0.1, h * 0.1, w * 0.8, h * 0.55);
                            // Stand
                            ctx.beginPath();
                            ctx.moveTo(w * 0.35, h * 0.65);
                            ctx.lineTo(w * 0.3, h * 0.88);
                            ctx.moveTo(w * 0.65, h * 0.65);
                            ctx.lineTo(w * 0.7, h * 0.88);
                            ctx.moveTo(w * 0.25, h * 0.88);
                            ctx.lineTo(w * 0.75, h * 0.88);
                            ctx.stroke();
                        }
                        onVisibleChanged: if (visible) requestPaint()
                    }
                }

                Text {
                    text: T.t("ui_screen_size", root.lang)
                    font.pixelSize: root._fItem
                    color: "#98b0c8"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Right side: current value label (cycles on Accept)
            Text {
                anchors.right: parent.right
                anchors.rightMargin: Math.round(root.width * 0.015)
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: root._fSub
                color: "#5098d8"
                text: {
                    if (root.screenSizeMode === "small")  return T.t("ui_screen_small",  root.lang);
                    if (root.screenSizeMode === "medium") return T.t("ui_screen_medium", root.lang);
                    if (root.screenSizeMode === "large")  return T.t("ui_screen_large",  root.lang);
                    if (root.screenSizeMode === "xlarge") return T.t("ui_screen_xlarge", root.lang);
                    return T.t("ui_screen_auto", root.lang);
                }
            }
        }
    }

    // LEGEND

    Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Math.round(root.height * 0.025)
        anchors.right: parent.right
        anchors.rightMargin: Math.round(root.width * 0.025)
        font.pixelSize: Math.max(11, Math.round(root.height * 0.016))
        color: "#ffffff"
        opacity: 1.0
        text: T.t("hint_toggle", root.lang)
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

        if (isLeft || isRight) {
            // Block dpad L/R so they don't bubble to menu tab switcher
            event.accepted = true;
            return;
        }

        if (isUp && root.focusIndex > 0) {
            root.focusIndex--;
        } else if (isDown && root.focusIndex < 4) {
            root.focusIndex++;
        } else if (isAccept) {
            if (root.focusIndex === 0) {
                root.platformBarAutoHide = !root.platformBarAutoHide;
                root.saveSettings();
            } else if (root.focusIndex === 1) {
                root.showLogoOutline = !root.showLogoOutline;
                root.saveSettings();
            } else if (root.focusIndex === 2) {
                root.showBattery = !root.showBattery;
                root.saveSettings();
            } else if (root.focusIndex === 3) {
                root.showWifi = !root.showWifi;
                root.saveSettings();
            } else if (root.focusIndex === 4) {
                // Cycle: auto → small → medium → large → xlarge → auto
                if (root.screenSizeMode === "auto")      root.screenSizeMode = "small";
                else if (root.screenSizeMode === "small")  root.screenSizeMode = "medium";
                else if (root.screenSizeMode === "medium") root.screenSizeMode = "large";
                else if (root.screenSizeMode === "large")  root.screenSizeMode = "xlarge";
                else root.screenSizeMode = "auto";
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
        forceActiveFocus();
        entranceAnim.start();
    }

    function closePanel() {
        if (exitAnim.running) return;
        saveSettings();
        exitAnim.start();
    }

    function loadSettings() {
        var ah = api.memory.get("platformbar_autohide");
        platformBarAutoHide = (ah === "true");
        var ol = api.memory.get("ui_logo_outline");
        showLogoOutline = (ol === null || ol === undefined || ol === "") ? true : (ol === "true");
        var sb = api.memory.get("ui_show_battery");
        showBattery = (sb === null || sb === undefined || sb === "") ? true : (sb === "true");
        var sw = api.memory.get("ui_show_wifi");
        showWifi = (sw === null || sw === undefined || sw === "") ? true : (sw === "true");
        var ss = api.memory.get("ui_screen_size");
        if (ss === "xxlarge") ss = "xlarge";  // migrate old value
        screenSizeMode = (ss === "small" || ss === "medium" || ss === "large" || ss === "xlarge") ? ss : "auto";
    }

    function saveSettings() {
        api.memory.set("platformbar_autohide", platformBarAutoHide ? "true" : "false");
        api.memory.set("ui_logo_outline", showLogoOutline ? "true" : "false");
        api.memory.set("ui_show_battery", showBattery ? "true" : "false");
        api.memory.set("ui_show_wifi", showWifi ? "true" : "false");
        api.memory.set("ui_screen_size", screenSizeMode);
        root.settingsChanged(platformBarAutoHide, showLogoOutline, showBattery, showWifi, screenSizeMode);
    }
}
