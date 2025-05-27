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
            text: "Выберите ваш возраст"
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
                width: 140
                height: 60
                color: "#eeeeee"
                radius: 10
                border.color: "black"

                Text {
                    anchors.centerIn: parent
                    text: age
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
