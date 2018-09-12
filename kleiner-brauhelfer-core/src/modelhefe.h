#ifndef MODELHEFE_H
#define MODELHEFE_H

#include "sqltablemodel.h"

class Brauhelfer;

class ModelHefe : public SqlTableModel
{
public:
    ModelHefe(Brauhelfer* bh);
    QVariant dataExt(const QModelIndex &index) const Q_DECL_OVERRIDE;
    bool setDataExt(const QModelIndex &index, const QVariant &value) Q_DECL_OVERRIDE;
    QVariantMap defaultValues() const Q_DECL_OVERRIDE;
};

#endif // MODELHEFE_H
