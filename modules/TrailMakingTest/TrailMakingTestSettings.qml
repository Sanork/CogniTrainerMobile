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
    property int age: (moduleData && typeof moduleData.age === "number") ? moduleData.age : 1


    property int gridColumns: {
        switch (age) {
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
        switch (age) {
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

            Label {
                text: moduleData?.name || "Модуль"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Item { width: 28 }
        }

        Label {
            text: "Выберите ваш возраст"
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
                    age--
                    if (age < 6) age = 90
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
                    text: age
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
                    age++
                    if (age > 90) age = 6
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
                if (moduleData && typeof moduleData.setAge === "function") {
                    moduleData.setAge(age)
                    stackViewRef.push(moduleData.qmlComponentUrl, {
                        moduleData: moduleData,
                        stackViewRef: stackViewRef
                    })
                } else {
                    console.warn("Ошибка: moduleData или setAge не определены")
                }
            }
        }
    }
}
