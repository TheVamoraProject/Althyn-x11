import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import QtQuick.Window
import "../components"
import com.vamora

Window {
    id: window
    visible: true
    width: screen.width
    height: 30
    title: "Vamora StatusBar"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"
    x: 0
    y: 0

    // ---- Vamora/AlthynUI palette (dark only, zinc) ----
    readonly property color cBarBg: "#CC09090b"        // zinc-950 @ 80%
    readonly property color cHover: "#40272a2e"         // zinc-800 hover overlay
    readonly property color cDivider: "#33ffffff"
    readonly property color cText: "#f4f4f5"            // zinc-100
    readonly property color cTextMuted: "#a1a1aa"        // zinc-400
    readonly property color cAccent: "#2563eb"           // Vamora blue-600

    property date currentTime: new Date()
    property int iconSize: 17
    property int trayBtnSize: 28

    UserInfo {
        id: userInfo
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: currentTime = new Date()
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: userInfo.refresh()
    }

    Rectangle {
        id: dock
        anchors.fill: parent
        color: cBarBg
        radius: 0
        border.width: 0

        Item {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8

            // LEFT SIDE
            Row {
                id: leftRow
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Button { // start button
                    width: trayBtnSize
                    height: trayBtnSize
                    padding: 0

                    background: Rectangle {
                        color: "#00000000"
                        radius: 8
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = cHover
                            onExited: parent.color = "#00000000"
                        }
                    }

                    onClicked: { 
                        if ( startMenu.active ) {
                        startMenu.active = false;
                        } else {
                        calendarLoader.active = false;   // force the other one shut first
                        startMenu.active = true;
                        startMenu.item.x = window.x + 8
                        startMenu.item.y = window.y + window.height + 6
                        }
                    }
                    Image {
                        anchors.centerIn: parent
                        width: parent.width - 8
                        height: parent.height - 8
                        source: "../../assets/Vamora.svg"
                    }
                }

                DividerV {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 4
                    color: window.cDivider
                }

                Button { // time
                    width: 118
                    height: trayBtnSize
                    padding: 0

                    background: Rectangle {
                        color: "#00000000"
                        radius: 8
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = cHover
                            onExited: parent.color = "#00000000"
                        }
                    }

                    onClicked: { // time / clock button
                        if ( calendarLoader.active ) {
                            calendarLoader.active = false;
                        } else {
                            startMenu.active = false;   // force the other one shut first
                            calendarLoader.active = true;
                            calendarLoader.item.x = window.x + 8
                            calendarLoader.item.y = window.y + window.height + 6
                        }
                    }
                    Text {
                        id: time
                        anchors.centerIn: parent
                        text: Qt.formatDateTime(currentTime, "hh:mm  ddd, d MMM")
                        color: cText
                        font.weight: Font.Medium
                        font.pixelSize: 13
                        font.family: "Inter"
                    }
                }

                Button { // notification
                    width: trayBtnSize
                    height: trayBtnSize
                    padding: 0

                    background: Rectangle {
                        color: "#00000000"
                        radius: 8
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = cHover
                            onExited: parent.color = "#00000000"
                        }
                    }

                    Image {
                        anchors.centerIn: parent
                        width: iconSize
                        height: iconSize
                        source: "../../assets/icons/notification/bell.svg"
                    }
                }
            }

            // RIGHT SIDE
            Row {
                id: rightRow
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Button {
                    width: trayBtnSize
                    height: trayBtnSize
                    padding: 0
                    background: Rectangle {
                        color: "#00000000"
                        radius: 8
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = cHover
                            onExited: parent.color = "#00000000"
                        }
                    }
                    Image {
                        anchors.centerIn: parent
                        width: iconSize
                        height: iconSize
                        source: "../../assets/icons/arrows/arrowdown.svg"
                    }
                }

                Button {
                    width: trayBtnSize
                    height: trayBtnSize
                    padding: 0
                    background: Rectangle {
                        color: "#00000000"
                        radius: 8
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = cHover
                            onExited: parent.color = "#00000000"
                        }
                    }
                    Image {
                        anchors.centerIn: parent
                        width: iconSize
                        height: iconSize
                        source: "../../assets/icons/volume-2.svg"
                    }
                }

                Button {
                    width: trayBtnSize
                    height: trayBtnSize
                    padding: 0
                    background: Rectangle {
                        color: "#00000000"
                        radius: 8
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = cHover
                            onExited: parent.color = "#00000000"
                        }
                    }
                    Image {
                        anchors.centerIn: parent
                        width: iconSize
                        height: iconSize
                        source: {
                            switch (userInfo.wifiStrength) {
                                case 4:  return "../../assets/icons/wifi.svg"
                                case 3:  return "../../assets/icons/wifi-high.svg"
                                case 2:  return "../../assets/icons/wifi-low.svg"
                                case 1:  return "../../assets/icons/wifi-low.svg"
                                default: return "../../assets/icons/wifi-zero.svg"
                            }
                        }
                    }
                }

                Button {
                    width: trayBtnSize
                    height: trayBtnSize
                    padding: 0
                    background: Rectangle {
                        color: "#00000000"
                        radius: 8
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = cHover
                            onExited: parent.color = "#00000000"
                        }
                    }
                    Image {
                        anchors.centerIn: parent
                        width: iconSize
                        height: iconSize
                        source: "../../assets/icons/settings.svg"
                    }
                }

                DividerV {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 4
                    color: window.cDivider
                }

                Button { // battery
                    width: trayBtnSize
                    height: trayBtnSize
                    padding: 0
                    background: Rectangle {
                        color: "#00000000"
                        radius: 8
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = cHover
                            onExited: parent.color = "#00000000"
                        }
                    }
                    Image {
                        anchors.centerIn: parent
                        width: iconSize
                        height: iconSize
                        source: "../../assets/icons/battery-full.svg"
                    }
                }
            }
        }
    }

    Loader {
        id: startMenu
        source: "../startmenu/window.qml"
        active: false
    }

    Loader {
        id: calendarLoader
        source: "../calendar/window.qml"
        active: false
    }
}
