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

    property int difficulty: (moduleData && typeof moduleData.difficulty === "number") ? moduleData.difficulty : 5
    property bool endlessMode: (moduleData && typeof moduleData.endlessMode === "boolean") ? moduleData.endlessMode : false

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

            Label {
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
            text: "Выберите уровень сложности"
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 30

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
                       text: difficulty
                       font.pixelSize: 32
                       color: Material.theme === Material.Dark ? "white" : "black"
                   }
               }

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

        CheckBox {
            text: "Бесконечный режим"
            checked: endlessMode
            Layout.alignment: Qt.AlignHCenter
            onCheckedChanged: endlessMode = checked
        }

        Button {
            text: "Продолжить"
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                if (moduleData?.setDifficulty) {
                    moduleData.setDifficulty(difficulty)
                    moduleData.endlessMode = endlessMode

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
