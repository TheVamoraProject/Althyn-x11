import QtQuick
import QtQuick.Controls
import QtQuick.Window
import com.vamora

Window {
    id: window
    // Height of the statusbar reserved via strut — must match STATUSBAR_HEIGHT
    // in vamora-statusbar's main.rs. Kept out of that top strip so homescreen
    // never visually overlaps the bar, regardless of X11 stacking order.
    readonly property int statusBarHeight: 30

    visible: true
    width: Screen.width
    height: Math.max(0, Screen.height - statusBarHeight)
    x: 0
    y: statusBarHeight
    title: "Vamora Homescreen"
    color: "transparent"

    // Frameless + always at the very bottom of the stack, like a launcher/
    // desktop layer sitting under every other window — the wallpaper (set
    // by the compositor/DE behind this) stays fully visible through it.
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnBottomHint

    // ---- Vamora/AlthynUI palette (dark only, zinc) ----
    readonly property color cText: "#f4f4f5"        // zinc-100
    readonly property color cTextMuted: "#a1a1aa"   // zinc-400
    readonly property color cDotActive: "#f4f4f5"
    readonly property color cDotInactive: "#80a1a1aa"
    readonly property color cHover: "#26f4f4f5"

    readonly property int pageCount: 3
    readonly property int gridCols: 6
    readonly property int gridRows: 4
    readonly property int perPage: gridCols * gridRows

    AppList {
        id: appList
    }

    property var allApps: []
    property var pagesModel: [[], [], []]

    function chunkApps() {
        var chunks = []
        for (var p = 0; p < pageCount; p++) {
            chunks.push(allApps.slice(p * perPage, (p + 1) * perPage))
        }
        pagesModel = chunks
    }

    function loadApps() {
        allApps = JSON.parse(appList.getAppsJson())
        chunkApps()
    }

    Component.onCompleted: loadApps()

    // Cheap polling refresh so icons added to ~/Desktop show up without a
    // restart — no filesystem watcher wired up yet, this project doesn't do
    // anything beyond reading the folder and drawing the grid.
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: loadApps()
    }

    // ── Page indicator — sits on top, above the grid ───────────────────────
    Row {
        id: indicatorRow
        anchors.top: parent.top
        anchors.topMargin: 48
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 8
        z: 10

        Repeater {
            model: window.pageCount

            Rectangle {
                readonly property bool active: index === pagesView.currentIndex
                width: active ? 22 : 7
                height: 7
                radius: 3.5
                color: active ? window.cDotActive : window.cDotInactive

                Behavior on width {
                    NumberAnimation { duration: 220; easing.type: Easing.OutQuart }
                }
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    onClicked: pagesView.currentIndex = index
                }
            }
        }
    }

    // ── Swipeable pages ─────────────────────────────────────────────────────
    SwipeView {
        id: pagesView
        anchors.top: indicatorRow.bottom
        anchors.topMargin: 24
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottomMargin: 24
        clip: true

        Repeater {
            model: window.pageCount

            HomePage {
                apps: window.pagesModel[index] !== undefined ? window.pagesModel[index] : []
                cols: window.gridCols
                rows: window.gridRows
                textColor: window.cText
                hoverColor: window.cHover

                onLaunch: function(execStr) {
                    if (execStr !== "") {
                        appList.launchApp(execStr)
                    }
                }

                onAppRightClicked: function(x, y, desktopPath, appName) {
                    appContextMenu.targetDesktopPath = desktopPath
                    appContextMenu.targetAppName = appName
                    appContextMenu.popup(x, y)
                }

                onBgRightClicked: function(x, y) {
                    bgContextMenu.popup(x, y)
                }
            }
        }
    }

    // ── App context menu (right-click on an app icon) ──────────────────────
    AppContextMenu {
        id: appContextMenu
        hostWindow: window

        property string targetDesktopPath: ""
        property string targetAppName: ""

        model: [
            {
                label: "Remove from Homescreen",
                icon: "../../assets/icons/pin-off.svg",
                destructive: true,
                action: function() {
                    if (appContextMenu.targetDesktopPath !== "") {
                        appList.removeApp(appContextMenu.targetDesktopPath)
                        loadApps()
                    }
                }
            },
            { label: "---" },
            {
                label: "App Info",
                icon: "../../assets/icons/info.svg",
                action: function() {
                    // placeholder — no action yet
                }
            }
        ]
    }

    // ── Background context menu (right-click on empty desktop) ────────────
    AppContextMenu {
        id: bgContextMenu
        hostWindow: window

        model: [
            {
                label: "Add Widget",
                icon: "../../assets/icons/monitor.svg",
                action: function() {
                    // placeholder — no action yet
                }
            },
            {
                label: "Add App",
                icon: "../../assets/icons/apps.svg",
                action: function() {
                    // placeholder — no action yet
                }
            },
            { label: "---" },
            {
                label: "Shut Down",
                icon: "../../assets/icons/power.svg",
                destructive: true,
                action: function() {
                    appList.shutdown()
                }
            }
        ]
    }
}
