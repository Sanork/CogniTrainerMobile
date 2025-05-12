#include "CategoryManager.h"

static QList<Category> availableCategories = {
    { "Реакция", "qrc:/images/ReactionIcon.png" },
    { "Память", "qrc:/images/MemoryIcon.png" },
    { "Внимание", "qrc:/images/AttentionIcon.png" }
};

const QList<Category>& CategoryManager::getAvailableCategories()
{
    return availableCategories;
}

bool CategoryManager::isValidCategory(const QString& name)
{
    return std::any_of(availableCategories.begin(), availableCategories.end(), [&](const Category& c) {
        return c.name.trimmed().compare(name.trimmed(), Qt::CaseInsensitive) == 0;
    });
}

QVariantList CategoryManager::categories() const
{
    QVariantList result;
    for (const auto& c : availableCategories) {
        QVariantMap map;
        map["name"] = c.name;
        map["icon"] = c.iconPath;  // возвращаем путь к иконке
        result.append(map);
    }
    return result;
}
