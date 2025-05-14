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

    // Привязка сложности (1–3)
    property int difficulty: moduleData.difficulty
    property int pairCount: moduleData.difficulty === 1 ? 8 : (moduleData.difficulty === 2 ? 12 : 20)
    property int gridColumns: moduleData.difficulty === 3 ? 5 : 4

    property real cardSpacing: 8
    property real cardWidth: ((grid.width - (gridColumns - 1) * cardSpacing) / gridColumns)
    property real cardHeight: cardWidth * 1.25  // Пропорции 4:5

    Timer {
        id: previewTimer
        interval: 3000 // 3 секунды для запоминания
        repeat: false
        onTriggered: {
            for (let i = 0; i < cards.length; ++i) {
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

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Button {
            text: "Новая игра"
            Layout.alignment: Qt.AlignHCenter
            onClicked: shuffleCards()
        }

        GridLayout {
            id: grid
            columns: gridColumns
            rowSpacing: cardSpacing
            columnSpacing: cardSpacing
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: false
                        Layout.fillHeight: false
                        width: parent.width * 0.80  // Оставляем немного пустого места по бокам
                        height: parent.height * 0.75 // Оставляем пространство сверху и снизу
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
        let values = selected.concat(selected); // пары
        values.sort(() => Math.random() - 0.5);

        for (let i = 0; i < values.length; ++i) {
            let card = Qt.createComponent("Card.qml").createObject(grid, {
                value: values[i],
                cardWidth: cardWidth,
                cardHeight: cardHeight,
                flipped: true // предварительно показываем
            });

            card.onClicked.connect(function () {
                if (card.flipped || card.matched || flippedCount === 2)
                    return;

                card.flipped = true;
                flippedIndices.push(i);
                flippedCount++;

                if (flippedCount === 2) {
                    let i1 = flippedIndices[0];
                    let i2 = flippedIndices[1];

                    if (cards[i1].value === cards[i2].value) {
                        cards[i1].matched = true;
                        cards[i2].matched = true;
                        flippedCount = 0;
                        flippedIndices = [];
                    } else {
                        resetTimer.start();
                    }
                }
            });

            cards.push(card);
        }

        // Закрываем все неугаданные карточки через 3 секунды
        Qt.createQmlObject(`
            import QtQuick 2.15
            Timer {
                interval: 3000
                running: true
                repeat: false
                onTriggered: {
                    for (let i = 0; i < cards.length; ++i) {
                        if (!cards[i].matched) {
                            cards[i].flipped = false;
                        }
                    }
                }
            }
        `, window);
    }


    Component.onCompleted: shuffleCards()
}
