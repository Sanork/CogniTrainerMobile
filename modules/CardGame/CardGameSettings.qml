import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15

import "../../"

Item {
    id: root
    anchors.fill: parent

    // Входные параметры
    property var moduleData
    property var stackViewRef

    // Выбранная сложность
    property int difficulty: (moduleData && typeof moduleData.difficulty === "number") ? moduleData.difficulty : 1


    property int gridColumns: {
        switch (difficulty) {
            case 1: return 2;
            case 2: return 4;
            case 3: return 4;
            case 4: return 4;
            case 5: return 5;
            case 6: return 5;
            default: return 4;
        }
    }
    property int gridRows: {
        switch (difficulty) {
            case 1: return 3;
            case 2: return 3;
            case 3: return 4;
            case 4: return 6;
            case 5: return 6;
            case 6: return 8;
            default: return 4;
        }
    }


    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 30

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ToolButton {
                text: "\u2190"
                font.pixelSize: 28
                onClicked: stackViewRef?.pop()
                Material.foreground: Material.theme === Material.Dark ? "white" : "black"
            }

            AppLabel {
                text: moduleData?.name || "Модуль"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Item { width: 28 }
        }

        Label {
            text: moduleData?.description || ""
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: root.width * 0.85
        }

        Label {
            text: "Выберите размер поля"
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
                    if (difficulty < 1) difficulty = 6
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
                   radius: 10
                   color: Material.theme === Material.Dark ? "#444" : "#eeeeee"
                   border.color: Material.theme === Material.Dark ? "#aaa" : "black"

                Text {
                    anchors.centerIn: parent
                    text: gridColumns + " x " + gridRows
                    font.pixelSize: 32
                    color: Material.theme === Material.Dark ? "white" : "black"
                }
            }

            // Правая кнопка
            // Правая кнопка (исправленная, треугольник вправо)
            MouseArea {
                width: 50
                height: 50
                onClicked: {
                    difficulty++
                    if (difficulty > 6) difficulty = 1
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
