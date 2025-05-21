import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes

Item {
    visible: true
    anchors.fill: parent

    property int clickCount: 0
    property int roundCount: 0
    property int totalRounds: 50
    property var moduleData

    Rectangle {
        id: root
        anchors.fill: parent
        color: "#ffffff"

        property int difficultyValue: moduleData ? moduleData.difficulty : 5


        // Верхняя панель
        Rectangle {
            id: topBar
            height: 56
            width: parent.width
            color: "#f0f0f0"
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
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

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "Круг: " + (roundCount+1 ) + " из " + totalRounds
                    font.pixelSize: 18
                    color: "#333333"
                    verticalAlignment: Text.AlignVCenter
                    visible: !gameOverOverlay.visible
                }
            }

        }

        // === Обратный отсчёт перед началом ===
        Item {
            id: countdownOverlay
            anchors.fill: parent
            visible: true
            z: 999

            property int countdownValue: 3

            Rectangle {
                id: countdownCircle
                width: 150
                height: 150
                radius: width / 2
                color: Qt.rgba(0, 0, 0, 0.6) // тёмный полупрозрачный
                anchors.centerIn: parent

                Text {
                    id: countdownText
                    text: countdownOverlay.countdownValue > 0 ? countdownOverlay.countdownValue : "Старт!"
                    anchors.centerIn: parent
                    font.pixelSize: 50
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Timer {
                id: countdownTimer
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    countdownOverlay.countdownValue--
                    if (countdownOverlay.countdownValue < 0) {
                        countdownTimer.stop()
                        countdownOverlay.visible = false
                        autoMoveTimer.start()
                        circle.visible = true
                        circle.moveToRandomPosition()
                    }
                }
            }
        }



        Rectangle {
            id: circle
            visible: false
            property int maxSize: 80
            property int minSize: 20

            width: {
                const clamped = Math.max(1, Math.min(10, root.difficultyValue))
                return maxSize - (clamped - 1) * ((maxSize - minSize) / 9)
            }
            height: width
            radius: width / 2
            color: "dodgerblue"

            // Учитываем верхнюю панель, чтобы круг не накрывал её
            function moveToRandomPosition() {
                const availableHeight = root.height - topBar.height;
                circle.x = Math.random() * (root.width - circle.width)
                circle.y = topBar.height + Math.random() * (availableHeight - circle.height)
            }



            Timer {
                           id: autoMoveTimer
                           interval: 2000 - (root.difficultyValue * 150)
                           running: false
                           repeat: true
                           onTriggered: {
                               // Если игра завершена — не продолжаем
                               if (roundCount >= totalRounds) {
                                   autoMoveTimer.stop()
                                   gameOverOverlay.visible = true
                                   return
                               }

                               roundCount++

                               // Красный след
                               var marker = Qt.createQmlObject(`
                                   import QtQuick 2.15
                                   Rectangle {
                                       id: marker
                                       width: ${circle.width}
                                       height: ${circle.height}
                                       radius: width / 2
                                       color: "#ff0000"
                                       opacity: 0.5
                                       x: ${circle.x}
                                       y: ${circle.y}
                                       z: -1

                                       SequentialAnimation {
                                           running: true
                                           PropertyAnimation {
                                               target: marker
                                               property: "opacity"
                                               to: 0
                                               duration: 800
                                           }
                                           ScriptAction {
                                               script: marker.destroy()
                                           }
                                       }
                                   }
                               `, hitMarkerLayer)


                               circle.moveToRandomPosition()
                           }
                       }

            MouseArea {
                           anchors.fill: parent
                           enabled: autoMoveTimer.running
                           onClicked: {
                               // Нажал — попадание
                               var marker = Qt.createQmlObject(`
                                   import QtQuick 2.15
                                   Rectangle {
                                       id: marker
                                       width: ${circle.width}
                                       height: ${circle.height}
                                       radius: width / 2
                                       color: "#00ff00"
                                       opacity: 0.5
                                       x: ${circle.x}
                                       y: ${circle.y}
                                       z: -1

                                       SequentialAnimation {
                                           running: true
                                           PropertyAnimation {
                                               target: marker
                                               property: "opacity"
                                               to: 0
                                               duration: 800
                                           }
                                           ScriptAction {
                                               script: marker.destroy()
                                           }
                                       }
                                   }
                               `, hitMarkerLayer)



                               clickCount++
                               roundCount++

                               if (roundCount >= totalRounds) {
                                   autoMoveTimer.stop()
                                   gameOverOverlay.visible = true
                               } else {
                                   circle.moveToRandomPosition()
                                   autoMoveTimer.restart()
                               }
                           }
                       }

                       Component.onCompleted: {

                       }
                   }

                   // Слой для маркеров
                   Item {
                       id: hitMarkerLayer
                       anchors.fill: parent
                   }





               }
    // === ОКНО ОКОНЧАНИЯ ИГРЫ ===
    Rectangle {
        id: gameOverOverlay
        visible: false
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)  // чёрный с 80% непрозрачности  // Почти полностью черный, но немного прозрачный
        z: 1000

        // Центрированный белый блок
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
                //horizontalAlignment: Qt.AlignHCenter

                Text {
                    text: "Тренировка\nокончена!"
                    font.pixelSize: 26
                    color: "black"
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "Точность: " + Math.round(clickCount / roundCount * 100) + " %"
                    font.pixelSize: 20
                    color: "black"
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Button {
                    text: "Сыграть снова"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        clickCount = 0
                        roundCount = 0
                        gameOverOverlay.visible = false

                        countdownOverlay.countdownValue = 3
                        countdownOverlay.visible = true
                        countdownTimer.start()

                        autoMoveTimer.stop()
                        circle.visible = false
                    }
                }

            }
        }
    }
           }
