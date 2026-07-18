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

    property int selectedCategoryX: 0
    property bool isMaximized: false
    property bool ignoreDeactivate: false
    property real normalX: 0
    property real normalY: 0
    property real normalWidth: width
    property real normalHeight: height
    property int statusBarHeight: 30 // must match your status bar's height

    // click-anywhere-closes: window loses focus (click outside) -> close
    // guarded by ignoreDeactivate so resizing (which can transiently
    // blur/refocus on some compositors) doesn't self-close the window
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

    // --- App data ---
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
        color: "#CC000000"
        width: parent.width
        height: parent.height
        border.color: "#20ffffff"
        border.width: 1
        radius: isMaximized ? 0 : 12

        // background click-catcher: sits behind everything, closes menu
        // when you click empty space (buttons/grid above it consume their own clicks first)
        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: window.close()
        }

        Rectangle {
            // top bar
            color: "#33838383"
            width: parent.width
            height: 50

            Rectangle {
                // topbar outline fyi
                color: "#20ffffff"
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
                    color: "#0Fffffff"
                    border.width: 1
                    border.color: "#26ffffff"
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
                height: 30
                color: "#ffffffff"
                x: ( parent.width / 2 ) - ( width / 2 )
                y: ( parent.height / 2 ) - ( height / 2 )
                leftPadding: 35
                placeholderText: "Search"

                onTextChanged: applyFilter(text)

                background: Rectangle {
                    color: "#0Fffffff"
                    border.color: "#26ffffff"
                    border.width: 0.5
                    radius: 25
                }
                Image {
                    source: "../../assets/icons/search.svg"
                    width: 17
                    height: 17
                    anchors.verticalCenter: parent.verticalCenter
                    x: 12
                }
            }

            Button {
                x: parent.width - width - 84
                y: ( parent.height / 2 ) - ( height / 2 )
                width: 28
                height: 28

                background: Rectangle {
                    radius: width / 2
                    color: "#0Fffffff"
                    border.width: 1
                    border.color: "#26ffffff"
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = "#1Affffff"
                        onExited: parent.color = "#0Fffffff"
                    }
                }

                onClicked: toggleMaximize()

                Image {
                    source: isMaximized ? "../../assets/icons/minimize.svg" : "../../assets/icons/maximize.svg"
                    width: 14
                    height: 14
                    anchors.centerIn: parent
                }
            }

            Button {
                x: parent.width - width - 50
                y: ( parent.height / 2 ) - ( height / 2 )
                width: 28
                height: 28

                background: Rectangle {
                    radius: width / 2
                    color: "#00ffffff"
                    border.width: 1
                    border.color: "#26ffffff"
                }

                Image {
                    source: "../../assets/icons/listview.svg"
                    width: 16
                    height: 16
                    anchors.centerIn: parent
                }
            }

            Button {
                x: parent.width - width - 16
                y: ( parent.height / 2 ) - ( height / 2 )
                width: 28
                height: 28

                background: Rectangle {
                    radius: width / 2
                    color: "#0Fffffff"
                    border.width: 1
                    border.color: "#26ffffff"
                }

                Image {
                    source: "../../assets/icons/gridview.svg"
                    width: 16
                    height: 16
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
                        color: "#40ffffff"
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

        // BOTTOM NAVBAR: pinned / all apps / recents, icon-only
        Rectangle {
            id: bottomNav
            width: 280
            height: 36
            color: "#0Affffff"
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height - height - 12
            radius: 50

            Rectangle {
                id: selectOverlay
                height: parent.height - 8
                color: "#26ffffff"
                radius: height / 2
                anchors.verticalCenter: parent.verticalCenter
                x: ( selectedCategoryX - 1 ) + 6
                width: 86

                Behavior on x {
                    NumberAnimation { duration: 250; easing.type: Easing.OutQuart }
                }
            }

            Row {
                id: navRow
                anchors.centerIn: parent
                width: parent.width - 12
                spacing: 4
                height: parent.height

                Button {
                    width: 86
                    height: parent.height

                    background: Rectangle { color: "#00ffffff" }

                    Image {
                        anchors.centerIn: parent
                        source: "../../assets/icons/apps.svg"
                        width: 16
                        height: 16
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: selectedCategoryX = parent.x
                    }
                }
                Button {
                    width: 86
                    height: parent.height

                    background: Rectangle { color: "#00ffffff" }

                    Image {
                        anchors.centerIn: parent
                        source: "../../assets/icons/star.svg"
                        width: 16
                        height: 16
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: selectedCategoryX = parent.x
                    }
                }
                Button {
                    width: 86
                    height: parent.height

                    background: Rectangle { color: "#00ffffff" }

                    Image {
                        anchors.centerIn: parent
                        source: "../../assets/icons/history.svg"
                        width: 16
                        height: 16
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: selectedCategoryX = parent.x
                    }
                }
            }
        }
    }
}