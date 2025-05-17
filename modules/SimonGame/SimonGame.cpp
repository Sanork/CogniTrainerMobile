#include "SimonGame.h"

// Конструктор
SimonGame::SimonGame(QObject *parent)
    : BaseModule(parent), m_difficulty(1)  // Явный вызов конструктора базового класса
{
}

// Переопределяем метод name
QString SimonGame::name() const {
    return "Саймон говорит";
}

// Переопределяем метод description
QString SimonGame::description() const {
    return "Повторите последовательность цветов";
}

// Переопределяем метод для ссылки на QML компонент
QUrl SimonGame::qmlComponentUrl() const {
    return QUrl("qrc:/modules/SimonGame/SimonGame.qml");
}

QUrl SimonGame::qmlSettingsUrl() const {
    return QUrl("qrc:/modules/SimonGame/SimonGameSettings.qml");
}
// Переопределяем метод category
QString SimonGame::category() const {
    return "Память";
}

// Переопределяем метод для иконки
QUrl SimonGame::iconUrl() const {
    return QUrl("qrc:/modules/SimonGame/SimonGameIcon.png");
}

