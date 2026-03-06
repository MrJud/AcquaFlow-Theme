import QtQuick 2.15
import QtGraphicalEffects 1.15

// GlassPanel — Liquid Glass container
// Renders a frosted-glass panel with:
// Translucent tinted background
// Top-edge specular highlight (sheen)
// Inner gradient border
// NOTE: This component does NOT blur the background itself.
// The blur should be applied once at the overlay level (e.g. Hub backdrop).
// This panel only provides the tinted glass surface on top of the already-blurred background.

Item {
    id: glassRoot

    // Public API
    property real glassRadius: 24
    property bool focused: false

    // Tint colors (the semi-transparent overlay on the glass)
    property color tintColor: focused
        ? Qt.rgba(0.10, 0.14, 0.28, 0.55)
        : Qt.rgba(0.06, 0.10, 0.22, 0.45)

    // Border colors
    property color borderColor: focused
        ? Qt.rgba(0.35, 0.55, 0.80, 0.40)
        : Qt.rgba(0.18, 0.25, 0.40, 0.20)
    property real borderWidth: focused ? 1.5 : 1
    property color borderColor2: borderColor
    property color borderColor3: borderColor
    property real borderGradientAngle: 0

    // Top specular highlight
    property real sheenOpacity: focused ? 0.10 : 0.06
    property real sheenHeight: 0.18  // fraction of panel height

    // Animation durations
    property int animDuration: 250

    // Content container — children go here via default property
    default property alias contentData: contentItem.data

    // Glass Surface
    Rectangle {
        id: glassSurface
        anchors.fill: parent
        radius: glassRoot.glassRadius
        color: "transparent"
        clip: true

        // Layer 1: Tinted glass fill
        Rectangle {
            id: tintLayer
            anchors.fill: parent
            radius: parent.radius
            color: glassRoot.tintColor

            Behavior on color { ColorAnimation { duration: glassRoot.animDuration } }
        }

        // Layer 2: Top-edge specular sheen (Liquid Glass signature)
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height * glassRoot.sheenHeight
            radius: parent.radius

            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, glassRoot.sheenOpacity) }
                GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, glassRoot.sheenOpacity * 0.3) }
                GradientStop { position: 1.0; color: "transparent" }
            }

            Behavior on opacity { NumberAnimation { duration: glassRoot.animDuration } }
        }

        // Layer 3: Bottom subtle dark gradient (depth)
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height * 0.3
            radius: parent.radius

            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.08) }
            }
        }

        // Content goes here
        Item {
            id: contentItem
            anchors.fill: parent
        }
    }

    // Layer 4: Multi-color gradient border (layer.effect approach for reliable masking)
    Rectangle {
        id: borderRing
        anchors.fill: parent
        radius: glassRoot.glassRadius
        color: "transparent"
        border.color: "white"
        border.width: Math.max(glassRoot.borderWidth, 1)
        layer.enabled: true
        layer.smooth: true
        layer.effect: ConicalGradient {
            angle: glassRoot.borderGradientAngle
            gradient: Gradient {
                GradientStop { position: 0.0;  color: glassRoot.borderColor }
                GradientStop { position: 0.33; color: glassRoot.borderColor2 }
                GradientStop { position: 0.66; color: glassRoot.borderColor3 }
                GradientStop { position: 1.0;  color: glassRoot.borderColor }
            }
        }
    }

    // Public API (glow)
    property color glowColor: "transparent"
    property real glowIntensity: 0.0  // 0.0 – 1.0

    // Layer 5: Luminous outer glow (3-layer bloom) — subtle
    Item {
        visible: glassRoot.glowIntensity > 0.01
        anchors.fill: parent
        z: -1

        // Wide soft bloom
        Rectangle {
            anchors.fill: parent
            anchors.margins: -6
            radius: glassRoot.glassRadius + 6
            color: "transparent"
            border.color: Qt.rgba(glassRoot.glowColor.r, glassRoot.glowColor.g, glassRoot.glowColor.b, glassRoot.glowIntensity * 0.12)
            border.width: 6
            Behavior on border.color { ColorAnimation { duration: 400 } }
        }
        // Medium glow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: glassRoot.glassRadius + 3
            color: "transparent"
            border.color: Qt.rgba(glassRoot.glowColor.r, glassRoot.glowColor.g, glassRoot.glowColor.b, glassRoot.glowIntensity * 0.22)
            border.width: 3
            Behavior on border.color { ColorAnimation { duration: 400 } }
        }
        // Tight bright edge
        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: glassRoot.glassRadius + 1
            color: "transparent"
            border.color: Qt.rgba(glassRoot.glowColor.r, glassRoot.glowColor.g, glassRoot.glowColor.b, glassRoot.glowIntensity * 0.35)
            border.width: 1.5
            Behavior on border.color { ColorAnimation { duration: 400 } }
        }
    }
}
