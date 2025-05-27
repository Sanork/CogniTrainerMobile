#include "ReactGame.h"

// Конструктор
ReactGame::ReactGame(QObject *parent)
    : BaseModule(parent)  // Явный вызов конструктора базового класса
{
}

// Переопределяем метод name
QString ReactGame::name() const {
    return "Моментальная рекция";
}

// Переопределяем метод description
QString ReactGame::description() const {
    return "Нажмите на круг при появлении как можно быстрее";
}

// Переопределяем метод для ссылки на QML компонент
QUrl ReactGame::qmlComponentUrl() const {
    return QUrl("qrc:/modules/ReactGame/ReactGame.qml");
}

QUrl ReactGame::qmlSettingsUrl() const {
    return QUrl("qrc:/modules/ReactGame/ReactGameSettings.qml");
}
// Переопределяем метод category
QString ReactGame::category() const {
    return "Реакция";
}

// Переопределяем метод для иконки
QUrl ReactGame::iconUrl() const {
    return QUrl("qrc:/modules/ReactGame/ReactGameIcon.png");
}

bool ReactGame::endlessMode() const
{
    return m_endlessMode;
}

void ReactGame::setEndlessMode(bool value)
{
    if (m_endlessMode != value) {
        m_endlessMode = value;
        emit endlessModeChanged();
    }
}

