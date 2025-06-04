import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.1

Page {
    id: settingsPage
    title: "Настройки"

    property Settings appSettingsRef
    property bool initialized: false

    Dialog {
        id: restartDialog
        title: "Требуется перезапуск"
        modal: true
        standardButtons: Dialog.Ok
        // Размеры диалога
        width: 300
        height: 200

        // Центрируем диалог относительно окна приложения
            x: (settingsPage.width - width) / 2
            y: (settingsPage.height - height) / 2

        onAccepted: restartDialog.close()

        contentItem: Label {
            text: "Перезапустите приложение, чтобы применить новую тему."
            wrapMode: Text.WordWrap
            padding: 16
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Label {
            text: "Тема оформления"
            font.bold: true
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            spacing: 12
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            Label {
                text: "Светлая"
                font.pixelSize: 16
                verticalAlignment: Text.AlignVCenter
            }

            Switch {
                id: themeSwitch
                checked: appSettingsRef.value("theme", "light") === "dark"

                Component.onCompleted: {
                    initialized = true
                }

                onCheckedChanged: {
                    if (initialized) {
                        appSettingsRef.setValue("theme", checked ? "dark" : "light")
                        restartDialog.open()
                    }
                }
            }

            Label {
                text: "Тёмная"
                font.pixelSize: 16
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
