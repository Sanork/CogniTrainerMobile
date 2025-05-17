// Card.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    property real cardWidth: 80
    property real cardHeight: 100
    property string value: ""
    property bool flipped: false
    property bool matched: false
    signal clicked()

    property bool allowFlipAnimation: true

    width: cardWidth
    height: cardHeight

    property real angle: 0
    property bool showFront: flipped || matched

    // Переворот: 0 → 90 → меняем сторону → 90 → 0
    SequentialAnimation on angle {
        id: flipAnimation
        PropertyAnimation { to: 90; duration: 150; easing.type: Easing.InOutQuad }
        ScriptAction { script: root.showFront = !root.showFront }
        PropertyAnimation { to: 0; duration: 150; easing.type: Easing.InOutQuad }
        running: false
    }

    onFlippedChanged: {
            if (!matched && allowFlipAnimation)
                flipAnimation.start()
            else
                showFront = flipped || matched  // мгновенно, без анимации
        }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
        enabled: !matched && !flipped
        cursorShape: Qt.PointingHandCursor
    }

    // Обертка для поворота
    Item {
        anchors.fill: parent
        transform: Rotation {
            origin.x: root.width / 2
            origin.y: root.height / 2
            axis { x: 0; y: 1; z: 0 }
            angle: root.angle
        }

        // Передняя сторона (открыта)
        Rectangle {
            visible: root.showFront
            width: parent.width
            height: parent.height
            radius: 10
            color: matched ? "#aaffaa" : "#ffffff"
            border.color: "#444"
            border.width: 1

            Text {
                anchors.centerIn: parent
                font.pixelSize: 30
                text: value
                color: "black"
            }
        }

        // Задняя сторона (закрыта)
        Rectangle {
            visible: !root.showFront
            width: parent.width
            height: parent.height
            radius: 10
            color: "#888888"
            border.color: "#444"
            border.width: 1
        }
    }
}
