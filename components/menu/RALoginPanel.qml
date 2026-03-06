import QtQuick 2.15
import ".."
import "../../components/config/Translations.js" as T

// RetroAchievements Login – inline XMB drill-down panel (like PlatformReorderPanel)
Item {
    id: root
    anchors.fill: parent
    visible: false
    opacity: 0

    // Layout proportionals (XMB metrics)
    readonly property real _contentX:  Math.round(width * 0.195)
    readonly property real _headerY:   Math.round(height * 0.125)
    readonly property real _listY:     _headerY + Math.round(height * 0.110)
    readonly property real _bigIconSz: Math.round(height * 0.100)
    readonly property real _smIconSz:  Math.round(height * 0.036)
    readonly property real _curIconSz: Math.round(height * 0.048)
    readonly property real _itemH:     Math.round(height * 0.058)
    readonly property real _fTitle:    Math.max(14, Math.round(height * 0.025))
    readonly property real _fSub:      Math.max(10, Math.round(height * 0.016))
    readonly property real _fItem:     Math.max(12, Math.round(height * 0.021))
    readonly property real _fItemSel:  Math.max(14, Math.round(height * 0.026))
    readonly property real _inputH:    Math.round(height * 0.052)

    // 0=username, 1=apikey, 2=link, 3=save, 4=cancel
    property int currentIdx: 0
    property bool editing: false
    property int _authState: 0  // 0=none, 1=verifying, 2=success, 3=error
    property string _authMsg: ""

    // Language
    property string lang: "it"

    signal loginSaved(string username, string apiKey)
    signal closed()

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
            text: "\uD83C\uDFC6"
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

        // Small RA icon (previous level)
        Rectangle {
            width: root._smIconSz
            height: width
            radius: width * 0.5
            color: "#10ffffff"
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.centerIn: parent
                text: "\u2605"
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
                text: "\uD83D\uDD11"
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
                text: T.t("ra_login_title", root.lang)
                font.pixelSize: root._fTitle
                font.bold: true
                color: "#d0e0f0"
            }

            Text {
                text: T.t("ra_login_subtitle", root.lang)
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

        // Username field (idx 0)
        Item {
            id: usernameItem
            y: 0
            width: parent.width
            height: root._itemH

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: root.currentIdx === 0 ? "#0affffff" : "transparent"
                border.color: root.currentIdx === 0 ? "#1a3860" : "transparent"
                border.width: root.currentIdx === 0 ? 1 : 0

                Behavior on color { ColorAnimation { duration: 180 } }
                Behavior on border.color { ColorAnimation { duration: 180 } }
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                spacing: Math.round(root.width * 0.012)

                Rectangle {
                    property real sz: root.currentIdx === 0 ? Math.round(root.height * 0.036) : Math.round(root.height * 0.026)
                    width: sz; height: sz
                    radius: Math.round(sz * 0.22)
                    color: root.currentIdx === 0 ? "#10ffffff" : "#06ffffff"
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on width  { NumberAnimation { duration: 220 } }
                    Behavior on height { NumberAnimation { duration: 220 } }

                    Text {
                        anchors.centerIn: parent
                        text: "\uD83D\uDC64"
                        font.pixelSize: Math.round(parent.width * 0.50)
                        color: root.currentIdx === 0 ? "#a0bcd8" : "#4a6478"
                    }
                }

                Text {
                    text: T.t("ra_username", root.lang)
                    font.pixelSize: root.currentIdx === 0 ? root._fItemSel : root._fItem
                    font.bold: root.currentIdx === 0
                    color: root.currentIdx === 0 ? "#d0e0f0" : "#7088a0"
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on color { ColorAnimation { duration: 180 } }
                }
            }

            // Input field (right side)
            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: Math.round(root.width * 0.25)
                height: root._inputH
                radius: 6
                color: root.editing && root.currentIdx === 0 ? "#0e1c38" : "#0a1528"
                border.color: root.editing && root.currentIdx === 0 ? "#3070b0" : root.currentIdx === 0 ? "#1a3860" : "#101828"
                border.width: root.editing && root.currentIdx === 0 ? 2 : 1

                Behavior on border.color { ColorAnimation { duration: 200 } }

                TextInput {
                    id: usernameInput
                    anchors.fill: parent
                    anchors.margins: Math.round(parent.height * 0.18)
                    font.pixelSize: Math.max(12, Math.round(root.height * 0.020))
                    color: "#d0e0f0"
                    clip: true
                    selectByMouse: false
                    selectionColor: "transparent"
                    selectedTextColor: color
                    activeFocusOnPress: false
                    persistentSelection: false
                    readOnly: !(root.editing && root.currentIdx === 0)
                    cursorVisible: root.editing && root.currentIdx === 0
                    inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData
                    onActiveFocusChanged: {
                        if (activeFocus) { deselect(); cursorPosition = length; }
                    }
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: Math.round(parent.height * 0.18)
                    anchors.verticalCenter: parent.verticalCenter
                    text: T.t("ra_username_ph", root.lang)
                    color: "#303848"
                    font.pixelSize: Math.max(11, Math.round(root.height * 0.018))
                    visible: usernameInput.text === "" && !usernameInput.activeFocus
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (root.currentIdx === 0 && !root.editing) {
                        activateEditing(0);
                    } else {
                        root.currentIdx = 0;
                        deactivateEditing();
                    }
                }
            }
        }

        // API Key field (idx 1)
        Item {
            id: apiKeyItem
            y: usernameItem.y + usernameItem.height + Math.round(root.height * 0.006)
            width: parent.width
            height: root._itemH

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: root.currentIdx === 1 ? "#0affffff" : "transparent"
                border.color: root.currentIdx === 1 ? "#1a3860" : "transparent"
                border.width: root.currentIdx === 1 ? 1 : 0

                Behavior on color { ColorAnimation { duration: 180 } }
                Behavior on border.color { ColorAnimation { duration: 180 } }
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                spacing: Math.round(root.width * 0.012)

                Rectangle {
                    property real sz: root.currentIdx === 1 ? Math.round(root.height * 0.036) : Math.round(root.height * 0.026)
                    width: sz; height: sz
                    radius: Math.round(sz * 0.22)
                    color: root.currentIdx === 1 ? "#10ffffff" : "#06ffffff"
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on width  { NumberAnimation { duration: 220 } }
                    Behavior on height { NumberAnimation { duration: 220 } }

                    Text {
                        anchors.centerIn: parent
                        text: "\uD83D\uDD11"
                        font.pixelSize: Math.round(parent.width * 0.50)
                        color: root.currentIdx === 1 ? "#a0bcd8" : "#4a6478"
                    }
                }

                Text {
                    text: T.t("ra_apikey", root.lang)
                    font.pixelSize: root.currentIdx === 1 ? root._fItemSel : root._fItem
                    font.bold: root.currentIdx === 1
                    color: root.currentIdx === 1 ? "#d0e0f0" : "#7088a0"
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on color { ColorAnimation { duration: 180 } }
                }
            }

            // Input field (right side)
            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: Math.round(root.width * 0.25)
                height: root._inputH
                radius: 6
                color: root.editing && root.currentIdx === 1 ? "#0e1c38" : "#0a1528"
                border.color: root.editing && root.currentIdx === 1 ? "#3070b0" : root.currentIdx === 1 ? "#1a3860" : "#101828"
                border.width: root.editing && root.currentIdx === 1 ? 2 : 1

                Behavior on border.color { ColorAnimation { duration: 200 } }

                TextInput {
                    id: apiKeyInput
                    anchors.fill: parent
                    anchors.margins: Math.round(parent.height * 0.18)
                    font.pixelSize: Math.max(12, Math.round(root.height * 0.020))
                    color: "#d0e0f0"
                    clip: true
                    selectByMouse: false
                    selectionColor: "transparent"
                    selectedTextColor: color
                    activeFocusOnPress: false
                    persistentSelection: false
                    echoMode: TextInput.Password
                    readOnly: !(root.editing && root.currentIdx === 1)
                    cursorVisible: root.editing && root.currentIdx === 1
                    inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData
                    onActiveFocusChanged: {
                        if (activeFocus) { deselect(); cursorPosition = length; }
                    }
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: Math.round(parent.height * 0.18)
                    anchors.verticalCenter: parent.verticalCenter
                    text: T.t("ra_apikey_ph", root.lang)
                    color: "#303848"
                    font.pixelSize: Math.max(11, Math.round(root.height * 0.018))
                    visible: apiKeyInput.text === "" && !apiKeyInput.activeFocus
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (root.currentIdx === 1 && !root.editing) {
                        activateEditing(1);
                    } else {
                        root.currentIdx = 1;
                        deactivateEditing();
                    }
                }
            }
        }

        // Separator
        Rectangle {
            id: fieldSep
            y: apiKeyItem.y + apiKeyItem.height + Math.round(root.height * 0.010)
            width: parent.width
            height: 1
            color: "#08ffffff"
        }

        // API Link (idx 2)
        Item {
            id: linkItem
            y: fieldSep.y + fieldSep.height + Math.round(root.height * 0.006)
            width: parent.width
            height: root._itemH

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: root.currentIdx === 2 ? "#0affffff" : "transparent"
                border.color: root.currentIdx === 2 ? "#1a3860" : "transparent"
                border.width: root.currentIdx === 2 ? 1 : 0

                Behavior on color { ColorAnimation { duration: 180 } }
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                spacing: Math.round(root.width * 0.012)

                Rectangle {
                    property real sz: root.currentIdx === 2 ? Math.round(root.height * 0.036) : Math.round(root.height * 0.026)
                    width: sz; height: sz
                    radius: Math.round(sz * 0.22)
                    color: root.currentIdx === 2 ? "#10ffffff" : "#06ffffff"
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on width  { NumberAnimation { duration: 220 } }
                    Behavior on height { NumberAnimation { duration: 220 } }

                    Text {
                        anchors.centerIn: parent
                        text: "\uD83D\uDD17"
                        font.pixelSize: Math.round(parent.width * 0.46)
                        color: root.currentIdx === 2 ? "#60b0ff" : "#4a6478"
                    }
                }

                Text {
                    text: T.t("ra_get_apikey", root.lang)
                    font.pixelSize: root.currentIdx === 2 ? root._fItemSel : root._fItem
                    font.bold: root.currentIdx === 2
                    color: root.currentIdx === 2 ? "#60b0ff" : "#4090d0"
                    font.underline: true
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on color { ColorAnimation { duration: 180 } }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.currentIdx = 2;
                    Qt.openUrlExternally("https://retroachievements.org/settings#api-keys");
                }
            }
        }

        // Separator 2
        Rectangle {
            id: btnSep
            y: linkItem.y + linkItem.height + Math.round(root.height * 0.010)
            width: parent.width
            height: 1
            color: "#08ffffff"
        }

        // Save button (idx 3)
        Item {
            id: saveItem
            y: btnSep.y + btnSep.height + Math.round(root.height * 0.006)
            width: parent.width
            height: root._itemH

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: root.currentIdx === 3 ? "#0affffff" : "transparent"
                border.color: root.currentIdx === 3 ? "#1a5030" : "transparent"
                border.width: root.currentIdx === 3 ? 1 : 0

                Behavior on color { ColorAnimation { duration: 180 } }
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                spacing: Math.round(root.width * 0.012)

                Rectangle {
                    property real sz: root.currentIdx === 3 ? Math.round(root.height * 0.036) : Math.round(root.height * 0.026)
                    width: sz; height: sz
                    radius: Math.round(sz * 0.22)
                    color: root.currentIdx === 3 ? "#10ffffff" : "#06ffffff"
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on width  { NumberAnimation { duration: 220 } }
                    Behavior on height { NumberAnimation { duration: 220 } }

                    Text {
                        anchors.centerIn: parent
                        text: "\u2714"
                        font.pixelSize: Math.round(parent.width * 0.46)
                        color: root.currentIdx === 3 ? "#80c080" : "#3a5040"
                    }
                }

                Text {
                    text: T.t("ra_save", root.lang)
                    font.pixelSize: root.currentIdx === 3 ? root._fItemSel : root._fItem
                    font.bold: root.currentIdx === 3
                    color: root.currentIdx === 3 ? "#80c080" : "#5a7060"
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on color { ColorAnimation { duration: 180 } }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.currentIdx = 3;
                    doSave();
                }
            }
        }

        // Cancel button (idx 4)
        Item {
            id: cancelItem
            y: saveItem.y + saveItem.height + Math.round(root.height * 0.004)
            width: parent.width
            height: root._itemH

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: root.currentIdx === 4 ? "#0affffff" : "transparent"
                border.color: root.currentIdx === 4 ? "#3a1828" : "transparent"
                border.width: root.currentIdx === 4 ? 1 : 0

                Behavior on color { ColorAnimation { duration: 180 } }
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                spacing: Math.round(root.width * 0.012)

                Rectangle {
                    property real sz: root.currentIdx === 4 ? Math.round(root.height * 0.036) : Math.round(root.height * 0.026)
                    width: sz; height: sz
                    radius: Math.round(sz * 0.22)
                    color: root.currentIdx === 4 ? "#10ffffff" : "#06ffffff"
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on width  { NumberAnimation { duration: 220 } }
                    Behavior on height { NumberAnimation { duration: 220 } }

                    Text {
                        anchors.centerIn: parent
                        text: "\u2716"
                        font.pixelSize: Math.round(parent.width * 0.46)
                        color: root.currentIdx === 4 ? "#a06060" : "#503838"
                    }
                }

                Text {
                    text: T.t("ra_cancel", root.lang)
                    font.pixelSize: root.currentIdx === 4 ? root._fItemSel : root._fItem
                    font.bold: root.currentIdx === 4
                    color: root.currentIdx === 4 ? "#a06060" : "#5a4848"
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on color { ColorAnimation { duration: 180 } }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.currentIdx = 4;
                    closePanel();
                }
            }
        }

        // Auth status indicator
        Item {
            id: authStatusItem
            y: cancelItem.y + cancelItem.height + Math.round(root.height * 0.016)
            width: parent.width
            height: root._itemH
            visible: root._authState > 0
            opacity: root._authState > 0 ? 1 : 0

            Behavior on opacity { NumberAnimation { duration: 250 } }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                spacing: Math.round(root.width * 0.012)

                // Spinner or result icon
                Rectangle {
                    width: Math.round(root.height * 0.036)
                    height: width
                    radius: width * 0.5
                    color: root._authState === 2 ? "#153518" :
                           root._authState === 3 ? "#351518" : "#101828"
                    border.color: root._authState === 2 ? "#40b060" :
                                  root._authState === 3 ? "#c04040" : "#2060a0"
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: root._authState === 1 ? "\u23F3" :
                              root._authState === 2 ? "\u2714" : "\u2716"
                        font.pixelSize: Math.round(parent.width * 0.50)
                        color: root._authState === 2 ? "#60e080" :
                               root._authState === 3 ? "#e06060" : "#60a0d0"
                    }

                    RotationAnimation on rotation {
                        running: root._authState === 1
                        from: 0; to: 360
                        duration: 1200
                        loops: Animation.Infinite
                    }
                }

                Text {
                    text: root._authState === 1 ? T.t("ra_verifying", root.lang) :
                          root._authState === 2 ? root._authMsg : root._authMsg
                    font.pixelSize: root._fItem
                    font.bold: root._authState === 2
                    color: root._authState === 2 ? "#60e080" :
                           root._authState === 3 ? "#e06060" : "#6888a0"
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on color { ColorAnimation { duration: 200 } }
                }
            }
        }

        // Control hints
        Item {
            id: controlHints
            y: parent.height - height
            width: parent.width
            height: Math.round(root.height * 0.035)

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Math.round(root.width * 0.025)
                text: root.editing
                    ? T.t("hint_cursor_close", root.lang)
                    : T.t("hint_edit_nav", root.lang)
                font.pixelSize: Math.max(11, Math.round(root.height * 0.016))
                color: "#ffffff"
            }
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

    // KEYBOARD / GAMEPAD

    Keys.onPressed: {
        // If editing, only intercept B/Escape to deactivate
        if (root.editing) {
            if (event.key === Qt.Key_Escape || event.key === 1048577) {
                event.accepted = true;
                deactivateEditing();
            }
            // Let all other keys pass through to TextInput
            return;
        }

        event.accepted = true;

        var isAccept = (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === 1048576);
        var isBack   = (event.key === Qt.Key_Escape || event.key === Qt.Key_Back ||
                        event.key === Qt.Key_Backspace || event.key === 1048577);
        var isUp     = (event.key === Qt.Key_Up);
        var isDown   = (event.key === Qt.Key_Down);

        if (isUp) {
            if (root.currentIdx > 0) root.currentIdx--;
        } else if (isDown) {
            if (root.currentIdx < 4) root.currentIdx++;
        } else if (isAccept) {
            activateCurrent();
        } else if (isBack) {
            closePanel();
        } else {
            event.accepted = false;
        }
    }

    // FUNCTIONS

    function activateEditing(idx) {
        root.editing = true;
        root.currentIdx = idx;
        if (idx === 0) usernameInput.forceActiveFocus();
        else if (idx === 1) apiKeyInput.forceActiveFocus();
    }

    function deactivateEditing() {
        root.editing = false;
        root.forceActiveFocus();
    }

    function activateCurrent() {
        if (root.currentIdx === 0 || root.currentIdx === 1) {
            activateEditing(root.currentIdx);
        } else if (root.currentIdx === 2) {
            Qt.openUrlExternally("https://retroachievements.org/settings#api-keys");
        } else if (root.currentIdx === 3) {
            doSave();
        } else if (root.currentIdx === 4) {
            closePanel();
        }
    }

    function doSave() {
        api.memory.set("ra_user", usernameInput.text);
        api.memory.set("ra_api_key", apiKeyInput.text);

        // Verify credentials via RA API
        if (usernameInput.text !== "" && apiKeyInput.text !== "") {
            root._authState = 1;
            root._authMsg = T.t("ra_verifying", root.lang);

            var xhr = new XMLHttpRequest();
            var url = "https://retroachievements.org/API/API_GetUserSummary.php"
                + "?z=" + encodeURIComponent(usernameInput.text)
                + "&y=" + encodeURIComponent(apiKeyInput.text)
                + "&u=" + encodeURIComponent(usernameInput.text)
                + "&g=0&a=0";

            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status === 200) {
                        try {
                            var data = JSON.parse(xhr.responseText);
                            if (data && data.User) {
                                root._authState = 2;
                                root._authMsg = T.t("ra_auth_ok", root.lang) + data.User + " (" + (data.TotalPoints || 0) + " pts)";
                                root.loginSaved(usernameInput.text, apiKeyInput.text);
                                // Auto-close after success
                                authCloseTimer.start();
                            } else {
                                root._authState = 3;
                                root._authMsg = T.t("ra_invalid_creds", root.lang);
                            }
                        } catch (e) {
                            root._authState = 3;
                            root._authMsg = T.t("ra_api_error", root.lang);
                        }
                    } else if (xhr.status === 401 || xhr.status === 403) {
                        root._authState = 3;
                        root._authMsg = T.t("ra_invalid_key", root.lang);
                    } else {
                        root._authState = 3;
                        root._authMsg = T.t("ra_network_error", root.lang) + xhr.status + ")";
                    }
                }
            };
            xhr.open("GET", url);
            xhr.send();
        } else {
            root._authState = 3;
            root._authMsg = T.t("ra_enter_creds", root.lang);
        }
    }

    Timer {
        id: authCloseTimer
        interval: 2200
        onTriggered: closePanel()
    }

    function openPanel() {
        usernameInput.text = api.memory.get("ra_user") || "";
        apiKeyInput.text = api.memory.get("ra_api_key") || "";
        root.currentIdx = 0;
        root.editing = false;
        root._authState = 0;
        root._authMsg = "";
        root.visible = true;
        root.opacity = 0;
        root._slideOffset = 0;
        root.forceActiveFocus();
        entranceAnim.start();
    }

    function closePanel() {
        if (exitAnim.running) return;
        deactivateEditing();
        exitAnim.start();
    }
}
