#ifndef MODELAUSRUESTUNG_H
#define MODELAUSRUESTUNG_H

#include "sqltablemodel.h"

class Brauhelfer;

class ModelAusruestung : public SqlTableModel
{
public:
    ModelAusruestung(Brauhelfer* bh);
    QVariant dataExt(const QModelIndex &index) const Q_DECL_OVERRIDE;
    QVariantMap defaultValues() const Q_DECL_OVERRIDE;
    QString name(int id) const;
    int id(const QString& name) const;
private:
    Brauhelfer* bh;
};

#endif // MODELAUSRUESTUNG_H
