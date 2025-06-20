import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import QtQuick.Controls.Material 2.15

Item {
    id: root
    anchors.fill: parent

    property var moduleData
    property var stackViewRef

    property bool endlessMode: (moduleData && typeof moduleData.endlessMode === "boolean") ? moduleData.endlessMode : false

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 30

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ToolButton {
                text: "\u2190"
                font.pixelSize: 28
                onClicked: stackViewRef?.pop()
                Material.foreground: Material.theme === Material.Dark ? "white" : "black"
            }

            Label {
                text: moduleData?.name || "Модуль"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Item { width: 28 }
        }

        Label {
            text: moduleData?.description || ""
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: root.width * 0.85
        }

        CheckBox {
            text: "Бесконечный режим"
            checked: endlessMode
            Layout.alignment: Qt.AlignHCenter
            onCheckedChanged: endlessMode = checked
        }

        Button {
            text: "Продолжить"
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                    moduleData.endlessMode = endlessMode

                    stackViewRef.push(moduleData.qmlComponentUrl, {
                        moduleData: moduleData,
                        stackViewRef: stackViewRef
                    })

            }
        }
    }
}
