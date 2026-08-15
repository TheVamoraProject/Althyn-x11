import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Qt5Compat.GraphicalEffects
import "../components"
import com.vamora

Window {
    id: window
    width: 348
    height: 548
    visible: true
    color: "transparent"
    title: "Vamora Quick Settings"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    // Keep Quick Settings on the same palette as the start menu, following appearance.theme.
    readonly property color cBg: isDark ? "#18181b" : "#fafafa"
    readonly property color cTopBar: isDark ? "#27272a" : "#f4f4f5"
    readonly property color cBorder: isDark ? "#3f3f46" : "#d4d4d8"
    readonly property color cSurface: isDark ? "#27272a" : "#f4f4f5"
    readonly property color cSurfaceHover: isDark ? "#3f3f46" : "#e4e4e7"
    readonly property color cText: isDark ? "#f4f4f5" : "#18181b"
    readonly property color cTextMuted: isDark ? "#a1a1aa" : "#52525b"
    readonly property color cTextFaint: "#71717a"
    readonly property color cAccent: isDark ? "#ffffff" : "#18181b"
    readonly property color cOnAccent: isDark ? "#09090b" : "#fafafa"

    ThemeManager {
        id: themeManager
    }

    // Local QML-native mirror of themeManager.darkMode — see statusbar.qml
    // for why we don't bind directly to themeManager.darkMode.
    property bool isDark: true

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            isDark = themeManager.refresh()
        }
    }

    onActiveChanged: {
        if (!active) {
            window.close()
        }
    }

    ListModel {
        id: toggleModel

        ListElement {
            label: "Wi-Fi"
            sub: "Vamora-5G"
            icon: "../../assets/icons/wifi/wifi.svg"
            on: true
            colSpan: 2
            rowSpan: 1
        }
        ListElement {
            label: "Notifications"
            sub: "Do Not Disturb"
            icon: "../../assets/icons/notification/bell.svg"
            on: false
            colSpan: 2
            rowSpan: 1
        }
        ListElement {
            label: "Keep Awake"
            sub: "Prevent sleep"
            icon: "../../assets/icons/cafeine.svg"
            on: false
            colSpan: 2
            rowSpan: 1
        }
        ListElement {
            label: "Always on Top"
            sub: "Pin windows"
            icon: "../../assets/icons/pin.svg"
            on: false
            colSpan: 2
            rowSpan: 1
        }
        ListElement {
            label: "USB Devices"
            sub: "Manage devices"
            icon: "../../assets/icons/usb.svg"
            on: false
            colSpan: 2
            rowSpan: 1
        }
        ListElement {
            label: "Workspaces"
            sub: "Overview"
            icon: "../../assets/icons/computer.svg"
            on: false
            colSpan: 2
            rowSpan: 1
        }
        ListElement {
            label: "File Sharing"
            sub: "Nearby devices"
            icon: "../../assets/icons/folder.svg"
            on: false
            colSpan: 2
            rowSpan: 1
        }
        ListElement {
            label: "Focus Mode"
            sub: "Quiet workspace"
            icon: "../../assets/icons/info.svg"
            on: false
            colSpan: 2
            rowSpan: 1
        }
    }

    Rectangle {
        id: panel
        anchors.fill: parent
        color: cBg
        border.color: cBorder
        border.width: 1
        radius: 32

        Rectangle {
            id: topBar
            width: parent.width
            height: 50
            color: cTopBar
            radius: parent.radius

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.radius
                color: parent.color
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: cBorder
            }

            // Power and edit are intentionally on the left, matching the original design.
            Row {
                x: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Rectangle {
                    width: 28
                    height: 28
                    radius: 14
                    color: cSurface
                    border.width: 1
                    border.color: cBorder

                    Image {
                        anchors.centerIn: parent
                        source: "../../assets/icons/power.svg"
                        width: 15
                        height: 15
                        layer.enabled: true
                        layer.effect: ColorOverlay {
                            color: cText
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = cSurfaceHover
                        onExited: parent.color = cSurface
                    }
                }

                Rectangle {
                    width: 28
                    height: 28
                    radius: 14
                    color: cSurface
                    border.width: 1
                    border.color: cBorder

                    Image {
                        anchors.centerIn: parent
                        source: "../../assets/icons/edit.svg"
                        width: 14
                        height: 14
                        layer.enabled: true
                        layer.effect: ColorOverlay {
                            color: cText
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = cSurfaceHover
                        onExited: parent.color = cSurface
                    }
                }
            }

            // The gear remains on the right; no title is shown in the top bar.
            Rectangle {
                x: parent.width - width - 16
                anchors.verticalCenter: parent.verticalCenter
                width: 28
                height: 28
                radius: 14
                color: cSurface
                border.width: 1
                border.color: cBorder

                Image {
                    anchors.centerIn: parent
                    source: "../../assets/icons/settings.svg"
                    width: 15
                    height: 15
                    layer.enabled: true
                    layer.effect: ColorOverlay {
                        color: cText
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = cSurfaceHover
                    onExited: parent.color = cSurface
                }
            }
        }

        // Everything below the top bar can scroll as more controls are added.
        Flickable {
            id: scrollView
            anchors.top: topBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: 1
            contentWidth: width
            contentHeight: contentColumn.implicitHeight + 28
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                width: 4
                contentItem: Rectangle {
                    implicitWidth: 4
                    radius: 2
                    color: cTextMuted
                    opacity: 0.65
                }
                background: null
            }

            Column {
                id: contentColumn
                width: scrollView.width - 32
                x: 16
                y: 14
                spacing: 12

                Text {
                    text: "QUICK CONTROLS"
                    color: cTextFaint
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1.1
                    font.family: "Inter"
                    leftPadding: 2
                }

                // Explicit spans make every module independently resizable later.
                GridLayout {
                    id: toggleGrid
                    width: parent.width
                    columns: 4
                    rowSpacing: 10
                    columnSpacing: 10

                    Repeater {
                        model: toggleModel

                        delegate: Rectangle {
                            Layout.columnSpan: model.colSpan
                            Layout.rowSpan: model.rowSpan
                            Layout.fillWidth: true
                            Layout.preferredHeight: 82
                            Layout.minimumHeight: 82
                            radius: 22
                            color: model.on ? cAccent : cSurface
                            border.width: 1
                            border.color: model.on ? cAccent : cBorder

                            Row {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 12
                                anchors.rightMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 10

                                Rectangle {
                                    width: 32
                                    height: 32
                                    radius: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: cBg

                                    Image {
                                        anchors.centerIn: parent
                                        source: model.icon
                                        width: 17
                                        height: 17
                                        opacity: model.on ? 1 : 0.82
                                        layer.enabled: true
                                        layer.effect: ColorOverlay {
                                            color: cText
                                        }
                                    }
                                }

                                Column {
                                    width: parent.width - 42
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 3

                                    Text {
                                        text: model.label
                                        color: model.on ? cOnAccent : cText
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        font.family: "Inter"
                                        width: parent.width
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: model.on ? model.sub : "Off"
                                        color: model.on ? cOnAccent : cTextMuted
                                        opacity: model.on ? 0.7 : 1
                                        font.pixelSize: 10
                                        font.family: "Inter"
                                        width: parent.width
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: if (!model.on) parent.color = cSurfaceHover
                                onExited: if (!model.on) parent.color = cSurface
                                onClicked: toggleModel.setProperty(index, "on", !model.on)
                            }
                        }
                    }
                }

                Text {
                    text: "DISPLAY & SOUND"
                    color: cTextFaint
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1.1
                    font.family: "Inter"
                    leftPadding: 2
                }

                SliderRow {
                    id: volumeRow
                    iconSource: "../../assets/icons/volume-2.svg"
                    value: 0.65
                }

                SliderRow {
                    id: brightnessRow
                    iconSource: "../../assets/icons/monitor.svg"
                    value: 0.8
                }

                Text {
                    text: "ACTIONS"
                    color: cTextFaint
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1.1
                    font.family: "Inter"
                    leftPadding: 2
                }

                Row {
                    width: parent.width
                    spacing: 10

                    ActionButton {
                        width: (parent.width - 10) / 2
                        label: "Restart"
                        iconSource: "../../assets/icons/refresh.svg"
                    }

                    ActionButton {
                        width: (parent.width - 10) / 2
                        label: "Shut Down"
                        iconSource: "../../assets/icons/power.svg"
                    }
                }
            }
        }
    }

    // Reusable slider row, kept local so Quick Settings remains one drop-in QML file.
    component SliderRow: Rectangle {
        property url iconSource
        property real value: 0.5

        width: parent.width
        height: 50
        radius: 20
        color: cSurface
        border.width: 1
        border.color: cBorder

        Row {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 10

            Rectangle {
                width: 30
                height: 30
                radius: 8
                anchors.verticalCenter: parent.verticalCenter
                color: cBg

                Image {
                    anchors.centerIn: parent
                    source: iconSource
                    width: 16
                    height: 16
                    layer.enabled: true
                    layer.effect: ColorOverlay {
                        color: cText
                    }
                }
            }

            Rectangle {
                id: track
                width: parent.width - 52
                height: 8
                radius: 4
                anchors.verticalCenter: parent.verticalCenter
                color: cBg

                Rectangle {
                    width: Math.max(8, track.width * value)
                    height: parent.height
                    radius: 4
                    color: cAccent
                }

                Rectangle {
                    x: Math.max(0, track.width * value - width / 2)
                    y: (parent.height - height) / 2
                    width: 18
                    height: 18
                    radius: 9
                    color: cText
                    border.width: 2
                    border.color: cBorder
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: value = Math.max(0, Math.min(1, mouse.x / width))
                    onPositionChanged: if (pressed) value = Math.max(0, Math.min(1, mouse.x / width))
                }
            }
        }
    }

    component ActionButton: Rectangle {
        property string label
        property url iconSource

        height: 38
        radius: 18
        color: cSurface
        border.width: 1
        border.color: cBorder

        Row {
            anchors.centerIn: parent
            spacing: 7

            Image {
                source: iconSource
                width: 14
                height: 14
                layer.enabled: true
                layer.effect: ColorOverlay {
                    color: cText
                }
            }

            Text {
                text: label
                color: cText
                font.pixelSize: 11
                font.weight: Font.Medium
                font.family: "Inter"
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.color = cSurfaceHover
            onExited: parent.color = cSurface
        }
    }
}