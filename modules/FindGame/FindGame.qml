import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    anchors.fill: parent

    property int score: 0
    property int currentRound: -1
    property int maxRounds: 5

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

    property bool isGameOver: false

    property bool isPaused: false

    Frame {
        anchors.fill: parent
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
            anchors.leftMargin: 4
            spacing: 4

            ToolButton {
                text: "\u2190"
                font.pixelSize: 28
                onClicked: stackView.pop()
                Material.foreground: Material.theme === Material.Dark ? "white" : "black"
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            Text {
                text: root.moduleData && root.moduleData.endlessMode
                    ? "Раунд: " + (currentRound + 1)
                    : "Раунд: " + Math.min(currentRound + 1, maxRounds) + " / " + maxRounds


                font.pixelSize: 16
                color: Material.theme === Material.Dark ? "#ddd" : "#333"
                visible: !figureGameOverOverlay.visible && !countdownOverlay.visible
                Layout.alignment: Qt.AlignVCenter
            }

            // Кнопка "Стоп"
            Item {
                width: 40
                height: 40
                visible: root.moduleData && root.moduleData.endlessMode && !figureGameOverOverlay.visible && !countdownOverlay.visible

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
            visible: true

            height: parent.height
            width: parent.width
            color: Material.theme === Material.Dark ? "#00FFFF" : "#4682B4"
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
            width: parent.width * 0.6
            height: parent.height * 0.35
            radius: 12
            anchors.centerIn: parent

            color: Material.theme === Material.Light ? "#ffffff" : "#2c3e50"
            border.color: Material.theme === Material.Light ? "#cccccc" : "#34495e"
            border.width: 1

            Column {
                anchors.centerIn: parent
                spacing: 16
                width: parent.width

                Text {
                    text: "Тренировка\nокончена!"
                    font.pixelSize: 26
                    color: Material.theme === Material.Light ? "black" : "#ecf0f1"
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: root.moduleData && root.moduleData.endlessMode
                        ? "Результат: " + score + " из " + currentRound
                        : "Результат: " + score + " из " + maxRounds
                    font.pixelSize: 20
                    color: Material.theme === Material.Light ? "black" : "#ecf0f1"
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
        isGameOver = false
        isCountdownActive = true
        awaitingNextRound = false
        selectedIndex = -1      // Сброс выбора
        lastChoiceCorrect = false  // Сброс результата выбора
        countdownOverlay.countdownValue = 3
        countdownOverlay.visible = true
        countdownTimer.start()
    }

    function togglePause() {
        root.isPaused = !root.isPaused

        if (root.isPaused) {
            // при паузе
            wasNextRoundDelayScheduled = nextRoundDelay.running
            selectionTimer.stop()
            timerBarAnimation.pause()
            nextRoundDelay.stop()
        } else {
            // при выходе из паузы
            if (wasNextRoundDelayScheduled) {
                wasNextRoundDelayScheduled = false
                nextRoundDelay.start()
            } else if (!root.awaitingNextRound && !root.isCountdownActive) {
                selectionTimer.start()
                timerBarAnimation.resume()
            }
        }
    }


    function nextRound() {
        if (isGameOver) return

        if (!moduleData.endlessMode && (currentRound + 1) >= maxRounds) {
            figuresData = []
            figureGameOverOverlay.visible = true
            return
        }

        currentRound++
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

        let duration;
        if (difficulty === 1) {
            duration = -1; // бесконечно
        } else {
            // от 5000 мс до 2000 мс при увеличении сложности
            duration = 5000 - (difficulty - 2) * 750
            duration = Math.max(duration, 1500)
        }

        if (duration === -1) {
            selectionTimer.stop()
            timerBarAnimation.stop()
            timerBar.width = timerBarBackground.width
            timerBar.visible = false
        } else {
            selectionTimer.interval = duration
            selectionTimer.restart()
            timerBar.width = timerBarBackground.width
            timerBarAnimation.duration = duration
            timerBarAnimation.start()
            timerBar.visible = true
        }


        selectionTimer.restart()
        timerBar.width = timerBarBackground.width
        timerBarAnimation.start()

    }

    function endGame() {
        if (awaitingNextRound && selectedIndex !== -1)
            currentRound++  // учесть текущий выбор, если раунд не завершён

        isPaused = false
        isGameOver = true
        selectionTimer.stop()
        timerBarAnimation.stop()
        nextRoundDelay.stop()
        figuresData = []
        figureGameOverOverlay.visible = true
    }

    Component.onCompleted: startCountdown()
}
