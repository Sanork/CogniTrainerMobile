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
        property bool isPaused: false

        // === Данные ===
        property var colorNames: ["Красный", "Синий", "Зелёный", "Жёлтый", "Чёрный", "Белый"]
        property var colorValues: ["red", "blue", "green", "yellow", "black", "white"]
        property string currentWord: ""
        property string currentColor: ""
        property string correctAnswer: ""

        property int correctCount: 0

        property string selectedAnswer: ""
        property bool answerCorrect: false

        // === Состояния ===
        property real timeLeft: 3
        property int score: 0
        property int currentRound: 0
        property int maxRounds: 10
        property int roundDuration: 3000

        property bool isCountdownActive: true

        ToolButton {
            text: "\u2190"
            font.pixelSize: 24
            onClicked: stackView.pop()
            background: Rectangle { color: "transparent" }
            contentItem: Text {
                text: "\u2190"
                color: "white"
                font.pixelSize: 24
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Row {
            id: controlButtons
            spacing: 10
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 10
            anchors.rightMargin: 10
            visible: !gameOverOverlay.visible && !countdownOverlay.visible

            // Пауза
            Item {
                width: 40
                height: 40

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "#666666"
                }

                // Левая палочка
                Rectangle {
                    width: 5
                    height: 16
                    radius: 2
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.horizontalCenter
                    anchors.rightMargin: 2
                }

                // Правая палочка
                Rectangle {
                    width: 5
                    height: 16
                    radius: 2
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.horizontalCenter
                    anchors.leftMargin: 2
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: gameArea.togglePause()
                }
            }

            // Стоп (только для бесконечного режима)
            Item {
                width: 40
                height: 40
                visible: moduleData.endlessMode

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "#666666"
                }

                Rectangle {
                    width: 14
                    height: 14
                    color: "white"
                    radius: 3
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: gameArea.endGame()
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }



        // === Обратный отсчёт ===
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
                if (!gameArea.isPaused) {
                    gameArea.timeLeft -= 0.1
                    if (gameArea.timeLeft <= 0) {
                        countdownTimer.stop()
                        gameArea.nextRound()
                    }
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
            gameArea.correctCount = 0  // <- сброс
            gameArea.currentRound = 0
            gameOverOverlay.visible = false
            gameArea.isPaused = false

            let difficulty = moduleData.difficulty
            let maxTime = 5000
            let minTime = 500
            gameArea.roundDuration = maxTime - ((difficulty - 1) * (maxTime - minTime) / 9)

            gameArea.nextRound()
        }


        function nextRound() {
            if (!moduleData.endlessMode && gameArea.currentRound >= gameArea.maxRounds) {
                gameOverOverlay.visible = true
                countdownTimer.stop()
                return
            }

            if (!gameArea.isPaused) {
                // ⚠️ Никаких увеличений здесь
                let wordIndex = Math.floor(Math.random() * gameArea.colorNames.length)
                let colorIndex = Math.floor(Math.random() * gameArea.colorValues.length)

                gameArea.currentWord = gameArea.colorNames[wordIndex]
                gameArea.currentColor = gameArea.colorValues[colorIndex]
                gameArea.correctAnswer = gameArea.colorNames[colorIndex]

                gameArea.timeLeft = gameArea.roundDuration / 1000.0
                countdownTimer.restart()
            }
        }


        function checkAnswer(answer) {
            if (gameArea.isPaused) return
            countdownTimer.stop()
            selectedAnswer = answer
            answerCorrect = (answer === correctAnswer)

            gameArea.currentRound++  // ✅ теперь только здесь, после ответа

            if (answerCorrect) {
                gameArea.score++
                gameArea.correctCount++
            }

            answerFeedbackTimer.start()
        }



        Item {
            id: contentArea
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 80

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
                text: moduleData.endlessMode
                    ? (gameArea.currentRound === 0 ? "" : "Правильно: " + gameArea.correctCount + " из " + gameArea.currentRound)
                    : "Слово " + gameArea.currentRound + " из " + gameArea.maxRounds
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
                        text: moduleData.endlessMode
                            ? "Точность: " + (gameArea.currentRound > 0 ? Math.round((gameArea.correctCount / gameArea.currentRound) * 100) : 0) + " %"
                            : "Точность: " + Math.round((gameArea.score / gameArea.maxRounds) * 100) + " %"
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

        Item {
            id: pauseOverlay
            anchors.fill: parent
            visible: gameArea.isPaused
            z: 998

            Rectangle {
                width: 150
                height: 150
                radius: width / 2
                color: Qt.rgba(0, 0, 0, 0.6)
                anchors.centerIn: parent

                Text {
                    text: "Пауза"
                    anchors.centerIn: parent
                    font.pixelSize: 28
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: gameArea.togglePause()
            }
        }

        function togglePause() {
            gameArea.isPaused = !gameArea.isPaused
            if (gameArea.isPaused) {
                countdownTimer.stop()
            } else if (!gameArea.isCountdownActive && gameArea.timeLeft > 0) {
                countdownTimer.start()
            }
        }

        function endGame() {
            countdownTimer.stop()
            gameOverOverlay.visible = true
        }


        Component.onCompleted: {
            gameArea.isCountdownActive = true
            countdownOverlay.countdownValue = 3
            countdownOverlay.visible = true
            countdownStartTimer.start()
        }
    }
}
