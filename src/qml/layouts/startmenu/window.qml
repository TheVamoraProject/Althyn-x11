import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import QtQuick.Window
import "../components"
import com.vamora

Window {
    id: window
    width: 550
    height: 570
    visible: true
    color: "transparent"
    title: "StartMenu"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    // ---- VamoraUI palette (dark, zinc) ----
    readonly property color cBg: "#18181b"        // zinc-900, solid
    readonly property color cTopBar: "#27272a"    // zinc-800, solid
    readonly property color cBorder: "#3f3f46"    // zinc-700
    readonly property color cSurface: "#27272a"   // zinc-800 (pills / inputs)
    readonly property color cSurfaceHover: "#3f3f46" // zinc-700
    readonly property color cText: "#f4f4f5"      // zinc-100
    readonly property color cTextMuted: "#a1a1aa" // zinc-400
    readonly property color cAccent: "#ffffff"    // white accent (selected states)
    readonly property color cOnAccent: "#09090b"  // near-black text/icons on white

    property bool isMaximized: false
    property bool ignoreDeactivate: false
    property real normalX: 0
    property real normalY: 0
    property real normalWidth: width
    property real normalHeight: height
    property int statusBarHeight: 30 // must match your status bar's height

    // click outside ==> close
    onActiveChanged: {
        if (!active && !ignoreDeactivate) {
            window.close()
        }
    }

    Timer {
        id: resizeGuardTimer
        interval: 250
        onTriggered: ignoreDeactivate = false
    }

    function toggleMaximize() {
        ignoreDeactivate = true
        resizeGuardTimer.restart()

        if (!isMaximized) {
            normalX = window.x
            normalY = window.y
            normalWidth = window.width
            normalHeight = window.height

            window.x = 0
            window.y = statusBarHeight
            window.width = Screen.width
            window.height = Screen.height - statusBarHeight
            isMaximized = true
        } else {
            window.x = normalX
            window.y = normalY
            window.width = normalWidth
            window.height = normalHeight
            isMaximized = false
        }
    }

    UserInfo {
        id: userInfo
    }

    AppList {
        id: appList
    }

    // --- App data from rust---
    property var allApps: []
    property var filteredApps: []
    property int cols: isMaximized ? 8 : 5
    property real cellSize: (startmenu.width - 24) / cols

    function applyFilter(text) {
        var q = text.toLowerCase().trim()
        filteredApps = (q === "")
            ? allApps.slice()
            : allApps.filter(function(a) {
                  return a.appName.toLowerCase().indexOf(q) !== -1
              })
    }

    Component.onCompleted: {
        allApps = JSON.parse(appList.getAppsJson())
        filteredApps = allApps.slice()
    }

    Rectangle {
        id: startmenu
        color: cBg
        width: parent.width
        height: parent.height
        border.color: cBorder
        border.width: 1
        radius: isMaximized ? 0 : 24

        
        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: window.close()
        }

        Rectangle {
            // top bar
            color: cTopBar
            width: parent.width
            height: 50
            radius: isMaximized ? 0 : 24

            
            Rectangle {
                color: parent.color
                width: parent.width
                height: parent.height / 2
                y: parent.height / 2
            }

            Rectangle {
                // topbar outline fyi
                color: cBorder
                width: parent.width
                height: 1
                y: 49
            }

            Button {
                id: pfpButton
                x: 16
                y: ( parent.height / 2 ) - ( height / 2 )
                width: 28
                height: 28

                background: Rectangle {
                    radius: width / 2
                    color: cSurface
                    border.width: 1
                    border.color: cBorder
                }

                Image {
                    id: pfpImage
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    source: userInfo.pfpPath
                    fillMode: Image.PreserveAspectCrop
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: pfpImage.width
                            height: pfpImage.height
                            radius: width / 2
                        }
                    }
                }

                ToolTip {
                    visible: pfpButton.hovered
                    text: userInfo.username
                    delay: 400
                    font.pixelSize: 12
                }
            }

            TextField {
                // the search bar
                id: searchField
                width: 284
                height: 32
                color: cText
                x: ( parent.width / 2 ) - ( width / 2 )
                y: ( parent.height / 2 ) - ( height / 2 )
                leftPadding: 35
                placeholderText: "Search"
                placeholderTextColor: cTextMuted
                font.pixelSize: 13

                onTextChanged: applyFilter(text)

                background: Rectangle {
                    color: cSurface
                    border.color: searchField.activeFocus ? cAccent : cBorder
                    border.width: 1
                    radius: 25

                    Behavior on border.color {
                        ColorAnimation { duration: 150 }
                    }
                }
                Image {
                    source: "../../assets/icons/lucide/search.svg"
                    width: 16
                    height: 16
                    anchors.verticalCenter: parent.verticalCenter
                    x: 12
                }
            }

            Button {
                x: parent.width - width - 16
                y: ( parent.height / 2 ) - ( height / 2 )
                width: 28
                height: 28

                background: Rectangle {
                    radius: width / 2
                    color: cSurface
                    border.width: 1
                    border.color: cBorder
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = cSurfaceHover
                        onExited: parent.color = cSurface
                    }
                }

                onClicked: toggleMaximize()

                Image {
                    source: isMaximized ? "../../assets/icons/lucide/minimize.svg" : "../../assets/icons/lucide/maximize.svg"
                    width: 14
                    height: 14
                    anchors.centerIn: parent
                }
            }

        }

        // App grid area (scrollable)
        Item {
            id: gridArea
            width: parent.width
            y: 50 + 6
            height: parent.height - 50 - 6 - 36 - 22
            clip: true

            GridView {
                id: appGrid
                anchors.fill: parent
                cellWidth: cellSize
                cellHeight: cellSize
                model: filteredApps
                clip: true

                boundsBehavior: Flickable.StopAtBounds
                flickDeceleration: 3000
                maximumFlickVelocity: 2500

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    width: 6

                    background: Rectangle { color: "transparent" }
                    contentItem: Rectangle {
                        radius: 3
                        color: cSurfaceHover
                    }
                }

                delegate: Item {
                    id: iconWrap
                    width: appGrid.cellWidth
                    height: appGrid.cellHeight
                    opacity: 0
                    scale: 0.75

                    Component.onCompleted: entranceAnim.start()

                    ParallelAnimation {
                        id: entranceAnim
                        PauseAnimation { duration: Math.min(index, 40) * 12 }
                        NumberAnimation { target: iconWrap; property: "opacity"; to: 1; duration: 200; easing.type: Easing.OutQuad }
                        NumberAnimation { target: iconWrap; property: "scale"; to: 1;   duration: 240; easing.type: Easing.OutBack }
                    }

                    Behavior on scale {
                        NumberAnimation { duration: 130; easing.type: Easing.OutQuad }
                    }

                    GridIcon {
                        anchors.fill: parent
                        anchors.margins: 4
                        appName: modelData.appName
                        iconPath: modelData.iconPath
                        execStr: modelData.execStr
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        propagateComposedEvents: true
                        onEntered: iconWrap.scale = 1.08
                        onExited:  iconWrap.scale = 1
                        onClicked: {
                            if (modelData.execStr !== "") {
                                appList.launchApp(modelData.execStr)
                                window.close()
                            }
                        }
                    }
                }
            }
        }

        // Always on bottom navbar (https://vamora.vercel.app/blog/vamui)
        property int selectedCategoryIndex: 0

        Rectangle {
            id: bottomNav
            width: 168
            height: 38
            color: cSurface
            border.width: 1
            border.color: cBorder
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height - height - 14
            radius: 50

            readonly property int btnWidth: 52
            readonly property int btnSpacing: 4

            Rectangle {
                id: selectOverlay
                height: parent.height - 8
                width: bottomNav.btnWidth
                radius: height / 2
                color: cAccent
                anchors.verticalCenter: parent.verticalCenter
                x: navRow.x + startmenu.selectedCategoryIndex * (bottomNav.btnWidth + bottomNav.btnSpacing)

                Behavior on x {
                    NumberAnimation { duration: 250; easing.type: Easing.OutQuart }
                }
            }

            Row {
                id: navRow
                anchors.centerIn: parent
                spacing: bottomNav.btnSpacing
                height: parent.height

                Button {
                    width: bottomNav.btnWidth
                    height: parent.height
                    background: Rectangle { color: "#00000000" }

                    Image {
                        id: appsIcon
                        anchors.centerIn: parent
                        source: "../../assets/icons/lucide/apps.svg"
                        width: 16
                        height: 16
                    }
                    ColorOverlay {
                        anchors.fill: appsIcon
                        source: appsIcon
                        color: cOnAccent
                        opacity: startmenu.selectedCategoryIndex === 0 ? 1 : 0
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: startmenu.selectedCategoryIndex = 0
                    }
                }
                Button {
                    width: bottomNav.btnWidth
                    height: parent.height
                    background: Rectangle { color: "#00000000" }

                    Image {
                        id: starIcon
                        anchors.centerIn: parent
                        source: "../../assets/icons/lucide/star.svg"
                        width: 16
                        height: 16
                    }
                    ColorOverlay {
                        anchors.fill: starIcon
                        source: starIcon
                        color: cOnAccent
                        opacity: startmenu.selectedCategoryIndex === 1 ? 1 : 0
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: startmenu.selectedCategoryIndex = 1
                    }
                }
                Button {
                    width: bottomNav.btnWidth
                    height: parent.height
                    background: Rectangle { color: "#00000000" }

                    Image {
                        id: historyIcon
                        anchors.centerIn: parent
                        source: "../../assets/icons/lucide/history.svg"
                        width: 16
                        height: 16
                    }
                    ColorOverlay {
                        anchors.fill: historyIcon
                        source: historyIcon
                        color: cOnAccent
                        opacity: startmenu.selectedCategoryIndex === 2 ? 1 : 0
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: startmenu.selectedCategoryIndex = 2
                    }
                }
            }
        }
    }
}
