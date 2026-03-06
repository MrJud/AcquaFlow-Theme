import QtQuick 2.15
import ".."
import QtGraphicalEffects 1.15

Item {
    id: root
    property string platformIdentifier: ""
    property var logoConfig: null

    Item {
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.6, parent.height * 0.6)
        height: width

        scale: logoConfig ? logoConfig.scale || 1.0 : 1.0
        opacity: logoConfig ? logoConfig.opacity || 1.0 : 1.0

        transform: [
            Translate {
                x: logoConfig ? (logoConfig.positionX || 0.5) * parent.width - width * 0.5 : 0
                y: logoConfig ? (logoConfig.positionY || 0.5) * parent.height - height * 0.5 : 0
            },
            Rotation {
                angle: logoConfig ? logoConfig.additionalRotation || 0 : 0
                origin.x: width * 0.5
                origin.y: height * 0.5
            }
        ]

        Image {
            id: logoImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            smooth: AntialiasingManager.smoothScaling
            asynchronous: AntialiasingManager.asynchronousLoading
            cache: AntialiasingManager.cachedImages
            mipmap: AntialiasingManager.mipmap
            antialiasing: AntialiasingManager.globalAntialiasing
            visible: false
            source: root.platformIdentifier !== "" ?
                    "../../assets/images/logospng/" + root.platformIdentifier + ".png" : ""

            Component.onCompleted: {
                AntialiasingManager.applyToImage(logoImage);
            }
        }

        ShaderEffectSource {
            id: logoSource
            sourceItem: logoImage
            hideSource: true
            live: true
        }

        ShaderEffect {
            anchors.fill: parent
            property variant source: logoSource
            property real outlineSize: 0.6
            property real alphaThreshold: 0.1
            property vector2d px: Qt.vector2d(1.0 / Math.max(1, logoImage.paintedWidth), 1.0 / Math.max(1, logoImage.paintedHeight))
            visible: logoImage.source !== "" && logoImage.status === Image.Ready

            fragmentShader: "
                varying highp vec2 qt_TexCoord0;
                uniform sampler2D source;
                uniform highp float outlineSize;
                uniform lowp float alphaThreshold;
                uniform highp vec2 px;

                void main() {
                    highp vec2 uv = qt_TexCoord0;
                    highp vec2 o = px * outlineSize;
                    lowp float alpha_center = texture2D(source, uv).a;
                    lowp float alpha_shadow = texture2D(source, uv - o).a;
                    lowp float shadow_edge = clamp(alpha_shadow - alpha_center, 0.0, 1.0);
                    vec4 shadow_color = vec4(0.0, 0.0, 0.0, 0.5 * shadow_edge);
                    lowp float alpha_highlight = texture2D(source, uv + o).a;
                    lowp float highlight_edge = clamp(alpha_highlight - alpha_center, 0.0, 1.0);
                    vec4 highlight_color = vec4(1.0, 1.0, 1.0, 0.5 * highlight_edge);
                    gl_FragColor = mix(shadow_color, highlight_color, highlight_color.a);
                }
            "
        }
    }
}
