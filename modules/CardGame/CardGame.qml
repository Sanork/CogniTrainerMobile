import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: window
    anchors.fill: parent
    visible: true

    property var moduleData
    property var cards: []
    property int flippedCount: 0
    property var flippedIndices: []

    property int difficulty: moduleData.difficulty

    property int gridColumns: (difficulty === 1) ? 2
                        : (difficulty === 2) ? 4
                        : (difficulty === 3) ? 4
                        : (difficulty === 4) ? 4
                        : (difficulty === 5) ? 5
                        : 5  // difficulty === 6
    property int gridRows: (difficulty === 1) ? 3
                        : (difficulty === 2) ? 3
                        : (difficulty === 3) ? 4
                        : (difficulty === 4) ? 6
                        : (difficulty === 5) ? 6
                        : 8

    property int pairCount: (gridColumns * gridRows) / 2
    property real cardSpacing: 8
    property real cardWidth: Math.min((grid.width - (gridColumns - 1) * cardSpacing) / gridColumns,
                                      cardHeight / 1.25)
    property real cardHeight: Math.min((grid.height - (gridRows - 1) * cardSpacing) / gridRows, maxCardHeight)


    property real maxCardHeight: 90

    property int moveCount: 0

    Timer {
        id: previewTimer
        interval: 3000
        running: false
        repeat: false
        onTriggered: {
            for (let i = 0; i < cards.length; ++i) {
                cards[i].allowFlipAnimation = true;   // включаем анимацию
                if (!cards[i].matched) {
                    cards[i].flipped = false;
                }
            }
        }
    }

    Timer {
        id: resetTimer
        interval: 1000
        running: false
        repeat: false
        onTriggered: {
            let i1 = flippedIndices[0];
            let i2 = flippedIndices[1];
            cards[i1].flipped = false;
            cards[i2].flipped = false;
            flippedCount = 0;
            flippedIndices = [];
        }
    }

    ToolButton {
        text: "\u2190"
        font.pixelSize: 24
        onClicked: stackView.pop()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10



        GridLayout {
            id: grid
            columns: gridColumns
            rowSpacing: cardSpacing
            columnSpacing: cardSpacing
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: false
            Layout.fillHeight: false
            width: parent.width * 0.80
            height: parent.height * 0.75
        }
    }

    function shuffleCards() {
        for (let i = grid.children.length - 1; i >= 0; --i)
            grid.children[i].destroy();

        cards = [];
        flippedCount = 0;
        flippedIndices = [];

        let allValues = [
            "🐶", "🐱", "🦊", "🐻", "🐼", "🐸", "🐵", "🐯",
            "🐷", "🐰", "🦁", "🐮", "🦝", "🐔", "🦄", "🐙",
            "🐳", "🐞", "🦋", "🦓", "🐢", "🐬", "🦕", "🦉", "🐍"
        ];
        let selected = allValues.slice(0, pairCount);
        let values = selected.concat(selected);
        values.sort(() => Math.random() - 0.5);

        for (let i = 0; i < values.length; ++i) {
            let card = Qt.createComponent("Card.qml").createObject(grid, {
                value: values[i],
                cardWidth: cardWidth,
                cardHeight: cardHeight,
                flipped: true,               // сначала показываем
                allowFlipAnimation: false    // без анимации
            });

            card.onClicked.connect(function () {
                if (card.flipped || card.matched || flippedCount === 2)
                    return;

                card.flipped = true;
                flippedIndices.push(i);
                flippedCount++;

                if (flippedCount === 2) {
                    moveCount++;
                    let i1 = flippedIndices[0];
                    let i2 = flippedIndices[1];

                    if (cards[i1].value === cards[i2].value) {
                        cards[i1].matched = true;
                        cards[i2].matched = true;
                        flippedCount = 0;
                        flippedIndices = [];

                        // 👇 Проверка завершения
                        if (cards.every(c => c.matched)) {
                            gameOverOverlay.visible = true;
                        }
                    } else {
                        resetTimer.start();
                    }
                }
            });

            cards.push(card);
        }

        previewTimer.start(); // закрываем после показа
    }


    // === ОКНО ОКОНЧАНИЯ ИГРЫ ===
    Rectangle {
        id: gameOverOverlay
        visible: false
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)  // тёмная полупрозрачная подложка
        z: 1000

        Rectangle {
            id: dialogRect
            width: 300
            height: 180
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
                    text: "Ходов: " + moveCount
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    color: Material.theme === Material.Light ? "#000000" : "#ecf0f1"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Button {
                    text: "Сыграть снова"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        moveCount = 0
                        gameOverOverlay.visible = false
                        shuffleCards()
                    }
                }
            }
        }
    }



    Component.onCompleted: shuffleCards()
}
