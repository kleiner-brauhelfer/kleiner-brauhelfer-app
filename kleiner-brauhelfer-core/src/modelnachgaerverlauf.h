#ifndef MODELNACHGAERVERLAUF_H
#define MODELNACHGAERVERLAUF_H

#include "sqltablemodel.h"
#include <QDateTime>

class Brauhelfer;

class ModelNachgaerverlauf : public SqlTableModel
{
public:
    ModelNachgaerverlauf(Brauhelfer* bh);
    QVariant dataExt(const QModelIndex &index) const Q_DECL_OVERRIDE;
    bool setDataExt(const QModelIndex &index, const QVariant &value) Q_DECL_OVERRIDE;
    QVariantMap defaultValues() const Q_DECL_OVERRIDE;
    QDateTime getLastDateTime(QString id = Q_NULLPTR) const;
    double getLastCO2(QString id = Q_NULLPTR) const;
private:
    Brauhelfer* bh;
};

#endif // MODELNACHGAERVERLAUF_H
