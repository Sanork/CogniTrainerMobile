#pragma once
#include "Category.h"
#include <QList>
#include <QObject>
#include <QVariantList>

class CategoryManager : public QObject
{
    Q_OBJECT

public:
    static const QList<Category>& getAvailableCategories();
    static bool isValidCategory(const QString& name);

    Q_INVOKABLE QVariantList categories() const;
};
