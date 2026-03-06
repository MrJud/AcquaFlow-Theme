import QtQuick 2.0
import ".."
import QtQuick.Layouts 1.12
import "../config/Translations.js" as T

// This component displays the RetroAchievements info for a game.
Item {
    id: root
    width: 300
    height: 80

    // Data properties to be set from the manager
    property string lang: "it"
    property int numAwarded: 0
    property int numAchievements: 0
    property string gameTitle: ""
    property string imageIcon: ""
    property bool isLoading: false
    property bool hasError: false

    visible: !hasError && gameTitle !== ""

    RowLayout {
        anchors.fill: parent
        spacing: 10

        Image {
            id: raLogo
            source: "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHZpZXdCb3g9IjAgMCA0MCA0MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjQwIiBoZWlnaHQ9IjQwIiByeD0iNSIgZmlsbD0iI0ZGRkZGRiIgZmlsbC1vcGFjaXR5PSIwLjEiLz4KPHN2ZyB4PSI1IiB5PSI1IiB3aWR0aD0iMzAiIGhlaWdodD0iMzAiIHZpZXdCb3g9IjAgMCAzMCAzMCIgZmlsbD0ibm9uZSI+CjxwYXRoIGQ9Ik0xNSAyQzcuODIgMiAyIDcuODIgMiAxNXM1LjgyIDEzIDEzIDEzczEzLTUuODIgMTMtMTNTMjIuMTggMiAxNSAyem0wIDIzYy01LjUxIDAtMTAtNC40OS0xMC0xMFM5LjQ5IDUgMTUgNXMxMCA0LjQ5IDEwIDEwLTQuNDkgMTAtMTAgMTB6IiBmaWxsPSIjRkZGRkZGIi8+CjxwYXRoIGQ9Im0xMS41IDEyLjUgMiAyIDQtNCIgc3Ryb2tlPSIjRkZGRkZGIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPgo8L3N2Zz4KPC9zdmc+"
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignVCenter

            onStatusChanged: {
                if (status === Image.Error) {
                    console.warn("Failed to load RetroAchievements favicon, using fallback icon");
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: T.t("gc_ra", root.lang)
                font.bold: true
                color: "white"
                font.pixelSize: 20
            }

            Text {
                text: isLoading ? T.t("gc_loading", root.lang) : T.t("gc_unlocked", root.lang) + root.numAwarded + " / " + root.numAchievements
                color: "lightgray"
                font.pixelSize: 18
            }

            Rectangle {
                id: progressBar
                Layout.fillWidth: true
                height: 8
                radius: 4
                color: "gray"
                visible: !isLoading

                property real value: root.numAchievements > 0 ? root.numAwarded / root.numAchievements : 0

                Rectangle {
                    width: parent.width * progressBar.value
                    height: parent.height
                    radius: 4
                    color: "#FFD700"  // Gold color
                }
            }
        }
    }
}
