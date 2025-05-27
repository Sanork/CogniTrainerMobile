import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    anchors.fill: parent

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

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 10
        width: parent.width * 0.8

        Rectangle {
            id: introOverlay
            visible: showingIntro
            color: "#cc000000"
            radius: 10
            anchors.fill: parent
            z: 10

            Rectangle {
                color: "white"
                radius: 8
                anchors.centerIn: parent
                width: Math.min(parent.width * 0.8, 600)
                implicitHeight: contentColumn.implicitHeight + 40
                opacity: 0.95

                ColumnLayout {
                    id: contentColumn
                    width: parent.width - 40
                    spacing: 15

                    Label {
                        text: introText
                        font.pixelSize: Math.max(14, parent.width / 40)
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                        color: "black"
                    }

                    Button {
                        text: "Продолжить"
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: {
                            showingIntro = false
                            startNextRound()
                        }
                    }
                }
            }
        }

        Label {
            id: digitDisplay
            text: ""
            font.pixelSize: 40
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            visible: !showingIntro && errorsCount <= maxErrors && !showResult
            height: font.pixelSize * 2
        }

        Label {
            id: modeWarningLabel
            visible: !showingIntro && modeWarningLabel.visible
            font.pixelSize: 18
            color: "orange"
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            text: "Теперь вводите последовательность наоборот"
        }

        TextField {
            id: inputField
            visible: !showingIntro && !showResult && errorsCount <= maxErrors
            enabled: !isShowingSequence && errorsCount <= maxErrors
            placeholderText: reverseMode ? "Введите последовательность наоборот" : "Введите последовательность"
            font.pixelSize: 24
            readOnly: false
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            width: parent.width * 0.7
            inputMethodHints: Qt.ImhDigitsOnly

            onTextChanged: {
                if (inputField.text.length > currentSequence.length) {
                    inputField.text = inputField.text.slice(0, currentSequence.length)
                }
                submitButton.enabled = (inputField.text.length === currentSequence.length) && !isShowingSequence && errorsCount <= maxErrors
                inputCounter.text = inputField.text.length + " из " + currentSequence.length
            }
        }

        Label {
            id: inputCounter
            text: "0 из " + sequenceLength
            font.pixelSize: 16
            color: "#555"
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            visible: !showingIntro && !isShowingSequence && !showResult && errorsCount <= maxErrors
        }

        Label {
            id: errorCounterLabel
            text: "Ошибок: " + errorsCount + " из " + maxErrors
            font.pixelSize: 16
            color: errorsCount > maxErrors ? "red" : "#555"
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            visible: !showingIntro && errorsCount <= maxErrors
        }

        Label {
            id: resultLabelMain
            visible: !showingIntro && showResult
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            color: lastResultSuccess ? "green" : "red"
            text: lastResultSuccess ? "Правильно!" : "Ошибка!"
        }

        Label {
            id: resultLabelSequence
            visible: !showingIntro && showResult && !lastResultSuccess
            font.pixelSize: 18
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            color: "red"
            text: "Правильная последовательность:\n" + (reverseMode ? currentSequence.slice().reverse().join("") : currentSequence.join(""))
            wrapMode: Text.Wrap
        }

        Label {
            id: finalResultLabel
            visible: !showingIntro && errorsCount > maxErrors
            font.pixelSize: 18
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            color: "blue"
            wrapMode: Text.Wrap
            text: ""
        }

        GridLayout {
            id: keypad
            columns: 3
            visible: !showingIntro && errorsCount <= maxErrors && !showResult
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
            visible: !showingIntro && !isShowingSequence && errorsCount <= maxErrors && !showResult
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
                }

                testCompleted(lastResultSuccess)

                submitButton.enabled = false
                keypad.enabled = false
                inputField.enabled = false

                if (errorsCount > maxErrors) {
                    if (!reverseMode) {
                        // Переключаемся на обратный режим с предупреждением, если ещё не показывали
                        reverseMode = true
                        errorsCount = 0
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
                            // Если предупреждение уже было — просто сразу показываем последовательность, без показа intro и проверки
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
                        // Игра окончена во втором режиме — показываем обе максимальные последовательности
                        digitDisplay.text = "Игра окончена!"
                        errorCounterLabel.visible = false
                        inputField.visible = false
                        keypad.visible = false
                        submitButton.visible = false
                        inputCounter.visible = false
                        showResult = false

                        finalResultLabel.text =
                            "Максимальная длина прямой последовательности: " + maxStraightLength + "\n" +
                            maxStraightSequence.join("") + "\n\n" +
                            "Максимальная длина обратной последовательности: " + maxReverseLength + "\n" +
                            maxReverseSequence.slice().reverse().join("")
                        finalResultLabel.visible = true

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
            inputCounter.text = inputField.text.length + " из " + currentSequence.length

            errorCounterLabel.visible = errorsCount <= maxErrors
            errorCounterLabel.text = "Ошибок: " + errorsCount + " из " + maxErrors

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
        submitButton.visible = false
        submitButton.enabled = false

        inputCounter.visible = false
        errorCounterLabel.visible = false
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
        inputCounter.text = "0 из " + currentSequence.length
        inputCounter.visible = true
        errorCounterLabel.visible = true
        submitButton.enabled = false

        showNext()
    }

    Component.onCompleted: {
        startNextRound()
    }
}
