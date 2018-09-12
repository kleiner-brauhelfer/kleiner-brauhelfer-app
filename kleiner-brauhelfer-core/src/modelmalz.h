#ifndef MODELMALZ_H
#define MODELMALZ_H

#include "sqltablemodel.h"

class Brauhelfer;

class ModelMalz : public SqlTableModel
{
public:
    ModelMalz(Brauhelfer* bh);
    QVariant dataExt(const QModelIndex &index) const Q_DECL_OVERRIDE;
    bool setDataExt(const QModelIndex &index, const QVariant &value) Q_DECL_OVERRIDE;
    QVariantMap defaultValues() const Q_DECL_OVERRIDE;
};

#endif // MODELMALZ_H
