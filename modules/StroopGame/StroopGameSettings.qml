import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15

Item {
    id: root
    anchors.fill: parent

    // Входные параметры
    property var moduleData
    property var stackViewRef

    // Выбранная сложность
    property int difficulty: (moduleData && typeof moduleData.difficulty === "number") ? moduleData.difficulty : 5

    ToolButton {
        text: "\u2190"
        font.pixelSize: 30
        onClicked: stackView.pop()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 30

        Text {
            text: moduleData.description
            font.pixelSize: 22
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: root.width * 0.8  // или колонка.width * 0.8, если доступно
            width: root.width * 0.8
        }

        Label {
            text: "Выберите уровень сложности"
            font.pixelSize: 18
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 30

            // Левая кнопка
            MouseArea {
                width: 50
                height: 50
                onClicked: {
                    difficulty--
                    if (difficulty < 1) difficulty = 10
                }

                Shape {
                    anchors.fill: parent
                    ShapePath {
                        strokeWidth: 0
                        fillColor: "gray"
                        startX: 35; startY: 10
                        PathLine { x: 15; y: 25 }
                        PathLine { x: 35; y: 40 }
                        PathLine { x: 35; y: 10 }
                        //PathClose {}
                    }
                }
            }

            Rectangle {
                width: 100
                height: 60
                color: "#eeeeee"
                radius: 10
                border.color: "black"

                Text {
                    anchors.centerIn: parent
                    text: difficulty
                    font.pixelSize: 32
                    color: "black"
                }
            }

            // Правая кнопка
            // Правая кнопка (исправленная, треугольник вправо)
            MouseArea {
                width: 50
                height: 50
                onClicked: {
                    difficulty++
                    if (difficulty > 10) difficulty = 1
                }

                Shape {
                    anchors.fill: parent
                    ShapePath {
                        strokeWidth: 0
                        fillColor: "gray"
                        startX: 15; startY: 10
                        PathLine { x: 35; y: 25 }
                        PathLine { x: 15; y: 40 }
                    }
                }
            }
        }

        Button {
            text: "Продолжить"
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                if (moduleData && typeof moduleData.setDifficulty === "function") {
                    moduleData.setDifficulty(difficulty)
                    stackViewRef.push(moduleData.qmlComponentUrl, {
                        moduleData: moduleData,
                        stackViewRef: stackViewRef
                    })
                } else {
                    console.warn("Ошибка: moduleData или setDifficulty не определены")
                }
            }
        }

    }
}
