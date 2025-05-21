import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Item {
    property var moduleData
    anchors.fill: parent

    Rectangle {
        id: gameArea
        anchors.fill: parent
        color: "#2b2b2b"

        // === Данные ===
        property var colorNames: ["Красный", "Синий", "Зелёный", "Жёлтый", "Чёрный", "Белый"]
        property var colorValues: ["red", "blue", "green", "yellow", "black", "white"]
        property string currentWord: ""
        property string currentColor: ""
        property string correctAnswer: ""

        property string selectedAnswer: ""
        property bool answerCorrect: false

        // === Состояния ===
        property real timeLeft: 3
        property int score: 0
        property int currentRound: 0
        property int maxRounds: 50
        property int roundDuration: 3000

        property bool isCountdownActive: true


        ToolButton {
            text: "\u2190"
            font.pixelSize: 24
            onClicked: stackView.pop()
            background: Rectangle {
                color: "transparent"
            }
            contentItem: Text {
                text: "\u2190"
                color: "white"
                font.pixelSize: 24
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        // === Обратный отсчёт перед началом ===
        Item {
            id: countdownOverlay
            anchors.fill: parent
            visible: true
            z: 999

            property int countdownValue: 3

            Rectangle {
                width: 200
                height: 200
                radius: 100
                color: Qt.rgba(0, 0, 0, 0.6)
                anchors.centerIn: parent

                Text {
                    id: countdownText
                    text: countdownOverlay.countdownValue > 0 ? countdownOverlay.countdownValue : "Старт!"
                    anchors.centerIn: parent
                    font.pixelSize: 72
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Timer {
                id: countdownStartTimer
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    countdownOverlay.countdownValue--
                    if (countdownOverlay.countdownValue < 0) {
                        countdownStartTimer.stop()
                        countdownOverlay.visible = false
                        gameArea.isCountdownActive = false
                        gameArea.startGame()
                    }
                }

            }
        }




        Timer {
            id: countdownTimer
            interval: 100
            repeat: true
            running: false
            onTriggered: {
                gameArea.timeLeft -= 0.1
                if (gameArea.timeLeft <= 0) {
                    countdownTimer.stop()
                    gameArea.nextRound()
                }
           }
        }

        Timer {
            id: answerFeedbackTimer
            interval: 300
            running: false
            repeat: false
            onTriggered: {
                gameArea.selectedAnswer = ""
                gameArea.nextRound()
            }
        }


        function startGame() {
            gameArea.score = 0
            gameArea.currentRound = 0
            gameOverOverlay.visible = false

            let difficulty = moduleData.difficulty
            let maxTime = 5000
            let minTime = 500
            gameArea.roundDuration = maxTime - ((difficulty - 1) * (maxTime - minTime) / 9)

            gameArea.nextRound()
        }

        function nextRound() {
            gameArea.currentRound++
            if (gameArea.currentRound > gameArea.maxRounds) {
                gameOverOverlay.visible = true
                return
            }

            let wordIndex = Math.floor(Math.random() * gameArea.colorNames.length)
            let colorIndex = Math.floor(Math.random() * gameArea.colorValues.length)

            gameArea.currentWord = gameArea.colorNames[wordIndex]
            gameArea.currentColor = gameArea.colorValues[colorIndex]
            gameArea.correctAnswer = gameArea.colorNames[colorIndex]

            gameArea.timeLeft = gameArea.roundDuration / 1000.0
            countdownTimer.restart()
        }

        function checkAnswer(answer) {
            countdownTimer.stop()
            selectedAnswer = answer
            answerCorrect = (answer === correctAnswer)

            if (answerCorrect) {
                score++
            }

            answerFeedbackTimer.start()
        }



        Item {
            id: contentArea
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 80  // чуть ниже, чем было

            // === СЛОВО ===
            Text {
                id: wordText
                text: gameArea.currentWord
                visible: gameArea.currentWord !== "" && !gameArea.isCountdownActive
                color: gameArea.currentColor
                font.pixelSize: 48
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                layer.enabled: true
                layer.effect: DropShadow {
                    color: "black"
                    radius: 6
                    samples: 16
                    horizontalOffset: 0
                    verticalOffset: 0
                    transparentBorder: true
                }
            }

            // === КНОПКИ ===
            GridLayout {
                id: colorGrid
                columns: 2
                rowSpacing: 15
                columnSpacing: 15
                anchors.top: wordText.bottom
                anchors.topMargin: 24
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    model: gameArea.colorNames
                    delegate: Button {
                        text: modelData
                        enabled: !gameArea.isCountdownActive && gameArea.selectedAnswer === ""
                        onClicked: gameArea.checkAnswer(modelData)
                        Layout.fillWidth: true
                        Layout.preferredHeight: 70
                        implicitWidth: 160

                        background: Rectangle {
                            color: {
                                if (gameArea.selectedAnswer === modelData) {
                                    return gameArea.answerCorrect ? "green" : "darkred"
                                } else {
                                    return "#3a3a3a"
                                }
                            }
                            border.color: "white"
                            radius: 8

                            // Анимация ПРИ смене цвета обратно
                            Behavior on color {
                                ColorAnimation {
                                    duration: 300
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }

                        contentItem: Text {
                            text: modelData
                            color: "white"
                            font.pixelSize: 24
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            anchors.fill: parent
                            padding: 6
                        }
                    }
                }
            }

            // === СЧЁТЧИК РАУНДОВ ===
            Text {
                id: roundsCounter
                text: "Слово " + gameArea.currentRound + " из " + gameArea.maxRounds
                color: "white"
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                anchors.top: colorGrid.bottom
                anchors.topMargin: 30
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !gameArea.isCountdownActive && !gameOverOverlay.visible
            }

        }

        Rectangle {
            id: timerBarBackground
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 10
            color: "#555"

            Rectangle {
                id: timerBar
                height: parent.height
                width: parent.width * (gameArea.timeLeft * 1000 / gameArea.roundDuration)
                color: "orange"
                anchors.left: parent.left

                Behavior on width {
                    NumberAnimation {
                        duration: 100
                        easing.type: Easing.Linear
                    }
                }
            }
        }


        // === ОКНО ОКОНЧАНИЯ ИГРЫ ===
        Rectangle {
            id: gameOverOverlay
            visible: false
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.6)
            z: 1000

            Rectangle {
                width: parent.width * 0.5
                height: parent.height * 0.35
                radius: 12
                anchors.centerIn: parent
                color: "#ffffff"
                border.color: "#cccccc"
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 16
                    width: parent.width

                    Text {
                        text: "Тренировка\nокончена!"
                        font.pixelSize: 26
                        color: "black"
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "Точность: " + Math.round((gameArea.score / gameArea.maxRounds) * 100) + " %"
                        font.pixelSize: 20
                        color: "black"
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Button {
                        text: "Сыграть снова"
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            gameArea.isCountdownActive = true
                            countdownOverlay.countdownValue = 3
                            countdownOverlay.visible = true
                            countdownStartTimer.restart()
                            gameOverOverlay.visible = false
                        }

                    }
                }
            }
        }

        Component.onCompleted: {
            gameArea.isCountdownActive = true
            countdownOverlay.countdownValue = 3
            countdownOverlay.visible = true
            countdownStartTimer.start()
        }
    }
}
