#ifndef REVERSETYPINGGAME_H
#define REVERSETYPINGGAME_H

#include "../../core/BaseModule.h"

class ReverseTypingGame : public BaseModule
{
    Q_OBJECT

    Q_PROPERTY(QString currentWord READ currentWord NOTIFY currentWordChanged)
    Q_PROPERTY(QUrl iconArrowUrl READ iconArrowUrl CONSTANT)

public:
    explicit ReverseTypingGame(QObject *parent = nullptr);

    QString name() const override;
    QString description() const override;
    //QString manual() const override;
    QUrl qmlComponentUrl() const override;
    QUrl qmlSettingsUrl() const override;
    QString category() const override;
    QUrl iconUrl() const override;
    QUrl iconArrowUrl() const ;

    QString currentWord() const;

    Q_INVOKABLE QString nextWord();
    Q_INVOKABLE bool checkAnswer(const QString &userInput);

signals:
    void currentWordChanged();
    void answerChecked(bool correct);

private:
    QString m_currentWord;
    QStringList m_wordList;
};

#endif // REVERSETYPINGGAME_H
