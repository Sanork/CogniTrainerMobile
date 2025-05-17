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

        Button {
            text: "Продолжить"
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                if (moduleData ) {
                    stackViewRef.push(moduleData.qmlComponentUrl, {
                        moduleData: moduleData,
                        stackViewRef: stackViewRef
                    })
                } else {
                    console.warn("Ошибка: moduleData или setDifficulty не определены")
                }
            }
        }

        Button {
            text: "← Назад"
            Layout.alignment: Qt.AlignHCenter
            onClicked: stackViewRef.pop()
        }
    }
}
