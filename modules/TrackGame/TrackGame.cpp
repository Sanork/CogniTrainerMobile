#include "TrackGame.h"

// Конструктор
TrackGame::TrackGame(QObject *parent)
    : BaseModule(parent), m_difficulty(5)  // Явный вызов конструктора базового класса
{
}

// Переопределяем метод name
QString TrackGame::name() const {
    return "Удерживание";
}

// Переопределяем метод description
QString TrackGame::description() const {
    return "Держите палец в круге";
}

// Переопределяем метод для ссылки на QML компонент
QUrl TrackGame::qmlComponentUrl() const {
    return QUrl("qrc:/modules/TrackGame/TrackGame.qml");
}

QUrl TrackGame::qmlSettingsUrl() const {
    return QUrl("qrc:/modules/TrackGame/TrackGameSettings.qml");
}
// Переопределяем метод category
QString TrackGame::category() const {
    return "Реакция";
}

// Переопределяем метод для иконки
QUrl TrackGame::iconUrl() const {
    return QUrl("qrc:/modules/TrackGame/TrackGameIcon.png");
}



int TrackGame::difficulty() const
{
    return m_difficulty;
}

void TrackGame::setDifficulty(int value)
{
    if (m_difficulty != value) {
        m_difficulty = value;
        emit difficultyChanged();
    }
}

bool TrackGame::endlessMode() const
{
    return m_endlessMode;
}

void TrackGame::setEndlessMode(bool value)
{
    if (m_endlessMode != value) {
        m_endlessMode = value;
        emit endlessModeChanged();
    }
}
