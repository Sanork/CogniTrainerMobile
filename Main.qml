import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    visible: true
    width: 360
    height: 640
    title: qsTr("Когнитивное приложение")

    property int currentTab: 0

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        StackView {
            id: stackView
            Layout.fillWidth: true
            Layout.fillHeight: true

            initialItem: trainingsPageComponent
        }

        TabBar {
            Layout.fillWidth: true
            height: 56

            TabButton {
                text: "Тренировки"
                checked: currentTab === 0
                onClicked: {
                    if (currentTab !== 0) {
                        currentTab = 0
                        stackView.replace(trainingsPageComponent, { stackViewRef: stackView })
                    }
                }
            }

            TabButton {
                text: "Тесты"
                checked: currentTab === 1
                onClicked: {
                    if (currentTab !== 1) {
                        currentTab = 1
                        stackView.replace(testsPageComponent, { stackViewRef: stackView })
                    }
                }
            }

            TabButton {
                text: "Настройки"
                checked: currentTab === 2
                onClicked: {
                    if (currentTab !== 2) {
                        currentTab = 2
                        stackView.replace(settingsPageComponent)
                    }
                }
            }
        }
    }

    Component {
        id: trainingsPageComponent
        TrainingsPage {
            stackViewRef: stackView
        }
    }

    Component {
        id: testsPageComponent
        TestsPage {
            stackViewRef: stackView
        }
    }

    Component {
        id: settingsPageComponent
        SettingsPage { }
    }
}
