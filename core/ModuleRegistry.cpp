#include "ModuleRegistry.h"
#include "../modules/CircleGame/CircleGame.h"  // Статически включённый модуль

ModuleRegistry::ModuleRegistry(QObject *parent)
    : QObject(parent)
{
}

QList<QObject*> ModuleRegistry::modules() const
{
    return m_modules;
}

void ModuleRegistry::tryAddModule(BaseModule* module)
{
    const QString cat = module->category().trimmed();

    if (!CategoryManager::isValidCategory(cat)) {
        qCritical().noquote() << QStringLiteral("Неверная категория в модуле '%1': %2")
                                     .arg(module->name(), cat);
        delete module;
        return;
    }

    m_modules.append(module);
    emit modulesChanged();
}


void ModuleRegistry::loadModules()
{
    tryAddModule(new CircleGameModule(this));  
}

