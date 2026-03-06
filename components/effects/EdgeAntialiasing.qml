import QtQuick 2.15
import ".."
import QtGraphicalEffects 1.15

Item {
    id: root

    property alias sourceItem: effectSource.sourceItem
    readonly property bool enabled: AntialiasingManager.enabled
    readonly property real intensity: AntialiasingManager.intensity
    readonly property real sharpness: AntialiasingManager.sharpness

    readonly property bool enhance3DEdges: AntialiasingManager.enhance3DEdges
    readonly property real depthSensitivity: AntialiasingManager.depthSensitivity

    ShaderEffectSource {
        id: effectSource
        anchors.fill: parent
        hideSource: root.enabled
        live: true
        smooth: true

        // 1× logical size — on 2K+ screens 2× created dozens of oversized offscreen
        // textures (~175 MB VRAM combined) causing GPU pressure and flickering.
        // The display's own pixel density already provides sufficient sharpness.
        textureSize: Qt.size(parent.width, parent.height)
    }

    ShaderEffect {
        id: fxaaEffect
        anchors.fill: parent
        visible: root.enabled

        property variant source: effectSource
        property real intensity: root.intensity
        property real sharpness: root.sharpness
        property bool enhance3D: root.enhance3DEdges
        property real depthSense: root.depthSensitivity
        property vector2d texelSize: Qt.vector2d(
            1.0 / Math.max(effectSource.textureSize.width, 1),
            1.0 / Math.max(effectSource.textureSize.height, 1)
        )

        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform sampler2D source;
            uniform lowp float intensity;
            uniform lowp float sharpness;
            uniform bool enhance3D;
            uniform lowp float depthSense;
            uniform highp vec2 texelSize;

            lowp vec4 fxaaAntialiasing(highp vec2 coord) {
                lowp vec4 center = texture2D(source, coord);
                lowp vec4 north  = texture2D(source, coord + vec2(0.0, -texelSize.y));
                lowp vec4 south  = texture2D(source, coord + vec2(0.0,  texelSize.y));
                lowp vec4 east   = texture2D(source, coord + vec2( texelSize.x, 0.0));
                lowp vec4 west   = texture2D(source, coord + vec2(-texelSize.x, 0.0));

                lowp float centerLuma = dot(center.rgb, vec3(0.299, 0.587, 0.114));
                lowp float northLuma  = dot(north.rgb,  vec3(0.299, 0.587, 0.114));
                lowp float southLuma  = dot(south.rgb,  vec3(0.299, 0.587, 0.114));
                lowp float eastLuma   = dot(east.rgb,   vec3(0.299, 0.587, 0.114));
                lowp float westLuma   = dot(west.rgb,   vec3(0.299, 0.587, 0.114));

                lowp float lumaRange = max(max(northLuma, southLuma), max(eastLuma, westLuma)) -
                                      min(min(northLuma, southLuma), min(eastLuma, westLuma));

                if (lumaRange < 0.05) return center;

                lowp float horizontal = abs(northLuma + southLuma - 2.0 * centerLuma);
                lowp float vertical   = abs(eastLuma + westLuma - 2.0 * centerLuma);
                bool isHorizontal = horizontal >= vertical;

                highp vec2 blurDirection = isHorizontal ?
                    vec2(0.0, texelSize.y) : vec2(texelSize.x, 0.0);

                lowp vec4 blur1 = texture2D(source, coord - blurDirection * intensity);
                lowp vec4 blur2 = texture2D(source, coord + blurDirection * intensity);

                lowp vec4 blurred = (blur1 + blur2) * 0.5;
                lowp float blendFactor = min(lumaRange * intensity * 2.0, 0.75);

                lowp vec4 result = mix(center, blurred, blendFactor);

                if (sharpness > 1.0) {
                    lowp vec4 sharpened = center + (center - blurred) * (sharpness - 1.0) * 0.5;
                    result = mix(result, sharpened, 0.3);
                }

                return result;
            }

            lowp vec4 enhance3DEdges(highp vec2 coord, lowp vec4 baseColor) {
                if (!enhance3D) return baseColor;

                lowp vec4 tl = texture2D(source, coord + vec2(-texelSize.x, -texelSize.y));
                lowp vec4 tm = texture2D(source, coord + vec2(0.0, -texelSize.y));
                lowp vec4 tr = texture2D(source, coord + vec2(texelSize.x, -texelSize.y));
                lowp vec4 ml = texture2D(source, coord + vec2(-texelSize.x, 0.0));
                lowp vec4 mr = texture2D(source, coord + vec2(texelSize.x, 0.0));
                lowp vec4 bl = texture2D(source, coord + vec2(-texelSize.x, texelSize.y));
                lowp vec4 bm = texture2D(source, coord + vec2(0.0, texelSize.y));
                lowp vec4 br = texture2D(source, coord + vec2(texelSize.x, texelSize.y));

                lowp vec3 sobelX = (-tl.rgb - 2.0*ml.rgb - bl.rgb) + (tr.rgb + 2.0*mr.rgb + br.rgb);
                lowp vec3 sobelY = (-tl.rgb - 2.0*tm.rgb - tr.rgb) + (bl.rgb + 2.0*bm.rgb + br.rgb);

                lowp float edgeStrength = length(sobelX) + length(sobelY);

                if (edgeStrength > 0.1) {
                    lowp float enhancement = edgeStrength * depthSense * 0.5;
                    return baseColor + vec4(vec3(enhancement * 0.1), 0.0);
                }

                return baseColor;
            }

            void main() {
                lowp vec4 antialiased = fxaaAntialiasing(qt_TexCoord0);

                lowp vec4 enhanced = enhance3DEdges(qt_TexCoord0, antialiased);

                gl_FragColor = enhanced;
            }
        "
    }
}
