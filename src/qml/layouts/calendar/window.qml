import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import QtQuick.Window
import "../components"

Window {
    width: 320
    height: 360
    visible: true
    color: "transparent"
    title: "Vamora Calendar"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    // ---- VamoraUI palette (dark, zinc, solid — no transparency here) ----
    readonly property color cBg: "#18181b"        // zinc-900, solid
    readonly property color cTopBar: "#27272a"    // zinc-800, solid
    readonly property color cBorder: "#3f3f46"    // zinc-700
    readonly property color cSurface: "#27272a"   // zinc-800
    readonly property color cSurfaceHover: "#3f3f46" // zinc-700
    readonly property color cText: "#f4f4f5"      // zinc-100
    readonly property color cTextMuted: "#a1a1aa" // zinc-400
    readonly property color cTextFaint: "#71717a" // zinc-500
    readonly property color cAccent: "#ffffff"    // white accent (today marker)
    readonly property color cOnAccent: "#09090b"  // near-black text on white

    property date viewDate: new Date()
    property date today: new Date()

    function daysInMonth(y, m) {
        return new Date(y, m + 1, 0).getDate()
    }

    function firstWeekday(y, m) {
        return new Date(y, m, 1).getDay()
    }

    function isToday(y, m, d) {
        return d === today.getDate() && m === today.getMonth() && y === today.getFullYear()
    }

    Rectangle {
        id: calendar
        color: cBg
        width: parent.width
        height: parent.height
        border.color: cBorder
        border.width: 1
        radius: 24

        // TOP BAR
        Rectangle {
            id: topBar
            color: cTopBar
            width: parent.width
            height: 50
            radius: 24

            // squares off the bottom corners of the top bar so it doesn't
            // look like a separate rounded pill sitting inside a rounded window
            Rectangle {
                color: parent.color
                width: parent.width
                height: parent.height / 2
                y: parent.height / 2
            }

            Rectangle {
                // topbar outline
                color: cBorder
                width: parent.width
                height: 1
                y: 49
            }

            Button { // prev month
                x: 16
                y: ( parent.height / 2 ) - ( height / 2 )
                width: 28
                height: 28
                padding: 0

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

                onClicked: {
                    viewDate = new Date(viewDate.getFullYear(), viewDate.getMonth() - 1, 1)
                }

                Image {
                    source: "../../assets/icons/lucide/chevron-left.svg"
                    width: 14
                    height: 14
                    anchors.centerIn: parent
                }
            }

            Text {
                anchors.centerIn: parent
                text: Qt.formatDate(viewDate, "MMMM yyyy")
                color: cText
                font.pixelSize: 15
                font.weight: Font.Medium
                font.family: "Inter"
            }

            Button { // next month
                x: parent.width - width - 16
                y: ( parent.height / 2 ) - ( height / 2 )
                width: 28
                height: 28
                padding: 0

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

                onClicked: {
                    viewDate = new Date(viewDate.getFullYear(), viewDate.getMonth() + 1, 1)
                }

                Image {
                    source: "../../assets/icons/lucide/chevron-right.svg"
                    width: 14
                    height: 14
                    anchors.centerIn: parent
                }
            }
        }

        // WEEKDAY LABEL ROW
        Row {
            id: weekdayRow
            width: parent.width - 24
            x: 12
            y: 62
            spacing: 0

            Repeater {
                model: ["S", "M", "T", "W", "T", "F", "S"]
                Item {
                    width: weekdayRow.width / 7
                    height: 20
                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: cTextFaint
                        font.pixelSize: 12
                        font.weight: Font.Medium
                    }
                }
            }
        }

        // DAY GRID
        Grid {
            id: dayGrid
            columns: 7
            width: parent.width - 24
            x: 12
            y: 90
            rowSpacing: 4
            columnSpacing: 0

            Repeater {
                model: firstWeekday(viewDate.getFullYear(), viewDate.getMonth())
                Item {
                    width: dayGrid.width / 7
                    height: 34
                }
            }

            Repeater {
                model: daysInMonth(viewDate.getFullYear(), viewDate.getMonth())

                Item {
                    width: dayGrid.width / 7
                    height: 34

                    property int dayNum: index + 1
                    property bool todayFlag: isToday(viewDate.getFullYear(), viewDate.getMonth(), dayNum)

                    Rectangle {
                        anchors.centerIn: parent
                        width: 28
                        height: 28
                        radius: 14
                        color: todayFlag ? cAccent : (dayMouse.containsMouse ? cSurfaceHover : "#00000000")
                        border.width: 0

                        Text {
                            anchors.centerIn: parent
                            text: dayNum
                            color: todayFlag ? cOnAccent : cText
                            font.pixelSize: 13
                            font.weight: todayFlag ? Font.DemiBold : Font.Normal
                        }

                        MouseArea {
                            id: dayMouse
                            anchors.fill: parent
                            hoverEnabled: true
                        }
                    }
                }
            }
        }
    }
}
