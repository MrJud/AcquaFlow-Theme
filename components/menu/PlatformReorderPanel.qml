import QtQuick 2.15
import ".."
import "../../components/config/Translations.js" as T

// Platform reorder – inline XMB drill-down panel (PS3 style)
Item {
    id: root
    anchors.fill: parent
    visible: false
    opacity: 0

    property var collections: null
    property int gcGameCount: 0
    property bool lastPlayedVisible: false
    property bool raVisible: true
    property bool favouriteVisible: false
    property bool isGrabbing: false
    property int currentIdx: 0

    // Startup platform: "lastplayed", "favourites", "first_platform"
    property string startupPlatform: "first_platform"

    // Language
    property string lang: "it"
    // LP/Fav order: false = LP first, Fav second; true = Fav first, LP second
    property bool lpFavSwapped: false

    // Layout proportionals (XMB metrics)
    readonly property real _contentX:  Math.round(width * 0.195)
    readonly property real _headerY:   Math.round(height * 0.125)
    readonly property real _listY:     _headerY + Math.round(height * 0.110)
    readonly property real _bigIconSz: Math.round(height * 0.100)
    readonly property real _smIconSz:  Math.round(height * 0.036)
    readonly property real _curIconSz: Math.round(height * 0.048)
    readonly property real _itemH:     Math.round(height * 0.054)
    readonly property real _fTitle:    Math.max(14, Math.round(height * 0.025))
    readonly property real _fSub:      Math.max(10, Math.round(height * 0.016))
    readonly property real _fItem:     Math.max(12, Math.round(height * 0.021))
    readonly property real _fItemSel:  Math.max(14, Math.round(height * 0.026))

    signal orderSaved(var orderArray, bool lpVisible, bool raVis, bool favVis)
    signal closed()

    ListModel { id: platformModel }

    property bool startupFocused: false
    property bool lpFocused: false
    property bool favFocused: false

    // Block touch events from falling through to menu
    MouseArea { anchors.fill: parent; z: -1 }

    // Slide offset for entrance/exit animation
    property real _slideOffset: 0

    // LARGE ICON (top-left decorative)

    Rectangle {
        x: Math.round(root.width * 0.055)
        y: Math.round(root.height * 0.055)
        width: root._bigIconSz
        height: root._bigIconSz
        radius: width * 0.24
        color: "#12ffffff"

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: "#0affffff"
            border.width: 1
        }

        Text {
            anchors.centerIn: parent
            text: "\u25C6"
            font.pixelSize: Math.round(parent.width * 0.42)
            color: "#8aadcc"
        }
    }

    // BREADCRUMB HEADER

    Row {
        id: breadcrumb
        x: root._contentX + root._slideOffset
        y: root._headerY
        spacing: Math.round(root.width * 0.012)

        // Small platform icon (previous level)
        Rectangle {
            width: root._smIconSz
            height: width
            radius: width * 0.5
            color: "#10ffffff"
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.centerIn: parent
                text: "\u25C6"
                font.pixelSize: Math.round(parent.width * 0.50)
                color: "#5a7a94"
            }
        }

        // Back arrow
        Text {
            text: "\u25C2"
            font.pixelSize: Math.round(root.height * 0.030)
            color: "#506a80"
            anchors.verticalCenter: parent.verticalCenter
        }

        // Current level icon (larger)
        Rectangle {
            width: root._curIconSz
            height: width
            radius: width * 0.24
            color: "#18ffffff"
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.centerIn: parent
                text: "\u2699"
                font.pixelSize: Math.round(parent.width * 0.48)
                color: "#a0c0dd"
            }
        }

        Item { width: Math.round(root.width * 0.008); height: 1 }

        // Title + subtitle
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                text: T.t("reorder_platforms", root.lang)
                font.pixelSize: root._fTitle
                font.bold: true
                color: "#d0e0f0"
            }

            Text {
                text: T.t("reorder_platforms_sub", root.lang)
                font.pixelSize: root._fSub
                color: "#5878a0"
            }
        }
    }

    // Back button (tap breadcrumb to go back)
    MouseArea {
        x: breadcrumb.x
        y: breadcrumb.y - Math.round(root.height * 0.01)
        width: Math.min(breadcrumb.width, root.width * 0.35)
        height: breadcrumb.height + Math.round(root.height * 0.02)
        onClicked: root.closePanel()
    }

    // Separator below header
    Rectangle {
        x: root._contentX + root._slideOffset
        y: root._headerY + Math.round(root.height * 0.068)
        width: root.width * 0.54
        height: 1
        color: "#0cffffff"
    }

    // CONTENT AREA

    Item {
        id: contentArea
        x: root._contentX + root._slideOffset
        y: root._listY
        width: root.width * 0.55
        height: root.height - y - Math.round(root.height * 0.045)
        clip: true

        // Startup Platform selector
        Item {
            id: startupArea
            y: 0
            width: parent.width
            height: Math.round(root.height * 0.048)

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: root.startupFocused ? "#0affffff" : "transparent"
                border.color: root.startupFocused ? "#1a3860" : "transparent"
                border.width: root.startupFocused ? 1 : 0
                Behavior on color { ColorAnimation { duration: 180 } }
                Behavior on border.color { ColorAnimation { duration: 180 } }
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: Math.round(root.width * 0.012)

                Rectangle {
                    width: root._smIconSz
                    height: width
                    radius: width * 0.24
                    color: "#0cffffff"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "\u25B7"
                        font.pixelSize: Math.round(parent.width * 0.50)
                        color: "#78a8d0"
                    }
                }

                Text {
                    text: T.t("plat_startup", root.lang)
                    font.pixelSize: root._fItem
                    font.bold: true
                    color: "#b0c8e0"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: Math.round(root.width * 0.015)
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    if (root.startupPlatform === "lastplayed") return "\u25C2  " + T.t("plat_lastplayed", root.lang) + "  \u25B8";
                    if (root.startupPlatform === "favourites") return "\u25C2  " + T.t("plat_favorites", root.lang) + "  \u25B8";
                    return "\u25C2  " + T.t("plat_first", root.lang) + "  \u25B8";
                }
                font.pixelSize: root._fSub
                color: root.startupFocused ? "#60b0e0" : "#5878a0"
                Behavior on color { ColorAnimation { duration: 180 } }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.cycleStartupPlatform(1)
            }
        }

        // Separator after startup
        Rectangle {
            id: startupSep
            y: startupArea.y + startupArea.height + Math.round(root.height * 0.015)
            width: parent.width
            height: 1
            color: "#08ffffff"
        }

        // Last Played / Favourites swappable pair
        Item {
            id: lpFavArea
            y: startupSep.y + startupSep.height + Math.round(root.height * 0.015)
            width: parent.width
            height: Math.round(root.height * 0.048) * 2 + Math.round(root.height * 0.004)

            Item {
                id: slot1
                y: 0
                width: parent.width
                height: Math.round(root.height * 0.048)

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: root.lpFocused ? "#0affffff" : "transparent"
                    border.color: root.lpFocused ? "#1a3860" : "transparent"
                    border.width: root.lpFocused ? 1 : 0
                    Behavior on color { ColorAnimation { duration: 180 } }
                    Behavior on border.color { ColorAnimation { duration: 180 } }
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Math.round(root.width * 0.012)

                    Rectangle {
                        width: root._smIconSz
                        height: width
                        radius: width * 0.24
                        color: "#0cffffff"
                        anchors.verticalCenter: parent.verticalCenter

                        Canvas {
                            anchors.centerIn: parent
                            width: Math.round(parent.width * 0.55)
                            height: width
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();
                                var w = width, h = height;
                                ctx.strokeStyle = (root.lpFavSwapped ? root.favouriteVisible : root.lastPlayedVisible) ? "#78a8d0" : "#3a5060";
                                ctx.lineWidth = 1.2;
                                ctx.fillStyle = "transparent";
                                if (root.lpFavSwapped) {
                                    // Heart
                                    var cx = w/2, top = h*0.22, bot = h*0.82;
                                    ctx.beginPath();
                                    ctx.moveTo(cx, bot);
                                    ctx.bezierCurveTo(cx - w*0.5, h*0.48, cx - w*0.42, top - h*0.08, cx, top + h*0.18);
                                    ctx.bezierCurveTo(cx + w*0.42, top - h*0.08, cx + w*0.5, h*0.48, cx, bot);
                                    ctx.stroke();
                                } else {
                                    // Clock
                                    var r = w*0.42;
                                    ctx.beginPath();
                                    ctx.arc(w/2, h/2, r, 0, Math.PI*2);
                                    ctx.stroke();
                                    ctx.beginPath();
                                    ctx.moveTo(w/2, h/2);
                                    ctx.lineTo(w/2, h/2 - r*0.65);
                                    ctx.moveTo(w/2, h/2);
                                    ctx.lineTo(w/2 + r*0.5, h/2);
                                    ctx.stroke();
                                }
                            }
                            property bool _dep1: root.lpFavSwapped
                            property bool _dep2: root.lpFavSwapped ? root.favouriteVisible : root.lastPlayedVisible
                            on_Dep1Changed: requestPaint()
                            on_Dep2Changed: requestPaint()
                        }
                    }

                    Text {
                        text: root.lpFavSwapped ? T.t("plat_favorites", root.lang) : T.t("plat_lastplayed", root.lang)
                        font.pixelSize: root._fItem
                        color: (root.lpFavSwapped ? root.favouriteVisible : root.lastPlayedVisible) ? "#98b0c8" : "#506070"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Swap hint + Toggle switch
                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: Math.round(root.width * 0.015)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Math.round(root.width * 0.010)

                    Canvas {
                        width: Math.round(root.height * 0.022)
                        height: width
                        anchors.verticalCenter: parent.verticalCenter
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            var w = width, h = height, cx = w/2;
                            var col = root.lpFocused ? "#5098d8" : "#3a5060";
                            ctx.strokeStyle = col; ctx.lineWidth = 1.2;
                            // Up arrow
                            ctx.beginPath();
                            ctx.moveTo(cx, h*0.08);
                            ctx.lineTo(cx - w*0.3, h*0.32);
                            ctx.moveTo(cx, h*0.08);
                            ctx.lineTo(cx + w*0.3, h*0.32);
                            ctx.stroke();
                            // Down arrow
                            ctx.beginPath();
                            ctx.moveTo(cx, h*0.92);
                            ctx.lineTo(cx - w*0.3, h*0.68);
                            ctx.moveTo(cx, h*0.92);
                            ctx.lineTo(cx + w*0.3, h*0.68);
                            ctx.stroke();
                            // Center line
                            ctx.beginPath();
                            ctx.moveTo(cx, h*0.12); ctx.lineTo(cx, h*0.88);
                            ctx.stroke();
                        }
                        property bool _f: root.lpFocused
                        on_FChanged: requestPaint()
                    }

                    Rectangle {
                        width: Math.round(root.width * 0.044)
                        height: Math.round(root.height * 0.024)
                        radius: height / 2
                        color: (root.lpFavSwapped ? root.favouriteVisible : root.lastPlayedVisible) ? "#2060a0" : "#1a2840"
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 200 } }

                        Rectangle {
                            width: parent.height - 4
                            height: width
                            radius: width / 2
                            color: "#d0e0f0"
                            x: (root.lpFavSwapped ? root.favouriteVisible : root.lastPlayedVisible) ? parent.width - width - 2 : 2
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.lpFavSwapped = !root.lpFavSwapped;
                        root.saveOrder();
                    }
                }
            }

            // Second item (the other one)
            Item {
                id: slot2
                y: slot1.height + Math.round(root.height * 0.004)
                width: parent.width
                height: Math.round(root.height * 0.048)

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: root.favFocused ? "#0affffff" : "transparent"
                    border.color: root.favFocused ? "#1a3860" : "transparent"
                    border.width: root.favFocused ? 1 : 0
                    Behavior on color { ColorAnimation { duration: 180 } }
                    Behavior on border.color { ColorAnimation { duration: 180 } }
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Math.round(root.width * 0.012)

                    Rectangle {
                        width: root._smIconSz
                        height: width
                        radius: width * 0.24
                        color: "#0cffffff"
                        anchors.verticalCenter: parent.verticalCenter

                        Canvas {
                            anchors.centerIn: parent
                            width: Math.round(parent.width * 0.55)
                            height: width
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();
                                var w = width, h = height;
                                ctx.strokeStyle = (root.lpFavSwapped ? root.lastPlayedVisible : root.favouriteVisible) ? "#78a8d0" : "#3a5060";
                                ctx.lineWidth = 1.2;
                                ctx.fillStyle = "transparent";
                                if (root.lpFavSwapped) {
                                    // Clock
                                    var r = w*0.42;
                                    ctx.beginPath();
                                    ctx.arc(w/2, h/2, r, 0, Math.PI*2);
                                    ctx.stroke();
                                    ctx.beginPath();
                                    ctx.moveTo(w/2, h/2);
                                    ctx.lineTo(w/2, h/2 - r*0.65);
                                    ctx.moveTo(w/2, h/2);
                                    ctx.lineTo(w/2 + r*0.5, h/2);
                                    ctx.stroke();
                                } else {
                                    // Heart
                                    var cx = w/2, top = h*0.22, bot = h*0.82;
                                    ctx.beginPath();
                                    ctx.moveTo(cx, bot);
                                    ctx.bezierCurveTo(cx - w*0.5, h*0.48, cx - w*0.42, top - h*0.08, cx, top + h*0.18);
                                    ctx.bezierCurveTo(cx + w*0.42, top - h*0.08, cx + w*0.5, h*0.48, cx, bot);
                                    ctx.stroke();
                                }
                            }
                            property bool _dep1: root.lpFavSwapped
                            property bool _dep2: root.lpFavSwapped ? root.lastPlayedVisible : root.favouriteVisible
                            on_Dep1Changed: requestPaint()
                            on_Dep2Changed: requestPaint()
                        }
                    }

                    Text {
                        text: root.lpFavSwapped ? T.t("plat_lastplayed", root.lang) : T.t("plat_favorites", root.lang)
                        font.pixelSize: root._fItem
                        color: (root.lpFavSwapped ? root.lastPlayedVisible : root.favouriteVisible) ? "#98b0c8" : "#506070"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: Math.round(root.width * 0.015)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Math.round(root.width * 0.010)

                    Canvas {
                        width: Math.round(root.height * 0.022)
                        height: width
                        anchors.verticalCenter: parent.verticalCenter
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            var w = width, h = height, cx = w/2;
                            var col = root.favFocused ? "#5098d8" : "#3a5060";
                            ctx.strokeStyle = col; ctx.lineWidth = 1.2;
                            // Up arrow
                            ctx.beginPath();
                            ctx.moveTo(cx, h*0.08);
                            ctx.lineTo(cx - w*0.3, h*0.32);
                            ctx.moveTo(cx, h*0.08);
                            ctx.lineTo(cx + w*0.3, h*0.32);
                            ctx.stroke();
                            // Down arrow
                            ctx.beginPath();
                            ctx.moveTo(cx, h*0.92);
                            ctx.lineTo(cx - w*0.3, h*0.68);
                            ctx.moveTo(cx, h*0.92);
                            ctx.lineTo(cx + w*0.3, h*0.68);
                            ctx.stroke();
                            // Center line
                            ctx.beginPath();
                            ctx.moveTo(cx, h*0.12); ctx.lineTo(cx, h*0.88);
                            ctx.stroke();
                        }
                        property bool _f: root.favFocused
                        on_FChanged: requestPaint()
                    }

                    Rectangle {
                        width: Math.round(root.width * 0.044)
                        height: Math.round(root.height * 0.024)
                        radius: height / 2
                        color: (root.lpFavSwapped ? root.lastPlayedVisible : root.favouriteVisible) ? "#2060a0" : "#1a2840"
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 200 } }

                        Rectangle {
                            width: parent.height - 4
                            height: width
                            radius: width / 2
                            color: "#d0e0f0"
                            x: (root.lpFavSwapped ? root.lastPlayedVisible : root.favouriteVisible) ? parent.width - width - 2 : 2
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.lpFavSwapped = !root.lpFavSwapped;
                        root.saveOrder();
                    }
                }
            }
        }

        // Separator
        Rectangle {
            id: listSep
            y: lpFavArea.y + lpFavArea.height + Math.round(root.height * 0.005)
            width: parent.width
            height: 1
            color: "#08ffffff"
        }

        // Platform list
        ListView {
            id: listView
            y: listSep.y + listSep.height + Math.round(root.height * 0.005)
            width: parent.width
            height: controlHintsOuter.y - contentArea.y - y - Math.round(root.height * 0.004)
            model: platformModel
            clip: true
            currentIndex: root.currentIdx
            spacing: 2
            interactive: !root.isGrabbing

            displaced: Transition {
                NumberAnimation { properties: "y"; duration: 250; easing.type: Easing.OutCubic }
            }

            move: Transition {
                NumberAnimation { properties: "y"; duration: 250; easing.type: Easing.OutCubic }
            }

            delegate: Item {
                id: itemDel
                width: listView.width
                height: root._itemH

                property bool isSel: !root.startupFocused && !root.lpFocused && !root.favFocused && root.currentIdx === index
                property bool isGrabbed: root.isGrabbing && root.currentIdx === index

                // Selection/grab highlight
                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: itemDel.isGrabbed ? "#16ffffff" : (itemDel.isSel ? "#0affffff" : "transparent")
                    border.color: itemDel.isGrabbed ? "#1a5090" : "transparent"
                    border.width: itemDel.isGrabbed ? 1 : 0

                    Behavior on color { ColorAnimation { duration: 180 } }
                    Behavior on border.color { ColorAnimation { duration: 180 } }
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Math.round(root.width * 0.004)
                    spacing: Math.round(root.width * 0.010)

                    // Item icon
                    Rectangle {
                        property real sz: itemDel.isSel ? Math.round(root.height * 0.036) : Math.round(root.height * 0.026)
                        width: sz
                        height: sz
                        radius: Math.round(sz * 0.22)
                        color: itemDel.isGrabbed ? "#1cffffff" : (itemDel.isSel ? "#10ffffff" : "#06ffffff")
                        anchors.verticalCenter: parent.verticalCenter

                        Behavior on width  { NumberAnimation { duration: 220 } }
                        Behavior on height { NumberAnimation { duration: 220 } }

                        Text {
                            anchors.centerIn: parent
                            text: itemDel.isGrabbed ? "\u2195" : "\u25B8"
                            font.pixelSize: Math.round(parent.width * 0.46)
                            color: itemDel.isGrabbed ? "#5098d8" : (itemDel.isSel ? "#a0bcd8" : "#4a6478")

                            Behavior on color { ColorAnimation { duration: 180 } }
                        }
                    }

                    // Platform name
                    Text {
                        text: model.name
                        font.pixelSize: itemDel.isSel ? root._fItemSel : root._fItem
                        font.bold: itemDel.isSel
                        color: itemDel.isGrabbed ? "#ffffff" : (itemDel.isSel ? "#d0e0f0" : "#7088a0")
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                        width: root.width * 0.28

                        Behavior on color { ColorAnimation { duration: 180 } }
                    }
                }

                // Game count + back covers indicator (right side)
                Column {
                    anchors.right: parent.right
                    anchors.rightMargin: Math.round(root.width * 0.015)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1

                    Text {
                        anchors.right: parent.right
                        text: model.gameCount + T.t("games_suffix", root.lang)
                        font.pixelSize: Math.max(10, Math.round(root.height * 0.015))
                        color: "#405060"
                    }

                    Text {
                        anchors.right: parent.right
                        text: {
                            var p = api.memory.get("boxback_path_" + model.shortName.toLowerCase());
                            return (p && p !== "") ? "✓ " + T.t("plat_backcovers", root.lang) : T.t("plat_select_bc", root.lang);
                        }
                        font.pixelSize: Math.max(9, Math.round(root.height * 0.013))
                        color: {
                            var p = api.memory.get("boxback_path_" + model.shortName.toLowerCase());
                            return (p && p !== "") ? "#4a90c0" : "#385060";
                        }
                    }
                }

                MouseArea {
                    id: delegateTouch
                    anchors.fill: parent
                    pressAndHoldInterval: 400

                    property real _startY: 0
                    property bool _dragging: false

                    onClicked: {
                        root.lpFocused = false;
                        root.currentIdx = index;
                        if (root.isGrabbing) {
                            root.isGrabbing = false;
                            root.saveOrder();
                        } else {
                            root.isGrabbing = true;
                        }
                    }

                    onPressAndHold: {
                        root.lpFocused = false;
                        root.currentIdx = index;
                        root.isGrabbing = true;
                        _startY = mouseY;
                        _dragging = true;
                    }

                    onMouseYChanged: {
                        if (!_dragging) return;
                        var dy = mouseY - _startY;
                        var threshold = root._itemH * 0.6;
                        if (dy < -threshold && root.currentIdx > 0) {
                            platformModel.move(root.currentIdx, root.currentIdx - 1, 1);
                            root.currentIdx--;
                            _startY = mouseY;
                        } else if (dy > threshold && root.currentIdx < platformModel.count - 1) {
                            platformModel.move(root.currentIdx, root.currentIdx + 1, 1);
                            root.currentIdx++;
                            _startY = mouseY;
                        }
                    }

                    onReleased: {
                        if (_dragging) {
                            _dragging = false;
                            root.isGrabbing = false;
                            root.saveOrder();
                        }
                    }
                }
            }
        }

        // Control hints
        Item {
            id: controlHints
            y: parent.height - height
            width: root.width - root._contentX - root._slideOffset
            height: Math.round(root.height * 0.035)

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Math.round(root.width * 0.025)
                text: root.startupFocused
                    ? T.t("hint_startup_choose", root.lang)
                    : (root.lpFocused
                        ? T.t("hint_swap", root.lang)
                        : (root.favFocused
                            ? T.t("hint_swap", root.lang)
                            : (root.isGrabbing
                                ? T.t("hint_move", root.lang)
                                : T.t("hint_grab", root.lang))))
                font.pixelSize: Math.max(11, Math.round(root.height * 0.016))
                color: "#ffffff"
            }
        }

    }

    // Control hints (outside contentArea to avoid clip)
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
            text: root.startupFocused
                ? T.t("hint_startup_choose", root.lang)
                : (root.lpFocused
                    ? T.t("hint_swap", root.lang)
                    : (root.favFocused
                        ? T.t("hint_swap", root.lang)
                        : (root.isGrabbing
                            ? T.t("hint_move", root.lang)
                            : T.t("hint_grab", root.lang))))
            font.pixelSize: Math.max(11, Math.round(root.height * 0.016))
            color: "#ffffff"
        }
    }

    // ANIMATIONS

    ParallelAnimation {
        id: entranceAnim
        NumberAnimation {
            target: root; property: "opacity"
            from: 0; to: 1; duration: 380
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: root; property: "_slideOffset"
            from: root.width * 0.04; to: 0; duration: 420
            easing.type: Easing.OutCubic
        }
    }

    ParallelAnimation {
        id: exitAnim
        NumberAnimation {
            target: root; property: "opacity"
            from: 1; to: 0; duration: 250
            easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: root; property: "_slideOffset"
            from: 0; to: root.width * 0.04; duration: 250
            easing.type: Easing.InCubic
        }
        onFinished: {
            root.visible = false;
            root.closed();
        }
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
        var isX      = (event.key === 1048578);
        var isY      = (event.key === 1048579);

        // Startup Platform selector
        if (root.startupFocused) {
            if (isDown) {
                root.startupFocused = false;
                root.lpFocused = true;
            } else if (isLeft) {
                root.cycleStartupPlatform(-1);
            } else if (isRight || isAccept) {
                root.cycleStartupPlatform(1);
            } else if (isBack) {
                root.closePanel();
            } else {
                event.accepted = false;
            }

        // LP/Fav slot 1
        } else if (root.lpFocused) {
            if (isUp) {
                root.lpFocused = false;
                root.startupFocused = true;
            } else if (isDown) {
                root.lpFocused = false;
                root.favFocused = true;
            } else if (isAccept) {
                if (root.lpFavSwapped) {
                    root.favouriteVisible = !root.favouriteVisible;
                } else {
                    root.lastPlayedVisible = !root.lastPlayedVisible;
                }
                root.saveOrder();
            } else if (isY) {
                root.lpFavSwapped = !root.lpFavSwapped;
                root.saveOrder();
            } else if (isBack) {
                root.closePanel();
            } else {
                event.accepted = false;
            }

        // LP/Fav slot 2
        } else if (root.favFocused) {
            if (isUp) {
                root.favFocused = false;
                root.lpFocused = true;
            } else if (isDown) {
                root.favFocused = false;
                root.currentIdx = 0;
            } else if (isAccept) {
                if (root.lpFavSwapped) {
                    root.lastPlayedVisible = !root.lastPlayedVisible;
                } else {
                    root.favouriteVisible = !root.favouriteVisible;
                }
                root.saveOrder();
            } else if (isY) {
                root.lpFavSwapped = !root.lpFavSwapped;
                root.saveOrder();
            } else if (isBack) {
                root.closePanel();
            } else {
                event.accepted = false;
            }

        // Platform list: grabbing
        } else if (root.isGrabbing) {
            if (isUp && root.currentIdx > 0) {
                platformModel.move(root.currentIdx, root.currentIdx - 1, 1);
                root.currentIdx--;
            } else if (isDown && root.currentIdx < platformModel.count - 1) {
                platformModel.move(root.currentIdx, root.currentIdx + 1, 1);
                root.currentIdx++;
            } else if (isAccept || isBack) {
                root.isGrabbing = false;
                root.saveOrder();
            } else {
                event.accepted = false;
            }

        // Platform list: normal
        } else {
            if (isUp && root.currentIdx > 0) {
                root.currentIdx--;
            } else if (isUp && root.currentIdx === 0) {
                root.favFocused = true;
            } else if (isDown && root.currentIdx < platformModel.count - 1) {
                root.currentIdx++;
            } else if (isAccept) {
                root.isGrabbing = true;
            } else if (isBack) {
                root.closePanel();
            } else {
                event.accepted = false;
            }
        }
    }

    // FUNCTIONS

    function openPanel() {
        populate();
        visible = true;
        opacity = 0;
        _slideOffset = 0;
        currentIdx = 0;
        isGrabbing = false;
        startupFocused = true;
        lpFocused = false;
        favFocused = false;
        forceActiveFocus();
        entranceAnim.start();
    }

    function closePanel() {
        if (exitAnim.running) return;
        saveOrder();
        exitAnim.start();
    }

    function cycleStartupPlatform(dir) {
        var opts = ["lastplayed", "favourites", "first_platform"];
        var idx = opts.indexOf(root.startupPlatform);
        if (idx < 0) idx = 0;
        idx = (idx + dir + opts.length) % opts.length;
        root.startupPlatform = opts[idx];
        root.saveOrder();
    }

    function populate() {
        platformModel.clear();
        if (!collections) return;

        var swapSetting = api.memory.get("lpfav_swapped");
        lpFavSwapped = (swapSetting === "true");

        // RA always visible
        raVisible = true;

        // LP & Fav visibility
        var lpSetting = api.memory.get("lastplayed_visible");
        lastPlayedVisible = (lpSetting === "true");
        var favSetting = api.memory.get("favourite_visible");
        favouriteVisible = (favSetting === "true");

        // Startup platform
        var spSetting = api.memory.get("startup_platform");
        if (spSetting && spSetting !== "") {
            startupPlatform = spSetting;
        } else {
            startupPlatform = "first_platform";
        }

        var savedOrderStr = api.memory.get("platform_order");
        var savedOrder = [];
        if (savedOrderStr && savedOrderStr !== "") {
            try { savedOrder = JSON.parse(savedOrderStr); } catch(e) { savedOrder = []; }
        }

        var allPlatforms = [];
        for (var i = 0; i < collections.count; i++) {
            var c = collections.get(i);
            if (c && c.games && c.games.count > 0) {
                allPlatforms.push({ shortName: c.shortName, name: c.name, gameCount: c.games.count });
            }
        }

        if (gcGameCount > 0) {
            var insertIdx = allPlatforms.length;
            for (var w = 0; w < allPlatforms.length; w++) {
                if (allPlatforms[w].shortName.toLowerCase() === "wii") {
                    insertIdx = w + 1;
                    break;
                }
            }
            allPlatforms.splice(insertIdx, 0, { shortName: "gc", name: "GameCube", gameCount: gcGameCount });
        }

        var lookup = {};
        for (var a = 0; a < allPlatforms.length; a++) {
            lookup[allPlatforms[a].shortName] = allPlatforms[a];
        }

        var added = {};
        for (var s = 0; s < savedOrder.length; s++) {
            var sn = savedOrder[s];
            if (lookup[sn] && !added[sn]) {
                platformModel.append(lookup[sn]);
                added[sn] = true;
            }
        }

        for (var r = 0; r < allPlatforms.length; r++) {
            if (!added[allPlatforms[r].shortName]) {
                platformModel.append(allPlatforms[r]);
                added[allPlatforms[r].shortName] = true;
            }
        }
    }

    function saveOrder() {
        var order = [];
        for (var i = 0; i < platformModel.count; i++) {
            order.push(platformModel.get(i).shortName);
        }
        api.memory.set("platform_order", JSON.stringify(order));
        api.memory.set("lastplayed_visible", lastPlayedVisible ? "true" : "false");
        api.memory.set("ra_platform_visible", "true");
        api.memory.set("favourite_visible", favouriteVisible ? "true" : "false");
        api.memory.set("lpfav_swapped", lpFavSwapped ? "true" : "false");
        api.memory.set("startup_platform", startupPlatform);
        root.orderSaved(order, lastPlayedVisible, true, favouriteVisible);
    }
}
