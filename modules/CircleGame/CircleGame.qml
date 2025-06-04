import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    visible: true
    anchors.fill: parent

    property bool hidesTabs: true

    property StackView stackViewRef
    property var moduleData
    property int difficultyValue: moduleData ? moduleData.difficulty : 5
    property bool endlessMode: moduleData && moduleData.endlessMode === true

    property int clickCount: 0
    property int roundCount: 0
    property int totalRounds: 10
    property bool answeredThisRound: false
    property bool processingRound: false

    property bool paused: false

    function createMarker(color) {
        var marker = Qt.createQmlObject(`
            import QtQuick 2.15
            Rectangle {
                id: markerRect
                width: ${circle.width}
                height: ${circle.height}
                radius: width / 2
                color: "${color}"
                opacity: 0.5
                x: ${circle.x}
                y: ${circle.y}
                z: -1

                SequentialAnimation {
                    running: true
                    PropertyAnimation {
                        target: markerRect
                        property: "opacity"
                        to: 0
                        duration: 800
                    }
                    ScriptAction {
                        script: markerRect.destroy()
                    }
                }
            }
        `, hitMarkerLayer);
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

                Text {
                    text: endlessMode
                          ? "Попаданий: " + root.clickCount + " из " + root.roundCount + " (" +
                            (root.roundCount > 0
                                ? Math.round(root.clickCount / root.roundCount * 100) + " %"
                                : "0%") + ")"
                          : "Круг: " + (root.roundCount + 1) + " из " + root.totalRounds
                    font.pixelSize: 16
                    color: Material.theme === Material.Dark ? "#ddd" : "#333"
                    visible: !gameOverOverlay.visible
                    Layout.alignment: Qt.AlignVCenter
                }

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
                        color: Material.theme === Material.Dark ? "white" : "white"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.horizontalCenter
                        anchors.rightMargin: 2
                    }

                    // Правая палочка
                    Rectangle {
                        width: 5
                        height: 16
                        radius: 2
                        color: Material.theme === Material.Dark ? "white" : "white"
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


        Item {
            id: hitMarkerLayer
            anchors.fill: parent
        }

        Rectangle {
            id: circle
            visible: false
            radius: width / 2
            property int maxSize: 80
            property int minSize: 20

            width: {
                const clamped = Math.max(1, Math.min(10, root.difficultyValue));
                return maxSize - (clamped - 1) * ((maxSize - minSize) / 9);
            }
            height: width
            color: "dodgerblue"

            function moveToRandomPosition() {
                const h = root.height - topBar.height;
                x = Math.random() * (root.width - width);
                y = topBar.height + Math.random() * (h - height);
            }

            MouseArea {
                id: circleMouseArea
                anchors.fill: parent
                enabled: false
                onClicked: {
                    if (!circle.visible || root.answeredThisRound)
                        return;

                    root.answeredThisRound = true;
                    root.clickCount++;
                    root.roundCount++;
                    root.createMarker("#00ff00");

                    if (!endlessMode && root.roundCount >= root.totalRounds) {
                        root.endGame();
                    } else {
                        circle.visible = false;
                        Qt.callLater(() => {
                            root.answeredThisRound = false;
                            circle.moveToRandomPosition();
                            circle.visible = true;
                            circleMouseArea.enabled = true;
                            autoMoveTimer.restart();
                        });
                    }
                }
            }
        }

        Timer {
            id: autoMoveTimer
            interval: 2000 - (root.difficultyValue * 150)
            repeat: true
            running: false

            onTriggered: {
                if (root.answeredThisRound)
                    return;

                root.answeredThisRound = true;
                root.roundCount++;
                root.createMarker("#ff0000");

                if (!endlessMode && root.roundCount >= root.totalRounds) {
                    root.endGame();
                } else {
                    circle.visible = false;
                    Qt.callLater(() => {
                        root.answeredThisRound = false;
                        circle.moveToRandomPosition();
                        circle.visible = true;
                        circleMouseArea.enabled = true;
                        autoMoveTimer.restart();
                    });
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
                width: parent.width * 0.5
                height: parent.height * 0.35
                radius: 12
                anchors.centerIn: parent

                color: Material.theme === Material.Light ? "#C9E9FF" : "#2c3e50"
                border.color: Material.theme === Material.Light ? "#cccccc" : "#34495e"
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 16
                    // Центрируем содержимое по вертикали и горизонтали
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    Label {
                        text: "Тренировка\nокончена!"
                        font.pixelSize: 26
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        color: Material.theme === Material.Light ? "#000000" : "#ecf0f1"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Label {
                        text: "Точность: " +
                              (root.roundCount > 0
                                ? Math.round(root.clickCount / root.roundCount * 100) + " %"
                                : "0 %")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        color: Material.theme === Material.Light ? "#000000" : "#ecf0f1"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Button {
                        text: "Сыграть снова"
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            root.clickCount = 0;
                            root.roundCount = 0;
                            root.answeredThisRound = false;
                            root.processingRound = false;
                            gameOverOverlay.visible = false;
                            countdownOverlay.countdownValue = 3;
                            countdownOverlay.visible = true;
                            countdownTimer.start();
                            autoMoveTimer.stop();
                            circle.visible = false;
                        }
                    }
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
                width: 150
                height: 150
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

            Timer {
                id: countdownTimer
                interval: 1000
                repeat: true
                running: true
                onTriggered: {
                    countdownOverlay.countdownValue--;
                    if (countdownOverlay.countdownValue < 0) {
                        countdownTimer.stop();
                        countdownOverlay.visible = false;
                        autoMoveTimer.start();

                        circle.moveToRandomPosition();
                        circle.visible = true;
                        circleMouseArea.enabled = true;
                    }
                }
            }
        }

        Item {
            id: pauseOverlay
            anchors.fill: parent
            visible: false
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
                onClicked: {
                    // Синхронизируем состояние паузы при клике на оверлей
                    if (root.paused) {
                        root.togglePause();
                    }
                }
            }
        }

    function endGame() {
        autoMoveTimer.stop();
        gameOverOverlay.visible = true;
        circle.visible = false;
    }

    function finishRound() {
        root.processingRound = false;
    }

    function togglePause() {
        paused = !paused;
        if (paused) {
            autoMoveTimer.stop();
            circle.visible = false;
            circleMouseArea.enabled = false;
            pauseOverlay.visible = true;
        } else {
            pauseOverlay.visible = false;
            circle.moveToRandomPosition();
            circle.visible = true;
            circleMouseArea.enabled = true;
            autoMoveTimer.start();
        }
    }
}
