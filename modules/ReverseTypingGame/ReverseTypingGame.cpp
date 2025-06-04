#include "ReverseTypingGame.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QDebug>
#include <QRandomGenerator>

ReverseTypingGame::ReverseTypingGame(QObject *parent)
    : BaseModule(parent)
{
    QFile file(":/modules/ReverseTypingGame/words.json");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Не удалось открыть words.json";
        return;
    }

    QByteArray jsonData = file.readAll();
    QJsonDocument doc = QJsonDocument::fromJson(jsonData);
    if (!doc.isArray()) {
        qWarning() << "words.json должен содержать JSON-массив";
        return;
    }

    QJsonArray arr = doc.array();
    for (const QJsonValue &val : arr) {
        if (val.isString()) {
            m_wordList.append(val.toString());
        }
    }
}

QString ReverseTypingGame::name() const
{
    return "Обратное письмо";
}

QString ReverseTypingGame::description() const
{
    return "Введите слово в обратном порядке. Тренировка внимания, памяти и моторики.";
}

/*QString ReverseTypingGame::manual() const
{
    return "- Вам будет показано слово.\n"
           "- Введите его наоборот (например, 'кот' → 'ток').\n"
           "- После правильного ввода появится следующее слово.\n"
           "- Бесконечный режим, без уровней сложности.";
}*/

QUrl ReverseTypingGame::qmlComponentUrl() const
{
    return QUrl("qrc:/modules/ReverseTypingGame/ReverseTypingGame.qml");
}

QUrl ReverseTypingGame::qmlSettingsUrl() const
{
    return QUrl("qrc:/modules/ReverseTypingGame/ReverseTypingGameSettings.qml");
}

QString ReverseTypingGame::category() const
{
    return "Письмо и ввод";
}

QUrl ReverseTypingGame::iconUrl() const
{
    return QUrl("qrc:/modules/ReverseTypingGame/ReverseTypingGameIcon.png");
}

QUrl ReverseTypingGame::iconArrowUrl() const
{
    return QUrl("qrc:/assets/leftArrow.png");
}

QString ReverseTypingGame::currentWord() const
{
    return m_currentWord;
}

QString ReverseTypingGame::nextWord()
{
    if (m_wordList.isEmpty()){
        qDebug()<< "В списке слов пусто!";
        return "";
    }


    int index = QRandomGenerator::global()->bounded(m_wordList.size());
    m_currentWord = m_wordList.at(index);

    qDebug() << "Текущее слово: "<< m_currentWord;
    emit currentWordChanged();
    return m_currentWord;
}

bool ReverseTypingGame::checkAnswer(const QString &userInput)
{
    QString reversed = m_currentWord;
    std::reverse(reversed.begin(), reversed.end());

    qDebug() << "Слова: " << userInput <<"  "<< reversed << m_currentWord;
    bool correct = (userInput == reversed);
    emit answerChecked(correct);

    if (correct)
        nextWord();

    return correct;
}
