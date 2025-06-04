cmake_minimum_required(VERSION 3.16)

project(CogniTrainerMobile VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 TextToSpeech)

qt_standard_project_setup(REQUIRES 6.8)

# Добавляем основной исполнимый файл
qt_add_executable(appCogniTrainerMobile
    main.cpp
)

qt_add_resources(appCogniTrainerMobile "app_images"
    PREFIX "/"
    FILES
        images
)
# Добавляем ресурсы в проект
qt_add_resources(appCogniTrainerMobile "app_qml"
    PREFIX "/qml"
    FILES
        Main.qml
        CategoryModulesView.qml
        SettingsPage.qml
        TestsPage.qml
        TrainingsPage.qml

)

qt_add_resources(appCogniTrainerMobile "app_modules"
    PREFIX "/"
    FILES
        modules/CircleGame/
        modules/CardGame/
        modules/SimonGame/
        modules/StroopGame/
        modules/FindGame/
        modules/ReactGame/
        modules/DigitSpanTest/
        modules/TrailMakingTest/
        modules/TrackGame/
        modules/TypingSpeedGame/
        modules/ReverseTypingGame/
        modules/ArrowSequenceGame/
)



# Подключаем QML-модуль, указывая файлы напрямую
qt_add_qml_module(appCogniTrainerMobile
    URI CogniTrainerMobile
    VERSION 1.0
    QML_FILES
        Main.qml

        modules/CircleGame/CircleGame.qml
        SOURCES core/BaseModule.h
        SOURCES modules/CircleGame/CircleGame.h modules/CircleGame/CircleGame.cpp
        SOURCES core/ModuleRegistry.h core/ModuleRegistry.cpp
        SOURCES core/Category.h
        SOURCES core/CategoryManager.h core/CategoryManager.cpp
        SOURCES modules/CardGame/CardGame.h modules/CardGame/CardGame.cpp
        QML_FILES modules/CardGame/CardGame.qml
        QML_FILES modules/CardGame/CardGameSettings.qml
        QML_FILES modules/CardGame/Card.qml
        SOURCES modules/SimonGame/SimonGame.h modules/SimonGame/SimonGame.cpp
        QML_FILES modules/SimonGame/SimonGameSettings.qml
        QML_FILES modules/SimonGame/SimonGame.qml
        QML_FILES modules/SimonGame/SimonButton.qml
        SOURCES modules/StroopGame/StroopGame.h modules/StroopGame/StroopGame.cpp
        QML_FILES modules/StroopGame/StroopGameSettings.qml
        QML_FILES modules/StroopGame/StroopGame.qml
        SOURCES modules/FindGame/FindGame.h modules/FindGame/FindGame.cpp
        QML_FILES modules/FindGame/FindGameSettings.qml
        QML_FILES modules/FindGame/FindGame.qml
        SOURCES modules/ReactGame/ReactGame.h modules/ReactGame/ReactGame.cpp
        QML_FILES modules/ReactGame/ReactGameSettings.qml
        QML_FILES modules/ReactGame/ReactGame.qml
        QML_FILES TrainingsPage.qml
        QML_FILES TestsPage.qml
        QML_FILES SettingsPage.qml
        SOURCES modules/DigitSpanTest/DigitSpanTest.h modules/DigitSpanTest/DigitSpanTest.cpp
        QML_FILES modules/DigitSpanTest/DigitSpanTestSettings.qml
        QML_FILES modules/DigitSpanTest/DigitSpanTest.qml
        QML_FILES
        SOURCES modules/TrailMakingTest/TrailMakingTest.h modules/TrailMakingTest/TtrailMakingTest.cpp
        QML_FILES modules/TrailMakingTest/TrailMakingTestSettings.qml
        QML_FILES modules/TrailMakingTest/TrailMakingTest.qml
        SOURCES
        SOURCES modules/TrackGame/TrackGame.h modules/TrackGame/TrackGame.cpp
        QML_FILES modules/TrackGame/TrackGameSettings.qml
        QML_FILES modules/TrackGame/TrackGame.qml
        SOURCES modules/TypingSpeedGame/TypingSpeedGame.h modules/TypingSpeedGame/TypingSpeedGame.cpp
        QML_FILES modules/TypingSpeedGame/TypingSpeedGameSettings.qml
        QML_FILES modules/TypingSpeedGame/TypingSpeedGame.qml
        SOURCES modules/ReverseTypingGame/ReverseTypingGame.h modules/ReverseTypingGame/ReverseTypingGame.cpp
        QML_FILES modules/ReverseTypingGame/ReverseTypingGameSettings.qml
        QML_FILES modules/ReverseTypingGame/ReverseTypingGame.qml
        SOURCES modules/ArrowSequenceGame/ArrowSequenceGame.h modules/ArrowSequenceGame/ArrowSequenceGame.cpp
        QML_FILES modules/ArrowSequenceGame/ArrowSequenceGameSettings.qml
        QML_FILES modules/ArrowSequenceGame/ArrowSequenceGame.qml
        QML_FILES AppLabel.qml
        #QML_FILES CategoryModulesView.qml
        #QML_FILES modules/CircleGame/CircleGameSettings.qml
        #RESOURCES resources.qrc

)

# Устанавливаем свойства для кроссплатформенных приложений
set_target_properties(appCogniTrainerMobile PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# Линкуем с Qt6
target_link_libraries(appCogniTrainerMobile
    PRIVATE Qt6::Quick
    Qt6::QuickControls2
    Qt6::TextToSpeech

)

# Устанавливаем пути для установки
include(GNUInstallDirs)
install(TARGETS appCogniTrainerMobile
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
