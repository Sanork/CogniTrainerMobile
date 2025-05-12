import QtQuick
import QtQuick.Controls
import QtQuick.Shapes


Item {
    visible: true
    anchors.fill: parent

    property int clickCount: 0
    property var moduleData


    Rectangle {
        id: root
        anchors.fill: parent
        color: "#ffffff"

        property int difficultyValue: moduleData ? moduleData.difficulty : 5


        Rectangle {
            id: circle

            property int maxSize: 80
            property int minSize: 20


            width: {
                   const clamped = Math.max(1, Math.min(10, root.difficultyValue))
                   return maxSize - (clamped - 1) * ((maxSize - minSize) / 9)
               }
               height: width
               radius: width / 2
               color: "dodgerblue"

               function moveToRandomPosition() {
                           circle.x = Math.random() * (root.width - circle.width)
                           circle.y = Math.random() * (root.height - circle.height)
               }



               Timer {
                   id: autoMoveTimer
                   interval: 2000 - (root.difficultyValue * 150)
                   running: true
                   repeat: true
                   onTriggered: {

                       circle.moveToRandomPosition()
                   }
               }

               Component.onCompleted: {
                   autoMoveTimer.start()
               }

               MouseArea {
                   anchors.fill: parent
                   onClicked: {

                                       circle.moveToRandomPosition()
                                       clickCount++
                                       autoMoveTimer.restart()
                   }
               }
        }
        Text {
                   id: counterText
                   text: "Нажатий: " + clickCount
                   font.pixelSize: 24
                   color: "black"
                   anchors.horizontalCenter: parent.horizontalCenter
                   anchors.bottom: parent.bottom
                   anchors.bottomMargin: 80
               }
    }
}

