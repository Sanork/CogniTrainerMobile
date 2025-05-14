// Card.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    property real cardWidth: 80
    property real cardHeight: 100
    property string value: ""
    property bool flipped: false
    property bool matched: false
    signal clicked()

    width: root.cardWidth
    height: root.cardHeight  // выше — удобно для вертикального размещения
    radius: 10
    color: matched ? "#aaffaa" : (flipped ? "#ffffff" : "#888888")
    border.color: "#444"
    border.width: 1

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
        enabled: !matched && !flipped
        cursorShape: Qt.PointingHandCursor
    }

    Text {
        anchors.centerIn: parent
        font.pixelSize: 30
        text: (flipped || matched) ? value : ""
        color: "black"
        visible: flipped || matched
    }
}
