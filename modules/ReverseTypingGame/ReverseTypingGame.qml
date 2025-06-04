// Импорт
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtTextToSpeech

Item {
    id: root

    property var moduleData
    property var stackViewRef
    property bool endlessMode
    property int wordDisplayMode  // 0 = всё время, 1 = 3 секунды, 2 = аудио
    property string currentWord: ""
    property string userInput: ""

    property int round: 0
    property int targetRound: 5

    property real startTime : 0
    property real averageWordTime : 0
    property real trainingTime: 0

    property bool showWord: true
    property bool hasError: false

    Timer {
        id: hideTimer
        interval: 3000
        repeat: false
        onTriggered: showWord = false
    }

    Component.onCompleted: {
        countdownTimer.start()
    }

    function initParameters() {
        round = 0
        startTime = Date.now()
        trainingTime = 0
        averageWordTime = 0
        mainScreen.visible = true
        textField.focus = true
        updateTimer.start()
        loadNextWord()
    }

    Timer {
        id: updateTimer
        interval: 100
        running: false
        repeat: true
        onTriggered: {
            if (startTime > 0)
                trainingTime = (Date.now() - startTime) / 1000.0
        }
    }

    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        running: false
        onTriggered: {
            countdownOverlay.countdownValue--
            if (countdownOverlay.countdownValue < 0) {
                countdownTimer.stop()
                countdownOverlay.visible = false
                initParameters()
            }
        }
    }

    Item {
        id: countdownOverlay
        anchors.fill: parent
        visible: true
        z: 999
        property int countdownValue: 3

        Rectangle {
            width: 120
            height: 120
            radius: width / 2
            color: Qt.rgba(0, 0, 0, 0.6)
            anchors.centerIn: parent

            Text {
                text: countdownOverlay.countdownValue > 0 ? countdownOverlay.countdownValue : "Старт!"
                anchors.centerIn: parent
                font.pixelSize: 36
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    function loadNextWord() {
        if (moduleData && typeof moduleData.nextWord === "function") {
            currentWord = moduleData.nextWord()
            if (wordDisplayMode === 0) {
                showWord = true
            } else if (wordDisplayMode === 1) {
                hideTimer.start()
                showWord = true
            } else if (wordDisplayMode === 2) {
                showWord = false
                speech.say(currentWord)
            }
        }
    }

    Rectangle {
        id: topBar
        height: 56
        width: parent.width
        anchors.top: parent.top
        color: Material.theme === Material.Dark ? "#303030" : "#f0f0f0"
        border.color: Material.theme === Material.Dark ? "#555555" : "#cccccc"

        RowLayout {
            anchors.fill: parent
            anchors.rightMargin: 8
            anchors.leftMargin: 8
            spacing: 4

            ToolButton {
                text: "\u2190"
                font.pixelSize: 28
                onClicked: stackViewRef?.pop()
                Material.foreground: Material.theme === Material.Dark ? "white" : "black"
            }

            Item {
                Layout.fillWidth: true
            }

            // Статистика
            ColumnLayout {
                spacing: 2
                visible: !gameOverOverlay.visible
                Layout.alignment: Qt.AlignVCenter

                Text {
                    text: "Время: " + trainingTime.toFixed(0) + " сек"
                    font.pixelSize: 16
                    color: Material.theme === Material.Dark ? "#ddd" : "#333"
                }

                Text {
                    text: !endlessMode ? "Осталось: " + (targetRound - round) : ""
                    font.pixelSize: 14
                    color: Material.theme === Material.Dark ? "#aaa" : "#555"
                    visible: !endlessMode
                }
            }

            // Кнопка стоп
            Item {
                width: 40
                height: 40
                visible: endlessMode && !gameOverOverlay.visible && !countdownOverlay.visible

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: Material.theme === Material.Dark ? "#888888" : "#666666"
                }

                Rectangle {
                    width: 14
                    height: 14
                    color: Material.theme === Material.Dark ? "#ddd" : "white"
                    radius: 3
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.endGame()
                    cursorShape: Qt.PointingHandCursor
                }

                Layout.alignment: Qt.AlignVCenter
            }
        }
    }



    TextToSpeech {
        id: speech
        locale: Qt.locale("ru_RU")
    }

    Column {
        id: mainScreen
        visible: false
        spacing: 24
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: topBar.bottom
        anchors.topMargin: 40
        width: Math.min(parent.width * 0.9, 400)

        Label {
            id: wordDisplay
            text: currentWord
            font.pixelSize: 36
            font.bold: true
            visible: true
            opacity: showWord ? 1 : 0
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
        }


        TextField {
            id: textField
            width: parent.width
            inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhPreferLowercase | Qt.ImhNoAutoUppercase | Qt.ImhEnterKeyTypeDone
            font.pixelSize: 18
            Keys.enabled: true
            text: userInput
            placeholderText: "Введите слово"
            onTextChanged: {
                userInput = text
                hasError = false
            }
            onActiveFocusChanged: {
                if (!activeFocus)
                    hasError = false
            }
            Keys.onReturnPressed: checkInput()

            Keys.onReleased: (event) => {
                if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                    checkInput()
                    event.accepted = true
                }
            }

            Material.accent: hasError ? "red" : "gray"




        }


        Button {
            text: "Проверить"
            width: 160
            font.pixelSize: 18
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                checkInput()
                textField.forceActiveFocus()
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
            id: dialogRect
            width: parent.width * 0.6
            height: parent.height * 0.45
            radius: 12
            anchors.centerIn: parent

            color: Material.theme === Material.Light ? "#C9E9FF" : "#2c3e50"
            border.color: Material.theme === Material.Light ? "#cccccc" : "#34495e"
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                Label {
                    text: "Тренировка\nзавершена!"
                    font.pixelSize: 26
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    color: Material.theme === Material.Light ? "#000000" : "#ecf0f1"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // Статистика
                Column {
                    spacing: 6
                    anchors.horizontalCenter: parent.horizontalCenter

                    Label {
                        text: endlessMode ? "Слов пройдено: " + round : ""
                        visible: endlessMode
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        color: Material.theme === Material.Light ? "#000000" : "#ecf0f1"
                    }

                    Label {
                        text: "Время: " + trainingTime.toFixed(2) + " сек"
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        color: Material.theme === Material.Light ? "#000000" : "#ecf0f1"
                    }

                    Label {
                        text: round !== 0 ? "Среднее: " + averageWordTime.toFixed(2) + " сек" : ""
                        visible: round !== 0
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        color: Material.theme === Material.Light ? "#000000" : "#ecf0f1"
                    }
                }

                Button {
                    text: "Сыграть снова"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: resetParams()
                }
            }
        }
    }


    function checkInput() {
        if (moduleData && typeof moduleData.checkAnswer === "function") {
            const correct = moduleData.checkAnswer(userInput)
            if (correct) {
                round++
                userInput = ""
                hasError = false
                hideTimer.stop()
                if (round === targetRound && !endlessMode) {
                    endGame()
                    return
                }
                loadNextWord()
            } else {
                hasError = true
                textField.focus = true
            }
        }
    }

    function endGame() {
        averageWordTime = trainingTime / round
        gameOverOverlay.visible = true
        updateTimer.stop()
    }

    function resetParams() {
        gameOverOverlay.visible = false
        countdownOverlay.countdownValue = 3
        countdownOverlay.visible = true
        mainScreen.visible = false
        round = 0
        trainingTime = 0
        averageWordTime = 0
        countdownTimer.restart()
    }
}
