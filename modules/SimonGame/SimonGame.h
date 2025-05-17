#ifndef SIMONGAME_H
#define SIMONGAME_H

#include "core/BaseModule.h"

class SimonGame : public BaseModule
{
    Q_OBJECT

public:
    using BaseModule::BaseModule;
    explicit SimonGame(QObject *parent = nullptr);

    QString name() const override;
    QString description() const override;
    QUrl qmlComponentUrl() const override;
    QUrl qmlSettingsUrl() const override;
    QString category() const override;
    QUrl iconUrl() const override;



private:
    int m_difficulty;
};

#endif
