#ifndef ORDERGAME_H
#define ORDERGAME_H

#include "core/BaseModule.h"

class OrderGame : public BaseModule
{
    Q_OBJECT
    Q_PROPERTY(int difficulty READ difficulty WRITE setDifficulty NOTIFY difficultyChanged)

public:
    using BaseModule::BaseModule;
    explicit OrderGame(QObject *parent = nullptr);

    QString name() const override;
    QString description() const override;
    QUrl qmlComponentUrl() const override;
    QUrl qmlSettingsUrl() const override;
    QString category() const override;
    QUrl iconUrl() const override;

    Q_INVOKABLE int difficulty() const;


public slots:
    void setDifficulty(int value);

signals:
    void difficultyChanged();

private:
    int m_difficulty;
};

#endif
