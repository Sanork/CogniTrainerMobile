#include "ArrowSequenceGame.h"

ArrowSequenceGame::ArrowSequenceGame(QObject *parent)
    : BaseModule(parent)
{}

QString ArrowSequenceGame::name() const
{
    return "Порядок стрелок";
}

QString ArrowSequenceGame::description() const
{
    return "Запоминайте и воспроизводите последовательность стрелок. "
           "Тренирует внимание, память и координацию.";
}

/*QString ArrowSequenceGame::manual() const
{
    return "- Смотрите на появляющуюся последовательность стрелок.\n"
           "- Введите её с клавиатуры в правильном порядке.\n"
           "- После ввода появится новая последовательность.\n"
           "- Тренировка заканчивается после заданного количества раундов.";
}*/

QUrl ArrowSequenceGame::qmlComponentUrl() const
{
    return QUrl("qrc:/modules/ArrowSequenceGame/ArrowSequenceGame.qml");
}

QUrl ArrowSequenceGame::qmlSettingsUrl() const
{
    return QUrl("qrc:/modules/ArrowSequenceGame/ArrowSequenceGameSettings.qml"); // Можно создать позже
}

QString ArrowSequenceGame::category() const
{
    return "Письмо и ввод";
}

QUrl ArrowSequenceGame::iconUrl() const
{
    return QUrl("qrc:/modules/ArrowSequenceGame/ArrowSequenceGameIcon.png");
}

QUrl ArrowSequenceGame::iconArrowUrl() const
{
    return QUrl("qrc:/modules/ArrowSequenceGame/leftArrow.png");
}
