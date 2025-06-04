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

        // Верхняя панель
        Rectangle {
            height: 72
            Layout.fillWidth: true
            anchors.margins: 8
            anchors.bottomMargin: 6
            color: Material.theme === Material.Dark ? "#2c3e50" : "#C9E9FF"

            Label {
                anchors.centerIn: parent
                text: "Тесты"
                font.pixelSize: 22
                color: Material.theme === Material.Dark ? "white" : "black"
            }
        }

        /*Rectangle {
            width: root.width
            height: 2
            color: Material.theme === Material.Dark ? "white" : "black"
        }*/

        Item { width: root.width; height: 8 }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: listView
                width: parent.width
                height: parent.height

                model: moduleRegistry.modules.filter(m => m.category === "Тест")
                spacing: 8
                clip: true

                delegate: Item {
                    width: listView.width
                    height: 88

                    Rectangle {
                        id: card
                        anchors.fill: parent
                        anchors.margins: 8
                        radius: 15
                        //border.color: Material.theme === Material.Dark ? "white" : "black"
                        //border.width: 2
                        color: Material.theme === Material.Dark ? "#2c3e50" : "#C9E9FF"

                        Image {
                            id: iconImage
                            source: modelData.iconUrl
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.leftMargin: 2
                            width: height - 4
                            fillMode: Image.PreserveAspectFit
                            mipmap: true

                            onStatusChanged: {
                                if (status === Image.Error)
                                    console.log("Ошибка загрузки иконки:", modelData.iconUrl)
                            }
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
                                if (root.stackViewRef) {
                                    root.stackViewRef.push(modelData.qmlSettingsUrl, {
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
