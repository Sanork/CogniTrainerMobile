#include "TypingSpeedGame.h"
#include <QFile>
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QDebug>



TypingSpeedGame::TypingSpeedGame(QObject *parent)
    : BaseModule(parent)
{
    QFile file(":/modules/TypingSpeedGame/sentences.json");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Не удалось открыть sentences.json";
        return;
    }

    QByteArray jsonData = file.readAll();
    QJsonDocument doc = QJsonDocument::fromJson(jsonData);
    if (!doc.isArray()) {
        qWarning() << "sentences.json должен содержать JSON-массив";
        return;
    }

    QJsonArray arr = doc.array();
    for (const QJsonValue &val : arr) {
        if (val.isString()) {
            m_sentences.append(val.toString());
        }
    }
    emit sentencesChanged();
}

QString TypingSpeedGame::name() const
{
    return "Скорость печати";
}

QString TypingSpeedGame::description() const
{
    return "Вводите появляющийся текст как можно быстрее. "
           "Программа измерит вашу скорость в символах в минуту.";
}

/*QString TypingSpeedGame::manual() const
{
    return "- Внимательно смотрите на текст, который появляется.\n"
           "- Старайтесь напечатать его без ошибок и как можно быстрее.\n"
           "- В конце вы увидите свою скорость и точность.\n";
}*/

QUrl TypingSpeedGame::qmlComponentUrl() const
{
    return QUrl("qrc:/modules/TypingSpeedGame/TypingSpeedGame.qml");
}

QUrl TypingSpeedGame::qmlSettingsUrl() const
{
    return QUrl("qrc:/modules/TypingSpeedGame/TypingSpeedGameSettings.qml"); // Настройки отсутствуют
}

QString TypingSpeedGame::category() const
{
    return "Письмо и ввод";
}

QUrl TypingSpeedGame::iconUrl() const
{
    return QUrl("qrc:/modules/TypingSpeedGame/TypingSpeedGameIcon.png");
}

QUrl TypingSpeedGame::iconArrowUrl() const
{
    return QUrl("qrc:/assets/leftArrow.png");
}

QStringList TypingSpeedGame::sentences() const {
    return m_sentences;
}
