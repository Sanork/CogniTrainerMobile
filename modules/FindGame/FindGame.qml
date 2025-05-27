import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    anchors.fill: parent

    property int score: 0
    property int currentRound: 0
    property int maxRounds: 20

    property color baseColor: "#6699cc"
    property color targetColor: "#6699cc"
    property var figuresData: []

    property bool isCountdownActive: false
    property bool awaitingNextRound: false
    property int selectedIndex: -1
    property bool lastChoiceCorrect: false

    property int totalGridWidth: 0
    property int totalGridHeight: 0

    property var moduleData

    property bool isPaused: false





    Rectangle {
        anchors.fill: parent
        color: "#2b2b2b"
    }

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

    Row {
        spacing: 12
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 6
        anchors.rightMargin: 10

        Text {
            text: root.moduleData && root.moduleData.endlessMode
                       ? "Раунд: " + currentRound
                       : "Раунд: " + Math.min(currentRound, maxRounds) + " / " + maxRounds

            font.pixelSize: 20
            color: "white"
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignVCenter
        }

        // Кнопка "Пауза"
        Item {
            width: 40
            height: 40

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "#666666"
            }

            Rectangle {
                width: 5
                height: 16
                radius: 2
                color: "white"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.horizontalCenter
                anchors.rightMargin: 2
            }

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
                onClicked: root.togglePause()
            }
        }

        // Кнопка "Стоп" — только в бесконечном режиме
        Item {
            width: 40
            height: 40
            visible: moduleData && moduleData.endlessMode

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
                onClicked: root.endGame()
                cursorShape: Qt.PointingHandCursor
            }
        }
    }


    RowLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        spacing: 10



        Item { Layout.fillWidth: true }



    }

    Item {
        id: playArea
        anchors {
            fill: parent
            topMargin: 80
            leftMargin: 20
            rightMargin: 20
            bottomMargin: 20
        }

    }




    Item {
        id: figuresContainer
        anchors.centerIn: playArea
        width: totalGridWidth
        height: totalGridHeight
        visible: !root.isCountdownActive

        Repeater {
            model: figuresData
            delegate: Rectangle {
                width: modelData.size
                height: modelData.size
                radius: 10
                x: modelData.x
                y: modelData.y
                color: modelData.color
                border.color: {
                    if (root.awaitingNextRound && index === root.selectedIndex)
                        return root.lastChoiceCorrect ? "lime" : "red"
                    else
                        return "black"
                }
                border.width: 2

                MouseArea {

                    anchors.fill: parent
                    enabled: !root.awaitingNextRound && !root.isCountdownActive && !root.isPaused
                    onClicked: {
                        root.selectedIndex = index
                        root.awaitingNextRound = true
                        root.lastChoiceCorrect = (modelData.isTarget === true)
                        if (root.lastChoiceCorrect) root.score++
                        selectionTimer.stop()
                        timerBarAnimation.stop()
                        nextRoundDelay.start()
                    }
                }
            }
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
            width: parent.width
            color: "orange"
            anchors.left: parent.left
        }

        PropertyAnimation {
            id: timerBarAnimation
            target: timerBar
            property: "width"
            from: timerBarBackground.width
            to: 0
            duration: 5000
        }
    }


    Item {
        id: countdownOverlay
        anchors.fill: parent
        visible: false
        z: 999
        property int countdownValue: 3

        Rectangle {
            width: 150; height: 150
            radius: 75
            color: Qt.rgba(0, 0, 0, 0.6)
            anchors.centerIn: parent

            Text {
                text: countdownOverlay.countdownValue > 0 ? countdownOverlay.countdownValue : "Старт!"
                anchors.centerIn: parent
                font.pixelSize: 50
                color: "white"
            }
        }

        Timer {
            id: countdownTimer
            interval: 1000
            running: false
            repeat: true
            onTriggered: {
                countdownOverlay.countdownValue--
                if (countdownOverlay.countdownValue < 0) {
                    countdownTimer.stop()
                    countdownOverlay.visible = false
                    isCountdownActive = false
                    generateFigures()
                }
            }
        }
    }

    Item {
        id: pauseOverlay
        anchors.fill: parent
        visible: root.isPaused
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
            onClicked: root.togglePause()
        }
    }



    Timer {
        id: nextRoundDelay
        interval: 1000
        running: false
        repeat: false
        onTriggered: {
            if (root.isPaused) return
            awaitingNextRound = false
            selectedIndex = -1
            nextRound()
        }

    }

    Timer {
        id: selectionTimer
        interval: 5000
        running: false
        repeat: false
        onTriggered: {
            if (root.isPaused) return
            root.awaitingNextRound = true
            root.lastChoiceCorrect = false
            root.selectedIndex = -1
            nextRoundDelay.start()
        }

    }

    // === ОКОНЧАНИЕ ИГРЫ (для игры "Найди отличающуюся фигуру") ===
    Rectangle {
        id: figureGameOverOverlay
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
                    text: root.moduleData && root.moduleData.endlessMode
                        ? "Результат: " + score + " из " + currentRound
                        : "Результат: " + score + " из " + maxRounds
                    font.pixelSize: 20
                    color: "black"
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Button {
                    text: "Сыграть снова"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        figureGameOverOverlay.visible = false
                        startCountdown()

                    }
                }
            }
        }
    }

    function startCountdown() {
        score = 0
        currentRound = 0
        isCountdownActive = true
        countdownOverlay.countdownValue = 3
        countdownOverlay.visible = true
        countdownTimer.start()
    }

    function togglePause() {
        root.isPaused = !root.isPaused
        if (root.isPaused) {
            selectionTimer.stop()
            timerBarAnimation.pause()
        } else {
            if (!root.awaitingNextRound && !root.isCountdownActive) {
                selectionTimer.start()
                timerBarAnimation.resume()
            }
        }
    }


    function nextRound() {
        currentRound++
        if (!moduleData.endlessMode && currentRound > maxRounds) {
            figuresData = []
            figureGameOverOverlay.visible = true
            return
        }
        generateFigures()
    }

    function generateFigures() {
        if (playArea.width === 0 || playArea.height === 0) {
            Qt.callLater(generateFigures)
            return
        }

        let difficulty = moduleData && moduleData.difficulty ? moduleData.difficulty : 1
        difficulty = Math.max(1, Math.min(difficulty, 6))

        let figuresCount = Math.pow(4 + difficulty, 2)

        let r = Math.floor(Math.random() * 200) + 30
        let g = Math.floor(Math.random() * 200) + 30
        let b = Math.floor(Math.random() * 200) + 30
        baseColor = Qt.rgba(r / 255, g / 255, b / 255, 1)

        let shift = 0.04
        targetColor = Qt.rgba(
            Math.min((r + shift * 255) / 255, 1),
            Math.max((g - shift * 255) / 255, 0),
            b / 255,
            1
        )

        let side = Math.ceil(Math.sqrt(figuresCount))
        let spacing = Math.max(1, 8 - difficulty)  // от 7 до 1
        let cellSize = Math.min(
            (playArea.width - spacing * (side + 1)) / side,
            (playArea.height - spacing * (side + 1)) / side
        )

        // Расчёт размеров контейнера
        totalGridWidth = side * cellSize + (side - 1) * spacing
        totalGridHeight = side * cellSize + (side - 1) * spacing

        let newFigures = []
        let index = 0
        for (let row = 0; row < side; row++) {
            for (let col = 0; col < side; col++) {
                if (index >= figuresCount) break
                newFigures.push({
                    x: col * (cellSize + spacing),
                    y: row * (cellSize + spacing),
                    size: cellSize,
                    color: baseColor,
                    isTarget: false
                })
                index++
            }
        }

        let targetIndex = Math.floor(Math.random() * newFigures.length)
        newFigures[targetIndex].color = targetColor
        newFigures[targetIndex].isTarget = true

        figuresData = newFigures

        selectionTimer.restart()
        timerBar.width = timerBarBackground.width
        timerBarAnimation.start()
    }

    function endGame() {
        isPaused = false
        selectionTimer.stop()
        timerBarAnimation.stop()
        figuresData = []
        figureGameOverOverlay.visible = true
    }


    Component.onCompleted: startCountdown()
}
