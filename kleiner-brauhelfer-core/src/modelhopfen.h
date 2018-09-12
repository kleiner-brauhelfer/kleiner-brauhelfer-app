#ifndef MODELHOPFEN_H
#define MODELHOPFEN_H

#include "sqltablemodel.h"

class Brauhelfer;

class ModelHopfen : public SqlTableModel
{
public:
    ModelHopfen(Brauhelfer* bh);
    QVariant dataExt(const QModelIndex &index) const Q_DECL_OVERRIDE;
    bool setDataExt(const QModelIndex &index, const QVariant &value) Q_DECL_OVERRIDE;
    QVariantMap defaultValues() const Q_DECL_OVERRIDE;
};

#endif // MODELHOPFEN_H
