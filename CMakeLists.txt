cmake_minimum_required(VERSION 3.16)

project(CogniTrainerMobile VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

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

)

qt_add_resources(appCogniTrainerMobile "app_modules"
    PREFIX "/"
    FILES
        modules/
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
)

# Устанавливаем пути для установки
include(GNUInstallDirs)
install(TARGETS appCogniTrainerMobile
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
