import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    anchors.fill: parent

    property bool hidesTabs: true

    property var moduleData
    property var stackViewRef

    property bool showingDigit: false
    property int sequenceLength: 2      // начинаем с 2 чисел
    property var currentSequence: []
    property int showIndex: 0
    property bool isShowingSequence: false
    property var showTimer: null
    property bool showResult: false
    property bool lastResultSuccess: false

    property int errorsCount: 0          // Счётчик ошибок
    property int maxErrors: 2            // Допустимо 2 ошибки (3-я завершает игру)

    property bool reverseMode: false    // Флаг обратного режима

    property int maxStraightLength: 1   // Максимальная длина прямой последовательности
    property int maxReverseLength: 1    // Максимальная длина обратной последовательности
    property var maxStraightSequence: []
    property var maxReverseSequence: []

    // Свойства для показа инструкции / предупреждения
    property bool showingIntro: false
    property string introText: ""

    // Добавляем флаги, чтобы показывать предупреждение для каждого режима только один раз
    property bool introShownForStraight: false
    property bool introShownForReverse: false

    signal testCompleted(bool success)
    signal gameOver()

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
            height: column.implicitHeight + 40 // динамическая высота

            Column {
                id: column
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                Text {
                    text: introText
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
                        startNextRound()
                    }
                }
            }
        }
    }

    ToolButton {
        text: "\u2190"
        font.pixelSize: 24
        onClicked: root.stackViewRef.pop()
        Layout.alignment: Qt.AlignVCenter
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 10
        width: parent.width * 0.8

        Label {
            id: modeWarningLabel
            visible: !showingIntro && modeWarningLabel.visible
            font.pixelSize: 18
            color: "orange"
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            text: "Теперь вводите последовательность наоборот"
        }



        Item {
            width: parent.width
            height: 70



            Column {
                anchors.centerIn: parent
                spacing: 6


                Label {
                    id: resultLabelMain
                    visible: !showingIntro && showResult
                    font.pixelSize: 20
                    color: lastResultSuccess ? "green" : "red"
                    text: lastResultSuccess ? "Правильно!" : "Ошибка!"
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width  // <–– добавь эту строку
                }


                Label {
                    id: resultLabelSequence
                    visible: !showingIntro && showResult && !lastResultSuccess
                    font.pixelSize: 18
                    color: "red"
                    text: "Правильная последовательность:\n" +
                          (reverseMode ? currentSequence.slice().reverse().join("") : currentSequence.join(""))
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    id: digitDisplay
                    visible: !showingIntro && !showResult
                    font.pixelSize: 32
                    text: currentDigit
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        TextField {
            id: inputField
            visible: !showingIntro && errorsCount <= maxErrors
            readOnly: true
            font.pixelSize: 24
            placeholderText: ""
            text: ""

            Layout.preferredWidth: parent.width * 0.6
            Layout.alignment: Qt.AlignHCenter

            horizontalAlignment: Text.AlignHCenter  // Центрируем текст по горизонтали

            background: Rectangle {
                anchors.fill: parent
                color: "white"
                radius: 5
                border.color: "#aaa"
                border.width: 1
            }

            onTextChanged: {
                inputCounter.text = inputField.text.length + "/" + currentSequence.length
                submitButton.enabled = (inputField.text.length === currentSequence.length) && !isShowingSequence && errorsCount <= maxErrors
            }
        }

        Label {
            id: inputCounter
            text: "0/" + sequenceLength
            font.pixelSize: 16
            color: "#555"
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            visible: !showingIntro && errorsCount <= maxErrors
        }

        Label {
            id: errorCounterLabel
            text:"Можно допустить ещё " + (maxErrors - errorsCount) + " " + pluralForm(maxErrors - errorsCount, "ошибку", "ошибки", "ошибок")
            font.pixelSize: 16
            color: errorsCount > maxErrors ? "red" : "#555"
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            visible: !showingIntro && errorsCount <= maxErrors
        }

        GridLayout {
            id: keypad
            columns: 3
            visible: !showingIntro && errorsCount <= maxErrors
            enabled: !isShowingSequence && errorsCount <= maxErrors
            Layout.alignment: Qt.AlignHCenter
            columnSpacing: 10
            rowSpacing: 10
            width: parent.width * 0.7
            Repeater {
                model: 9
                delegate: Button {
                    text: index + 1
                    font.pixelSize: 24
                    enabled: keypad.enabled
                    onClicked: {
                        if (inputField.text.length < currentSequence.length) {
                            inputField.text += text
                        }
                    }
                }
            }

            Button {
                text: "0"
                font.pixelSize: 24
                Layout.columnSpan: 3
                Layout.alignment: Qt.AlignHCenter
                enabled: keypad.enabled
                onClicked: {
                    if (inputField.text.length < currentSequence.length) {
                        inputField.text += text
                    }
                }
            }
        }

        Button {
            id: submitButton
            text: "Проверить"
            visible: !showingIntro && errorsCount <= maxErrors
            enabled: false
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                const entered = inputField.text
                const correct = reverseMode ? currentSequence.slice().reverse().join("") : currentSequence.join("")
                lastResultSuccess = (entered === correct)
                showResult = true
                if (lastResultSuccess) {
                    // Обновляем максимум для текущего режима
                    if (!reverseMode) {
                        if (sequenceLength > maxStraightLength) {
                            maxStraightLength = sequenceLength
                            maxStraightSequence = currentSequence.slice()
                        }
                    } else {
                        if (sequenceLength > maxReverseLength) {
                            maxReverseLength = sequenceLength
                            maxReverseSequence = currentSequence.slice()
                        }
                    }
                    sequenceLength++
                } else {
                    errorsCount++
                    errorCounterLabel.text = "Можно допустить ещё " + (maxErrors - errorsCount) + " " + pluralForm(maxErrors - errorsCount, "ошибку", "ошибки", "ошибок")
                }

                testCompleted(lastResultSuccess)
                // Отключаем ввод и кнопку, но не меняем видимость — она управляется декларативно
                submitButton.enabled = false
                keypad.enabled = false
                inputField.enabled = false

                if (errorsCount > maxErrors) {
                    if (!reverseMode) {
                        // Переходим в обратный режим с предупреждением, если не показывали
                        reverseMode = true
                        errorsCount = 0
                        errorCounterLabel.text = "Можно допустить ещё " + (maxErrors - errorsCount) + " " + pluralForm(maxErrors - errorsCount, "ошибку", "ошибки", "ошибок")
                        sequenceLength = 2
                        showResult = false
                        inputField.text = ""
                        modeWarningLabel.visible = true
                        if (!introShownForReverse) {
                            introText = "Теперь вводите последовательность наоборот.\nБудьте внимательны!"
                            showingIntro = true
                            introShownForReverse = true
                            modeWarningLabel.visible = false
                        } else {
                            // Если предупреждение уже было — сразу показываем последовательность
                            modeWarningLabel.visible = true
                            Qt.createQmlObject(`
                                import QtQuick 2.0
                                Timer {
                                    interval: 3000
                                    running: true
                                    repeat: false
                                    onTriggered: {
                                        modeWarningLabel.visible = false
                                        root.startShowSequence()
                                    }
                                }
                            `, root, "ModeWarningTimer")
                        }

                        return
                    } else {
                        errorCounterLabel.visible = false
                        showResult = false
                        finalOverlay.visible = true
                        gameOver()
                        return
                    }
                }

                // Через 2 секунды начинаем следующий раунд
                Qt.createQmlObject(`
                    import QtQuick 2.0
                    Timer {
                        interval: 2000
                        running: true
                        repeat: false
                        onTriggered: {
                            showResult = false
                            root.startNextRound()
                        }
                    }
                `, root, "ResultTimer")
            }
        }
    }

    Rectangle {
        id: finalOverlay
        visible: !showingIntro && errorsCount > maxErrors && reverseMode
        anchors.fill: parent
        color: "#cc000000"
        z: 10

        Rectangle {
            id: finalBox
            width: Math.min(parent.width * 0.9, 500)
            color: "white"
            radius: 10
            opacity: 0.95
            anchors.centerIn: parent
            height: columnFinal.implicitHeight + 40

            Column {
                id: columnFinal
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                Text {
                    text: "Тест завершён"
                    font.pixelSize: 22
                    horizontalAlignment: Text.AlignHCenter
                    color: "black"
                    width: parent.width
                }

                Text {
                    text: "Максимальная длина прямой последовательности: " + maxStraightLength + "\n" +
                          "Максимальная длина обратной последовательности: " + maxReverseLength
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 18
                    color: "#333"
                    width: parent.width
                }

                Text {
                    text: interpretDigitSpanCombined(moduleData.age, maxStraightLength, maxReverseLength)
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 18
                    color: "#333"
                    width: parent.width
                }


                Button {
                    text: "Готово"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        gameOver()
                        root.stackViewRef.pop()
                        root.stackViewRef.pop()
                    }
                }
            }
        }
    }

    function pluralForm(n, form1, form2, form5) {
        if (n % 10 === 1 && n % 100 !== 11)
            return form1
        else if ([2,3,4].includes(n % 10) && ![12,13,14].includes(n % 100))
            return form2
        else
            return form5
    }


    function generateSequence(len) {
        let result = []
        for (let i = 0; i < len; i++) {
            result.push(Math.floor(Math.random() * 10))
        }
        return result
    }

    function showNext() {
        if (showIndex >= currentSequence.length && !showingDigit) {
            digitDisplay.text = ""
            isShowingSequence = false

            inputField.enabled = errorsCount <= maxErrors
            keypad.enabled = errorsCount <= maxErrors
            submitButton.visible = errorsCount <= maxErrors
            submitButton.enabled = (inputField.text.length === currentSequence.length) && errorsCount <= maxErrors
            inputCounter.visible = errorsCount <= maxErrors
            inputCounter.text = inputField.text.length + "/" + currentSequence.length
            errorCounterLabel.visible = errorsCount <= maxErrors
            errorCounterLabel.text = "Можно допустить ещё " + (maxErrors - errorsCount) + " " + pluralForm(maxErrors - errorsCount, "ошибку", "ошибки", "ошибок")
            inputField.focus = true

            return
        }

        if (showTimer) {
            showTimer.stop()
            showTimer.destroy()
            showTimer = null
        }

        if (!showingDigit) {
            digitDisplay.text = ""
            showingDigit = true
            showTimer = Qt.createQmlObject(`
                import QtQuick 2.0
                Timer {
                    interval: 500
                    running: true
                    repeat: false
                    onTriggered: root.showNext()
                }
            `, root, "PauseTimer")

        } else {
            digitDisplay.text = currentSequence[showIndex]
            showIndex++
            showingDigit = false
            showTimer = Qt.createQmlObject(`
                import QtQuick 2.0
                Timer {
                    interval: 1000
                    running: true
                    repeat: false
                    onTriggered: root.showNext()
                }
            `, root, "DigitTimer")
        }

        isShowingSequence = true

        inputField.enabled = false
        keypad.enabled = false
        submitButton.enabled = false
    }

    function startNextRound() {
        showResult = false
        inputField.text = ""
        submitButton.enabled = false
        keypad.enabled = false
        currentSequence = generateSequence(sequenceLength)

        // Показываем introOverlay ТОЛЬКО если для этого режима предупреждение еще не показывали
        if (!reverseMode) {
            if (!introShownForStraight) {
                introText = "Сейчас будет показана последовательность чисел.\nЗапомните их и введите по порядку."
                showingIntro = true
                introShownForStraight = true
                return
            }
        } else {
            if (!introShownForReverse) {
                introText = "Теперь вводите последовательность наоборот.\nБудьте внимательны!"
                showingIntro = true
                introShownForReverse = true
                return
            }
        }

        showSequence(currentSequence)
    }

    function startShowSequence() {
        showSequence(currentSequence)
    }

    function showSequence(seq) {
        digitDisplay.visible = true
        showIndex = 0
        currentSequence = seq
        inputField.text = ""
        inputCounter.text = "0/" + currentSequence.length
        inputCounter.visible = true
        errorCounterLabel.visible = true
        submitButton.enabled = false
        showNext()
    }

    function getNormRange(age, isBackward) {
        if (isBackward) {
            if (age <= 5) return [0, 0];
            else if (age <= 7) return [2, 3];
            else if (age <= 9) return [3, 4];
            else if (age <= 12) return [4, 5];
            else if (age <= 17) return [5, 6];
            else if (age <= 29) return [5, 7];
            else if (age <= 39) return [5, 6];
            else if (age <= 49) return [4, 6];
            else if (age <= 59) return [4, 5];
            else if (age <= 69) return [3, 5];
            else return [3, 4];
        } else {
            if (age <= 5) return [3, 4];
            else if (age <= 7) return [4, 5];
            else if (age <= 9) return [5, 6];
            else if (age <= 12) return [6, 7];
            else if (age <= 17) return [7, 8];
            else if (age <= 29) return [7, 9];
            else if (age <= 39) return [6, 8];
            else if (age <= 49) return [6, 7];
            else if (age <= 59) return [5, 7];
            else if (age <= 69) return [5, 6];
            else return [4, 6];
        }
    }

    function interpretSingle(score, range) {
        if (score < range[0])
            return { result: "Ниже возрастной нормы", level: -1 };
        else if (score > range[1])
            return { result: "Выше возрастной нормы", level: 1 };
        else
            return { result: "В пределах нормы", level: 0 };
    }

    function interpretDigitSpanCombined(age, forwardScore, backwardScore) {
        const forwardNorm = getNormRange(age, false);
        const backwardNorm = getNormRange(age, true);

        const forwardInterp = interpretSingle(forwardScore, forwardNorm);
        const backwardInterp = interpretSingle(backwardScore, backwardNorm);

        let summary = "";
        const f = forwardInterp.level;
        const b = backwardInterp.level;

        if (f === -1 && b === -1) {
            summary = "Оба результата ниже возрастной нормы. Возможны выраженные трудности с кратковременной и рабочей памятью.";
        } else if (f === 1 && b === 1) {
            summary = "Оба результата выше нормы. Отличная память и способности к переработке информации.";
        } else if (f === 0 && b === 0) {
            summary = "Оба результата соответствуют возрастной норме.";
        } else if (f === -1 && b >= 0) {
            summary = "Прямой ряд ниже нормы, обратный — в пределах нормы. Возможны трудности с кратковременным удержанием информации.";
        } else if (f >= 0 && b === -1) {
            summary = "Обратный ряд ниже нормы, прямой — в пределах нормы. Возможны трудности с рабочей памятью и переработкой информации.";
        } else if (f === 1 && b === 0) {
            summary = "Прямой ряд выше нормы, обратный — в норме. Хорошее удержание информации.";
        } else if (f === 0 && b === 1) {
            summary = "Обратный ряд выше нормы, прямой — в норме. Отличные способности к переработке и манипуляции информацией.";
        } else if (f === -1 && b === 1) {
            summary = "Прямой ряд ниже нормы, обратный — выше. Возможен дисбаланс между кратковременной и рабочей памятью.";
        } else if (f === 1 && b === -1) {
            summary = "Прямой ряд выше нормы, обратный — ниже. Хорошее запоминание, но сниженная способность к манипуляции информацией.";
        } else {
            summary = "Нестандартная комбинация результатов. Требуется дополнительная интерпретация.";
        }

        return  summary
    }

    Component.onCompleted: {
        startNextRound()
    }
}
