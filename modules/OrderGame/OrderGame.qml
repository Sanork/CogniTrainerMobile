import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: window
    anchors.fill: parent
    visible: true

    property var moduleData
    property int difficulty: moduleData ? moduleData.difficulty : 1
    property int sequenceLength: Math.min(2 + difficulty, 10)

    property var cards: []
    property var originalValues: []
    property int currentStep: 0
    property bool inputPhase: false
    property bool success: false

    property real cardSpacing: 10
    property int estimatedMinCardWidth: 50
    property int maxCardsInRow: Math.floor((window.width - 40) / (estimatedMinCardWidth + cardSpacing))
    property real cardWidth: Math.min((window.width - (maxCardsInRow + 1) * cardSpacing) / maxCardsInRow, 60)
    property real cardHeight: cardWidth * 1.25



    ToolButton {
        text: "←"
        font.pixelSize: 24
        onClicked: stackView.pop()
    }

    Item {
        id: cardArea
        width: parent.width
        height: parent.height

        Grid {
            id: row
            columns: maxCardsInRow
            columnSpacing: cardSpacing
            rowSpacing: cardSpacing
            anchors.centerIn: parent
        }
    }

    // 1. Показываем открытые карты (3 секунды)
    Timer {
        id: showOpenTimer
        interval: 3000
        repeat: false
        onTriggered: {
            for (let c of cards) {
                c.flip()
                //c.flipped = false;
            }
            showClosedTimer.start();
        }
    }

    // 2. Показываем закрытые карты (2 секунды)
    Timer {
        id: showClosedTimer
        interval: 2000
        repeat: false
        onTriggered: {
            let shuffledValues = shuffleArray(originalValues);

            // Удаляем старые карты
            for (let i = row.children.length - 1; i >= 0; --i) {
                row.children[i].destroy();
            }
            cards = [];

            // Создаем перемешанные карты (закрытые)
            // Создаем перемешанные карты (закрытые)
            for (let i = 0; i < shuffledValues.length; ++i) {
                let card = Qt.createComponent("Card.qml").createObject(row, {
                    value: shuffledValues[i],
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                    allowFlipAnimation: false,
                    flipped: false

                });

                // ✨ Добавь обработку клика ЗДЕСЬ:
                card.onClicked.connect(() => {
                    if (!inputPhase) return;

                    if (card.value === originalValues[currentStep]) {
                            card.matched = true;
                        currentStep++;
                        if (currentStep === originalValues.length) {
                            success = true;
                            inputPhase = false;
                            gameOverOverlay.visible = true;
                        }
                    } else {
                        if (card.hasOwnProperty("backColor"))
                            card.backColor = "indianred";
                        success = false;
                        inputPhase = false;
                        gameOverOverlay.visible = true;
                    }
                });

                cards.push(card);
            }

            showShuffledOpenTimer.start();
        }
    }

    // 3. Показываем перемешанные карты открытыми (3 секунды)
    Timer {
        id: showShuffledOpenTimer
        interval: 3000
        repeat: false
        onTriggered: {
            for (let c of cards) {
                //c.flipped = true;
                c.flip()
            }
            inputPhase = true;
            currentStep = 0;
        }
    }

    function shuffleArray(array) {
        let newArray = array.slice();
        for (let i = newArray.length - 1; i > 0; i--) {
            let j = Math.floor(Math.random() * (i + 1));
            [newArray[i], newArray[j]] = [newArray[j], newArray[i]];
        }
        return newArray;
    }

    function generateCards() {
        for (let i = row.children.length - 1; i >= 0; --i)
            row.children[i].destroy();

        cards = [];
        currentStep = 0;
        inputPhase = false;
        success = false;

        let allValues = [
            "🐶", "🐱", "🦊", "🐻", "🐼", "🐸", "🐵", "🐯",
            "🐷", "🐰", "🦁", "🐮", "🦝", "🐔", "🦄", "🐙"
        ];

        let values = shuffleArray(allValues).slice(0, sequenceLength);
        originalValues = values.slice();

        for (let i = 0; i < values.length; ++i) {
            let card = Qt.createComponent("Card.qml").createObject(row, {
                value: values[i],
                cardWidth: cardWidth,
                cardHeight: cardHeight,
                flipped: true,
                //allowFlipAnimation: true
            });

            // Обработка клика
            card.onClicked.connect(() => {
                if (!inputPhase) return;

                if (card.value === originalValues[currentStep]) {
                    if (card.hasOwnProperty("backColor"))
                        card.backColor = "lightgreen";
                    currentStep++;
                    if (currentStep === originalValues.length) {
                        success = true;
                        inputPhase = false;
                        gameOverOverlay.visible = true;
                    }
                } else {
                    if (card.hasOwnProperty("backColor"))
                        card.backColor = "indianred";
                    success = false;
                    inputPhase = false;
                    gameOverOverlay.visible = true;
                }
            });

            cards.push(card);
        }

        showOpenTimer.start();
    }

    Rectangle {
        id: gameOverOverlay
        visible: false
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)  // тёмная полупрозрачная подложка
        z: 1000

        Rectangle {
            width: parent.width * 0.8
            height: parent.height * 0.35
            radius: 12
            anchors.centerIn: parent

            color: Material.theme === Material.Light ? "#ffffff" : "#2c3e50"
            border.color: Material.theme === Material.Light ? "#cccccc" : "#34495e"
            border.width: 1

            Column {
                anchors.centerIn: parent
                spacing: 16
                width: parent.width * 0.9

                Label {
                    id: resultLabel
                    text: window.success
                        ? "Вы успешно\nповторили последовательность!"
                        : "Ошибка! Последовательность\nнарушена."
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Button {
                    text: "Сыграть снова"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        gameOverOverlay.visible = false;
                        generateCards();
                    }
                }
            }
        }
    }



    Component.onCompleted: generateCards()
}
