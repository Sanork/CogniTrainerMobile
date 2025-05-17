#include "CircleGame.h"

// Конструктор
CircleGameModule::CircleGameModule(QObject *parent)
    : BaseModule(parent), m_difficulty(5)  // Явный вызов конструктора базового класса
{
}

// Переопределяем метод name
QString CircleGameModule::name() const {
    return "Случайный круг";
}

// Переопределяем метод description
QString CircleGameModule::description() const {
    return "Нажимайте на круг как можно быстрее";
}

// Переопределяем метод для ссылки на QML компонент
QUrl CircleGameModule::qmlComponentUrl() const {
    return QUrl("qrc:/modules/CircleGame/CircleGame.qml");
}

QUrl CircleGameModule::qmlSettingsUrl() const {
    return QUrl("qrc:/modules/CircleGame/CircleGameSettings.qml");
}
// Переопределяем метод category
QString CircleGameModule::category() const {
    return "Реакция";
}

// Переопределяем метод для иконки
QUrl CircleGameModule::iconUrl() const {
    return QUrl("qrc:/modules/CircleGame/CircleGameIcon.png");
}



int CircleGameModule::difficulty() const
{
    return m_difficulty;
}

void CircleGameModule::setDifficulty(int value)
{
    if (m_difficulty != value) {
        m_difficulty = value;
        emit difficultyChanged();
    }
}
