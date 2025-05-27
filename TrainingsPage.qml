import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "."  // Чтобы находить локальные компоненты

Item {
    id: root
    anchors.fill: parent

    property var stackViewRef

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            height: 56
            Layout.fillWidth: true
            color: "#f0f0f0"
            border.color: "#cccccc"

            Label {
                anchors.centerIn: parent
                text: "Выберите категорию:"
                font.pixelSize: 20
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: categoryManager.categories()
            spacing: 12
            clip: true

            delegate: Item {
                width: ListView.view.width
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
                            source: modelData.icon
                            sourceSize.width: 32
                            sourceSize.height: 32
                            fillMode: Image.PreserveAspectFit
                        }

                        Text {
                            text: modelData.name
                            font.pixelSize: 16
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Item { Layout.fillWidth: true }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            const modulesForCategory = moduleRegistry.modules.filter(m => m.category === modelData.name)
                            if (stackViewRef) {
                                stackViewRef.push("qrc:/qml/CategoryModulesView.qml", {
                                    categoryName: modelData.name,
                                    modulesModel: modulesForCategory,
                                    stackViewRef: stackViewRef
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
