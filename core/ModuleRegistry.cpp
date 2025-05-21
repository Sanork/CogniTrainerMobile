#include "ModuleRegistry.h"
#include "../modules/CircleGame/CircleGame.h"
#include "../modules/CardGame/CardGame.h"
#include "../modules/SimonGame/SimonGame.h"
#include "../modules/StroopGame/StroopGame.h"
#include "../modules/FindGame/FindGame.h"

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
    tryAddModule(new CardGame(this));
    tryAddModule(new SimonGame(this));
    tryAddModule(new StroopGame(this));
    tryAddModule(new FindGame(this));


}

