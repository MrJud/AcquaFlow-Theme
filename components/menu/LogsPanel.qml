import QtQuick 2.15

// Logs / Known Issues – inline XMB drill-down panel
Item {
    id: root
    anchors.fill: parent
    visible: false
    opacity: 0

    // Layout
    readonly property real _bigIconSz: Math.round(height * 0.100)
    readonly property real _smIconSz:  Math.round(height * 0.036)
    readonly property real _curIconSz: Math.round(height * 0.048)
    readonly property real _contentX:  Math.round(width  * 0.195)
    readonly property real _headerY:   Math.round(height * 0.125)
    readonly property real _listY:     _headerY + Math.round(height * 0.110)
    readonly property real _fTitle:    Math.max(14, Math.round(height * 0.025))
    readonly property real _fSub:      Math.max(10, Math.round(height * 0.016))
    readonly property real _fItem:     Math.max(12, Math.round(height * 0.020))
    readonly property real _fLabel:    Math.max(10, Math.round(height * 0.015))
    readonly property real _rowH:      Math.round(height * 0.068)

    signal closed()

    property real _slideOffset: 0

    // Block touch passthrough
    MouseArea { anchors.fill: parent; z: -1 }

    // Known Issues data
    readonly property var issues: [
        {
            tag:  "RA HUB",
            col:  "#c05090",
            text: "Properly implement the RetroAchievements Hub trophy/achievement detail page — currently shows placeholder layout."
        },
        {
            tag:  "UI / UX",
            col:  "#5090c0",
            text: "General UI revision and UX consolidation needed: spacing, transitions and interactive states require a full pass."
        },
        {
            tag:  "ASSETS",
            col:  "#60a870",
            text: "Several platform sprite sets are still missing — add side-cover art and logo assets for incomplete systems."
        },
        {
            tag:  "SETTINGS",
            col:  "#c08030",
            text: "Not all menu settings are fully operational — some options are wired to memory but not yet propagated to the UI."
        },
        {
            tag:  "BUGS",
            col:  "#c04040",
            text: "Minor bugs scattered across the theme: edge cases in navigation, animation glitches and occasional null-ref warnings."
        },
        {
            tag:  "SCALING",
            col:  "#7060b8",
            text: "Multi-resolution scaling needs further tuning — some UI elements behave inconsistently at non-1080p resolutions."
        },
        {
            tag:  "FUTURE",
            col:  "#408080",
            text: "Additional themes and visual variants are planned for future releases — colour palettes, layout modes and icon packs."
        }
    ]

    // LARGE ICON
    Rectangle {
        x: Math.round(root.width  * 0.055)
        y: Math.round(root.height * 0.055)
        width: root._bigIconSz; height: root._bigIconSz
        radius: width * 0.24
        color: "#12ffffff"

        Rectangle {
            anchors.fill: parent; radius: parent.radius
            color: "transparent"; border.color: "#0affffff"; border.width: 1
        }

        Text {
            anchors.centerIn: parent
            text: "\u2139"
            font.pixelSize: Math.round(parent.width * 0.52)
            color: "#8aadcc"
        }
    }

    // BREADCRUMB HEADER
    Row {
        id: breadcrumb
        x: root._contentX + root._slideOffset
        y: root._headerY
        spacing: Math.round(root.width * 0.012)

        Rectangle {
            width: root._smIconSz; height: width; radius: width * 0.5
            color: "#10ffffff"; anchors.verticalCenter: parent.verticalCenter
            Text { anchors.centerIn: parent; text: "\u25C6"; font.pixelSize: Math.round(parent.width * 0.50); color: "#5a7a94" }
        }

        Text { text: "\u25C2"; font.pixelSize: Math.round(root.height * 0.030); color: "#506a80"; anchors.verticalCenter: parent.verticalCenter }

        Rectangle {
            width: root._curIconSz; height: width; radius: width * 0.24
            color: "#18ffffff"; anchors.verticalCenter: parent.verticalCenter
            Text { anchors.centerIn: parent; text: "\u2139"; font.pixelSize: Math.round(parent.width * 0.52); color: "#a0c0dd" }
        }

        Item { width: Math.round(root.width * 0.008); height: 1 }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                text: "Logs"
                font.pixelSize: root._fTitle; font.bold: true; color: "#d0e0f0"
            }
            Text {
                text: "Known Issues  ·  Alpha Build v0.6.0"
                font.pixelSize: root._fSub; color: "#5878a0"
            }
        }
    }

    // Tap breadcrumb to close
    MouseArea {
        x: breadcrumb.x; y: breadcrumb.y - Math.round(root.height * 0.01)
        width: Math.min(breadcrumb.width, root.width * 0.45)
        height: breadcrumb.height + Math.round(root.height * 0.02)
        onClicked: root.closePanel()
    }

    // Separator
    Rectangle {
        x: root._contentX + root._slideOffset
        y: root._headerY + Math.round(root.height * 0.068)
        width: root.width * 0.60; height: 1; color: "#0cffffff"
    }

    // ISSUES LIST
    Column {
        x: root._contentX + root._slideOffset
        y: root._listY
        width: root.width * 0.60
        spacing: Math.round(root.height * 0.010)

        Repeater {
            model: root.issues

            Item {
                width: parent.width
                height: root._rowH

                // Row background
                Rectangle {
                    anchors.fill: parent; radius: 6
                    color: "#08ffffff"
                    border.color: "#0cffffff"; border.width: 1
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Math.round(root.width * 0.010)
                    anchors.right: parent.right
                    anchors.rightMargin: Math.round(root.width * 0.010)
                    spacing: Math.round(root.width * 0.012)

                    // Tag badge
                    Rectangle {
                        height: Math.round(root.height * 0.026)
                        width: tagText.implicitWidth + Math.round(root.width * 0.018)
                        radius: height * 0.5
                        color: Qt.rgba(
                            parseInt(modelData.col.substring(1,3), 16) / 255,
                            parseInt(modelData.col.substring(3,5), 16) / 255,
                            parseInt(modelData.col.substring(5,7), 16) / 255,
                            0.22
                        )
                        border.color: Qt.rgba(
                            parseInt(modelData.col.substring(1,3), 16) / 255,
                            parseInt(modelData.col.substring(3,5), 16) / 255,
                            parseInt(modelData.col.substring(5,7), 16) / 255,
                            0.55
                        )
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            id: tagText
                            anchors.centerIn: parent
                            text: modelData.tag
                            font.pixelSize: root._fLabel
                            font.bold: true
                            color: modelData.col
                        }
                    }

                    // Issue description
                    Text {
                        width: parent.width - parent.spacing - (parent.width * 0.18)
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.text
                        font.pixelSize: root._fItem
                        color: "#90a8c0"
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        maximumLineCount: 2
                    }
                }
            }
        }
    }

    // Hint bar
    Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Math.round(root.height * 0.025)
        anchors.right: parent.right
        anchors.rightMargin: Math.round(root.width * 0.025)
        text: "B  Back"
        font.pixelSize: Math.max(11, Math.round(root.height * 0.016))
        color: "#ffffff"
        x: root._slideOffset
    }

    // ANIMATIONS
    ParallelAnimation {
        id: entranceAnim
        NumberAnimation { target: root; property: "opacity";      from: 0; to: 1; duration: 380; easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "_slideOffset"; from: root.width * 0.04; to: 0; duration: 420; easing.type: Easing.OutCubic }
    }

    ParallelAnimation {
        id: exitAnim
        NumberAnimation { target: root; property: "opacity";      from: 1; to: 0; duration: 250; easing.type: Easing.InCubic }
        NumberAnimation { target: root; property: "_slideOffset"; from: 0; to: root.width * 0.04; duration: 250; easing.type: Easing.InCubic }
        onFinished: { root.visible = false; root.closed(); }
    }

    Keys.onPressed: {
        var isBack = (event.key === Qt.Key_Escape || event.key === Qt.Key_Back ||
                      event.key === Qt.Key_Backspace || event.key === 1048577);
        if (isBack) { event.accepted = true; root.closePanel(); }
        else { event.accepted = false; }
    }

    // FUNCTIONS
    function openPanel() {
        visible = true;
        opacity = 0;
        _slideOffset = 0;
        forceActiveFocus();
        entranceAnim.start();
    }

    function closePanel() {
        if (exitAnim.running) return;
        exitAnim.start();
    }
}
