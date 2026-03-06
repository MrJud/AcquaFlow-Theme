import QtQuick 2.15
import ".." as Components

Item {
    id: root

    property string textureSource: ""
    property color topColor: "#555555"
    property color bottomColor: "#555555"
    property string side: "left"
    property bool active: true
    readonly property bool textureLoaded: sideTexture.status === Image.Ready

    Image {
        id: sideTexture
        anchors.fill: parent
        source: root.textureSource
        fillMode: Image.Stretch
        visible: false  // Only used as shader input texture, never rendered directly

        // Do NOT apply AntialiasingManager here: mipmap blurs magenta boundaries
        // and creates intermediate colors the replacement shader cannot detect.
        mipmap: false

        onStatusChanged: {
            if (status === Image.Error && root.textureSource.indexOf("/default/") === -1) {
                var fallbackSource;

                if (root.textureSource.indexOf("Side3") !== -1) {
                    fallbackSource = "../../assets/images/Side/default/Side3.png";
                } else if (root.textureSource.indexOf("Side4") !== -1) {
                    fallbackSource = "../../assets/images/Side/default/Side4.png";
                } else if (root.side === "left" || root.side === "back-left") {
                    fallbackSource = "../../assets/images/Side/default/Side1.png";
                } else if (root.side === "right" || root.side === "back-right") {
                    fallbackSource = "../../assets/images/Side/default/Side2.png";
                } else {
                    fallbackSource = "../../assets/images/Side/default/Side1.png";
                }
                root.textureSource = fallbackSource;
            }
        }
    }

    Components.EdgeAntialiasing {
        id: antialiasedShader
        anchors.fill: parent
        sourceItem: root.active ? precisePixelReplacer : null
        visible: root.textureLoaded && root.active
    }

    ShaderEffect {
        id: precisePixelReplacer
        anchors.fill: parent
        visible: false  // Consumed by EdgeAntialiasing, not rendered directly

        property variant source: sideTexture
        property color topColor: root.topColor
        property color bottomColor: root.bottomColor

        Component.onCompleted: {
            Components.AntialiasingManager.applyToEffect(precisePixelReplacer);
        }

        // Consolidated uniforms: target magenta color and detection radii
        property vector3d magentaTarget: Qt.vector3d(1.0, 0.0, 0.729411764705882)
        property real innerRadius: 0.040  // Core detection boundary
        property real outerRadius: 0.085  // Outer faded-edge boundary (0.065 × 1.3)

        // Edge fade: smooth alpha over 1.5px at all 4 edges (pre-transform, survives Matrix4x4 shear)
        property real edgeFadeX: width > 0 ? 1.5 / width : 0.01
        property real edgeFadeY: height > 0 ? 1.5 / height : 0.01

        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform sampler2D source;
            uniform highp vec4 topColor;
            uniform highp vec4 bottomColor;
            uniform highp vec3 magentaTarget;
            uniform highp float innerRadius;
            uniform highp float outerRadius;
            uniform highp float edgeFadeX;
            uniform highp float edgeFadeY;

            // Compute hue and saturation in a single pass (shared min/max)
            highp vec2 getHueSat(highp vec3 rgb) {
                highp float maxC = max(max(rgb.r, rgb.g), rgb.b);
                highp float minC = min(min(rgb.r, rgb.g), rgb.b);
                highp float delta = maxC - minC;

                highp float sat = maxC > 0.001 ? delta / maxC : 0.0;
                if (delta < 0.001) return vec2(0.0, sat);

                highp float hue;
                if (maxC == rgb.r) {
                    hue = 60.0 * mod((rgb.g - rgb.b) / delta, 6.0);
                } else if (maxC == rgb.g) {
                    hue = 60.0 * ((rgb.b - rgb.r) / delta + 2.0);
                } else {
                    hue = 60.0 * ((rgb.r - rgb.g) / delta + 4.0);
                }
                if (hue < 0.0) hue += 360.0;

                return vec2(hue, sat);
            }

            void main() {
                highp vec4 pixel = texture2D(source, qt_TexCoord0);

                // Euclidean distance from target magenta (#FF00BA)
                highp float dist = distance(pixel.rgb, magentaTarget);

                // Primary detection: smooth falloff from inner to outer radius
                highp float distMask = 1.0 - smoothstep(innerRadius, outerRadius, dist);

                // HSV analysis (hue + saturation in one call)
                highp vec2 hs = getHueSat(pixel.rgb);

                // Saturation confidence: smooth ramp [0.42 → 0.62]
                highp float satMask = smoothstep(0.42, 0.62, hs.y);

                // Hue confidence: in magenta range [290, 340] with soft 10-degree edges
                highp float hueMask = smoothstep(285.0, 295.0, hs.x) *
                                      (1.0 - smoothstep(335.0, 345.0, hs.x));

                // Green channel: must be low for magenta (smooth cutoff)
                highp float greenMask = 1.0 - smoothstep(0.15, 0.25, pixel.g);

                // RGB profile: high R, low G, B in magenta range (smooth edges)
                highp float profileMask = smoothstep(0.72, 0.82, pixel.r) *
                                          (1.0 - smoothstep(0.18, 0.28, pixel.g)) *
                                          smoothstep(0.48, 0.58, pixel.b) *
                                          (1.0 - smoothstep(0.88, 1.02, pixel.b));

                // Combine: distance weighted by best confidence signal
                highp float maskStrength = distMask * max(
                    satMask,
                    max(profileMask, hueMask * satMask * greenMask)
                );
                maskStrength = clamp(maskStrength, 0.0, 1.0);

                // Edge fade at UV boundaries (survives Matrix4x4 shear transform)
                highp float fadeX = smoothstep(0.0, edgeFadeX, qt_TexCoord0.x) *
                                    smoothstep(0.0, edgeFadeX, 1.0 - qt_TexCoord0.x);
                highp float fadeY = smoothstep(0.0, edgeFadeY, qt_TexCoord0.y) *
                                    smoothstep(0.0, edgeFadeY, 1.0 - qt_TexCoord0.y);
                highp float edgeFade = fadeX * fadeY;

                // Gradient from cover art colors
                highp vec4 gradientColor = mix(topColor, bottomColor, qt_TexCoord0.y);

                // Branchless output: blend original <-> gradient by mask strength
                highp float finalAlpha = pixel.a * edgeFade;
                gl_FragColor = mix(
                    vec4(pixel.rgb, finalAlpha),
                    vec4(gradientColor.rgb, finalAlpha),
                    maskStrength
                );
            }
        "
    }
}
