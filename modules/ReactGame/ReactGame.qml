import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    anchors.fill: parent

    property var moduleData
    property StackView stackViewRef

    property bool endlessMode: moduleData?.endlessMode ?? false

    property int totalRounds: 3
    property int roundCount: 0
    property int clickCount: 0
    property real totalReactionTime: 0
    property real bestReactionTime: 999999
    property bool waitingForGreen: false
    property bool isGreen: false
    property real roundStartTime: 0
    property bool paused: false

    property int falseStarts: 0 // [добавлено]

    Timer {
        id: waitTimer
        interval: 1000 + Math.random() * 3000
        running: false
        repeat: false
        onTriggered: {
            if (!paused) {
                showGreen()
            }
        }
    }

    // Игровой фон
    Frame {
        anchors.fill: parent
        //color: "white"
        z: 0
    }

    // Верхняя панель
    Rectangle {
        id: topBar
        height: 56
        width: parent.width
        anchors.top: parent.top
        color: Material.theme === Material.Dark ? "#303030" : "#f0f0f0"
        border.color: Material.theme === Material.Dark ? "#555555" : "#cccccc"
        z: 10

        RowLayout {
            anchors.fill: parent
            anchors.rightMargin: 8
            spacing: 4

            ToolButton {
                text: "\u2190"
                font.pixelSize: 28
                onClicked: root.stackViewRef?.pop()
                Material.foreground: Material.theme === Material.Dark ? "white" : "black"
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            Text {
                text: endlessMode
                      ? "Среднее время: " + (clickCount > 0
                          ? Math.round(totalReactionTime / clickCount) + " мс"
                          : "—")
                      : "Раунд: " + (roundCount + 1) + " из " + totalRounds
                font.pixelSize: 16
                color: Material.theme === Material.Dark ? "#ddd" : "#333"
                visible: !gameOverOverlay.visible
                Layout.alignment: Qt.AlignVCenter
            }

            // Пауза
            Item {
                width: 40
                height: 40
                visible: !gameOverOverlay.visible && !countdownOverlay.visible

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: Material.theme === Material.Dark ? "#888888" : "#666666"
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
                    onClicked: root.togglePause()
                    cursorShape: Qt.PointingHandCursor
                }

                Layout.alignment: Qt.AlignVCenter
            }

            // Стоп
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


    // Игровое поле
    Rectangle {
        id: gameArea
        anchors {
            top: topBar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        color: "transparent"
        z: 5

        MouseArea {
               id: gameMouseArea
               anchors.fill: parent
               enabled: !countdownOverlay.visible && !gameOverOverlay.visible && !paused
               onClicked: {
                   if (waitingForGreen && !isGreen) {
                       falseStarts++  // [добавлено]
                       waitNext()
                   } else if (isGreen) {
                       const reactionTime = Date.now() - roundStartTime
                       totalReactionTime += reactionTime
                       if (reactionTime < bestReactionTime)
                           bestReactionTime = reactionTime
                       clickCount++
                       roundCount++
                       waitNext()
                   }
               }
           }

        Rectangle {
            id: circle
            width: 200
            height: 200
            radius: 100
            color: isGreen ? "limegreen" : "crimson"
            anchors.centerIn: parent
            visible: waitingForGreen || isGreen
        }
    }

    // Оверлей окончания
    Rectangle {
        id: gameOverOverlay
        visible: false
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)
        z: 1000

        Rectangle {
            id: dialogRect
            width: 300
            height: 260
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

                Label {
                    text: "Тренировка окончена!"
                    font.pixelSize: 26
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    color: Material.theme === Material.Light ? "#000000" : "#ecf0f1"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Label {
                    text: "Среднее время: " + (root.clickCount > 0
                        ? Math.round(root.totalReactionTime / root.clickCount) + " мс"
                        : "—")
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    color: Material.theme === Material.Light ? "#000000" : "#ecf0f1"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Label {
                    text: "Лучшее время: " + (root.bestReactionTime < 999999
                        ? Math.round(root.bestReactionTime) + " мс"
                        : "—")
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    color: Material.theme === Material.Light ? "#000000" : "#ecf0f1"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Label {
                    text: "Фальстарты: " + root.falseStarts
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Button {
                    text: "Сыграть снова"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: resetGame()
                }
            }
        }
    }

    // Оверлей паузы
    Rectangle {
        id: pauseOverlay
        anchors.fill: parent
        visible: paused
        color: "#00000066"
        z: 90

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
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (root.paused) {
                    root.togglePause()
                }
            }
        }
    }

    Rectangle {
        id: countdownOverlay
        anchors.fill: parent
        visible: false
        color: "#00000066"
        z: 95

        property int countdownValue: 3

        Timer {
            id: countdownStartTimer
            interval: 1000
            running: false
            repeat: true
            onTriggered: {
                countdownOverlay.countdownValue--
                if (countdownOverlay.countdownValue < 0) {
                    countdownStartTimer.stop()
                    countdownOverlay.visible = false
                    startGame()  // запускать только после окончания отсчёта
                }
            }

        }

        Rectangle {
            width: 150
            height: 150
            radius: width / 2
            color: Qt.rgba(0, 0, 0, 0.6)
            anchors.centerIn: parent

            Text {
                anchors.centerIn: parent
                width: parent.width
                text: countdownOverlay.countdownValue > 0
                      ? countdownOverlay.countdownValue
                      : "Старт!"                      // 🔧 Здесь — фикс!
                font.pixelSize: 48
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }




    // --- Логика игры --- //

    function showGreen() {
        isGreen = true
        waitingForGreen = true
        roundStartTime = Date.now()
    }

    function waitNext() {
        isGreen = false
        waitingForGreen = false

        if (!endlessMode && roundCount >= totalRounds) {
            gameOverOverlay.visible = true
        } else {
            waitingForGreen = true
            waitTimer.interval = 1000 + Math.random() * 3000
            if (!paused) {
                waitTimer.restart()
            }
        }
    }

    function resetGame() {
        roundCount = 0
        clickCount = 0
        totalReactionTime = 0
        bestReactionTime = 999999

        isGreen = false
        waitingForGreen = false

        waitTimer.stop()            // остановить таймер ожидания появления зеленого круга
        countdownStartTimer.stop()  // остановить таймер отсчёта (на всякий случай)

        gameOverOverlay.visible = false
        paused = false

        countdownOverlay.countdownValue = 3
        countdownOverlay.visible = true
        countdownStartTimer.start() // запустить отсчёт заново
    }



    function startGame() {
        isGreen = false          // круг пока не зеленый
        waitingForGreen = true   // мы ждём момента зеленого круга, но круг виден

        waitTimer.interval = 1000 + Math.random() * 3000
        if (!paused) {
            waitTimer.start()
        }
    }



    function togglePause() {
        paused = !paused
        if (paused) {
            waitTimer.stop()
        } else {
            if (waitingForGreen) {
                waitTimer.restart()
            }
        }
    }

    function endGame() {
        gameOverOverlay.visible = true
    }

    Component.onCompleted: resetGame()
}

