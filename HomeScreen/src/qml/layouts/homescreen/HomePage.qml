import QtQuick

Item {
    id: page
    property var items: []
    property int cols: 4
    property int rows: 6
    property color textColor: "#f4f4f5"
    property color hoverColor: "#26f4f4f5"
    signal launch(string execStr)
    signal itemChanged(var item)
    signal appRightClicked(real x, real y, string desktopPath, string appName)
    signal bgRightClicked(real x, real y)
    // Fired when an item is dragged to (and held at) the left/right edge
    // of the page, requesting a move to the adjacent page. direction is
    // -1 (previous page) or +1 (next page).
    signal requestPageShift(var itemData, int direction)
    // How close to the page edge (in px) a dragged item must get before
    // the hold timer starts.
    property int edgeZone: 32
    // How long (ms) an item must be held at the edge before it shifts pages.
    property int edgeHoldDuration: 650

    MouseArea {
        anchors.fill: parent
        // RightButton for desktop right-click; LeftButton is accepted too
        // so a long press on empty space works as the touch equivalent
        // (see onPressAndHold below) — a plain tap is ignored.
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        onPressed: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                var p = page.mapToItem(null, mouse.x, mouse.y)
                page.bgRightClicked(p.x, p.y)
            }
        }
        onPressAndHold: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                var p = page.mapToItem(null, mouse.x, mouse.y)
                page.bgRightClicked(p.x, p.y)
            }
        }
    }

    Repeater {
        model: page.items
        delegate: Item {
            id: cell
            property var itemData: modelData
            property int cellW: Math.max(1, Math.floor((page.width - 32) / page.cols))
            property int cellH: Math.max(1, Math.floor((page.height - 32) / page.rows))
            x: 16 + itemData.x * cellW
            y: 16 + itemData.y * cellH
            width: Math.max(cellW, itemData.width * cellW)
            height: Math.max(cellH, itemData.height * cellH)
            z: dragArea.drag.active ? 10 : 1

            Rectangle { anchors.fill: parent; anchors.margins: 4; radius: 14; color: dragArea.containsMouse ? page.hoverColor : "transparent"; visible: itemData.type !== "app" || dragArea.containsMouse }
            AppTile {
                anchors.fill: parent; anchors.margins: Math.max(4, Math.floor(Math.min(cellW,cellH)*0.08))
                appName: itemData.appName || (itemData.type === "folder" ? (itemData.name || "Folder") : (itemData.type === "widget" ? (itemData.name || "Widget") : ""))
                iconPath: itemData.iconPath || "../../assets/icons/unknown.svg"
                textColor: page.textColor; hoverColor: page.hoverColor
                onClicked: { if (itemData.type === "app") page.launch(itemData.execStr || "") }
                onRightClicked: function(px,py) { page.appRightClicked(px,py,itemData.desktopPath||"",itemData.appName||itemData.name||"") }
            }
            MouseArea {
                id: dragArea; anchors.fill: parent; acceptedButtons: Qt.LeftButton; hoverEnabled: true; propagateComposedEvents: true
                drag.target: cell; drag.axis: Drag.XAndYAxis

                // Direction the item is currently held against an edge:
                // -1 left, +1 right, 0 neither.
                property int pendingEdgeDir: 0

                Timer {
                    id: edgeHoldTimer
                    interval: page.edgeHoldDuration
                    repeat: false
                    onTriggered: {
                        if (dragArea.pendingEdgeDir !== 0) {
                            page.requestPageShift(itemData, dragArea.pendingEdgeDir)
                            dragArea.pendingEdgeDir = 0
                        }
                    }
                }

                function updateEdgeHold() {
                    var dir = 0
                    if (cell.x <= page.edgeZone) dir = -1
                    else if (cell.x + cell.width >= page.width - page.edgeZone) dir = 1
                    if (dir !== dragArea.pendingEdgeDir) {
                        dragArea.pendingEdgeDir = dir
                        if (dir !== 0) edgeHoldTimer.restart()
                        else edgeHoldTimer.stop()
                    }
                }

                onPositionChanged: if (drag.active) dragArea.updateEdgeHold()

                onReleased: {
                    edgeHoldTimer.stop(); dragArea.pendingEdgeDir = 0
                    var nx=Math.max(0,Math.min(page.cols-itemData.width,Math.round((cell.x-16)/cellW)))
                    var ny=Math.max(0,Math.min(page.rows-itemData.height,Math.round((cell.y-16)/cellH)))
                    itemData.x=nx; itemData.y=ny; cell.x=16+nx*cellW; cell.y=16+ny*cellH; page.itemChanged(itemData)
                }
            }
            Rectangle { width: 14; height: 14; radius: 4; color: page.textColor; opacity: dragArea.containsMouse ? .8 : 0; anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 3
                MouseArea { anchors.fill: parent; cursorShape: Qt.SizeFDiagCursor; onPressed: { mouse.accepted=true }
                    onPositionChanged: { if (pressed) { var nw=Math.max(1,Math.min(page.cols-itemData.x,Math.round((mouse.x+cell.width)/cellW))); var nh=Math.max(1,Math.min(page.rows-itemData.y,Math.round((mouse.y+cell.height)/cellH))); itemData.width=nw; itemData.height=nh; cell.width=nw*cellW; cell.height=nh*cellH } }
                    onReleased: page.itemChanged(itemData)
                }
            }
        }
    }
}
