import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    anchors.fill: parent

    property var stackViewRef: null

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Верхняя панель — как в TrainingsPage.qml
        Rectangle {
            height: 56
            Layout.fillWidth: true
            color: "#f0f0f0"
            border.color: "#cccccc"

            Label {
                anchors.centerIn: parent
                text: "Тесты"
                font.pixelSize: 20
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: listView
                width: parent.width
                height: parent.height

                // Фильтр по категории "Тест"
                model: moduleRegistry.modules.filter(m => m.category === "Тест")

                spacing: 12
                clip: true

                delegate: Item {
                    width: listView.width
                    height: 72

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 8
                        color: "#dcdcdc"
                        radius: 10

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Image {
                                source: modelData.iconUrl
                                sourceSize.width: 32
                                sourceSize.height: 32
                                fillMode: Image.PreserveAspectFit

                                onStatusChanged: {
                                    if (status === Image.Error)
                                        console.log("Ошибка загрузки иконки:", modelData.iconUrl)
                                }
                            }

                            Text {
                                text: modelData.name
                                font.pixelSize: 16
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Item { Layout.fillWidth: true }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (root.stackViewRef) {
                                        var moduleFile = modelData.qmlSettingsUrl
                                        root.stackViewRef.push(moduleFile, {
                                            moduleData: modelData,
                                            stackViewRef: root.stackViewRef
                                        })
                                    } else {
                                        console.log("stackViewRef не передан")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
