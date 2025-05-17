import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    property string categoryName
    property var modulesModel
    property var stackViewRef: null

    width: parent.width
    height: parent.height

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Верхняя панель
        Rectangle {
            height: 50
            width: parent.width
            color: "#f0f0f0"
            Layout.fillWidth: true

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 12

                ToolButton {
                    text: "\u2190"
                    font.pixelSize: 30
                    onClicked: stackViewRef.pop()
                }

                Label {
                    text: categoryName
                    font.pixelSize: 18
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true }
            }
        }

        // Отступ после верхней панели
        Item {
            Layout.preferredHeight: 8
        }

        // Прокручиваемый список
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: listView
                width: parent.width
                height: parent.height
                model: modulesModel
                spacing: 12
                clip: true

                delegate: Item {
                    width: listView.width
                    height: 72

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        height: 60
                        radius: 10
                        color: "#dcdcdc"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Image {
                                            id: moduleIcon
                                            source: modelData.iconUrl
                                            sourceSize.width: 32
                                            sourceSize.height: 32
                                            fillMode: Image.PreserveAspectFit

                                            onStatusChanged: {
                                                if (moduleIcon.status === Image.Error)
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
                                    var moduleFile = modelData.qmlSettingsUrl
                                    stackViewRef.push(moduleFile, {
                                        moduleData: modelData,
                                        stackViewRef: stackViewRef
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
