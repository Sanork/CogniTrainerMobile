#ifndef BASEMODULE_H
#define BASEMODULE_H

#include <QObject>
#include <QString>
#include <QUrl>
#include <qdebug.h>
#include "CategoryManager.h"

class BaseModule : public QObject
{
    Q_OBJECT

    // Объявление свойств для работы с QML
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString description READ description CONSTANT)
    Q_PROPERTY(QUrl qmlComponentUrl READ qmlComponentUrl CONSTANT)
    Q_PROPERTY(QUrl qmlSettingsUrl READ qmlSettingsUrl CONSTANT)
    Q_PROPERTY(QString category READ category CONSTANT)
    Q_PROPERTY(QUrl iconUrl READ iconUrl CONSTANT)


public:
    explicit BaseModule(QObject *parent = nullptr)
        : QObject(parent)
    {

    }

    // Чисто виртуальные методы, которые должны быть реализованы в наследниках
    virtual QString name() const = 0;
    virtual QString description() const = 0;
    virtual QUrl qmlComponentUrl() const = 0;
    virtual QUrl qmlSettingsUrl() const = 0;
    virtual QString category() const = 0;
    virtual QUrl iconUrl() const = 0;

};

#endif // BASEMODULE_H
