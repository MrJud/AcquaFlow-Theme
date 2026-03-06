import QtQuick 2.15
import Pegasus.FolderListModel 1.0

// Wrapper for Pegasus native FolderListModel.
// Loaded via Loader in FileBrowser.qml to safely handle import.
FolderListModel {
    id: root
    extensions: [".jpg", ".jpeg", ".png", ".bmp", ".webp"]
}
