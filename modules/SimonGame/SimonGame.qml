import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: simonGame
    anchors.fill: parent

    property var colors: ["#f41310", "#006400", "#000080", "#FEFE22"]
    property var sequence: []
    property int step: 0
    property bool acceptingInput: false

    property int flashIndex: 0
    property bool flashing: false

    property color successFeedbackColor: "#66FF00"
    property color failFeedbackColor: "#800000"

    property int flashAllCount: 0
    property color flashAllColor: "transparent"
    property bool flashAllOn: false

    property int score: 0

    signal gameOver()

    ToolButton {
        text: "\u2190"
        font.pixelSize: 24
        onClicked: stackView.pop()
    }

    Column {
        spacing: 20
        anchors.centerIn: parent

        GridLayout {
            id: buttonGrid
            columns: 2
            anchors.horizontalCenter: parent.horizontalCenter

            property var buttons: []

            Component.onCompleted: {
                for (let i = 0; i < simonGame.colors.length; ++i) {
                    let button = Qt.createComponent("SimonButton.qml").createObject(buttonGrid, {
                        index: i,
                        baseColor: simonGame.colors[i]
                    });

                    button.clicked.connect(function (i) {
                        if (!simonGame.acceptingInput) return;

                        simonGame.flashButton(i);

                        if (i === simonGame.sequence[simonGame.step]) {
                            simonGame.step++;
                            if (simonGame.step === simonGame.sequence.length) {
                                simonGame.acceptingInput = false;
                                simonGame.flashAllButtons(simonGame.successFeedbackColor, 3);

                                Qt.createQmlObject(`
                                    import QtQuick 2.15
                                    Timer {
                                        interval: 1800
                                        repeat: false
                                        running: true
                                        onTriggered: simonGame.nextRound();
                                    }
                                `, buttonGrid);
                            }
                        } else {
                            simonGame.flashAllButtons(simonGame.failFeedbackColor, 3);
                            simonGame.gameOver();
                        }
                    });

                    buttonGrid.buttons.push(button);
                }

                simonGame.startGame();
            }
        }
    }


    Timer {
        id: flashTimer
        interval: 500
        repeat: true
        running: false
        onTriggered: {
            let btn = buttonGrid.buttons[simonGame.sequence[simonGame.flashIndex]];
            if (simonGame.flashing) {
                btn.isFlashing = false;
                simonGame.flashing = false;
                simonGame.flashIndex += 1;

                if (simonGame.flashIndex >= simonGame.sequence.length) {
                    flashTimer.stop();
                    simonGame.acceptingInput = true;
                    simonGame.step = 0;
                }
            } else {
                btn.isFlashing = true;
                simonGame.flashing = true;
            }
        }
    }

    Timer {
        id: flashAllTimer
        interval: 200
        repeat: true
        running: false
        onTriggered: {
            flashAllOn = !flashAllOn;
            for (let i = 0; i < buttonGrid.buttons.length; ++i) {
                buttonGrid.buttons[i].currentColor = flashAllOn
                    ? flashAllColor
                    : buttonGrid.buttons[i].baseColor;
            }

            if (!flashAllOn) {
                flashAllCount--;
                if (flashAllCount <= 0) {
                    flashAllTimer.stop();
                    for (let i = 0; i < buttonGrid.buttons.length; ++i) {
                        buttonGrid.buttons[i].currentColor = buttonGrid.buttons[i].baseColor;
                    }
                }
            }
        }
    }

    function flashAllButtons(color, times) {
        flashAllColor = color;
        flashAllCount = times;
        flashAllOn = false;
        flashAllTimer.start();
    }

    function startGame() {
        simonGame.sequence = [];
        simonGame.score = 0;
        simonGame.nextRound();
    }

    function nextRound() {
        simonGame.sequence.push(Math.floor(Math.random() * 4));
        simonGame.score = simonGame.sequence.length - 1;
        simonGame.playSequence();
    }

    function playSequence() {
        simonGame.acceptingInput = false;
        simonGame.flashIndex = 0;
        simonGame.flashing = false;
        flashTimer.start();
    }

    function flashButton(i) {
        buttonGrid.buttons[i].isFlashing = true;
        Qt.createQmlObject(`
            import QtQuick 2.15
            Timer {
                interval: 400
                repeat: false
                running: true
                onTriggered: buttonGrid.buttons[${i}].isFlashing = false;
            }
        `, buttonGrid);
    }


    Rectangle {
        id: gameOverOverlay
        visible: false
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)  // тёмная полупрозрачная подложка
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
                    text: "Длина цепочки: " + simonGame.score
                    font.pixelSize: 20
                    color: Material.theme === Material.Light ? "black" : "#ecf0f1"
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Button {
                    text: "Сыграть снова"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        gameOverOverlay.visible = false;
                        simonGame.startGame();
                    }
                }
            }
        }
    }

    onGameOver: {
        simonGame.acceptingInput = false;
        console.log("Игра окончена. Правильная последовательность:", simonGame.sequence);
        gameOverOverlay.visible = true;
    }
}
