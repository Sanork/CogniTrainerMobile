import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import Qt.labs.settings 1.1

ApplicationWindow {
    id: root
    visible: true
    width: 360
    height: 640
    title: qsTr("Когнитивное приложение")
    Material.labelFontSize: 16

    Settings {
        id: appSettings
    }

    // Читаем тему из настроек один раз при старте
    property int savedTheme: Material.Light
    Component.onCompleted: {
        var themeStr = appSettings.value("theme", "light")
        console.log("Loaded theme from settings:", themeStr)
        Material.theme = themeStr === "dark" ? Material.Dark : Material.Light
    }

    // Реактивно меняем фон под тему
    Material.background: Material.theme === Material.Light ? "white" : "#1B232D"
    Material.accent: Material.Blue


    property int currentTab: 0

    property bool tabsVisible: true

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        StackView {
            id: stackView
            Layout.fillWidth: true
            Layout.fillHeight: true

            initialItem: trainingsPageComponent
        }

        Connections {
            target: stackView

            onPushTransitionChanged: {
                Qt.callLater(updateTabsVisibility)
            }
            onPopTransitionChanged: {
                Qt.callLater(updateTabsVisibility)
            }
        }

        function updateTabsVisibility() {
            const topItem = stackView.currentItem
            if (topItem && topItem.hidesTabs) {
                tabsVisible = false
            } else {
                tabsVisible = true
            }
        }


        TabBar {
            visible: tabsVisible
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
        SettingsPage {
            appSettingsRef: appSettings  // передаем Settings сюда
        }
    }


}
