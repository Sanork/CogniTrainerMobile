import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    anchors.fill: parent

    // Входные параметры
    property var moduleData
    property var stackViewRef

    ToolButton {
        text: "\u2190"
        font.pixelSize: 30
        onClicked: stackViewRef.pop()
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
            Layout.preferredWidth: root.width * 0.8
        }

        CheckBox {
            id: endlessCheckBox
            text: "Бесконечный режим"
            checked: moduleData && moduleData.endlessMode === true
            Layout.alignment: Qt.AlignHCenter

            onCheckedChanged: {
                if (moduleData) {
                    moduleData.endlessMode = checked
                }
            }
        }

        Button {
            text: "Продолжить"
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                if (moduleData) {
                    stackViewRef.push(moduleData.qmlComponentUrl, {
                        moduleData: moduleData,
                        stackViewRef: stackViewRef
                    })
                } else {
                    console.warn("Ошибка: moduleData не определён")
                }
            }
        }
    }
}
