#pragma once
#include <QString>
#include <QIcon> // или QPixmap

struct Category {
    QString name;
    QString iconPath;

    Category(const QString& name, const QString& iconPath)
        : name(name), iconPath(QString(iconPath)) {}
};
