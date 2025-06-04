import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import QtQuick.Controls.Material 2.15

Item {
    id: root
    anchors.fill: parent

    property var moduleData
    property var stackViewRef

    property int difficultyMode: 4
    property bool endlessMode: false

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20   // уменьшил с 30 на 20 для компактности

        // Верхняя панель
        RowLayout {
            Layout.fillWidth: true
            spacing: 10  // было 12

            ToolButton {
                text: "\u2190"
                font.pixelSize: 30     // было 28 → 30, как во втором
                onClicked: stackViewRef?.pop()
                Material.foreground: Material.theme === Material.Dark ? "white" : "black"
            }

            Label {
                text: moduleData?.name || "Модуль"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

        }

        // Инструкция
        Label {
            text: moduleData?.description || ""
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: root.width * 0.8   // как во втором
        }

        // Подпись выбора сложности
        Label {
            text: "Выберите длину последовательности"

            font.weight: Font.DemiBold
            Layout.alignment: Qt.AlignHCenter
        }


        // Панель выбора сложности
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20

            MouseArea {
                width: 40  // было 50
                height: 40
                onClicked: {
                    difficultyMode--
                    if (difficultyMode < 1) difficultyMode = 8
                }

                Shape {
                    anchors.fill: parent
                    ShapePath {
                        strokeWidth: 0
                        fillColor: "gray"
                        startX: 28; startY: 8
                        PathLine { x: 12; y: 20 }
                        PathLine { x: 28; y: 32 }
                        PathLine { x: 28; y: 8 }
                    }
                }
            }

            Rectangle {
                width: 80   // было 100
                height: 50  // было 60
                radius: 8
                color: Material.theme === Material.Dark ? "#444" : "#eeeeee"
                border.color: Material.theme === Material.Dark ? "#aaa" : "black"

                Text {
                    anchors.centerIn: parent
                    text: difficultyMode
                    font.pixelSize: 28   // было 32
                    color: Material.theme === Material.Dark ? "white" : "black"
                }
            }

            MouseArea {
                width: 40
                height: 40
                onClicked: {
                    difficultyMode++
                    if (difficultyMode > 8) difficultyMode = 1
                }

                Shape {
                    anchors.fill: parent
                    ShapePath {
                        strokeWidth: 0
                        fillColor: "gray"
                        startX: 12; startY: 8
                        PathLine { x: 28; y: 20 }
                        PathLine { x: 12; y: 32 }
                    }
                }
            }
        }



        // Бесконечный режим
        CheckBox {
            text: "Бесконечный режим"
            checked: endlessMode
            Layout.alignment: Qt.AlignHCenter
            onCheckedChanged: endlessMode = checked
        }


        // Кнопка продолжить
        Button {
            text: "Продолжить"
            Layout.alignment: Qt.AlignHCenter
            width: 280   // чуть меньше 300
            onClicked: {
                if (moduleData) {
                    stackViewRef.push(moduleData.qmlComponentUrl, {
                        moduleData: moduleData,
                        stackViewRef: stackViewRef,
                        endlessMode: endlessMode,
                        difficultyMode: difficultyMode
                    })
                } else {
                    console.warn("Ошибка: moduleData не определён")
                }
            }
        }
    }
}
