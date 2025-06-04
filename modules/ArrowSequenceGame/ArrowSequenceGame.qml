import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Item {
    id: root
    focus: true
    anchors.fill: parent
    Keys.forwardTo: []
    property var moduleData
    property var stackViewRef



    property var directions: ["left", "up", "right", "down"]
    property var currentSequence: []
    property int round: 0
    property int targetRound: 10
    property int inputIndex: 0

    property double trainingTime: 0
    property double startTime: 0
    property double avgRoundTime: 0

    property bool errorFlash: false
    property bool successFlash: false

    property int difficultyMode
    property bool endlessMode: false

    property int difficultyLength: {
        switch (difficultyMode) {
        case 1: return 3
        case 2: return 4
        case 3: return 5
        case 4: return 6
        case 5: return 8
        case 6: return 10
        case 7: return 12
        case 8: return 15

        default: return 3
        }
    }

    Component.onCompleted: {
        countdownTimer.start()

    }


    Timer {
        id: updateTimer
        interval: 100
        running: false
        repeat: true
        onTriggered: {
            if (startTime > 0) {

                trainingTime = (Date.now() - startTime) / 1000.0
            }
        }
    }

    Timer {
        id: errorFlashResetTimer
        interval: 300
        running: false
        repeat: false
        onTriggered: errorFlash = false
    }

    Timer {
        id: countdownTimer

        interval: 1000
        repeat: true
        running: false
        onTriggered: {
            countdownOverlay.countdownValue--;
            if (countdownOverlay.countdownValue < 0) {
                countdownTimer.stop();
                countdownOverlay.visible = false;
                mainScreen.visible = true

                updateTimer.start()
                startTime = Date.now()
                startRound()
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
            width: 200
            height: 200
            radius: width / 2
            color: Qt.rgba(0, 0, 0, 0.6)
            anchors.centerIn: parent

            Text {
                text: countdownOverlay.countdownValue > 0 ? countdownOverlay.countdownValue : "Старт!"
                anchors.centerIn: parent
                font.pixelSize: 50
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }



    function generateSequence() {
        let result = []
        for (let i = 0; i < difficultyLength; i++) {
            result.push(directions[Math.floor(Math.random() * 4)])
        }
        return result
    }

    function startRound() {
        currentSequence = generateSequence()
        inputIndex = 0
    }



    function endGame() {
        updateTimer.stop()
        avgRoundTime = trainingTime / round
        gameOverOverlay.visible = true

    }

    function resetParams() {
        gameOverOverlay.visible = false
        round = 0
        trainingTime = 0
        avgRoundTime = 0
        countdownOverlay.countdownValue = 3
        countdownOverlay.visible = true
        mainScreen.visible = false
        countdownTimer.start()

    }

    function processInput(dir) {
        if (currentSequence[inputIndex] === dir) {
            inputIndex++
            if (inputIndex === currentSequence.length) {
                successFlash = true

                Qt.createQmlObject(`
                                   import QtQuick 2.0
                                   Timer {
                                   interval: 500
                                   repeat: false
                                   onTriggered: {
                                   successFlash = false
                                   round++
                                   if (!endlessMode && targetRound <= round) {
                                   endGame()
                                   } else {
                                   startRound()
                                   }
                                   }
                                   }
                                   `, parent, "SuccessTimer").start()
            }

        } else {
            inputIndex = 0 // сброс при ошибке
            errorFlash = true
            errorFlashResetTimer.restart()
        }
    }

    Keys.onPressed: (event) => {
        const ch = event.text.toLowerCase()

        switch (event.key) {
            case Qt.Key_Left:
                processInput("left")
                break
            case Qt.Key_Up:
                processInput("up")
                break
            case Qt.Key_Right:
                processInput("right")
                break
            case Qt.Key_Down:
                processInput("down")
                break
            default:
                switch (ch) {
                    case "a": case "ф":
                        processInput("left")
                        break
                    case "w": case "ц":
                        processInput("up")
                        break
                    case "d": case "в":
                        processInput("right")
                        break
                    case "s": case "ы":
                        processInput("down")
                        break
                }
                break
        }
    }

    // Верхняя панель
    Rectangle {
        id: topBar
        height: 56
        width: parent.width
        anchors.top: parent.top
        color: Material.theme === Material.Dark ? "#303030" : "#f0f0f0"
        border.color: Material.theme === Material.Dark ? "#555555" : "#cccccc"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 12
            //verticalAlignment: Qt.AlignVCenter

            ToolButton {
                text: "\u2190"
                font.pixelSize: 28
                onClicked: stackViewRef?.pop()
                Material.foreground: Material.theme === Material.Dark ? "white" : "black"
                Layout.alignment: Qt.AlignVCenter
            }

            // Заполнитель между кнопкой назад и текстом
            Item {
                Layout.fillWidth: true
            }

            Text {
                text: "Время тренировки: " + trainingTime.toFixed(0) + " сек"
                font.pixelSize: 16
                color: Material.theme === Material.Dark ? "#ddd" : "#333"
                Layout.alignment: Qt.AlignVCenter
                visible: !gameOverOverlay.visible
            }

            // Иконка для бесконечного режима (видимая если endlessMode и не gameOver)
            Item {
                width: 40
                height: 40
                visible: endlessMode && !gameOverOverlay.visible

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


    //основной экран
    Column {
        id: mainScreen
        visible: false
        spacing: 30

        anchors.top: parent.top
        anchors.topMargin: 80  // отступ сверху, можно менять
        anchors.horizontalCenter: parent.horizontalCenter

        Label {
            text: "Раунд: " + (round + 1) + (endlessMode ? "" : " / " + targetRound)
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 26
            font.weight: Font.DemiBold

        }

        Flow {
            spacing: 12
            width: 6 * (45 + 12) - 12  // минус последний spacing

            Repeater {
                model: currentSequence.length
                Rectangle {
                    width: 45
                    height: 45
                    radius: 6
                    border.width: 3
                    border.color: "#ccc"

                    color: {
                        if (errorFlash) return "red"
                        else if (successFlash) return "lightgreen"
                        else if (index < inputIndex) return "lightgreen"
                        else return "#f0f0f0"
                    }
                    scale: (errorFlash || successFlash) ? 1.3 : 1.0
                    transformOrigin: Item.Center

                    Behavior on color {
                        ColorAnimation {
                            duration: errorFlash ? 200 : 0
                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                    }

                    Image {
                        anchors.centerIn: parent
                        source: moduleData.iconArrowUrl
                        width: 25
                        fillMode: Image.PreserveAspectFit

                        rotation: {
                            switch (currentSequence[index]) {
                                case "left": return 0
                                case "up": return 90
                                case "right": return 180
                                case "down": return -90
                            }
                        }
                    }
                }
            }
        }

        Item {
            width: 1
            height: 40
        }

        Item {
            width: 240
            height: 240
            anchors.horizontalCenter: parent.horizontalCenter

            // Верхняя кнопка
            Rectangle {
                id: upButton
                width: 70; height: 70
                radius: 8
                color: "#f0f0f0"
                border.color: "#ccc"
                border.width: 3
                anchors.horizontalCenter: parent.horizontalCenter
                y: 0

                Image {
                    anchors.centerIn: parent
                    source: moduleData.iconArrowUrl
                    width: 35
                    fillMode: Image.PreserveAspectFit
                    rotation: 90
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: processInput("up")
                }
            }

            // Левая кнопка
            Rectangle {
                id: leftButton
                width: 70; height: 70
                radius: 8
                color: "#f0f0f0"
                border.color: "#ccc"
                border.width: 3
                x: 0
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    anchors.centerIn: parent
                    source: moduleData.iconArrowUrl
                    width: 35
                    fillMode: Image.PreserveAspectFit
                    rotation: 0
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: processInput("left")
                }
            }

            // Правая кнопка
            Rectangle {
                id: rightButton
                width: 70; height: 70
                radius: 8
                color: "#f0f0f0"
                border.color: "#ccc"
                border.width: 3
                x: parent.width - width
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    anchors.centerIn: parent
                    source: moduleData.iconArrowUrl
                    width: 35
                    fillMode: Image.PreserveAspectFit
                    rotation: 180
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: processInput("right")
                }
            }

            // Нижняя кнопка
            Rectangle {
                id: downButton
                width: 70; height: 70
                radius: 8
                color: "#f0f0f0"
                border.color: "#ccc"
                border.width: 3
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height - height

                Image {
                    anchors.centerIn: parent
                    source: moduleData.iconArrowUrl
                    width: 35
                    fillMode: Image.PreserveAspectFit
                    rotation: -90
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: processInput("down")
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
            id: dialogRect
            width: parent.width * 0.6
            height: parent.height * 0.45
            radius: 12
            anchors.centerIn: parent

            color: Material.theme === Material.Light ? "#C9E9FF" : "#2c3e50"
            border.color: Material.theme === Material.Light ? "#cccccc" : "#34495e"
            border.width: 3

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
                        text: endlessMode ? "Раундов пройдено: " + round : ""
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
                        text: round !== 0 ? "Среднее: " + avgRoundTime.toFixed(2) + " сек" : ""
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

}
