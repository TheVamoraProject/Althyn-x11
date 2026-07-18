import QtQuick
import QtQuick.Controls

Button {
    // size is set by parent (anchors.fill); these are just fallback defaults
    implicitWidth: 80
    implicitHeight: 80

    property string appName: ""
    property string iconPath: ""
    property string execStr: ""

    background: Rectangle {
        color: "#00ffffff"
        radius: width / 6

        MouseArea {
            width: parent.width
            height: parent.height
            hoverEnabled: true
            onEntered: parent.color = "#0Affffff"
            onExited: parent.color = "#00ffffff"
        }
    }

    Column {
        anchors.centerIn: parent
        width: parent.width - 8
        spacing: 5

        Image {
            source: iconPath !== "" ? iconPath : "../../assets/icons/unknown.svg"
            width: 44
            height: 44
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        Text {
            text: appName
            color: "#ffffff"
            font.pixelSize: 11
            font.weight: Font.Medium
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            elide: Text.ElideRight
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
