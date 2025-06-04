#include "StroopGame.h"

// Конструктор
StroopGame::StroopGame(QObject *parent)
    : BaseModule(parent), m_difficulty(1)  // Явный вызов конструктора базового класса
{
}

// Переопределяем метод name
QString StroopGame::name() const {
    return "Форма-цвет";
}

// Переопределяем метод description
QString StroopGame::description() const {
    return "Нужно выбирать цвет текста";
}

// Переопределяем метод для ссылки на QML компонент
QUrl StroopGame::qmlComponentUrl() const {
    return QUrl("qrc:/modules/StroopGame/StroopGame.qml");
}

QUrl StroopGame::qmlSettingsUrl() const {
    return QUrl("qrc:/modules/StroopGame/StroopGameSettings.qml");
}
// Переопределяем метод category
QString StroopGame::category() const {
    return "Внимание";
}

// Переопределяем метод для иконки
QUrl StroopGame::iconUrl() const {
    return QUrl("qrc:/modules/StroopGame/StroopGameIcon.png");
}



int StroopGame::difficulty() const
{
    return m_difficulty;
}

void StroopGame::setDifficulty(int value)
{
    if (m_difficulty != value) {
        m_difficulty = value;
        emit difficultyChanged();
    }
}


bool StroopGame::endlessMode() const
{
    return m_endlessMode;
}

void StroopGame::setEndlessMode(bool value)
{
    if (m_endlessMode != value) {
        m_endlessMode = value;
        emit endlessModeChanged();
    }
}

