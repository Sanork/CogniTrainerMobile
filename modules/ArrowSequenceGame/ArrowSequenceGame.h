#ifndef ARROWSEQUENCEGAME_H
#define ARROWSEQUENCEGAME_H

#include "../../core/BaseModule.h"

class ArrowSequenceGame : public BaseModule
{
    Q_OBJECT

    Q_PROPERTY(QUrl iconArrowUrl READ iconArrowUrl CONSTANT)

public:
    explicit ArrowSequenceGame(QObject *parent = nullptr);

    QString name() const override;
    QString description() const override;
    //QString manual() const override;
    QUrl qmlComponentUrl() const override;
    QUrl qmlSettingsUrl() const override;
    QString category() const override;
    QUrl iconUrl() const override;
    QUrl iconArrowUrl() const;
};

#endif // ARROWSEQUENCEGAME_H
