import QtQuick 2.15
import ".."
import "../../components/config/Translations.js" as T

// RetroAchievements login dialog – XMB-consistent style with gamepad navigation
// Fields are selectable first (highlight), then activatable (tap/A opens keyboard)
Rectangle {
    id: root
    width: parent.width
    height: parent.height
    color: "#00000000"
    visible: false
    focus: visible

    property real _anim: 0
    // 0=username, 1=apikey, 2=link, 3=save, 4=cancel
    property int focusIndex: 0
    // true when a TextInput is actively being edited (keyboard open)
    property bool editing: false

    // Language
    property string lang: "it"

    signal saved(string username, string apiKey)
    signal closed()

    // Fade background
    Rectangle {
        anchors.fill: parent
        color: "#050d18"
        opacity: root._anim * 0.65
    }

    // Click outside to close
    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (root.editing) { deactivateEditing(); return; }
            if (mouseX < dialogContent.x || mouseX > dialogContent.x + dialogContent.width ||
                mouseY < dialogContent.y || mouseY > dialogContent.y + dialogContent.height) {
                close();
            }
        }
    }

    // Dialog card
    Rectangle {
        id: dialogContent
        width: Math.min(600, parent.width * 0.88)
        height: col.implicitHeight + col.anchors.margins * 2
        anchors.centerIn: parent
        radius: 16
        color: "#0f1e36"
        border.color: "#1a3058"
        border.width: 1

        scale: 0.92 + root._anim * 0.08
        opacity: root._anim

        // Top gradient
        Rectangle {
            anchors.fill: parent; radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#08ffffff" }
                GradientStop { position: 0.25; color: "transparent" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Column {
            id: col
            anchors.fill: parent
            anchors.margins: Math.round(dialogContent.width * 0.06)
            spacing: Math.round(dialogContent.width * 0.035)

            // Header row
            Row {
                spacing: Math.round(dialogContent.width * 0.025)
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: Math.round(dialogContent.width * 0.075)
                    height: width; radius: width * 0.5
                    color: "#1a3058"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "\uD83C\uDFC6"
                        font.pixelSize: Math.round(parent.width * 0.50)
                    }
                }

                Text {
                    text: T.t("gc_ra", root.lang)
                    font.pixelSize: Math.round(dialogContent.width * 0.052)
                    font.bold: true
                    color: "#d0e0f0"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Text {
                text: T.t("ra_dialog_desc", root.lang)
                wrapMode: Text.WordWrap
                color: "#6888a0"
                font.pixelSize: Math.round(dialogContent.width * 0.032)
                width: parent.width
            }

            // Username field
            Rectangle {
                id: usernameField
                width: parent.width
                height: Math.round(dialogContent.width * 0.085)
                color: root.focusIndex === 0 ? "#101e38" : "#0a1528"
                border.color: root.focusIndex === 0 ? "#3070b0" : usernameInput.activeFocus ? "#3070b0" : "#1a3058"
                border.width: root.focusIndex === 0 || usernameInput.activeFocus ? 2 : 1
                radius: 10

                property alias text: usernameInput.text

                Behavior on border.color { ColorAnimation { duration: 200 } }
                Behavior on color { ColorAnimation { duration: 200 } }

                // Selection indicator (left accent bar)
                Rectangle {
                    width: 4; height: parent.height * 0.6
                    radius: 2
                    anchors.left: parent.left; anchors.leftMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#3070b0"
                    visible: root.focusIndex === 0 && !root.editing
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: Math.round(parent.height * 0.28)
                    anchors.verticalCenter: parent.verticalCenter
                    text: "\uD83D\uDC64"
                    font.pixelSize: Math.round(parent.height * 0.38)
                    visible: usernameInput.text === ""
                    opacity: 0.35
                }

                TextInput {
                    id: usernameInput
                    anchors.fill: parent
                    anchors.leftMargin: Math.round(parent.height * 0.28)
                    anchors.rightMargin: Math.round(parent.height * 0.20)
                    anchors.topMargin: Math.round(parent.height * 0.18)
                    anchors.bottomMargin: Math.round(parent.height * 0.18)
                    font.pixelSize: Math.round(dialogContent.width * 0.036)
                    color: "#d0e0f0"
                    clip: true
                    selectByMouse: true
                    readOnly: !(root.editing && root.focusIndex === 0)
                    // Hide cursor when not editing
                    cursorVisible: root.editing && root.focusIndex === 0
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: Math.round(parent.height * 0.28)
                    anchors.verticalCenter: parent.verticalCenter
                    text: T.t("ra_username", root.lang)
                    color: "#405060"
                    font.pixelSize: Math.round(dialogContent.width * 0.036)
                    visible: usernameInput.text === "" && !usernameInput.activeFocus
                }

                // Tap to select + activate
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.focusIndex === 0 && !root.editing) {
                            activateEditing(0);
                        } else {
                            root.focusIndex = 0;
                            deactivateEditing();
                        }
                    }
                }
            }

            // API Key field
            Rectangle {
                id: apiKeyField
                width: parent.width
                height: Math.round(dialogContent.width * 0.085)
                color: root.focusIndex === 1 ? "#101e38" : "#0a1528"
                border.color: root.focusIndex === 1 ? "#3070b0" : apiKeyInput.activeFocus ? "#3070b0" : "#1a3058"
                border.width: root.focusIndex === 1 || apiKeyInput.activeFocus ? 2 : 1
                radius: 10

                property alias text: apiKeyInput.text

                Behavior on border.color { ColorAnimation { duration: 200 } }
                Behavior on color { ColorAnimation { duration: 200 } }

                // Selection indicator
                Rectangle {
                    width: 4; height: parent.height * 0.6
                    radius: 2
                    anchors.left: parent.left; anchors.leftMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#3070b0"
                    visible: root.focusIndex === 1 && !root.editing
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: Math.round(parent.height * 0.28)
                    anchors.verticalCenter: parent.verticalCenter
                    text: "\uD83D\uDD11"
                    font.pixelSize: Math.round(parent.height * 0.38)
                    visible: apiKeyInput.text === ""
                    opacity: 0.35
                }

                TextInput {
                    id: apiKeyInput
                    anchors.fill: parent
                    anchors.leftMargin: Math.round(parent.height * 0.28)
                    anchors.rightMargin: Math.round(parent.height * 0.20)
                    anchors.topMargin: Math.round(parent.height * 0.18)
                    anchors.bottomMargin: Math.round(parent.height * 0.18)
                    font.pixelSize: Math.round(dialogContent.width * 0.036)
                    color: "#d0e0f0"
                    clip: true
                    selectByMouse: true
                    echoMode: TextInput.Password
                    readOnly: !(root.editing && root.focusIndex === 1)
                    cursorVisible: root.editing && root.focusIndex === 1
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: Math.round(parent.height * 0.28)
                    anchors.verticalCenter: parent.verticalCenter
                    text: T.t("ra_apikey", root.lang)
                    color: "#405060"
                    font.pixelSize: Math.round(dialogContent.width * 0.036)
                    visible: apiKeyInput.text === "" && !apiKeyInput.activeFocus
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.focusIndex === 1 && !root.editing) {
                            activateEditing(1);
                        } else {
                            root.focusIndex = 1;
                            deactivateEditing();
                        }
                    }
                }
            }

            // Clickable link
            Row {
                spacing: Math.round(dialogContent.width * 0.015)

                // Selection indicator for link
                Rectangle {
                    width: 4; height: parent.height * 0.8
                    radius: 2
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#4090d0"
                    visible: root.focusIndex === 2
                }

                Text {
                    text: "\uD83D\uDD17"
                    font.pixelSize: Math.round(dialogContent.width * 0.028)
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    id: apiLinkText
                    text: T.t("ra_no_apikey", root.lang)
                    font.pixelSize: Math.round(dialogContent.width * 0.030)
                    color: root.focusIndex === 2 ? "#60b0ff" : linkMA.containsMouse ? "#60b0ff" : "#4090d0"
                    font.underline: true

                    Behavior on color { ColorAnimation { duration: 150 } }

                    MouseArea {
                        id: linkMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.focusIndex = 2;
                            Qt.openUrlExternally("https://retroachievements.org/settings#api-keys");
                        }
                    }
                }
            }

            // Spacer
            Item { width: 1; height: Math.round(dialogContent.width * 0.01) }

            // Buttons row
            Row {
                spacing: Math.round(dialogContent.width * 0.04)
                anchors.horizontalCenter: parent.horizontalCenter

                // Save button
                Rectangle {
                    id: saveBtn
                    width: Math.round(dialogContent.width * 0.28)
                    height: Math.round(dialogContent.width * 0.07)
                    radius: 10
                    color: root.focusIndex === 3 ? "#2060a0" : saveMA.containsMouse ? "#2060a0" : "#183a68"
                    border.color: root.focusIndex === 3 ? "#4090d0" : "#2a5090"
                    border.width: root.focusIndex === 3 ? 2 : 1

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Row {
                        anchors.centerIn: parent
                        spacing: Math.round(dialogContent.width * 0.015)

                        Text {
                            text: "\u2714"
                            font.pixelSize: Math.round(dialogContent.width * 0.032)
                            color: "#80c080"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: T.t("ra_save", root.lang)
                            color: "#d0e0f0"
                            font.pixelSize: Math.round(dialogContent.width * 0.034)
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: saveMA
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: doSave()
                    }
                }

                // Cancel button
                Rectangle {
                    id: cancelBtn
                    width: Math.round(dialogContent.width * 0.28)
                    height: Math.round(dialogContent.width * 0.07)
                    radius: 10
                    color: root.focusIndex === 4 ? "#30182a" : cancelMA.containsMouse ? "#30182a" : "#1a1028"
                    border.color: root.focusIndex === 4 ? "#a06060" : "#2a1838"
                    border.width: root.focusIndex === 4 ? 2 : 1

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Row {
                        anchors.centerIn: parent
                        spacing: Math.round(dialogContent.width * 0.015)

                        Text {
                            text: "\u2716"
                            font.pixelSize: Math.round(dialogContent.width * 0.032)
                            color: "#a06060"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: T.t("ra_cancel", root.lang)
                            color: "#9080a0"
                            font.pixelSize: Math.round(dialogContent.width * 0.034)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: cancelMA
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.close()
                    }
                }
            }
        }
    }

    // Open/close animations
    NumberAnimation {
        id: openAnim
        target: root; property: "_anim"
        from: 0; to: 1
        duration: 280; easing.type: Easing.OutCubic
    }
    NumberAnimation {
        id: closeAnim
        target: root; property: "_anim"
        from: 1; to: 0
        duration: 220; easing.type: Easing.InCubic
        onStopped: {
            root.visible = false;
            root.closed();
        }
    }

    // Navigation logic
    function activateEditing(idx) {
        root.editing = true;
        root.focusIndex = idx;
        if (idx === 0) usernameInput.forceActiveFocus();
        else if (idx === 1) apiKeyInput.forceActiveFocus();
    }

    function deactivateEditing() {
        root.editing = false;
        root.forceActiveFocus();
    }

    function doSave() {
        api.memory.set("ra_user", usernameInput.text);
        api.memory.set("ra_api_key", apiKeyInput.text);
        root.saved(usernameInput.text, apiKeyInput.text);
        root.close();
    }

    function activateCurrent() {
        if (root.focusIndex === 0 || root.focusIndex === 1) {
            activateEditing(root.focusIndex);
        } else if (root.focusIndex === 2) {
            Qt.openUrlExternally("https://retroachievements.org/settings#api-keys");
        } else if (root.focusIndex === 3) {
            doSave();
        } else if (root.focusIndex === 4) {
            close();
        }
    }

    function open() {
        usernameInput.text = api.memory.get("ra_user") || "";
        apiKeyInput.text = api.memory.get("ra_api_key") || "";
        root.focusIndex = 0;
        root.editing = false;
        root.visible = true;
        openAnim.start();
        root.forceActiveFocus();
    }

    function close() {
        deactivateEditing();
        closeAnim.start();
    }

    // Gamepad / Keyboard handler
    Keys.onPressed: {
        if (!visible) return;

        // If editing a text field, only intercept B/Escape to deactivate
        if (root.editing) {
            if (event.key === Qt.Key_Escape || event.key === 1048577) {
                event.accepted = true;
                deactivateEditing();
            }
            // Let all other keys pass through to TextInput
            return;
        }

        event.accepted = true;

        // D-pad Down → next item
        if (event.key === Qt.Key_Down) {
            root.focusIndex = Math.min(4, root.focusIndex + 1);
            return;
        }
        // D-pad Up → prev item
        if (event.key === Qt.Key_Up) {
            root.focusIndex = Math.max(0, root.focusIndex - 1);
            return;
        }
        // D-pad Left on buttons row → switch save/cancel
        if (event.key === Qt.Key_Left && root.focusIndex >= 3) {
            root.focusIndex = 3;
            return;
        }
        // D-pad Right on buttons row → switch save/cancel
        if (event.key === Qt.Key_Right && root.focusIndex >= 3) {
            root.focusIndex = 4;
            return;
        }
        // A / Enter → activate current
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === 1048576) {
            activateCurrent();
            return;
        }
        // B / Escape → close
        if (event.key === Qt.Key_Escape || event.key === 1048577) {
            close();
            return;
        }
    }
}
