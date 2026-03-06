import QtQuick 2.15
import ".."

pragma Singleton

QtObject {
    id: antialiasingManager

    readonly property bool globalAntialiasing: true
    readonly property bool smoothScaling: true
    readonly property bool asynchronousLoading: true
    readonly property bool cachedImages: true
    readonly property bool mipmap: true

    readonly property bool enabled: true
    readonly property real intensity: 2.8
    readonly property real sharpness: 4.0
    readonly property bool highQualityMode: true
    readonly property bool enhance3DEdges: true
    readonly property real depthSensitivity: 0.9

    function applyToImage(imageComponent) {
        if (!imageComponent) return;

        try {
            imageComponent.antialiasing = globalAntialiasing;
            imageComponent.smooth = smoothScaling;
            imageComponent.asynchronous = asynchronousLoading;
            imageComponent.cache = cachedImages;
            imageComponent.mipmap = mipmap;

        } catch (error) {

        }
    }

    function applyToEffect(effectComponent) {
        if (!effectComponent) return;

        try {
            if (effectComponent.hasOwnProperty("antialiasing")) {
                effectComponent.antialiasing = globalAntialiasing;
            }
            if (effectComponent.hasOwnProperty("smooth")) {
                effectComponent.smooth = smoothScaling;
            }

        } catch (error) {

        }
    }

    function applyToSideLogo(logoComponent) {
        if (!logoComponent) return;

        try {
            logoComponent.antialiasing = true;
            logoComponent.smooth = smoothScaling;
            logoComponent.asynchronous = asynchronousLoading;
            logoComponent.cache = cachedImages;
            logoComponent.mipmap = mipmap;

            if (logoComponent.hasOwnProperty("layer")) {
                logoComponent.layer.enabled = true;
                logoComponent.layer.smooth = true;
            }

        } catch (error) {

        }
    }
}
