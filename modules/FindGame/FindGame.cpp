#include "FindGame.h"

// Конструктор
FindGame::FindGame(QObject *parent)
    : BaseModule(parent), m_difficulty(1)  // Явный вызов конструктора базового класса
{
}

// Переопределяем метод name
QString FindGame::name() const {
    return "Найди предмет";
}

// Переопределяем метод description
QString FindGame::description() const {
    return "Найди отличающуюся по цвету фигуру";
}

// Переопределяем метод для ссылки на QML компонент
QUrl FindGame::qmlComponentUrl() const {
    return QUrl("qrc:/modules/FindGame/FindGame.qml");
}

QUrl FindGame::qmlSettingsUrl() const {
    return QUrl("qrc:/modules/FindGame/FindGameSettings.qml");
}
// Переопределяем метод category
QString FindGame::category() const {
    return "Внимание";
}

// Переопределяем метод для иконки
QUrl FindGame::iconUrl() const {
    return QUrl("qrc:/modules/FindGame/FindGameIcon.png");
}



int FindGame::difficulty() const
{
    return m_difficulty;
}

void FindGame::setDifficulty(int value)
{
    if (m_difficulty != value) {
        m_difficulty = value;
        emit difficultyChanged();
    }
}

bool FindGame::endlessMode() const
{
    return m_endlessMode;
}

void FindGame::setEndlessMode(bool value)
{
    if (m_endlessMode != value) {
        m_endlessMode = value;
        emit endlessModeChanged();
    }
}
