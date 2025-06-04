import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."  // Чтобы находить локальные компоненты

Item {
    id: root
    anchors.fill: parent

    property var stackViewRef

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            height: 72
            Layout.fillWidth: true

            anchors.margins: 8
            anchors.bottomMargin: 6
            color: Material.theme === Material.Dark ? "#2c3e50" : "#C9E9FF"


            Label {
                anchors.centerIn: parent
                text: "Выберите категорию:"
                font.pixelSize: 22
                color: Material.theme === Material.Dark ? "white" : "black"
            }

        }
        /*Rectangle {
            width: root.width
            color: Material.theme === Material.Dark ? "white" : "black"
            height: 2
        }*/

        Item {
            width: root.width
            height: 8
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: categoryManager.categories()
            clip: true

            delegate: Item {
                width: ListView.view.width
                height: 88
                anchors.topMargin: 4

                Rectangle {
                    id: backgroundRect
                    anchors.fill: parent
                    anchors.margins: 8
                    radius: 15
                    //border.color: Material.theme === Material.Dark ? "white" : "black"
                    //border.width: 2

                    // Конкретные цвета для тем и высокая контрастность
                    color: Material.theme === Material.Dark ? "#2c3e50" : "#C9E9FF"  // Тёмно-синий и светло-синий

                    Image {
                        id: iconImage
                        source: modelData.icon
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.leftMargin: 2
                        width: height - 4
                        fillMode: Image.PreserveAspectFit
                        mipmap: true

                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: iconImage.width + 24
                        anchors.rightMargin: 12
                        anchors.topMargin: 12
                        anchors.bottomMargin: 12
                        spacing: 12

                        Text {
                            text: modelData.name
                            font.pixelSize: 22
                            color: Material.theme === Material.Dark ? "#ffffff" : "#000000"
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
