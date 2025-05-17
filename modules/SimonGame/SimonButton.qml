import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    Layout.preferredWidth: 120
    Layout.preferredHeight: 120

    property int index: -1
    property color baseColor: "gray"             // Исходный цвет кнопки
    property color currentColor: baseColor       // Текущий цвет для отображения

    property bool isFlashing: false              // Вспомогательный флаг мигания
    property color flashColor: Qt.lighter(baseColor, 1.5) // Цвет мигания

    signal clicked(int index)

    Rectangle {
        id: background
        anchors.fill: parent
        radius: 16
        color: root.currentColor                  // Используем currentColor напрямую
        border.width: 2
        border.color: "black"
        scale: isFlashing ? 1.1 : 1.0

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        Behavior on scale {
            NumberAnimation { duration: 150 }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked(index)
    }
}
