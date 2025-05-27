#include "DigitSpanTest.h"

// Конструктор
DigitSpanTest::DigitSpanTest(QObject *parent)
    : BaseModule(parent), m_age(18)  // Явный вызов конструктора базового класса
{
}

// Переопределяем метод name
QString DigitSpanTest::name() const {
    return "Digit Span Test";
}

// Переопределяем метод description
QString DigitSpanTest::description() const {
    return "Повторяйте последовательность цифр";
}

// Переопределяем метод для ссылки на QML компонент
QUrl DigitSpanTest::qmlComponentUrl() const {
    return QUrl("qrc:/modules/DigitSpanTest/DigitSpanTest.qml");
}

QUrl DigitSpanTest::qmlSettingsUrl() const {
    return QUrl("qrc:/modules/DigitSpanTest/DigitSpanTestSettings.qml");
}
// Переопределяем метод category
QString DigitSpanTest::category() const {
    return "Тест";
}

// Переопределяем метод для иконки
QUrl DigitSpanTest::iconUrl() const {
    return QUrl("qrc:/modules/DigitSpanTest/DigitSpanTestIcon.png");
}


int DigitSpanTest::age() const
{
    return m_age;
}

void DigitSpanTest::setAge(int value)
{
    if (m_age != value) {
        m_age = value;
        emit ageChanged();
    }
}
