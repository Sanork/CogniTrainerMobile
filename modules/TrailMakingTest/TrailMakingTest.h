#ifndef TRAILMAKINGTEST_H
#define TRAILMAKINGTEST_H

#include "core/BaseModule.h"

class TrailMakingTest : public BaseModule
{
    Q_OBJECT
    Q_PROPERTY(int age READ age WRITE setAge NOTIFY ageChanged)

public:
    using BaseModule::BaseModule;
    explicit TrailMakingTest(QObject *parent = nullptr);

    QString name() const override;
    QString description() const override;
    QUrl qmlComponentUrl() const override;
    QUrl qmlSettingsUrl() const override;
    QString category() const override;
    QUrl iconUrl() const override;

    Q_INVOKABLE int age() const;


public slots:
    void setAge(int value);

signals:
    void ageChanged();

private:
    int m_age;
};

#endif // TRAILMAKINGTEST_H
