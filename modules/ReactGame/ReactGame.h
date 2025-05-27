#ifndef REACTGAME_H
#define REACTGAME_H

#include "core/BaseModule.h"


class ReactGame : public BaseModule
{
    Q_OBJECT
    Q_PROPERTY(bool endlessMode READ endlessMode WRITE setEndlessMode NOTIFY endlessModeChanged)

public:
    using BaseModule::BaseModule;
    explicit ReactGame(QObject *parent = nullptr);

    QString name() const override;
    QString description() const override;
    QUrl qmlComponentUrl() const override;
    QUrl qmlSettingsUrl() const override;
    QString category() const override;
    QUrl iconUrl() const override;


    Q_INVOKABLE bool endlessMode() const;

public slots:
    void setEndlessMode(bool value);

signals:
    void endlessModeChanged();

private:
    bool m_endlessMode;
};

#endif
