import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    visible: true
    anchors.fill: parent

    property int clickCount: 0
    property int roundCount: 0
    property int totalRounds: 50
    property bool answeredThisRound: false
    property bool processingRound: false
    property var moduleData
    property int difficultyValue: moduleData ? moduleData.difficulty : 5

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
        anchors.fill: parent
        color: "#ffffff"

        Rectangle {
            id: topBar
            height: 56
            width: parent.width
            color: "#f0f0f0"
            anchors.top: parent.top
            border.color: "#cccccc"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 12

                ToolButton {
                    text: "\u2190"
                    font.pixelSize: 30
                    onClicked: stackView.pop()
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "Круг: " + (root.roundCount + 1) + " из " + root.totalRounds
                    font.pixelSize: 18
                    color: "#333"
                    visible: !gameOverOverlay.visible
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

                    if (root.roundCount >= root.totalRounds) {
                        root.endGame();
                    } else {
                        circle.visible = false;

                        Qt.callLater(() => {
                            root.answeredThisRound = false;  // ← сбрасываем для нового раунда
                            circle.moveToRandomPosition();
                            circle.visible = true;
                            circleMouseArea.enabled = true;
                            autoMoveTimer.stop();
                            autoMoveTimer.start();
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

                if (root.roundCount >= root.totalRounds) {
                    root.endGame();
                } else {
                    circle.visible = false;

                    Qt.callLater(() => {
                        root.answeredThisRound = false;  // ← сбрасываем для нового раунда
                        circle.moveToRandomPosition();
                        circle.visible = true;
                        circleMouseArea.enabled = true;
                        autoMoveTimer.stop();
                        autoMoveTimer.start();
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
                        text: "Точность: " + Math.round(root.clickCount / root.roundCount * 100) + " %"
                        font.pixelSize: 20
                        color: "black"
                        horizontalAlignment: Text.AlignHCenter
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





    }

    function endGame() {
        autoMoveTimer.stop();
        gameOverOverlay.visible = true;
        circle.visible = false;
    }

    function finishRound() {
        root.processingRound = false;
    }


}
