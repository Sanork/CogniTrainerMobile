#include "TrailMakingTest.h"

// Конструктор
TrailMakingTest::TrailMakingTest(QObject *parent)
    : BaseModule(parent), m_age(18)  // Явный вызов конструктора базового класса
{
}

// Переопределяем метод name
QString TrailMakingTest::name() const {
    return "Trail Making Test";
}

// Переопределяем метод description
QString TrailMakingTest::description() const {
    return "Соединяйте числа";
}

// Переопределяем метод для ссылки на QML компонент
QUrl TrailMakingTest::qmlComponentUrl() const {
    return QUrl("qrc:/modules/TrailMakingTest/TrailMakingTest.qml");
}

QUrl TrailMakingTest::qmlSettingsUrl() const {
    return QUrl("qrc:/modules/TrailMakingTest/TrailMakingTestSettings.qml");
}
// Переопределяем метод category
QString TrailMakingTest::category() const {
    return "Тест";
}

// Переопределяем метод для иконки
QUrl TrailMakingTest::iconUrl() const {
    return QUrl("qrc:/modules/TrailMakingTest/TrailMakingTestIcon.png");
}


int TrailMakingTest::age() const
{
    return m_age;
}

void TrailMakingTest::setAge(int value)
{
    if (m_age != value) {
        m_age = value;
        emit ageChanged();
    }
}
