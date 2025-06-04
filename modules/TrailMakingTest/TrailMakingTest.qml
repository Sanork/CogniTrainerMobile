import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15

Item {
    id: root
    anchors.fill: parent

    property int totalDots: 25
    property int currentNumber: 1
    property int errors: 0
    property bool testStarted: false
    property bool testFinished: false
    property double startTime: 0
    property double endTime: 0
    property int testPart: 1 // 1 = A, 2 = B

    property double partATime: 0
    property double partBTime: 0
    property bool showingIntro: true

    property var dotPositions: []
    property var dotData: []

    signal testCompleted(double duration, int errors)

    property var stackViewRef
    property var moduleData

    Timer {
        id: countdownTimer
        interval: 100
        repeat: true
        running: testStarted && !testFinished
        onTriggered: {
            if (testStarted && !testFinished)
                timeDisplay.text = "Время: " + ((Date.now() - startTime) / 1000).toFixed(1) + " сек"
        }
    }

    ToolButton {
        text: "\u2190"
        font.pixelSize: 24
        onClicked: root.stackViewRef.pop()
        Layout.alignment: Qt.AlignVCenter
    }

    Text {
        id: timeDisplay
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: Math.max(16, root.width / 40)
        text: ""
        padding: 10
    }

    Canvas {
        id: lineCanvas
        anchors.fill: parent
        z: 0
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.strokeStyle = "red"
            ctx.lineWidth = 3
            ctx.beginPath()
            for (let i = 0; i < dotPositions.length - 1; i++) {
                const p1 = dotPositions[i]
                const p2 = dotPositions[i + 1]
                ctx.moveTo(p1.x, p1.y)
                ctx.lineTo(p2.x, p2.y)
            }
            ctx.stroke()
        }
    }

    Item {
        id: dotContainer
        anchors {
            top: timeDisplay.bottom
            topMargin: 20
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: 40
        }
        z: 1

        property int dotRadius: Math.max(18, Math.min(width, height) / 18)

        onWidthChanged: {
            if (width > 0 && height > 0 && dotData.length === 0)
                generateRandomDots()
        }
        onHeightChanged: {
            if (width > 0 && height > 0 && dotData.length === 0)
                generateRandomDots()
        }

        Repeater {
            id: dotRepeater
            model: dotData

            Rectangle {
                width: dotContainer.dotRadius * 2
                height: dotContainer.dotRadius * 2
                radius: dotContainer.dotRadius
                x: modelData.x
                y: modelData.y
                color: passed ? "lightgreen" : (testPart === 1 ? "lightblue" : "#FFD580")
                border.color: "black"
                border.width: 2

                property string label: modelData.label
                property bool passed: false

                Text {
                    anchors.centerIn: parent
                    text: modelData.label
                    font.pixelSize: dotContainer.dotRadius
                    font.family: {
                        if (testPart === 2) {
                            return isNaN(parseInt(modelData.label)) ? "Georgia" : "Arial Rounded MT Bold"
                        } else {
                            return "Arial Rounded MT Bold"
                        }
                    }
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: !testFinished && !showingIntro
                    onClicked: {
                        if (!testStarted) {
                            testStarted = true
                            startTime = Date.now()
                            countdownTimer.start()
                            timeDisplay.text = "Время: 0.0 сек"
                        }

                        if (parent.label === expectedLabel()) {
                            var point = parent.mapToItem(root, parent.width / 2, parent.height / 2)
                            dotPositions.push({ x: point.x, y: point.y })
                            currentNumber++
                            parent.passed = true
                            lineCanvas.requestPaint()

                            if (currentNumber > totalDots) {
                                endTime = Date.now()
                                testFinished = true
                                countdownTimer.stop()

                                if (testPart === 1) {
                                    partATime = endTime - startTime
                                    Qt.callLater(startPartB)
                                } else {
                                    partBTime = endTime - startTime
                                    resultOverlay.visible = true
                                    testCompleted((endTime - startTime) / 1000, errors)
                                }
                            }
                        } else {
                            errors++
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: resultOverlay
        anchors.fill: parent
        visible: testFinished && !showingIntro
        color: "#cc000000"
        z: 10

        Rectangle {
            id: resultBox
            width: Math.min(parent.width * 0.9, 500)
            color: "white"
            radius: 10
            opacity: 0.95
            anchors.centerIn: parent
            height: columnResult.implicitHeight + 40

            Column {
                id: columnResult
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                Text {
                    text: "Тест завершён!"
                    font.pixelSize: 22
                    horizontalAlignment: Text.AlignHCenter
                    color: "black"
                    width: parent.width
                }

                Text {
                    text: "Часть A — Время: " + (partATime / 1000).toFixed(1) + " сек"
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    color: "#333"
                    width: parent.width
                }

                Text {
                    text: "Часть B — Время: " + (partBTime / 1000).toFixed(1) + " сек"
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    color: "#333"
                    width: parent.width
                }

                Text {
                    text: interpretTrailMaking(moduleData.age, partATime / 1000, partBTime / 1000)
                    wrapMode: Text.WordWrap
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    color: "#333"
                    width: parent.width
                }

                Row {
                    spacing: 20
                    anchors.horizontalCenter: parent.horizontalCenter

                    Button {
                        text: "Выход"
                        onClicked: {
                            root.visible = false
                            if (root.stackViewRef) {
                                root.stackViewRef.pop()
                                root.stackViewRef.pop()
                            }
                        }
                    }
                }
            }
        }
    }


    Rectangle {
        id: introOverlay
        visible: showingIntro
        anchors.fill: parent
        color: "#cc000000"
        z: 10

        Rectangle {
            id: introBox
            width: Math.min(parent.width * 0.9, 500)
            color: "white"
            radius: 10
            opacity: 0.95
            anchors.centerIn: parent
            height: column.implicitHeight + 40

            Column {
                id: column
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                Text {
                    text: testPart === 1
                        ? "Часть A:\nСоедините числа от 1 до 25 по порядку."
                        : "Часть B:\nЧередуйте числа и буквы: 1-А-2-Б-3-В и т.д."
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 18
                    color: "black"
                    width: parent.width
                }

                Button {
                    text: "Продолжить"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        showingIntro = false
                        timeDisplay.text = testPart === 1
                            ? "Нажмите 1 для начала"
                            : "Часть B: нажмите 1 для начала"
                    }
                }
            }
        }
    }


    function resetTest() {
        currentNumber = 1
        errors = 0
        testStarted = false
        testFinished = false
        dotPositions = []
        dotData = []
        lineCanvas.requestPaint()
        resultOverlay.visible = false
        timeDisplay.text = ""
        generateRandomDots()
    }

    function generateRandomDots() {
        var newDots = []
        const radius = dotContainer.dotRadius
        var used = []

        function overlaps(x, y) {
            for (var i = 0; i < used.length; i++) {
                var dx = used[i].x - x
                var dy = used[i].y - y
                if (Math.sqrt(dx * dx + dy * dy) < 2 * radius + 10)
                    return true
            }
            return false
        }

        var labels = []

        if (testPart === 1) {
            for (var i = 1; i <= totalDots; i++) {
                labels.push(i.toString())
            }
        } else {
            var rusLetters = ['А', 'Б', 'В', 'Г', 'Д', 'Е', 'Ё', 'Ж', 'З', 'И', 'Й', 'К']
            for (var i = 1; i <= 13; i++) {
                labels.push(i.toString())
                if (i <= rusLetters.length) {
                    labels.push(rusLetters[i - 1])
                }
            }
        }

        for (var i = 0; i < labels.length; i++) {
            var x, y, tries = 0
            var xMarginRight = radius - 20
            var yMarginTop = 0
            var yMarginBottom = 10

            do {
                x = Math.random() * (dotContainer.width - xMarginRight - 2 * radius)
                y = yMarginTop + Math.random() * (dotContainer.height - yMarginTop - yMarginBottom - 2 * radius)
                tries++
            } while (overlaps(x, y) && tries < 100)

            newDots.push({ label: labels[i], x: x, y: y })
            used.push({ x: x, y: y })
        }

        dotData = newDots
    }

    function expectedLabel() {
        if (testPart === 1) {
            return currentNumber.toString()
        } else {
            var rusLetters = ['А', 'Б', 'В', 'Г', 'Д', 'Е', 'Ё', 'Ж', 'З', 'И', 'Й', 'К']
            var index = currentNumber - 1
            if (index % 2 === 0)
                return ((index / 2) + 1).toString()
            else
                return rusLetters[Math.floor(index / 2)]
        }
    }

    function startPartB() {
        testPart = 2
        currentNumber = 1
        errors = 0
        testStarted = false
        testFinished = false
        dotPositions = []
        dotData = []
        lineCanvas.requestPaint()
        showingIntro = true
        timeDisplay.text = ""
        generateRandomDots()
    }

    // Возвращает нормальные диапазоны времени в секундах
    function getTrailMakingNorms(age) {
        if (age <= 6) return { A: [50, 90], B: [100, 180] };
        else if (age <= 8) return { A: [40, 75], B: [90, 160] };
        else if (age <= 10) return { A: [35, 65], B: [80, 140] };
        else if (age <= 12) return { A: [30, 55], B: [70, 120] };
        else if (age <= 14) return { A: [25, 50], B: [60, 110] };
        else if (age <= 16) return { A: [20, 45], B: [50, 100] };
        else if (age <= 19) return { A: [18, 40], B: [45, 90] };
        else if (age <= 29) return { A: [16, 38], B: [43, 90] };
        else if (age <= 39) return { A: [18, 40], B: [45, 95] };
        else if (age <= 49) return { A: [20, 42], B: [50, 100] };
        else if (age <= 59) return { A: [22, 45], B: [55, 110] };
        else if (age <= 69) return { A: [25, 50], B: [60, 120] };
        else return { A: [28, 55], B: [70, 135] };
    }

    // Интерпретация одного результата
    function interpretTrailScore(score, range) {
        if (score < range[0]) {
            return { result: "Быстрее нормы", level: 1 };
        } else if (score > range[1]) {
            return { result: "Медленнее нормы", level: -1 };
        } else {
            return { result: "В пределах нормы", level: 0 };
        }
    }

    // Итоговая интерпретация по обеим частям
    function interpretTrailMaking(age, timeA, timeB) {
        const norms = getTrailMakingNorms(age);
        const interpA = interpretTrailScore(timeA, norms.A);
        const interpB = interpretTrailScore(timeB, norms.B);

        const a = interpA.level;
        const b = interpB.level;
        let summary = "";

        if (a === -1 && b === -1) {
            summary = "Оба задания выполнены медленнее нормы. Возможны трудности с вниманием, когнитивной гибкостью или моторной скоростью.";
        } else if (a === 1 && b === 1) {
            summary = "Оба задания выполнены быстрее нормы. Отличная скорость обработки и когнитивная гибкость.";
        } else if (a === 0 && b === 0) {
            summary = "Результаты находятся в пределах возрастной нормы.";
        } else if (a === -1 && b >= 0) {
            summary = "Часть A выполнена медленно, часть B — в норме или быстро. Возможны трудности с моторной скоростью.";
        } else if (a >= 0 && b === -1) {
            summary = "Часть B выполнена медленно, часть A — в норме или быстро. Возможны трудности с переключением внимания или когнитивной гибкостью.";
        } else if (a === 1 && b === 0) {
            summary = "Часть A выполнена быстрее нормы, часть B — в пределах нормы. Хорошая моторная скорость.";
        } else if (a === 0 && b === 1) {
            summary = "Часть B выполнена быстрее нормы, часть A — в пределах нормы. Хорошая когнитивная гибкость.";
        } else {
            summary = "Нестандартная комбинация результатов. Возможно влияние внешних факторов.";
        }

        return summary;
    }

    Component.onCompleted: {
        resetTest()
        showingIntro = true
    }
}
