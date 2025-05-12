import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    property string categoryName
    property var modulesModel
    property var stackViewRef: null // Убираем alias и объявляем, как обычное свойство

    width: parent.width
    height: parent.height

    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        anchors.margins: 20
        Button {
                            text: "← Назад"
                            onClicked: {
                                stackView.pop(); // Возвращаемся к предыдущей странице
                            }
                        }

        Label {
            text: "Модули категории: " + categoryName
            font.pixelSize: 20
            Layout.alignment: Qt.AlignHCenter
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: modulesModel
            spacing: 10
            delegate: Rectangle {
                width: parent.width
                height: 50
                color: "lightgray"
                radius: 10
                Layout.fillWidth: true

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Text {
                        text: modelData.name
                        font.pixelSize: 16
                        verticalAlignment: Text.AlignVCenter
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Button {
                        text: "Открыть"
                        onClicked: {

                            var moduleFile = modelData.qmlSettingsUrl ;

                            stackViewRef.push(moduleFile, {
                                moduleData: modelData,  // Передаем данные модуля
                                stackViewRef: stackViewRef  // Передаем stackView, если нужно будет переходить с этого экрана
                            });
                        }
                    }

                }
            }
        }
    }
}
