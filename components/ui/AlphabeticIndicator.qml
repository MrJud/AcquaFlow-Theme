import QtQuick 2.15
import ".."

// Fullscreen alphabetic jump indicator (L2/R2).
// Appare brevemente e sfuma via.
Item {
    id: root
    anchors.fill: parent
    visible: false
    opacity: 0
    z: 9999

    property string currentLetter: ""

    Timer {
        id: hideTimer
        interval: 1200
        onTriggered: root.opacity = 0
    }

    function show(letter) {
        currentLetter = letter.toUpperCase()
        visible = true
        opacity = 1
        hideTimer.restart()
    }

    onOpacityChanged: {
        if (opacity === 0) visible = false
    }

    Behavior on opacity {
        NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
    }

    // Dark semi-transparent background
    Rectangle {
        anchors.fill: parent
        color: "#59000000"  // ~35% black (was double: Rectangle 35% + RadialGradient 30%)
    }

    // Center letter
    Text {
        id: letterText
        anchors.centerIn: parent
        text: root.currentLetter
        font.pixelSize: 180
        font.bold: true
        color: "#FFFFFF"
        style: Text.Outline
        styleColor: "#60FFFFFF"
    }
}
