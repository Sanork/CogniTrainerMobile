#ifndef FINDGAME_H
#define FINDGAME_H

#include "core/BaseModule.h"

class FindGame : public BaseModule
{
    Q_OBJECT
    Q_PROPERTY(int difficulty READ difficulty WRITE setDifficulty NOTIFY difficultyChanged)
    Q_PROPERTY(bool endlessMode READ endlessMode WRITE setEndlessMode NOTIFY endlessModeChanged)

public:
    using BaseModule::BaseModule;
    explicit FindGame(QObject *parent = nullptr);

    QString name() const override;
    QString description() const override;
    QUrl qmlComponentUrl() const override;
    QUrl qmlSettingsUrl() const override;
    QString category() const override;
    QUrl iconUrl() const override;

    Q_INVOKABLE int difficulty() const;
    Q_INVOKABLE bool endlessMode() const;

public slots:
    void setDifficulty(int value);
    void setEndlessMode(bool value);

signals:
    void difficultyChanged();
    void endlessModeChanged();

private:
    int m_difficulty;
    bool m_endlessMode;;
};

#endif // FINDGAME_H
