#include "CardGame.h"

// Конструктор
CardGame::CardGame(QObject *parent)
    : BaseModule(parent), m_difficulty(1)  // Явный вызов конструктора базового класса
{
}

// Переопределяем метод name
QString CardGame::name() const {
    return "Карточные пары";
}

// Переопределяем метод description
QString CardGame::description() const {
    return "Находите пары карт";
}

// Переопределяем метод для ссылки на QML компонент
QUrl CardGame::qmlComponentUrl() const {
    return QUrl("qrc:/modules/CardGame/CardGame.qml");
}

QUrl CardGame::qmlSettingsUrl() const {
    return QUrl("qrc:/modules/CardGame/CardGameSettings.qml");
}
// Переопределяем метод category
QString CardGame::category() const {
    return "Память";
}

// Переопределяем метод для иконки
QUrl CardGame::iconUrl() const {
    return QUrl("qrc:/modules/CardGame/СardGameIcon.png");
}



int CardGame::difficulty() const
{
    return m_difficulty;
}

void CardGame::setDifficulty(int value)
{
    if (m_difficulty != value) {
        m_difficulty = value;
        emit difficultyChanged();
    }
}
