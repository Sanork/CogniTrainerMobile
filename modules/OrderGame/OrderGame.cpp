#include "OrderGame.h"

// Конструктор
OrderGame::OrderGame(QObject *parent)
    : BaseModule(parent), m_difficulty(1)  // Явный вызов конструктора базового класса
{
}

// Переопределяем метод name
QString OrderGame::name() const {
    return "Порядок карточек";
}

// Переопределяем метод description
QString OrderGame::description() const {
    return "Запомните и воспроизведите последовательность карточек";
}

// Переопределяем метод для ссылки на QML компонент
QUrl OrderGame::qmlComponentUrl() const {
    return QUrl("qrc:/modules/OrderGame/OrderGame.qml");
}

QUrl OrderGame::qmlSettingsUrl() const {
    return QUrl("qrc:/modules/OrderGame/OrderGameSettings.qml");
}
// Переопределяем метод category
QString OrderGame::category() const {
    return "Память";
}

// Переопределяем метод для иконки
QUrl OrderGame::iconUrl() const {
    return QUrl("qrc:/modules/OrderGame/OrderGameIcon.png");
}



int OrderGame::difficulty() const
{
    return m_difficulty;
}

void OrderGame::setDifficulty(int value)
{
    if (m_difficulty != value) {
        m_difficulty = value;
        emit difficultyChanged();
    }
}
