#ifndef DIGITSPANTEST_H
#define DIGITSPANTEST_H

#include "core/BaseModule.h"

class DigitSpanTest : public BaseModule
{
    Q_OBJECT
    Q_PROPERTY(int age READ age WRITE setAge NOTIFY ageChanged)

public:
    using BaseModule::BaseModule;
    explicit DigitSpanTest(QObject *parent = nullptr);

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

#endif // DIGITSPANTEST_H
