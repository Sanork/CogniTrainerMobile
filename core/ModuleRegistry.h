#ifndef MODULEREGISTRY_H
#define MODULEREGISTRY_H

#include <QObject>
#include "BaseModule.h"

class ModuleRegistry : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QList<QObject*> modules READ modules NOTIFY modulesChanged)

public:
    explicit ModuleRegistry(QObject *parent = nullptr);

    QList<QObject*> modules() const;

    Q_INVOKABLE void loadModules();

signals:
    void modulesChanged();

private:
    QList<QObject*> m_modules;
    void tryAddModule(BaseModule* module);
};

#endif // MODULEREGISTRY_H
