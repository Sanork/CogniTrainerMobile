import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    visible: true
    width: 360
    height: 640
    title: qsTr("Категории")

    Item {
        id: rootItem
        anchors.fill: parent
        focus: true
        // Печатаем в консоль, чтобы проверить, что вывод работает
                Component.onCompleted: {
                    console.log("Приложение запущено")
                }

        Keys.onReleased: {
            if (event.key === Qt.Key_Back) {
                if (stackView.depth > 1) {
                    event.accepted = true
                    stackView.pop()
                } else {
                    Qt.quit()
                }
            }
        }

        StackView {
            id: stackView
            anchors.fill: parent
            initialItem: categoryPage

            // Страница с категориями
            Component {
                id: categoryPage
                Item {
                    width: parent.width
                    height: parent.height

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10
                        anchors.margins: 20

                        Label {
                            text: "Выберите категорию:"
                            font.pixelSize: 20
                            Layout.alignment: Qt.AlignHCenter
                        }

                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: categoryManager.categories()
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

                                    Image {
                                        id: categoryIcon
                                        source: modelData.icon
                                        sourceSize.width: 30
                                        sourceSize.height: 30
                                        fillMode: Image.PreserveAspectFit

                                        onStatusChanged: {
                                            console.log("Image status: " + categoryIcon.status)
                                            if (categoryIcon.status === Image.Error) {
                                                console.log("Error loading image!")
                                            }
                                        }
                                    }

                                    Text {
                                        text: modelData.name      // ← это тоже правильно
                                        font.pixelSize: 16
                                        verticalAlignment: Text.AlignVCenter
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Item { Layout.fillWidth: true }

                                    Button {
                                        text: "Открыть"
                                        onClicked: {
                                            const modulesForCategory = moduleRegistry.modules.filter(m => m.category === modelData.name);
                                            stackView.push("qrc:/qml/CategoryModulesView.qml", {
                                                categoryName: modelData.name,
                                                modulesModel: modulesForCategory,
                                                stackViewRef: stackView
                                            });
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
}
