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

            Component {
                id: categoryPage
                Item {
                    width: parent.width
                    height: parent.height

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        // Верхняя панель
                        Rectangle {
                            id: topBar
                            height: 56
                            width: parent.width
                            color: "#f0f0f0"
                            border.color: "#cccccc"
                            Layout.fillWidth: true



                            Label {
                                anchors.centerIn: parent
                                text: "Выберите категорию:"
                                font.pixelSize: 20
                            }
                        }

                        Item {
                                Layout.preferredHeight: 8
                            }



                        // Список категорий с прокруткой
                        ListView {
                            id: listView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: categoryManager.categories()
                            spacing: 12
                            clip: true

                            delegate: Item {
                                width: listView.width
                                height: 72  // немного выше, чтобы учесть внешние отступы

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.leftMargin: 16  // ← отступ слева
                                    anchors.rightMargin: 16
                                    height: 60
                                    color: "#dcdcdc"
                                    radius: 10

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 12

                                        Image {
                                            id: categoryIcon
                                            source: modelData.icon
                                            sourceSize.width: 32
                                            sourceSize.height: 32
                                            fillMode: Image.PreserveAspectFit

                                            onStatusChanged: {
                                                if (categoryIcon.status === Image.Error)
                                                    console.log("Ошибка загрузки иконки:", modelData.icon)
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
                                                const modulesForCategory = moduleRegistry.modules.filter(m => m.category === modelData.name)
                                                stackView.push("qrc:/qml/CategoryModulesView.qml", {
                                                    categoryName: modelData.name,
                                                    modulesModel: modulesForCategory,
                                                    stackViewRef: stackView
                                                })
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
}
