import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property var moduleData
    property var stackViewRef

    property string fullText: ""
    property var allSentences: moduleData.sentences
    property int countSentences: 5
    property int currentIndex: 0
    property var stateList: []

    property int totalTyped: 0
    property int correctTyped: 0
    property real startTime: 0
    property real elapsedTime: 0
    property real spm: 0
    property real accuracy: 0
    property bool timerRunning: false

    Component.onCompleted: {
        generateFullText()
        stateList = new Array(fullText.length).fill(0)
        Qt.callLater(() => {
            typingField.forceActiveFocus()
            Qt.inputMethod.show()
        })
    }

    Rectangle {
        id: topBar
        height: 60
        width: parent.width
        color: Material.theme === Material.Dark ? "#303030" : "#f0f0f0"
        border.color: Material.theme === Material.Dark ? "#555555" : "#cccccc"

        RowLayout {
            anchors.fill: parent
            spacing: 8
            anchors.margins: 8

            ToolButton {
                text: "\u2190"
                font.pixelSize: 24
                onClicked: stackViewRef.pop()
                background: Rectangle { color: "transparent" }
                contentItem: Label {
                    text: "\u2190"
                    font.pixelSize: 24
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Item { Layout.fillWidth: true }

            ColumnLayout {
                spacing: 4
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                Text {
                    text: "Скорость: " + spm.toFixed(1) + " сим/мин"
                    font.pixelSize: 16
                    color: Material.theme === Material.Dark ? "white" : "black"
                }

                Text {
                    text: "Точность: " + accuracy.toFixed(1) + " %"
                    font.pixelSize: 16
                    color: Material.theme === Material.Dark ? "white" : "black"
                }

            }
        }
    }

    Item {
        id: contentArea

        focus: true
        Keys.forwardTo: [typingField]
        anchors {
            top: topBar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        Column {
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                topMargin: 20
            }

            Label {
                id: displayText
                width: contentArea.width * 0.8
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.pixelSize: 18
                textFormat: Text.RichText
                horizontalAlignment: Text.AlignHCenter

                text: {
                    stateList; currentIndex; fullText;
                    var result = ""
                    var correctBg = Material.theme === Material.Dark ? "#336633" : "#ccffcc"
                    var wrongBg = Material.theme === Material.Dark ? "#663333" : "#ffcccc"

                    for (var i = 0; i < fullText.length; i++) {
                        var c = fullText[i]
                        var style = ""
                        if (stateList[i] === 1)
                            style += "background-color:" + correctBg + ";"
                        else if (stateList[i] === 2)
                            style += "background-color:" + wrongBg + ";"
                        if (i === currentIndex)
                            style += "text-decoration: underline;"
                        result += style.length > 0 ? "<span style='" + style + "'>" + c + "</span>" : c
                    }
                    return result
                }

            }

            TextField {
                id: typingField
                width: 100
                height: 100
                opacity: 0
                focus: true
                visible: true
                z: -1

                property string lastText: ""

                onTextChanged: {
                    if (text.length > lastText.length) {
                        const newChar = text.charAt(text.length - 1)
                        processInputChar(newChar)

                    } else {
                        lastText = text
                    }
                }


            }

            Button {
                text: "Перезапустить"
                width: 150
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    generateFullText()
                    stateList = new Array(fullText.length).fill(0)
                    resetParams()
                }
            }


        }
    }

    Rectangle {
        id: gameOverOverlay
        visible: false
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)
        z: 1000

        Rectangle {
            width: 250
            height: 250
            radius: 12
            anchors.centerIn: parent
            color: Material.theme === Material.Light ? "#C9E9FF" : "#2c3e50"
            border.color: Material.theme === Material.Light ? "#cccccc" : "#34495e"
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: "Тренировка\nокончена!"
                    font.pixelSize: 26
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    color: Material.theme === Material.Light ? "#000000" : "#ecf0f1"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "Скорость: " + spm.toFixed(1) + " сим/мин\nТочность: " + accuracy.toFixed(1) + " %"
                    font.pixelSize: 18
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    color: Material.theme === Material.Light ? "#000000" : "#ecf0f1"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Button {
                    text: "Сыграть снова"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        root.resetParams()
                    }
                }
            }
        }
    }


    Timer {
        id: updateTimer
        interval: 1000
        running: false
        repeat: true
        onTriggered: {
            if (startTime > 0) {
                elapsedTime = (Date.now() - startTime) / 1000.0
                if (elapsedTime > 0) {
                    spm = (correctTyped / elapsedTime) * 60.0
                    accuracy = totalTyped > 0 ? (correctTyped / totalTyped) * 100.0 : 0
                }
            }
        }
    }

    function generateFullText() {
        if (allSentences && allSentences.length >= 5) {
            var copy = allSentences.slice()
            var selected = []
            for (var i = 0; i < countSentences; i++) {
                var index = Math.floor(Math.random() * copy.length)
                selected.push(copy.splice(index, 1)[0])
            }
            fullText = selected.join(" ")
        } else {
            console.warn("Недостаточно предложений в allSentences")
            fullText = "Пример текста для тренировки."
        }
    }

    function resetParams() {
        fullText = ""
        generateFullText()
        currentIndex = 0
        stateList = new Array(fullText.length).fill(0)
        correctTyped = 0
        totalTyped = 0
        startTime = 0
        elapsedTime = 0
        spm = 0
        accuracy = 0
        timerRunning = false
        updateTimer.stop()
        gameOverOverlay.visible = false
        typingField.text = ""
        typingField.lastText = ""
        Qt.callLater(() => {
            typingField.forceActiveFocus()
            Qt.inputMethod.show()
        })
    }


    function processInputChar(inputChar) {
        if (currentIndex >= fullText.length)
            return;

        if (!timerRunning) {
            startTime = Date.now()
            updateTimer.start()
            timerRunning = true
        }

        totalTyped++
        let expectedChar = fullText[currentIndex]

        // Отладка
        // console.log("Ожидалось:", JSON.stringify(expectedChar), "Введено:", JSON.stringify(inputChar))

        let cleanInput = inputChar.normalize().trim().toLowerCase()
        let cleanExpected = expectedChar.normalize().trim().toLowerCase()

        if (cleanInput === cleanExpected) {
            stateList[currentIndex] = 1
            currentIndex++
            correctTyped++
            if (currentIndex >= fullText.length) {
                updateTimer.stop()
                timerRunning = false
                gameOverOverlay.visible = true
            }
        } else {
            stateList[currentIndex] = 2
        }

        stateList = stateList.slice()
    }
}
