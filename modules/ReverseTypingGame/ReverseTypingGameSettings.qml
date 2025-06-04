import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Item {
    id: root
    anchors.fill: parent

    property var moduleData
    property var stackViewRef

    // Параметры
    property bool endlessMode: (moduleData && typeof moduleData.endlessMode === "boolean") ? moduleData.endlessMode : false
    property int wordDisplayMode: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 30

        // Верхняя панель
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

            Item { width: 28 } // чтобы центрировать заголовок
        }

        // Описание
        Label {
            text: moduleData?.description || ""
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: root.width * 0.85
        }

        // Заголовок режима игры
        Label {
            text: "Режим игры"
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        // Переключатели режима
        ColumnLayout {
            spacing: 10
            Layout.alignment: Qt.AlignHCenter

            RadioButton {
                text: "Показывать всё время"
                font.pixelSize: 16
                checked: wordDisplayMode === 0
                onClicked: wordDisplayMode = 0
            }

            RadioButton {
                text: "Показывать 3 секунды"
                font.pixelSize: 16
                checked: wordDisplayMode === 1
                onClicked: wordDisplayMode = 1
            }

            RadioButton {
                text: "Только аудиопроизношение"
                font.pixelSize: 16
                checked: wordDisplayMode === 2
                onClicked: wordDisplayMode = 2
            }
        }

        // Бесконечный режим
        CheckBox {
            text: "Бесконечный режим"
            checked: endlessMode
            Layout.alignment: Qt.AlignHCenter
            onCheckedChanged: endlessMode = checked
        }

        // Кнопка продолжения
        Button {
            text: "Продолжить"
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                if (moduleData) {
                    moduleData.endlessMode = endlessMode
                    stackViewRef.push(moduleData.qmlComponentUrl, {
                        moduleData: moduleData,
                        stackViewRef: stackViewRef,
                        wordDisplayMode: wordDisplayMode,
                        endlessMode: endlessMode
                    })
                } else {
                    console.warn("Ошибка: moduleData не определён")
                }
            }
        }
    }
}
