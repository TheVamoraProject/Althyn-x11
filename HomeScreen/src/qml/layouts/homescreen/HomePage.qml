import QtQuick

Item {
    id: page

    property var apps: []
    property int cols: 6
    property int rows: 4
    property color textColor: "#f4f4f5"
    property color hoverColor: "#26f4f4f5"

    signal launch(string execStr)
    // Emitted when user right-clicks an app tile; carries window coords + app info
    signal appRightClicked(real x, real y, string desktopPath, string appName)
    // Emitted when user right-clicks the background (not on an app)
    signal bgRightClicked(real x, real y)

    // Background right-click catch — sits underneath the grid
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onPressed: function(mouse) {
            var pt = page.mapToItem(null, mouse.x, mouse.y)
            page.bgRightClicked(pt.x, pt.y)
        }
    }

    GridView {
        id: grid
        anchors.fill: parent
        anchors.margins: 16
        cellWidth: width / page.cols
        cellHeight: height / page.rows
        interactive: false
        model: page.apps

        delegate: Item {
            width: grid.cellWidth
            height: grid.cellHeight

            AppTile {
                anchors.centerIn: parent
                width: 76
                height: 92
                appName: modelData.appName !== undefined ? modelData.appName : ""
                iconPath: modelData.iconPath !== undefined ? modelData.iconPath : ""
                desktopPath: modelData.desktopPath !== undefined ? modelData.desktopPath : ""
                textColor: page.textColor
                hoverColor: page.hoverColor

                onClicked: page.launch(modelData.execStr !== undefined ? modelData.execStr : "")

                onRightClicked: function(x, y) {
                    page.appRightClicked(
                        x, y,
                        modelData.desktopPath !== undefined ? modelData.desktopPath : "",
                        modelData.appName !== undefined ? modelData.appName : ""
                    )
                }
            }
        }
    }
}
