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

        // === Состояния ===
        property real timeLeft: 3
        property int score: 0
        property int currentRound: 0
        property int maxRounds: 50
        property int roundDuration: 3000

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
            if (answer === gameArea.correctAnswer) {
                gameArea.score++
            }
            gameArea.nextRound()
        }

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: gameArea.currentWord
                color: gameArea.currentColor
                font.pixelSize: 48
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
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
                columns: 2
                rowSpacing: 15
                columnSpacing: 15
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    model: gameArea.colorNames
                    delegate: Button {
                        text: modelData
                        onClicked: gameArea.checkAnswer(modelData)
                        Layout.fillWidth: true
                        Layout.preferredHeight: 70    // увеличена высота кнопки
                        implicitWidth: 160            // увеличена минимальная ширина кнопки

                        background: Rectangle {
                            color: "#3a3a3a"
                            border.color: "white"
                            radius: 8                  // чуть больше скругление
                        }
                        contentItem: Text {
                            text: modelData
                            color: "white"
                            font.pixelSize: 24          // увеличен размер шрифта
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            anchors.fill: parent
                            padding: 6
                        }
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
                            gameArea.startGame()
                        }
                    }
                }
            }
        }

        Component.onCompleted: gameArea.startGame()
    }
}
